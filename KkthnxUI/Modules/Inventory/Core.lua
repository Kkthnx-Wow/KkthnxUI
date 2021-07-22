local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("Bags")

local Unfit = K.Unfit
local cargBags = K.cargBags

local _G = _G
local ceil = _G.ceil
local ipairs = _G.ipairs
local string_match = _G.string.match
local table_wipe = _G.table.wipe
local unpack = _G.unpack

local C_AzeriteEmpoweredItem_IsAzeriteEmpoweredItemByID = _G.C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItemByID
local C_NewItems_IsNewItem = _G.C_NewItems.IsNewItem
local C_NewItems_RemoveNewItem = _G.C_NewItems.RemoveNewItem
local C_Soulbinds_IsItemConduitByItemInfo = _G.C_Soulbinds.IsItemConduitByItemInfo
local C_Timer_After = _G.C_Timer.After
local ClearCursor = _G.ClearCursor
local CreateFrame = _G.CreateFrame
local DeleteCursorItem = _G.DeleteCursorItem
local GetContainerItemID = _G.GetContainerItemID
local GetContainerItemInfo = _G.GetContainerItemInfo
local GetContainerNumSlots = _G.GetContainerNumSlots
local GetInventoryItemID = _G.GetInventoryItemID
local GetItemInfo = _G.GetItemInfo
local InCombatLockdown = _G.InCombatLockdown
local IsAltKeyDown = _G.IsAltKeyDown
local IsControlKeyDown = _G.IsControlKeyDown
local IsCosmeticItem = _G.IsCosmeticItem
local IsReagentBankUnlocked = _G.IsReagentBankUnlocked
local LE_ITEM_QUALITY_POOR = _G.LE_ITEM_QUALITY_POOR
local PickupContainerItem = _G.PickupContainerItem
local PlaySound = _G.PlaySound
local SOUNDKIT = _G.SOUNDKIT
local SortBags = _G.SortBags
local SortBankBags = _G.SortBankBags

local bagsFont = K.GetFont(C["UIFonts"].InventoryFonts)
local toggleButtons = {}
local deleteEnable, favouriteEnable, splitEnable, customJunkEnable
local sortCache = {}

function Module:ReverseSort()
	for bag = 0, 4 do
		local numSlots = GetContainerNumSlots(bag)
		for slot = 1, numSlots do
			local texture, _, locked = GetContainerItemInfo(bag, slot)
			if (slot <= numSlots / 2) and texture and not locked and not sortCache["b"..bag.."s"..slot] then
				PickupContainerItem(bag, slot)
				PickupContainerItem(bag, numSlots+1 - slot)
				sortCache["b"..bag.."s"..slot] = true
			end
		end
	end

	Module.Bags.isSorting = false
	Module:UpdateAllBags()
end

function Module:UpdateAnchors(parent, bags)
	if not parent:IsShown() then
		return
	end

	local anchor = parent
	for _, bag in ipairs(bags) do
		if bag:GetHeight() > 45 then
			bag:Show()
		else
			bag:Hide()
		end

		if bag:IsShown() then
			bag:SetPoint("BOTTOMLEFT", anchor, "TOPLEFT", 0, 6)
			anchor = bag
		end
	end
end

local function highlightFunction(button, match)
	button:SetAlpha(match and 1 or 0.25)
end

function Module:CreateInfoFrame()
	local infoFrame = CreateFrame("Button", nil, self)
	infoFrame:SetPoint("TOPLEFT", 10, 0)
	infoFrame:SetSize(160, 32)

	local icon = CreateFrame("Button", nil, infoFrame)
	icon:SetSize(18, 18)
	icon:SetPoint("LEFT")
	icon:EnableMouse(false)

	icon.Icon = icon:CreateTexture(nil, "ARTWORK")
	icon.Icon:SetAllPoints()
	icon.Icon:SetTexCoord(unpack(K.TexCoords))
	icon.Icon:SetTexture("Interface\\Minimap\\Tracking\\None")

	local search = self:SpawnPlugin("SearchBar", infoFrame)
	search.highlightFunction = highlightFunction
	search.isGlobal = true
	search:SetPoint("LEFT", 0, 5)
	search:DisableDrawLayer("BACKGROUND")
	search:CreateBackdrop()
	search.Backdrop:SetPoint("TOPLEFT", -5, -7)
	search.Backdrop:SetPoint("BOTTOMRIGHT", 5, 7)

	local moneyTag = self:SpawnPlugin("TagDisplay", "[money]", infoFrame)
	moneyTag:SetFontObject(bagsFont)
	moneyTag:SetFont(select(1, moneyTag:GetFont()), 13, select(3, moneyTag:GetFont()))
	moneyTag:SetPoint("LEFT", icon, "RIGHT", 5, 0)

	local moneyTagFrame = CreateFrame("Frame", nil, UIParent)
	moneyTagFrame:SetParent(infoFrame)
	moneyTagFrame:SetAllPoints(moneyTag)
	moneyTagFrame:SetScript("OnEnter", K.GoldButton_OnEnter)
	moneyTagFrame:SetScript("OnLeave", K.GoldButton_OnLeave)

	local currencyTag = self:SpawnPlugin("TagDisplay", "[currencies]", infoFrame)
	currencyTag:SetFontObject(bagsFont)
	currencyTag:SetFont(select(1, currencyTag:GetFont()), 13, select(3, currencyTag:GetFont()))
	currencyTag:SetPoint("TOP", self, "BOTTOM", 0, -6)
end

function Module:CreateBagBar(settings, columns)
	local bagBar = self:SpawnPlugin("BagBar", settings.Bags)
	local width, height = bagBar:LayoutButtons("grid", columns, 6, 5, -5)
	bagBar:SetSize(width + 10, height + 10)
	bagBar:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, -6)
	bagBar:CreateBorder()
	bagBar.highlightFunction = highlightFunction
	bagBar.isGlobal = true
	bagBar:Hide()

	self.BagBar = bagBar
end

function Module:CreateCloseButton()
	local closeButton = CreateFrame("Button", nil, self)
	closeButton:SetSize(18, 18)
	closeButton:CreateBorder()
	closeButton:StyleButton()

	closeButton.Icon = closeButton:CreateTexture(nil, "ARTWORK")
	closeButton.Icon:SetAllPoints()
	closeButton.Icon:SetTexCoord(unpack(K.TexCoords))
	closeButton.Icon:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\Textures\\CloseButton_32")

	closeButton:SetScript("OnClick", _G.CloseAllBags)
	closeButton.title = _G.CLOSE
	K.AddTooltip(closeButton, "ANCHOR_TOP")

	return closeButton
end

function Module:CreateRestoreButton(f)
	local restoreButton = CreateFrame("Button", nil, self)
	restoreButton:SetSize(18, 18)
	restoreButton:CreateBorder()
	restoreButton:StyleButton()

	restoreButton.Icon = restoreButton:CreateTexture(nil, "ARTWORK")
	restoreButton.Icon:SetAllPoints()
	restoreButton.Icon:SetTexCoord(unpack(K.TexCoords))
	restoreButton.Icon:SetAtlas("transmog-icon-revert")

	restoreButton:SetScript("OnClick", function()
		KkthnxUIDB.Variables[K.Realm][K.Name]["TempAnchor"][f.main:GetName()] = nil
		KkthnxUIDB.Variables[K.Realm][K.Name]["TempAnchor"][f.bank:GetName()] = nil
		KkthnxUIDB.Variables[K.Realm][K.Name]["TempAnchor"][f.reagent:GetName()] = nil
		f.main:ClearAllPoints()
		f.main:SetPoint("BOTTOMRIGHT", -86, 76)
		f.bank:ClearAllPoints()
		f.bank:SetPoint("BOTTOMRIGHT", f.main, "BOTTOMLEFT", -12, 0)
		f.reagent:ClearAllPoints()
		f.reagent:SetPoint("BOTTOMLEFT", f.bank)
		PlaySound(SOUNDKIT.IG_MINIMAP_OPEN)
	end)
	restoreButton.title = _G.RESET
	K.AddTooltip(restoreButton, "ANCHOR_TOP")

	return restoreButton
end

function Module:CreateReagentButton(f)
	local reagentButton = CreateFrame("Button", nil, self)
	reagentButton:SetSize(18, 18)
	reagentButton:CreateBorder()
	reagentButton:StyleButton()

	reagentButton.Icon = reagentButton:CreateTexture(nil, "ARTWORK")
	reagentButton.Icon:SetAllPoints()
	reagentButton.Icon:SetTexCoord(unpack(K.TexCoords))
	reagentButton.Icon:SetTexture("Interface\\ICONS\\INV_Enchant_DustArcane")

	reagentButton:RegisterForClicks("AnyUp")
	reagentButton:SetScript("OnClick", function(_, btn)
		if not IsReagentBankUnlocked() then
			_G.StaticPopup_Show("CONFIRM_BUY_REAGENTBANK_TAB")
		else
			PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
			_G.ReagentBankFrame:Show()
			_G.BankFrame.selectedTab = 2
			f.reagent:Show()
			f.bank:Hide()

			if btn == "RightButton" then
				_G.DepositReagentBank()
			end
		end
	end)
	reagentButton.title = _G.REAGENT_BANK
	K.AddTooltip(reagentButton, "ANCHOR_TOP")

	return reagentButton
end

function Module:CreateBankButton(f)
	local BankButton = CreateFrame("Button", nil, self)
	BankButton:SetSize(18, 18)
	BankButton:CreateBorder()
	BankButton:StyleButton()

	BankButton.Icon = BankButton:CreateTexture(nil, "ARTWORK")
	BankButton.Icon:SetAllPoints()
	BankButton.Icon:SetTexCoord(unpack(K.TexCoords))
	BankButton.Icon:SetAtlas("Banker")

	BankButton:SetScript("OnClick", function()
		PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
		_G.ReagentBankFrame:Hide()
		_G.BankFrame.selectedTab = 1
		f.reagent:Hide()
		f.bank:Show()
	end)

	BankButton.title = _G.BANK
	K.AddTooltip(BankButton, "ANCHOR_TOP")

	return BankButton
end

local function updateDepositButtonStatus(bu)
	if C["Inventory"].AutoDeposit then
		bu.KKUI_Border:SetVertexColor(1, 0.8, 0)
	else
		bu.KKUI_Border:SetVertexColor(1, 1, 1)
	end
end

function Module:AutoDeposit()
	if C["Inventory"].AutoDeposit then
		DepositReagentBank()
	end
end

function Module:CreateDepositButton()
	local DepositButton = CreateFrame("Button", nil, self)
	DepositButton:SetSize(18, 18)
	DepositButton:CreateBorder()
	DepositButton:StyleButton()

	DepositButton.Icon = DepositButton:CreateTexture(nil, "ARTWORK")
	DepositButton.Icon:SetAllPoints()
	DepositButton.Icon:SetTexCoord(unpack(K.TexCoords))
	DepositButton.Icon:SetTexture("Interface\\ICONS\\misc_arrowdown")

	DepositButton:SetScript("OnClick", function(_, btn)
		if btn == "RightButton" then
			C["Inventory"].AutoDeposit = not C["Inventory"].AutoDeposit
			updateDepositButtonStatus(DepositButton)
		else
			DepositReagentBank()
		end
	end)

	DepositButton.title = _G.REAGENTBANK_DEPOSIT
	K.AddTooltip(DepositButton, "ANCHOR_TOP", K.InfoColor..L["AutoDepositTip"])

	return DepositButton
end

function Module:CreateBagToggle()
	local bagToggleButton = CreateFrame("Button", nil, self)
	bagToggleButton:SetSize(18, 18)
	bagToggleButton:CreateBorder()
	bagToggleButton:StyleButton()

	bagToggleButton.Icon = bagToggleButton:CreateTexture(nil, "ARTWORK")
	bagToggleButton.Icon:SetAllPoints()
	bagToggleButton.Icon:SetTexCoord(unpack(K.TexCoords))
	bagToggleButton.Icon:SetTexture("Interface\\Buttons\\Button-Backpack-Up")

	bagToggleButton:SetScript("OnClick", function()
		K.TogglePanel(self.BagBar)
		if self.BagBar:IsShown() then
			bagToggleButton.KKUI_Border:SetVertexColor(1, .8, 0)
			PlaySound(SOUNDKIT.IG_BACKPACK_OPEN)
		elseif C["General"].ColorTextures then
			bagToggleButton.KKUI_Border:SetVertexColor(unpack(C["General"].TexturesColor))
			PlaySound(SOUNDKIT.IG_BACKPACK_CLOSE)
		else
			bagToggleButton.KKUI_Border:SetVertexColor(1, 1, 1)
			PlaySound(SOUNDKIT.IG_BACKPACK_CLOSE)
		end
	end)
	bagToggleButton.title = _G.BACKPACK_TOOLTIP
	K.AddTooltip(bagToggleButton, "ANCHOR_TOP")

	return bagToggleButton
end

function Module:CreateSortButton(name)
	local sortButton = CreateFrame("Button", nil, self)
	sortButton:SetSize(18, 18)
	sortButton:CreateBorder()
	sortButton:StyleButton()

	sortButton.Icon = sortButton:CreateTexture(nil, "ARTWORK")
	sortButton.Icon:SetAllPoints()
	sortButton.Icon:SetTexCoord(unpack(K.TexCoords))
	sortButton.Icon:SetTexture("Interface\\Icons\\INV_Pet_Broom")

	sortButton:SetScript("OnClick", function()
		if name == "Bank" then
			SortBankBags()
		elseif name == "Reagent" then
			_G.SortReagentBankBags()
		else
			if C["Inventory"].ReverseSort then
				if InCombatLockdown() then
					_G.UIErrorsFrame:AddMessage(K.InfoColor.._G.ERR_NOT_IN_COMBAT)
				else
					SortBags()
					table_wipe(sortCache)
					Module.Bags.isSorting = true
					C_Timer_After(.5, Module.ReverseSort)
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
		local slotID = Module:GetContainerEmptySlot(-1)
		if slotID then
			return -1, slotID
		end

		for bagID = 5, 11 do
			local slotID = Module:GetContainerEmptySlot(bagID)
			if slotID then
				return bagID, slotID
			end
		end
	elseif name == "Reagent" then
		local slotID = Module:GetContainerEmptySlot(-3)
		if slotID then
			return -3, slotID
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
	["Reagent"] = true,
}

function Module:CreateFreeSlots()
	local name = self.name
	if not freeSlotContainer[name] then
		return
	end

	local slot = CreateFrame("Button", name.."FreeSlot", self)
	slot:SetSize(self.iconSize, self.iconSize)
	slot:CreateBorder()
	slot:StyleButton()
	slot:SetScript("OnMouseUp", Module.FreeSlotOnDrop)
	slot:SetScript("OnReceiveDrag", Module.FreeSlotOnDrop)
	K.AddTooltip(slot, "ANCHOR_RIGHT", "FreeSlots")
	slot.__name = name

	local tag = self:SpawnPlugin("TagDisplay", "[space]", slot)
	tag:SetFontObject(bagsFont)
	tag:SetFont(select(1, tag:GetFont()), 16, select(3, tag:GetFont()))
	tag:SetPoint("CENTER", 1, 0)
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
	local enabledText = K.SystemColor..L["StackSplitEnable"]

	local splitFrame = CreateFrame("Frame", nil, self)
	splitFrame:SetSize(100, 50)
	splitFrame:SetPoint("TOPRIGHT", self, "TOPLEFT", -6, 0)
	K.CreateFontString(splitFrame, 14, L["Split Count"], "", "system", "TOP", 1, -5)
	splitFrame:CreateBorder()
	splitFrame:Hide()

	local editBox = CreateFrame("EditBox", nil, splitFrame)
	editBox:CreateBorder()
	editBox:SetWidth(90)
	editBox:SetHeight(20)
	editBox:SetAutoFocus(false)
	editBox:SetTextInsets(5, 5, 0, 0)
	editBox:SetFontObject(bagsFont)
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
	splitButton.Icon:SetTexCoord(unpack(K.TexCoords))
	splitButton.Icon:SetTexture("Interface\\HELPFRAME\\ReportLagIcon-AuctionHouse")

	splitButton.__turnOff = function()
		if C["General"].ColorTextures then
			splitButton.KKUI_Border:SetVertexColor(unpack(C["General"].TexturesColor))
		else
			splitButton.KKUI_Border:SetVertexColor(1, 1, 1)
		end
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

	PickupContainerItem(self.bagID, self.slotID)

	local texture, itemCount, locked = GetContainerItemInfo(self.bagID, self.slotID)
	if texture and not locked and itemCount and itemCount > KkthnxUIDB.Variables[K.Realm][K.Name].SplitCount then
		SplitContainerItem(self.bagID, self.slotID, KkthnxUIDB.Variables[K.Realm][K.Name].SplitCount)

		local bagID, slotID = Module:GetEmptySlot("Bag")
		if slotID then
			PickupContainerItem(bagID, slotID)
		end
	end
end

function Module:CreateFavouriteButton()
	local enabledText = K.SystemColor..L["Favourite Mode Enabled"]

	local favouriteButton = CreateFrame("Button", nil, self)
	favouriteButton:SetSize(18, 18)
	favouriteButton:CreateBorder()
	favouriteButton:StyleButton()

	favouriteButton.Icon = favouriteButton:CreateTexture(nil, "ARTWORK")
	favouriteButton.Icon:SetPoint("TOPLEFT", -3, -1)
	favouriteButton.Icon:SetPoint("BOTTOMRIGHT", 3, -4)
	favouriteButton.Icon:SetTexCoord(unpack(K.TexCoords))
	favouriteButton.Icon:SetTexture("Interface\\Common\\friendship-heart")

	favouriteButton.__turnOff = function()
		if C["General"].ColorTextures then
			favouriteButton.KKUI_Border:SetVertexColor(unpack(C["General"].TexturesColor))
		else
			favouriteButton.KKUI_Border:SetVertexColor(1, 1, 1)
		end
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
	favouriteButton.title = L["Favourite Mode"]
	K.AddTooltip(favouriteButton, "ANCHOR_TOP")

	toggleButtons[2] = favouriteButton

	return favouriteButton
end

local function favouriteOnClick(self)
	if not favouriteEnable then
		return
	end

	local texture, _, _, quality, _, _, _, _, _, itemID = GetContainerItemInfo(self.bagID, self.slotID)
	if texture and quality > LE_ITEM_QUALITY_POOR then
		if KkthnxUIDB.Variables[K.Realm][K.Name].FavouriteItems[itemID] then
			KkthnxUIDB.Variables[K.Realm][K.Name].FavouriteItems[itemID] = nil
		else
			KkthnxUIDB.Variables[K.Realm][K.Name].FavouriteItems[itemID] = true
		end
		ClearCursor()
		Module:UpdateAllBags()
	end
end

function Module:CreateJunkButton()
	local enabledText = K.InfoColor.."|nClick an item to tag it as junk.|n|nIf 'Module Autosell' is enabled, these items will be sold as well.|n|nThe list is saved account-wide."

	local JunkButton = CreateFrame("Button", nil, self)
	JunkButton:SetSize(18, 18)
	JunkButton:CreateBorder()
	JunkButton:StyleButton()

	JunkButton.Icon = JunkButton:CreateTexture(nil, "ARTWORK")
	JunkButton.Icon:SetPoint("TOPLEFT", 1, -2)
	JunkButton.Icon:SetPoint("BOTTOMRIGHT", -1, -2)
	JunkButton.Icon:SetTexCoord(unpack(K.TexCoords))
	JunkButton.Icon:SetTexture("Interface\\BUTTONS\\UI-GroupLoot-Coin-Up")

	JunkButton.__turnOff = function()
		if C["General"].ColorTextures then
			JunkButton.KKUI_Border:SetVertexColor(unpack(C["General"].TexturesColor))
		else
			JunkButton.KKUI_Border:SetVertexColor(1, 1, 1)
		end
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

	local texture, _, _, _, _, _, _, _, _, itemID = GetContainerItemInfo(self.bagID, self.slotID)
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
	local enabledText = K.SystemColor..L["Delete Mode Enabled"]

	local deleteButton = CreateFrame("Button", nil, self)
	deleteButton:SetSize(18, 18)
	deleteButton:CreateBorder()
	deleteButton:StyleButton()

	deleteButton.Icon = deleteButton:CreateTexture(nil, "ARTWORK")
	deleteButton.Icon:SetPoint("TOPLEFT", 3, -2)
	deleteButton.Icon:SetPoint("BOTTOMRIGHT", -1, 2)
	deleteButton.Icon:SetTexCoord(unpack(K.TexCoords))
	deleteButton.Icon:SetTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Up")

	deleteButton.__turnOff = function()
		if C["General"].ColorTextures then
			deleteButton.KKUI_Border:SetVertexColor(unpack(C["General"].TexturesColor))
		else
			deleteButton.KKUI_Border:SetVertexColor(1, 1, 1)
		end
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

	local texture, _, _, quality = GetContainerItemInfo(self.bagID, self.slotID)
	if IsControlKeyDown() and IsAltKeyDown() and texture and (quality < LE_ITEM_QUALITY_RARE) then
		PickupContainerItem(self.bagID, self.slotID)
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
	CloseAllBags()
end

function Module:OnEnable()
	self:CreateInventoryBar()
	self:CreateAutoRepair()
	self:CreateAutoSell()

	if not C["Inventory"].Enable then
		return
	end

	if IsAddOnLoaded("AdiBags") or IsAddOnLoaded("ArkInventory") or IsAddOnLoaded("cargBags_Nivaya") or IsAddOnLoaded("cargBags") or IsAddOnLoaded("Bagnon") or IsAddOnLoaded("Combuctor") or IsAddOnLoaded("TBag") or IsAddOnLoaded("BaudBag") then
		return
	end

	-- Settings
	local bagsWidth = C["Inventory"].BagsWidth
	local bankWidth = C["Inventory"].BankWidth
	local iconSize = C["Inventory"].IconSize
	local showItemLevel = C["Inventory"].BagsItemLevel
	local deleteButton = C["Inventory"].DeleteButton
	local showNewItem = C["Inventory"].ShowNewItem
	local hasCanIMogIt = IsAddOnLoaded("CanIMogIt")
	local hasPawn = IsAddOnLoaded("Pawn")

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
	Module.BagsType[0] = 0	-- Backpack
	Module.BagsType[-1] = 0	-- Bank
	Module.BagsType[-3] = 0	-- Reagent

	local f = {}
	local filters = Module:GetFilters()
	local MyContainer = Backpack:GetContainerClass()
	local ContainerGroups = {["Bag"] = {}, ["Bank"] = {}}

	local function AddNewContainer(bagType, index, name, filter)
		local width = bagsWidth
		if bagType == "Bank" then
			width = bankWidth
		end

		local newContainer = MyContainer:New(name, {Columns = width, BagType = bagType})
		newContainer:SetFilter(filter, true)
		ContainerGroups[bagType][index] = newContainer
	end

	function Backpack:OnInit()
		AddNewContainer("Bag", 11, "Junk", filters.bagsJunk)
		AddNewContainer("Bag", 10, "BagFavourite", filters.bagFavourite)
		AddNewContainer("Bag", 3, "EquipSet", filters.bagEquipSet)
		AddNewContainer("Bag", 1, "AzeriteItem", filters.bagAzeriteItem)
		AddNewContainer("Bag", 2, "Equipment", filters.bagEquipment)
		AddNewContainer("Bag", 4, "BagCollection", filters.bagCollection)
		AddNewContainer("Bag", 6, "Consumable", filters.bagConsumable)
		AddNewContainer("Bag", 5, "BagGoods", filters.bagGoods)
		AddNewContainer("Bag", 8, "BagQuest", filters.bagQuest)
		AddNewContainer("Bag", 7, "BagLegendary", filters.bagLegendary)
		AddNewContainer("Bag", 9, "BagAnima", filters.bagAnima)

		f.main = MyContainer:New("Bag", {Columns = bagsWidth, Bags = "bags"})
		f.main:SetPoint("BOTTOMRIGHT", -86, 76)
		f.main:SetFilter(filters.onlyBags, true)

		AddNewContainer("Bank", 9, "BankFavourite", filters.bankFavourite)
		AddNewContainer("Bank", 3, "BankEquipSet", filters.bankEquipSet)
		AddNewContainer("Bank", 1, "BankAzeriteItem", filters.bankAzeriteItem)
		AddNewContainer("Bank", 4, "BankLegendary", filters.bankLegendary)
		AddNewContainer("Bank", 2, "BankEquipment", filters.bankEquipment)
		AddNewContainer("Bank", 5, "BankCollection", filters.bankCollection)
		AddNewContainer("Bank", 7, "BankConsumable", filters.bankConsumable)
		AddNewContainer("Bank", 6, "BankGoods", filters.bankGoods)
		AddNewContainer("Bank", 8, "BankQuest", filters.bankQuest)

		f.bank = MyContainer:New("Bank", {Columns = bankWidth, Bags = "bank"})
		f.bank:SetPoint("BOTTOMRIGHT", f.main, "BOTTOMLEFT", -12, 0)
		f.bank:SetFilter(filters.onlyBank, true)
		f.bank:Hide()

		f.reagent = MyContainer:New("Reagent", {Columns = bankWidth, Bags = "bankreagent"})
		f.reagent:SetFilter(filters.onlyReagent, true)
		f.reagent:SetPoint("BOTTOMLEFT", f.bank)
		f.reagent:Hide()

		for bagType, groups in pairs(ContainerGroups) do
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
		self:GetContainer("Bank"):Show()

		if not initBagType then
			Module:UpdateAllBags() -- Initialize bagType
			initBagType = true
		end
	end

	function Backpack:OnBankClosed()
		BankFrame.selectedTab = 1
		BankFrame:Hide()
		self:GetContainer("Bank"):Hide()
		self:GetContainer("Reagent"):Hide()
		ReagentBankFrame:Hide()
	end

	local MyButton = Backpack:GetItemButtonClass()
	MyButton:Scaffold("Default")

	function MyButton:OnCreate()
		self:SetNormalTexture(nil)
		self:SetPushedTexture(nil)
		self:SetSize(iconSize, iconSize)

		self.Icon:SetAllPoints()
		self.Icon:SetTexCoord(unpack(K.TexCoords))

		self.Count:SetPoint("BOTTOMRIGHT", 1, 1)
		self.Count:SetFontObject(bagsFont)

		self.Cooldown:SetPoint("TOPLEFT", 1, -1)
		self.Cooldown:SetPoint("BOTTOMRIGHT", -1, 1)

		self.IconOverlay:SetPoint("TOPLEFT", 1, -1)
		self.IconOverlay:SetPoint("BOTTOMRIGHT", -1, 1)

		self:CreateBorder()
		self:StyleButton()

		local parentFrame = CreateFrame("Frame", nil, self)
		parentFrame:SetAllPoints()
		parentFrame:SetFrameLevel(5)

		self.Favourite = parentFrame:CreateTexture(nil, "OVERLAY")
		self.Favourite:SetAtlas("collections-icon-favorites")
		self.Favourite:SetSize(24, 24)
		self.Favourite:SetPoint("TOPRIGHT", 3, 2)

		self.Quest = parentFrame:CreateTexture(nil, "OVERLAY")
		self.Quest:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\Inventory\\QuestIcon.tga")
		self.Quest:SetSize(26, 26)
		self.Quest:SetPoint("LEFT", 0, 1)

		self.iLvl = K.CreateFontString(self, 12, "", "OUTLINE", false, "BOTTOMLEFT", 1, 1)
		self.iLvl:SetFontObject(bagsFont)
		self.iLvl:SetFont(select(1, self.iLvl:GetFont()), 12, select(3, self.iLvl:GetFont()))

		if showNewItem then
			self.glowFrame = self.glowFrame or CreateFrame("Frame", nil, self, "BackdropTemplate")
			self.glowFrame:SetBackdrop({edgeFile = C["Media"].Borders.GlowBorder, edgeSize = 12})
			self.glowFrame:SetPoint("TOPLEFT", self, -5, 5)
			self.glowFrame:SetPoint("BOTTOMRIGHT", self, 5, -5)
			self.glowFrame:Hide()

			self.glowFrame.Animation = self.glowFrame.Animation or self.glowFrame:CreateAnimationGroup()
			self.glowFrame.Animation:SetLooping("BOUNCE")
			self.glowFrame.Animation.Fader = self.glowFrame.Animation:CreateAnimation("Alpha")
			self.glowFrame.Animation.Fader:SetFromAlpha(0.8)
			self.glowFrame.Animation.Fader:SetToAlpha(0.2)
			self.glowFrame.Animation.Fader:SetDuration(1)
			self.glowFrame.Animation.Fader:SetSmoothing("OUT")
		end

		self:HookScript("OnClick", Module.ButtonOnClick)

		if hasCanIMogIt then
			self.canIMogIt = parentFrame:CreateTexture(nil, "OVERLAY")
			self.canIMogIt:SetSize(C["Inventory"].IconSize / 2.6, C["Inventory"].IconSize / 2.6)
			self.canIMogIt:SetPoint(unpack(CanIMogIt.ICON_LOCATIONS[CanIMogItOptions["iconLocation"]]))
		end
	end

	function MyButton:ItemOnEnter()
		if self.glowFrame.Animation and self.glowFrame.Animation:IsPlaying() then
			self.glowFrame.Animation:Stop()
			self.glowFrame:Hide()
			C_NewItems_RemoveNewItem(self.bagID, self.slotID)
		end
	end

	local bagTypeColor = {
		[0] = {0, 0, 0, .25}, -- container
		[1] = false, -- Ammunition bag
		[2] = {0, .5, 0, .25}, -- Herbal bag
		[3] = {.8, 0, .8, .25}, -- Enchant bag
		[4] = {1, .8, 0, .25}, -- Engineering bag
		[5] = {0, .8, .8, .25}, -- Gem bag
		[6] = {.5, .4, 0, .25}, -- Ore bag
		[7] = {.8, .5, .5, .25}, -- Leather bag
		[8] = {.8, .8, .8, .25}, -- Inscription bag
		[9] = {.4, .6, 1, .25}, -- Toolbox
		[10] = {.8, 0, 0, .25}, -- Cooking bag
	}

	local function isItemNeedsLevel(item)
		return item.link and item.quality > 1 and Module:IsItemHasLevel(item)
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

		local text, unmodifiedText = CanIMogIt:GetTooltipText(nil, item.bagID, item.slotID)
		if text and text ~= "" then
			local icon = CanIMogIt.tooltipOverlayIcons[unmodifiedText]
			self.canIMogIt:SetTexture(icon)
			self.canIMogIt:Show()
		else
			self.canIMogIt:Hide()
		end
	end

	local function UpdatePawnArrow(self, item)
		if not hasPawn then
			return
		end

		if not PawnIsContainerItemAnUpgrade then
			return
		end

		if self.UpgradeIcon then
			self.UpgradeIcon:SetShown(PawnIsContainerItemAnUpgrade(item.bagID, item.slotID))
		end
	end

	function MyButton:OnUpdate(item)
		local buttonIconTexture = _G[self:GetName().."IconTexture"]

		if self.JunkIcon then
			if (item.quality == LE_ITEM_QUALITY_POOR or KkthnxUIDB.Variables[K.Realm][K.Name].CustomJunkList[item.id]) and item.hasPrice then
				self.JunkIcon:Show()
			else
				self.JunkIcon:Hide()
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

		if KkthnxUIDB.Variables[K.Realm][K.Name].FavouriteItems[item.id] then
			self.Favourite:Show()
		else
			self.Favourite:Hide()
		end

		self.iLvl:SetText("")
		if showItemLevel then
			local level = item.level -- ilvl for keystone and battlepet
			if not level and isItemNeedsLevel(item) then
				local ilvl = K.GetItemLevel(item.link, item.bagID, item.slotID)
				if ilvl and ilvl > 1 then
					level = ilvl
				end
			end

			if level then
				local color = K.QualityColors[item.quality]
				self.iLvl:SetText(level)
				self.iLvl:SetTextColor(color.r, color.g, color.b)
			end
		end

		-- Determine if we can use that item or not?
		if (Unfit:IsItemUnusable(item.id) or item.minLevel and item.minLevel > K.Level) and not item.locked then
			buttonIconTexture:SetVertexColor(1, 0.1, 0.1)
		else
			buttonIconTexture:SetVertexColor(1, 1, 1)
		end

		if self.glowFrame then
			if C_NewItems_IsNewItem(item.bagID, item.slotID) then
				local color = K.QualityColors[item.quality]
				if item.questID or item.isQuestItem then
					self.glowFrame:SetBackdropBorderColor(1, .82, .2)
				elseif color and item.quality and item.quality > -1 then
					self.glowFrame:SetBackdropBorderColor(color.r, color.g, color.b)
				else
					self.glowFrame:SetBackdropBorderColor(1, 1, 1)
				end

				if not self.glowFrame.Animation:IsPlaying() then
					self.glowFrame.Animation:Play()
					self.glowFrame:Show()
				end
			else
				if self.glowFrame.Animation and self.glowFrame.Animation:IsPlaying() then
					self.glowFrame.Animation:Stop()
					self.glowFrame:Hide()
				end
			end
		end

		if C["Inventory"].SpecialBagsColor then
			local bagType = Module.BagsType[item.bagID]
			local color = bagTypeColor[bagType] or bagTypeColor[0]
			self:SetBackdropColor(unpack(color))
		else
			self:SetBackdropColor(.04, .04, .04, 0.9)
		end

		-- Hide empty tooltip
		if GameTooltip:GetOwner() == self and not GetContainerItemInfo(item.bagID, item.slotID) then
			GameTooltip:Hide()
		end

		-- Support CanIMogIt
		UpdateCanIMogIt(self, item)

		-- Support Pawn
		UpdatePawnArrow(self, item)
	end

	function MyButton:OnUpdateQuest(item)
		if item.questID and not item.questActive then
			self.Quest:Show()
		else
			self.Quest:Hide()
		end

		if item.questID or item.isQuestItem then
			self.KKUI_Border:SetVertexColor(1, .82, .2)
		elseif item.quality and item.quality > -1 then
			local color = K.QualityColors[item.quality]
			self.KKUI_Border:SetVertexColor(color.r, color.g, color.b)
		else
			if C["General"].ColorTextures then
				self.KKUI_Border:SetVertexColor(unpack(C["General"].TexturesColor))
			else
				self.KKUI_Border:SetVertexColor(1, 1, 1)
			end
		end
	end

	function MyContainer:OnContentsChanged()
		self:SortButtons("bagSlot")

		local columns = self.Settings.Columns
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

				local xPos = (col-1) * (iconSize + spacing)
				local yPos = -1 * (row-1) * (iconSize + spacing)

				self.freeSlot:ClearAllPoints()
				self.freeSlot:SetPoint("TOPLEFT", self, "TOPLEFT", xPos+xOffset, yPos + yOffset)
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

		Module:UpdateAnchors(f.main, ContainerGroups["Bag"])
		Module:UpdateAnchors(f.bank, ContainerGroups["Bank"])
	end

	function MyContainer:OnCreate(name, settings)
		self.Settings = settings
		self:SetFrameStrata("HIGH")
		self:SetClampedToScreen(true)
		self:CreateBorder()

		if settings.Bags then
			K.CreateMoverFrame(self, nil, true)
		end

		local label
		if string_match(name, "AzeriteItem$") then
			label = "Azerite Armor"
		elseif string_match(name, "Equipment$") then
			label = BAG_FILTER_EQUIPMENT
		elseif string_match(name, "EquipSet$") then
			label = L["Equipement Set"]
		elseif string_match(name, "Legendary$") then
			label = LOOT_JOURNAL_LEGENDARIES
		elseif string_match(name, "Consumable$") then
			label = BAG_FILTER_CONSUMABLES
		elseif name == "Junk" then
			label = BAG_FILTER_JUNK
		elseif string_match(name, "Collection") then
			label = COLLECTIONS
		elseif string_match(name, "Favourite") then
			label = PREFERENCES
		elseif string_match(name, "Goods") then
			label = AUCTION_CATEGORY_TRADE_GOODS
		elseif string_match(name, "Quest") then
			label = QUESTS_LABEL
		elseif string_match(name, "Anima") then
			label = POWER_TYPE_ANIMA
		end

		if label then
			self.label = K.CreateFontString(self, 13, label, "OUTLINE", true, "TOPLEFT", 5, -8)
			return
		end

		Module.CreateInfoFrame(self)

		local buttons = {}
		buttons[1] = Module.CreateCloseButton(self)
		if name == "Bag" then
			Module.CreateBagBar(self, settings, 4)
			buttons[2] = Module.CreateRestoreButton(self, f)
			buttons[3] = Module.CreateBagToggle(self)
			buttons[5] = Module.CreateSplitButton(self)
			buttons[6] = Module.CreateFavouriteButton(self)
			buttons[7] = Module.CreateJunkButton(self)
			if deleteButton then
				buttons[8] = Module.CreateDeleteButton(self)
			end
		elseif name == "Bank" then
			Module.CreateBagBar(self, settings, 7)
			buttons[2] = Module.CreateReagentButton(self, f)
			buttons[3] = Module.CreateBagToggle(self)
		elseif name == "Reagent" then
			buttons[2] = Module.CreateBankButton(self, f)
			buttons[3] = Module.CreateDepositButton(self)
		end
		buttons[4] = Module.CreateSortButton(self, name)

		for i = 1, #buttons do
			local bu = buttons[i]
			if not bu then
				break
			end

			if i == 1 then
				bu:SetPoint("TOPRIGHT", -6, -6)
			else
				bu:SetPoint("RIGHT", buttons[i - 1], "LEFT", -5, 0)
			end
		end

		self:HookScript("OnShow", K.RestoreMoverFrame)

		self.iconSize = iconSize
		Module.CreateFreeSlots(self)
	end

	local BagButton = Backpack:GetClass("BagButton", true, "BagButton")
	function BagButton:OnCreate()
		self:SetNormalTexture(nil)
		self:SetPushedTexture(nil)

		self:SetSize(iconSize, iconSize)
		self:CreateBorder()
		self:StyleButton()

		self.Icon:SetAllPoints()
		self.Icon:SetTexCoord(unpack(K.TexCoords))
	end

	function BagButton:OnUpdate()
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
			if C["General"].ColorTextures then
				self.KKUI_Border:SetVertexColor(unpack(C["General"].TexturesColor))
			else
				self.KKUI_Border:SetVertexColor(1, 1, 1)
			end
		end

		if classID == LE_ITEM_CLASS_CONTAINER then
			Module.BagsType[self.bagID] = subClassID or 0
		else
			Module.BagsType[self.bagID] = 0
		end
	end

	-- Sort order
	SetSortBagsRightToLeft(not C["Inventory"].ReverseSort)
	SetInsertItemsLeftToRight(false)

	-- Init
	ToggleAllBags()
	ToggleAllBags()
	Module.initComplete = true

	K:RegisterEvent("TRADE_SHOW", Module.OpenBags)
	K:RegisterEvent("TRADE_CLOSED", Module.CloseBags)
	K:RegisterEvent("BANKFRAME_OPENED", Module.AutoDeposit)

	-- Fixes
	BankFrame.GetRight = function()
		return f.bank:GetRight()
	end
	BankFrameItemButton_Update = K.Noop
end