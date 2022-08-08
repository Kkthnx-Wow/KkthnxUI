local K, C = unpack(KkthnxUI)
local Module = K:GetModule("Automation")

-- Automatically sets your role (iSpawnAtHome)

local _G = _G

local InCombatLockdown = _G.InCombatLockdown
local IsInGroup = _G.IsInGroup
local IsPartyLFG = _G.IsPartyLFG
local GetSpecialization = _G.GetSpecialization
local GetSpecializationRole = _G.GetSpecializationRole
local UnitGroupRolesAssigned = _G.UnitGroupRolesAssigned
local GetTime = _G.GetTime
local UnitSetRole = _G.UnitSetRole

local PreviousAutoRole = 0

function Module:CombatAutoSetRole()
	K:UnregisterEvent("PLAYER_REGEN_ENABLED", Module.CombatAutoSetRole)
	Module:SetupAutoSetRole() -- Force role check
end

function Module:SetupAutoSetRole()
	if IsInGroup() then
		if IsPartyLFG() then
			return
		end

		local spec = GetSpecialization()
		if not spec then -- No spec selected
			return
		end

		local role = GetSpecializationRole(spec)
		if role and UnitGroupRolesAssigned("player") ~= role then
			if InCombatLockdown() or UnitAffectingCombat("player") then
				K:RegisterEvent("PLAYER_REGEN_ENABLED", Module.CombatAutoSetRole)
				return
			end

			local t = GetTime()
			if t - PreviousAutoRole > 2 then
				PreviousAutoRole = t
				UnitSetRole("player", role)
			end
		end
	end
end

function Module:CreateAutoSetRole()
	if not C["Automation"].AutoSetRole then
		return
	end

	K:RegisterEvent("GROUP_ROSTER_UPDATE", Module.SetupAutoSetRole)
	RolePollPopup:UnregisterEvent("ROLE_POLL_BEGIN")
end
