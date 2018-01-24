local K, C, L = unpack(select(2, ...))
if C["Inventory"].Enable ~= true then return end
local LibButtonGlow = LibStub("LibButtonGlow-1.0", true)

-- Sorced (by Hungtar, editor Tukz then Kkthnx)

local _G = _G
local pairs = pairs
local print = print

local BAG_FILTER_CLEANUP = _G.BAG_FILTER_CLEANUP
local CLOSE = _G.CLOSE
local ERR_NOT_IN_COMBAT = _G.ERR_NOT_IN_COMBAT
local GetContainerItemInfo = _G.GetContainerItemInfo
local GetItemInfo = _G.GetItemInfo
local GetNumBankSlots = _G.GetNumBankSlots
local InCombatLockdown = _G.InCombatLockdown
local PickupContainerItem = PickupContainerItem
local SortBags = SortBags
local SortBankBags = SortBankBags
local SortReagentBankBags = SortReagentBankBags
local PlaySound = _G.PlaySound
local Token1, Token2, Token3 = _G.BackpackTokenFrameToken1, _G.BackpackTokenFrameToken2, _G.BackpackTokenFrameToken3

local BAGS_BACKPACK = {0, 1, 2, 3, 4}
local BAGS_BANK = {-1, 5, 6, 7, 8, 9, 10, 11}
local ST_NORMAL = 1
local ST_FISHBAG = 2
local ST_SPECIAL = 3
local bag_bars = 0
local unusable

if K.Class == "DEATHKNIGHT" then
	unusable = {{LE_ITEM_WEAPON_BOWS, LE_ITEM_WEAPON_GUNS, LE_ITEM_WEAPON_WARGLAIVE, LE_ITEM_WEAPON_STAFF, LE_ITEM_WEAPON_UNARMED, LE_ITEM_WEAPON_DAGGER, LE_ITEM_WEAPON_THROWN, LE_ITEM_WEAPON_CROSSBOW, LE_ITEM_WEAPON_WAND}, {LE_ITEM_ARMOR_SHIELD}} -- weapons, armor, dual wield
elseif K.Class == "DEMONHUNTER" then
	unusable = {{LE_ITEM_WEAPON_AXE2H, LE_ITEM_WEAPON_BOWS, LE_ITEM_WEAPON_GUNS, LE_ITEM_WEAPON_MACE2H, LE_ITEM_WEAPON_POLEARM, LE_ITEM_WEAPON_SWORD2H, LE_ITEM_WEAPON_STAFF, LE_ITEM_WEAPON_THROWN, LE_ITEM_WEAPON_CROSSBOW, LE_ITEM_WEAPON_WAND}, {LE_ITEM_ARMOR_MAIL, LE_ITEM_ARMOR_PLATE, LE_ITEM_ARMOR_SHIELD}}
elseif K.Class == "DRUID" then
	unusable = {{LE_ITEM_WEAPON_AXE1H, LE_ITEM_WEAPON_AXE2H, LE_ITEM_WEAPON_BOWS, LE_ITEM_WEAPON_GUNS, LE_ITEM_WEAPON_SWORD1H, LE_ITEM_WEAPON_SWORD2H, LE_ITEM_WEAPON_WARGLAIVE, LE_ITEM_WEAPON_THROWN, LE_ITEM_WEAPON_CROSSBOW, LE_ITEM_WEAPON_WAND}, {LE_ITEM_ARMOR_MAIL, LE_ITEM_ARMOR_PLATE, LE_ITEM_ARMOR_SHIELD}, true}
elseif K.Class == "HUNTER" then
	unusable = {{LE_ITEM_WEAPON_MACE1H, LE_ITEM_WEAPON_MACE2H, LE_ITEM_WEAPON_WARGLAIVE, LE_ITEM_WEAPON_THROWN, LE_ITEM_WEAPON_WAND}, {LE_ITEM_ARMOR_PLATE, LE_ITEM_ARMOR_SHIELD}}
elseif K.Class == "MAGE" then
	unusable = {{LE_ITEM_WEAPON_AXE1H, LE_ITEM_WEAPON_AXE2H, LE_ITEM_WEAPON_BOWS, LE_ITEM_WEAPON_GUNS, LE_ITEM_WEAPON_MACE1H, LE_ITEM_WEAPON_MACE2H, LE_ITEM_WEAPON_POLEARM, LE_ITEM_WEAPON_SWORD2H, LE_ITEM_WEAPON_WARGLAIVE, LE_ITEM_WEAPON_UNARMED, LE_ITEM_WEAPON_THROWN, LE_ITEM_WEAPON_CROSSBOW}, {LE_ITEM_ARMOR_LEATHER, LE_ITEM_ARMOR_MAIL, LE_ITEM_ARMOR_PLATE, LE_ITEM_ARMOR_SHIELD,}, true}
elseif K.Class == "MONK" then
	unusable = {{LE_ITEM_WEAPON_AXE2H, LE_ITEM_WEAPON_BOWS, LE_ITEM_WEAPON_GUNS, LE_ITEM_WEAPON_MACE2H, LE_ITEM_WEAPON_SWORD2H, LE_ITEM_WEAPON_WARGLAIVE, LE_ITEM_WEAPON_DAGGER, LE_ITEM_WEAPON_THROWN, LE_ITEM_WEAPON_CROSSBOW, LE_ITEM_WEAPON_WAND}, {LE_ITEM_ARMOR_MAIL, LE_ITEM_ARMOR_PLATE, LE_ITEM_ARMOR_SHIELD}}
elseif K.Class == "PALADIN" then
	unusable = {{LE_ITEM_WEAPON_BOWS, LE_ITEM_WEAPON_GUNS, LE_ITEM_WEAPON_WARGLAIVE, LE_ITEM_WEAPON_STAFF, LE_ITEM_WEAPON_UNARMED, LE_ITEM_WEAPON_DAGGER, LE_ITEM_WEAPON_THROWN, LE_ITEM_WEAPON_CROSSBOW, LE_ITEM_WEAPON_WAND}, {}, true}
elseif K.Class == "PRIEST" then
	unusable = {{LE_ITEM_WEAPON_AXE1H, LE_ITEM_WEAPON_AXE2H, LE_ITEM_WEAPON_BOWS, LE_ITEM_WEAPON_GUNS, LE_ITEM_WEAPON_MACE2H, LE_ITEM_WEAPON_POLEARM, LE_ITEM_WEAPON_SWORD1H, LE_ITEM_WEAPON_SWORD2H, LE_ITEM_WEAPON_WARGLAIVE, LE_ITEM_WEAPON_UNARMED, LE_ITEM_WEAPON_THROWN, LE_ITEM_WEAPON_CROSSBOW}, {LE_ITEM_ARMOR_LEATHER, LE_ITEM_ARMOR_MAIL, LE_ITEM_ARMOR_PLATE, LE_ITEM_ARMOR_SHIELD}, true}
elseif K.Class == "ROGUE" then
	unusable = {{LE_ITEM_WEAPON_AXE2H, LE_ITEM_WEAPON_MACE2H, LE_ITEM_WEAPON_POLEARM, LE_ITEM_WEAPON_SWORD2H, LE_ITEM_WEAPON_WARGLAIVE, LE_ITEM_WEAPON_STAFF, LE_ITEM_WEAPON_WAND}, {LE_ITEM_ARMOR_MAIL, LE_ITEM_ARMOR_PLATE, LE_ITEM_ARMOR_SHIELD}}
elseif K.Class == "SHAMAN" then
	unusable = {{LE_ITEM_WEAPON_BOWS, LE_ITEM_WEAPON_GUNS, LE_ITEM_WEAPON_POLEARM, LE_ITEM_WEAPON_SWORD1H, LE_ITEM_WEAPON_SWORD2H, LE_ITEM_WEAPON_WARGLAIVE, LE_ITEM_WEAPON_THROWN, LE_ITEM_WEAPON_CROSSBOW, LE_ITEM_WEAPON_WAND}, {LE_ITEM_ARMOR_PLATEM}}
elseif K.Class == "WARLOCK" then
	unusable = {{LE_ITEM_WEAPON_AXE1H, LE_ITEM_WEAPON_AXE2H, LE_ITEM_WEAPON_BOWS, LE_ITEM_WEAPON_GUNS, LE_ITEM_WEAPON_MACE1H, LE_ITEM_WEAPON_MACE2H, LE_ITEM_WEAPON_POLEARM, LE_ITEM_WEAPON_SWORD2H, LE_ITEM_WEAPON_WARGLAIVE, LE_ITEM_WEAPON_UNARMED, LE_ITEM_WEAPON_THROWN, LE_ITEM_WEAPON_CROSSBOW}, {LE_ITEM_ARMOR_LEATHER, LE_ITEM_ARMOR_MAIL, LE_ITEM_ARMOR_PLATE, LE_ITEM_ARMOR_SHIELD}, true}
elseif K.Class == "WARRIOR" then
	unusable = {{LE_ITEM_WEAPON_WARGLAIVE, LE_ITEM_WEAPON_WAND}, {}}
else
	unusable = {{}, {}}
end

local subs = {}
for k = 0, 20 do
	subs[k + 1] = GetItemSubClassInfo(LE_ITEM_CLASS_WEAPON, k)
end

for i, subclass in ipairs(unusable[1]) do
	unusable[subs[subclass+1]] = true
end

subs = {}
for k = 0, 11 do
	subs[k + 1] = GetItemSubClassInfo(LE_ITEM_CLASS_ARMOR, k)
end

for i, subclass in ipairs(unusable[2]) do
	unusable[subs[subclass + 1]] = true
end


local function IsClassUnusable(subclass, slot)
	if subclass then
		return slot ~= "" and unusable[subclass] or slot == "INVTYPE_WEAPONOFFHAND" and unusable[3]
	end
end

local function IsItemUnusable(...)
	if ... then
		local subclass, _, slot = select(7, GetItemInfo(...))
		return IsClassUnusable(subclass, slot)
	end
end

Stuffing = CreateFrame("Frame", nil, UIParent)
Stuffing:RegisterEvent("ADDON_LOADED")
Stuffing:RegisterEvent("PLAYER_ENTERING_WORLD")
Stuffing:SetScript("OnEvent", function(this, event, ...)
	if IsAddOnLoaded("AdiBags") or IsAddOnLoaded("ArkInventory") or IsAddOnLoaded("cargBags_Nivaya") or IsAddOnLoaded("cargBags") or IsAddOnLoaded("Bagnon") or IsAddOnLoaded("Combuctor") or IsAddOnLoaded("TBag") or IsAddOnLoaded("BaudBag") then return end
	Stuffing[event](this, ...)
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
	PlaySound(PlaySoundKitID and "igbackpackclose" or SOUNDKIT.IG_BACKPACK_CLOSE)
end

local function Stuffing_OnHide()
	if Stuffing.bankFrame and Stuffing.bankFrame:IsShown() then
		Stuffing.bankFrame:Hide()
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
local ItemDB = {}

-- Tooltip and scanning by Phanx @ http://www.wowinterface.com/forums/showthread.php?p=271406
local S_ITEM_LEVEL = "^" .. gsub(_G.ITEM_LEVEL, "%%d", "(%%d+)")

local scantip = CreateFrame("GameTooltip", "iLvlScanningTooltip", nil, "GameTooltipTemplate")
scantip:SetOwner(UIParent, "ANCHOR_NONE")

local function _getRealItemLevel(link)
	if ItemDB[link] then return ItemDB[link] end

	local realItemLevel
	scantip:SetHyperlink(link)

	for i = 2, scantip:NumLines() do -- Line 1 is always the name so you can skip it.
		local text = _G["iLvlScanningTooltipTextLeft"..i]:GetText()
		if text and text ~= "" then
			realItemLevel = realItemLevel or strmatch(text, S_ITEM_LEVEL)

			if realItemLevel then
				ItemDB[link] = tonumber(realItemLevel)
				return tonumber(realItemLevel)
			end
		end
	end

	return realItemLevel
end

function Stuffing:SlotUpdate(b)
	local texture, count, locked, quality, _, _, _, _, noValue = GetContainerItemInfo(b.bag, b.slot)
	local clink = GetContainerItemLink(b.bag, b.slot)
	local isQuestItem, questId, isActiveQuest = GetContainerItemQuestInfo(b.bag, b.slot)
	local IsNewItem = C_NewItems.IsNewItem(b.frame:GetParent():GetID(), b.frame:GetID())

	if (b.frame.questIcon) then
		b.frame.questIcon:Hide()
	end

	-- New Item Overlay
	if (IsNewItem) and C["Inventory"].PulseNewItem == true then
		LibButtonGlow.ShowOverlayGlow(b.frame)
	else
		LibButtonGlow.HideOverlayGlow(b.frame)
	end

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

	-- Pawn"ed thx Wetxius
	if (b.frame.UpgradeIcon) then
		b.frame.UpgradeIcon:SetPoint("TOPLEFT", C["Inventory"].ButtonSize / 2.4, -C["Inventory"].ButtonSize / 2.4)
		b.frame.UpgradeIcon:SetSize(C["Inventory"].ButtonSize / 1.6, C["Inventory"].ButtonSize / 1.6)
		local itemIsUpgrade = IsContainerItemAnUpgrade(b.frame:GetParent():GetID(), b.frame:GetID())
		if itemIsUpgrade and itemIsUpgrade == true then
			b.frame.UpgradeIcon:SetShown(true)
		else
			b.frame.UpgradeIcon:SetShown(false)
		end
	end

	if (b.frame.JunkIcon) then
		b.frame.JunkIcon:ClearAllPoints()
		b.frame.JunkIcon:SetPoint("BOTTOMRIGHT", -C["Inventory"].ButtonSize / 2, C["Inventory"].ButtonSize / 2)
		b.frame.JunkIcon:SetSize(C["Inventory"].ButtonSize / 1.8, C["Inventory"].ButtonSize / 1.8)
		if (quality) and (quality == LE_ITEM_QUALITY_POOR and not noValue) then
			b.frame.JunkIcon:Show();
		else
			b.frame.JunkIcon:Hide()
		end
	end

	if (clink) then
		b.name, _, _, b.itemlevel, b.level, _, _, _, _, _, _, b.itemClassID, b.itemSubClassID = GetItemInfo(clink)

		if C["Inventory"].ItemLevel == true and b.itemlevel and quality > 1 and (b.itemClassID == 2 or b.itemClassID == 4 or (b.itemClassID == 3 and b.itemSubClassID == 11)) then
			b.itemlevel = _getRealItemLevel(clink) or b.itemlevel
			b.frame.text:SetText(b.itemlevel)
			b.frame.text:SetTextColor(GetItemQualityColor(quality))
		end

		if (IsItemUnusable(clink) or b.level and b.level > K.Level) and not locked then
			_G[b.frame:GetName().."IconTexture"]:SetVertexColor(1, 0.1, 0.1)
		else
			_G[b.frame:GetName().."IconTexture"]:SetVertexColor(1, 1, 1)
		end

		-- Color slot according to item quality
		if not b.frame.lock and quality and quality > 1 and not (isQuestItem or questId) then
			b.frame:SetBackdropBorderColor(GetItemQualityColor(quality))
		elseif questId and not isActiveQuest then
			b.frame:SetBackdropBorderColor(1, 1, 0)
			if (b.frame.questIcon) then
				b.frame.questIcon:Show()
			end
		elseif isQuestItem or questId then
			b.frame:SetBackdropBorderColor(1, 1, 0)
			if (b.frame.questIcon) then
				b.frame.questIcon:Show()
			end
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
	SwitchBankButton:SetScript("OnEnter", tooltip_show)
	SwitchBankButton:SetScript("OnLeave", tooltip_hide)
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
	Deposit:SetScript("OnEnter", tooltip_show)
	Deposit:SetScript("OnLeave", tooltip_hide)
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
		local button = _G["ReagentBankFrameItem" .. i]
		local icon = _G[button:GetName() .. "IconTexture"]
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

	if bagType and bit.band(bagType, BAGTYPE_FISHING) > 0 then
		return ST_FISHBAG
	elseif bagType and bit.band(bagType, BAGTYPE_PROFESSION) > 0 then
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
				if IsItemUnusable(b.name) or minLevel > K.Level then
					_G[b.frame:GetName().."IconTexture"]:SetVertexColor(0.5, 0.5, 0.5)
				end
				SetItemButtonDesaturated(b.frame, true)
				b.frame:SetAlpha(0.2)
			else
				if IsItemUnusable(b.name) or minLevel > K.Level then
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
		if IsItemUnusable(b.name) or (b.level and b.level > K.Level) then
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
		GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 4)
		GameTooltip:ClearLines()
		GameTooltip:AddDoubleLine(L["Inventory"].Shift_Move)

		GameTooltip:Show()
	end)
	f:SetScript("OnLeave", function()
		if not GameTooltip:IsForbidden() then -- WHY??? BECAUSE FUCK GAMETOOLTIP, THATS WHY!!
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
		f.reagentToggle:GetNormalTexture():SetTexCoord(unpack(K.TexCoords))
		f.reagentToggle:GetNormalTexture():SetAllPoints()
		f.reagentToggle:SetPushedTexture("Interface\\ICONS\\INV_Enchant_DustArcane")
		f.reagentToggle:GetPushedTexture():SetTexCoord(unpack(K.TexCoords))
		f.reagentToggle:GetPushedTexture():SetAllPoints()
		f.reagentToggle:StyleButton(nil, true)
		f.reagentToggle.ttText = "Show/Hide Reagents"
		f.reagentToggle:SetScript("OnEnter", tooltip_show)
		f.reagentToggle:SetScript("OnLeave", tooltip_hide)
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

		-- Buy button
		f.b_purchase = CreateFrame("Button", "StuffingPurchaseButton"..w, f)
		f.b_purchase:SetSize(80, 20)
		f.b_purchase:SetPoint("TOPLEFT", f.b_reagent, "TOPRIGHT", 6, 0)
		f.b_purchase:RegisterForClicks("AnyUp")
		f.b_purchase:SkinButton()
		f.b_purchase:SetScript("OnClick", function(self) StaticPopup_Show("BUY_BANK_SLOT") end) -- Fix this.
		f.b_purchase:FontString("text", C["Media"].Font, C["Media"].FontSize, C["Media"].FontStyle)
		f.b_purchase.text:SetShadowOffset(0, 0)
		f.b_purchase.text:SetPoint("CENTER")
		f.b_purchase.text:SetText(BANKSLOTPURCHASE)
		f.b_purchase:SetFontString(f.b_purchase.text)
		local _, full = GetNumBankSlots()
		if full then
			f.b_purchase:Hide()
		else
			f.b_purchase:Show()
		end
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
	editbox:SetText(SEARCH)

	local detail = f:CreateFontString(nil, "ARTWORK", "GameFontHighlightLarge")
	detail:SetPoint("TOPLEFT", f, 11, -10)
	detail:SetPoint("RIGHT", f, -140, -10)
	detail:SetHeight(13)
	detail:SetShadowColor(0, 0, 0, 0)
	detail:SetJustifyH("LEFT")
	detail:SetText("|cff4488ff"..SEARCH.."|r")
	editbox:SetAllPoints(detail)

	do
		Token2:ClearAllPoints()
		Token2:SetPoint("BOTTOM", f, "BOTTOM", 0, -20)
		Token3:ClearAllPoints()
		Token3:SetPoint("LEFT", Token2, "RIGHT", 10, 0)
		Token1:ClearAllPoints()
		Token1:SetPoint("RIGHT", Token2, "LEFT", -10, 0)
	end

	for i = 1, 3 do
		local Token = _G["BackpackTokenFrameToken"..i]
		local Icon = _G["BackpackTokenFrameToken"..i.."Icon"]
		local Count = _G["BackpackTokenFrameToken"..i.."Count"]

		Token:SetParent(f)
		Token:SetFrameStrata("LOW")
		Token:SetFrameLevel(0)
		Token:SetScale(1)
		Token:CreateBackdrop("", true)
		Token.Backdrop:SetAllPoints(Icon)

		Icon:SetSize(12, 12)
		Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
		Icon:SetPoint("LEFT", Token, "RIGHT", -10, 1)

		Count:SetFont(C.Media.Font, 12, "OUTLINE")
		Count:SetShadowOffset(0, 0)
	end

	local gold = f:CreateFontString(nil, "ARTWORK", "GameFontHighlightLarge")
	gold:SetJustifyH("RIGHT")

	f:SetScript("OnEvent", function(self, e)
		self.gold:SetText(K.FormatMoney(GetMoney(), 12))
	end)

	f:RegisterEvent("PLAYER_ENTERING_WORLD")
	f:RegisterEvent("PLAYER_MONEY")
	f:RegisterEvent("PLAYER_TRADE_MONEY")
	f:RegisterEvent("TRADE_MONEY_CHANGED")

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

	function tooltip_hide()
		if not GameTooltip:IsForbidden() then
			GameTooltip:Hide() -- WHY??? BECAUSE FUCK GAMETOOLTIP, THATS WHY!!
		end
	end

	function tooltip_show(self)
		GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", -12, 11)
		GameTooltip:ClearLines()
		GameTooltip:SetText(self.ttText)
	end

	button:SetScript("OnEnter", tooltip_show)
	button:SetScript("OnLeave", tooltip_hide)

	-- Stack Button
	f.restackButton = CreateFrame("Button", nil, f)
	f.restackButton:SetSize(16, 16)
	f.restackButton:SetTemplate("")
	f.restackButton:StyleButton(true)
	f.restackButton:SetPoint("TOPRIGHT", f, -32, -7)
	f.restackButton:SetNormalTexture("Interface\\ICONS\\misc_arrowdown")
	f.restackButton:GetNormalTexture():SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
	f.restackButton:GetNormalTexture():SetAllPoints()
	f.restackButton:SetPushedTexture("Interface\\ICONS\\misc_arrowdown")
	f.restackButton:GetPushedTexture():SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
	f.restackButton:GetPushedTexture():SetAllPoints()
	f.restackButton.ttText = L["Inventory"].Buttons_Stack
	f.restackButton:SetScript("OnEnter", tooltip_show)
	f.restackButton:SetScript("OnLeave", tooltip_hide)
	f.restackButton:SetScript("OnClick", function()
		PlaySound(PlaySoundKitID and "igMainMenuOption" or SOUNDKIT.IG_MAINMENU_OPTION)
		if InCombatLockdown() then
			print("|cffffff00"..ERR_NOT_IN_COMBAT.."|r") return
		end
		Stuffing:SetBagsForSorting("d")
		Stuffing:Restack()
	end)

	-- Toggle Bags Button
	f.bagsButton = CreateFrame("Button", nil, f)
	f.bagsButton:SetSize(16, 16)
	f.bagsButton:SetTemplate("", true)
	f.bagsButton:SetPoint("RIGHT", f.restackButton, "LEFT", -5, 0)
	f.bagsButton:SetNormalTexture("Interface\\Buttons\\Button-Backpack-Up")
	f.bagsButton:GetNormalTexture():SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
	f.bagsButton:GetNormalTexture():SetAllPoints()
	f.bagsButton:SetPushedTexture("Interface\\Buttons\\Button-Backpack-Up")
	f.bagsButton:GetPushedTexture():SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
	f.bagsButton:GetPushedTexture():SetAllPoints()
	f.bagsButton:StyleButton(nil, true)
	f.bagsButton.ttText = L["Inventory"].Show_Bags
	f.bagsButton:SetScript("OnEnter", tooltip_show)
	f.bagsButton:SetScript("OnLeave", tooltip_hide)
	f.bagsButton:SetScript("OnClick", function()
		if bag_bars == 1 then
			bag_bars = 0
		else
			bag_bars = 1
		end
		Stuffing:Layout()
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
	f.sortButton.ttText = L["Inventory"].Buttons_Sort
	f.sortButton:SetScript("OnEnter", tooltip_show)
	f.sortButton:SetScript("OnLeave", tooltip_hide)
	f.sortButton:SetScript("OnMouseUp", function(_, btn)
		if InCombatLockdown() then
			print("|cffffff00"..ERR_NOT_IN_COMBAT.."|r") return
		end
		if btn == "RightButton" then
			SetSortBagsRightToLeft(true)
			SortBags()
		else
			Stuffing:SetBagsForSorting("d")
			Stuffing:SortBags()
		end
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
		f.ArtifactButton.ttText = L["Inventory"].Buttons_Artifact
		f.ArtifactButton.UpdateTooltip = nil
		f.ArtifactButton:SetScript("OnEnter", tooltip_show)
		f.ArtifactButton:SetScript("OnLeave", tooltip_hide)
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
		f.ArtifactButton:SetScript("OnEnter", function()
			local count = 0
			for bag = 0, 4 do
				for slot = 1, GetContainerNumSlots(bag) do
					if IsArtifactPowerItem(GetContainerItemID(bag, slot)) then
						count = count + 1
					end
				end
			end

			f.ArtifactButton:FadeIn()
			GameTooltip:SetOwner(f.ArtifactButton, "ANCHOR_LEFT")
			GameTooltip:AddLine(ARTIFACT_POWER)
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(L["Inventory"].Artifact_Count.." "..count)
			GameTooltip:AddLine(L["Inventory"].Artifact_Use)
			GameTooltip:Show()
		end)
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
		f:SetAlpha(1)
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

	rows = floor(slots / cols)
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
				local y = floor(idx / cols)

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

				idx = idx + 1
			end
		end
	end
end

function Stuffing:SetBagsForSorting(c)
	Stuffing_Open()

	self.sortBags = {}

	local cmd = ((c == nil or c == "") and {"d"} or {strsplit("/", c)})

	for _, s in ipairs(cmd) do
		if s == "c" then
			self.sortBags = {}
		elseif s == "d" then
			if not self.bankFrame or not self.bankFrame:IsShown() then
				for _, i in ipairs(BAGS_BACKPACK) do
					if self.bags[i] and self.bags[i].bagType == ST_NORMAL then
						table.insert(self.sortBags, i)
					end
				end
			elseif not _G["StuffingFrameReagent"] or not _G["StuffingFrameReagent"]:IsShown() then
				for _, i in ipairs(BAGS_BANK) do
					if self.bags[i] and self.bags[i].bagType == ST_NORMAL then
						table.insert(self.sortBags, i)
					end
				end
			end
		elseif s == "p" then
			if not self.bankFrame or not self.bankFrame:IsShown() then
				for _, i in ipairs(BAGS_BACKPACK) do
					if self.bags[i] and self.bags[i].bagType == ST_SPECIAL then
						table.insert(self.sortBags, i)
					end
				end
			else
				for _, i in ipairs(BAGS_BANK) do
					if self.bags[i] and self.bags[i].bagType == ST_SPECIAL then
						table.insert(self.sortBags, i)
					end
				end
			end
		else
			table.insert(self.sortBags, tonumber(s))
		end
	end
end

function Stuffing:ADDON_LOADED(addon)
	if addon ~= "KkthnxUI" then return nil end

	self:RegisterEvent("BAG_UPDATE")
	self:RegisterEvent("ITEM_LOCK_CHANGED")
	self:RegisterEvent("BANKFRAME_OPENED")
	self:RegisterEvent("BANKFRAME_CLOSED")
	self:RegisterEvent("GUILDBANKFRAME_OPENED")
	self:RegisterEvent("GUILDBANKFRAME_CLOSED")
	self:RegisterEvent("PLAYERBANKSLOTS_CHANGED")
	self:RegisterEvent("PLAYERBANKBAGSLOTS_CHANGED")
	self:RegisterEvent("PLAYERREAGENTBANKSLOTS_CHANGED")
	self:RegisterEvent("BAG_CLOSED")
	self:RegisterEvent("BAG_UPDATE_COOLDOWN")

	self:InitBags()

	tinsert(UISpecialFrames, "StuffingFrameBags")
	tinsert(UISpecialFrames, "StuffingFrameReagent")

	ToggleBackpack = Stuffing_Toggle
	ToggleBag = Stuffing_Toggle
	ToggleAllBags = Stuffing_Toggle
	OpenAllBags = Stuffing_Open
	OpenBackpack = Stuffing_Open
	CloseAllBags = Stuffing_Close
	CloseBackpack = Stuffing_Close

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
		local button = _G["ReagentBankFrameItem" .. i]
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

local function InBags(x)
	if not Stuffing.bags[x] then
		return false
	end

	for _, v in ipairs(Stuffing.sortBags) do
		if x == v then
			return true
		end
	end
	return false
end

local BS_bagGroups
local BS_itemSwapGrid

local function BS_clearData()
	BS_itemSwapGrid = {}
	BS_bagGroups = {}
end

function Stuffing:SortOnUpdate(elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed

	if self.elapsed < 0.05 then
		return
	end

	self.elapsed = 0

	local changed = false
	local blocked = false

	for bagIndex in pairs(BS_itemSwapGrid) do
		for slotIndex in pairs(BS_itemSwapGrid[bagIndex]) do
			local destinationBag = BS_itemSwapGrid[bagIndex][slotIndex].destinationBag
			local destinationSlot = BS_itemSwapGrid[bagIndex][slotIndex].destinationSlot

			local _, _, locked1 = GetContainerItemInfo(bagIndex, slotIndex)
			local _, _, locked2 = GetContainerItemInfo(destinationBag, destinationSlot)

			if locked1 or locked2 then
				blocked = true
			elseif bagIndex ~= destinationBag or slotIndex ~= destinationSlot then
				PickupContainerItem(bagIndex, slotIndex)
				PickupContainerItem(destinationBag, destinationSlot)

				local tempItem = BS_itemSwapGrid[destinationBag][destinationSlot]
				BS_itemSwapGrid[destinationBag][destinationSlot] = BS_itemSwapGrid[bagIndex][slotIndex]
				BS_itemSwapGrid[bagIndex][slotIndex] = tempItem

				changed = true
				return
			end
		end
	end

	if not changed and not blocked then
		self:SetScript("OnUpdate", nil)
		BS_clearData()
	end
end

function Stuffing:SortBags()
	BS_clearData()

	local bagList
	if _G["StuffingFrameReagent"] and _G["StuffingFrameReagent"]:IsShown() then
		bagList = {-3}
	elseif Stuffing.bankFrame and Stuffing.bankFrame:IsShown() then
		bagList = {11, 10, 9, 8, 7, 6, 5, -1}
	else
		bagList = {4, 3, 2, 1, 0}
	end

	for _, slotNum in pairs(bagList) do
		if GetContainerNumSlots(slotNum) > 0 then
			BS_itemSwapGrid[slotNum] = {}
			local family = select(2, GetContainerNumFreeSlots(slotNum))
			if family then
				if family == 0 then family = "Default" end
				if not BS_bagGroups[family] then
					BS_bagGroups[family] = {}
					BS_bagGroups[family].bagSlotNumbers = {}
				end
				table.insert(BS_bagGroups[family].bagSlotNumbers, slotNum)
			end
		end
	end

	for _, group in pairs(BS_bagGroups) do
		group.itemList = {}
		for _, bagSlot in pairs(group.bagSlotNumbers) do
			for itemSlot = 1, GetContainerNumSlots(bagSlot) do

				local itemLink = GetContainerItemLink(bagSlot, itemSlot)
				if itemLink ~= nil then

					local newItem = {}

					local n, _, q, iL, rL, c1, c2, _, Sl = GetItemInfo(itemLink)
					-- Hearthstone
					if n == GetItemInfo(6948) or n == GetItemInfo(110560) then
						q = 9
					end
					-- Fix for battle pets
					if not n then
						n = itemLink
						q = select(4, GetContainerItemInfo(bagSlot, itemSlot))
						iL = 1
						rL = 1
						c1 = "Pet"
						c2 = "Pet"
						Sl = ""
					end

					newItem.sort = q..c1..c2..rL..n..iL..Sl

					tinsert(group.itemList, newItem)

					BS_itemSwapGrid[bagSlot][itemSlot] = newItem
					newItem.startBag = bagSlot
					newItem.startSlot = itemSlot
				end
			end
		end

		table.sort(group.itemList, function(a, b)
			return a.sort > b.sort
		end)

		for index, item in pairs(group.itemList) do
			local gridSlot = index
			for _, bagSlotNumber in pairs(group.bagSlotNumbers) do
				if gridSlot <= GetContainerNumSlots(bagSlotNumber) then
					BS_itemSwapGrid[item.startBag][item.startSlot].destinationBag = bagSlotNumber
					BS_itemSwapGrid[item.startBag][item.startSlot].destinationSlot = GetContainerNumSlots(bagSlotNumber) - gridSlot + 1
					break
				else
					gridSlot = gridSlot - GetContainerNumSlots(bagSlotNumber)
				end
			end
		end
	end

	self:SetScript("OnUpdate", Stuffing.SortOnUpdate)
end

function Stuffing:RestackOnUpdate(e)
	if not self.elapsed then
		self.elapsed = 0
	end

	self.elapsed = self.elapsed + e

	if self.elapsed < 0.1 then return end

	self.elapsed = 0
	self:Restack()
end

function Stuffing:Restack()
	local st = {}

	Stuffing_Open()

	for i, v in pairs(self.buttons) do
		if InBags(v.bag) then
			local _, cnt, _, _, _, _, clink = GetContainerItemInfo(v.bag, v.slot)
			if clink then
				local n, _, _, _, _, _, _, s = GetItemInfo(clink)

				if n and cnt ~= s then
					if not st[n] then
						st[n] = {{item = v, size = cnt, max = s}}
					else
						table.insert(st[n], {item = v, size = cnt, max = s})
					end
				end
			end
		end
	end

	local did_restack = false

	for i, v in pairs(st) do
		if #v > 1 then
			for j = 2, #v, 2 do
				local a, b = v[j - 1], v[j]
				local _, _, l1 = GetContainerItemInfo(a.item.bag, a.item.slot)
				local _, _, l2 = GetContainerItemInfo(b.item.bag, b.item.slot)

				if l1 or l2 then
					did_restack = true
				else
					PickupContainerItem(a.item.bag, a.item.slot)
					PickupContainerItem(b.item.bag, b.item.slot)
					did_restack = true
				end
			end
		end
	end

	if did_restack then
		self:SetScript("OnUpdate", Stuffing.RestackOnUpdate)
	else
		self:SetScript("OnUpdate", nil)
	end
end

function Stuffing:PLAYERBANKBAGSLOTS_CHANGED()
	if not StuffingPurchaseButtonBank then return end
	local _, full = GetNumBankSlots()
	if full then
		StuffingPurchaseButtonBank:Hide()
	else
		StuffingPurchaseButtonBank:Show()
	end
end

-- Kill Blizzard functions
LootWonAlertFrame_OnClick = K.Noop
LootUpgradeFrame_OnClick = K.Noop
StorePurchaseAlertFrame_OnClick = K.Noop
LegendaryItemAlertFrame_OnClick = K.Noop