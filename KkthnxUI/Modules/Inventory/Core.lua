local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:NewModule("Bags")

local cargBags = K.cargBags
local Unfit = K.LibUnfit

local ceil = ceil
local ipairs = ipairs
local pairs = pairs
local string_match = string.match
local table_wipe = table.wipe
local tinsert = table.insert
local tonumber = tonumber
local type = type
local unpack = unpack

local C_AzeriteEmpoweredItem_IsAzeriteEmpoweredItemByID = C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItemByID
local C_Bank_CanViewBank = C_Bank.CanViewBank
local C_Container_GetContainerItemInfo = C_Container.GetContainerItemInfo
local C_Container_SetInsertItemsLeftToRight = C_Container.SetInsertItemsLeftToRight
local C_Container_SetSortBagsRightToLeft = C_Container.SetSortBagsRightToLeft
local C_Container_SortAccountBankBags = C_Container.SortAccountBankBags
local C_NewItems_IsNewItem = C_NewItems.IsNewItem
local C_NewItems_RemoveNewItem = C_NewItems.RemoveNewItem
local C_Soulbinds_IsItemConduitByItemInfo = C_Soulbinds.IsItemConduitByItemInfo
local C_Spell_GetSpellName = C_Spell.GetSpellName
local ClearCursor = ClearCursor
local CreateFrame = CreateFrame
local DeleteCursorItem = DeleteCursorItem
local GameTooltip = GameTooltip
local GetCVarBool = GetCVarBool
local GetContainerItemID = C_Container.GetContainerItemID
local GetContainerNumSlots = C_Container.GetContainerNumSlots
local GetInventoryItemID = GetInventoryItemID
local GetItemInfo = C_Item.GetItemInfo
local InCombatLockdown = InCombatLockdown
local IsAltKeyDown = IsAltKeyDown
local IsControlKeyDown = IsControlKeyDown
local IsCosmeticItem = C_Item.IsCosmeticItem
local PickupContainerItem = C_Container.PickupContainerItem
local PlaySound = PlaySound
local SetCVar = SetCVar
local SetCVarBitfield = SetCVarBitfield
local SetItemCraftingQualityOverlay = SetItemCraftingQualityOverlay
local SOUNDKIT = SOUNDKIT
local SortBags = C_Container.SortBags
local SortBankBags = C_Container.SortBankBags
local SplitContainerItem = C_Container.SplitContainerItem
local StaticPopup_Hide = StaticPopup_Hide
local StaticPopup_Show = StaticPopup_Show
local StaticPopup_Visible = StaticPopup_Visible
local UIParent = UIParent

local ACCOUNT_BANK_TYPE = Enum.BankType.Account or 2
local CHAR_BANK_TYPE = Enum.BankType.Character or 0

local deleteEnable
local favouriteEnable
local splitEnable
local customJunkEnable

local sortCache = {}
local toggleButtons = {}

function Module:ReverseSort()
	for bag = 0, 4 do
		local numSlots = GetContainerNumSlots(bag)
		for slot = 1, numSlots do
			local info = C_Container_GetContainerItemInfo(bag, slot)
			local texture = info and info.iconFileID
			local locked = info and info.isLocked
			if (slot <= numSlots / 2) and texture and not locked and not sortCache["b" .. bag .. "s" .. slot] then
				PickupContainerItem(bag, slot)
				PickupContainerItem(bag, numSlots + 1 - slot)
				sortCache["b" .. bag .. "s" .. slot] = true
			end
		end
	end

	Module.Bags.isSorting = false
	Module:UpdateAllBags()
end

local anchorCache = {}
local function CheckForBagReagent(name)
	local pass = true
	if name == "BagReagent" and GetContainerNumSlots(5) == 0 then
		pass = false
	end
	return pass
end

function Module:UpdateBagsAnchor(parent, bags)
	table_wipe(anchorCache)

	local index = 1
	local perRow = C["Inventory"].BagsPerRow
	anchorCache[index] = parent

	for i = 1, #bags do
		local bag = bags[i]
		if bag:GetHeight() > 45 and CheckForBagReagent(bag.name) then
			bag:Show()
			index = index + 1

			bag:ClearAllPoints()
			if (index - 1) % perRow == 0 then
				bag:SetPoint("BOTTOMRIGHT", anchorCache[index - perRow], "BOTTOMLEFT", -6, 0)
			else
				bag:SetPoint("BOTTOMLEFT", anchorCache[index - 1], "TOPLEFT", 0, 6)
			end
			anchorCache[index] = bag
		else
			bag:Hide()
		end
	end
end

function Module:UpdateBankAnchor(parent, bags)
	table_wipe(anchorCache)

	local index = 1
	local perRow = C["Inventory"].BankPerRow
	anchorCache[index] = parent

	for i = 1, #bags do
		local bag = bags[i]
		if bag:GetHeight() > 45 then
			bag:Show()
			index = index + 1

			bag:ClearAllPoints()
			if index <= perRow then
				bag:SetPoint("BOTTOMLEFT", anchorCache[index - 1], "TOPLEFT", 0, 6)
			elseif index == perRow + 1 then
				bag:SetPoint("TOPLEFT", anchorCache[index - 1], "TOPRIGHT", 6, 0)
			elseif (index - 1) % perRow == 0 then
				bag:SetPoint("TOPLEFT", anchorCache[index - perRow], "TOPRIGHT", 6, 0)
			else
				bag:SetPoint("TOPLEFT", anchorCache[index - 1], "BOTTOMLEFT", 0, -6)
			end
			anchorCache[index] = bag
		else
			bag:Hide()
		end
	end
end

local function highlightFunction(button, match)
	button.searchOverlay:SetShown(not match)
end

local function IsItemMatched(str, text)
	if not str or str == "" then
		return
	end

	return string_match(string.lower(str), text)
end

local BagSmartFilter = {
	default = function(item, text)
		text = string.lower(text)
		if text == "boe" then
			return item.bindOn == "equip"
		elseif text == "aoe" then
			return item.bindOn == "accountequip"
		else
			return IsItemMatched(item.subType, text) or IsItemMatched(item.equipLoc, text) or IsItemMatched(item.name, text) or IsItemMatched((item.expacID or 0) + 1, text)
		end
	end,

	_default = "default",
}

function Module:CreateInfoFrame()
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

	local search = self:SpawnPlugin("SearchBar", infoFrame)
	search.highlightFunction = highlightFunction
	search.isGlobal = true
	search:SetPoint("LEFT", 0, 6)
	search:DisableDrawLayer("BACKGROUND")
	search:CreateBackdrop()
	search.textFilters = BagSmartFilter

	local currencyTag = self:SpawnPlugin("TagDisplay", "[currencies]", infoFrame)
	currencyTag:SetFontObject(K.UIFontOutline)
	currencyTag:SetFont(select(1, currencyTag:GetFont()), 13, select(3, currencyTag:GetFont()))
	currencyTag:SetPoint("TOP", _G.KKUI_BackpackBag, "BOTTOM", 0, -6)

	infoFrame.title = SEARCH
	K.AddTooltip(infoFrame, "ANCHOR_TOPLEFT", K.InfoColorTint .. "|nClick to search your bag items.|nYou can type in item names or item equip locations.|n|n'boe' for items that bind on equip and 'quest' for quest items.")
end

local HideWidgets = true
local function ToggleWidgetButtons(self)
	HideWidgets = not HideWidgets

	local buttons = self.__owner.widgetButtons

	for index, button in pairs(buttons) do
		if index > 2 then
			button:SetShown(not HideWidgets)
		end
	end

	if HideWidgets then
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

	local moneyTagFrame = CreateFrame("Frame", nil, UIParent)
	moneyTagFrame:SetParent(self)
	moneyTagFrame:SetAllPoints(moneyTag)
	moneyTagFrame:SetScript("OnEnter", K.GoldButton_OnEnter)
	moneyTagFrame:SetScript("OnLeave", K.GoldButton_OnLeave)

	collapseArrow.moneyTag = moneyTag

	collapseArrow.__owner = self
	HideWidgets = not HideWidgets -- reset before toggle
	ToggleWidgetButtons(collapseArrow)
	collapseArrow:SetScript("OnClick", ToggleWidgetButtons)

	collapseArrow.title = "Widgets Toggle"
	K.AddTooltip(collapseArrow, "ANCHOR_TOP")

	self.widgetArrow = collapseArrow
end

local function updateBagBar(bar)
	local spacing = 6
	local offset = 6
	local width, height = bar:LayoutButtons("grid", bar.columns, spacing, offset, -offset)
	bar:SetSize(width + offset * 2, height + offset * 2)
end

function Module:CreateBagBar(settings, columns)
	local bagBar = self:SpawnPlugin("BagBar", settings.Bags)
	local spacing = 6
	local offset = 6
	local _, height = bagBar:LayoutButtons("grid", columns, spacing, offset, -offset)
	local width = columns * (self.iconSize + spacing) - spacing
	bagBar:SetSize(width + offset * 2, height + offset * 2)
	bagBar:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, -6)
	bagBar:CreateBorder()
	bagBar.highlightFunction = highlightFunction
	bagBar.isGlobal = true
	bagBar:Hide()
	bagBar.columns = columns
	bagBar.UpdateAnchor = updateBagBar
	bagBar:UpdateAnchor()

	self.BagBar = bagBar
end

function Module:CreateBagTab(settings, columns, account)
	local bagTab = self:SpawnPlugin("BagTab", settings.Bags, account)
	bagTab:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, -6)
	bagTab:CreateBorder()
	bagTab.highlightFunction = highlightFunction
	bagTab.isGlobal = true
	bagTab:Hide()
	bagTab.columns = columns
	bagTab.UpdateAnchor = updateBagBar
	bagTab:UpdateAnchor()

	if account then
		local purchaseButton = CreateFrame("Button", "KKUI_BankPurchaseButton", bagTab, "InsecureActionButtonTemplate")
		purchaseButton:SetSize(120, 22)
		purchaseButton:SetPoint("TOP", bagTab, "BOTTOM", 0, -5)
		K.CreateFontString(purchaseButton, 14, PURCHASE, "info")
		purchaseButton:SkinButton()
		purchaseButton:Hide()

		purchaseButton:RegisterForClicks("AnyUp", "AnyDown")
		purchaseButton:SetAttribute("type", "click")
		purchaseButton:SetAttribute("clickbutton", _G.BankFrame.BankPanel.PurchasePrompt.TabCostFrame.PurchaseButton)
	end

	self.BagBar = bagTab
end

local function CloseOrRestoreBags(self, btn)
	if btn == "RightButton" then
		local bag = self.__owner.main
		local bank = self.__owner.bank
		local account = self.__owner.accountbank
		KkthnxUIDB.Variables[K.Realm][K.Name]["TempAnchor"][bag:GetName()] = nil
		KkthnxUIDB.Variables[K.Realm][K.Name]["TempAnchor"][bank:GetName()] = nil
		KkthnxUIDB.Variables[K.Realm][K.Name]["TempAnchor"][account:GetName()] = nil
		bag:ClearAllPoints()
		bag:SetPoint(unpack(bag.__anchor))
		bank:ClearAllPoints()
		bank:SetPoint(unpack(bank.__anchor))
		account:ClearAllPoints()
		account:SetPoint(unpack(bank.__anchor))
		PlaySound(SOUNDKIT.IG_MINIMAP_OPEN)
	else
		Module:CloseBags()
	end
end

function Module:CreateCloseButton(f)
	local closeButton = CreateFrame("Button", nil, self)
	closeButton:RegisterForClicks("AnyUp")
	closeButton:SetSize(18, 18)
	closeButton:CreateBorder(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, { 0.85, 0.25, 0.25 })
	closeButton:StyleButton()
	closeButton.__owner = f

	closeButton.Icon = closeButton:CreateTexture(nil, "ARTWORK")
	closeButton.Icon:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\Textures\\CloseButton_32")
	closeButton.Icon:SetAllPoints()

	closeButton:SetScript("OnClick", CloseOrRestoreBags)
	closeButton.title = CLOSE .. "/" .. _G.RESET
	K.AddTooltip(closeButton, "ANCHOR_TOP")

	return closeButton
end

function Module:CreateAccountBankButton(f)
	local accountBankButton = CreateFrame("Button", nil, self)
	accountBankButton:SetSize(18, 18)
	accountBankButton:CreateBorder()
	accountBankButton:StyleButton()

	accountBankButton.Icon = accountBankButton:CreateTexture(nil, "ARTWORK")
	accountBankButton.Icon:SetAllPoints()
	accountBankButton.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
	accountBankButton.Icon:SetTexture(939373)

	accountBankButton:RegisterForClicks("AnyUp")
	accountBankButton:SetScript("OnClick", function(_, btn)
		if not C_Bank_CanViewBank(ACCOUNT_BANK_TYPE) then
			return
		end

		if BankFrame.BankPanel:ShouldShowLockPrompt() then
			UIErrorsFrame:AddMessage(K.InfoColor .. ACCOUNT_BANK_LOCKED_PROMPT)
		else
			PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
			BankFrame.BankPanel:SetBankType(ACCOUNT_BANK_TYPE)
		end
	end)
	accountBankButton.title = ACCOUNT_BANK_PANEL_TITLE
	K.AddTooltip(accountBankButton, "ANCHOR_TOP")

	return accountBankButton
end

function Module:CreateAccountMoney()
	local frame = CreateFrame("Button", nil, self)
	frame:SetSize(50, 22)

	local tag = self:SpawnPlugin("TagDisplay", "[accountmoney]", self)
	tag:SetFontObject(K.UIFontOutline)
	tag:SetPoint("RIGHT", frame, -2, 0)
	frame.tag = tag

	frame:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	frame:SetScript("OnClick", function(_, btn)
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
	frame.title = K.LeftButton .. BANK_DEPOSIT_MONEY_BUTTON_LABEL .. "|n" .. K.RightButton .. BANK_WITHDRAW_MONEY_BUTTON_LABEL
	K.AddTooltip(frame, "ANCHOR_TOP")

	return frame
end

function Module:CreateBankButton(f)
	local BankButton = CreateFrame("Button", nil, self)
	BankButton:SetSize(18, 18)
	BankButton:CreateBorder()
	BankButton:StyleButton()

	BankButton.Icon = BankButton:CreateTexture(nil, "ARTWORK")
	BankButton.Icon:SetAllPoints()
	BankButton.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
	BankButton.Icon:SetTexture(413587)

	BankButton:SetScript("OnClick", function()
		if not C_Bank_CanViewBank(CHAR_BANK_TYPE) then
			return
		end

		PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
		BankFrame.BankPanel:SetBankType(CHAR_BANK_TYPE)
	end)

	BankButton.title = BANK
	K.AddTooltip(BankButton, "ANCHOR_TOP")

	return BankButton
end

local function updateAccountBankDeposit(bu)
	if GetCVarBool("bankAutoDepositReagents") then
		bu.KKUI_Border:SetVertexColor(1, 0.8, 0)
	else
		K.SetBorderColor(bu.KKUI_Border)
	end
end

function Module:CreateAccountBankDeposit()
	local AccountBankDepositButton = CreateFrame("Button", nil, self)
	AccountBankDepositButton:SetSize(18, 18)
	AccountBankDepositButton:CreateBorder()
	AccountBankDepositButton:StyleButton()

	AccountBankDepositButton.Icon = AccountBankDepositButton:CreateTexture(nil, "ARTWORK")
	AccountBankDepositButton.Icon:SetAllPoints()
	AccountBankDepositButton.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
	AccountBankDepositButton.Icon:SetTexture("450905")

	AccountBankDepositButton:RegisterForClicks("AnyUp")
	AccountBankDepositButton:SetScript("OnClick", function(_, btn)
		if btn == "RightButton" then
			local isOn = GetCVarBool("bankAutoDepositReagents")
			SetCVar("bankAutoDepositReagents", isOn and 0 or 1)
			updateAccountBankDeposit(AccountBankDepositButton)
		end
	end)
	AccountBankDepositButton:SetScript("OnDoubleClick", function(_, btn)
		if btn == "LeftButton" then
			C_Bank.AutoDepositItemsIntoBank(ACCOUNT_BANK_TYPE)
		end
	end)
	AccountBankDepositButton.title = ACCOUNT_BANK_DEPOSIT_BUTTON_LABEL
	K.AddTooltip(AccountBankDepositButton, "ANCHOR_TOP", K.InfoColor .. "|nLeft-click to deposit warband items|n|nright-click to switch deposit modes.|n|nIf the button border is visible, items from your bags will also be deposited into your warband bank.")
	updateAccountBankDeposit(AccountBankDepositButton)

	return AccountBankDepositButton
end

function Module:CreateBankDeposit()
	local BankDepositButton = CreateFrame("Button", nil, self)
	BankDepositButton:SetSize(18, 18)
	BankDepositButton:CreateBorder()
	BankDepositButton:StyleButton()

	BankDepositButton.Icon = BankDepositButton:CreateTexture(nil, "ARTWORK")
	BankDepositButton.Icon:SetAllPoints()
	BankDepositButton.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
	BankDepositButton.Icon:SetTexture("450905")

	BankDepositButton:RegisterForClicks("AnyUp")
	BankDepositButton:SetScript("OnDoubleClick", function(_, btn)
		if btn == "LeftButton" then
			C_Bank.AutoDepositItemsIntoBank(CHAR_BANK_TYPE)
		end
	end)
	BankDepositButton.title = CHARACTER_BANK_DEPOSIT_BUTTON_LABEL
	K.AddTooltip(BankDepositButton, "ANCHOR_TOP", K.InfoColor .. "|nDuoble click the left button to deposit reagents.")

	return BankDepositButton
end

local function ToggleBackpacks(self)
	local parent = self.__owner
	if not parent.BagBar then
		return
	end

	K.TogglePanel(parent.BagBar)
	if parent.BagBar:IsShown() then
		self.KKUI_Border:SetVertexColor(1, 0.8, 0)
		PlaySound(SOUNDKIT.IG_BACKPACK_OPEN)
	else
		K.SetBorderColor(self.KKUI_Border)
		PlaySound(SOUNDKIT.IG_BACKPACK_CLOSE)
	end
end

function Module:CreateBagToggle(click)
	local bagToggleButton = CreateFrame("Button", nil, self)
	bagToggleButton:SetSize(18, 18)
	bagToggleButton:CreateBorder()
	bagToggleButton:StyleButton()

	bagToggleButton.Icon = bagToggleButton:CreateTexture(nil, "ARTWORK")
	bagToggleButton.Icon:SetAllPoints()
	bagToggleButton.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
	bagToggleButton.Icon:SetTexture("Interface\\Buttons\\Button-Backpack-Up")

	bagToggleButton.__owner = self
	bagToggleButton:SetScript("OnClick", ToggleBackpacks)
	bagToggleButton.title = BACKPACK_TOOLTIP
	K.AddTooltip(bagToggleButton, "ANCHOR_TOP")

	if click then
		ToggleBackpacks(bagToggleButton)
	end

	return bagToggleButton
end

function Module:CreateSortButton(name)
	local sortButton = CreateFrame("Button", nil, self)
	sortButton:SetSize(18, 18)
	sortButton:CreateBorder()
	sortButton:StyleButton()

	sortButton.Icon = sortButton:CreateTexture(nil, "ARTWORK")
	sortButton.Icon:SetAllPoints()
	sortButton.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
	sortButton.Icon:SetTexture("Interface\\Icons\\INV_Pet_Broom")

	sortButton:SetScript("OnClick", function()
		if name == "Bank" then
			SortBankBags()
		elseif name == "Account" then
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
	end)
	sortButton.title = "Sort"
	K.AddTooltip(sortButton, "ANCHOR_TOP")

	return sortButton
end

function Module:GetContainerEmptySlot(bagID)
	for slotID = 1, GetContainerNumSlots(bagID) do
		if not GetContainerItemID(bagID, slotID) then
			return slotID
		end
	end
end

function Module:GetEmptySlot(name)
	if name == "Bag" then
		for bagID = 0, 4 do
			local slotID = Module:GetContainerEmptySlot(bagID)
			if slotID then
				return bagID, slotID
			end
		end
	elseif name == "Bank" then
		for bagID = 6, 11 do
			local slotID = Module:GetContainerEmptySlot(bagID)
			if slotID then
				return bagID, slotID
			end
		end
	elseif name == "BagReagent" then
		local slotID = Module:GetContainerEmptySlot(5)
		if slotID then
			return 5, slotID
		end
	elseif name == "Account" then
		for bagID = 12, 16 do
			local slotID = Module:GetContainerEmptySlot(bagID)
			if slotID then
				return bagID, slotID
			end
		end
	end
end

function Module:FreeSlotOnDrop()
	local bagID, slotID = Module:GetEmptySlot(self.__name)
	if slotID then
		PickupContainerItem(bagID, slotID)
	end
end

local freeSlotContainer = {
	["Bag"] = true,
	["Bank"] = true,
	["BagReagent"] = true,
	["Account"] = true,
}

function Module:CreateFreeSlots()
	local name = self.name
	if not freeSlotContainer[name] then
		return
	end

	local slot = CreateFrame("Button", name .. "FreeSlot", self)
	slot:SetSize(self.iconSize, self.iconSize)
	slot:CreateBorder(nil, nil, nil, nil, nil, nil, "Interface\\PaperDoll\\UI-PaperDoll-Slot-Bag", nil, nil, nil, { 1, 1, 1 })
	slot:StyleButton()
	slot:SetScript("OnMouseUp", Module.FreeSlotOnDrop)
	slot:SetScript("OnReceiveDrag", Module.FreeSlotOnDrop)
	K.AddTooltip(slot, "ANCHOR_RIGHT", "FreeSlots")
	slot.__name = name

	local tag = self:SpawnPlugin("TagDisplay", "|cff5C8BCF[space]|r", slot)
	tag:SetFontObject(K.UIFontOutline)
	tag:SetFont(select(1, tag:GetFont()), 16, select(3, tag:GetFont()))
	tag:SetPoint("CENTER", 0, 0)
	tag.__name = name

	self.freeSlot = slot
end

function Module:SelectToggleButton(id)
	for index, button in pairs(toggleButtons) do
		if index ~= id then
			button.__turnOff()
		end
	end
end

local function saveSplitCount(self)
	local count = self:GetText() or ""
	KkthnxUIDB.Variables[K.Realm][K.Name].SplitCount = tonumber(count) or 1
end

local function editBoxClearFocus(self)
	self:ClearFocus()
end

function Module:CreateSplitButton()
	local enabledText = K.SystemColor .. L["StackSplitEnable"]

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
	editBox:SetScript("OnEscapePressed", editBoxClearFocus)
	editBox:SetScript("OnEnterPressed", editBoxClearFocus)
	editBox:SetScript("OnTextChanged", saveSplitCount)

	local splitButton = CreateFrame("Button", nil, self)
	splitButton:SetSize(18, 18)
	splitButton:CreateBorder()
	splitButton:StyleButton()

	splitButton.Icon = splitButton:CreateTexture(nil, "ARTWORK")
	splitButton.Icon:SetPoint("TOPLEFT", -1, 3)
	splitButton.Icon:SetPoint("BOTTOMRIGHT", 1, -3)
	splitButton.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
	splitButton.Icon:SetTexture("Interface\\HELPFRAME\\ReportLagIcon-AuctionHouse")

	splitButton.__turnOff = function()
		K.SetBorderColor(splitButton.KKUI_Border)
		splitButton.Icon:SetDesaturated(false)
		splitButton.text = nil
		splitFrame:Hide()
		splitEnable = nil
	end

	splitButton:SetScript("OnClick", function(self)
		Module:SelectToggleButton(1)
		splitEnable = not splitEnable
		if splitEnable then
			self.KKUI_Border:SetVertexColor(1, 0, 0)
			self.Icon:SetDesaturated(true)
			self.text = enabledText
			splitFrame:Show()
			editBox:SetText(KkthnxUIDB.Variables[K.Realm][K.Name].SplitCount)
		else
			self.__turnOff()
		end
		self:GetScript("OnEnter")(self)
	end)
	splitButton:SetScript("OnHide", splitButton.__turnOff)
	splitButton.title = L["Quick Split"]
	K.AddTooltip(splitButton, "ANCHOR_TOP")

	toggleButtons[1] = splitButton

	return splitButton
end

local function splitOnClick(self)
	if not splitEnable then
		return
	end

	PickupContainerItem(self.bagId, self.slotId)

	local info = C_Container_GetContainerItemInfo(self.bagId, self.slotId)
	local texture = info and info.iconFileID
	local itemCount = info and info.stackCount
	local locked = info and info.isLocked
	if texture and not locked and itemCount and itemCount > KkthnxUIDB.Variables[K.Realm][K.Name].SplitCount then
		SplitContainerItem(self.bagId, self.slotId, KkthnxUIDB.Variables[K.Realm][K.Name].SplitCount)

		local bagID, slotID = Module:GetEmptySlot("Bag")
		if slotID then
			PickupContainerItem(bagID, slotID)
		end
	end
end

local function GetCustomGroupTitle(index)
	return KkthnxUIDB.Variables[K.Realm][K.Name].CustomNames[index] or (CUSTOM .. " " .. FILTER .. " " .. index)
end

StaticPopupDialogs["KKUI_RENAMECUSTOMGROUP"] = {
	text = BATTLE_PET_RENAME,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function(self)
		local index = Module.selectGroupIndex
		local text = self.editBox:GetText()
		KkthnxUIDB.Variables[K.Realm][K.Name].CustomNames[index] = text ~= "" and text or nil

		Module.CustomMenu[index + 2].text = GetCustomGroupTitle(index)
		Module.ContainerGroups["Bag"][index].label:SetText(GetCustomGroupTitle(index))
		Module.ContainerGroups["Bank"][index].label:SetText(GetCustomGroupTitle(index))
	end,
	EditBoxOnEscapePressed = function(self)
		self:GetParent():Hide()
	end,
	whileDead = 1,
	showAlert = 1,
	hasEditBox = 1,
	editBoxWidth = 250,
}

function Module:RenameCustomGroup(index)
	Module.selectGroupIndex = index
	StaticPopup_Show("KKUI_RENAMECUSTOMGROUP")
end

function Module:MoveItemToCustomBag(index)
	local itemID = Module.selectItemID
	if index == 0 then
		if KkthnxUIDB.Variables[K.Realm][K.Name].CustomItems[itemID] then
			KkthnxUIDB.Variables[K.Realm][K.Name].CustomItems[itemID] = nil
		end
	else
		KkthnxUIDB.Variables[K.Realm][K.Name].CustomItems[itemID] = index
	end
	Module:UpdateAllBags()
end

function Module:IsItemInCustomBag()
	local index = self.arg1
	local itemID = Module.selectItemID
	return (index == 0 and not KkthnxUIDB.Variables[K.Realm][K.Name].CustomItems[itemID]) or (KkthnxUIDB.Variables[K.Realm][K.Name].CustomItems[itemID] == index)
end

function Module:CreateFavouriteButton()
	local menuList = {
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
		{ text = NONE, arg1 = 0, func = Module.MoveItemToCustomBag, checked = Module.IsItemInCustomBag },
	}
	for i = 1, 5 do
		tinsert(menuList, {
			text = GetCustomGroupTitle(i),
			arg1 = i,
			func = Module.MoveItemToCustomBag,
			checked = Module.IsItemInCustomBag,
			hasArrow = true,
			menuList = { { text = BATTLE_PET_RENAME, arg1 = i, func = Module.RenameCustomGroup } },
		})
	end
	Module.CustomMenu = menuList

	local enabledText = K.SystemColor .. L["Custom Filter Mode Enabled"]

	local favouriteButton = CreateFrame("Button", nil, self)
	favouriteButton:SetSize(18, 18)
	favouriteButton:CreateBorder()
	favouriteButton:StyleButton()

	favouriteButton.Icon = favouriteButton:CreateTexture(nil, "ARTWORK")
	favouriteButton.Icon:SetPoint("TOPLEFT", -4, 3.5)
	favouriteButton.Icon:SetPoint("BOTTOMRIGHT", 4, -2.5)
	favouriteButton.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
	favouriteButton.Icon:SetTexture("Interface\\Common\\friendship-heart")

	favouriteButton.__turnOff = function()
		K.SetBorderColor(favouriteButton.KKUI_Border)
		favouriteButton.Icon:SetDesaturated(false)
		favouriteButton.text = nil
		favouriteEnable = nil
	end

	favouriteButton:SetScript("OnClick", function(self)
		Module:SelectToggleButton(2)
		favouriteEnable = not favouriteEnable
		if favouriteEnable then
			self.KKUI_Border:SetVertexColor(1, 0, 0)
			self.Icon:SetDesaturated(true)
			self.text = enabledText
		else
			self.__turnOff()
		end
		self:GetScript("OnEnter")(self)
	end)
	favouriteButton:SetScript("OnHide", favouriteButton.__turnOff)
	favouriteButton.title = L["Custom Filter Mode"]
	K.AddTooltip(favouriteButton, "ANCHOR_TOP")

	toggleButtons[2] = favouriteButton

	return favouriteButton
end

local function favouriteOnClick(self)
	if not favouriteEnable then
		return
	end

	local info = C_Container_GetContainerItemInfo(self.bagId, self.slotId)
	local texture = info and info.iconFileID
	local quality = info and info.quality
	local link = info and info.hyperlink
	local itemID = info and info.itemID
	if texture and quality > Enum.ItemQuality.Poor then
		ClearCursor()
		Module.selectItemID = itemID
		Module.CustomMenu[1].text = link
		Module.CustomMenu[1].icon = texture
		K.LibEasyMenu.Create(Module.CustomMenu, K.EasyMenu, self, 0, 0, "MENU")
	end
end

function Module:CreateJunkButton()
	local enabledText = K.InfoColor .. "|nClick an item to tag it as junk.|n|nIf 'Module Autosell' is enabled, these items will be sold as well.|n|nThe list is saved account-wide."

	local JunkButton = CreateFrame("Button", nil, self)
	JunkButton:SetSize(18, 18)
	JunkButton:CreateBorder()
	JunkButton:StyleButton()

	JunkButton.Icon = JunkButton:CreateTexture(nil, "ARTWORK")
	JunkButton.Icon:SetPoint("TOPLEFT", 1, -2)
	JunkButton.Icon:SetPoint("BOTTOMRIGHT", -1, -2)
	JunkButton.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
	JunkButton.Icon:SetTexture("Interface\\BUTTONS\\UI-GroupLoot-Coin-Up")

	JunkButton.__turnOff = function()
		K.SetBorderColor(JunkButton.KKUI_Border)
		JunkButton.Icon:SetDesaturated(false)
		JunkButton.text = nil
		customJunkEnable = nil
	end

	JunkButton:SetScript("OnClick", function(self)
		Module:SelectToggleButton(3)
		customJunkEnable = not customJunkEnable
		if customJunkEnable then
			self.KKUI_Border:SetVertexColor(1, 0, 0)
			self.Icon:SetDesaturated(true)
			self.text = enabledText
		else
			JunkButton.__turnOff()
		end
		self:GetScript("OnEnter")(self)
		Module:UpdateAllBags()
	end)
	JunkButton:SetScript("OnHide", JunkButton.__turnOff)
	JunkButton.title = "Custom Junk List"
	K.AddTooltip(JunkButton, "ANCHOR_TOP")

	toggleButtons[3] = JunkButton

	return JunkButton
end

local function customJunkOnClick(self)
	if not customJunkEnable then
		return
	end

	local info = C_Container_GetContainerItemInfo(self.bagId, self.slotId)
	local texture = info and info.iconFileID
	local itemID = info and info.itemID
	local price = select(11, GetItemInfo(itemID))
	if texture and price > 0 then
		if KkthnxUIDB.Variables[K.Realm][K.Name].CustomJunkList[itemID] then
			KkthnxUIDB.Variables[K.Realm][K.Name].CustomJunkList[itemID] = nil
		else
			KkthnxUIDB.Variables[K.Realm][K.Name].CustomJunkList[itemID] = true
		end
		ClearCursor()
		Module:UpdateAllBags()
	end
end

function Module:CreateDeleteButton()
	local enabledText = K.SystemColor .. L["Delete Mode Enabled"]

	local deleteButton = CreateFrame("Button", nil, self)
	deleteButton:SetSize(18, 18)
	deleteButton:CreateBorder()
	deleteButton:StyleButton()

	deleteButton.Icon = deleteButton:CreateTexture(nil, "ARTWORK")
	deleteButton.Icon:SetPoint("TOPLEFT", 3, -2)
	deleteButton.Icon:SetPoint("BOTTOMRIGHT", -1, 2)
	deleteButton.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
	deleteButton.Icon:SetTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Up")

	deleteButton.__turnOff = function()
		K.SetBorderColor(deleteButton.KKUI_Border)
		deleteButton.Icon:SetDesaturated(false)
		deleteButton.text = nil
		deleteEnable = nil
	end

	deleteButton:SetScript("OnClick", function(self)
		Module:SelectToggleButton(4)
		deleteEnable = not deleteEnable
		if deleteEnable then
			self.KKUI_Border:SetVertexColor(1, 0, 0)
			self.Icon:SetDesaturated(true)
			self.text = enabledText
		else
			deleteButton.__turnOff()
		end
		self:GetScript("OnEnter")(self)
	end)
	deleteButton:SetScript("OnHide", deleteButton.__turnOff)
	deleteButton.title = L["Item Delete Mode"]
	K.AddTooltip(deleteButton, "ANCHOR_TOP")

	toggleButtons[4] = deleteButton

	return deleteButton
end

local function deleteButtonOnClick(self)
	if not deleteEnable then
		return
	end

	local info = C_Container_GetContainerItemInfo(self.bagId, self.slotId)
	local texture = info and info.iconFileID
	local quality = info and info.quality
	if IsControlKeyDown() and IsAltKeyDown() and texture and (quality < Enum.ItemQuality.Rare) then
		PickupContainerItem(self.bagId, self.slotId)
		DeleteCursorItem()
	end
end

function Module:ButtonOnClick(btn)
	if btn ~= "LeftButton" then
		return
	end

	splitOnClick(self)
	favouriteOnClick(self)
	customJunkOnClick(self)
	deleteButtonOnClick(self)
end

function Module:UpdateAllBags()
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

	-- Check for conflicting bag addons (cached at local level for faster access)
	if C_AddOns.IsAddOnLoaded("AdiBags") or C_AddOns.IsAddOnLoaded("ArkInventory") or C_AddOns.IsAddOnLoaded("cargBags_Nivaya") or C_AddOns.IsAddOnLoaded("cargBags") or C_AddOns.IsAddOnLoaded("Bagnon") or C_AddOns.IsAddOnLoaded("Combuctor") or C_AddOns.IsAddOnLoaded("TBag") or C_AddOns.IsAddOnLoaded("BaudBag") then
		return
	end

	-- Settings
	local iconSize = C["Inventory"].IconSize
	local showItemLevel = C["Inventory"].BagsItemLevel
	local showBindOnEquip = C["Inventory"].BagsBindOnEquip
	local showNewItem = C["Inventory"].ShowNewItem
	local hasCanIMogIt = C_AddOns.IsAddOnLoaded("CanIMogIt")
	local hasPawn = C_AddOns.IsAddOnLoaded("Pawn")

	-- Init
	local Backpack = cargBags:NewImplementation("KKUI_Backpack")
	Backpack:RegisterBlizzard()

	Backpack:HookScript("OnShow", function()
		PlaySound(SOUNDKIT.IG_BACKPACK_OPEN)
	end)

	Backpack:HookScript("OnHide", function()
		PlaySound(SOUNDKIT.IG_BACKPACK_CLOSE)
	end)

	Module.Bags = Backpack
	Module.BagsType = {}
	Module.BagsType[0] = 0 -- Backpack

	local f = {}
	local filters = Module:GetFilters()
	local MyContainer = Backpack:GetContainerClass()
	Module.ContainerGroups = { ["Bag"] = {}, ["Bank"] = {}, ["Account"] = {} }

	local function AddNewContainer(bagType, index, name, filter)
		local newContainer = MyContainer:New(name, { BagType = bagType, Index = index })
		newContainer:SetFilter(filter, true)
		Module.ContainerGroups[bagType][index] = newContainer
	end

	function Backpack:OnInit()
		for i = 1, 5 do
			AddNewContainer("Bag", i, "BagCustom" .. i, filters["bagCustom" .. i])
		end
		AddNewContainer("Bag", 6, "BagReagent", filters.onlyBagReagent)
		AddNewContainer("Bag", 20, "Junk", filters.bagsJunk)
		AddNewContainer("Bag", 9, "EquipSet", filters.bagEquipSet)
		AddNewContainer("Bag", 10, "BagAOE", filters.bagAOE)
		AddNewContainer("Bag", 7, "AzeriteItem", filters.bagAzeriteItem)
		AddNewContainer("Bag", 17, "BagLegacy", filters.bagLegacy)
		AddNewContainer("Bag", 19, "BagLower", filters.bagLower)
		AddNewContainer("Bag", 8, "Equipment", filters.bagEquipment)
		AddNewContainer("Bag", 11, "BagCollection", filters.bagCollection)
		AddNewContainer("Bag", 14, "BagStone", filters.bagStone)
		AddNewContainer("Bag", 18, "BagKeystone", filters.bagKeystone)
		AddNewContainer("Bag", 15, "Consumable", filters.bagConsumable)
		AddNewContainer("Bag", 12, "BagGoods", filters.bagGoods)
		AddNewContainer("Bag", 16, "BagQuest", filters.bagQuest)
		AddNewContainer("Bag", 13, "BagAnima", filters.bagAnima)

		f.main = MyContainer:New("Bag", { Bags = "bags", BagType = "Bag" })
		f.main.__anchor = { "BOTTOMRIGHT", -50, 100 }
		f.main:SetPoint(unpack(f.main.__anchor))
		f.main:SetFilter(filters.onlyBags, true)

		for i = 1, 5 do
			AddNewContainer("Bank", i, "BankCustom" .. i, filters["bankCustom" .. i])
		end
		AddNewContainer("Bank", 8, "BankEquipSet", filters.bankEquipSet)
		AddNewContainer("Bank", 9, "BankAOE", filters.bankAOE)
		AddNewContainer("Bank", 6, "BankAzeriteItem", filters.bankAzeriteItem)
		AddNewContainer("Bank", 10, "BankLegendary", filters.bankLegendary)
		AddNewContainer("Bank", 16, "BankLegacy", filters.bankLegacy)
		AddNewContainer("Bank", 17, "BankLower", filters.bankLower)
		AddNewContainer("Bank", 7, "BankEquipment", filters.bankEquipment)
		AddNewContainer("Bank", 11, "BankCollection", filters.bankCollection)
		AddNewContainer("Bank", 14, "BankConsumable", filters.bankConsumable)
		AddNewContainer("Bank", 12, "BankGoods", filters.bankGoods)
		AddNewContainer("Bank", 15, "BankQuest", filters.bankQuest)
		AddNewContainer("Bank", 13, "BankAnima", filters.bankAnima)

		f.bank = MyContainer:New("Bank", { Bags = "bank", BagType = "Bank" })
		f.bank.__anchor = { "BOTTOMLEFT", 25, 50 }
		f.bank:SetPoint(unpack(f.bank.__anchor))
		f.bank:SetFilter(filters.onlyBank, true)
		f.bank:Hide()

		for i = 1, 5 do
			AddNewContainer("Account", i, "AccountCustom" .. i, filters["accountCustom" .. i])
		end
		AddNewContainer("Account", 8, "AccountAOE", filters.accountAOE)
		AddNewContainer("Account", 7, "AccountLegacy", filters.accountLegacy)
		AddNewContainer("Account", 6, "AccountEquipment", filters.accountEquipment)
		AddNewContainer("Account", 10, "AccountConsumable", filters.accountConsumable)
		AddNewContainer("Account", 9, "AccountGoods", filters.accountGoods)

		f.accountbank = MyContainer:New("Account", { Bags = "accountbank", BagType = "Account" })
		f.accountbank:SetFilter(filters.accountbank, true)
		f.accountbank:SetPoint(unpack(f.bank.__anchor))
		f.accountbank:Hide()

		for bagType, groups in pairs(Module.ContainerGroups) do
			for _, container in ipairs(groups) do
				local parent = Backpack.contByName[bagType]
				container:SetParent(parent)
				K.CreateMoverFrame(container, parent, true)
			end
		end
	end

	local initBagType
	function Backpack:OnBankOpened()
		BankFrame:Show()
		BankFrame.BankPanel:Show()

		if not initBagType then
			Module:UpdateBagSize()
			initBagType = true
		end
	end

	function Backpack:OnBankClosed()
		self:GetContainer("Bank"):Hide()
		BankFrame.BankPanel:Hide()
		self:GetContainer("Account"):Hide()
	end

	local MyButton = Backpack:GetItemButtonClass()
	MyButton:Scaffold("Default")

	function MyButton:OnCreate()
		self:SetNormalTexture(0)
		self:SetPushedTexture(0)
		self:SetSize(iconSize, iconSize)

		self.Icon:SetAllPoints()
		self.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])

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

		local parentFrame = CreateFrame("Frame", nil, self)
		parentFrame:SetAllPoints()
		parentFrame:SetFrameLevel(12)

		self.Favourite = parentFrame:CreateTexture(nil, "OVERLAY")
		self.Favourite:SetAtlas("collections-icon-favorites")
		self.Favourite:SetSize(28, 28)
		self.Favourite:SetPoint("TOPRIGHT", 4, 3)

		self.QuestTag = parentFrame:CreateTexture(nil, "OVERLAY")
		self.QuestTag:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\Inventory\\QuestIcon.tga")
		self.QuestTag:SetSize(26, 26)
		self.QuestTag:SetPoint("LEFT", 0, 1)

		self.iLvl = K.CreateFontString(self, 12, "", "OUTLINE", false, "BOTTOMLEFT", 1, 0)
		self.iLvl:SetFontObject(K.UIFontOutline)
		self.iLvl:SetFont(select(1, self.iLvl:GetFont()), 12, select(3, self.iLvl:GetFont()))

		self.bindType = K.CreateFontString(self, 12, "", "OUTLINE", false, "TOPLEFT", 1, -2)
		self.bindType:SetFontObject(K.UIFontOutline)
		self.bindType:SetFont(select(1, self.iLvl:GetFont()), 12, select(3, self.iLvl:GetFont()))

		if showNewItem and not self.glowFrame then
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
			self.canIMogIt = parentFrame:CreateTexture(nil, "OVERLAY")
			self.canIMogIt:SetSize(C["Inventory"].IconSize / 2.6, C["Inventory"].IconSize / 2.6)
			self.canIMogIt:SetPoint(unpack(CanIMogIt.ICON_LOCATIONS[CanIMogItOptions["iconLocation"]]))
		end

		if not self.ProfessionQualityOverlay then
			self.ProfessionQualityOverlay = parentFrame:CreateTexture(nil, "OVERLAY")
			self.ProfessionQualityOverlay:SetPoint("TOPLEFT", -3, 2)
		end
	end

	function MyButton:ItemOnEnter()
		if self.glowFrame and self.glowFrame.Animation then
			local isNewItem = C_NewItems.IsNewItem(self.bagId, self.slotId)
			local isAnimationPlaying = self.glowFrame.Animation:IsPlaying()

			if not isNewItem and isAnimationPlaying then
				self.glowFrame.Animation:Stop()
				self.glowFrame:Hide()
				C_NewItems_RemoveNewItem(self.bagId, self.slotId)
			end
		end
	end

	local bagTypeColor = {
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

	local function GetIconOverlayAtlas(item)
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

	local function UpdateCanIMogIt(self, item)
		if not self.canIMogIt then
			return
		end

		local text, unmodifiedText = CanIMogIt:GetTooltipText(nil, item.bagId, item.slotId)
		if text and text ~= "" then
			local icon = CanIMogIt.tooltipOverlayIcons[unmodifiedText]
			self.canIMogIt:SetTexture(icon)
			self.canIMogIt:Show()
		else
			self.canIMogIt:Hide()
		end
	end

	-- Upgrade arrow update (ElvUI-style integration per Pawn guidance)
	local ITEM_UPGRADE_CHECK_TIME = 0.5

	local function UpgradeCheck_OnUpdate(self, elapsed)
		self._timeSinceUpgradeCheck = (self._timeSinceUpgradeCheck or 0) + elapsed
		if self._timeSinceUpgradeCheck >= ITEM_UPGRADE_CHECK_TIME then
			self._timeSinceUpgradeCheck = 0
			if self._callUpdateUpgradeIcon then
				self:_callUpdateUpgradeIcon()
			end
		end
	end

	local function UpdatePawnArrow(self, item)
		if not self or not self.UpgradeIcon then
			return
		end

		-- Respect user setting; only show for equippable items
		if not C["Inventory"].UpgradeIcon or not item or not item.link or not IsEquippableItem(item.link) then
			self.UpgradeIcon:SetShown(false)
			self:SetScript("OnUpdate", nil)
			return
		end

		local itemIsUpgrade
		local containerID, slotID = item.bagId, item.slotId

		-- Prefer Pawn API; fallback to Blizzard API if needed
		if _G.PawnIsContainerItemAnUpgrade then
			itemIsUpgrade = _G.PawnIsContainerItemAnUpgrade(containerID, slotID)
		end
		if itemIsUpgrade == nil and _G.IsContainerItemAnUpgrade then
			itemIsUpgrade = _G.IsContainerItemAnUpgrade(containerID, slotID)
		end

		self.UpgradeIcon:ClearAllPoints()
		self.UpgradeIcon:SetPoint("TOPRIGHT", 3, 3)

		if itemIsUpgrade == nil then
			-- Data not ready yet; hide for now and retry on a throttled OnUpdate
			self.UpgradeIcon:SetShown(false)
			self._callUpdateUpgradeIcon = function(btn)
				-- Re-evaluate using the latest item for this button
				UpdatePawnArrow(btn, item)
			end
			self:SetScript("OnUpdate", UpgradeCheck_OnUpdate)
		else
			self.UpgradeIcon:SetShown(itemIsUpgrade)
			self:SetScript("OnUpdate", nil)
		end
	end

	function MyButton:OnUpdateButton(item)
		if self.JunkIcon then
			if (item.quality == Enum.ItemQuality.Poor or KkthnxUIDB.Variables[K.Realm][K.Name].CustomJunkList[item.id]) and item.hasPrice then
				self.JunkIcon:Show()
			else
				self.JunkIcon:Hide()
			end
		end

		-- Determine if we can use that item
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

		local atlas, secondAtlas = GetIconOverlayAtlas(item)
		if atlas then
			self.IconOverlay:SetAtlas(atlas)
			self.IconOverlay:Show()

			if secondAtlas then
				local color = K.QualityColors[item.quality or 1]
				self.IconOverlay:SetVertexColor(color.r, color.g, color.b)
				self.IconOverlay2:SetAtlas(secondAtlas)
				self.IconOverlay2:Show()
			end
		end

		if self.ProfessionQualityOverlay then
			self.ProfessionQualityOverlay:SetAtlas(nil)
			SetItemCraftingQualityOverlay(self, item.link)
		end

		if KkthnxUIDB.Variables[K.Realm][K.Name].CustomItems[item.id] and not C["Inventory"].ItemFilter then
			self.Favourite:Show()
		else
			self.Favourite:Hide()
		end

		self.iLvl:SetText("")
		if showItemLevel then
			local level = item.level -- ilvl for keystone and battlepet
			if not level and isItemNeedsLevel(item) then
				level = item.ilvl
			end

			if level then
				local color = K.QualityColors[item.quality]
				self.iLvl:SetText(level)
				self.iLvl:SetTextColor(color.r, color.g, color.b)
			end
		end

		self.bindType:SetText("")
		if showBindOnEquip then
			local BoE, BoU = item.bindType == 2, item.bindType == 3
			if BoE or BoU then
				if item.quality > 1 and not item.bound then
					local color = K.QualityColors[item.quality]
					self.bindType:SetText(BoE and L["BoE"] or L["BoU"]) -- Local these asap
					self.bindType:SetTextColor(color.r, color.g, color.b)
				end
			end
		end

		if self.glowFrame then
			if C_NewItems_IsNewItem(item.bagId, item.slotId) then
				local color = K.QualityColors[item.quality] or {}
				if item.questID or item.isQuestItem then
					self.glowFrame:SetBackdropBorderColor(1, 0.82, 0.2, 1)
				elseif color.r and color.g and color.b then
					self.glowFrame:SetBackdropBorderColor(color.r, color.g, color.b, 1)
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
			local color = bagTypeColor[bagType] or bagTypeColor[0]
			self:SetBackdropColor(unpack(color))
		else
			self:SetBackdropColor(0.04, 0.04, 0.04, 0.9)
		end

		-- Hide empty tooltip
		if not item.texture and not GameTooltip:IsForbidden() and GameTooltip:GetOwner() == self then
			GameTooltip:Hide()
		end

		-- Support CanIMogIt
		UpdateCanIMogIt(self, item)

		-- Support Pawn
		UpdatePawnArrow(self, item)
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
			local color = K.QualityColors[item.quality]
			self.KKUI_Border:SetVertexColor(color.r, color.g, color.b)
		else
			K.SetBorderColor(self.KKUI_Border)
		end
	end

	function Module:UpdateAllAnchors()
		Module:UpdateBagsAnchor(f.main, Module.ContainerGroups["Bag"])
		Module:UpdateBankAnchor(f.bank, Module.ContainerGroups["Bank"])
		Module:UpdateBankAnchor(f.accountbank, Module.ContainerGroups["Account"])
	end

	function Module:GetContainerColumns(bagType)
		if bagType == "Bag" then
			return C["Inventory"].BagsWidth
		elseif bagType == "Bank" then
			return C["Inventory"].BankWidth
		elseif bagType == "Account" then
			return C["Inventory"].BankWidth -- AccountWidth
		end
	end

	function MyContainer:OnContentsChanged(gridOnly)
		self:SortButtons("bagSlot")

		local columns = Module:GetContainerColumns(self.Settings.BagType)
		local offset = 38
		local spacing = 6
		local xOffset = 6
		local yOffset = -offset + xOffset
		local _, height = self:LayoutButtons("grid", columns, spacing, xOffset, yOffset)
		local width = columns * (iconSize + spacing) - spacing
		if self.freeSlot then
			if C["Inventory"].GatherEmpty then
				local numSlots = #self.buttons + 1
				local row = ceil(numSlots / columns)
				local col = numSlots % columns
				if col == 0 then
					col = columns
				end

				local xPos = (col - 1) * (iconSize + spacing)
				local yPos = -1 * (row - 1) * (iconSize + spacing)

				self.freeSlot:ClearAllPoints()
				self.freeSlot:SetPoint("TOPLEFT", self, "TOPLEFT", xPos + xOffset, yPos + yOffset)
				self.freeSlot:Show()

				if height < 0 then
					height = iconSize
				elseif col == 1 then
					height = height + iconSize + spacing
				end
			else
				self.freeSlot:Hide()
			end
		end
		self:SetSize(width + xOffset * 2, height + offset)

		if not gridOnly then
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

		local label
		-- Use patterns with '$' to match the end of the string
		if name:match("AzeriteItem$") then
			label = L["Azerite Armor"]
		elseif name:match("Equipment$") then
			label = BAG_FILTER_EQUIPMENT
		elseif name:match("EquipSet$") then
			label = L["Equipment Set"]
		elseif name == "Junk" then
			label = BAG_FILTER_JUNK
		elseif name == "BagRelic" then
			label = L["Korthian Relics"]
		elseif name == "BagReagent" then
			label = L["Reagent Bag"]
		elseif name == "BagStone" then
			label = C_Spell_GetSpellName(404861)
		elseif name:match("Keystone$") then
			label = WEEKLY_REWARDS_MYTHIC_KEYSTONE
		elseif strmatch(name, "AOE") then
			label = ITEM_ACCOUNTBOUND_UNTIL_EQUIP
		elseif strmatch(name, "Lower") then
			label = L["Lower Item Level"]
		elseif strmatch(name, "Legacy") then
			label = L["Legacy Items"]
		else
			if name:match("Legendary$") then
				label = LOOT_JOURNAL_LEGENDARIES
			elseif name:match("Consumable$") then
				label = BAG_FILTER_CONSUMABLES
			elseif name:match("Collection") then
				label = COLLECTIONS
			elseif name:match("Goods") then
				label = AUCTION_CATEGORY_TRADE_GOODS
			elseif name:match("Quest") then
				label = QUESTS_LABEL
			elseif name:match("Anima") then
				label = POWER_TYPE_ANIMA
			elseif name:match("Custom%d") then
				-- If 'name' matches the pattern "Custom%d", call GetCustomGroupTitle
				label = GetCustomGroupTitle(settings.Index)
			end
		end

		if label then
			-- Create font string only if label is found
			self.label = K.CreateFontString(self, 13, label, "OUTLINE", true, "TOPLEFT", 6, -8)
			return
		end

		Module.CreateInfoFrame(self)

		local buttons = {}
		buttons[1] = Module.CreateCloseButton(self, f)
		buttons[2] = Module.CreateSortButton(self, name)
		if name == "Bag" then
			Module.CreateBagBar(self, settings, 5)
			buttons[3] = Module.CreateBagToggle(self)
			buttons[4] = Module.CreateSplitButton(self)
			buttons[5] = Module.CreateFavouriteButton(self)
			buttons[6] = Module.CreateJunkButton(self)
			buttons[7] = Module.CreateDeleteButton(self)
		elseif name == "Bank" then
			Module.CreateBagTab(self, settings, 6)
			buttons[3] = Module.CreateBagToggle(self)
			buttons[4] = Module.CreateBankDeposit(self)
			buttons[5] = Module.CreateAccountBankButton(self, f)
		elseif name == "Account" then
			Module.CreateBagTab(self, settings, 5, "account")
			buttons[3] = Module.CreateBagToggle(self)
			buttons[4] = Module.CreateAccountBankDeposit(self)
			buttons[5] = Module.CreateBankButton(self, f)
			buttons[6] = Module.CreateAccountMoney(self)
		end

		for i = 1, #buttons do
			local bu = buttons[i]
			if not bu then
				break
			end

			if i == 1 then
				bu:SetPoint("TOPRIGHT", -6, -6)
			else
				bu:SetPoint("RIGHT", buttons[i - 1], "LEFT", -6, 0)
			end
		end
		self.widgetButtons = buttons

		if name == "Bag" then
			Module.CreateCollapseArrow(self)
		end

		self:HookScript("OnShow", K.RestoreMoverFrame)
	end

	local function updateBagSize(button)
		button:SetSize(iconSize, iconSize)
		if button.glowFrame then
			button.glowFrame:SetSize(iconSize + 8, iconSize + 8)
		end
	end

	-- Called from GUI hooks to refresh bag visuals when options change
	function Module:UpdateBagStatus()
		Module:UpdateAllBags()
	end

	function Module:UpdateBagSize()
		iconSize = C["Inventory"].IconSize
		for _, container in pairs(Backpack.contByName) do
			container:ApplyToButtons(updateBagSize)
			if container.freeSlot then
				container.freeSlot:SetSize(iconSize, iconSize)
			end
			if container.BagBar then
				for _, bagButton in pairs(container.BagBar.buttons) do
					bagButton:SetSize(iconSize, iconSize)
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
		self.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
	end

	function BagButton:OnUpdateButton()
		local id = GetInventoryItemID("player", (self.GetInventorySlot and self:GetInventorySlot()) or self.invID)
		if not id then
			return
		end

		local _, _, quality, _, _, _, _, _, _, _, _, classID, subClassID = GetItemInfo(id)
		if not quality or quality == 1 then
			quality = 0
		end

		local color = K.QualityColors[quality]
		if not self.hidden and not self.notBought then
			self.KKUI_Border:SetVertexColor(color.r, color.g, color.b)
		else
			K.SetBorderColor(self.KKUI_Border)
		end

		if classID == LE_ITEM_CLASS_CONTAINER then
			Module.BagsType[self.bagId] = subClassID or 0
		else
			Module.BagsType[self.bagId] = 0
		end
	end

	-- Sort order
	C_Container_SetSortBagsRightToLeft(not C["Inventory"].ReverseSort)
	C_Container_SetInsertItemsLeftToRight(false)

	-- Init
	C["Inventory"].GatherEmpty = not C["Inventory"].GatherEmpty
	ToggleAllBags()
	C["Inventory"].GatherEmpty = not C["Inventory"].GatherEmpty
	ToggleAllBags()
	Module.initComplete = true

	K:RegisterEvent("TRADE_SHOW", Module.OpenBags)
	K:RegisterEvent("TRADE_CLOSED", Module.CloseBags)

	-- Update DataText slots
	if _G.KKUI_GoldDataText then
		Backpack.OnOpen = function()
			if not KkthnxUIDB.ShowSlots then
				return
			end
			K.GoldButton_OnEvent()
		end
	end

	local passedSystems = {
		["TutorialReagentBag"] = true,
	}
	hooksecurefunc(HelpTip, "Show", function(self, _, info)
		if info and passedSystems[info.system] then
			self:HideAllSystem(info.system)
		end
	end)
	SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_EQUIP_REAGENT_BAG, true)

	SetCVar("professionToolSlotsExampleShown", 1)
	SetCVar("professionAccessorySlotsExampleShown", 1)

	-- Bank frame paging
	hooksecurefunc(BankFrame.BankPanel, "SetBankType", function(self, bankType)
		Module.Bags:GetContainer("Bank"):SetShown(bankType == CHAR_BANK_TYPE)
		Module.Bags:GetContainer("Account"):SetShown(bankType == ACCOUNT_BANK_TYPE)
		Module:UpdateAllBags()
		if _G["KKUI_BankPurchaseButton"] then
			_G["KKUI_BankPurchaseButton"]:SetShown(bankType == ACCOUNT_BANK_TYPE and C_Bank.CanPurchaseBankTab(ACCOUNT_BANK_TYPE))
		end
	end)

	-- Delay updates for data jam
	local updater = CreateFrame("Frame", nil, f.main)
	updater:Hide()
	updater:SetScript("OnUpdate", function(self, elapsed)
		self.delay = self.delay - elapsed
		if self.delay < 0 then
			Module:UpdateAllBags()
			self:Hide()
		end
	end)

	K:RegisterEvent("GET_ITEM_INFO_RECEIVED", function()
		if Module.Bags and Module.Bags:IsShown() then
			updater.delay = 1
			updater:Show()
		end
	end)
end
