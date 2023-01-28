local K, C = unpack(KkthnxUI)
local Module = K:GetModule("Automation")

local UnitBuff = UnitBuff
local InCombatLockdown = InCombatLockdown

local function SetupAutoBadBuffs(event)
	if InCombatLockdown() then
		return K:RegisterEvent("PLAYER_REGEN_ENABLED", SetupAutoBadBuffs)
	elseif event == "PLAYER_REGEN_ENABLED" then
		K:UnregisterEvent("PLAYER_REGEN_ENABLED", SetupAutoBadBuffs)
	end

	local index = 1
	while true do
		local name, _, _, _, _, _, _, _, _, spellId = UnitBuff("player", index)
		if not name then
			return
		end

		if C.CheckBadBuffs[name] then
			CancelSpellByName(name)
			K.Print(K.SystemColor .. "Removed Bad Buff" .. " " .. GetSpellLink(spellId) .. "|r")
		end

		index = index + 1
	end
end

function Module:CreateAutoBadBuffs()
	if C["Automation"].NoBadBuffs then
		K:RegisterEvent("UNIT_AURA", SetupAutoBadBuffs, "player")
	else
		K:UnregisterEvent("UNIT_AURA", SetupAutoBadBuffs)
	end
end
