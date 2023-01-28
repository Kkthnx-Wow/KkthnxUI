local K, C = unpack(KkthnxUI)
local Module = K:GetModule("Automation")

-- Automatically sets your role (iSpawnAtHome)

local GetSpecialization = GetSpecialization
local GetSpecializationRole = GetSpecializationRole
local GetTime = GetTime
local InCombatLockdown = InCombatLockdown
local IsInGroup = IsInGroup
local IsPartyLFG = IsPartyLFG
local UnitGroupRolesAssigned = UnitGroupRolesAssigned
local UnitSetRole = UnitSetRole

local prev = 0 -- variable to store the previous time the role was set
local playerRole = nil -- variable to store the player's current role

function Module:SetupAutoRole()
	if K.Level >= 10 and not InCombatLockdown() and IsInGroup() and not IsPartyLFG() then
		local spec = GetSpecialization()
		if spec then
			local role = GetSpecializationRole(spec) -- Check the current role of the player's current specialization
			if playerRole ~= role then
				if UnitGroupRolesAssigned("player") ~= role then
					local t = GetTime()
					if t - prev > 2 then -- Check if it's been more than 2 seconds since the last role change
						prev = t
						UnitSetRole("player", role) -- set the player's role
						playerRole = role -- Update the stored value of the player's role
						return
					end
				end
			end
		else -- If there is no specialization, set No Role as default.
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
