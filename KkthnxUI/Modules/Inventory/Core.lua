--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Main Inventory/Bag management module logic.
-- - Design: Uses cargBags for bag implementation and anchoring.
-- - Events: TRADE_SHOW, TRADE_CLOSED, BANKFRAME_OPENED, GET_ITEM_INFO_RECEIVED
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:NewModule("Bags")

-- PERF: Localize globals and API functions to minimize lookup overhead.
local _G = _G
local BankFrame_ShowPanel = _G.BankFrame_ShowPanel
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
local DepositReagentBank = _G.DepositReagentBank
local GameTooltip = _G.GameTooltip
local GetCVarBool = _G.GetCVarBool
local GetContainerItemID = _G.C_Container.GetContainerItemID
local GetContainerNumSlots = _G.C_Container.GetContainerNumSlots
local GetInventoryItemID = _G.GetInventoryItemID
local GetRealZoneText = _G.GetRealZoneText
local InCombatLockdown = _G.InCombatLockdown
local IsAltKeyDown = _G.IsAltKeyDown
local IsControlKeyDown = _G.IsControlKeyDown
local IsCosmeticItem = _G.C_Item.IsCosmeticItem
local IsReagentBankUnlocked = _G.IsReagentBankUnlocked
local IsShiftKeyDown = _G.IsShiftKeyDown
local OpenAllBags = _G.OpenAllBags
local PickupContainerItem = _G.C_Container.PickupContainerItem
local PlaySound = _G.PlaySound
local SetCVar = _G.SetCVar
local SetCVarBitfield = _G.SetCVarBitfield
local SetItemCraftingQualityOverlay = _G.SetItemCraftingQualityOverlay
local SortBags = _G.C_Container.SortBags
local SortBankBags = _G.C_Container.SortBankBags
local SortReagentBankBags = _G.C_Container.SortReagentBankBags
local SplitContainerItem = _G.C_Container.SplitContainerItem
local StaticPopup_Hide = _G.StaticPopup_Hide
local StaticPopup_Show = _G.StaticPopup_Show
local StaticPopup_Visible = _G.StaticPopup_Visible
-- local ToggleAllBags = _G.ToggleAllBags
local UIParent = _G.UIParent
local ipairs = _G.ipairs
local math_ceil = _G.math.ceil
local pairs = _G.pairs
local pcall = _G.pcall
local select = _G.select
local string_lower = _G.string.lower
local string_match = _G.string.match
local table_insert = _G.table.insert
local table_wipe = _G.table.wipe
local tonumber = _G.tonumber
local tostring = _G.tostring
local type = _G.type
local unpack = _G.unpack

-- ---------------------------------------------------------------------------
-- Constants & State
-- ---------------------------------------------------------------------------
local cargBags = K.cargBags
local Unfit = K.LibUnfit

local ACCOUNT_BANK_TYPE = _G.Enum.BankType.Account or 2
local CHAR_BANK_TYPE = _G.Enum.BankType.Character or 0

local isDeleteEnabled = false
local isFavouriteEnabled = false
local isSplitEnabled = false
local isCustomJunkEnabled = false

local sortCache = {}
local toggleButtons = {}

-- ---------------------------------------------------------------------------
-- Sorting & Anchoring
-- ---------------------------------------------------------------------------
function Module:ReverseSort()
	-- REASON: Standard C_Container.SortBags often fills from top-left, but many users prefer bottom-filling
	-- layouts. This post-processing step manually swaps items to achieve a reversed visual order.
	for bagID = 0, 4 do
		local numSlots = GetContainerNumSlots(bagID)
		for slotID = 1, numSlots do
			local info = C_Container_GetContainerItemInfo(bagID, slotID)
			local texture = info and info.iconFileID
			local locked = info and info.isLocked
			if (slotID <= numSlots / 2) and texture and not locked and not sortCache["b" .. bagID .. "s" .. slotID] then
				PickupContainerItem(bagID, slotID)
				PickupContainerItem(bagID, numSlots + 1 - slotID)
				sortCache["b" .. bagID .. "s" .. slotID] = true
			end
		end
	end

	Module.Bags.isSorting = false
	Module:UpdateAllBags()
end

local anchorCache = {}
local function hasReagentBag(name)
	-- REASON: Checks if the reagent bag (index 5) exists before attempting to anchor it.
	if name == "BagReagent" and GetContainerNumSlots(5) == 0 then
		return false
	end
	return true
end

function Module:UpdateBagsAnchor(parent, bags)
	-- REASON: cargBags creates dynamic containers. This logic ensures that as filters move items between containers,
	-- the visible "virtual bags" stack neatly without gaps or overlapping the Main Backpack.
	table_wipe(anchorCache)

	local currentIndex = 1
	local perRow = C["Inventory"].BagsPerRow
	anchorCache[currentIndex] = parent

	for i = 1, #bags do
		local bagFrame = bags[i]
		if bagFrame:GetHeight() > 45 and hasReagentBag(bagFrame.name) then
			bagFrame:Show()
			currentIndex = currentIndex + 1

			bagFrame:ClearAllPoints()
			if (currentIndex - 1) % perRow == 0 then
				bagFrame:SetPoint("BOTTOMRIGHT", anchorCache[currentIndex - perRow], "BOTTOMLEFT", -6, 0)
			else
				bagFrame:SetPoint("BOTTOMLEFT", anchorCache[currentIndex - 1], "TOPLEFT", 0, 6)
			end
			anchorCache[currentIndex] = bagFrame
		else
			bagFrame:Hide()
		end
	end
end

function Module:UpdateBankAnchor(parent, bags)
	-- REASON: Bank layout differs from player bags as it often needs to accommodate the Reagent Bank or Warband
	-- tabs. Anchoring flows relative to the primary Bank frame to maintain a cohesive unified look.
	table_wipe(anchorCache)

	local currentIndex = 1
	local perRow = C["Inventory"].BankPerRow
	anchorCache[currentIndex] = parent

	for i = 1, #bags do
		local bagFrame = bags[i]
		if bagFrame:GetHeight() > 45 then
			bagFrame:Show()
			currentIndex = currentIndex + 1

			bagFrame:ClearAllPoints()
			if currentIndex <= perRow then
				bagFrame:SetPoint("BOTTOMLEFT", anchorCache[currentIndex - 1], "TOPLEFT", 0, 6)
			elseif currentIndex == perRow + 1 then
				bagFrame:SetPoint("TOPLEFT", anchorCache[currentIndex - 1], "TOPRIGHT", 6, 0)
			elseif (currentIndex - 1) % perRow == 0 then
				bagFrame:SetPoint("TOPLEFT", anchorCache[currentIndex - perRow], "TOPRIGHT", 6, 0)
			else
				bagFrame:SetPoint("TOPLEFT", anchorCache[currentIndex - 1], "BOTTOMLEFT", 0, -6)
			end
			anchorCache[currentIndex] = bagFrame
		else
			bagFrame:Hide()
		end
	end
end

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
	for index, button in pairs(buttons) do
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

	local moneyOverlay = CreateFrame("Frame", nil, UIParent)
	moneyOverlay:SetParent(self)
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

function Module:CreateBagTab(settings, tabColumns)
	local bagTab = self:SpawnPlugin("BagTab", settings.Bags)
	bagTab:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, -6)
	bagTab:CreateBorder()
	bagTab.highlightFunction = searchHighlight
	bagTab.isGlobal = true
	bagTab:Hide()
	bagTab.columns = tabColumns
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
	purchaseBtn:SetAttribute("clickbutton", _G.AccountBankPanel.PurchasePrompt.TabCostFrame.PurchaseButton)

	self.BagBar = bagTab
end

local function handleCloseOrReset(self, btn)
	if btn == "RightButton" then
		-- REASON: Users often reposition bag containers during gameplay. This provides a quick "panic reset"
		-- that purges character-specific position variables and snaps all frames back to their default
		-- UI layout positions.
		local bag = self.__owner.main
		local bank = self.__owner.bank
		local reagent = self.__owner.reagent
		local account = self.__owner.accountbank
		local tempAnchors = K.GetCharVars()["TempAnchor"]
		tempAnchors[bag:GetName()] = nil
		tempAnchors[bank:GetName()] = nil
		tempAnchors[reagent:GetName()] = nil
		tempAnchors[account:GetName()] = nil

		bag:ClearAllPoints()
		bag:SetPoint(unpack(bag.__anchor))
		bank:ClearAllPoints()
		bank:SetPoint(unpack(bank.__anchor))
		reagent:ClearAllPoints()
		reagent:SetPoint(unpack(bank.__anchor))
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
	local function closeClick(self, btn)
		if btn == "RightButton" then
			local bag = self.__owner.main
			local bank = self.__owner.bank
			local reagent = self.__owner.reagent
			local account = self.__owner.accountbank
			local tempAnchors = K.GetCharVars()["TempAnchor"]
			tempAnchors[bag:GetName()] = nil
			tempAnchors[bank:GetName()] = nil
			tempAnchors[reagent:GetName()] = nil
			tempAnchors[account:GetName()] = nil

			bag:ClearAllPoints()
			bag:SetPoint(unpack(bag.__anchor))
			bank:ClearAllPoints()
			bank:SetPoint(unpack(bank.__anchor))
			reagent:ClearAllPoints()
			reagent:SetPoint(unpack(bank.__anchor))
			account:ClearAllPoints()
			account:SetPoint(unpack(bank.__anchor))
			PlaySound(_G.SOUNDKIT.IG_MINIMAP_OPEN)
		else
			Module:CloseBags()
		end
	end

	local closeBtn = Module:CreateInventoryButton(self, 18, "Interface\\AddOns\\KkthnxUI\\Media\\Textures\\CloseButton_32", _G.CLOSE .. "/" .. _G.RESET, closeClick, true)
	closeBtn.__owner = sourceFrame

	return closeBtn
end

function Module:CreateReagentButton()
	local clickFunc = function(_, btn)
		if not C_Bank_CanViewBank(CHAR_BANK_TYPE) then
			return
		end

		if not IsReagentBankUnlocked() then
			StaticPopup_Show("CONFIRM_BUY_REAGENTBANK_TAB")
		else
			PlaySound(_G.SOUNDKIT.IG_CHARACTER_INFO_TAB)
			BankFrame_ShowPanel("ReagentBankFrame")
			if btn == "RightButton" then
				DepositReagentBank()
			end
		end
	end

	return Module:CreateInventoryButton(self, 18, 3566850, _G.REAGENT_BANK, clickFunc)
end

function Module:CreateAccountBankButton()
	local clickFunc = function()
		if not C_Bank_CanViewBank(ACCOUNT_BANK_TYPE) then
			return
		end

		if _G.AccountBankPanel:ShouldShowLockPrompt() then
			_G.UIErrorsFrame:AddMessage(K.InfoColor .. _G.ACCOUNT_BANK_LOCKED_PROMPT)
		else
			PlaySound(_G.SOUNDKIT.IG_CHARACTER_INFO_TAB)
			_G.BankFrame_ShowPanel("AccountBankPanel")
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
		BankFrame_ShowPanel("BankSlotsFrame")
	end

	return Module:CreateInventoryButton(self, 18, 413587, _G.BANK, clickFunc)
end

local function updateDepositButtonStatus(bu)
	if not bu then
		return
	end

	if K.GetCharVars().AutoDeposit then
		bu.KKUI_Border:SetVertexColor(1, 0.8, 0)
	else
		bu.KKUI_Border:SetVertexColor(1, 1, 1)
	end
end

function Module:AutoDeposit()
	if K.GetCharVars().AutoDeposit and not IsShiftKeyDown() then
		DepositReagentBank()
	end
end

function Module:CreateDepositButton()
	local clickFunc = function(self, btn)
		if btn == "RightButton" then
			K.GetCharVars().AutoDeposit = not K.GetCharVars().AutoDeposit
			updateDepositButtonStatus(self)
		else
			DepositReagentBank()
		end
	end

	local button = Module:CreateInventoryButton(self, 18, 450905, _G.REAGENTBANK_DEPOSIT, clickFunc)
	self.depositButton = button
	updateDepositButtonStatus(button)

	return button
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
		elseif btnName == "Reagent" then
			SortReagentBankBags()
		elseif btnName == "Account" then
			C_Container_SortAccountBankBags()
		else
			if C["Inventory"].ReverseSort then
				if InCombatLockdown() then
					_G.UIErrorsFrame:AddMessage(K.InfoColor .. _G.ERR_NOT_IN_COMBAT)
				else
					SortBags()
					table_wipe(sortCache)
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
		local slotID = Module:GetContainerEmptySlot(-1)
		if slotID then
			return -1, slotID
		end
		for bagID = 6, 12 do
			local nextSlotID = Module:GetContainerEmptySlot(bagID)
			if nextSlotID then
				return bagID, nextSlotID
			end
		end
	elseif context == "Reagent" then
		local slotID = Module:GetContainerEmptySlot(-3)
		if slotID then
			return -3, slotID
		end
	elseif context == "BagReagent" then
		local slotID = Module:GetContainerEmptySlot(5)
		if slotID then
			return 5, slotID
		end
	elseif context == "Account" then
		for bagID = 13, 17 do
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
	["Reagent"] = true,
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
	K.AddTooltip(slotFrame, "_G.ANCHOR_RIGHT", "FreeSlots")
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
	for index, button in pairs(toggleButtons) do
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

local function getCustomGroupTitle(id)
	return K.GetCharVars().CustomNames[id] or (CUSTOM .. " " .. FILTER .. " " .. id)
end

_G.StaticPopupDialogs["KKUI_RENAMECUSTOMGROUP"] = {
	text = _G.BATTLE_PET_RENAME,
	button1 = _G.OKAY,
	button2 = _G.CANCEL,
	OnAccept = function(self)
		local groupId = Module.selectGroupIndex
		local newName = self.editBox:GetText()
		K.GetCharVars().CustomNames[groupId] = newName ~= "" and newName or nil

		Module.CustomMenu[groupId + 2].text = getCustomGroupTitle(groupId)
		Module.ContainerGroups["Bag"][groupId].label:SetText(getCustomGroupTitle(groupId))
		Module.ContainerGroups["Bank"][groupId].label:SetText(getCustomGroupTitle(groupId))
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
			text = getCustomGroupTitle(i),
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

	if icon and rarity > _G.Enum.ItemQuality.Poor then
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
	local sellPrice = select(11, _G.C_Item.GetItemInfo(targetID))
	if icon and sellPrice > 0 then
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
	if IsControlKeyDown() and IsAltKeyDown() and icon and (rarity < _G.Enum.ItemQuality.Rare) then
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

function Module:OpenBags()
	OpenAllBags(true)
end

function Module:CloseBags()
	if self.Bags and self.Bags:IsShown() then
		ToggleAllBags()
	end
end

function Module:OnEnable()
	local loadInventoryModules = {
		"CreateInventoryBar",
		"CreateAutoRepair",
		"CreateAutoSell",
	}

	for _, funcName in ipairs(loadInventoryModules) do
		local func = self[funcName]
		if type(func) == "function" then
			local success, err = pcall(func, self)
			if not success then
				error("Error in function " .. funcName .. ": " .. tostring(err), 2)
			end
		end
	end

	if not C["Inventory"].Enable then
		return
	end

	-- REASON: Inventory management is a core system frequently replaced by specialized addons.
	-- To prevent conflicting logic, taint, or UI overlap, we gracefully disable the module
	-- if any well-known alternative is detected.
	local conflictAddons = { "AdiBags", "ArkInventory", "cargBags_Nivaya", "cargBags", "Bagnon", "Combuctor", "TBag", "BaudBag" }
	for _, addon in ipairs(conflictAddons) do
		if _G.C_AddOns.IsAddOnLoaded(addon) then
			return
		end
	end

	local iconSize = C["Inventory"].IconSize
	local isShowItemLevel = C["Inventory"].BagsItemLevel
	local isShowBindOnEquip = C["Inventory"].BagsBindOnEquip
	local isShowNewItem = C["Inventory"].ShowNewItem
	local hasCanIMogIt = _G.C_AddOns.IsAddOnLoaded("CanIMogIt")

	-- ---------------------------------------------------------------------------
	-- cargBags Implementation
	-- ---------------------------------------------------------------------------
	local Backpack = cargBags:NewImplementation("KKUI_Backpack")
	Backpack:RegisterBlizzard()

	Backpack:HookScript("OnShow", function()
		PlaySound(_G.SOUNDKIT.IG_BACKPACK_OPEN)
	end)

	Backpack:HookScript("OnHide", function()
		PlaySound(_G.SOUNDKIT.IG_BACKPACK_CLOSE)
	end)

	Module.Bags = Backpack
	Module.BagsType = { [0] = 0, [-1] = 0, [-3] = 0 }
	for bagID = 13, 17 do
		Module.BagsType[bagID] = 0 -- Account Bank
	end

	local bagFrames = {}
	local filters = Module:GetFilters()
	local MyContainer = Backpack:GetContainerClass()
	Module.ContainerGroups = { ["Bag"] = {}, ["Bank"] = {}, ["Account"] = {} }

	local function addNewContainer(bagType, index, name, filter)
		local container = MyContainer:New(name, { BagType = bagType, Index = index })
		container:SetFilter(filter, true)
		Module.ContainerGroups[bagType][index] = container
	end

	function Backpack:OnInit()
		for i = 1, 5 do
			addNewContainer("Bag", i, "BagCustom" .. i, filters["bagCustom" .. i])
		end
		addNewContainer("Bag", 6, "BagReagent", filters.onlyBagReagent)
		addNewContainer("Bag", 20, "Junk", filters.bagsJunk)
		addNewContainer("Bag", 9, "EquipSet", filters.bagEquipSet)
		addNewContainer("Bag", 10, "BagAOE", filters.bagAOE)
		addNewContainer("Bag", 7, "AzeriteItem", filters.bagAzeriteItem)
		addNewContainer("Bag", 17, "BagLegacy", filters.bagLegacy)
		addNewContainer("Bag", 19, "BagLower", filters.bagLower)
		addNewContainer("Bag", 8, "Equipment", filters.bagEquipment)
		addNewContainer("Bag", 11, "BagCollection", filters.bagCollection)
		addNewContainer("Bag", 14, "BagStone", filters.bagStone)
		addNewContainer("Bag", 18, "BagKeystone", filters.bagKeystone)
		addNewContainer("Bag", 15, "Consumable", filters.bagConsumable)
		addNewContainer("Bag", 12, "BagGoods", filters.bagGoods)
		addNewContainer("Bag", 16, "BagQuest", filters.bagQuest)
		addNewContainer("Bag", 13, "BagAnima", filters.bagAnima)

		bagFrames.main = MyContainer:New("Bag", { Bags = "bags", BagType = "Bag" })
		bagFrames.main.__anchor = { "BOTTOMRIGHT", -50, 100 }
		bagFrames.main:SetPoint(unpack(bagFrames.main.__anchor))
		bagFrames.main:SetFilter(filters.onlyBags, true)

		for i = 1, 5 do
			addNewContainer("Bank", i, "BankCustom" .. i, filters["bankCustom" .. i])
		end
		addNewContainer("Bank", 8, "BankEquipSet", filters.bankEquipSet)
		addNewContainer("Bank", 9, "BankAOE", filters.bankAOE)
		addNewContainer("Bank", 6, "BankAzeriteItem", filters.bankAzeriteItem)
		addNewContainer("Bank", 10, "BankLegendary", filters.bankLegendary)
		addNewContainer("Bank", 16, "BankLegacy", filters.bankLegacy)
		addNewContainer("Bank", 17, "BankLower", filters.bankLower)
		addNewContainer("Bank", 7, "BankEquipment", filters.bankEquipment)
		addNewContainer("Bank", 11, "BankCollection", filters.bankCollection)
		addNewContainer("Bank", 14, "BankConsumable", filters.bankConsumable)
		addNewContainer("Bank", 12, "BankGoods", filters.bankGoods)
		addNewContainer("Bank", 15, "BankQuest", filters.bankQuest)
		addNewContainer("Bank", 13, "BankAnima", filters.bankAnima)

		bagFrames.bank = MyContainer:New("Bank", { Bags = "bank", BagType = "Bank" })
		bagFrames.bank.__anchor = { "BOTTOMLEFT", 25, 50 }
		bagFrames.bank:SetPoint(unpack(bagFrames.bank.__anchor))
		bagFrames.bank:SetFilter(filters.onlyBank, true)
		bagFrames.bank:Hide()

		bagFrames.reagent = MyContainer:New("Reagent", { Bags = "bankreagent", BagType = "Bank" })
		bagFrames.reagent:SetFilter(filters.onlyReagent, true)
		bagFrames.reagent:SetPoint(unpack(bagFrames.bank.__anchor))
		bagFrames.reagent:Hide()

		for i = 1, 5 do
			addNewContainer("Account", i, "AccountCustom" .. i, filters["accountCustom" .. i])
		end
		addNewContainer("Account", 8, "AccountAOE", filters.accountAOE)
		addNewContainer("Account", 7, "AccountLegacy", filters.accountLegacy)
		addNewContainer("Account", 6, "AccountEquipment", filters.accountEquipment)
		addNewContainer("Account", 10, "AccountConsumable", filters.accountConsumable)
		addNewContainer("Account", 9, "AccountGoods", filters.accountGoods)

		bagFrames.accountbank = MyContainer:New("Account", { Bags = "accountbank", BagType = "Account" })
		bagFrames.accountbank:SetFilter(filters.accountbank, true)
		bagFrames.accountbank:SetPoint(unpack(bagFrames.bank.__anchor))
		bagFrames.accountbank:Hide()

		for bagType, groups in pairs(Module.ContainerGroups) do
			for _, container in ipairs(groups) do
				local parent = Backpack.contByName[bagType]
				container:SetParent(parent)
				K.CreateMoverFrame(container, parent, true)
			end
		end
	end

	local isBagTypeInitialized = false
	function Backpack:OnBankOpened()
		_G.BankFrame:Show()
		self:GetContainer("Bank"):Show()

		if not isBagTypeInitialized then
			Module:UpdateAllBags()
			Module:UpdateBagSize()
			isBagTypeInitialized = true
		end
	end

	function Backpack:OnBankClosed()
		_G.BankFrame.selectedTab = 1
		_G.BankFrame.activeTabIndex = 1
		self:GetContainer("Bank"):Hide()
		self:GetContainer("Reagent"):Hide()
		self:GetContainer("Account"):Hide()
	end

	-- ---------------------------------------------------------------------------
	-- Button Decoration
	-- ---------------------------------------------------------------------------
	local MyButton = Backpack:GetItemButtonClass()
	MyButton:Scaffold("Default")

	function MyButton:OnCreate()
		self:SetNormalTexture(0)
		self:SetPushedTexture(0)
		self:SetSize(iconSize, iconSize)

		self.Icon:SetAllPoints()
		self.Icon:SetTexCoord(unpack(K.TexCoords))

		self.Count:SetPoint("BOTTOMRIGHT", 1, 1)
		self.Count:SetFontObject(K.UIFontOutline)

		self.Cooldown:SetPoint("TOPLEFT", 1, -1)
		self.Cooldown:SetPoint("BOTTOMRIGHT", -1, 1)

		self.IconOverlay:SetPoint("TOPLEFT", 1, -1)
		self.IconOverlay:SetPoint("BOTTOMRIGHT", -1, 1)

		self.IconOverlay2:SetPoint("TOPLEFT", 1, -1)
		self.IconOverlay2:SetPoint("BOTTOMRIGHT", -1, 1)

		self:CreateBorder(nil, nil, nil, nil, nil, nil, K.MediaFolder .. "Skins\\UI-Slot-Background", nil, nil, nil, { 1, 1, 1 })
		self:StyleButton()

		local overlayFrame = CreateFrame("Frame", nil, self)
		overlayFrame:SetAllPoints()
		overlayFrame:SetFrameLevel(12)

		self.Favourite = overlayFrame:CreateTexture(nil, "OVERLAY")
		self.Favourite:SetAtlas("collections-icon-favorites")
		self.Favourite:SetSize(28, 28)
		self.Favourite:SetPoint("TOPRIGHT", 4, 3)

		self.QuestTag = overlayFrame:CreateTexture(nil, "OVERLAY")
		self.QuestTag:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\Inventory\\QuestIcon.tga")
		self.QuestTag:SetSize(26, 26)
		self.QuestTag:SetPoint("LEFT", 0, 1)

		self.iLvl = K.CreateFontString(self, 12, "", "OUTLINE", false, "BOTTOMLEFT", 1, 0)
		self.bindType = K.CreateFontString(self, 12, "", "OUTLINE", false, "TOPLEFT", 1, -2)

		if isShowNewItem and not self.glowFrame then
			self.glowFrame = CreateFrame("Frame", nil, self, "BackdropTemplate")
			self.glowFrame:SetFrameLevel(self:GetFrameLevel() + 2)
			self.glowFrame:SetBackdrop({ edgeFile = C["Media"].Borders.GlowBorder, edgeSize = 16 })
			self.glowFrame:SetBackdropBorderColor(1, 223 / 255, 0, 1)
			self.glowFrame:SetPoint("TOPLEFT", self, -6, 6)
			self.glowFrame:SetPoint("BOTTOMRIGHT", self, 6, -6)

			self.glowFrame.Animation = self.glowFrame.Animation or self.glowFrame:CreateAnimationGroup()
			self.glowFrame.Animation:SetLooping("BOUNCE")

			self.glowFrame.Animation.FadeOut = self.glowFrame.Animation.FadeOut or self.glowFrame.Animation:CreateAnimation("Alpha")
			self.glowFrame.Animation.FadeOut:SetFromAlpha(1)
			self.glowFrame.Animation.FadeOut:SetToAlpha(0.1)
			self.glowFrame.Animation.FadeOut:SetDuration(0.6)
			self.glowFrame.Animation.FadeOut:SetSmoothing("IN_OUT")
		end

		self:HookScript("OnClick", Module.ButtonOnClick)

		if hasCanIMogIt then
			self.canIMogIt = overlayFrame:CreateTexture(nil, "OVERLAY")
			self.canIMogIt:SetSize(iconSize / 2.6, iconSize / 2.6)
			self.canIMogIt:SetPoint(unpack(_G.CanIMogIt.ICON_LOCATIONS[_G.CanIMogItOptions["iconLocation"]]))
		end

		if not self.ProfessionQualityOverlay then
			self.ProfessionQualityOverlay = overlayFrame:CreateTexture(nil, "OVERLAY")
			self.ProfessionQualityOverlay:SetPoint("TOPLEFT", -3, 2)
		end
	end

	function MyButton:ItemOnEnter()
		if self.glowFrame and self.glowFrame.Animation then
			local isNew = C_NewItems_IsNewItem(self.bagId, self.slotId)
			local isPlaying = self.glowFrame.Animation:IsPlaying()

			if not isNew and isPlaying then
				self.glowFrame.Animation:Stop()
				self.glowFrame:Hide()
				C_NewItems_RemoveNewItem(self.bagId, self.slotId)
			end
		end
	end

	local BAG_TYPE_COLOR = {
		[0] = { 1, 1, 1, 0.3 }, -- Container
		[1] = false, -- Soul Bag
		[2] = { 0, 0.5, 0, 0.25 }, -- Herb Bag
		[3] = { 0.8, 0, 0.8, 0.25 }, -- Enchanting Bag
		[4] = { 1, 0.8, 0, 0.25 }, -- Engineering Bag
		[5] = { 0, 0.8, 0.8, 0.25 }, -- Gem Bag
		[6] = { 0.5, 0.4, 0, 0.25 }, -- Mining Bag
		[7] = { 0.8, 0.5, 0.5, 0.25 }, -- Leatherworking Bag
		[8] = { 0.8, 0.8, 0.8, 0.25 }, -- Inscription Bag
		[9] = { 0.4, 0.6, 1, 0.25 }, -- Toolbox
		[10] = { 0.8, 0, 0, 0.25 }, -- Cooking Bag
		[11] = { 0.2, 0.8, 0.2, 0.25 }, -- Material Bag
	}

	local function isItemNeedsLevel(item)
		return item.link and item.quality > 1 and item.ilvl
	end

	local function getIconOverlayAtlas(item)
		if not item.link then
			return
		end

		if C_AzeriteEmpoweredItem_IsAzeriteEmpoweredItemByID(item.link) then
			return "AzeriteIconFrame"
		elseif IsCosmeticItem(item.link) then
			return "CosmeticIconFrame"
		elseif C_Soulbinds_IsItemConduitByItemInfo(item.link) then
			return "ConduitIconFrame", "ConduitIconFrame-Corners"
		end
	end

	local function updateCanIMogIt(self, item)
		if not self.canIMogIt then
			return
		end

		local text, unmodifiedText = _G.CanIMogIt:GetTooltipText(nil, item.bagId, item.slotId)
		if text and text ~= "" then
			local icon = _G.CanIMogIt.tooltipOverlayIcons[unmodifiedText]
			self.canIMogIt:SetTexture(icon)
			self.canIMogIt:Show()
		else
			self.canIMogIt:Hide()
		end
	end

	local ITEM_UPGRADE_THROTTLE = 0.5
	local function onUpgradeCheckUpdate(self, elapsed)
		self._timeSinceUpgradeCheck = (self._timeSinceUpgradeCheck or 0) + elapsed
		if self._timeSinceUpgradeCheck >= ITEM_UPGRADE_THROTTLE then
			self._timeSinceUpgradeCheck = 0
			if self._callUpdateUpgradeIcon then
				self:_callUpdateUpgradeIcon()
			end
		end
	end

	local function updateUpgradeArrow(self, item)
		if not self or not self.UpgradeIcon then
			return
		end

		if not C["Inventory"].UpgradeIcon or not item or not item.link or not _G.IsEquippableItem(item.link) then
			self.UpgradeIcon:SetShown(false)
			self:SetScript("OnUpdate", nil)
			return
		end

		local isUpgrade
		local bagID, slotID = item.bagId, item.slotId

		if _G.PawnIsContainerItemAnUpgrade then
			isUpgrade = _G.PawnIsContainerItemAnUpgrade(bagID, slotID)
		end
		if isUpgrade == nil and _G.IsContainerItemAnUpgrade then
			isUpgrade = _G.IsContainerItemAnUpgrade(bagID, slotID)
		end

		self.UpgradeIcon:ClearAllPoints()
		self.UpgradeIcon:SetPoint("TOPRIGHT", 3, 3)

		if isUpgrade == nil then
			self.UpgradeIcon:SetShown(false)
			self._callUpdateUpgradeIcon = function(btn)
				updateUpgradeArrow(btn, btn:GetInfo())
			end
			self:SetScript("OnUpdate", onUpgradeCheckUpdate)
		else
			self.UpgradeIcon:SetShown(isUpgrade)
			self:SetScript("OnUpdate", nil)
		end
	end

	function MyButton:OnUpdateButton(item)
		if self.JunkIcon then
			local charVars = K.GetCharVars()
			if (item.quality == _G.Enum.ItemQuality.Poor or (charVars and charVars.CustomJunkList and charVars.CustomJunkList[item.id])) and item.hasPrice then
				self.JunkIcon:Show()
			else
				self.JunkIcon:Hide()
			end
		end

		-- REASON: Visual feedback for items that the player cannot use due to level or class restrictions.
		-- We apply a red tint to the icon to match Blizzard's standard unusable item indicator.
		if C["Inventory"].ColorUnusableItems then
			if (Unfit:IsItemUnusable(item.link) or item.minLevel and item.minLevel > K.Level) and not item.locked then
				self.Icon:SetVertexColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
			else
				self.Icon:SetVertexColor(1, 1, 1)
			end
		end

		self.IconOverlay:SetVertexColor(1, 1, 1)
		self.IconOverlay:Hide()
		self.IconOverlay2:Hide()

		local atlas, secondAtlas = getIconOverlayAtlas(item)
		if atlas then
			self.IconOverlay:SetAtlas(atlas)
			self.IconOverlay:Show()

			if secondAtlas then
				local qualityColor = K.QualityColors[item.quality or 1]
				self.IconOverlay:SetVertexColor(qualityColor.r, qualityColor.g, qualityColor.b)
				self.IconOverlay2:SetAtlas(secondAtlas)
				self.IconOverlay2:Show()
			end
		end

		if self.ProfessionQualityOverlay then
			self.ProfessionQualityOverlay:SetAtlas(nil)
			_G.SetItemCraftingQualityOverlay(self, item.link)
		end

		local charVars = K.GetCharVars()
		if charVars and charVars.CustomItems and charVars.CustomItems[item.id] and not C["Inventory"].ItemFilter then
			self.Favourite:Show()
		else
			self.Favourite:Hide()
		end

		self.iLvl:SetText("")
		if isShowItemLevel then
			local level = item.level -- ilvl for keystone and battlepet
			if not level and isItemNeedsLevel(item) then
				level = item.ilvl
			end

			if level then
				local qualityColor = K.QualityColors[item.quality]
				self.iLvl:SetText(level)
				self.iLvl:SetTextColor(qualityColor.r, qualityColor.g, qualityColor.b)
			end
		end

		self.bindType:SetText("")
		if isShowBindOnEquip then
			local isBoE, isBoU = item.bindType == 2, item.bindType == 3
			if isBoE or isBoU then
				if item.quality > 1 and not item.bound then
					local qualityColor = K.QualityColors[item.quality]
					self.bindType:SetText(isBoE and L["BoE"] or L["BoU"])
					self.bindType:SetTextColor(qualityColor.r, qualityColor.g, qualityColor.b)
				end
			end
		end

		if self.glowFrame then
			if C_NewItems_IsNewItem(item.bagId, item.slotId) then
				local qualityColor = K.QualityColors[item.quality] or {}
				if item.questID or item.isQuestItem then
					self.glowFrame:SetBackdropBorderColor(1, 0.82, 0.2, 1)
				elseif qualityColor.r and qualityColor.g and qualityColor.b then
					self.glowFrame:SetBackdropBorderColor(qualityColor.r, qualityColor.g, qualityColor.b, 1)
				else
					self.glowFrame:SetBackdropBorderColor(1, 223 / 255, 0, 1)
				end
				self.glowFrame:Show()
				self.glowFrame.Animation:Play()
			else
				self.glowFrame:Hide()
				self.glowFrame.Animation:Stop()
			end
		end

		if C["Inventory"].SpecialBagsColor then
			local bagType = Module.BagsType[item.bagId]
			local vertexColor = BAG_TYPE_COLOR[bagType] or BAG_TYPE_COLOR[0]
			self:SetBackdropColor(unpack(vertexColor))
		else
			self:SetBackdropColor(0.04, 0.04, 0.04, 0.9)
		end

		if not item.texture and not _G.GameTooltip:IsForbidden() and _G.GameTooltip:GetOwner() == self then
			_G.GameTooltip:Hide()
		end

		updateCanIMogIt(self, item)
		updateUpgradeArrow(self, item)
	end

	function MyButton:OnUpdateQuest(item)
		if item.questID and not item.questActive then
			self.QuestTag:Show()
		else
			self.QuestTag:Hide()
		end

		if item.questID or item.isQuestItem then
			self.KKUI_Border:SetVertexColor(1, 0.82, 0.2)
		elseif item.quality and item.quality > -1 then
			local qualityColor = K.QualityColors[item.quality]
			self.KKUI_Border:SetVertexColor(qualityColor.r, qualityColor.g, qualityColor.b)
		else
			K.SetBorderColor(self.KKUI_Border)
		end
	end

	function Module:UpdateAllAnchors()
		Module:UpdateBagsAnchor(bagFrames.main, Module.ContainerGroups["Bag"])
		Module:UpdateBankAnchor(bagFrames.bank, Module.ContainerGroups["Bank"])
		Module:UpdateBankAnchor(bagFrames.accountbank, Module.ContainerGroups["Account"])
	end

	function Module:GetContainerColumns(bagType)
		if bagType == "Bag" then
			return C["Inventory"].BagsWidth
		elseif bagType == "Bank" then
			return C["Inventory"].BankWidth
		elseif bagType == "Account" then
			return C["Inventory"].BankWidth
		end
	end

	function MyContainer:OnContentsChanged(isGridOnly)
		self:SortButtons("bagSlot")

		local columns = Module:GetContainerColumns(self.Settings.BagType)
		local headerOffset = 38
		local itemSpacing = 6
		local horizontalOffset = 6
		local verticalOffset = -headerOffset + horizontalOffset
		local _, totalHeight = self:LayoutButtons("grid", columns, itemSpacing, horizontalOffset, verticalOffset)
		local totalWidth = columns * (iconSize + itemSpacing) - itemSpacing

		if self.freeSlot then
			if C["Inventory"].GatherEmpty then
				local slotCount = #self.buttons + 1
				local rowIdx = math_ceil(slotCount / columns)
				local colIdx = slotCount % columns
				if colIdx == 0 then
					colIdx = columns
				end

				local posX = (colIdx - 1) * (iconSize + itemSpacing)
				local posY = -1 * (rowIdx - 1) * (iconSize + itemSpacing)

				self.freeSlot:ClearAllPoints()
				self.freeSlot:SetPoint("TOPLEFT", self, "TOPLEFT", posX + horizontalOffset, posY + verticalOffset)
				self.freeSlot:Show()

				if totalHeight < 0 then
					totalHeight = iconSize
				elseif colIdx == 1 then
					totalHeight = totalHeight + iconSize + itemSpacing
				end
			else
				self.freeSlot:Hide()
			end
		end
		self:SetSize(totalWidth + horizontalOffset * 2, totalHeight + headerOffset)

		if not isGridOnly then
			Module:UpdateAllAnchors()
		end
	end

	function MyContainer:OnCreate(name, settings)
		self.Settings = settings
		self:SetFrameStrata("HIGH")
		self:SetClampedToScreen(true)
		self:CreateBorder()

		if settings.Bags then
			K.CreateMoverFrame(self, nil, true)
		end

		self.iconSize = iconSize
		Module.CreateFreeSlots(self)

		local groupLabel
		if name:match("AzeriteItem$") then
			groupLabel = L["Azerite Armor"]
		elseif name:match("Equipment$") then
			groupLabel = _G.BAG_FILTER_EQUIPMENT
		elseif name:match("EquipSet$") then
			groupLabel = L["Equipment Set"]
		elseif name == "Junk" then
			groupLabel = _G.BAG_FILTER_JUNK
		elseif name == "BagRelic" then
			groupLabel = L["Korthian Relics"]
		elseif name == "BagReagent" then
			groupLabel = L["Reagent Bag"]
		elseif name == "BagStone" then
			groupLabel = _G.C_Spell.GetSpellName(404861)
		elseif name:match("Keystone$") then
			groupLabel = _G.WEEKLY_REWARDS_MYTHIC_KEYSTONE
		elseif string_match(name, "AOE") then
			groupLabel = _G.ITEM_ACCOUNTBOUND_UNTIL_EQUIP
		elseif string_match(name, "Lower") then
			groupLabel = L["Lower Item Level"]
		elseif string_match(name, "Legacy") then
			groupLabel = L["Legacy Items"]
		else
			if name:match("Legendary$") then
				groupLabel = _G.LOOT_JOURNAL_LEGENDARIES
			elseif name:match("Consumable$") then
				groupLabel = _G.BAG_FILTER_CONSUMABLES
			elseif name:match("Collection") then
				groupLabel = _G.COLLECTIONS
			elseif name:match("Goods") then
				groupLabel = _G.AUCTION_CATEGORY_TRADE_GOODS
			elseif name:match("Quest") then
				groupLabel = _G.QUESTS_LABEL
			elseif name:match("Anima") then
				groupLabel = _G.POWER_TYPE_ANIMA
			elseif name:match("Custom%d") then
				groupLabel = getCustomGroupTitle(settings.Index)
			end
		end

		if groupLabel then
			self.label = K.CreateFontString(self, 13, groupLabel, "OUTLINE", true, "TOPLEFT", 6, -8)
			return
		end

		Module.CreateInfoFrame(self)

		local widgets = {}
		widgets[1] = Module.CreateCloseButton(self, bagFrames)
		widgets[2] = Module.CreateSortButton(self, name)
		if name == "Bag" then
			Module.CreateBagBar(self, settings, 5)
			widgets[3] = Module.CreateBagToggle(self)
			widgets[4] = Module.CreateSplitButton(self)
			widgets[5] = Module.CreateFavouriteButton(self)
			widgets[6] = Module.CreateJunkButton(self)
			widgets[7] = Module.CreateDeleteButton(self)
		elseif name == "Bank" then
			Module.CreateBagBar(self, settings, 7)
			widgets[3] = Module.CreateBagToggle(self)
			widgets[4] = Module.CreateReagentButton(self)
			widgets[5] = Module.CreateAccountBankButton(self)
		elseif name == "Reagent" then
			widgets[3] = Module.CreateDepositButton(self)
			widgets[4] = Module.CreateBankButton(self)
			widgets[5] = Module.CreateAccountBankButton(self)
		elseif name == "Account" then
			Module.CreateBagTab(self, settings, 5)
			widgets[3] = Module.CreateBagToggle(self)
			widgets[4] = Module.CreateAccountBankDeposit(self)
			widgets[5] = Module.CreateBankButton(self)
			widgets[6] = Module.CreateReagentButton(self)
			widgets[7] = Module.CreateAccountMoney(self)
		end

		for i = 1, #widgets do
			local widgetBu = widgets[i]
			if not widgetBu then
				break
			end

			if i == 1 then
				widgetBu:SetPoint("TOPRIGHT", -6, -6)
			else
				widgetBu:SetPoint("RIGHT", widgets[i - 1], "LEFT", -6, 0)
			end
		end
		self.widgetButtons = widgets

		if name == "Bag" then
			Module.CreateCollapseArrow(self)
		end

		self:HookScript("OnShow", K.RestoreMoverFrame)
	end

	local function refreshSlotSize(button)
		button:SetSize(iconSize, iconSize)
		if button.glowFrame then
			button.glowFrame:SetSize(iconSize + 8, iconSize + 8)
		end
	end

	-- REASON: External hook for UI configuration changes. This allows other modules or the options GUI
	-- to trigger a forced refresh of the bag system when settings like 'Icon Size' or 'Reverse Sort' are modified.
	function Module:UpdateBagStatus()
		Module:UpdateAllBags()
	end

	function Module:UpdateBagSize()
		iconSize = C["Inventory"].IconSize
		for _, container in pairs(Backpack.contByName) do
			container:ApplyToButtons(refreshSlotSize)
			if container.freeSlot then
				container.freeSlot:SetSize(iconSize, iconSize)
			end
			if container.BagBar then
				for _, bagBtn in pairs(container.BagBar.buttons) do
					bagBtn:SetSize(iconSize, iconSize)
				end
				container.BagBar:UpdateAnchor()
			end
			container:OnContentsChanged(true)
		end
	end

	local BagButton = Backpack:GetClass("BagButton", true, "BagButton")
	function BagButton:OnCreate()
		self:SetNormalTexture(0)
		self:SetPushedTexture(0)

		self:SetSize(iconSize, iconSize)
		self:CreateBorder()
		self:StyleButton()

		self.Icon:SetAllPoints()
		self.Icon:SetTexCoord(unpack(K.TexCoords))
	end

	function BagButton:OnUpdateButton()
		local itemID = _G.GetInventoryItemID("player", (self.GetInventorySlot and self:GetInventorySlot()) or self.invID)
		if not itemID then
			return
		end

		local _, _, quality, _, _, _, _, _, _, _, _, classID, subClassID = _G.C_Item.GetItemInfo(itemID)
		if not quality or quality == 1 then
			quality = 0
		end

		local qualityColor = K.QualityColors[quality]
		if not self.hidden and not self.notBought then
			self.KKUI_Border:SetVertexColor(qualityColor.r, qualityColor.g, qualityColor.b)
		else
			K.SetBorderColor(self.KKUI_Border)
		end

		if classID == _G.LE_ITEM_CLASS_CONTAINER then
			Module.BagsType[self.bagId] = subClassID or 0
		else
			Module.BagsType[self.bagId] = 0
		end
	end

	_G.C_Container.SetSortBagsRightToLeft(not C["Inventory"].ReverseSort)
	_G.C_Container.SetInsertItemsLeftToRight(false)

	-- REASON: Brief toggle to force cargBags to recalculate slot groupings on load. This ensures
	-- that the initial bag display correctly reflects the user's filtered categories and layout.
	C["Inventory"].GatherEmpty = not C["Inventory"].GatherEmpty
	_G.ToggleAllBags()
	C["Inventory"].GatherEmpty = not C["Inventory"].GatherEmpty
	_G.ToggleAllBags()
	Module.initComplete = true

	K:RegisterEvent("TRADE_SHOW", Module.OpenBags)
	K:RegisterEvent("TRADE_CLOSED", Module.CloseBags)
	K:RegisterEvent("BANKFRAME_OPENED", Module.AutoDeposit)

	if _G.KKUI_GoldDataText then
		Backpack.OnOpen = function()
			if not _G.KkthnxUIDB.ShowSlots then
				return
			end
			K.GoldButton_OnEvent()
		end
	end

	-- REASON: Shim for Blizzard BankFrame logic to respect custom anchoring. By overriding 'GetRight',
	-- we ensure that dependent UI elements (like tutorial popups or specific addon frames) anchor
	-- correctly to our virtual bank container rather than the hidden original Blizzard bank frame.
	_G.BankFrame.GetRight = function()
		return bagFrames.bank:GetRight()
	end
	_G.BankFrameItemButton_Update = K.Noop

	local suppressedTable = { ["TutorialReagentBag"] = true }
	hooksecurefunc(_G.HelpTip, "Show", function(self, _, info)
		if info and suppressedTable[info.system] then
			self:HideAllSystem(info.system)
		end
	end)

	_G.SetCVarBitfield("closedInfoFrames", _G.LE_FRAME_TUTORIAL_EQUIP_REAGENT_BAG, true)
	_G.SetCVar("professionToolSlotsExampleShown", 1)
	_G.SetCVar("professionAccessorySlotsExampleShown", 1)

	local bankPanelMapping = {
		["BankSlotsFrame"] = 1,
		["ReagentBankFrame"] = 2,
		["AccountBankPanel"] = 3,
	}

	-- REASON: Blizzard's 'BankFrame_ShowPanel' handles the switching between the main bank and reagent bank.
	-- We hook this to ensure our custom virtual containers (Bank/Reagent/Account) show and hide in sync
	-- with the user's selected bank tab.
	hooksecurefunc("BankFrame_ShowPanel", function(panelName)
		local idx = bankPanelMapping[panelName]
		if idx then
			_G.BankFrame.selectedTab = idx
			_G.BankFrame.activeTabIndex = idx
			bagFrames.bank:SetShown(idx == 1)
			bagFrames.reagent:SetShown(idx == 2)
			bagFrames.accountbank:SetShown(idx == 3)
			if _G["KKUI_BankPurchaseButton"] then
				_G["KKUI_BankPurchaseButton"]:SetShown(idx == 3 and _G.C_Bank.CanPurchaseBankTab(_G.ACCOUNT_BANK_TYPE))
			end
		end
	end)

	local throttlingFrame = CreateFrame("Frame", nil, bagFrames.main)
	throttlingFrame:Hide()
	throttlingFrame:SetScript("OnUpdate", function(self, elapsed)
		self.delay = self.delay - elapsed
		if self.delay < 0 then
			Module:UpdateAllBags()
			self:Hide()
		end
	end)

	K:RegisterEvent("GET_ITEM_INFO_RECEIVED", function()
		if Module.Bags and Module.Bags:IsShown() then
			throttlingFrame.delay = 1
			throttlingFrame:Show()
		end
	end)
end
