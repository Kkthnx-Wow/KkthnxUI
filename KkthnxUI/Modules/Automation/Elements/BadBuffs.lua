local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Automation")

local InCombatLockdown = InCombatLockdown
local CancelSpellByName = CancelSpellByName
local C_UnitAuras_GetBuffDataByIndex = C_UnitAuras.GetBuffDataByIndex
local C_Spell_GetSpellLink = C_Spell.GetSpellLink

-- Function to check for bad buffs and remove them
local function CheckAndRemoveBadBuffs(event)
	-- Early exit if in combat, register for PLAYER_REGEN_ENABLED to retry after combat ends
	if InCombatLockdown() then
		K:RegisterEvent("PLAYER_REGEN_ENABLED", CheckAndRemoveBadBuffs)
		return
	elseif event == "PLAYER_REGEN_ENABLED" then
		K:UnregisterEvent("PLAYER_REGEN_ENABLED", CheckAndRemoveBadBuffs)
	end

	-- Loop through buffs on the player
	local index = 1
	while true do
		-- Get buff data for current index
		local aura = C_UnitAuras_GetBuffDataByIndex("player", index)

		-- Exit loop if no more buffs
		if not aura then
			break
		end

		-- Check for bad buffs and cancel them
		if C.CheckBadBuffs[aura.name] then
			CancelSpellByName(aura.name)
			local spellLink = C_Spell_GetSpellLink(aura.spellId)
			K.Print(K.SystemColor .. "Removed Bad Buff: " .. (spellLink or aura.name) .. "|r")
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
