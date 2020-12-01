local K, C, L = unpack(select(2, ...))
local Module = K:GetModule("Auras")

local _G = _G
local next = _G.next
local pairs = _G.pairs
local table_insert = _G.table.insert
local unpack = _G.unpack

local CreateFrame = _G.CreateFrame
local GetItemCooldown = _G.GetItemCooldown
local GetItemCount = _G.GetItemCount
local GetItemIcon = _G.GetItemIcon
local GetSpecialization = _G.GetSpecialization
local GetSpellTexture = _G.GetSpellTexture
local GetWeaponEnchantInfo = _G.GetWeaponEnchantInfo
local GetZonePVPInfo = _G.GetZonePVPInfo
local InCombatLockdown = _G.InCombatLockdown
local IsEquippedItem = _G.IsEquippedItem
local IsInInstance = _G.IsInInstance
local IsPlayerSpell = _G.IsPlayerSpell
local UIParent = _G.UIParent
local UnitBuff = _G.UnitBuff
local UnitInVehicle = _G.UnitInVehicle
local UnitIsDeadOrGhost = _G.UnitIsDeadOrGhost

local groups = C.SpellReminderBuffs[K.Class]
local iconSize = C["Auras"].DebuffSize + 4
local frames, parentFrame = {}

function Module:Reminder_Update(cfg)
	local frame = cfg.frame
	local depend = cfg.depend
	local spec = cfg.spec
	local combat = cfg.combat
	local instance = cfg.instance
	local pvp = cfg.pvp
	local itemID = cfg.itemID
	local equip = cfg.equip
	local isPlayerSpell, isRightSpec, isEquipped, isInCombat, isInInst, isInPVP = true, true, true
	local inInst, instType = IsInInstance()
	local weaponIndex = cfg.weaponIndex

	if itemID then
		if equip and not IsEquippedItem(itemID) then
			isEquipped = false
		end

		if GetItemCount(itemID) == 0 or (not isEquipped) or GetItemCooldown(itemID) > 0 then -- Check item cooldown
			frame:Hide()
			return
		end
	end

	if depend and not IsPlayerSpell(depend) then
		isPlayerSpell = false
	end

	if spec and spec ~= GetSpecialization() then
		isRightSpec = false
	end

	if combat and InCombatLockdown() then
		isInCombat = true
	end

	if instance and inInst and (instType == "scenario" or instType == "party" or instType == "raid") then
		isInInst = true
	end

	if pvp and (instType == "arena" or instType == "pvp" or GetZonePVPInfo() == "combat") then
		isInPVP = true
	end

	if not combat and not instance and not pvp then
		isInCombat, isInInst, isInPVP = true, true, true
	end

	frame:Hide()
	if isPlayerSpell and isRightSpec and (isInCombat or isInInst or isInPVP) and not UnitInVehicle("player") and not UnitIsDeadOrGhost("player") then
		if weaponIndex then
			local hasMainHandEnchant, _, _, _, hasOffHandEnchant = GetWeaponEnchantInfo()
			if (hasMainHandEnchant and weaponIndex == 1) or (hasOffHandEnchant and weaponIndex == 2) then
				frame:Hide()
				return
			end
		else
			for i = 1, 32 do
				local name, _, _, _, _, _, _, _, _, spellID = UnitBuff("player", i)
				if not name then
					break
				end

				if name and cfg.spells[spellID] then
					frame:Hide()
					return
				end
			end
		end
		frame:Show()
	end
end

function Module:Reminder_Create(cfg)
	local frame = CreateFrame("Frame", nil, parentFrame)
	frame:SetSize(iconSize, iconSize)

	frame.Icon = frame:CreateTexture(nil, "ARTWORK")
	frame.Icon:SetAllPoints()
	frame.Icon:SetTexCoord(unpack(K.TexCoords))

	local texture = cfg.texture
	if not texture then
		for spellID in pairs(cfg.spells) do
			texture = GetSpellTexture(spellID)
			break
		end
	end
	frame.Icon:SetTexture(texture)

	frame:CreateBorder()

	frame.text = frame:CreateFontString(nil, "OVERLAY")
	frame.text:SetFontObject(K.GetFont(C["UIFonts"].AuraFonts))
	frame.text:SetText(L["Lack"])
	frame.text:SetPoint("TOP", frame, "TOP", 1, 15)

	frame:Hide()
	cfg.frame = frame

	table_insert(frames, frame)
end

function Module:Reminder_UpdateAnchor()
	local index = 0
	local offset = iconSize + 6
	for _, frame in next, frames do
		if frame:IsShown() then
			frame:SetPoint("LEFT", offset * index, 0)
			index = index + 1
		end
	end

	parentFrame:SetWidth(offset * index)
end

function Module:Reminder_OnEvent()
	for _, cfg in pairs(groups) do
		if not cfg.frame then
			Module:Reminder_Create(cfg)
		end
		Module:Reminder_Update(cfg)
	end

	Module:Reminder_UpdateAnchor()
end

function Module:Reminder_AddItemGroup()
	if not groups then
		groups = {}
	end

	for _, value in pairs(C.SpellReminderBuffs["ITEMS"]) do
		if not value.disable and GetItemCount(value.itemID) > 0 then
			if not value.texture then
				value.texture = GetItemIcon(value.itemID)
			end

			if not groups then
				groups = {}
			end
			table_insert(groups, value)
		end
	end
end

function Module:CreateReminder()
	Module:Reminder_AddItemGroup()

	if not groups or not next(groups) then
		return
	end

	if C["Auras"].Reminder then
		if not parentFrame then
			parentFrame = CreateFrame("Frame", nil, UIParent)
			parentFrame:SetPoint("CENTER", -220, 130)
			parentFrame:SetSize(iconSize, iconSize)
		end
		parentFrame:Show()

		Module:Reminder_OnEvent()
		K:RegisterEvent("UNIT_AURA", Module.Reminder_OnEvent, "player")
		K:RegisterEvent("UNIT_EXITED_VEHICLE", Module.Reminder_OnEvent)
		K:RegisterEvent("UNIT_ENTERED_VEHICLE", Module.Reminder_OnEvent)
		K:RegisterEvent("PLAYER_REGEN_ENABLED", Module.Reminder_OnEvent)
		K:RegisterEvent("PLAYER_REGEN_DISABLED", Module.Reminder_OnEvent)
		K:RegisterEvent("ZONE_CHANGED_NEW_AREA", Module.Reminder_OnEvent)
		K:RegisterEvent("PLAYER_ENTERING_WORLD", Module.Reminder_OnEvent)
	else
		if parentFrame then
			parentFrame:Hide()
			K:UnregisterEvent("UNIT_AURA", Module.Reminder_OnEvent)
			K:UnregisterEvent("UNIT_EXITED_VEHICLE", Module.Reminder_OnEvent)
			K:UnregisterEvent("UNIT_ENTERED_VEHICLE", Module.Reminder_OnEvent)
			K:UnregisterEvent("PLAYER_REGEN_ENABLED", Module.Reminder_OnEvent)
			K:UnregisterEvent("PLAYER_REGEN_DISABLED", Module.Reminder_OnEvent)
			K:UnregisterEvent("ZONE_CHANGED_NEW_AREA", Module.Reminder_OnEvent)
			K:UnregisterEvent("PLAYER_ENTERING_WORLD", Module.Reminder_OnEvent)
		end
	end
end