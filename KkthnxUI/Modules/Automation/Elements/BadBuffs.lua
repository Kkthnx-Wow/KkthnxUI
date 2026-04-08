--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Automatically removes undesirable buffs (e.g., click-off buffs like Neural Silencer).
-- - Design: Scans player buffs on UNIT_AURA and uses CancelSpellByName to remove matching entries.
-- - Events: UNIT_AURA (player), PLAYER_REGEN_ENABLED (deferred)
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Automation")

-- PERF: Localize globals to reduce lookup overhead.
local C_Spell_GetSpellLink = C_Spell.GetSpellLink
local C_UnitAuras_GetAuraDataByIndex = C_UnitAuras.GetAuraDataByIndex
local CancelSpellByName = CancelSpellByName
local GetTime = GetTime
local InCombatLockdown = InCombatLockdown
local next = next
local string_format = string.format

-- ---------------------------------------------------------------------------
-- State
-- ---------------------------------------------------------------------------
local queuedAfterCombat = false
local lastPrintAtBySpellId = {}

-- ---------------------------------------------------------------------------
-- Internal Logic
-- ---------------------------------------------------------------------------
local function isBadAura(badList, aura)
	-- REASON: Checks both spell ID and name against the bad list for maximum compatibility.
	local spellId = aura.spellId
	local name = aura.name
	if spellId and badList[spellId] then
		return true
	end

	if name and badList[name] then
		return true
	end

	return false
end

local function printRemoved(aura)
	-- REASON: Throttles chat output for the same spell to avoid spamming the user.
	local spellId = aura.spellId
	if spellId then
		local now = GetTime()
		local lastAt = lastPrintAtBySpellId[spellId] or 0
		if now - lastAt <= 1.0 then
			return
		end
		lastPrintAtBySpellId[spellId] = now
	end

	local link = (spellId and C_Spell_GetSpellLink(spellId)) or aura.name or "Unknown"
	local msgRemoved = L["Removed Bad Buff: %s"] or "Removed Bad Buff: %s"
	K.Print(K.SystemColor .. string_format(msgRemoved, link) .. "|r")
end

local function removeBadBuffsNow(_, unit)
	if unit and unit ~= "player" then
		return
	end

	if not C["Automation"].NoBadBuffs then
		return
	end

	local badList = C.CheckBadBuffs
	if not badList or not next(badList) then
		return
	end

	-- REASON: Defer buff removal if in combat to avoid potential taint or protected function blocks.
	if InCombatLockdown() then
		if not queuedAfterCombat then
			queuedAfterCombat = true
			K:RegisterEvent("PLAYER_REGEN_ENABLED", removeBadBuffsNow)
		end
		return
	end

	if queuedAfterCombat then
		queuedAfterCombat = false
		K:UnregisterEvent("PLAYER_REGEN_ENABLED", removeBadBuffsNow)
	end

	-- PERF: Iterates backwards from 40 to safely handle buff removal shifts.
	for i = 40, 1, -1 do
		local aura = C_UnitAuras_GetAuraDataByIndex("player", i, "HELPFUL")
		if aura then
			if isBadAura(badList, aura) then
				CancelSpellByName(aura.name)
				printRemoved(aura)
			end
		end
	end
end

-- ---------------------------------------------------------------------------
-- Module Registration
-- ---------------------------------------------------------------------------
function Module:CreateAutoBadBuffs()
	-- REASON: Entry point to enable/disable the bad buff removal automation.
	if C["Automation"].NoBadBuffs then
		K:RegisterEvent("UNIT_AURA", removeBadBuffsNow, "player")
	else
		K:UnregisterEvent("UNIT_AURA", removeBadBuffsNow)
		K:UnregisterEvent("PLAYER_REGEN_ENABLED", removeBadBuffsNow)
		queuedAfterCombat = false
	end
end
