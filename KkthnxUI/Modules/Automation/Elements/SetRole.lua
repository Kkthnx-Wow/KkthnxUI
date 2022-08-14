local K, C = unpack(KkthnxUI)
local Module = K:GetModule("Automation")

-- Automatically sets your role (iSpawnAtHome)

local _G = _G

local GetSpecialization = _G.GetSpecialization
local GetSpecializationRole = _G.GetSpecializationRole
local GetTime = _G.GetTime
local InCombatLockdown = _G.InCombatLockdown
local IsInGroup = _G.IsInGroup
local IsPartyLFG = _G.IsPartyLFG
local RolePollPopup = _G.RolePollPopup
local UnitGroupRolesAssigned = _G.UnitGroupRolesAssigned
local UnitSetRole = _G.UnitSetRole

local prev = 0
function Module:SetupAutoRole()
	if K.Level >= 10 and not InCombatLockdown() and IsInGroup() and not IsPartyLFG() then
		local spec = GetSpecialization()
		if spec then
			local role = GetSpecializationRole(spec)
			if UnitGroupRolesAssigned("player") ~= role then
				local t = GetTime()
				if t - prev > 2 then
					prev = t
					UnitSetRole("player", role)
					return
				end
			end
		else
			UnitSetRole("player", "No Role")
			return
		end
	end
end

function Module:CreateAutoSetRole()
	if not C["Automation"].AutoSetRole then
		return
	end

	K:RegisterEvent("PLAYER_TALENT_UPDATE", Module.SetupAutoRole)
	K:RegisterEvent("GROUP_ROSTER_UPDATE", Module.SetupAutoRole)
	RolePollPopup:UnregisterEvent("ROLE_POLL_BEGIN")
end
