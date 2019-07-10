local K, C, L = unpack(select(2, ...))
local Unfit = LibStub("Unfit-1.0")
local ModuleSort = K:GetModule("InventorySort")
local ModuleVendor = K:GetModule("Vendor")

if C["Inventory"].Enable ~= true
or K.CheckAddOnState("AdiBags")
or K.CheckAddOnState("ArkInventory")
or K.CheckAddOnState("cargBags_Nivaya")
or K.CheckAddOnState("cargBags")
or K.CheckAddOnState("Bagnon")
or K.CheckAddOnState("Combuctor")
or K.CheckAddOnState("TBag")
or K.CheckAddOnState("BaudBag") then
	return
end

-- Sourced (by Hungtar, editor Tukz then Kkthnx)

local _G = _G
local bit_band = bit.band
local ipairs = ipairs
local math_floor = math.floor
local pairs = pairs
local select = select
local string_find = string.find
local string_gsub = string.gsub
local string_lower = string.lower
local string_match = string.match
local table_insert = table.insert
local table_remove = table.remove
local tonumber = tonumber

local BankFrameItemButton_Update = _G.BankFrameItemButton_Update
local BankFrameItemButton_UpdateLocked = _G.BankFrameItemButton_UpdateLocked
local C_NewItems_IsNewItem = _G.C_NewItems.IsNewItem
local CloseBankFrame = _G.CloseBankFrame
local CooldownFrame_Set = _G.CooldownFrame_Set
local CreateFrame = _G.CreateFrame
local CURRENCY = _G.CURRENCY
local GameTooltip = _G.GameTooltip
local GetContainerItemCooldown = _G.GetContainerItemCooldown
local GetContainerItemEquipmentSetInfo = _G.GetContainerItemEquipmentSetInfo
local GetContainerItemID = _G.GetContainerItemID
local GetContainerItemInfo = _G.GetContainerItemInfo
local GetContainerItemLink = _G.GetContainerItemLink
local GetContainerItemQuestInfo = _G.GetContainerItemQuestInfo
local GetContainerNumFreeSlots = _G.GetContainerNumFreeSlots
local GetContainerNumSlots = _G.GetContainerNumSlots
local GetItemInfo = _G.GetItemInfo
local GetItemQualityColor = _G.GetItemQualityColor
local GetMoney = _G.GetMoney
local GetNumBankSlots = _G.GetNumBankSlots
local GetReagentBankCost = _G.GetReagentBankCost
local hooksecurefunc = _G.hooksecurefunc
local IsBattlePayItem = _G.IsBattlePayItem
local IsShiftKeyDown = _G.IsShiftKeyDown
local LE_ITEM_QUALITY_POOR = _G.LE_ITEM_QUALITY_POOR
local MAX_WATCHED_TOKENS = _G.MAX_WATCHED_TOKENS
local MoneyFrame_Update = _G.MoneyFrame_Update
local NEW_ITEM_ATLAS_BY_QUALITY = _G.NEW_ITEM_ATLAS_BY_QUALITY
local PlaySound = _G.PlaySound
local SEARCH = _G.SEARCH
local SetItemButtonCount = _G.SetItemButtonCount
local SetItemButtonDesaturated = _G.SetItemButtonDesaturated
local SetItemButtonTexture = _G.SetItemButtonTexture
local SortReagentBankBags = _G.SortReagentBankBags
local SOUNDKIT = _G.SOUNDKIT
local Token1, Token2, Token3 = _G.BackpackTokenFrameToken1, _G.BackpackTokenFrameToken2, _G.BackpackTokenFrameToken3
local UIParent = _G.UIParent

local BAGS_FONT = K.GetFont(C["UIFonts"].InventoryFonts)
local BAGS_BACKPACK = {0, 1, 2, 3, 4}
local BAGS_BANK = {-1, 5, 6, 7, 8, 9, 10, 11}
local ST_NORMAL = 1
local ST_FISHBAG = 2
local ST_SPECIAL = 3
local bag_bars = 0
local Ticker
local Profit = 0
local Spent = 0
local resetCountersFormatter = strjoin("", "|cffaaaaaa", "Reset Counters: Hold Shift + Left Click", "|r")
local resetInfoFormatter = strjoin("", "|cffaaaaaa", "Reset Data: Hold Shift + Right Click", "|r")

local function GetGraysValue()
	local value = 0

	for bag = 0, 4 do
		for slot = 1, GetContainerNumSlots(bag) do
			local itemID = GetContainerItemID(bag, slot)
			if itemID then
				local _, _, rarity, _, _, itype, _, _, _, _, itemPrice = GetItemInfo(itemID)
				if itemPrice then
					local stackCount = select(2, GetContainerItemInfo(bag, slot)) or 1
					local stackPrice = itemPrice * stackCount
					if (rarity and rarity == 0) and (itype and itype ~= "Quest") and (stackPrice > 0) then
						value = value + stackPrice
					end
				end
			end
		end
	end

	return value
end

local function VendorGrayCheck()
	local value = GetGraysValue()

	if value == 0 then
		K.Print("No gray items to delete.")
	elseif not MerchantFrame or not MerchantFrame:IsShown() then
		K.PopupDialogs["DELETE_GRAYS"].Money = value
		K.StaticPopup_Show("DELETE_GRAYS")
	else
		ModuleVendor:VendorGrays()
	end
end

local Stuffing = CreateFrame("Frame", nil, UIParent)
Stuffing:RegisterEvent("ADDON_LOADED")
Stuffing:RegisterEvent("PLAYER_ENTERING_WORLD")
Stuffing:SetScript("OnEvent", function(this, event, ...)
	Stuffing[event](this, ...)
end)

local function Stuffing_OnShow()
	Stuffing:PLAYERBANKSLOTS_CHANGED(29)

	for i = 0, #BAGS_BACKPACK - 1 do
		Stuffing:BAG_UPDATE(i)
	end

	Stuffing:Layout()
	Stuffing:SearchReset()
	PlaySound(SOUNDKIT.IG_BACKPACK_OPEN)
end

local function StuffingBank_OnHide()
	CloseBankFrame()

	if Stuffing.frame:IsShown() then
		Stuffing.frame:Hide()
	end

	if bag_bars == 1 then
		bag_bars = 0
	end

	PlaySound(SOUNDKIT.IG_BACKPACK_CLOSE)
end

local function Stuffing_OnHide()
	if Stuffing.bankFrame and Stuffing.bankFrame:IsShown() then
		Stuffing.bankFrame:Hide()
	end

	if bag_bars == 1 then
		bag_bars = 0
	end

	PlaySound(SOUNDKIT.IG_BACKPACK_CLOSE)
end

local function Stuffing_Open()
	if not Stuffing.frame:IsShown() then
		Stuffing.frame:Show()
	end
end

local function Stuffing_Close()
	Stuffing.frame:Hide()
end

local function Stuffing_Toggle()
	if Stuffing.frame:IsShown() then
		Stuffing.frame:Hide()
	else
		Stuffing.frame:Show()
	end
end

-- Bag slot stuff
local trashButton = {}
local trashBag = {}

-- Tooltip and scanning by Phanx @ http://www.wowinterface.com/forums/showthread.php?p=271406
local S_ITEM_LEVEL = "^" .. string_gsub(_G.ITEM_LEVEL, "%%d", "(%%d+)")

local ItemDB = {}
local function IsRealItemLevel(link, owner, bag, slot)
	if ItemDB[link] then
		return ItemDB[link]
	end

	local realItemLevel

	K.ScanTooltip.owner = owner
	K.ScanTooltip:SetOwner(_G.UIParent, "ANCHOR_NONE")
	K.ScanTooltip:SetBagItem(bag, slot)

	local line = _G[K.ScanTooltip:GetName() .. "TextLeft2"]
	if line then
		local msg = line:GetText()
		if msg and string_find(msg, S_ITEM_LEVEL) then
			local itemLevel = string_match(msg, S_ITEM_LEVEL)
			if itemLevel and (tonumber(itemLevel) > 0) then
				realItemLevel = itemLevel
			end
		else
			-- Check line 3, some artifacts have the ilevel there
			line = _G[K.ScanTooltip:GetName() .. "TextLeft3"]
			if line then
				local msg = line:GetText()
				if msg and string_find(msg, S_ITEM_LEVEL) then
					local itemLevel = string_match(msg, S_ITEM_LEVEL)
					if itemLevel and (tonumber(itemLevel) > 0) then
						realItemLevel = itemLevel
					end
				end
			end
		end
	end

	ItemDB[link] = tonumber(realItemLevel)
	return realItemLevel
end

function Stuffing:SlotUpdate(b)
	local texture, count, locked, quality, _, _, _, _, noValue = GetContainerItemInfo(b.bag, b.slot)
	local clink = GetContainerItemLink(b.bag, b.slot)
	local isQuestItem, questId, isActiveQuest = GetContainerItemQuestInfo(b.bag, b.slot)

	if not b.frame.lock then
		b.frame:SetBackdropBorderColor()
	end

	if b.cooldown and StuffingFrameBags and StuffingFrameBags:IsShown() then
		local start, duration, enable = GetContainerItemCooldown(b.bag, b.slot)
		CooldownFrame_Set(b.cooldown, start, duration, enable)
	end

	if C["Inventory"].ItemLevel == true then
		b.frame.text:SetText("")
	end

	if (b.frame.Azerite) then
		b.frame.Azerite:Hide()
	end

	if C["Inventory"].BindText == true then
		b.frame.bindType:SetText("")
	end

	if (b.frame.JunkIcon) then
		if (quality and quality == LE_ITEM_QUALITY_POOR) and not noValue and C["Inventory"].JunkIcon then
			b.frame.JunkIcon:Show()
		else
			b.frame.JunkIcon:Hide()
		end
	end

	if b.frame.UpgradeIcon then
		b.frame.UpgradeIcon:ClearAllPoints()
		b.frame.UpgradeIcon:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\Inventory\\UpgradeIcon")
		b.frame.UpgradeIcon:SetPoint("BOTTOMRIGHT", 6, -3)
		b.frame.UpgradeIcon:SetSize(C["Inventory"].ButtonSize / 1.4, C["Inventory"].ButtonSize / 1.4)
		b.frame.UpgradeIcon:SetTexCoord(0, 1, 0, 1)

		local itemIsUpgrade = _G.IsContainerItemAnUpgrade(b.frame:GetParent():GetID(), b.frame:GetID())
		if not itemIsUpgrade or itemIsUpgrade == nil then
			b.frame.UpgradeIcon:SetShown(false)
		else
			b.frame.UpgradeIcon:SetShown(itemIsUpgrade or true)
		end
	end

	if C["Inventory"].BindText and quality and quality > LE_ITEM_QUALITY_COMMON then
		K.ScanTooltip:SetOwner(self, "ANCHOR_NONE")
		K.ScanTooltip:SetBagItem(b.frame:GetParent():GetID(), b.frame:GetID())
		K.ScanTooltip:Show()

		for i = 2, 6 do -- trying line 2 to 6 for the bind texts, don't think they are further down
			local line = _G[K.ScanTooltip:GetName().."TextLeft"..i]:GetText()
			if (not line) or (line == _G.ITEM_SOULBOUND or line == _G.ITEM_ACCOUNTBOUND or line == _G.ITEM_BNETACCOUNTBOUND) then
				break
			end
			if line == _G.ITEM_BIND_ON_EQUIP then
				b.frame.bindType:SetText('BoE')
				b.frame.bindType:SetVertexColor(GetItemQualityColor(quality))
				break
			end
			if line == _G.ITEM_BIND_ON_USE then
				b.frame.bindType:SetText('BoU')
				b.frame.bindType:SetVertexColor(GetItemQualityColor(quality))
				break
			end
		end

		K.ScanTooltip:Hide()
	end

	local newItemTexture = b.frame.NewItemTexture
	local battlePayTexture = b.frame.BattlepayItemTexture
	local flashAnim = b.frame.flashAnim
	local newItemAnim = b.frame.newitemglowAnim
	if newItemTexture and C["Inventory"].PulseNewItem then
		if C_NewItems_IsNewItem(b.bag, b.slot) then
			if IsBattlePayItem(b.bag, b.slot) then
				newItemTexture:Hide()
				battlePayTexture:Show()
			else
				if quality and NEW_ITEM_ATLAS_BY_QUALITY[quality] then
					newItemTexture:SetAtlas(NEW_ITEM_ATLAS_BY_QUALITY[quality])
				else
					newItemTexture:SetAtlas("bags-glow-white")
				end
				newItemTexture:Show()
				battlePayTexture:Hide()
			end
			if not flashAnim:IsPlaying() and not newItemAnim:IsPlaying() then
				flashAnim:Play()
				newItemAnim:Play()
			end
		else
			newItemTexture:Hide()
			battlePayTexture:Hide()
			if flashAnim:IsPlaying() or newItemAnim:IsPlaying() then
				flashAnim:Stop()
				newItemAnim:Stop()
			end
		end

		battlePayTexture:SetSize(b.frame:GetSize())
		newItemTexture:SetSize(b.frame:GetSize())
	end

	local questTexture = _G[b.frame:GetName() .. "IconQuestTexture"]
	if questTexture then
		questTexture:ClearAllPoints()
		if questId and not isActiveQuest then
			questTexture:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\Inventory\\QuestIcon.tga")
			questTexture:SetPoint("BOTTOMLEFT", 1, 1)
			questTexture:SetSize(C["Inventory"].ButtonSize / 1.2, C["Inventory"].ButtonSize / 1.2)
			questTexture:SetTexCoord(0, 1, 0, 1)
			questTexture:Show()
		else
			questTexture:Hide()
		end
	end

	if IsAddOnLoaded("CanIMogIt") then
		CIMI_AddToFrame(b.frame, ContainerFrameItemButton_CIMIUpdateIcon)
		ContainerFrameItemButton_CIMIUpdateIcon(b.frame.CanIMogItOverlay)
	end

	if clink then
		b.name, _, _, b.itemlevel, b.level, _, _, _, _, _, _, b.itemClassID, b.itemSubClassID = GetItemInfo(clink)

		if not b.name then	-- Keystone bug
			b.name = clink:match("%[(.-)%]") or ""
		end

		if C["Inventory"].ItemLevel == true and b.itemlevel and quality > 1 and (b.itemClassID == 2 or b.itemClassID == 4 or (b.itemClassID == 3 and b.itemSubClassID == 11)) then
			b.itemlevel = IsRealItemLevel(clink, self, b.bag, b.slot) or b.itemlevel
			b.frame.text:SetText(b.itemlevel)
			b.frame.text:SetTextColor(GetItemQualityColor(quality))
		end

		if (Unfit:IsItemUnusable(clink) or b.level and b.level > K.Level) and not locked then
			_G[b.frame:GetName().."IconTexture"]:SetVertexColor(1, 0.1, 0.1)
		else
			_G[b.frame:GetName().."IconTexture"]:SetVertexColor(1, 1, 1)
		end

		-- Color slot according to item quality
		if not b.frame.lock and questId and not isActiveQuest then
			b.frame:SetBackdropBorderColor(1.0, 0.3, 0.3)
			if (b.frame.questIcon) then
				b.frame.questIcon:Show()
			end
		elseif questId or isQuestItem then
			b.frame:SetBackdropBorderColor(1.0, 0.3, 0.3)
		elseif quality and quality > 1 then
			b.frame:SetBackdropBorderColor(GetItemQualityColor(quality))
			if b.frame.Azerite and C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItemByID(clink) then
				b.frame.Azerite:Show()
			end
		else
			b.frame:SetBackdropBorderColor()
			b.name, b.level = nil, nil
		end

		-- Color slot according to item quality
		if not b.frame.lock and quality and quality > 1 and not (isQuestItem or questId) then
			b.frame:SetBackdropBorderColor(GetItemQualityColor(quality))
			if b.frame.Azerite and C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItemByID(clink) then
				b.frame.Azerite:Show()
			end
		elseif isQuestItem or questId then
			b.frame:SetBackdropBorderColor(1, 1, 0)
		end
	else
		b.name, b.level = nil, nil
	end

	SetItemButtonTexture(b.frame, texture)
	SetItemButtonCount(b.frame, count)
	SetItemButtonDesaturated(b.frame, locked)

	b.frame:Show()
end

function Stuffing:BagSlotUpdate(bag)
	if not self.buttons then
		return
	end

	for _, v in ipairs(self.buttons) do
		if v.bag == bag then
			self:SlotUpdate(v)
		end
	end
end

function Stuffing:UpdateCooldowns(b)
	if b.cooldown and StuffingFrameBags and StuffingFrameBags:IsShown() then
		local start, duration, enable = GetContainerItemCooldown(b.bag, b.slot)
		CooldownFrame_Set(b.cooldown, start, duration, enable)
	end
end

local function Stuffing_TooltipHide()
	if not GameTooltip:IsForbidden() then
		GameTooltip:Hide()
	end
end

local function Stuffing_TooltipShow(self)
	GameTooltip:SetOwner(self)
	GameTooltip:ClearLines()
	GameTooltip:AddLine(self.ttText)

	GameTooltip:Show()
end

local function Stuffing_CreateReagentContainer()
	ReagentBankFrame:StripTextures()

	local Reagent = CreateFrame("Frame", "StuffingFrameReagent", UIParent)
	local SwitchBankButton = CreateFrame("Button", nil, Reagent)
	local NumButtons = ReagentBankFrame.size
	local NumRows, LastRowButton, NumButtons, LastButton = 0, ReagentBankFrameItem1, 1, ReagentBankFrameItem1
	local Deposit = ReagentBankFrame.DespositButton

	Reagent:SetWidth(((C["Inventory"].ButtonSize + C["Inventory"].ButtonSpace) * C["Inventory"].BankColumns) + 17)
	Reagent:SetPoint("TOPLEFT", _G["StuffingFrameBank"], "TOPLEFT", 0, 0)
	Reagent:CreateBorder()
	Reagent:SetFrameStrata(_G["StuffingFrameBank"]:GetFrameStrata())
	Reagent:SetFrameLevel(_G["StuffingFrameBank"]:GetFrameLevel() + 5)
	Reagent:EnableMouse(true)
	Reagent:SetMovable(true)
	Reagent:SetClampedToScreen(true)
	Reagent:SetClampRectInsets(0, 0, 0, -20)
	Reagent:SetScript("OnMouseDown", function(self, button)
		if IsShiftKeyDown() and button == "LeftButton" then
			self:StartMoving()
		end
	end)
	Reagent:SetScript("OnMouseUp", Reagent.StopMovingOrSizing)

	SwitchBankButton:SetSize(16, 16)
	SwitchBankButton:CreateBorder()
	SwitchBankButton:StyleButton(true)
	SwitchBankButton:SetPoint("TOPRIGHT", -54, -7)
	SwitchBankButton:SetNormalTexture("Interface\\ICONS\\achievement_guildperk_mobilebanking")
	SwitchBankButton:GetNormalTexture():SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
	SwitchBankButton:GetNormalTexture():SetAllPoints()
	SwitchBankButton:SetPushedTexture("Interface\\ICONS\\achievement_guildperk_mobilebanking")
	SwitchBankButton:GetPushedTexture():SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
	SwitchBankButton:GetPushedTexture():SetAllPoints()
	SwitchBankButton.ttText = L["Inventory"].Bank
	SwitchBankButton:SetScript("OnEnter", Stuffing_TooltipShow)
	SwitchBankButton:SetScript("OnLeave", Stuffing_TooltipHide)
	SwitchBankButton:SetScript("OnClick", function()
		Reagent:Hide()
		_G["StuffingFrameBank"]:Show()
		_G["StuffingFrameBank"]:SetAlpha(1)
		BankFrame_ShowPanel(BANK_PANELS[1].name)
		PlaySound(PlaySoundKitID and "igbackpackopen" or SOUNDKIT.IG_BACKPACK_OPEN)
	end)

	local SortReagentButton = CreateFrame("Button", nil, Reagent)
	SortReagentButton:SetSize(16, 16)
	SortReagentButton:CreateBorder()
	SortReagentButton:StyleButton(true)
	SortReagentButton:SetPoint("TOPRIGHT", SwitchBankButton, -22, 0)
	SortReagentButton:SetNormalTexture("Interface\\ICONS\\INV_Pet_Broom")
	SortReagentButton:GetNormalTexture():SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
	SortReagentButton:GetNormalTexture():SetAllPoints()
	SortReagentButton:SetPushedTexture("Interface\\ICONS\\INV_Pet_Broom")
	SortReagentButton:GetPushedTexture():SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
	SortReagentButton:GetPushedTexture():SetAllPoints()
	SortReagentButton:SetDisabledTexture("Interface\\ICONS\\INV_Pet_Broom")
	SortReagentButton:GetDisabledTexture():SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
	SortReagentButton:GetDisabledTexture():SetAllPoints()
	SortReagentButton:GetDisabledTexture():SetDesaturated(1)
	SortReagentButton.ttText = _G.BAG_FILTER_CLEANUP
	SortReagentButton:SetScript("OnEnter", Stuffing_TooltipShow)
	SortReagentButton:SetScript("OnLeave", Stuffing_TooltipHide)
	SortReagentButton:SetScript("OnMouseUp", SortReagentBankBags)

	Deposit:SetParent(Reagent)
	Deposit:ClearAllPoints()
	Deposit:SetText("")
	Deposit:SetSize(16, 16)
	Deposit:CreateBorder()
	Deposit:StyleButton(true)
	Deposit:SetPoint("TOPLEFT", SwitchBankButton, "TOPRIGHT", 6, 0)
	Deposit:SetNormalTexture("Interface\\ICONS\\misc_arrowdown")
	Deposit:GetNormalTexture():SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
	Deposit:GetNormalTexture():SetAllPoints()
	Deposit:SetPushedTexture("Interface\\ICONS\\misc_arrowdown")
	Deposit:GetPushedTexture():SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
	Deposit:GetPushedTexture():SetAllPoints()
	Deposit.ttText = _G.REAGENTBANK_DEPOSIT
	Deposit:SetScript("OnEnter", Stuffing_TooltipShow)
	Deposit:SetScript("OnLeave", Stuffing_TooltipHide)
	Deposit:SetScript("OnClick", function()
		PlaySound(PlaySoundKitID and "igmainmenuoption" or SOUNDKIT.IG_MAINMENU_OPTION)
		DepositReagentBank()
	end)

	local Close = CreateFrame("Button", "StuffingCloseButtonReagent", Reagent, "UIPanelCloseButton")
	Close:SetPoint("TOPRIGHT", 0, 1)
	Close:SkinCloseButton()
	Close:RegisterForClicks("AnyUp")
	Close:SetScript("OnClick", function()
		StuffingBank_OnHide()
	end)

	for i = 1, 98 do
		local button = _G["ReagentBankFrameItem" .. i]
		local icon = _G[button:GetName() .. "IconTexture"]
		local count = _G[button:GetName() .. "Count"]

		ReagentBankFrame:SetParent(Reagent)
		ReagentBankFrame:ClearAllPoints()
		ReagentBankFrame:SetAllPoints()
		button:CreateBorder()
		button:StyleButton()
		button:SetNormalTexture(nil)
		button.IconBorder:SetAlpha(0)

		button:ClearAllPoints()
		button:SetSize(C["Inventory"].ButtonSize, C["Inventory"].ButtonSize)

		local _, _, _, quality = GetContainerItemInfo(-3, i)
		local clink = GetContainerItemLink(-3, i)
		if clink then
			if quality and quality > 1 then
				button:SetBackdropBorderColor(GetItemQualityColor(quality))
			end
		end

		if i == 1 then
			button:SetPoint("TOPLEFT", Reagent, "TOPLEFT", 10, -30)
			LastRowButton = button
			LastButton = button
		elseif NumButtons == C["Inventory"].BankColumns then
			button:SetPoint("TOPRIGHT", LastRowButton, "TOPRIGHT", 0, -(C["Inventory"].ButtonSpace + C["Inventory"].ButtonSize))
			button:SetPoint("BOTTOMLEFT", LastRowButton, "BOTTOMLEFT", 0, -(C["Inventory"].ButtonSpace + C["Inventory"].ButtonSize))
			LastRowButton = button
			NumRows = NumRows + 1
			NumButtons = 1
		else
			button:SetPoint("TOPRIGHT", LastButton, "TOPRIGHT", (C["Inventory"].ButtonSpace + C["Inventory"].ButtonSize), 0)
			button:SetPoint("BOTTOMLEFT", LastButton, "BOTTOMLEFT", (C["Inventory"].ButtonSpace + C["Inventory"].ButtonSize), 0)
			NumButtons = NumButtons + 1
		end

		icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
		icon:SetAllPoints()

		count:SetFontObject(BAGS_FONT)
		count:SetPoint("BOTTOMRIGHT", 1, 1)

		if (LastButton ~= button) then
			LastButton = button
		end
	end
	Reagent:SetHeight(((C["Inventory"].ButtonSize + C["Inventory"].ButtonSpace) * (NumRows + 1) + 40) - C["Inventory"].ButtonSpace)

	MoneyFrame_Update(ReagentBankFrame.UnlockInfo.CostMoneyFrame, GetReagentBankCost())
	ReagentBankFrameUnlockInfo:StripTextures()
	ReagentBankFrameUnlockInfo:SetAllPoints(Reagent)
	ReagentBankFrameUnlockInfo:CreateBorder()
	ReagentBankFrameUnlockInfo:SetFrameStrata("FULLSCREEN")
	ReagentBankFrameUnlockInfoPurchaseButton:SkinButton()
end

function Stuffing:BagFrameSlotNew(p, slot)
	for _, v in ipairs(self.bagframe_buttons) do
		if v.slot == slot then
			return v, false
		end
	end

	local ret = {}

	if slot > 3 then
		ret.slot = slot
		slot = slot - 4
		ret.frame = CreateFrame("CheckButton", "StuffingBBag" .. slot .. "Slot", p, "BankItemButtonBagTemplate")
		ret.frame:StripTextures()
		ret.frame:SetID(slot)

		hooksecurefunc(ret.frame.IconBorder, "SetVertexColor", function(self, r, g, b)
			if r ~= 0.65882 and g ~= 0.65882 and b ~= 0.65882 then
				self:GetParent():SetBackdropBorderColor(r, g, b)
			end

			self:SetTexture("")
		end)

		hooksecurefunc(ret.frame.IconBorder, "Hide", function(self)
			self:GetParent():SetBackdropBorderColor()
		end)

		table_insert(self.bagframe_buttons, ret)

		BankFrameItemButton_Update(ret.frame)
		BankFrameItemButton_UpdateLocked(ret.frame)

		if not ret.frame.tooltipText then
			ret.frame.tooltipText = ""
		end

		if slot > GetNumBankSlots() then
			SetItemButtonTextureVertexColor(ret.frame, 1.0, 0.1, 0.1)
		else
			SetItemButtonTextureVertexColor(ret.frame, 1.0, 1.0, 1.0)
		end
	else
		ret.frame = CreateFrame("ItemButton", "StuffingFBag" .. slot .. "Slot", p, "BagSlotButtonTemplate")

		hooksecurefunc(ret.frame.IconBorder, "SetVertexColor", function(self, r, g, b)
			if r ~= 0.65882 and g ~= 0.65882 and b ~= 0.65882 then
				self:GetParent():SetBackdropBorderColor(r, g, b)
			end

			self:SetTexture("")
		end)

		hooksecurefunc(ret.frame.IconBorder, "Hide", function(self)
			self:GetParent():SetBackdropBorderColor()
		end)

		ret.slot = slot
		table_insert(self.bagframe_buttons, ret)
	end

	ret.frame:CreateBorder()
	ret.frame:StyleButton()
	ret.frame:SetNormalTexture(nil)

	ret.icon = _G[ret.frame:GetName() .. "IconTexture"]
	ret.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	ret.icon:SetAllPoints()

	return ret
end

function Stuffing:SlotNew(bag, slot)
	for _, v in ipairs(self.buttons) do
		if v.bag == bag and v.slot == slot then
			v.lock = false
			return v, false
		end
	end

	local tpl = "ContainerFrameItemButtonTemplate"

	if bag == -1 then
		tpl = "BankItemButtonGenericTemplate"
	end

	local ret = {}

	if #trashButton > 0 then
		local f = -1
		for i, v in ipairs(trashButton) do
			local b, s = v:GetName():match("(%d+)_(%d+)")

			b = tonumber(b)
			s = tonumber(s)

			if b == bag and s == slot then
				f = i
				break
			else
				v:Hide()
			end
		end

		if f ~= -1 then
			ret.frame = trashButton[f]
			table_remove(trashButton, f)
			ret.frame:Show()
		end
	end

	if not ret.frame then
		ret.frame = CreateFrame("ItemButton", "StuffingBag" .. bag .. "_" .. slot, self.bags[bag], tpl)

		ret.frame:CreateBorder()
		ret.frame:StyleButton()
		ret.frame:SetNormalTexture(nil)

		ret.icon = _G[ret.frame:GetName() .. "IconTexture"]
		ret.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
		ret.icon:SetAllPoints()

		ret.count = _G[ret.frame:GetName() .. "Count"]
		ret.count:SetFontObject(BAGS_FONT)
		ret.count:SetShadowOffset(0, 0)
		ret.count:SetPoint("BOTTOMRIGHT", 1, 1)

		if C["Inventory"].ItemLevel == true then
			ret.frame.text = ret.frame:CreateFontString(nil, 'OVERLAY')
			ret.frame.text:SetPoint("TOPLEFT", 1, -1)
			ret.frame.text:FontTemplate(nil, 11, "OUTLINE")
		end

		if C["Inventory"].BindText == true then
			ret.frame.bindType = ret.frame:CreateFontString(nil, 'OVERLAY')
			ret.frame.bindType:SetPoint("BOTTOM", 2, 2)
			ret.frame.bindType:FontTemplate(nil, 10, "OUTLINE")
		end

		-- JunkIcon only exists for items created through ContainerFrameItemButtonTemplate
		if not ret.frame.JunkIcon then
			ret.frame.JunkIcon = ret.frame:CreateTexture(nil, "OVERLAY")
			ret.frame.JunkIcon:SetAtlas("bags-junkcoin")
			ret.frame.JunkIcon:SetPoint("TOPLEFT", 1, 0)
			ret.frame.JunkIcon:Hide()
		end

		if not ret.frame.Azerite then
			ret.frame.Azerite = ret.frame:CreateTexture(nil, "OVERLAY")
			ret.frame.Azerite:SetAtlas("AzeriteIconFrame")
			ret.frame.Azerite:SetTexCoord(0, 1, 0, 1)
			ret.frame.Azerite:SetPoint("TOPLEFT")
			ret.frame.Azerite:SetPoint("BOTTOMRIGHT")
			ret.frame.Azerite:Hide()
		end

		local Battlepay = _G[ret.frame:GetName()].BattlepayItemTexture
		if Battlepay then
			Battlepay:SetAlpha(0)
		end
	end

	ret.bag = bag
	ret.slot = slot
	ret.frame:SetID(slot)

	ret.cooldown = _G[ret.frame:GetName() .. "Cooldown"]
	ret.cooldown:Show()

	self:SlotUpdate(ret)

	return ret, true
end

local BAGTYPE_PROFESSION = 0x0008 + 0x0010 + 0x0020 + 0x0040 + 0x0080 + 0x0200 + 0x0400 + 0x10000
local BAGTYPE_FISHING = 32768

function Stuffing:BagType(bag)
	local bagType = select(2, GetContainerNumFreeSlots(bag))

	if bagType and bit_band(bagType, BAGTYPE_FISHING) > 0 then
		return ST_FISHBAG
	elseif bagType and bit_band(bagType, BAGTYPE_PROFESSION) > 0 then
		return ST_SPECIAL
	end

	return ST_NORMAL
end

function Stuffing:BagNew(bag, f)
	for _, v in pairs(self.bags) do
		if v:GetID() == bag then
			v.bagType = self:BagType(bag)
			return v
		end
	end

	local ret

	if #trashBag > 0 then
		local f = -1
		for i, v in pairs(trashBag) do
			if v:GetID() == bag then
				f = i
				break
			end
		end

		if f ~= -1 then
			ret = trashBag[f]
			table_remove(trashBag, f)
			ret:Show()
			ret.bagType = self:BagType(bag)
			return ret
		end
	end

	ret = CreateFrame("Frame", "StuffingBag" .. bag, f)
	ret.bagType = self:BagType(bag)

	ret:SetID(bag)
	return ret
end

function Stuffing:SearchUpdate(str)
	str = string_lower(str)

	for _, b in ipairs(self.buttons) do
		if b.frame and not b.name then
			b.frame:SetAlpha(0.2)
		end
		if b.name then
			local _, setName = GetContainerItemEquipmentSetInfo(b.bag, b.slot)

			setName = setName or ""

			local ilink = GetContainerItemLink(b.bag, b.slot)
			local class, subclass, _, equipSlot = select(6, GetItemInfo(ilink))
			local minLevel = select(5, GetItemInfo(ilink))

			class = _G[class] or ""
			subclass = _G[subclass] or ""
			equipSlot = _G[equipSlot] or ""
			minLevel = minLevel or 1

			if not string_find(string_lower(b.name), str) and not string_find(string_lower(setName), str) and not string_find(string_lower(class), str) and not string_find(string_lower(subclass), str) and not string_find(string_lower(equipSlot), str) then
				if Unfit:IsItemUnusable(b.name) or minLevel > K.Level then
					_G[b.frame:GetName() .. "IconTexture"]:SetVertexColor(0.5, 0.5, 0.5)
				end

				SetItemButtonDesaturated(b.frame, true)
				b.frame:SetAlpha(0.2)
			else
				if Unfit:IsItemUnusable(b.name) or minLevel > K.Level then
					_G[b.frame:GetName() .. "IconTexture"]:SetVertexColor(1, 0.1, 0.1)
				end

				SetItemButtonDesaturated(b.frame, false)
				b.frame:SetAlpha(1)
			end
		end
	end
end

function Stuffing:SearchReset()
	for _, b in ipairs(self.buttons) do
		if Unfit:IsItemUnusable(b.name) or (b.level and b.level > K.Level) then
			_G[b.frame:GetName() .. "IconTexture"]:SetVertexColor(1, 0.1, 0.1)
		end

		b.frame:SetAlpha(1)
		SetItemButtonDesaturated(b.frame, false)
	end
end

local function DragFunction(self, mode)
	for index = 1, select("#", self:GetChildren()) do
		local frame = select(index, self:GetChildren())
		if frame:GetName() and frame:GetName():match("StuffingBag") then
			if mode then
				frame:Hide()
			else
				frame:Show()
			end
		end
	end
end

function Stuffing:CreateBagFrame(w)
	local n = "StuffingFrame" .. w
	local f = CreateFrame("Frame", n, UIParent)
	f:EnableMouse(true)
	f:SetMovable(true)
	f:SetFrameStrata("MEDIUM")
	f:SetFrameLevel(5)
	f:RegisterForDrag("LeftButton", "RightButton")

	f:SetScript("OnDragStart", function(self)
		if IsShiftKeyDown() then
			self:StartMoving()
			DragFunction(self, true)
		end
	end)

	f:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
		DragFunction(self, false)
	end)

	f:SetScript("OnEnter", function(self)
		if GameTooltip:IsForbidden() then
			return
		end

		GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 4)
		GameTooltip:ClearLines()
		GameTooltip:AddDoubleLine(L["Inventory"].Shift_Move)

		GameTooltip:Show()
	end)

	f:SetScript("OnLeave", function()
		if not GameTooltip:IsForbidden() then
			GameTooltip:Hide()
		end
	end)

	if w == "Bank" then
		f:SetPoint("BOTTOMLEFT", "UIParent", "BOTTOMLEFT", 86, 142)
	else
		f:SetPoint("BOTTOMRIGHT", "UIParent", "BOTTOMRIGHT", -86, 142)
	end

	if w == "Bank" then
		f.reagentToggle = CreateFrame("Button", "StuffingReagentButton" .. w, f)
		f.reagentToggle:SetSize(16, 16)
		f.reagentToggle:CreateBorder()
		f.reagentToggle:SetPoint("TOPRIGHT", f, -32, -7)
		f.reagentToggle:SetNormalTexture("Interface\\ICONS\\INV_Enchant_DustArcane")
		f.reagentToggle:GetNormalTexture():SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
		f.reagentToggle:GetNormalTexture():SetAllPoints()
		f.reagentToggle:SetPushedTexture("Interface\\ICONS\\INV_Enchant_DustArcane")
		f.reagentToggle:GetPushedTexture():SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
		f.reagentToggle:GetPushedTexture():SetAllPoints()
		f.reagentToggle:StyleButton(nil, true)
		f.reagentToggle.ttText = L["Inventory"].Reagents
		f.reagentToggle:SetScript("OnEnter", Stuffing_TooltipShow)
		f.reagentToggle:SetScript("OnLeave", Stuffing_TooltipHide)
		f.reagentToggle:SetScript("OnClick", function()
			BankFrame_ShowPanel(BANK_PANELS[2].name)
			PlaySound(PlaySoundKitID and "igcharacterinfotab" or SOUNDKIT.IG_CHARACTER_INFO_TAB)
			if not ReagentBankFrame.isMade then
				Stuffing_CreateReagentContainer()
				ReagentBankFrame.isMade = true
			else
				_G["StuffingFrameReagent"]:Show()
			end

			_G["StuffingFrameBank"]:SetAlpha(0)
		end)

		f.bagsButton = CreateFrame("Button", nil, f)
		f.bagsButton:SetSize(16, 16)
		f.bagsButton:CreateBorder()
		f.bagsButton:SetPoint("RIGHT", f.reagentToggle, "LEFT", -5, 0)
		f.bagsButton:SetNormalTexture("Interface\\Buttons\\Button-Backpack-Up")
		f.bagsButton:GetNormalTexture():SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
		f.bagsButton:GetNormalTexture():SetAllPoints()
		f.bagsButton:SetPushedTexture("Interface\\Buttons\\Button-Backpack-Up")
		f.bagsButton:GetPushedTexture():SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
		f.bagsButton:GetPushedTexture():SetAllPoints()
		f.bagsButton:StyleButton(nil, true)
		f.bagsButton.ttText = L["Inventory"].Show_Bags
		f.bagsButton:SetScript("OnEnter", Stuffing_TooltipShow)
		f.bagsButton:SetScript("OnLeave", Stuffing_TooltipHide)
		f.bagsButton:SetScript("OnClick", function()
			PlaySound(PlaySoundKitID and "igmainmenuoption" or SOUNDKIT.IG_MAINMENU_OPTION)
			if bag_bars == 1 then
				bag_bars = 0
			else
				bag_bars = 1
			end

			if Stuffing.bankFrame and Stuffing.bankFrame:IsShown() then
				Stuffing:Layout(true)
			end
		end)

		f.sortButton = CreateFrame("Button", nil, f)
		f.sortButton:SetSize(16, 16)
		f.sortButton:CreateBorder()
		f.sortButton:StyleButton(true)
		f.sortButton:SetPoint("TOPRIGHT", f.bagsButton, -22, 0)
		f.sortButton:SetNormalTexture("Interface\\ICONS\\INV_Pet_Broom")
		f.sortButton:GetNormalTexture():SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
		f.sortButton:GetNormalTexture():SetAllPoints()
		f.sortButton:SetPushedTexture("Interface\\ICONS\\INV_Pet_Broom")
		f.sortButton:GetPushedTexture():SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
		f.sortButton:GetPushedTexture():SetAllPoints()
		f.sortButton:SetDisabledTexture("Interface\\ICONS\\INV_Pet_Broom")
		f.sortButton:GetDisabledTexture():SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
		f.sortButton:GetDisabledTexture():SetAllPoints()
		f.sortButton:GetDisabledTexture():SetDesaturated(1)
		f.sortButton.ttText = BAG_FILTER_CLEANUP
		f.sortButton:SetScript("OnEnter", Stuffing_TooltipShow)
		f.sortButton:SetScript("OnLeave", Stuffing_TooltipHide)
		f.sortButton:SetScript("OnMouseUp", function()
			-- if StuffingFrameBags and StuffingFrameBags:IsShown() then
			if Stuffing.frame:IsShown() then
				f:UnregisterAllEvents() -- Unregister to prevent unnecessary updates
				f.registerUpdate = true -- Set variable that indicates this bag should be updated when sorting is done
				ModuleSort:CommandDecorator(ModuleSort.SortBags, "bank")()
			end
		end)

		f.purchaseBagButton = CreateFrame("Button", "StuffingPurchaseButton" .. w, f)
		f.purchaseBagButton:SetSize(16, 16)
		f.purchaseBagButton:CreateBorder()
		f.purchaseBagButton:SetPoint("RIGHT", f.sortButton, "LEFT", -5, 0)
		f.purchaseBagButton:SetNormalTexture("Interface\\ICONS\\INV_Misc_Coin_01")
		f.purchaseBagButton:GetNormalTexture():SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
		f.purchaseBagButton:GetNormalTexture():SetAllPoints()
		f.purchaseBagButton:SetPushedTexture("Interface\\ICONS\\INV_Misc_Coin_01")
		f.purchaseBagButton:GetPushedTexture():SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
		f.purchaseBagButton:GetPushedTexture():SetAllPoints()
		f.purchaseBagButton:StyleButton(nil, true)
		f.purchaseBagButton.ttText = L["Inventory"].Purchase_Slot
		f.purchaseBagButton:SetScript("OnEnter", Stuffing_TooltipShow)
		f.purchaseBagButton:SetScript("OnLeave", Stuffing_TooltipHide)
		f.purchaseBagButton:SetScript("OnClick", function()
			local numSlots, full = GetNumBankSlots()

			if (full) then
				K.StaticPopup_Show("CANNOT_BUY_BANK_SLOT")
			else
				K.StaticPopup_Show("BUY_BANK_SLOT")
			end

			local button
			for i = 1, NUM_BANKBAGSLOTS, 1 do
				button = _G["StuffingBBag"..i.."Slot"]
				if button then
					if i <= numSlots then
						SetItemButtonTextureVertexColor(button, 1.0, 1.0, 1.0)
					else
						SetItemButtonTextureVertexColor(button, 1.0, 0.1, 0.1)
					end
				end
			end
		end)
	end

	f.b_close = CreateFrame("Button", "StuffingCloseButton" .. w, f, "UIPanelCloseButton")
	f.b_close:SetPoint("TOPRIGHT", -2, 1)
	f.b_close:SkinCloseButton()
	f.b_close:RegisterForClicks("AnyUp")
	f.b_close:SetScript("OnClick", function(self)
		self:GetParent():Hide()
	end)

	local fb = CreateFrame("Frame", n .. "BagsFrame", f)
	fb:SetPoint("BOTTOMLEFT", f, "TOPLEFT", 0, 6)
	fb:SetFrameStrata("MEDIUM")
	f.bags_frame = fb

	return f
end

function Stuffing:InitBank()
	if self.bankFrame then
		return
	end

	local f = self:CreateBagFrame("Bank")
	f:SetScript("OnHide", StuffingBank_OnHide)
	self.bankFrame = f
end

function Stuffing:InitBags()
	if self.frame then
		return
	end

	self.buttons = {}
	self.bags = {}
	self.bagframe_buttons = {}

	local f = self:CreateBagFrame("Bags")
	f:SetScript("OnShow", Stuffing_OnShow)
	f:SetScript("OnHide", Stuffing_OnHide)

	local editbox = CreateFrame("EditBox", nil, f)
	editbox:Hide()
	editbox:SetAutoFocus(true)
	editbox:CreateBackdrop()

	local function resetAndClear(self)
		self:GetParent().detail:Show()
		self:ClearFocus()
		Stuffing:SearchReset()
	end

	local function updateSearch(self, t)
		if t == true then
			Stuffing:SearchUpdate(self:GetText())
		end
	end

	editbox:SetScript("OnEscapePressed", resetAndClear)
	editbox:SetScript("OnEnterPressed", resetAndClear)
	editbox:SetScript("OnEditFocusLost", editbox.Hide)
	editbox:SetScript("OnEditFocusGained", editbox.HighlightText)
	editbox:SetScript("OnTextChanged", updateSearch)
	editbox:SetScript("OnChar", updateSearch)

	local detail = f:CreateFontString(nil, "ARTWORK", "GameFontHighlightLarge")
	detail:SetPoint("TOPLEFT", f, 11, -10)
	detail:SetPoint("RIGHT", f, -140, -10)
	detail:SetShadowColor(0, 0, 0, 0)
	detail:SetJustifyH("LEFT")
	detail:SetText(K.MyClassColor .. SEARCH)
	editbox:SetAllPoints(detail)

	local gold = CreateFrame("Button", nil, f)
	gold:SetFrameLevel(f:GetFrameLevel() + 2)
	gold:RegisterForClicks("AnyUp")

	gold.text = f:CreateFontString(nil, "OVERLAY")
	gold.text:SetFontObject(BAGS_FONT)
	gold.text:SetFont(select(1, gold.text:GetFont()), 12, select(3, gold.text:GetFont()))

	gold:SetAllPoints(gold.text)

	local function OnGoldEvent(self)
		if not _G.IsLoggedIn() then
			return
		end

		if not Ticker then
			C_WowTokenPublic.UpdateMarketPrice()
			Ticker = _G.C_Timer.NewTicker(60, C_WowTokenPublic.UpdateMarketPrice)
		end

		local NewMoney = GetMoney()
		KkthnxUIData = KkthnxUIData or {}
		KkthnxUIData["Gold"] = KkthnxUIData["Gold"] or {}
		KkthnxUIData["Gold"][K.Realm] = KkthnxUIData["Gold"][K.Realm] or {}
		KkthnxUIData["Gold"][K.Realm][K.Name] = KkthnxUIData["Gold"][K.Realm][K.Name] or NewMoney

		KkthnxUIData["Class"] = KkthnxUIData["Class"] or {}
		KkthnxUIData["Class"][K.Realm] = KkthnxUIData["Class"][K.Realm] or {}
		KkthnxUIData["Class"][K.Realm][K.Name] = K.Class

		local OldMoney = KkthnxUIData["Gold"][K.Realm][K.Name] or NewMoney

		local Change = NewMoney - OldMoney -- Positive If We Gain Money
		if OldMoney > NewMoney then -- Lost Money
			Spent = Spent - Change
		else -- Gained Moeny
			Profit = Profit + Change
		end

		self.text:SetText(K.FormatMoney(NewMoney))

		KkthnxUIData["Gold"][K.Realm][K.Name] = NewMoney
	end

	local function OnGoldClick(self, btn)
		if btn == "RightButton" then
			if IsShiftKeyDown() then
				KkthnxUIData.Gold = nil
				OnGoldEvent(self)
				GameTooltip:Hide()
			elseif _G.IsControlKeyDown() then
				Profit = 0
				Spent = 0
				GameTooltip:Hide()
			end
		end
	end

	local myGold = {}
	local function OnGoldEnter(self)
		GameTooltip:SetOwner(self, "ANCHOR_NONE")
		GameTooltip:SetPoint(K.GetAnchors(self))
		GameTooltip:ClearLines()

		GameTooltip:AddLine("Session:")
		GameTooltip:AddDoubleLine("Earned:", K.FormatMoney(Profit), 1, 1, 1, 1, 1, 1)
		GameTooltip:AddDoubleLine("Spent:", K.FormatMoney(Spent), 1, 1, 1, 1, 1, 1)
		if Profit < Spent then
			GameTooltip:AddDoubleLine("Deficit:", K.FormatMoney(Profit - Spent), 1, 0, 0, 1, 1, 1)
		elseif (Profit-Spent)>0 then
			GameTooltip:AddDoubleLine("Profit:", K.FormatMoney(Profit - Spent), 0, 1, 0, 1, 1, 1)
		end
		GameTooltip:AddLine(" ")

		local totalGold = 0
		GameTooltip:AddLine("Character: ")

		table.wipe(myGold)
		for k, _ in pairs(KkthnxUIData["Gold"][K.Realm]) do
			if KkthnxUIData["Gold"][K.Realm][k] then
				local class = KkthnxUIData["Class"][K.Realm][k] or "PRIEST"
				local color = class and (_G.CUSTOM_CLASS_COLORS and _G.CUSTOM_CLASS_COLORS[class] or _G.RAID_CLASS_COLORS[class])
				table_insert(myGold,
					{
						name = k,
						amount = KkthnxUIData["Gold"][K.Realm][k],
						amountText = K.FormatMoney(KkthnxUIData["Gold"][K.Realm][k]),
						r = color.r, g = color.g, b = color.b,
					}
				)
			end
			totalGold = totalGold + KkthnxUIData["Gold"][K.Realm][k]
		end

		for _, g in ipairs(myGold) do
			GameTooltip:AddDoubleLine(g.name == K.Name and g.name.." |TInterface\\COMMON\\Indicator-Green:14|t" or g.name, g.amountText, g.r, g.g, g.b, 1, 1, 1)
		end

		GameTooltip:AddLine(" ")
		GameTooltip:AddLine("Server: ")
		GameTooltip:AddDoubleLine("Total: ", K.FormatMoney(totalGold), 1, 1, 1, 1, 1, 1)
		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine("WoW Token:", K.FormatMoney(_G.C_WowTokenPublic.GetCurrentMarketPrice() or 0), 1, 1, 1, 1, 1, 1)

		for i = 1, MAX_WATCHED_TOKENS do
			local name, count = _G.GetBackpackCurrencyInfo(i)
			if name and i == 1 then
				GameTooltip:AddLine(" ")
				GameTooltip:AddLine(CURRENCY)
			end
			if name and count then GameTooltip:AddDoubleLine(name, count, 1, 1, 1) end
		end

		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(resetCountersFormatter)
		GameTooltip:AddLine(resetInfoFormatter)

		GameTooltip:Show()
	end

	local function OnGoldLeave()
		GameTooltip:Hide()
	end

	gold:RegisterEvent("PLAYER_ENTERING_WORLD")
	gold:RegisterEvent("PLAYER_MONEY")
	gold:RegisterEvent("SEND_MAIL_MONEY_CHANGED")
	gold:RegisterEvent("SEND_MAIL_COD_CHANGED")
	gold:RegisterEvent("PLAYER_TRADE_MONEY")
	gold:RegisterEvent("TRADE_MONEY_CHANGED")
	gold:SetScript("OnEvent", OnGoldEvent)
	gold:SetScript("OnMouseUp", OnGoldClick)
	gold:SetScript("OnEnter", OnGoldEnter)
	gold:SetScript("OnLeave", OnGoldLeave)

	do
		Token3:ClearAllPoints()
		Token3:SetPoint("TOP", f, "BOTTOM", -70, -10)
		Token2:ClearAllPoints()
		Token2:SetPoint("LEFT", Token3, "RIGHT", 14, 0)
		Token1:ClearAllPoints()
		Token1:SetPoint("LEFT", Token2, "RIGHT", 14, 0)
	end

	for i = 1, 3 do
		local Token = _G["BackpackTokenFrameToken" .. i]
		local Icon = _G["BackpackTokenFrameToken" .. i .. "Icon"]
		local Count = _G["BackpackTokenFrameToken" .. i .. "Count"]

		Token:SetParent(f)
		Token:SetScale(1)
		Token:CreateBackdrop()
		Token.Backdrop:SetAllPoints(Icon)
		Token.Backdrop:SetFrameLevel(6)
		Token:SetFrameStrata("MEDIUM")
		Token:SetFrameLevel(51)

		Icon:SetSize(16, 16)
		Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
		Icon:SetPoint("LEFT", Token, "RIGHT", -8, 2)

		Count:SetFontObject(BAGS_FONT)
		Count:SetShadowOffset(0, 0)
	end

	local button = CreateFrame("Button", nil, f)
	button:EnableMouse(true)
	button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	button:SetAllPoints(detail)
	button.ttText = L["Inventory"].Right_Click_Search
	button:SetScript("OnClick", function(self, btn)
		if btn == "RightButton" then
			self:GetParent().detail:Hide()
			self:GetParent().editbox:Show()
			self:GetParent().editbox:HighlightText()
		else
			if self:GetParent().editbox:IsShown() then
				self:GetParent().editbox:Hide()
				self:GetParent().editbox:ClearFocus()
				self:GetParent().detail:Show()
				Stuffing:SearchReset()
			end
		end
	end)

	button:SetScript("OnEnter", Stuffing_TooltipShow)
	button:SetScript("OnLeave", Stuffing_TooltipHide)

	f.bagsButton = CreateFrame("Button", nil, f)
	f.bagsButton:SetSize(16, 16)
	f.bagsButton:CreateBorder()
	f.bagsButton:SetPoint("TOPRIGHT", f, -32, -7)
	f.bagsButton:SetNormalTexture("Interface\\Buttons\\Button-Backpack-Up")
	f.bagsButton:GetNormalTexture():SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
	f.bagsButton:GetNormalTexture():SetAllPoints()
	f.bagsButton:SetPushedTexture("Interface\\Buttons\\Button-Backpack-Up")
	f.bagsButton:GetPushedTexture():SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
	f.bagsButton:GetPushedTexture():SetAllPoints()
	f.bagsButton:StyleButton(nil, true)
	f.bagsButton.ttText = L["Inventory"].Show_Bags
	f.bagsButton:SetScript("OnEnter", Stuffing_TooltipShow)
	f.bagsButton:SetScript("OnLeave", Stuffing_TooltipHide)
	f.bagsButton:SetScript("OnClick", function()
		PlaySound(PlaySoundKitID and "igmainmenuoption" or SOUNDKIT.IG_MAINMENU_OPTION)
		if bag_bars == 1 then
			bag_bars = 0
		else
			bag_bars = 1
		end

		if Stuffing.frame and Stuffing.frame:IsShown() then
			Stuffing:Layout()
		end
	end)

	f.sortButton = CreateFrame("Button", nil, f)
	f.sortButton:SetSize(16, 16)
	f.sortButton:CreateBorder()
	f.sortButton:StyleButton(nil, true)
	f.sortButton:SetPoint("TOPRIGHT", f.bagsButton, -22, 0)
	f.sortButton:SetNormalTexture("Interface\\ICONS\\INV_Pet_Broom")
	f.sortButton:GetNormalTexture():SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
	f.sortButton:GetNormalTexture():SetAllPoints()
	f.sortButton:SetPushedTexture("Interface\\ICONS\\INV_Pet_Broom")
	f.sortButton:GetPushedTexture():SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
	f.sortButton:GetPushedTexture():SetAllPoints()
	f.sortButton:SetDisabledTexture("Interface\\ICONS\\INV_Pet_Broom")
	f.sortButton:GetDisabledTexture():SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
	f.sortButton:GetDisabledTexture():SetAllPoints()
	f.sortButton:GetDisabledTexture():SetDesaturated(1)
	f.sortButton.ttText = _G.BAG_FILTER_CLEANUP
	f.sortButton:SetScript("OnEnter", Stuffing_TooltipShow)
	f.sortButton:SetScript("OnLeave", Stuffing_TooltipHide)
	f.sortButton:SetScript("OnMouseUp", function()
		f:UnregisterAllEvents() -- Unregister To Prevent Unnecessary Updates
		f.registerUpdate = true -- Set Variable That Indicates This Bag Should Be Updated When Sorting Is Done
		ModuleSort:CommandDecorator(ModuleSort.SortBags, "bags")()
	end)

	--Vendor Grays
	f.vendorGraysButton = CreateFrame('Button', nil, f)
	f.vendorGraysButton:SetSize(16, 16)
	f.vendorGraysButton:CreateBorder()
	f.vendorGraysButton:SetPoint("RIGHT", f.sortButton, "LEFT", -5, 0)
	f.vendorGraysButton:SetNormalTexture("Interface\\ICONS\\INV_Misc_Coin_01")
	f.vendorGraysButton:GetNormalTexture():SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
	f.vendorGraysButton:GetNormalTexture():SetAllPoints()
	f.vendorGraysButton:SetPushedTexture("Interface\\ICONS\\INV_Misc_Coin_01")
	f.vendorGraysButton:GetPushedTexture():SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
	f.vendorGraysButton:GetPushedTexture():SetAllPoints()
	f.vendorGraysButton:StyleButton(nil, true)
	f.vendorGraysButton.ttText = "Vendor / Delete Grays|n|nMust be at vendor to recieve money for grays"
	f.vendorGraysButton:SetScript("OnEnter", Stuffing_TooltipShow)
	f.vendorGraysButton:SetScript("OnLeave", Stuffing_TooltipHide)
	f.vendorGraysButton:SetScript("OnClick", VendorGrayCheck)

	-- Editbox And Gold
	editbox.Backdrop:SetPoint("TOPLEFT", -2, 1)
	editbox.Backdrop:SetPoint("BOTTOMRIGHT", gold.text, "LEFT", -5, -8)
	gold.text:SetPoint("RIGHT", f.vendorGraysButton, "LEFT", -6, 0)

	f.editbox = editbox
	f.detail = detail
	f.button = button

	self.frame = f

	f:Hide()
end

function Stuffing:Layout(isBank)
	local slots = 0
	local rows = 0
	local off = 20
	local cols, f, bs

	if isBank then
		bs = BAGS_BANK
		cols = C["Inventory"].BankColumns
		f = self.bankFrame
		self.bankFrame:SetAlpha(1)
	else
		bs = BAGS_BACKPACK
		cols = C["Inventory"].BagColumns
		f = self.frame

		f.editbox:SetFontObject(BAGS_FONT)
		f.detail:SetFontObject(BAGS_FONT)
		f.detail:ClearAllPoints()
		f.detail:SetPoint("TOPLEFT", f, 12, -8)
		f.detail:SetPoint("RIGHT", f, -140, 0)
	end

	f:SetClampedToScreen(1)
	f:CreateBorder()

	local fb = f.bags_frame
	if bag_bars == 1 then
		fb:SetClampedToScreen(1)
		fb:CreateBorder()

		local bsize = C["Inventory"].ButtonSize
		local w = 2 * 8

		w = w + ((#bs - 1) * bsize)
		w = w + ((#bs - 2) * 6)

		fb:SetHeight(2 * 8 + bsize)
		fb:SetWidth(w)
		fb:Show()
	else
		fb:Hide()
	end

	local idx = 0
	for _, v in ipairs(bs) do
		if (not isBank and v <= 3) or (isBank and v ~= -1) then
			local bsize = C["Inventory"].ButtonSize
			local b = self:BagFrameSlotNew(fb, v)
			local xoff = 8

			xoff = xoff + (idx * bsize)
			xoff = xoff + (idx * 6)

			b.frame:ClearAllPoints()
			b.frame:SetPoint("LEFT", fb, "LEFT", xoff, 0)
			b.frame:SetSize(bsize, bsize)

			local btns = self.buttons
			b.frame:HookScript("OnEnter", function(self)
				local bag
				if isBank then
					bag = v
				else
					bag = v + 1
				end

				for _, val in ipairs(btns) do
					if val.bag == bag then
						val.frame:SetAlpha(1)
					else
						val.frame:SetAlpha(0.2)
					end
				end
			end)

			b.frame:HookScript("OnLeave", function(self)
				for _, btn in ipairs(btns) do
					btn.frame:SetAlpha(1)
				end
			end)

			b.frame:SetScript("OnClick", nil)

			idx = idx + 1
		end
	end

	for _, i in ipairs(bs) do
		local x = GetContainerNumSlots(i)
		if x > 0 then
			if not self.bags[i] then
				self.bags[i] = self:BagNew(i, f)
			end

			slots = slots + GetContainerNumSlots(i)
		end
	end

	rows = math_floor(slots / cols)
	if (slots % cols) ~= 0 then
		rows = rows + 1
	end

	f:SetWidth(cols * C["Inventory"].ButtonSize + (cols - 1) * C["Inventory"].ButtonSpace + 10 * 2)
	f:SetHeight(rows * C["Inventory"].ButtonSize + (rows - 1) * C["Inventory"].ButtonSpace + off + 10 * 2)

	local idx = 0
	for _, i in ipairs(bs) do
		local bag_cnt = GetContainerNumSlots(i)
		local specialType = select(2, GetContainerNumFreeSlots(i))
		if bag_cnt > 0 then
			self.bags[i] = self:BagNew(i, f)
			local bagType = self.bags[i].bagType

			self.bags[i]:Show()
			for j = 1, bag_cnt do
				local b, isnew = self:SlotNew(i, j)
				local xoff
				local yoff
				local x = (idx % cols)
				local y = math_floor(idx / cols)

				if isnew then
					table_insert(self.buttons, idx + 1, b)
				end

				xoff = 10 + (x * C["Inventory"].ButtonSize) + (x * C["Inventory"].ButtonSpace)
				yoff = off + 10 + (y * C["Inventory"].ButtonSize) + ((y) * C["Inventory"].ButtonSpace)
				yoff = yoff * -1

				b.frame:ClearAllPoints()
				b.frame:SetPoint("TOPLEFT", f, "TOPLEFT", xoff, yoff)
				b.frame:SetSize(C["Inventory"].ButtonSize, C["Inventory"].ButtonSize)
				b.frame.lock = false
				b.frame:SetAlpha(1)

				if bagType == ST_FISHBAG then
					b.frame:SetBackdropBorderColor(107/255, 150/255, 255/255) -- Tackle
					b.frame.lock = true
				elseif bagType == ST_SPECIAL then
					if specialType == 0x0008 then -- Leatherworking
						b.frame:SetBackdropBorderColor(224/255, 187/255, 74/255)
					elseif specialType == 0x0010 then -- Inscription
						b.frame:SetBackdropBorderColor(74/255, 77/255, 224/255)
					elseif specialType == 0x0020 then -- Herbs
						b.frame:SetBackdropBorderColor(18/255, 181/255, 32/255)
					elseif specialType == 0x0040 then -- Enchanting
						b.frame:SetBackdropBorderColor(194/255, 4/255, 204/255)
					elseif specialType == 0x0080 then -- Engineering
						b.frame:SetBackdropBorderColor(232/255, 118/255, 46/255)
					elseif specialType == 0x0200 then -- Gems
						b.frame:SetBackdropBorderColor(8/255, 180/255, 207/255)
					elseif specialType == 0x0400 then -- Mining
						b.frame:SetBackdropBorderColor(138/255, 103/255, 9/255)
					elseif specialType == 0x8000 then -- Fishing
						b.frame:SetBackdropBorderColor(107/255, 150/255, 255/255)
					elseif specialType == 0x10000 then -- Cooking
						b.frame:SetBackdropBorderColor(222/255, 13/255, 65/255)
					end
					b.frame.lock = true
				end

				self:SlotUpdate(b)
				idx = idx + 1
			end
		end
	end
end

function Stuffing:ADDON_LOADED(addon)
	if addon ~= "KkthnxUI" then
		return nil
	end

	self:RegisterEvent("BAG_UPDATE")
	self:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
	self:RegisterEvent("ITEM_LOCK_CHANGED")
	self:RegisterEvent("ITEM_UNLOCKED")
	self:RegisterEvent("BANKFRAME_OPENED")
	self:RegisterEvent("BANKFRAME_CLOSED")
	self:RegisterEvent("GUILDBANKFRAME_OPENED")
	self:RegisterEvent("GUILDBANKFRAME_CLOSED")
	self:RegisterEvent("PLAYERBANKSLOTS_CHANGED")
	self:RegisterEvent("PLAYERREAGENTBANKSLOTS_CHANGED")
	self:RegisterEvent("BAG_CLOSED")
	self:RegisterEvent("BAG_UPDATE_COOLDOWN")

	self:InitBags()

	table_insert(UISpecialFrames, "StuffingFrameBags")
	table_insert(UISpecialFrames, "StuffingFrameReagent")

	ToggleBackpack = Stuffing_Toggle
	ToggleBag = Stuffing_Toggle
	ToggleAllBags = Stuffing_Toggle
	OpenAllBags = Stuffing_Open
	OpenBackpack = Stuffing_Open
	CloseAllBags = Stuffing_Close
	CloseBackpack = Stuffing_Close

	BankFrame:UnregisterAllEvents()
	BankFrame:SetScale(0.0001)
	BankFrame:SetAlpha(0)
	BankFrame:SetPoint("TOPLEFT")

	function ManageBackpackTokenFrame() end

	if ContainerFrame5 then
		ContainerFrame5:EnableMouse(false)
	end
end

function Stuffing:PLAYER_ENTERING_WORLD()
	Stuffing:UnregisterEvent("PLAYER_ENTERING_WORLD")

	ToggleBackpack()
	ToggleBackpack()
end

function Stuffing:PLAYERBANKSLOTS_CHANGED(id)
	if id > 28 then
		for _, v in ipairs(self.bagframe_buttons) do
			if v.frame and v.frame.GetInventorySlot then
				BankFrameItemButton_Update(v.frame)
				BankFrameItemButton_UpdateLocked(v.frame)

				if not v.frame.tooltipText then
					v.frame.tooltipText = ""
				end
			end
		end
	end

	if self.bankFrame and self.bankFrame:IsShown() then
		self:BagSlotUpdate(-1)
	end
end

function Stuffing:PLAYERREAGENTBANKSLOTS_CHANGED()
	for i = 1, 98 do
		local button = _G["ReagentBankFrameItem" .. i]
		if not button then
			return
		end

		local _, _, _, quality = GetContainerItemInfo(-3, i)
		local clink = GetContainerItemLink(-3, i)
		button:SetBackdropBorderColor()

		if clink then
			if quality and quality > 1 then
				button:SetBackdropBorderColor(GetItemQualityColor(quality))
			end
		end
	end
end

function Stuffing:CURRENCY_DISPLAY_UPDATE()
	BackpackTokenFrame_Update()
end

function Stuffing:BAG_UPDATE(id)
	self:BagSlotUpdate(id)
end

function Stuffing:ITEM_LOCK_CHANGED(bag, slot)
	if slot == nil then
		return
	end

	for _, v in ipairs(self.buttons) do
		if v.bag == bag and v.slot == slot then
			self:SlotUpdate(v)
			break
		end
	end
end

function Stuffing:ITEM_UNLOCKED(bag, slot)
	if slot == nil then
		return
	end

	for _, v in ipairs(self.buttons) do
		if v.bag == bag and v.slot == slot then
			self:SlotUpdate(v)
			break
		end
	end
end

function Stuffing:BANKFRAME_OPENED()
	if not self.bankFrame then
		self:InitBank()
	end

	self:Layout(true)
	for _, x in ipairs(BAGS_BANK) do
		self:BagSlotUpdate(x)
	end

	self.bankFrame:Show()
	Stuffing_Open()
end

function Stuffing:BANKFRAME_CLOSED()
	if StuffingFrameReagent then
		StuffingFrameReagent:Hide()
	end

	if self.bankFrame then
		self.bankFrame:Hide()
	end
end

function Stuffing:GUILDBANKFRAME_OPENED()
	Stuffing_Open()

	if K.Name == "Upright" and K.Realm == "Sethraliss" then
		local guildSortbutton = CreateFrame("Button", "GuildSortButton", GuildBankFrame, "UIPanelButtonTemplate")
		guildSortbutton:SetSize(110, 20)
		guildSortbutton:SetPoint("RIGHT", GuildItemSearchBox, "LEFT", -5, 0)
		guildSortbutton:SetText("Sort Tab")
		guildSortbutton:SetScript("OnClick", function()
			ModuleSort:CommandDecorator(ModuleSort.SortBags, "guild")()
		end)
	end
end

function Stuffing:GUILDBANKFRAME_CLOSED()
	Stuffing_Close()
end

function Stuffing:BAG_CLOSED(id)
	local b = self.bags[id]
	if b then
		table_remove(self.bags, id)
		b:Hide()
		table_insert(trashBag, #trashBag + 1, b)
	end

	while true do
		local changed = false

		for i, v in ipairs(self.buttons) do
			if v.bag == id then
				v.frame:Hide()
				v.frame.lock = false

				table_insert(trashButton, #trashButton + 1, v.frame)
				table_remove(self.buttons, i)

				-- v = nil
				changed = true
			end
		end

		if not changed then
			break
		end
	end

	Stuffing_Close()
end

function Stuffing:BAG_UPDATE_COOLDOWN()
	for _, v in pairs(self.buttons) do
		self:UpdateCooldowns(v)
	end
end

function Stuffing:SCRAPPING_MACHINE_SHOW()
	for i = 0, #BAGS_BACKPACK - 1 do
		Stuffing:BAG_UPDATE(i)
	end
end

-- Kill Blizzard Functions
LootWonAlertFrame_OnClick = K.Noop
LootUpgradeFrame_OnClick = K.Noop
StorePurchaseAlertFrame_OnClick = K.Noop
LegendaryItemAlertFrame_OnClick = K.Noop