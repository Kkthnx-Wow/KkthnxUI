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

local C_NewItems_IsNewItem = _G.C_NewItems.IsNewItem
local C_NewItems_RemoveNewItem = _G.C_NewItems.RemoveNewItem
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
local IsContainerItemAnUpgrade = _G.IsContainerItemAnUpgrade
local IsControlKeyDown = _G.IsControlKeyDown
local IsReagentBankUnlocked = _G.IsReagentBankUnlocked
local LE_ITEM_CLASS_ARMOR = _G.LE_ITEM_CLASS_ARMOR
local LE_ITEM_CLASS_WEAPON = _G.LE_ITEM_CLASS_WEAPON
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

function Module:UpdateItemUpgradeIcon(self)
	if not C["Inventory"].UpgradeIcon then
		self.UpgradeIcon:SetShown(false)
		self:SetScript("OnUpdate", nil)
		return
	end

	local itemIsUpgrade, containerID, slotID = nil, self:GetParent():GetID(), self:GetID()

	-- We need to use the Pawn function here to show actually the icon, as Blizzard API doesnt seem to work.
	if _G.PawnIsContainerItemAnUpgrade then
		itemIsUpgrade = _G.PawnIsContainerItemAnUpgrade(containerID, slotID)
	end

	-- Pawn author suggests to fallback to Blizzard API anyways.
	if itemIsUpgrade == nil then
		itemIsUpgrade = _G.IsContainerItemAnUpgrade(containerID, slotID)
	end

	if itemIsUpgrade == nil then -- nil means not all the data was available to determine if this is an upgrade.
		self.UpgradeIcon:SetShown(false)
		self:SetScript("OnUpdate", Module.UpgradeCheck_OnUpdate)
	else
		self.UpgradeIcon:SetShown(itemIsUpgrade)
		self:SetScript("OnUpdate", nil)
	end
end

local ITEM_UPGRADE_CHECK_TIME = 0.5
function Module:UpgradeCheck_OnUpdate(elapsed)
	self.timeSinceUpgradeCheck = (self.timeSinceUpgradeCheck or 0) + elapsed
	if self.timeSinceUpgradeCheck >= ITEM_UPGRADE_CHECK_TIME then
		Module:UpdateItemUpgradeIcon(self)
		self.timeSinceUpgradeCheck = 0
	end
end

local profit, spent, oldMoney, ticker = 0, 0, 0
local crossRealms = GetAutoCompleteRealms()

if not crossRealms or #crossRealms == 0 then
	crossRealms = {[1] = K.Realm}
end

StaticPopupDialogs["RESETGOLD"] = {
	text = "Are you sure to reset the gold count?",
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		for _, realm in pairs(crossRealms) do
			if KkthnxUIGold.totalGold[realm] then
				table_wipe(KkthnxUIGold.totalGold[realm])
			end
		end
		KkthnxUIGold.totalGold[K.Realm][K.Name] = {GetMoney(), K.Class}
	end,
	whileDead = 1,
}

local function getClassIcon(class)
	local c1, c2, c3, c4 = unpack(CLASS_ICON_TCOORDS[class])
	c1, c2, c3, c4 = (c1 + 0.03) * 50, (c2 - 0.03) * 50, (c3 + 0.03) * 50, (c4 - 0.03) * 50
	local classStr = "|TInterface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes:12:12:0:0:50:50:"..c1..":"..c2..":"..c3..":"..c4.."|t "
	return classStr or ""
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

	local moneyFrame = CreateFrame('Button', nil, infoFrame)
	moneyFrame:SetPoint("LEFT", icon, "RIGHT", 6, 0)
	moneyFrame:SetSize(140, 16)

	moneyFrame:RegisterEvent("PLAYER_MONEY")
	moneyFrame:RegisterEvent("SEND_MAIL_MONEY_CHANGED")
	moneyFrame:RegisterEvent("SEND_MAIL_COD_CHANGED")
	moneyFrame:RegisterEvent("PLAYER_TRADE_MONEY")
	moneyFrame:RegisterEvent("TRADE_MONEY_CHANGED")
	moneyFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	moneyFrame:SetScript('OnEvent', function(self, event)
		if not IsLoggedIn() then
			return
		end

		if event == "PLAYER_ENTERING_WORLD" then
			oldMoney = GetMoney()
			self:UnregisterEvent(event)
		end

		if not ticker then
			C_WowTokenPublic.UpdateMarketPrice()
			ticker = C_Timer.NewTicker(60, C_WowTokenPublic.UpdateMarketPrice)
		end

		local newMoney = GetMoney()
		local change = newMoney - oldMoney -- Positive if we gain money
		if oldMoney > newMoney then -- Lost Money
			spent = spent - change
		else -- Gained Moeny
			profit = profit + change
		end

		KkthnxUIGold = KkthnxUIGold or {}
		KkthnxUIGold.totalGold = KkthnxUIGold.totalGold or {}

		if not KkthnxUIGold.totalGold[K.Realm] then
			KkthnxUIGold.totalGold[K.Realm] = {}
		end

		if not KkthnxUIGold.totalGold[K.Realm][K.Name] then
			KkthnxUIGold.totalGold[K.Realm][K.Name] = {}
		end

		KkthnxUIGold.totalGold[K.Realm][K.Name][1] = GetMoney()
		KkthnxUIGold.totalGold[K.Realm][K.Name][2] = K.Class

		oldMoney = newMoney
	end)

	moneyFrame:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_NONE")
		GameTooltip:SetPoint(K.GetAnchors(self))
		GameTooltip:ClearLines()

		GameTooltip:AddLine(K.InfoColor..CURRENCY)
		GameTooltip:AddLine(" ")

		GameTooltip:AddLine(L["Session"], 0.6, 0.8, 1)
		GameTooltip:AddDoubleLine(L["Earned"], K.FormatMoney(profit), 1, 1, 1, 1, 1, 1)
		GameTooltip:AddDoubleLine(L["Spent"], K.FormatMoney(spent), 1, 1, 1, 1, 1, 1)
		if profit < spent then
			GameTooltip:AddDoubleLine(L["Deficit"], K.FormatMoney(spent-profit), 1, 0, 0, 1, 1, 1)
		elseif profit > spent then
			GameTooltip:AddDoubleLine(L["Profit"], K.FormatMoney(profit-spent), 0, 1, 0, 1, 1, 1)
		end
		GameTooltip:AddLine(" ")

		local totalGold = 0
		GameTooltip:AddLine(L["RealmCharacter"], 0.6, 0.8, 1)
		for _, realm in pairs(crossRealms) do
			local thisRealmList = KkthnxUIGold.totalGold[realm]
			if thisRealmList then
				for k, v in pairs(thisRealmList) do
					local name = Ambiguate(k.."-"..realm, "none")
					local gold, class = unpack(v)
					local r, g, b = K.ColorClass(class)
					GameTooltip:AddDoubleLine(getClassIcon(class)..name, K.FormatMoney(gold), r, g, b, 1, 1, 1)
					totalGold = totalGold + gold
				end
			end
		end
		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine(TOTAL..":", K.FormatMoney(totalGold), 0.63, 0.82, 1, 1, 1, 1)
		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine("|TInterface\\ICONS\\WoW_Token01:12:12:0:0:50:50:4:46:4:46|t ".."Token:", K.FormatMoney(C_WowTokenPublic.GetCurrentMarketPrice() or 0), .6,.8,1, 1, 1, 1)

		for i = 1, GetNumWatchedTokens() do
			local currencyInfo = C_CurrencyInfo.GetBackpackCurrencyInfo(i)
			local name, count, icon, currencyID = currencyInfo.name, currencyInfo.quantity, currencyInfo.iconFileID, currencyInfo.currencyTypesID
			if name and i == 1 then
				GameTooltip:AddLine(" ")
				GameTooltip:AddLine(CURRENCY..":", 0.6, 0.8, 1)
			end

			if name and count then
				local total = C_CurrencyInfo.GetCurrencyInfo(currencyID).maxQuantity
				local iconTexture = " |T"..icon..":12:12:0:0:50:50:4:46:4:46|t"
				if total > 0 then
					GameTooltip:AddDoubleLine(name, count.."/"..total..iconTexture, 1, 1, 1, 1, 1, 1)
				else
					GameTooltip:AddDoubleLine(name, count..iconTexture, 1, 1, 1, 1, 1, 1)
				end
			end
		end

		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine(" ", L["Ctrl Key"]..K.RightButton.."Reset Gold".." ", 1, 1, 1, 0.6, 0.8, 1)
		GameTooltip:Show()
	end)

	moneyFrame:HookScript("OnLeave", function()
		K.HideTooltip()
	end)

	moneyFrame:HookScript("OnMouseUp", function(_, button)
		if IsControlKeyDown() and button == "RightButton" then
			StaticPopup_Show("RESETGOLD")
		else
			if InCombatLockdown() then
				UIErrorsFrame:AddMessage(K.InfoColor..ERR_NOT_IN_COMBAT)
				return
			end
		end
	end)

	local moneyTag = self:SpawnPlugin("TagDisplay", "[money]", infoFrame)
	moneyTag:SetFontObject(bagsFont)
	moneyTag:SetFont(select(1, moneyTag:GetFont()), 13, select(3, moneyTag:GetFont()))
	moneyTag:SetPoint("LEFT", moneyFrame, "LEFT", 1, 1)

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
	closeButton:CreateBorder(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, true)
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
	restoreButton:CreateBorder(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, true)
	restoreButton:StyleButton()

	restoreButton.Icon = restoreButton:CreateTexture(nil, "ARTWORK")
	restoreButton.Icon:SetAllPoints()
	restoreButton.Icon:SetTexCoord(unpack(K.TexCoords))
	restoreButton.Icon:SetAtlas("transmog-icon-revert")

	restoreButton:SetScript("OnClick", function()
		KkthnxUIData[K.Realm][K.Name]["TempAnchor"][f.main:GetName()] = nil
		KkthnxUIData[K.Realm][K.Name]["TempAnchor"][f.bank:GetName()] = nil
		KkthnxUIData[K.Realm][K.Name]["TempAnchor"][f.reagent:GetName()] = nil
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
	reagentButton:CreateBorder(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, true)
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
	BankButton:CreateBorder(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, true)
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

function Module:CreateDepositButton()
	local DepositButton = CreateFrame("Button", nil, self)
	DepositButton:SetSize(18, 18)
	DepositButton:CreateBorder(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, true)
	DepositButton:StyleButton()

	DepositButton.Icon = DepositButton:CreateTexture(nil, "ARTWORK")
	DepositButton.Icon:SetAllPoints()
	DepositButton.Icon:SetTexCoord(unpack(K.TexCoords))
	DepositButton.Icon:SetTexture("Interface\\ICONS\\misc_arrowdown")

	DepositButton:SetScript("OnClick", _G.DepositReagentBank)

	DepositButton.title = _G.REAGENTBANK_DEPOSIT
	K.AddTooltip(DepositButton, "ANCHOR_TOP")

	return DepositButton
end

function Module:CreateBagToggle()
	local bagToggleButton = CreateFrame("Button", nil, self)
	bagToggleButton:SetSize(18, 18)
	bagToggleButton:CreateBorder(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, true)
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
	sortButton:CreateBorder(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, true)
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
	if name == "Main" then
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
	["Main"] = true,
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
	slot:CreateBorder(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, true)
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
	KkthnxUIData[K.Realm][K.Name].SplitCount = tonumber(count) or 1
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
	splitButton:CreateBorder(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, true)
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
			editBox:SetText(KkthnxUIData[K.Realm][K.Name].SplitCount)
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
	if texture and not locked and itemCount and itemCount > KkthnxUIData[K.Realm][K.Name].SplitCount then
		SplitContainerItem(self.bagID, self.slotID, KkthnxUIData[K.Realm][K.Name].SplitCount)

		local bagID, slotID = Module:GetEmptySlot("Main")
		if slotID then
			PickupContainerItem(bagID, slotID)
		end
	end
end

function Module:CreateFavouriteButton()
	local enabledText = K.SystemColor..L["Favourite Mode Enabled"]

	local favouriteButton = CreateFrame("Button", nil, self)
	favouriteButton:SetSize(18, 18)
	favouriteButton:CreateBorder(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, true)
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
		if KkthnxUIData[K.Realm][K.Name].FavouriteItems[itemID] then
			KkthnxUIData[K.Realm][K.Name].FavouriteItems[itemID] = nil
		else
			KkthnxUIData[K.Realm][K.Name].FavouriteItems[itemID] = true
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
		if KkthnxUIData[K.Realm][K.Name].CustomJunkList[itemID] then
			KkthnxUIData[K.Realm][K.Name].CustomJunkList[itemID] = nil
		else
			KkthnxUIData[K.Realm][K.Name].CustomJunkList[itemID] = true
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
	local itemSetFilter = C["Inventory"].ItemSetFilter
	local showNewItem = C["Inventory"].ShowNewItem

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
	local filters = self:GetFilters()

	function Backpack:OnInit()
		local MyContainer = self:GetContainerClass()

		f.main = MyContainer:New("Main", {Columns = bagsWidth, Bags = "bags"})
		f.main:SetFilter(filters.onlyBags, true)
		f.main:SetPoint("BOTTOMRIGHT", -86, 76)

		f.junk = MyContainer:New("Junk", {Columns = bagsWidth, Parent = f.main})
		f.junk:SetFilter(filters.bagsJunk, true)

		f.bagFavourite = MyContainer:New("BagFavourite", {Columns = bagsWidth, Parent = f.main})
		f.bagFavourite:SetFilter(filters.bagFavourite, true)

		f.azeriteItem = MyContainer:New("AzeriteItem", {Columns = bagsWidth, Parent = f.main})
		f.azeriteItem:SetFilter(filters.bagAzeriteItem, true)

		f.bagLegendary = MyContainer:New("BagLegendary", {Columns = bagsWidth, Parent = f.main})
		f.bagLegendary:SetFilter(filters.bagLegendary, true)

		f.equipment = MyContainer:New("Equipment", {Columns = bagsWidth, Parent = f.main})
		f.equipment:SetFilter(filters.bagEquipment, true)

		f.consumable = MyContainer:New("Consumable", {Columns = bagsWidth, Parent = f.main})
		f.consumable:SetFilter(filters.bagConsumable, true)

		f.bagCompanion = MyContainer:New("BagCompanion", {Columns = bagsWidth, Parent = f.main})
		f.bagCompanion:SetFilter(filters.bagMountPet, true)

		f.bagGoods = MyContainer:New("BagGoods", {Columns = bagsWidth, Parent = f.main})
		f.bagGoods:SetFilter(filters.bagGoods, true)

		f.bagQuest = MyContainer:New("BagQuest", {Columns = bagsWidth, Parent = f.main})
		f.bagQuest:SetFilter(filters.bagQuest, true)

		f.bank = MyContainer:New("Bank", {Columns = bankWidth, Bags = "bank"})
		f.bank:SetFilter(filters.onlyBank, true)
		f.bank:SetPoint("BOTTOMRIGHT", f.main, "BOTTOMLEFT", -12, 0)
		f.bank:Hide()

		f.bankFavourite = MyContainer:New("BankFavourite", {Columns = bankWidth, Parent = f.bank})
		f.bankFavourite:SetFilter(filters.bankFavourite, true)

		f.bankAzeriteItem = MyContainer:New("BankAzeriteItem", {Columns = bankWidth, Parent = f.bank})
		f.bankAzeriteItem:SetFilter(filters.bankAzeriteItem, true)

		f.bankLegendary = MyContainer:New("BankLegendary", {Columns = bankWidth, Parent = f.bank})
		f.bankLegendary:SetFilter(filters.bankLegendary, true)

		f.bankEquipment = MyContainer:New("BankEquipment", {Columns = bankWidth, Parent = f.bank})
		f.bankEquipment:SetFilter(filters.bankEquipment, true)

		f.bankConsumable = MyContainer:New("BankConsumable", {Columns = bankWidth, Parent = f.bank})
		f.bankConsumable:SetFilter(filters.bankConsumable, true)

		f.bankCompanion = MyContainer:New("BankCompanion", {Columns = bankWidth, Parent = f.bank})
		f.bankCompanion:SetFilter(filters.bankMountPet, true)

		f.bankGoods = MyContainer:New("BankGoods", {Columns = bankWidth, Parent = f.bank})
		f.bankGoods:SetFilter(filters.bankGoods, true)

		f.bankQuest = MyContainer:New("BankQuest", {Columns = bankWidth, Parent = f.bank})
		f.bankQuest:SetFilter(filters.bankQuest, true)

		f.reagent = MyContainer:New("Reagent", {Columns = bankWidth})
		f.reagent:SetFilter(filters.onlyReagent, true)
		f.reagent:SetPoint("BOTTOMLEFT", f.bank)
		f.reagent:Hide()

		Module.BagGroup = {f.azeriteItem, f.equipment, f.bagLegendary, f.bagCompanion, f.bagGoods, f.bagQuest, f.consumable, f.bagFavourite, f.junk}
		Module.BankGroup = {f.bankAzeriteItem, f.bankEquipment, f.bankLegendary, f.bankCompanion, f.bankGoods, f.bankQuest, f.bankConsumable, f.bankFavourite}
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

		self.IconOverlay:SetAllPoints()

		self:CreateBorder(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, true)
		self:StyleButton()

		local parentFrame = CreateFrame("Frame", nil, self)
		parentFrame:SetAllPoints()
		parentFrame:SetFrameLevel(5)

		if self.UpgradeIcon then
			self.UpgradeIcon:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\Inventory\\UpgradeIcon.tga")
			self.UpgradeIcon:SetTexCoord(0, 1, 0, 1)
			self.UpgradeIcon:SetPoint("TOPLEFT", -C["Inventory"].IconSize / 20, C["Inventory"].IconSize / 20)
			self.UpgradeIcon:SetSize(C["Inventory"].IconSize / 1.4, C["Inventory"].IconSize / 1.4)
			self.UpgradeIcon:Hide()
		end

		if not self.Favourite then
			self.Favourite = parentFrame:CreateTexture(nil, "OVERLAY")
			self.Favourite:SetAtlas("collections-icon-favorites")
			self.Favourite:SetSize(24, 24)
			self.Favourite:SetPoint("TOPRIGHT", 3, 2)
		end

		if not self.Quest then
			self.Quest = self:CreateTexture(nil, "ARTWORK")
			self.Quest:SetSize(26, 26)
			self.Quest:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\Inventory\\QuestIcon.tga")
			self.Quest:ClearAllPoints()
			self.Quest:SetPoint("LEFT", self, "LEFT", 0, 1)
		end

		self.iLvl = K.CreateFontString(self, 12, "", "OUTLINE", false, "BOTTOMLEFT", 1, 1)
		self.iLvl:SetFontObject(bagsFont)
		self.iLvl:SetFont(select(1, self.iLvl:GetFont()), 12, select(3, self.iLvl:GetFont()))

		if showNewItem then
			if not self.glowFrame then
				self.glowFrame = CreateFrame("Frame", nil, self, "BackdropTemplate")
				self.glowFrame:SetBackdrop({edgeFile = "Interface\\AddOns\\KkthnxUI\\Media\\Border\\Border_Glow_Overlay", edgeSize = 12})
				self.glowFrame:SetPoint("TOPLEFT", self, -6, 6)
				self.glowFrame:SetPoint("BOTTOMRIGHT", self, 6, -6)
				self.glowFrame:Hide()
			end

			if not self.glowFrame.Animation then
				self.glowFrame.Animation = self.glowFrame:CreateAnimationGroup()
				self.glowFrame.Animation:SetLooping("BOUNCE")

				self.glowFrame.Animation.FadeOut = self.glowFrame.Animation:CreateAnimation("Alpha")
				self.glowFrame.Animation.FadeOut:SetFromAlpha(1)
				self.glowFrame.Animation.FadeOut:SetToAlpha(0.1)
				self.glowFrame.Animation.FadeOut:SetDuration(0.5)
				self.glowFrame.Animation.FadeOut:SetSmoothing("IN_OUT")
			end
		end

		self:HookScript("OnClick", Module.ButtonOnClick)
	end

	function MyButton:ItemOnEnter()
		if self.glowFrame then
			if self.glowFrame.Animation:IsPlaying() then
				self.glowFrame.Animation:Stop()
				self.glowFrame:Hide()
			end
			-- Clear things on blizzard side too.
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
		return item.link and item.level and item.rarity > 1 and (Module:isArtifactRelic(item) or item.classID == LE_ITEM_CLASS_WEAPON or item.classID == LE_ITEM_CLASS_ARMOR)
	end

	local function GetIconOverlayAtlas(item)
		if not item.link then
			return
		end

		if C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItemByID(item.link) then
			return "AzeriteIconFrame"
		end
	end

	function MyButton:OnUpdate(item)
		local buttonIconTexture = _G[self:GetName().."IconTexture"]

		if self.JunkIcon then
			if (item.rarity == LE_ITEM_QUALITY_POOR or KkthnxUIData[K.Realm][K.Name].CustomJunkList[item.id]) and item.sellPrice and item.sellPrice > 0 then
				self.JunkIcon:Show()
			else
				self.JunkIcon:Hide()
			end
		end

		local atlas = GetIconOverlayAtlas(item)
		if atlas then
			self.IconOverlay:SetAtlas(atlas)
			self.IconOverlay:Show()
		else
			self.IconOverlay:Hide()
		end

		if self.UpgradeIcon then
			Module:UpdateItemUpgradeIcon(self)
		end

		if IsAddOnLoaded("CanIMogIt") then
			CIMI_AddToFrame(self, ContainerFrameItemButton_CIMIUpdateIcon)
			ContainerFrameItemButton_CIMIUpdateIcon(self.CanIMogItOverlay)
		end

		if KkthnxUIData[K.Realm][K.Name].FavouriteItems[item.id] then
			self.Favourite:Show()
		else
			self.Favourite:Hide()
		end

		if showItemLevel and isItemNeedsLevel(item) then
			local level = K.GetItemLevel(item.link, item.bagID, item.slotID) or item.level
			local color = K.QualityColors[item.rarity]

			self.iLvl:SetText(level)
			self.iLvl:SetTextColor(color.r, color.g, color.b)
		else
			self.iLvl:SetText("")
		end

		-- Determine if we can use that item or not?
		if (Unfit:IsItemUnusable(item.id) or item.minLevel and item.minLevel > K.Level) and not item.locked then
			buttonIconTexture:SetVertexColor(1, 0.1, 0.1)
		else
			buttonIconTexture:SetVertexColor(1, 1, 1)
		end

		if self.glowFrame then
			if C_NewItems_IsNewItem(item.bagID, item.slotID) then
				local color = K.QualityColors[item.rarity]

				if item.questID or item.isQuestItem then
					self.glowFrame:SetBackdropBorderColor(1, .82, .2)
				elseif color and item.rarity and item.rarity > -1 then
					self.glowFrame:SetBackdropBorderColor(color.r, color.g, color.b)
				else
					self.glowFrame:SetBackdropBorderColor(1, 1, 1)
				end

				if not self.glowFrame.Animation:IsPlaying() then
					self.glowFrame.Animation:Play()
					self.glowFrame:Show()
				end
			else
				if self.glowFrame.Animation:IsPlaying() then
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
	end

	function MyButton:OnUpdateQuest(item)
		local color = K.QualityColors[item.rarity]

		if item.questID and not item.questActive then
			self.Quest:Show()
		else
			self.Quest:Hide()
		end

		if item.questID or item.isQuestItem then
			self.KKUI_Border:SetVertexColor(1, .82, .2)
		elseif color and item.rarity and item.rarity > -1 then
			self.KKUI_Border:SetVertexColor(color.r, color.g, color.b)
		else
			if C["General"].ColorTextures then
				self.KKUI_Border:SetVertexColor(unpack(C["General"].TexturesColor))
			else
				self.KKUI_Border:SetVertexColor(1, 1, 1)
			end
		end
	end

	local MyContainer = Backpack:GetContainerClass()
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

		Module:UpdateAnchors(f.main, Module.BagGroup)
		Module:UpdateAnchors(f.bank, Module.BankGroup)
	end

	function MyContainer:OnCreate(name, settings)
		self.Settings = settings
		self:SetParent(settings.Parent or Backpack)
		self:SetFrameStrata("HIGH")
		self:SetClampedToScreen(true)
		self:CreateBorder()
		K.CreateMoverFrame(self, settings.Parent, true)

		local label
		if string_match(name, "AzeriteItem$") then
			label = "Azerite Armor"
		elseif string_match(name, "Equipment$") then
			if itemSetFilter then
				label = "EquipmentSet Items"
			else
				label = BAG_FILTER_EQUIPMENT
			end
		elseif name == "BagLegendary" then
			label = LOOT_JOURNAL_LEGENDARIES
		elseif name == "BankLegendary" then
			label = LOOT_JOURNAL_LEGENDARIES
		elseif string_match(name, "Consumable$") then
			label = BAG_FILTER_CONSUMABLES
		elseif name == "Junk" then
			label = BAG_FILTER_JUNK
		elseif string_match(name, "Companion") then
			label = MOUNTS_AND_PETS
		elseif string_match(name, "Favourite") then
			label = PREFERENCES
		elseif string_match(name, "Goods") then
			label = AUCTION_CATEGORY_TRADE_GOODS
		elseif string_match(name, "Quest") then
			label = AUCTION_CATEGORY_QUEST_ITEMS
		end

		if label then
			self.label = K.CreateFontString(self, 13, label, "OUTLINE", true, "TOPLEFT", 5, -8)
			return
		end

		Module.CreateInfoFrame(self)

		local buttons = {}
		buttons[1] = Module.CreateCloseButton(self)
		if name == "Main" then
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
		self:CreateBorder(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, true)
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

	-- Fixes
	BankFrame.GetRight = function()
		return f.bank:GetRight()
	end
	BankFrameItemButton_Update = K.Noop

	-- Shift key alert
	local function OnShiftUpdate(self, elapsed)
		if IsShiftKeyDown() then
			self.elapsed = (self.elapsed or 0) + elapsed
			if self.elapsed > 5 then
				UIErrorsFrame:AddMessage(K.InfoColor.."Your SHIFT key may be stuck!")
				self.elapsed = 0
			end
		end
	end

	local ShiftUpdaterFrame = CreateFrame("Frame", nil, f.main)
	ShiftUpdaterFrame:SetScript("OnUpdate", OnShiftUpdate)
end