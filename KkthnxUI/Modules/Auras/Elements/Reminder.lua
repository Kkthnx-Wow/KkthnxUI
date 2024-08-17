local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Auras")

local next = next
local pairs = pairs
local table_insert = table.insert

local CreateFrame = CreateFrame
local GetItemCooldown = C_Item.GetItemCooldown
local GetItemCount = C_Item.GetItemCount
local GetItemIcon = C_Item.GetItemIconByID
local GetNumGroupMembers = GetNumGroupMembers
local GetSpecialization = GetSpecialization
local GetSpellTexture = GetSpellTexture
local GetWeaponEnchantInfo = GetWeaponEnchantInfo
local GetZonePVPInfo = C_PvP.GetZonePVPInfo
local InCombatLockdown = InCombatLockdown
local IsEquippedItem = IsEquippedItem
local IsInInstance = IsInInstance
local IsPlayerSpell = IsPlayerSpell
local UIParent = UIParent
local UnitBuff = UnitBuff
local UnitInVehicle = UnitInVehicle
local UnitIsDeadOrGhost = UnitIsDeadOrGhost

local groups = C.SpellReminderBuffs[K.Class]
local iconSize = C["Auras"].DebuffSize + 4
local frames = {}
local parentFrame

function Module:Reminder_Update(cfg)
	local frame = cfg.frame
	local depend = cfg.depend
	local spec = cfg.spec
	local combat = cfg.combat
	local instance = cfg.instance
	local pvp = cfg.pvp
	local itemID = cfg.itemID
	local equip = cfg.equip
	local inGroup = cfg.inGroup
	local isPlayerSpell = true
	local isRightSpec = true
	local isEquipped = true
	local isGrouped = true
	local isInCombat
	local isInInst
	local isInPVP
	local inInst, instType = IsInInstance()
	local weaponIndex = cfg.weaponIndex

	if itemID then
		if inGroup and GetNumGroupMembers() < 2 then
			isGrouped = false
		end

		if equip and not IsEquippedItem(itemID) then
			isEquipped = false
		end

		if GetItemCount(itemID) == 0 or not isEquipped or not isGrouped or GetItemCooldown(itemID) > 0 then -- check item cooldown
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
	frame.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])

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
	frame.text:SetFontObject(K.UIFontOutline)
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
