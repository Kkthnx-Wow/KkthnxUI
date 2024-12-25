local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Automation")

-- WoW API functions
local GetSpecialization = GetSpecialization
local GetSpecializationRole = GetSpecializationRole
local GetTime = GetTime
local InCombatLockdown = InCombatLockdown
local IsInGroup = IsInGroup
local IsPartyLFG = IsPartyLFG
local UnitGroupRolesAssigned = UnitGroupRolesAssigned
local UnitSetRole = UnitSetRole

-- Local variables
local lastRoleChangeTime = 0
local ROLE_CHANGE_THRESHOLD = 2

-- Function to change the player's role
local function ChangePlayerRole(role)
	local currentTime = GetTime()
	if (currentTime - lastRoleChangeTime > ROLE_CHANGE_THRESHOLD) and UnitGroupRolesAssigned("player") ~= role then
		UnitSetRole("player", role)
		lastRoleChangeTime = currentTime
	end
end

-- Function to determine if auto role setup should run
local function ShouldSetupAutoRole()
	return K.Level >= 10 and not InCombatLockdown() and IsInGroup() and not IsPartyLFG()
end

-- Setup auto role function
function Module:SetupAutoRole()
	if not ShouldSetupAutoRole() then
		return
	end

	local spec = GetSpecialization()
	if spec then
		local role = GetSpecializationRole(spec)
		ChangePlayerRole(role)
	end
end

-- Create auto set role function
function Module:CreateAutoSetRole()
	if not C["Automation"].AutoSetRole then
		K:UnregisterEvent("PLAYER_TALENT_UPDATE", self.SetupAutoRole)
		K:UnregisterEvent("GROUP_ROSTER_UPDATE", self.SetupAutoRole)
		return
	end

	K:RegisterEvent("PLAYER_TALENT_UPDATE", self.SetupAutoRole)
	K:RegisterEvent("GROUP_ROSTER_UPDATE", self.SetupAutoRole)

	RolePollPopup:UnregisterEvent("ROLE_POLL_BEGIN")
end
