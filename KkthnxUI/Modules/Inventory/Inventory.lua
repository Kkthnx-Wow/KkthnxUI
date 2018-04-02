local K, C, L = unpack(select(2, ...))
local Unfit = LibStub("Unfit-1.0")
local Dialog = LibStub("LibDialog-1.0")
if C["Inventory"].Enable ~= true or K.CheckAddOnState("AdiBags") or K.CheckAddOnState("ArkInventory") or K.CheckAddOnState("cargBags_Nivaya")
or K.CheckAddOnState("cargBags") or K.CheckAddOnState("Bagnon") or K.CheckAddOnState("Combuctor") or K.CheckAddOnState("TBag") or K.CheckAddOnState("BaudBag") then
	return
end

-- Sorced (by Hungtar, editor Tukz then Kkthnx)

local _G = _G
local bit_band = bit.band
local math_floor = math.floor
local pairs = pairs
local print = print
local table_insert = tinsert

local ARTIFACT_POWER = _G.ARTIFACT_POWER
local BANK = _G.BANK
local C_NewItems_IsNewItem = _G.C_NewItems.IsNewItem
local CLOSE = _G.CLOSE
local CooldownFrame_Set = _G.CooldownFrame_Set
local ERR_NOT_IN_COMBAT = _G.ERR_NOT_IN_COMBAT
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
local InCombatLockdown = _G.InCombatLockdown
local IsArtifactPowerItem = _G.IsArtifactPowerItem
local IsBattlePayItem = _G.IsBattlePayItem
local IsShiftKeyDown = _G.IsShiftKeyDown
local LE_ITEM_QUALITY_POOR = _G.LE_ITEM_QUALITY_POOR
local NEW_ITEM_ATLAS_BY_QUALITY = _G.NEW_ITEM_ATLAS_BY_QUALITY
local PlaySound = _G.PlaySound
local PlaySoundKitID = _G.PlaySoundKitID
local SetItemButtonCount = _G.SetItemButtonCount
local SetItemButtonDesaturated = _G.SetItemButtonDesaturated
local SetItemButtonTexture = _G.SetItemButtonTexture
local SOUNDKIT = _G.SOUNDKIT
local Token1, Token2, Token3 = _G.BackpackTokenFrameToken1, _G.BackpackTokenFrameToken2, _G.BackpackTokenFrameToken3
local CreateFrame = _G.CreateFrame

-- GLOBALS: StuffingFrameBags, ReagentBankFrameItem1, ReagentBankFrame, BankFrame, ToggleBackpack, ToggleAllBags, OpenAllBags
-- GLOBALS: ToggleBag, IsContainerItemAnUpgrade

local BAGS_BACKPACK = {0, 1, 2, 3, 4}
local BAGS_BANK = {-1, 5, 6, 7, 8, 9, 10, 11}
local ST_NORMAL = 1
local ST_FISHBAG = 2
local ST_SPECIAL = 3
local bag_bars = 0

local Stuffing = CreateFrame("Frame", nil, UIParent)
Stuffing:RegisterEvent("ADDON_LOADED")
Stuffing:RegisterEvent("PLAYER_ENTERING_WORLD")
Stuffing:SetScript("OnEvent", function(self, event, ...)
	self[event](self, ...)
end)

local function Stuffing_OnShow()
	Stuffing:PLAYERBANKSLOTS_CHANGED(29)

	for i = 0, #BAGS_BACKPACK - 1 do
		Stuffing:BAG_UPDATE(i)
	end

	Stuffing:Layout()
	Stuffing:SearchReset()
	PlaySound(PlaySoundKitID and "igbackpackopen" or SOUNDKIT.IG_BACKPACK_OPEN)
end

local function StuffingBank_OnHide()
	CloseBankFrame()

	if Stuffing.frame:IsShown() then
		Stuffing.frame:Hide()
	end

	if bag_bars == 1 then
		bag_bars = 0
	end

	PlaySound(PlaySoundKitID and "igbackpackclose" or SOUNDKIT.IG_BACKPACK_CLOSE)
end

local function Stuffing_OnHide()
	if Stuffing.bankFrame and Stuffing.bankFrame:IsShown() then
		Stuffing.bankFrame:Hide()
	end

	if bag_bars == 1 then
		bag_bars = 0
	end

	PlaySound(PlaySoundKitID and "igbackpackclose" or SOUNDKIT.IG_BACKPACK_CLOSE)
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

-- Tooltip used for scanning
local scanner = CreateFrame("GameTooltip", "iLvlScanningTooltip", nil, "GameTooltipTemplate")
local scannerName = scanner:GetName()

-- Tooltip and scanning by Phanx @ http://www.wowinterface.com/forums/showthread.php?p=271406
local S_ITEM_LEVEL = "^"..gsub(_G.ITEM_LEVEL, "%%d", "(%%d+)")

local ItemDB = {}
local function IsRealItemLevel(link, owner, bag, slot)
	if ItemDB[link] then return ItemDB[link] end

	local realItemLevel

	scanner.owner = owner
	scanner:SetOwner(owner, "ANCHOR_NONE")
	scanner:SetBagItem(bag, slot)

	local line = _G[scannerName.."TextLeft2"]
	if line then
		local msg = line:GetText()
		if msg and string.find(msg, S_ITEM_LEVEL) then
			local itemLevel = string.match(msg, S_ITEM_LEVEL)
			if itemLevel and (tonumber(itemLevel) > 0) then
				realItemLevel = itemLevel
			end
		else
			-- Check line 3, some artifacts have the ilevel there
			line = _G[scannerName.."TextLeft3"]
			if line then
				local msg = line:GetText()
				if msg and string.find(msg, S_ITEM_LEVEL) then
					local itemLevel = string.match(msg, S_ITEM_LEVEL)
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

local function IsItemEligibleForItemLevelDisplay(classID, subClassID, equipLoc, rarity)
	if ((classID == 3 and subClassID == 11) -- Artifact Relics
	or (equipLoc ~= nil and equipLoc ~= "" and equipLoc ~= "INVTYPE_BAG" and equipLoc ~= "INVTYPE_QUIVER" and equipLoc ~= "INVTYPE_TABARD"))
	and (rarity and rarity > 1) then

		return true
	end

	return false
end

function Stuffing:SlotUpdate(b)
	local texture, count, locked, quality, _, _, _, _, noValue = GetContainerItemInfo(b.bag, b.slot)
	local clink = GetContainerItemLink(b.bag, b.slot)
	local IsNewItem = C_NewItems_IsNewItem(b.bag, b.slot)
	local isQuestItem, questId, isActiveQuest =	GetContainerItemQuestInfo(b.bag, b.slot)

	-- Set all slot color to default KkthnxUI on update
	if not b.frame.lock then
		b.frame:SetBackdropBorderColor(C["Media"].BorderColor[1], C["Media"].BorderColor[2], C["Media"].BorderColor[3], C["Media"].BorderColor[4])
	end

	if b.cooldown and StuffingFrameBags and StuffingFrameBags:IsShown() then
		local start, duration, enable = GetContainerItemCooldown(b.bag, b.slot)
		CooldownFrame_Set(b.cooldown, start, duration, enable)
	end

	if C["Inventory"].ItemLevel == true then
		b.frame.text:SetText("")
	end

	-- Pawn'ed thx Wetxius
	if (b.frame.UpgradeIcon) then
		b.frame.UpgradeIcon:ClearAllPoints()
		b.frame.UpgradeIcon:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\Inventory\\UpgradeIcon")
		b.frame.UpgradeIcon:SetPoint("BOTTOMRIGHT", 6, -3)
		b.frame.UpgradeIcon:SetSize(C["Inventory"].ButtonSize / 1.4, C["Inventory"].ButtonSize / 1.4)
		b.frame.UpgradeIcon:SetTexCoord(0, 1, 0, 1)
		local itemIsUpgrade = IsContainerItemAnUpgrade(b.frame:GetParent():GetID(), b.frame:GetID())
		if not itemIsUpgrade or itemIsUpgrade == nil then
			b.frame.UpgradeIcon:SetShown(false)
		else
			b.frame.UpgradeIcon:SetShown(itemIsUpgrade or true)
		end
	end

	-- New item code from Blizzard's ContainerFrame.lua
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
		-- Make sure that the textures are the same size as the itemframe.
		battlePayTexture:SetSize(b.frame:GetSize())
		newItemTexture:SetSize(b.frame:GetSize())
	end

	if (b.frame.JunkIcon and C["Inventory"].JunkIcon) then
		b.frame.JunkIcon:ClearAllPoints()
		b.frame.JunkIcon:SetPoint("BOTTOMRIGHT", -C["Inventory"].ButtonSize / 2, C["Inventory"].ButtonSize / 2)
		b.frame.JunkIcon:SetSize(C["Inventory"].ButtonSize / 1.8, C["Inventory"].ButtonSize / 1.8)
		b.frame.JunkIcon:SetShown(quality == LE_ITEM_QUALITY_POOR and not noValue)
	end

	-- Quest Item code from Blizzard"s ContainerFrame.lua
	local questTexture = _G[b.frame:GetName().."IconQuestTexture"]
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

	if clink then
		b.name, _, _, b.itemlevel, b.level, _, _, _, b.itemEquipLoc, _, _, b.itemClassID, b.itemSubClassID = GetItemInfo(clink)

		if b.itemlevel and C["Inventory"].ItemLevel and IsItemEligibleForItemLevelDisplay(b.itemClassID, b.itemSubClassID, b.itemEquipLoc, quality) then
			if (b.itemlevel >= C["Inventory"].ItemLevelThreshold) then
				b.itemlevel = IsRealItemLevel(clink, self, b.bag, b.slot) or b.itemlevel
				b.frame.text:SetText(b.itemlevel)
				b.frame.text:SetTextColor(GetItemQualityColor(quality))
			end
		end

		if (Unfit:IsItemUnusable(clink) or b.level and b.level > K.Level) and not locked then
			_G[b.frame:GetName().."IconTexture"]:SetVertexColor(1, 0.1, 0.1)
		else
			_G[b.frame:GetName().."IconTexture"]:SetVertexColor(1, 1, 1)
		end

		-- color slot according to item quality
		if questId and not isActiveQuest then
			b.frame:SetBackdropBorderColor(1, 1, 0)
		elseif questId or isQuestItem then
			b.frame:SetBackdropBorderColor(1, 1, 0)
		elseif not b.frame.lock and quality and quality > 1 and not (isQuestItem or questId) then
			b.frame:SetBackdropBorderColor(GetItemQualityColor(quality))
		else
			b.frame:SetBackdropBorderColor(C["Media"].BorderColor[1], C["Media"].BorderColor[2], C["Media"].BorderColor[3], C["Media"].BorderColor[4])
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

function CreateReagentContainer()
	ReagentBankFrame:StripTextures()

	local Reagent = CreateFrame("Frame", "StuffingFrameReagent", UIParent)
	local SwitchBankButton = CreateFrame("Button", nil, Reagent)
	local NumButtons = ReagentBankFrame.size
	local NumRows, LastRowButton, NumButtons, LastButton = 0, ReagentBankFrameItem1, 1, ReagentBankFrameItem1
	local Deposit = ReagentBankFrame.DespositButton

	Reagent:SetWidth(((C["Inventory"].ButtonSize + C["Inventory"].ButtonSpace) * C["Inventory"].BankColumns) + 17)
	Reagent:SetPoint("TOPLEFT", _G["StuffingFrameBank"], "TOPLEFT", 0, 0)
	Reagent:SetTemplate("Transparent", true)
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

	-- Stack Button
	SwitchBankButton:SetSize(16, 16)
	SwitchBankButton:SetTemplate("", true)
	SwitchBankButton:StyleButton(true)
	SwitchBankButton:SetPoint("TOPRIGHT", -54, -7)
	SwitchBankButton:SetNormalTexture("Interface\\ICONS\\achievement_guildperk_mobilebanking")
	SwitchBankButton:GetNormalTexture():SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
	SwitchBankButton:GetNormalTexture():SetAllPoints()
	SwitchBankButton:SetPushedTexture("Interface\\ICONS\\achievement_guildperk_mobilebanking")
	SwitchBankButton:GetPushedTexture():SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
	SwitchBankButton:GetPushedTexture():SetAllPoints()
	SwitchBankButton.ttText = BANK
	SwitchBankButton:SetScript("OnEnter", TooltipShow)
	SwitchBankButton:SetScript("OnLeave", TooltipHide)
	SwitchBankButton:SetScript("OnClick", function()
		Reagent:Hide()
		_G["StuffingFrameBank"]:Show()
		_G["StuffingFrameBank"]:SetAlpha(1)
		BankFrame_ShowPanel(BANK_PANELS[1].name)
		PlaySound(PlaySoundKitID and "igbackpackopen" or SOUNDKIT.IG_BACKPACK_OPEN)
	end)

	Deposit:SetParent(Reagent)
	Deposit:ClearAllPoints()
	Deposit:SetText("")
	Deposit:SetSize(16, 16)
	Deposit:SetTemplate("")
	Deposit:StyleButton(true)
	Deposit:SetPoint("TOPLEFT", SwitchBankButton, "TOPRIGHT", 6, 0)
	Deposit:SetNormalTexture("Interface\\ICONS\\misc_arrowdown")
	Deposit:GetNormalTexture():SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
	Deposit:GetNormalTexture():SetAllPoints()
	Deposit:SetPushedTexture("Interface\\ICONS\\misc_arrowdown")
	Deposit:GetPushedTexture():SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
	Deposit:GetPushedTexture():SetAllPoints()
	Deposit.ttText = REAGENTBANK_DEPOSIT
	Deposit:SetScript("OnEnter", TooltipShow)
	Deposit:SetScript("OnLeave", TooltipHide)
	Deposit:SetScript("OnClick", function()
		PlaySound(PlaySoundKitID and "Igmainmenuoption" or SOUNDKIT.IG_MAINMENU_OPTION)
		DepositReagentBank()
	end)

	-- Close button
	local Close = CreateFrame("Button", "StuffingCloseButtonReagent", Reagent, "UIPanelCloseButton")
	Close:SetPoint("TOPRIGHT", 0, 1)
	Close:SkinCloseButton()
	Close:RegisterForClicks("AnyUp")
	Close:SetScript("OnClick", function(self, btn)
		StuffingBank_OnHide()
	end)

	for i = 1, 98 do
		local button = _G["ReagentBankFrameItem"..i]
		local icon = _G[button:GetName().."IconTexture"]
		local count = _G[button:GetName().."Count"]

		ReagentBankFrame:SetParent(Reagent)
		ReagentBankFrame:ClearAllPoints()
		ReagentBankFrame:SetAllPoints()

		button:StyleButton()
		button:SetTemplate("Transparent", true)
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

		count:SetFont(C["Media"].Font, C["Media"].FontSize, C["Media"].FontStyle)
		count:SetShadowOffset(0, 0)
		count:SetPoint("BOTTOMRIGHT", 1, 1)

		LastButton = button
	end
	Reagent:SetHeight(((C["Inventory"].ButtonSize + C["Inventory"].ButtonSpace) * (NumRows + 1) + 40) - C["Inventory"].ButtonSpace)

	MoneyFrame_Update(ReagentBankFrame.UnlockInfo.CostMoneyFrame, GetReagentBankCost())
	ReagentBankFrameUnlockInfo:StripTextures()
	ReagentBankFrameUnlockInfo:SetAllPoints(Reagent)
	ReagentBankFrameUnlockInfo:SetTemplate("Transparent", true)
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
		ret.frame = CreateFrame("CheckButton", "StuffingBBag"..slot.."Slot", p, "BankItemButtonBagTemplate")
		ret.frame:StripTextures()
		ret.frame:SetID(slot)

		hooksecurefunc(ret.frame.IconBorder, "SetVertexColor", function(self, r, g, b)
			if r ~= 0.65882 and g ~= 0.65882 and b ~= 0.65882 then
				self:GetParent():SetBackdropBorderColor(r, g, b)
			end
			self:SetTexture("")
		end)

		hooksecurefunc(ret.frame.IconBorder, "Hide", function(self)
			self:GetParent():SetBackdropBorderColor(C["Media"].BorderColor[1], C["Media"].BorderColor[2], C["Media"].BorderColor[3], C["Media"].BorderColor[4])
		end)

		table.insert(self.bagframe_buttons, ret)

		BankFrameItemButton_Update(ret.frame)
		BankFrameItemButton_UpdateLocked(ret.frame)

		if not ret.frame.tooltipText then
			ret.frame.tooltipText = ""
		end
	else
		ret.frame = CreateFrame("CheckButton", "StuffingFBag"..slot.."Slot", p, "BagSlotButtonTemplate")

		hooksecurefunc(ret.frame.IconBorder, "SetVertexColor", function(self, r, g, b)
			if r ~= 0.65882 and g ~= 0.65882 and b ~= 0.65882 then
				self:GetParent():SetBackdropBorderColor(r, g, b)
			end
			self:SetTexture("")
		end)

		hooksecurefunc(ret.frame.IconBorder, "Hide", function(self)
			self:GetParent():SetBackdropBorderColor(C["Media"].BorderColor[1], C["Media"].BorderColor[2], C["Media"].BorderColor[3], C["Media"].BorderColor[4])
		end)

		ret.slot = slot
		table.insert(self.bagframe_buttons, ret)
	end

	ret.frame:SetTemplate("Transparent", true)
	ret.frame:StyleButton()
	ret.frame:SetNormalTexture("")
	ret.frame:SetCheckedTexture("")

	ret.icon = _G[ret.frame:GetName().."IconTexture"]
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
			table.remove(trashButton, f)
			ret.frame:Show()
		end
	end

	if not ret.frame then
		ret.frame = CreateFrame("Button", "StuffingBag"..bag.."_"..slot, self.bags[bag], tpl)
		ret.frame:StyleButton()
		ret.frame:SetTemplate("Transparent", true)
		ret.frame:SetNormalTexture(nil)

		ret.icon = _G[ret.frame:GetName().."IconTexture"]
		ret.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
		ret.icon:SetAllPoints()

		ret.count = _G[ret.frame:GetName().."Count"]
		ret.count:SetFont(C["Media"].Font, C["Media"].FontSize, C["Media"].FontStyle)
		ret.count:SetShadowOffset(0, 0)
		ret.count:SetPoint("BOTTOMRIGHT", 1, 1)

		if C["Inventory"].ItemLevel == true then
			ret.frame:FontString("text", C["Media"].Font, C["Media"].FontSize, C["Media"].FontStyle)
			ret.frame.text:SetPoint("TOPLEFT", 1, -1)
			ret.frame.text:SetShadowOffset(0, 0)
		end

		local Battlepay = _G[ret.frame:GetName()].BattlepayItemTexture
		if Battlepay then
			Battlepay:SetAlpha(0)
		end
	end

	ret.bag = bag
	ret.slot = slot
	ret.frame:SetID(slot)

	ret.cooldown = _G[ret.frame:GetName().."Cooldown"]
	ret.cooldown:Show()

	self:SlotUpdate(ret)

	return ret, true
end

-- From OneBag
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
	for i, v in pairs(self.bags) do
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
			table.remove(trashBag, f)
			ret:Show()
			ret.bagType = self:BagType(bag)
			return ret
		end
	end

	ret = CreateFrame("Frame", "StuffingBag"..bag, f)
	ret.bagType = self:BagType(bag)

	ret:SetID(bag)
	return ret
end

function Stuffing:SearchUpdate(str)
	str = string.lower(str)

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
			equipSlot = _G[equipSlot] or ""
			if not string.find(string.lower(b.name), str) and not string.find(string.lower(setName), str) and not string.find(string.lower(class), str) and not string.find(string.lower(subclass), str) and not string.find(string.lower(equipSlot), str) then
				if Unfit:IsItemUnusable(b.name) or minLevel > K.Level then
					_G[b.frame:GetName().."IconTexture"]:SetVertexColor(0.5, 0.5, 0.5)
				end
				SetItemButtonDesaturated(b.frame, true)
				b.frame:SetAlpha(0.2)
			else
				if Unfit:IsItemUnusable(b.name) or minLevel > K.Level then
					_G[b.frame:GetName().."IconTexture"]:SetVertexColor(1, 0.1, 0.1)
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
			_G[b.frame:GetName().."IconTexture"]:SetVertexColor(1, 0.1, 0.1)
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
	local n = "StuffingFrame"..w
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
		if GameTooltip:IsForbidden() then return end
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
		f:SetPoint("BOTTOMLEFT", "UIParent", "BOTTOMLEFT", 4, 204)
	else
		f:SetPoint("BOTTOMRIGHT", "UIParent", "BOTTOMRIGHT", -4, 204)
	end

	if w == "Bank" then
		-- Reagent button
		f.reagentToggle = CreateFrame("Button", "StuffingReagentButton"..w, f)
		f.reagentToggle:SetSize(16, 16)
		f.reagentToggle:SetTemplate()
		f.reagentToggle:SetPoint("TOPRIGHT", f, -32, -7)
		f.reagentToggle:SetNormalTexture("Interface\\ICONS\\INV_Enchant_DustArcane")
		f.reagentToggle:GetNormalTexture():SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
		f.reagentToggle:GetNormalTexture():SetAllPoints()
		f.reagentToggle:SetPushedTexture("Interface\\ICONS\\INV_Enchant_DustArcane")
		f.reagentToggle:GetPushedTexture():SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
		f.reagentToggle:GetPushedTexture():SetAllPoints()
		f.reagentToggle:StyleButton(nil, true)
		f.reagentToggle.ttText = "Show/Hide Reagents"
		f.reagentToggle:SetScript("OnEnter", TooltipShow)
		f.reagentToggle:SetScript("OnLeave", TooltipHide)
		f.reagentToggle:SetScript("OnClick", function()
			BankFrame_ShowPanel(BANK_PANELS[2].name)
			PlaySound(PlaySoundKitID and "igbackpackopen" or SOUNDKIT.IG_CHARACTER_INFO_TAB)
			if not ReagentBankFrame.isMade then
				CreateReagentContainer()
				ReagentBankFrame.isMade = true
			else
				_G["StuffingFrameReagent"]:Show()
			end
			_G["StuffingFrameBank"]:SetAlpha(0)
		end)

		-- Toggle Bags Button
		f.bagsButton = CreateFrame("Button", nil, f)
		f.bagsButton:SetSize(16, 16)
		f.bagsButton:SetTemplate("", true)
		f.bagsButton:SetPoint("RIGHT", f.reagentToggle, "LEFT", -5, 0)
		f.bagsButton:SetNormalTexture("Interface\\Buttons\\Button-Backpack-Up")
		f.bagsButton:GetNormalTexture():SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
		f.bagsButton:GetNormalTexture():SetAllPoints()
		f.bagsButton:SetPushedTexture("Interface\\Buttons\\Button-Backpack-Up")
		f.bagsButton:GetPushedTexture():SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
		f.bagsButton:GetPushedTexture():SetAllPoints()
		f.bagsButton:StyleButton(nil, true)
		f.bagsButton.ttText = L["Inventory"].Show_Bags
		f.bagsButton:SetScript("OnEnter", TooltipShow)
		f.bagsButton:SetScript("OnLeave", TooltipHide)
		f.bagsButton:SetScript("OnClick", function()
			PlaySound(PlaySoundKitID and "igMainMenuOption" or SOUNDKIT.IG_MAINMENU_OPTION)
			if bag_bars == 1 then
				bag_bars = 0
			else
				bag_bars = 1
			end
			if Stuffing.bankFrame and Stuffing.bankFrame:IsShown() then
				Stuffing:Layout(true)
			end
		end)


		-- Sort Button
		f.sortButton = CreateFrame("Button", nil, f)
		f.sortButton:SetSize(16, 16)
		f.sortButton:SetTemplate("", true)
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
		f.sortButton:SetScript("OnEnter", TooltipShow)
		f.sortButton:SetScript("OnLeave", TooltipHide)
		f.sortButton:SetScript("OnMouseUp", function(_, btn)
			if InCombatLockdown() then
				print("|cffffff00"..ERR_NOT_IN_COMBAT.."|r") return
			end
			if Stuffing.frame:IsShown() then
				local Module = K:GetModule("InventorySort")
				Module:CommandDecorator(Module.SortBags, "bank")()
			else
				SortReagentBankBags()
			end
		end)

		f.purchaseBagButton = CreateFrame("Button", "StuffingPurchaseButton"..w, f)
		f.purchaseBagButton:SetSize(16, 16)
		f.purchaseBagButton:SetTemplate()
		f.purchaseBagButton:SetPoint("RIGHT", f.sortButton, "LEFT", -5, 0)
		f.purchaseBagButton:SetNormalTexture("Interface\\ICONS\\INV_Misc_Coin_01")
		f.purchaseBagButton:GetNormalTexture():SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
		f.purchaseBagButton:GetNormalTexture():SetAllPoints()
		f.purchaseBagButton:SetPushedTexture("Interface\\ICONS\\INV_Misc_Coin_01")
		f.purchaseBagButton:GetPushedTexture():SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
		f.purchaseBagButton:GetPushedTexture():SetAllPoints()
		f.purchaseBagButton:StyleButton(nil, true)
		f.purchaseBagButton.ttText = L["Inventory"].Purchase_Slot
		f.purchaseBagButton:SetScript("OnEnter", TooltipShow)
		f.purchaseBagButton:SetScript("OnLeave", TooltipHide)
		f.purchaseBagButton:SetScript("OnClick", function()
			local _, full = GetNumBankSlots()
			if (full) then
				if Dialog:ActiveDialog("CANNOT_BUY_BANK_SLOT") then
					Dialog:Dismiss("CANNOT_BUY_BANK_SLOT")
				end
				Dialog:Spawn("CANNOT_BUY_BANK_SLOT")
			else
				if Dialog:ActiveDialog("BUY_BANK_SLOT") then
					Dialog:Dismiss("BUY_BANK_SLOT")
				end
				Dialog:Spawn("BUY_BANK_SLOT")
			end
		end)
	end

	-- Close button
	f.b_close = CreateFrame("Button", "StuffingCloseButton"..w, f, "UIPanelCloseButton")
	f.b_close:SetPoint("TOPRIGHT", 0, 1)
	f.b_close:SkinCloseButton()
	f.b_close:RegisterForClicks("AnyUp")
	f.b_close:SetScript("OnClick", function(self, btn)
		self:GetParent():Hide()
	end)

	-- Create the bags frame
	local fb = CreateFrame("Frame", n.."BagsFrame", f)
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
	if self.frame then return end

	self.buttons = {}
	self.bags = {}
	self.bagframe_buttons = {}

	local f = self:CreateBagFrame("Bags")
	f:SetScript("OnShow", Stuffing_OnShow)
	f:SetScript("OnHide", Stuffing_OnHide)

	-- Search editbox (tekKonfigAboutPanel.lua)
	local editbox = CreateFrame("EditBox", nil, f)
	editbox:Hide()
	editbox:SetAutoFocus(true)
	editbox:SetHeight(32)
	editbox:CreateBackdrop("Transparent")
	editbox.Backdrop:SetPoint("TOPLEFT", -2, 2)
	editbox.Backdrop:SetPoint("BOTTOMRIGHT", 2, -2)

	local resetAndClear = function(self)
		self:GetParent().detail:Show()
		self:GetParent().gold:Show()
		self:ClearFocus()
		Stuffing:SearchReset()
	end

	local updateSearch = function(self, t)
		if t == true then
			Stuffing:SearchUpdate(self:GetText())
		end
	end

	editbox:SetScript("OnEscapePressed", resetAndClear)
	editbox:SetScript("OnEnterPressed", resetAndClear)
	editbox:SetScript("OnEditFocusLost", editbox.Hide)
	editbox:SetScript("OnEditFocusGained", editbox.HighlightText)
	editbox:SetScript("OnTextChanged", updateSearch)

	local detail = f:CreateFontString(nil, "ARTWORK", "GameFontHighlightLarge")
	detail:SetPoint("TOPLEFT", f, 11, -10)
	detail:SetPoint("RIGHT", f, -140, -10)
	detail:SetHeight(14)
	detail:SetShadowColor(0, 0, 0, 0)
	detail:SetJustifyH("LEFT")
	detail:SetText(SEARCH)
	editbox:SetAllPoints(detail)

	local gold = f:CreateFontString(nil, "ARTWORK", "GameFontHighlightLarge")
	gold:SetJustifyH("RIGHT")

	f:SetScript("OnEvent", function(self, e)
		self.gold:SetText(K.FormatMoney(GetMoney(), 12))
	end)

	f:RegisterEvent("PLAYER_ENTERING_WORLD")
	f:RegisterEvent("PLAYER_MONEY")
	f:RegisterEvent("PLAYER_TRADE_MONEY")
	f:RegisterEvent("TRADE_MONEY_CHANGED")

	do
		Token3:ClearAllPoints()
		Token3:SetPoint("BOTTOM", f, "TOP", -70, 4)
		Token2:ClearAllPoints()
		Token2:SetPoint("LEFT", Token3, "RIGHT", 10, 0)
		Token1:ClearAllPoints()
		Token1:SetPoint("LEFT", Token2, "RIGHT", 10, 0)
	end

	for i = 1, 3 do
		local Token = _G["BackpackTokenFrameToken"..i]
		local Icon = _G["BackpackTokenFrameToken"..i.."Icon"]
		local Count = _G["BackpackTokenFrameToken"..i.."Count"]

		Token:SetParent(f)
		Token:SetScale(1)
		Token:CreateBackdrop("", true)
		Token.Backdrop:SetAllPoints(Icon)

		Icon:SetSize(12, 12)
		Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
		Icon:SetPoint("LEFT", Token, "RIGHT", -8, 2)

		Count:SetFont(C.Media.Font, 12, "OUTLINE")
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
			self:GetParent().gold:Hide()
			self:GetParent().editbox:Show()
			self:GetParent().editbox:HighlightText()
		else
			if self:GetParent().editbox:IsShown() then
				self:GetParent().editbox:Hide()
				self:GetParent().editbox:ClearFocus()
				self:GetParent().detail:Show()
				self:GetParent().gold:Show()
				Stuffing:SearchReset()
			end
		end
	end)

	function TooltipHide()
		if not GameTooltip:IsForbidden() then
			GameTooltip:Hide()
		end
	end

	function TooltipShow(self)
		if GameTooltip:IsForbidden() then
			return
		end

		GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", -12, 11)
		GameTooltip:ClearLines()
		GameTooltip:SetText(self.ttText)
	end

	button:SetScript("OnEnter", TooltipShow)
	button:SetScript("OnLeave", TooltipHide)

	---- Stack Button
	--f.restackButton = CreateFrame("Button", nil, f)
	--f.restackButton:SetSize(16, 16)
	--f.restackButton:SetTemplate("")
	--f.restackButton:StyleButton(true)
	--f.restackButton:SetPoint("TOPRIGHT", f, -32, -7)
	--f.restackButton:SetNormalTexture("Interface\\ICONS\\misc_arrowdown")
	--f.restackButton:GetNormalTexture():SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
	--f.restackButton:GetNormalTexture():SetAllPoints()
	--f.restackButton:SetPushedTexture("Interface\\ICONS\\misc_arrowdown")
	--f.restackButton:GetPushedTexture():SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
	--f.restackButton:GetPushedTexture():SetAllPoints()
	--f.restackButton.ttText = L["Inventory"].Buttons_Stack
	--f.restackButton:SetScript("OnEnter", TooltipShow)
	--f.restackButton:SetScript("OnLeave", TooltipHide)
	--f.restackButton:SetScript("OnClick", function()
	--	if InCombatLockdown() then
	--		print("|cffffff00"..ERR_NOT_IN_COMBAT.."|r") return
	--	end
	--	PlaySound(PlaySoundKitID and "igMainMenuOption" or SOUNDKIT.IG_MAINMENU_OPTION)
	--	local Module = K:GetModule("InventorySort")
	--	if IsShiftKeyDown() then
	--		Module:CommandDecorator(Module.Stack, "bags")()
	--	else
	--		Module:CommandDecorator(Module.Compress, "bank")()
	--	end
	--end)

	-- Toggle Bags Button
	f.bagsButton = CreateFrame("Button", nil, f)
	f.bagsButton:SetSize(16, 16)
	f.bagsButton:SetTemplate("", true)
	f.bagsButton:SetPoint("TOPRIGHT", f, -32, -7)
	f.bagsButton:SetNormalTexture("Interface\\Buttons\\Button-Backpack-Up")
	f.bagsButton:GetNormalTexture():SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
	f.bagsButton:GetNormalTexture():SetAllPoints()
	f.bagsButton:SetPushedTexture("Interface\\Buttons\\Button-Backpack-Up")
	f.bagsButton:GetPushedTexture():SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
	f.bagsButton:GetPushedTexture():SetAllPoints()
	f.bagsButton:StyleButton(nil, true)
	f.bagsButton.ttText = L["Inventory"].Show_Bags
	f.bagsButton:SetScript("OnEnter", TooltipShow)
	f.bagsButton:SetScript("OnLeave", TooltipHide)
	f.bagsButton:SetScript("OnClick", function()
		PlaySound(PlaySoundKitID and "igMainMenuOption" or SOUNDKIT.IG_MAINMENU_OPTION)
		if bag_bars == 1 then
			bag_bars = 0
		else
			bag_bars = 1
		end
		if Stuffing.frame and Stuffing.frame:IsShown() then
			Stuffing:Layout()
		end
	end)

	-- Sort Button
	f.sortButton = CreateFrame("Button", nil, f)
	f.sortButton:SetSize(16, 16)
	f.sortButton:SetTemplate("", true)
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
	f.sortButton:SetScript("OnEnter", TooltipShow)
	f.sortButton:SetScript("OnLeave", TooltipHide)
	f.sortButton:SetScript("OnMouseUp", function(_, btn)
		if InCombatLockdown() then
			print("|cffffff00"..ERR_NOT_IN_COMBAT.."|r") return
		end
		local Module = K:GetModule("InventorySort")
		Module:CommandDecorator(Module.SortBags, "bags")()
	end)

	if K.Level >= 100 then
		-- Artifact Button
		f.ArtifactButton = CreateFrame("Button", nil, f, "BankItemButtonGenericTemplate")
		f.ArtifactButton:SetSize(16, 16)
		f.ArtifactButton:SetTemplate("", true)
		f.ArtifactButton:StyleButton(true)
		f.ArtifactButton:SetPoint("TOPRIGHT", f.sortButton, -22, 0)
		f.ArtifactButton:SetNormalTexture("Interface\\ICONS\\Achievement_doublejeopardy")
		f.ArtifactButton:GetNormalTexture():SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
		f.ArtifactButton:GetNormalTexture():SetAllPoints()
		f.ArtifactButton:SetPushedTexture("Interface\\ICONS\\Achievement_doublejeopardy")
		f.ArtifactButton:GetPushedTexture():SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
		f.ArtifactButton:GetPushedTexture():SetAllPoints()
		f.ArtifactButton:SetDisabledTexture("Interface\\ICONS\\Achievement_doublejeopardy")
		f.ArtifactButton:GetDisabledTexture():SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
		f.ArtifactButton:GetDisabledTexture():SetAllPoints()
		f.ArtifactButton:GetDisabledTexture():SetDesaturated(1)
		f.ArtifactButton:RegisterForClicks("RightButtonUp")
		--f.ArtifactButton.ttText = L["Inventory"].Buttons_Artifact
		--f.ArtifactButton:SetScript("OnEnter", TooltipShow)
		f.ArtifactButton:SetScript("OnLeave", TooltipHide)
		f.ArtifactButton:SetScript("PreClick", function(self)
			for bag = 0, 4 do
				for slot = 1, GetContainerNumSlots(bag) do
					if IsArtifactPowerItem(GetContainerItemID(bag, slot)) then
						self:GetParent():SetID(bag)
						self:SetID(slot)
						return
					end
				end
			end
		end)
		f.ArtifactButton:SetScript("OnEnter", function(self)
			self:UpdateTooltip()
		end)
		f.ArtifactButton:HookScript("OnClick", function(self)
			if GameTooltip:IsForbidden() then
				return
			end
			if GameTooltip:GetOwner() == self then
				self:UpdateTooltip()
			end
		end)
		f.ArtifactButton.UpdateTooltip = function(self)
			if GameTooltip:IsForbidden() then
				return
			end

			local count = 0
			for bag = 0, 4 do
				for slot = 1, GetContainerNumSlots(bag) do
					if IsArtifactPowerItem(GetContainerItemID(bag, slot)) then
						count = count + 1
					end
				end
			end

			GameTooltip:SetOwner(self, "ANCHOR_LEFT")
			GameTooltip:AddLine(ARTIFACT_POWER..": "..count)
			GameTooltip:AddLine(L["Inventory"].Artifact_Use)
			GameTooltip:Show()
		end
	end

	if K.Level >= 100 then
		gold:SetPoint("RIGHT", f.ArtifactButton, "LEFT", -8, 0)
	else
		gold:SetPoint("RIGHT", f.sortButton, "LEFT", -8, 0)
	end

	f.editbox = editbox
	f.detail = detail
	f.button = button
	f.gold = gold
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

		f.editbox:SetFont(C["Media"].Font, C["Media"].FontSize)

		f.detail:SetFont(C["Media"].Font, C["Media"].FontSize, C["Media"].FontStyle)
		f.detail:SetShadowOffset(0, 0)

		f.gold:SetText(K.FormatMoney(GetMoney(), 12))
		f.gold:SetFont(C["Media"].Font, C["Media"].FontSize, C["Media"].FontStyle)
		f.gold:SetShadowOffset(0, 0)

		f.detail:ClearAllPoints()
		f.detail:SetPoint("TOPLEFT", f, 12, -8)
		f.detail:SetPoint("RIGHT", f, -140, 0)
	end

	f:SetClampedToScreen(1)
	f:SetTemplate("Transparent", true)

	-- Bag frame stuff
	local fb = f.bags_frame
	if bag_bars == 1 then
		fb:SetClampedToScreen(1)
		fb:SetTemplate("Transparent", true)

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
		if (not isBank and v <= 3 ) or (isBank and v ~= -1) then
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
				if isBank then bag = v else bag = v + 1 end

				for ind, val in ipairs(btns) do
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
					table.insert(self.buttons, idx + 1, b)
				end

				xoff = 10 + (x * C["Inventory"].ButtonSize) + (x * C["Inventory"].ButtonSpace)
				yoff = off + 10 + (y * C["Inventory"].ButtonSize) + ((y) * C["Inventory"].ButtonSpace) -- Don"t forget you changed this Kkthnx!
				yoff = yoff * -1

				b.frame:ClearAllPoints()
				b.frame:SetPoint("TOPLEFT", f, "TOPLEFT", xoff, yoff)
				b.frame:SetSize(C["Inventory"].ButtonSize, C["Inventory"].ButtonSize)
				b.frame.lock = false
				b.frame:SetAlpha(1)

				if bagType == ST_FISHBAG then
					b.frame:SetBackdropBorderColor(1, 0, 0)	-- Tackle
					b.frame.lock = true
				elseif bagType == ST_SPECIAL then
					if specialType == 0x0008 then			-- Leatherworking
						b.frame:SetBackdropBorderColor(0.8, 0.7, 0.3)
					elseif specialType == 0x0010 then		-- Inscription
						b.frame:SetBackdropBorderColor(0.3, 0.3, 0.8)
					elseif specialType == 0x0020 then		-- Herbs
						b.frame:SetBackdropBorderColor(0.3, 0.7, 0.3)
					elseif specialType == 0x0040 then		-- Enchanting
						b.frame:SetBackdropBorderColor(0.6, 0, 0.6)
					elseif specialType == 0x0080 then		-- Engineering
						b.frame:SetBackdropBorderColor(0.9, 0.4, 0.1)
					elseif specialType == 0x0200 then		-- Gems
						b.frame:SetBackdropBorderColor(0, 0.7, 0.8)
					elseif specialType == 0x0400 then		-- Mining
						b.frame:SetBackdropBorderColor(0.4, 0.3, 0.1)
					elseif specialType == 0x10000 then		-- Cooking
						b.frame:SetBackdropBorderColor(0.9, 0, 0.1)
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
	self:RegisterEvent("ITEM_LOCK_CHANGED")
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
end

function Stuffing:PLAYER_ENTERING_WORLD()
	Stuffing:UnregisterEvent("PLAYER_ENTERING_WORLD")
	ToggleBackpack()
	ToggleBackpack()
	function ManageBackpackTokenFrame() end
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
		local button = _G["ReagentBankFrameItem"..i]
		if not button then return end
		local _, _, _, quality = GetContainerItemInfo(-3, i)
		local clink = GetContainerItemLink(-3, i)
		button:SetBackdropBorderColor(C["Media"].BorderColor[1], C["Media"].BorderColor[2], C["Media"].BorderColor[3], C["Media"].BorderColor[4])

		if clink then
			if quality and quality > 1 then
				button:SetBackdropBorderColor(GetItemQualityColor(quality))
			end
		end
	end
end

function Stuffing:BAG_UPDATE(id)
	self:BagSlotUpdate(id)
end

function Stuffing:ITEM_LOCK_CHANGED(bag, slot)
	if slot == nil then return end
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

	-- -- Sort Button
	-- guildSortButton = CreateFrame("Button", "GuildSortButton", GuildBankFrame, "UIPanelButtonTemplate")
	-- guildSortButton:SetSize(16, 16)
	-- guildSortButton:SetTemplate("", true)
	-- guildSortButton:StyleButton(true)
	-- guildSortButton:SetPoint("RIGHT", GuildBankFrame.CloseButton, "LEFT", 2, 0)
	-- guildSortButton:SetNormalTexture("Interface\\ICONS\\INV_Pet_Broom")
	-- guildSortButton:GetNormalTexture():SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
	-- guildSortButton:GetNormalTexture():SetAllPoints()
	-- guildSortButton:SetPushedTexture("Interface\\ICONS\\INV_Pet_Broom")
	-- guildSortButton:GetPushedTexture():SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
	-- guildSortButton:GetPushedTexture():SetAllPoints()
	-- guildSortButton:SetDisabledTexture("Interface\\ICONS\\INV_Pet_Broom")
	-- guildSortButton:GetDisabledTexture():SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
	-- guildSortButton:GetDisabledTexture():SetAllPoints()
	-- guildSortButton:GetDisabledTexture():SetDesaturated(1)
	-- guildSortButton.ttText = BAG_FILTER_CLEANUP
	-- guildSortButton:SetScript("OnEnter", TooltipShow)
	-- guildSortButton:SetScript("OnLeave", TooltipHide)
	-- guildSortButton:SetScript("OnMouseUp", function(_, btn)
	-- 	if InCombatLockdown() then
	-- 		print("|cffffff00"..ERR_NOT_IN_COMBAT.."|r") return
	-- 	end
	-- 	if Stuffing.frame:IsShown() then
	-- 		local Module = K:GetModule("InventorySort")
	-- 		Module:CommandDecorator(Module.SortBags, "guild")()
	-- 	end
	-- end)
end

function Stuffing:GUILDBANKFRAME_CLOSED()
	Stuffing_Close()
end

function Stuffing:BAG_CLOSED(id)
	local b = self.bags[id]
	if b then
		table.remove(self.bags, id)
		b:Hide()
		table.insert(trashBag, #trashBag + 1, b)
	end

	while true do
		local changed = false

		for i, v in ipairs(self.buttons) do
			if v.bag == id then
				v.frame:Hide()
				v.frame.lock = false

				table.insert(trashButton, #trashButton + 1, v.frame)
				table.remove(self.buttons, i)

				v = nil
				changed = true
			end
		end

		if not changed then
			break
		end
	end
end

function Stuffing:BAG_UPDATE_COOLDOWN()
	for i, v in pairs(self.buttons) do
		self:UpdateCooldowns(v)
	end
end