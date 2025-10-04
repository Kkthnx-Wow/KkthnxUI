local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Automation")

local InCombatLockdown = InCombatLockdown
local CancelSpellByName = CancelSpellByName
local C_UnitAuras_GetBuffDataByIndex = C_UnitAuras and C_UnitAuras.GetBuffDataByIndex
local C_Spell_GetSpellLink = C_Spell and C_Spell.GetSpellLink
local format = string.format
local GetTime = GetTime

local lastCanceledAtBySpellId = {}
local pendingRegen = false

local function CheckAndRemoveBadBuffs(event, unit)
	if not C["Automation"].NoBadBuffs then
		return
	end

	if unit and unit ~= "player" then
		return
	end

	if InCombatLockdown() then
		if not pendingRegen then
			K:RegisterEvent("PLAYER_REGEN_ENABLED", CheckAndRemoveBadBuffs)
			pendingRegen = true
		end
		return
	elseif event == "PLAYER_REGEN_ENABLED" then
		K:UnregisterEvent("PLAYER_REGEN_ENABLED", CheckAndRemoveBadBuffs)
		pendingRegen = false
	end

	if not C.CheckBadBuffs then
		return
	end

	local index = 1
	while true do
		local aura = C_UnitAuras_GetBuffDataByIndex("player", index, "CANCELABLE")

		if not aura then
			break
		end

		if aura.name and C.CheckBadBuffs[aura.name] then
			CancelSpellByName(aura.name)
			local spellLink = C_Spell_GetSpellLink(aura.spellId)
			local msgRemoved = L["Removed Bad Buff: %s"] or "Removed Bad Buff: %s"
			local now = GetTime()
			local lastAt = lastCanceledAtBySpellId[aura.spellId] or 0
			if now - lastAt > 1.0 then
				K.Print(K.SystemColor .. format(msgRemoved, (spellLink or aura.name)) .. "|r")
				lastCanceledAtBySpellId[aura.spellId] = now
			end
			break
		end

		index = index + 1
	end
end

function Module:CreateAutoBadBuffs()
	if C["Automation"].NoBadBuffs then
		K:RegisterEvent("UNIT_AURA", CheckAndRemoveBadBuffs, "player")
	else
		K:UnregisterEvent("UNIT_AURA", CheckAndRemoveBadBuffs)
	end
end
