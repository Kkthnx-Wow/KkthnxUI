local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Automation")

local UnitBuff = UnitBuff
local InCombatLockdown = InCombatLockdown

-- Function to check for bad buffs and remove them
local function CheckAndRemoveBadBuffs(event)
	-- Check if the player is in combat, if so, register for the event when the player leaves combat
	if InCombatLockdown() then
		return K:RegisterEvent("PLAYER_REGEN_ENABLED", CheckAndRemoveBadBuffs)
	-- Unregister the event if the player has left combat
	elseif event == "PLAYER_REGEN_ENABLED" then
		K:UnregisterEvent("PLAYER_REGEN_ENABLED", CheckAndRemoveBadBuffs)
	end

	-- Loop through all the player's buffs
	local index = 1
	while true do
		-- Fetch buff data using the new API
		local aura = C_UnitAuras.GetBuffDataByIndex("player", index)

		-- Exit the loop if there are no more buffs
		if not aura then
			return
		end

		-- Check if the current buff is a bad buff, and if so, cancel it and print a message
		if C.CheckBadBuffs[aura.name] then
			CancelSpellByName(aura.name)

			-- Use C_Spell.GetSpellLink to retrieve the spell link
			local spellLink = C_Spell.GetSpellLink(aura.spellId)
			K.Print(K.SystemColor .. "Removed Bad Buff: " .. (spellLink or aura.name) .. "|r")
		end

		-- Move to the next buff
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
