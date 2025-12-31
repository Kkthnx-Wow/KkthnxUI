local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Automation")

-- Global Caches
local InCombatLockdown = InCombatLockdown
local GetTime = GetTime
local C_UnitAuras_GetAuraDataByIndex = C_UnitAuras.GetAuraDataByIndex
local C_Spell_GetSpellLink = C_Spell.GetSpellLink
local next = next
local string_format = string.format

-- State
local queuedAfterCombat = false
local lastPrintAtBySpellId = {}

-- Matching
local function IsBadAura(badList, aura)
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

-- Chat Output
local function PrintRemoved(aura)
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

local function RemoveBadBuffsNow(_, unit)
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

	if InCombatLockdown() then
		if not queuedAfterCombat then
			queuedAfterCombat = true
			K:RegisterEvent("PLAYER_REGEN_ENABLED", RemoveBadBuffsNow)
		end
		return
	end

	if queuedAfterCombat then
		queuedAfterCombat = false
		K:UnregisterEvent("PLAYER_REGEN_ENABLED", RemoveBadBuffsNow)
	end

	local scanCount = 0
	for i = 40, 1, -1 do
		local aura = C_UnitAuras_GetAuraDataByIndex("player", i, "HELPFUL")
		if aura then
			scanCount = scanCount + 1
			if IsBadAura(badList, aura) then
				CancelSpellByName(aura.name)
				PrintRemoved(aura)
			end
		end
	end
end

-- Public
function Module:CreateAutoBadBuffs()
	if C["Automation"].NoBadBuffs then
		K:RegisterEvent("UNIT_AURA", RemoveBadBuffsNow, "player")
	else
		K:UnregisterEvent("UNIT_AURA", RemoveBadBuffsNow)
		K:UnregisterEvent("PLAYER_REGEN_ENABLED", RemoveBadBuffsNow)
		queuedAfterCombat = false
	end
end
