--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Bag frame widgets (search, sort/split/junk buttons, bag bar).
-- - Design: cargBags plugins and utility toggles for backpack/bank/account.
-- - Events: N/A — wired from InitBags container OnCreate.
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Bags")

local _G = _G
local C_AzeriteEmpoweredItem_IsAzeriteEmpoweredItemByID = _G.C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItemByID
local C_Bank_CanPurchaseBankTab = _G.C_Bank.CanPurchaseBankTab
local C_Bank_CanViewBank = _G.C_Bank.CanViewBank
local C_Container_GetContainerItemInfo = _G.C_Container.GetContainerItemInfo
local C_Container_SetInsertItemsLeftToRight = _G.C_Container.SetInsertItemsLeftToRight
local C_Container_SetSortBagsRightToLeft = _G.C_Container.SetSortBagsRightToLeft
local C_Container_SortAccountBankBags = _G.C_Container.SortAccountBankBags
local C_Item_GetItemInfo = _G.C_Item.GetItemInfo
local C_NewItems_IsNewItem = _G.C_NewItems.IsNewItem
local C_NewItems_RemoveNewItem = _G.C_NewItems.RemoveNewItem
local C_Soulbinds_IsItemConduitByItemInfo = _G.C_Soulbinds.IsItemConduitByItemInfo
local C_Spell_GetSpellName = _G.C_Spell.GetSpellName
local ClearCursor = _G.ClearCursor
local CreateFrame = _G.CreateFrame
local DeleteCursorItem = _G.DeleteCursorItem
local GameTooltip = _G.GameTooltip
local GetContainerItemID = _G.C_Container.GetContainerItemID
local GetContainerNumSlots = _G.C_Container.GetContainerNumSlots
local GetInventoryItemID = _G.GetInventoryItemID
local InCombatLockdown = _G.InCombatLockdown
local IsAltKeyDown = _G.IsAltKeyDown
local IsControlKeyDown = _G.IsControlKeyDown
local IsCosmeticItem = _G.C_Item.IsCosmeticItem
local PickupContainerItem = _G.C_Container.PickupContainerItem
local PlaySound = _G.PlaySound
local SortBags = _G.C_Container.SortBags
local SortBankBags = _G.C_Container.SortBankBags
local SplitContainerItem = _G.C_Container.SplitContainerItem
local StaticPopup_Hide = _G.StaticPopup_Hide
local StaticPopup_Show = _G.StaticPopup_Show
local StaticPopup_Visible = _G.StaticPopup_Visible
local ipairs = _G.ipairs
local pairs = _G.pairs
local select = _G.select
local string_lower = _G.string.lower
local string_match = _G.string.match
local table_insert = _G.table.insert
local table_wipe = _G.table.wipe
local tonumber = _G.tonumber
local tostring = _G.tostring
local type = _G.type
local unpack = _G.unpack

-- BagInit defines these as file locals too — widgets must not rely on a shared global.
local ACCOUNT_BANK_TYPE = _G.Enum.BankType.Account
local CHAR_BANK_TYPE = _G.Enum.BankType.Character

local isDeleteEnabled = false
local isFavouriteEnabled = false
local isSplitEnabled = false
local isCustomJunkEnabled = false
local toggleButtons = {}
-- ---------------------------------------------------------------------------
-- Search & Filtering
-- ---------------------------------------------------------------------------
local function searchHighlight(button, isMatch)
	button.searchOverlay:SetShown(not isMatch)
end

local function isSearchMatch(str, query)
	if type(str) ~= "string" then
		str = tostring(str)
	end

	if not str or str == "" then
		return false
	end
	return _G.string.find(string_lower(str), query, 1, true) ~= nil
end

local bagSmartFilter = {
	default = function(item, text)
		text = string_lower(text)
		if text == "boe" then
			return item.bindOn == "equip"
		elseif text == "aoe" then
			return item.bindOn == "accountequip"
		else
			return isSearchMatch(item.subType, text) or isSearchMatch(item.equipLoc, text) or isSearchMatch(item.name, text) or isSearchMatch((item.expacID or 0) + 1, text)
		end
	end,

	_default = "default",
}

function Module:CreateInfoFrame()
	-- REASON: Creates the utility section of the Backpack, housing the SearchBar for item filtering and the
	-- TagDisplay for quick currency/gold cross-referencing.
	local infoFrame = CreateFrame("Button", nil, self)
	infoFrame:SetPoint("TOPLEFT", 6, -8)
	infoFrame:SetSize(160, 18)

	local icon = infoFrame:CreateTexture(nil, "ARTWORK")
	icon:SetSize(22, 22)
	icon:SetPoint("LEFT", 0, 2)
	icon:SetTexture("Interface\\Minimap\\Tracking\\None")

	local hl = infoFrame:CreateTexture(nil, "HIGHLIGHT")
	hl:SetSize(22, 22)
	hl:SetPoint("LEFT", 0, 2)
	hl:SetTexture("Interface\\Minimap\\Tracking\\None")

	local searchBar = self:SpawnPlugin("SearchBar", infoFrame)
	searchBar.highlightFunction = searchHighlight
	searchBar.isGlobal = true
	searchBar:SetPoint("LEFT", 0, 6)
	searchBar:DisableDrawLayer("BACKGROUND")
	searchBar:CreateBackdrop()
	searchBar.textFilters = bagSmartFilter

	local currencyTag = self:SpawnPlugin("TagDisplay", "[currencies]", infoFrame)
	currencyTag:SetFontObject(K.UIFontOutline)
	currencyTag:SetFont(select(1, currencyTag:GetFont()), 13, select(3, currencyTag:GetFont()))
	currencyTag:SetPoint("TOP", _G.KKUI_BackpackBag, "BOTTOM", 0, -6)

	infoFrame.title = _G.SEARCH
	K.AddTooltip(infoFrame, "ANCHOR_TOPLEFT", K.InfoColorTint .. "|nClick to search your bag items.|nYou can type in item names or item equip locations.|n|n'boe' for items that bind on equip and 'quest' for quest items.")
end

-- ---------------------------------------------------------------------------
-- Widgets & Feature Toggles
-- ---------------------------------------------------------------------------
local isWidgetsHidden = true
local function toggleWidgetVisibility(self)
	-- REASON: To save space, utility buttons (Delete mode, Split mode, etc.) are hidden behind a toggle arrow.
	-- Closing them expands the Money tag's visibility, while opening them prioritizes the button list.
	isWidgetsHidden = not isWidgetsHidden

	local buttons = self.__owner.widgetButtons
	for index, button in ipairs(buttons) do
		if index > 2 then
			button:SetShown(not isWidgetsHidden)
		end
	end

	if isWidgetsHidden then
		self:SetPoint("RIGHT", buttons[2], "LEFT", -1, 0)
		K.SetupArrow(self.__texture, "left")
		self.moneyTag:Show()
	else
		self:SetPoint("RIGHT", buttons[#buttons], "LEFT", -1, 0)
		K.SetupArrow(self.__texture, "right")
		self.moneyTag:Hide()
	end
	self:Show()
end

function Module:CreateCollapseArrow()
	local collapseArrow = CreateFrame("Button", nil, self)
	collapseArrow:SetSize(16, 16)

	collapseArrow.Icon = collapseArrow:CreateTexture()
	collapseArrow.Icon:SetAllPoints()
	K.SetupArrow(collapseArrow.Icon, "right")
	collapseArrow.__texture = collapseArrow.Icon

	local moneyTag = self:SpawnPlugin("TagDisplay", "[money]", self)
	moneyTag:SetFontObject(K.UIFontOutline)
	moneyTag:SetFont(select(1, moneyTag:GetFont()), 13, select(3, moneyTag:GetFont()))
	moneyTag:SetPoint("RIGHT", collapseArrow, "LEFT", -12, 0)

	-- FIX: Previously created with UIParent as parent then immediately re-parented to self; redundant assignment removed.
	local moneyOverlay = CreateFrame("Frame", nil, self)
	moneyOverlay:SetAllPoints(moneyTag)
	moneyOverlay:SetScript("OnEnter", K.GoldButton_OnEnter)
	moneyOverlay:SetScript("OnLeave", K.GoldButton_OnLeave)

	collapseArrow.moneyTag = moneyTag
	collapseArrow.__owner = self
	isWidgetsHidden = not isWidgetsHidden -- REASON: Reset before initial toggle setup.
	toggleWidgetVisibility(collapseArrow)
	collapseArrow:SetScript("OnClick", toggleWidgetVisibility)

	collapseArrow.title = "Widgets Toggle"
	K.AddTooltip(collapseArrow, "ANCHOR_TOP")

	self.widgetArrow = collapseArrow
end

local function updateBagBarLayout(bar)
	local gap = 6
	local pad = 6
	local barW, barH = bar:LayoutButtons("grid", bar.columns, gap, pad, -pad)
	bar:SetSize(barW + pad * 2, barH + pad * 2)
end

function Module:CreateBagBar(settings, bagColumns)
	local bagBar = self:SpawnPlugin("BagBar", settings.Bags)
	local gap = 6
	local pad = 6
	local _, barH = bagBar:LayoutButtons("grid", bagColumns, gap, pad, -pad)
	local barW = bagColumns * (self.iconSize + gap) - gap
	bagBar:SetSize(barW + pad * 2, barH + pad * 2)
	bagBar:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, -6)
	bagBar:CreateBorder()
	bagBar.highlightFunction = searchHighlight
	bagBar.isGlobal = true
	bagBar:Hide()
	bagBar.columns = bagColumns
	bagBar.UpdateAnchor = updateBagBarLayout
	bagBar:UpdateAnchor()

	self.BagBar = bagBar
end

function Module:CreateBagTab(settings, columns, account)
	local bagTab = self:SpawnPlugin("BagTab", settings.Bags, account)
	bagTab:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, -6)
	bagTab:CreateBorder()
	bagTab.highlightFunction = searchHighlight
	bagTab.isGlobal = true
	bagTab:Hide()
	bagTab.columns = columns
	bagTab.UpdateAnchor = updateBagBarLayout
	bagTab:UpdateAnchor()

	local purchaseBtn = CreateFrame("Button", "KKUI_BankPurchaseButton", bagTab, "InsecureActionButtonTemplate")
	purchaseBtn:SetSize(120, 22)
	purchaseBtn:SetPoint("TOP", bagTab, "BOTTOM", 0, -5)
	K.CreateFontString(purchaseBtn, 14, _G.PURCHASE, "info")
	purchaseBtn:SkinButton()
	purchaseBtn:Hide()

	purchaseBtn:RegisterForClicks("AnyUp", "AnyDown")
	purchaseBtn:SetAttribute("type", "click")
	purchaseBtn:SetAttribute("clickbutton", _G.BankFrame.BankPanel.PurchasePrompt.TabCostFrame.PurchaseButton)

	self.BagBar = bagTab
end

local function handleCloseOrReset(self, btn)
	if btn == "RightButton" then
		-- REASON: Users often reposition bag containers during gameplay. This provides a quick "panic reset"
		-- that purges character-specific position variables and snaps all frames back to their default
		-- UI layout positions.
		local bag = self.__owner.main
		local bank = self.__owner.bank
		local account = self.__owner.accountbank
		local tempAnchors = K.GetCharVars()["TempAnchor"]
		tempAnchors[bag:GetName()] = nil
		tempAnchors[bank:GetName()] = nil
		tempAnchors[account:GetName()] = nil

		bag:ClearAllPoints()
		bag:SetPoint(unpack(bag.__anchor))
		bank:ClearAllPoints()
		bank:SetPoint(unpack(bank.__anchor))
		account:ClearAllPoints()
		account:SetPoint(unpack(bank.__anchor))
		PlaySound(_G.SOUNDKIT.IG_MINIMAP_OPEN)
	else
		Module:CloseBags()
	end
end

-- PERF: Helper to create and style utility buttons with consistent aesthetics.
function Module:CreateInventoryButton(parent, size, icon, title, clickFunc, isClose)
	local button = CreateFrame("Button", nil, parent)
	button:SetSize(size, size)
	button:CreateBorder(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, isClose and { 0.85, 0.25, 0.25 } or nil)
	button:StyleButton()

	button.Icon = button:CreateTexture(nil, "ARTWORK")
	button.Icon:SetTexture(icon)
	button.Icon:SetAllPoints()
	if not isClose then
		button.Icon:SetTexCoord(unpack(K.TexCoords))
	end

	if clickFunc then
		button:RegisterForClicks("AnyUp")
		button:SetScript("OnClick", clickFunc)
	end

	button.title = title
	K.AddTooltip(button, "ANCHOR_TOP")

	return button
end

function Module:CreateCloseButton(sourceFrame)
	-- REASON: Reuses the module-scope handleCloseOrReset directly; the previous inner closeClick closure
	-- was a verbatim 25-line duplicate of that function with no behavioral difference.
	local closeBtn = Module:CreateInventoryButton(self, 18, "Interface\\AddOns\\KkthnxUI\\Media\\Textures\\CloseButton_32", _G.CLOSE .. "/" .. _G.RESET, handleCloseOrReset, true)
	closeBtn.__owner = sourceFrame

	return closeBtn
end

function Module:CreateAccountBankButton()
	local clickFunc = function()
		if not C_Bank_CanViewBank(ACCOUNT_BANK_TYPE) then
			return
		end

		if BankFrame.BankPanel:ShouldShowLockPrompt() then
			_G.UIErrorsFrame:AddMessage(K.InfoColor .. _G.ACCOUNT_BANK_LOCKED_PROMPT)
		else
			PlaySound(_G.SOUNDKIT.IG_CHARACTER_INFO_TAB)
			BankFrame.BankPanel:SetBankType(ACCOUNT_BANK_TYPE)
		end
	end

	return Module:CreateInventoryButton(self, 18, 939373, _G.ACCOUNT_BANK_PANEL_TITLE, clickFunc)
end

function Module:CreateAccountMoney()
	local accountMoneyFrame = CreateFrame("Button", nil, self)
	accountMoneyFrame:SetSize(50, 22)

	local moneyTag = self:SpawnPlugin("TagDisplay", "[accountmoney]", self)
	moneyTag:SetFontObject(K.UIFontOutline)
	moneyTag:SetPoint("RIGHT", accountMoneyFrame, -2, 0)
	accountMoneyFrame.tag = moneyTag

	accountMoneyFrame:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	accountMoneyFrame:SetScript("OnClick", function(_, btn)
		if btn == "RightButton" then
			StaticPopup_Hide("BANK_MONEY_DEPOSIT")
			if StaticPopup_Visible("BANK_MONEY_WITHDRAW") then
				StaticPopup_Hide("BANK_MONEY_WITHDRAW")
			else
				StaticPopup_Show("BANK_MONEY_WITHDRAW", nil, nil, { bankType = ACCOUNT_BANK_TYPE })
			end
		else
			StaticPopup_Hide("BANK_MONEY_WITHDRAW")
			if StaticPopup_Visible("BANK_MONEY_DEPOSIT") then
				StaticPopup_Hide("BANK_MONEY_DEPOSIT")
			else
				StaticPopup_Show("BANK_MONEY_DEPOSIT", nil, nil, { bankType = ACCOUNT_BANK_TYPE })
			end
		end
	end)
	accountMoneyFrame.title = K.LeftButton .. _G.BANK_DEPOSIT_MONEY_BUTTON_LABEL .. "|n" .. K.RightButton .. _G.BANK_WITHDRAW_MONEY_BUTTON_LABEL
	K.AddTooltip(accountMoneyFrame, "ANCHOR_TOP")

	return accountMoneyFrame
end

function Module:CreateBankButton()
	local clickFunc = function()
		if not C_Bank_CanViewBank(CHAR_BANK_TYPE) then
			return
		end

		PlaySound(_G.SOUNDKIT.IG_CHARACTER_INFO_TAB)
		BankFrame.BankPanel:SetBankType(CHAR_BANK_TYPE)
	end

	return Module:CreateInventoryButton(self, 18, 413587, _G.BANK, clickFunc)
end

local function updateAccountBankDeposit(bu)
	if GetCVarBool("bankAutoDepositReagents") then
		bu.KKUI_Border:SetVertexColor(1, 0.8, 0)
	else
		K.SetBorderColor(bu.KKUI_Border)
	end
end

function Module:CreateAccountBankDeposit()
	local clickFunc = function(self, btn)
		if btn == "RightButton" then
			local isOn = GetCVarBool("bankAutoDepositReagents")
			SetCVar("bankAutoDepositReagents", isOn and 0 or 1)
			updateAccountBankDeposit(self)
		else
			_G.C_Bank.AutoDepositItemsIntoBank(ACCOUNT_BANK_TYPE)
		end
	end

	local button = Module:CreateInventoryButton(self, 18, 450905, _G.ACCOUNT_BANK_DEPOSIT_BUTTON_LABEL, clickFunc)
	self.accountDepositButton = button
	updateAccountBankDeposit(button)

	return button
end

local function toggleBagBar(self)
	local parentFrame = self.__owner
	if not parentFrame.BagBar then
		return
	end

	K.TogglePanel(parentFrame.BagBar)
	if parentFrame.BagBar:IsShown() then
		self.KKUI_Border:SetVertexColor(1, 0.8, 0)
		PlaySound(_G.SOUNDKIT.IG_BACKPACK_OPEN)
	else
		K.SetBorderColor(self.KKUI_Border)
		PlaySound(_G.SOUNDKIT.IG_BACKPACK_CLOSE)
	end
end

function Module:CreateBagToggle()
	local button = Module:CreateInventoryButton(self, 18, "Interface\\Buttons\\Button-Backpack-Up", _G.BACKPACK_TOOLTIP, toggleBagBar)
	button.__owner = self

	return button
end

function Module:CreateSortButton(btnName)
	local clickFunc = function()
		if btnName == "Bank" then
			SortBankBags()
		elseif btnName == "Account" then
			C_Container_SortAccountBankBags()
		else
			-- Sorting reorganizes the bag — drop Recent membership.
			if Module.ClearRecentBackpack then
				Module:ClearRecentBackpack()
			end
			if C["Inventory"].ReverseSort then
				if InCombatLockdown() then
					_G.UIErrorsFrame:AddMessage(K.InfoColor .. _G.ERR_NOT_IN_COMBAT)
				else
					SortBags()
					table_wipe(Module._sortCache)
					Module.Bags.isSorting = true
					K.Delay(0.5, Module.ReverseSort)
				end
			else
				SortBags()
			end
		end
	end

	return Module:CreateInventoryButton(self, 18, "Interface\\Icons\\INV_Pet_Broom", "Sort", clickFunc)
end

function Module:GetContainerEmptySlot(bagID)
	-- REASON: Scans a container for the first available empty slot index. This is a performance optimization
	-- to avoid calling the full 'GetEmptySlot' logic if the bag ID is already known (e.g., during specific transfers).
	for slotID = 1, GetContainerNumSlots(bagID) do
		if not GetContainerItemID(bagID, slotID) then
			return slotID
		end
	end
end

function Module:GetEmptySlot(context)
	-- REASON: Resolves the first available empty slot across multiple bags based on the intended destination
	-- (e.g., standard bags vs bank vs warband bank). This is critical for automated item transfers like 'Quick Split'.
	if context == "Bag" then
		for bagID = 0, 4 do
			local slotID = Module:GetContainerEmptySlot(bagID)
			if slotID then
				return bagID, slotID
			end
		end
	elseif context == "Bank" then
		for bagID = 6, 11 do
			local nextSlotID = Module:GetContainerEmptySlot(bagID)
			if nextSlotID then
				return bagID, nextSlotID
			end
		end
	elseif context == "BagReagent" then
		local slotID = Module:GetContainerEmptySlot(5)
		if slotID then
			return 5, slotID
		end
	elseif context == "Account" then
		for bagID = 12, 16 do
			local slotID = Module:GetContainerEmptySlot(bagID)
			if slotID then
				return bagID, slotID
			end
		end
	end
end

function Module:FreeSlotOnDrop()
	-- REASON: User-convenience feature: dragging an item to the 'Free Space' indicator in the bag will
	-- automatically place it into the first available slot, mirroring the behavior of regular slots.
	local bagID, slotID = Module:GetEmptySlot(self.__name)
	if slotID then
		PickupContainerItem(bagID, slotID)
	end
end

local FREE_SLOT_CONTAINERS = {
	["Bag"] = true,
	["Bank"] = true,
	["BagReagent"] = true,
	["Account"] = true,
}

function Module:CreateFreeSlots()
	local sourceName = self.name
	if not FREE_SLOT_CONTAINERS[sourceName] then
		return
	end

	local slotFrame = CreateFrame("Button", sourceName .. "FreeSlot", self)
	slotFrame:SetSize(self.iconSize, self.iconSize)
	slotFrame:CreateBorder(nil, nil, nil, nil, nil, nil, "Interface\\PaperDoll\\UI-PaperDoll-Slot-Bag", nil, nil, nil, { 1, 1, 1 })
	slotFrame:StyleButton()
	slotFrame:SetScript("OnMouseUp", Module.FreeSlotOnDrop)
	slotFrame:SetScript("OnReceiveDrag", Module.FreeSlotOnDrop)
	-- FIX: "_G.ANCHOR_RIGHT" was a Lua source string literal, not the anchor value "ANCHOR_RIGHT".
	-- GameTooltip:SetOwner would not recognise it, causing silent tooltip positioning fallback.
	K.AddTooltip(slotFrame, "ANCHOR_RIGHT", "FreeSlots")
	slotFrame.__name = sourceName

	local spaceTag = self:SpawnPlugin("TagDisplay", "|cff5C8BCF[space]|r", slotFrame)
	spaceTag:SetFontObject(K.UIFontOutline)
	spaceTag:SetFont(select(1, spaceTag:GetFont()), 16, select(3, spaceTag:GetFont()))
	spaceTag:SetPoint("CENTER", 0, 0)
	spaceTag.__name = sourceName

	self.freeSlot = slotFrame
end

function Module:SelectToggleButton(activeID)
	-- REASON: Ensures mutual exclusivity among the primary utility modes (Split, Favourite, Junk, Delete).
	-- Activating one mode automatically deactivates any existing mode to prevent logic conflicts.
	for index, button in ipairs(toggleButtons) do
		if index ~= activeID then
			button.__turnOff()
		end
	end
end

local function saveStackSplitCount(self)
	local input = self:GetText() or ""
	K.GetCharVars().SplitCount = tonumber(input) or 1
end

local function clearActiveFocus(self)
	self:ClearFocus()
end

function Module:CreateSplitButton()
	local splitFrame = CreateFrame("Frame", nil, self)
	splitFrame:SetSize(100, 50)
	splitFrame:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -6)
	K.CreateFontString(splitFrame, 14, L["Split Count"], "", "system", "TOP", 1, -5)
	splitFrame:CreateBorder()
	splitFrame:Hide()

	local editBox = CreateFrame("EditBox", nil, splitFrame)
	editBox:CreateBorder()
	editBox:SetWidth(90)
	editBox:SetHeight(20)
	editBox:SetAutoFocus(false)
	editBox:SetTextInsets(5, 5, 0, 0)
	editBox:SetFontObject(K.UIFontOutline)
	editBox:SetPoint("BOTTOMLEFT", 5, 5)
	editBox:SetScript("OnEscapePressed", clearActiveFocus)
	editBox:SetScript("OnEnterPressed", clearActiveFocus)
	editBox:SetScript("OnTextChanged", saveStackSplitCount)

	local splitBtn = CreateFrame("Button", nil, self)
	splitBtn:SetSize(18, 18)
	splitBtn:CreateBorder()
	splitBtn:StyleButton()

	splitBtn.Icon = splitBtn:CreateTexture(nil, "ARTWORK")
	splitBtn.Icon:SetPoint("TOPLEFT", -1, 3)
	splitBtn.Icon:SetPoint("BOTTOMRIGHT", 1, -3)
	splitBtn.Icon:SetTexCoord(unpack(K.TexCoords))
	splitBtn.Icon:SetTexture("Interface\\HELPFRAME\\ReportLagIcon-AuctionHouse")

	splitBtn.__turnOff = function()
		K.SetBorderColor(splitBtn.KKUI_Border)
		splitBtn.Icon:SetDesaturated(false)
		splitBtn.text = nil
		splitFrame:Hide()
		isSplitEnabled = false
	end

	splitBtn:SetScript("OnClick", function(self)
		Module:SelectToggleButton(1)
		isSplitEnabled = not isSplitEnabled
		if isSplitEnabled then
			self.KKUI_Border:SetVertexColor(1, 0, 0)
			self.Icon:SetDesaturated(true)
			self.text = K.SystemColor .. L["StackSplitEnable"]
			splitFrame:Show()
			editBox:SetText(K.GetCharVars().SplitCount)
		else
			self.__turnOff()
		end
		self:GetScript("OnEnter")(self)
	end)
	splitBtn:SetScript("OnHide", splitBtn.__turnOff)
	splitBtn.title = L["Quick Split"]
	K.AddTooltip(splitBtn, "ANCHOR_TOP")

	toggleButtons[1] = splitBtn
	return splitBtn
end

local function handleStackSplit(self)
	-- REASON: Logic for splitting stacks on click when 'Split Mode' is active. Deferring the move
	-- to an empty slot until the split is confirmed by the server ensures no item loss or UI desync.
	if not isSplitEnabled then
		return
	end

	PickupContainerItem(self.bagId, self.slotId)
	local itemInfo = C_Container_GetContainerItemInfo(self.bagId, self.slotId)
	local texture = itemInfo and itemInfo.iconFileID
	local stackCount = itemInfo and itemInfo.stackCount
	local isLocked = itemInfo and itemInfo.isLocked
	local splitAmt = K.GetCharVars().SplitCount

	if texture and not isLocked and stackCount and stackCount > splitAmt then
		SplitContainerItem(self.bagId, self.slotId, splitAmt)
		local destBag, destSlot = Module:GetEmptySlot("Bag")
		if destSlot then
			PickupContainerItem(destBag, destSlot)
		end
	end
end

function Module:GetCustomGroupTitle(id)
	return K.GetCharVars().CustomNames[id] or (_G.CUSTOM .. " " .. _G.FILTER .. " " .. id)
end

_G.StaticPopupDialogs["KKUI_RENAMECUSTOMGROUP"] = {
	text = _G.BATTLE_PET_RENAME,
	button1 = _G.OKAY,
	button2 = _G.CANCEL,
	OnAccept = function(self)
		local groupId = Module.selectGroupIndex
		local newName = self.editBox:GetText()
		K.GetCharVars().CustomNames[groupId] = newName ~= "" and newName or nil

		Module.CustomMenu[groupId + 2].text = Module:GetCustomGroupTitle(groupId)
		Module.ContainerGroups["Bag"][groupId].label:SetText(Module:GetCustomGroupTitle(groupId))
		Module.ContainerGroups["Bank"][groupId].label:SetText(Module:GetCustomGroupTitle(groupId))
	end,
	EditBoxOnEscapePressed = function(self)
		self:GetParent():Hide()
	end,
	whileDead = 1,
	showAlert = 1,
	hasEditBox = 1,
	editBoxWidth = 250,
}

function Module:RenameCustomGroup(id)
	Module.selectGroupIndex = id
	StaticPopup_Show("KKUI_RENAMECUSTOMGROUP")
end

function Module:MoveItemToCustomBag(id)
	-- REASON: Reassigns an item to a specific virtual custom bag index. This allows users to create
	-- their own categories (e.g., 'Consumables', 'Gear Sets') that aren't natively supported.
	local targetID = Module.selectItemID
	if id == 0 then
		if K.GetCharVars().CustomItems[targetID] then
			K.GetCharVars().CustomItems[targetID] = nil
		end
	else
		K.GetCharVars().CustomItems[targetID] = id
	end
	Module:UpdateAllBags()
end

function Module:IsItemInCustomBag()
	local groupId = self.arg1
	local targetID = Module.selectItemID
	return (groupId == 0 and not K.GetCharVars().CustomItems[targetID]) or (K.GetCharVars().CustomItems[targetID] == groupId)
end

function Module:CreateFavouriteButton()
	local customMenuList = {
		{
			text = "",
			icon = 134400,
			isTitle = true,
			notCheckable = true,
			tCoordLeft = 0.08,
			tCoordRight = 0.92,
			tCoordTop = 0.08,
			tCoordBottom = 0.92,
		},
		{ text = _G.NONE, arg1 = 0, func = Module.MoveItemToCustomBag, checked = Module.IsItemInCustomBag },
	}
	for i = 1, 5 do
		table_insert(customMenuList, {
			text = Module:GetCustomGroupTitle(i),
			arg1 = i,
			func = Module.MoveItemToCustomBag,
			checked = Module.IsItemInCustomBag,
			hasArrow = true,
			menuList = { { text = _G.BATTLE_PET_RENAME, arg1 = i, func = Module.RenameCustomGroup } },
		})
	end
	Module.CustomMenu = customMenuList

	local favBtn = Module:CreateInventoryButton(self, 18, "Interface\\Common\\friendship-heart", L["Custom Filter Mode"], function(self)
		Module:SelectToggleButton(2)
		isFavouriteEnabled = not isFavouriteEnabled
		if isFavouriteEnabled then
			self.KKUI_Border:SetVertexColor(1, 0, 0)
			self.Icon:SetDesaturated(true)
			self.text = K.SystemColor .. L["Custom Filter Mode Enabled"]
		else
			self.__turnOff()
		end
		self:GetScript("OnEnter")(self)
	end)

	favBtn.Icon:SetPoint("TOPLEFT", -4, 3.5)
	favBtn.Icon:SetPoint("BOTTOMRIGHT", 4, -2.5)

	favBtn.__turnOff = function()
		K.SetBorderColor(favBtn.KKUI_Border)
		favBtn.Icon:SetDesaturated(false)
		favBtn.text = nil
		isFavouriteEnabled = false
	end
	favBtn:SetScript("OnHide", favBtn.__turnOff)
	favBtn.title = L["Custom Filter Mode"]
	K.AddTooltip(favBtn, "ANCHOR_TOP")

	toggleButtons[2] = favBtn
	return favBtn
end

local function handleFavouriteTagging(self)
	-- REASON: Opens the custom assignment menu for an item when 'Favourite Mode' is active.
	-- This allows rapid categorization of items into virtual sub-bags.
	if not isFavouriteEnabled then
		return
	end

	local itemData = C_Container_GetContainerItemInfo(self.bagId, self.slotId)
	local icon = itemData and itemData.iconFileID
	local rarity = itemData and itemData.quality
	local itemLink = itemData and itemData.hyperlink
	local targetID = itemData and itemData.itemID

	if icon and rarity and rarity > _G.Enum.ItemQuality.Poor then
		ClearCursor()
		Module.selectItemID = targetID
		Module.CustomMenu[1].text = itemLink
		Module.CustomMenu[1].icon = icon
		K.LibEasyMenu.Create(Module.CustomMenu, K.EasyMenu, self, 0, 0, "MENU")
	end
end

function Module:CreateJunkButton()
	local junkBtn = Module:CreateInventoryButton(self, 18, "Interface\\BUTTONS\\UI-GroupLoot-Coin-Up", _G.CUSTOM .. " " .. _G.BAG_FILTER_JUNK, function(self)
		Module:SelectToggleButton(3)
		isCustomJunkEnabled = not isCustomJunkEnabled
		if isCustomJunkEnabled then
			self.KKUI_Border:SetVertexColor(1, 0, 0)
			self.Icon:SetDesaturated(true)
			self.text = K.InfoColor .. "|nClick an item to tag it as junk.|n|nIf 'Module Autosell' is enabled, these items will be sold as well.|n|nThe list is saved account-wide."
		else
			self.__turnOff()
		end
		self:GetScript("OnEnter")(self)
		Module:UpdateAllBags()
	end)

	junkBtn.Icon:SetPoint("TOPLEFT", 1, -2)
	junkBtn.Icon:SetPoint("BOTTOMRIGHT", -1, -2)

	junkBtn.__turnOff = function()
		K.SetBorderColor(junkBtn.KKUI_Border)
		junkBtn.Icon:SetDesaturated(false)
		junkBtn.text = nil
		isCustomJunkEnabled = false
	end

	junkBtn:SetScript("OnHide", junkBtn.__turnOff)
	toggleButtons[3] = junkBtn
	return junkBtn
end

local function handleJunkTagging(self)
	-- REASON: Toggles an item's status in the user-defined custom junk list.
	-- This list is integrated with the AutoSell module for automated vendor interactions.
	if not isCustomJunkEnabled then
		return
	end

	local itemData = C_Container_GetContainerItemInfo(self.bagId, self.slotId)
	local icon = itemData and itemData.iconFileID
	local targetID = itemData and itemData.itemID
	local sellPrice = select(11, C_Item_GetItemInfo(targetID))
	if icon and sellPrice and sellPrice > 0 then
		local junkList = K.GetCharVars().CustomJunkList
		if junkList[targetID] then
			junkList[targetID] = nil
		else
			junkList[targetID] = true
		end
		ClearCursor()
		Module:UpdateAllBags()
	end
end

function Module:CreateDeleteButton()
	local delBtn = Module:CreateInventoryButton(self, 18, "Interface\\Buttons\\UI-GroupLoot-Pass-Up", L["Item Delete Mode"], function(self)
		Module:SelectToggleButton(4)
		isDeleteEnabled = not isDeleteEnabled
		if isDeleteEnabled then
			self.KKUI_Border:SetVertexColor(1, 0, 0)
			self.Icon:SetDesaturated(true)
			self.text = K.SystemColor .. L["Delete Mode Enabled"]
		else
			self.__turnOff()
		end
		self:GetScript("OnEnter")(self)
	end)

	delBtn.Icon:SetPoint("TOPLEFT", 3, -2)
	delBtn.Icon:SetPoint("BOTTOMRIGHT", -1, 2)

	delBtn.__turnOff = function()
		K.SetBorderColor(delBtn.KKUI_Border)
		delBtn.Icon:SetDesaturated(false)
		delBtn.text = nil
		isDeleteEnabled = false
	end

	delBtn:SetScript("OnHide", delBtn.__turnOff)
	toggleButtons[4] = delBtn
	return delBtn
end

local function handleItemDeletion(self)
	-- REASON: Instantly deletes an item if 'Delete Mode' is active and Alt+Ctrl are held.
	-- This is a high-risk feature, so multiple modifier keys and a quality check (below Rare)
	-- are enforced to prevent accidental loss of valuable gear.
	if not isDeleteEnabled then
		return
	end

	local itemData = C_Container_GetContainerItemInfo(self.bagId, self.slotId)
	local icon = itemData and itemData.iconFileID
	local rarity = itemData and itemData.quality
	if IsControlKeyDown() and IsAltKeyDown() and icon and rarity and (rarity < _G.Enum.ItemQuality.Rare) then
		PickupContainerItem(self.bagId, self.slotId)
		DeleteCursorItem()
	end
end

function Module:ButtonOnClick(btn)
	-- REASON: Central interaction hub for customized bag buttons. Depending on the currently
	-- active specialized mode, standard Blizzard clicks are intercepted for custom logic.
	if btn ~= "LeftButton" then
		return
	end

	-- Click clears "new" so the slot leaves Recent / loses glow.
	if self.bagId and self.slotId and Module.ClearRecentItem and Module:IsRecentItem(self.bagId, self.slotId) then
		Module:ClearRecentItem(self.bagId, self.slotId)
		if Module.Bags then
			Module.Bags:BAG_UPDATE(self.bagId, self.slotId)
		end
	end

	handleStackSplit(self)
	handleFavouriteTagging(self)
	handleJunkTagging(self)
	handleItemDeletion(self)
end

function Module:UpdateAllBags()
	-- REASON: Signals a complete data refresh of all managed bag containers.
	if self.Bags and self.Bags:IsShown() then
		self.Bags:BAG_UPDATE()
	end
end

function Module.OpenBags()
	OpenAllBags(true)
end

-- COMPAT: Dot syntax (not colon). K:RegisterEvent dispatches func(event, ...), so a colon
-- handler would bind `self` to "TRADE_CLOSED" and skip the real Module.Bags check.
function Module.CloseBags()
	if Module.Bags and Module.Bags:IsShown() then
		_G.ToggleAllBags()
	end
end
