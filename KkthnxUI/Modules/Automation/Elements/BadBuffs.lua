local K, C, L = unpack(select(2, ...))
local Module = K:GetModule("Automation")

local _G = _G

local UnitBuff = _G.UnitBuff
local InCombatLockdown = _G.InCombatLockdown

local function SetupAutoBadBuffs(_, unit)
	if unit == "player" and not InCombatLockdown() then
		local i = 1
		while true do
			local name = UnitBuff(unit, i)
			if not name then
				return
			end

			if C.CheckBadBuffs[name] then
				CancelSpellByName(name)
				K.Print(K.SystemColor..ACTION_SPELL_AURA_REMOVED.." ["..name.."].|r")
			end

			i = i + 1
		end
	end
end

function Module:CreateAutoBadBuffs()
	if C["Automation"].NoBadBuffs then
		K:RegisterEvent("UNIT_AURA", SetupAutoBadBuffs)
	else
		K:UnregisterEvent("UNIT_AURA", SetupAutoBadBuffs)
	end
end