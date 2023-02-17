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
		local name, _, _, _, _, _, _, _, _, spellId = UnitBuff("player", index)
		if not name then
			return
		end

		-- Check if the current buff is a bad buff, and if so, cancel it and print a message
		if C.CheckBadBuffs[name] then
			CancelSpellByName(name)
			K.Print(K.SystemColor .. "Removed Bad Buff" .. " " .. GetSpellLink(spellId) .. "|r")
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
