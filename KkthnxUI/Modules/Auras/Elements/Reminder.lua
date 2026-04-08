--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Monitors player buffs and items to provide visual reminders for missing essentials.
-- - Design: Uses a periodic scan and event-driven updates to show/hide reminder icons.
-- - Events: UNIT_AURA, PLAYER_ENTERING_WORLD, WEAPON_ENCHANT_CHANGED, etc.
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Auras")

-- PERF: Localize globals and C-functions to minimize global lookup overhead.
local _G = _G
local ipairs, next, pairs, table_insert, table_wipe = _G.ipairs, _G.next, _G.pairs, _G.table.insert, _G.table.wipe

local CreateFrame = CreateFrame
local GetNumGroupMembers = GetNumGroupMembers
local GetSpecialization = GetSpecialization
local GetWeaponEnchantInfo = GetWeaponEnchantInfo
local InCombatLockdown = InCombatLockdown
local IsInInstance = IsInInstance
local IsPlayerSpell = IsPlayerSpell
local UIParent = UIParent
local UnitEnteredVehicle = UnitEnteredVehicle
local UnitIsDeadOrGhost = UnitIsDeadOrGhost

local C_Item_GetItemCooldown = C_Item.GetItemCooldown
local C_Item_GetItemCount = C_Item.GetItemCount
local C_Item_GetItemIconByID = C_Item.GetItemIconByID
local C_Item_IsEquippedItem = C_Item.IsEquippedItem
local C_PvP_GetZonePVPInfo = C_PvP.GetZonePVPInfo
local C_Spell_GetSpellTexture = C_Spell.GetSpellTexture
local C_UnitAuras_GetBuffDataByIndex = C_UnitAuras.GetBuffDataByIndex

-- ---------------------------------------------------------------------------
-- Configuration & State
-- ---------------------------------------------------------------------------
local iconSize = C["Auras"].DebuffSize + 4
local frames = {}
local parentFrame
local isRegistered = false
local itemsMerged = false
local activeBuffs = {}
local state = {}

-- REASON: Ensure the class table exists; some client forks can omit a class key.
local groups = C.SpellReminderBuffs[K.Class]
if not groups then
	groups = {}
	C.SpellReminderBuffs[K.Class] = groups
end

-- ---------------------------------------------------------------------------
-- Utility Logic
-- ---------------------------------------------------------------------------
local function IsItemReady(itemID)
	if not itemID then
		return true
	end

	if C_Item_GetItemCount(itemID) <= 0 then
		return false
	end

	-- REASON: C_Item.GetItemCooldown returns (startTime, duration, enable).
	-- Using direct comparison ensures we only show reminders for available items.
	local startTime, duration, enable = C_Item_GetItemCooldown(itemID)
	if not enable then
		return false
	end

	return duration == 0 or startTime == 0
end

local function BuildActiveBuffSet()
	table_wipe(activeBuffs)

	-- PERF: Scan up to 40 buffs once per update cycle to avoid repeated iterations.
	for i = 1, 40 do
		local auraData = C_UnitAuras_GetBuffDataByIndex("player", i, "HELPFUL")
		if not auraData then
			break
		end

		local spellID = auraData.spellId
		if spellID then
			activeBuffs[spellID] = true
		end
	end
end

local function UpdateState()
	state.groupMembers = GetNumGroupMembers()
	state.inCombat = InCombatLockdown()

	state.inInstance, state.instType = IsInInstance()
	state.zonePvp = C_PvP_GetZonePVPInfo()

	state.spec = GetSpecialization()
	state.inVehicle = UnitEnteredVehicle("player")
	state.isDead = UnitIsDeadOrGhost("player")
end

local function PlayerHasAnyReminderBuff(cfg)
	for spellID in pairs(cfg.spells) do
		if activeBuffs[spellID] then
			return true
		end
	end

	return false
end

local function ShouldShowReminder(cfg)
	-- REASON: Core filtering logic to determine if a reminder icon should be displayed.
	if not cfg or cfg.disable or not cfg.spells then
		return false
	end

	if PlayerHasAnyReminderBuff(cfg) then
		return false
	end

	local inGroup = (not cfg.inGroup) or (state.groupMembers >= 2)
	local inCombat = (not cfg.combat) or state.inCombat

	local inInst = true
	if cfg.instance then
		inInst = state.inInstance and (state.instType == "scenario" or state.instType == "party" or state.instType == "raid")
	end

	local inPVP = true
	if cfg.pvp then
		inPVP = (state.instType == "arena" or state.instType == "pvp" or state.zonePvp == "combat")
	end

	local isKnownSpell = (not cfg.depend) or IsPlayerSpell(cfg.depend)
	local isRightSpec = (not cfg.spec) or (cfg.spec == state.spec)

	local isEquipped = true
	if cfg.equip then
		-- WARNING: Guard against bad config entries where equip=true but itemID is missing.
		isEquipped = cfg.itemID and C_Item_IsEquippedItem(cfg.itemID) or false
	end

	local isNotOnCooldown = IsItemReady(cfg.itemID)

	-- Temporary weapon enchants logic
	local weaponIndex = cfg.weaponIndex
	if weaponIndex then
		local hasMainHandEnchant, _, _, _, hasOffHandEnchant = GetWeaponEnchantInfo()
		if (weaponIndex == 1 and hasMainHandEnchant) or (weaponIndex == 2 and hasOffHandEnchant) then
			return false
		end
	end

	return inGroup and inCombat and inInst and inPVP and isKnownSpell and isRightSpec and isEquipped and isNotOnCooldown and not state.inVehicle and not state.isDead
end

-- ---------------------------------------------------------------------------
-- Core Module Functions
-- ---------------------------------------------------------------------------
function Module:Reminder_Update(cfg)
	local frame = cfg.frame
	if not frame then
		return
	end

	if ShouldShowReminder(cfg) then
		frame:Show()
	else
		frame:Hide()
	end
end

function Module:Reminder_Create(cfg)
	-- REASON: Reminder frames live under parentFrame, created only when the feature is enabled.
	if not parentFrame then
		return
	end

	local frame = CreateFrame("Frame", nil, parentFrame)
	frame:SetSize(iconSize, iconSize)

	frame.Icon = frame:CreateTexture(nil, "ARTWORK")
	frame.Icon:SetAllPoints()
	frame.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])

	local firstSpellID = next(cfg.spells)
	frame.Icon:SetTexture(cfg.texture or (firstSpellID and C_Spell_GetSpellTexture(firstSpellID)))

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

	-- PERF: Use ipairs for array iteration.
	for _, frame in ipairs(frames) do
		if frame:IsShown() then
			frame:ClearAllPoints()
			frame:SetPoint("LEFT", offset * index, 0)
			index = index + 1
		end
	end

	-- REASON: Dynamically resize parent container to center/align current icons.
	parentFrame:SetWidth(index > 0 and (offset * index) or iconSize)
end

function Module:Reminder_OnEvent()
	if not parentFrame or not parentFrame:IsShown() then
		return
	end

	BuildActiveBuffSet()
	UpdateState()

	-- PERF: Use ipairs for array iteration.
	for _, cfg in ipairs(groups) do
		if not cfg.frame then
			Module:Reminder_Create(cfg)
		end

		Module:Reminder_Update(cfg)
	end

	Module:Reminder_UpdateAnchor()
end

function Module:Reminder_AddItemGroup()
	if itemsMerged then
		return
	end

	-- REASON: Prevent duplicating item entries if CreateReminder is called multiple times.
	local added = {}

	-- PERF: Use ipairs for array iteration.
	for _, cfg in ipairs(groups) do
		if cfg and cfg.itemID then
			added[cfg.itemID] = true
		end
	end

	-- PERF: Use ipairs for array iteration.
	for _, value in ipairs(C.SpellReminderBuffs["ITEMS"]) do
		if value and not value.disable and value.itemID and not added[value.itemID] and (C_Item_GetItemCount(value.itemID) > 0) then
			value.texture = value.texture or C_Item_GetItemIconByID(value.itemID)
			table_insert(groups, value)
			added[value.itemID] = true
		end
	end

	itemsMerged = true
end

local function RegisterEvents()
	if isRegistered then
		return
	end
	isRegistered = true

	K:RegisterEvent("UNIT_AURA", Module.Reminder_OnEvent, "player")
	K:RegisterEvent("UNIT_EXITED_VEHICLE", Module.Reminder_OnEvent)
	K:RegisterEvent("UNIT_ENTERED_VEHICLE", Module.Reminder_OnEvent)
	K:RegisterEvent("PLAYER_REGEN_ENABLED", Module.Reminder_OnEvent)
	K:RegisterEvent("PLAYER_REGEN_DISABLED", Module.Reminder_OnEvent)
	K:RegisterEvent("ZONE_CHANGED_NEW_AREA", Module.Reminder_OnEvent)
	K:RegisterEvent("PLAYER_ENTERING_WORLD", Module.Reminder_OnEvent)
	K:RegisterEvent("WEAPON_ENCHANT_CHANGED", Module.Reminder_OnEvent)
end

local function UnregisterEvents()
	if not isRegistered then
		return
	end
	isRegistered = false

	K:UnregisterEvent("UNIT_AURA", Module.Reminder_OnEvent)
	K:UnregisterEvent("UNIT_EXITED_VEHICLE", Module.Reminder_OnEvent)
	K:UnregisterEvent("UNIT_ENTERED_VEHICLE", Module.Reminder_OnEvent)
	K:UnregisterEvent("PLAYER_REGEN_ENABLED", Module.Reminder_OnEvent)
	K:UnregisterEvent("PLAYER_REGEN_DISABLED", Module.Reminder_OnEvent)
	K:UnregisterEvent("ZONE_CHANGED_NEW_AREA", Module.Reminder_OnEvent)
	K:UnregisterEvent("PLAYER_ENTERING_WORLD", Module.Reminder_OnEvent)
	K:UnregisterEvent("WEAPON_ENCHANT_CHANGED", Module.Reminder_OnEvent)
end

function Module:CreateReminder()
	Module:Reminder_AddItemGroup()

	if not next(groups) then
		return
	end

	if C["Auras"].Reminder then
		if not parentFrame then
			parentFrame = CreateFrame("Frame", nil, UIParent)
			parentFrame:SetPoint("CENTER", -220, 130)
			parentFrame:SetSize(iconSize, iconSize)
		end

		parentFrame:Show()
		RegisterEvents()
		Module:Reminder_OnEvent()
	else
		if parentFrame then
			parentFrame:Hide()
		end

		-- PERF: Use ipairs for array iteration.
		for _, frame in ipairs(frames) do
			frame:Hide()
		end

		UnregisterEvents()
	end
end
