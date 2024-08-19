local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Auras")

-- Cache frequently used functions
local next, pairs, table_insert = next, pairs, table.insert
local CreateFrame, UIParent = CreateFrame, UIParent
local GetItemCooldown, GetItemCount, GetItemIcon = C_Item.GetItemCooldown, C_Item.GetItemCount, C_Item.GetItemIconByID
local GetNumGroupMembers, GetSpecialization = GetNumGroupMembers, GetSpecialization
local GetSpellTexture = C_Spell.GetSpellTexture
local GetWeaponEnchantInfo = GetWeaponEnchantInfo
local GetZonePVPInfo = C_PvP.GetZonePVPInfo
local InCombatLockdown, UnitInVehicle, UnitIsDeadOrGhost = InCombatLockdown, UnitInVehicle, UnitIsDeadOrGhost
local IsEquippedItem, IsPlayerSpell, IsInInstance = C_Item.IsEquippedItem, IsPlayerSpell, IsInInstance

local groups = C.SpellReminderBuffs[K.Class]
local iconSize = C["Auras"].DebuffSize + 4
local frames, parentFrame = {}, nil

local function ShouldShowReminder(cfg)
	local inGroup = not cfg.inGroup or GetNumGroupMembers() >= 2
	local inCombat = not cfg.combat or InCombatLockdown()
	local inInstance, instType = IsInInstance()
	local inInst = not cfg.instance or (inInstance and (instType == "scenario" or instType == "party" or instType == "raid"))
	local inPVP = not cfg.pvp or (instType == "arena" or instType == "pvp" or GetZonePVPInfo() == "combat")
	local isPlayerSpell = not cfg.depend or IsPlayerSpell(cfg.depend)
	local isRightSpec = not cfg.spec or cfg.spec == GetSpecialization()
	local isEquipped = not cfg.equip or IsEquippedItem(cfg.itemID)
	local isNotOnCooldown = not cfg.itemID or (GetItemCount(cfg.itemID) > 0 and GetItemCooldown(cfg.itemID) == 0)
	local weaponIndex = cfg.weaponIndex

	if weaponIndex then
		local hasMainHandEnchant, _, _, _, hasOffHandEnchant = GetWeaponEnchantInfo()
		if (weaponIndex == 1 and hasMainHandEnchant) or (weaponIndex == 2 and hasOffHandEnchant) then
			return false
		end
	end

	for i = 1, 40 do
		local auraData = C_UnitAuras.GetBuffDataByIndex("player", i, "HELPFUL")
		if not auraData then
			break
		end
		if cfg.spells[auraData.spellId] then
			return false
		end
	end

	return inGroup and inCombat and inInst and inPVP and isPlayerSpell and isRightSpec and isEquipped and isNotOnCooldown and not UnitInVehicle("player") and not UnitIsDeadOrGhost("player")
end

function Module:Reminder_Update(cfg)
	local frame = cfg.frame
	if ShouldShowReminder(cfg) then
		frame:Show()
	else
		frame:Hide()
	end
end

function Module:Reminder_Create(cfg)
	local frame = CreateFrame("Frame", nil, parentFrame)
	frame:SetSize(iconSize, iconSize)
	frame.Icon = frame:CreateTexture(nil, "ARTWORK")
	frame.Icon:SetAllPoints()
	frame.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
	frame.Icon:SetTexture(cfg.texture or GetSpellTexture(next(cfg.spells)))
	frame:CreateBorder()
	frame.text = frame:CreateFontString(nil, "OVERLAY")
	frame.text:SetFontObject(K.UIFontOutline)
	frame.text:SetText(L["Lack"])
	frame.text:SetPoint("TOP", frame, "TOP", 1, 15)
	frame:Hide()
	cfg.frame = frame
	table_insert(frames, frame)
end

function Module:Reminder_UpdateAnchor()
	local index, offset = 0, iconSize + 6
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
	for _, value in pairs(C.SpellReminderBuffs["ITEMS"]) do
		if not value.disable and GetItemCount(value.itemID) > 0 then
			value.texture = value.texture or GetItemIcon(value.itemID)
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
		K:RegisterEvent("WEAPON_ENCHANT_CHANGED", Module.Reminder_OnEvent)
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
			K:UnregisterEvent("WEAPON_ENCHANT_CHANGED", Module.Reminder_OnEvent)
		end
	end
end
