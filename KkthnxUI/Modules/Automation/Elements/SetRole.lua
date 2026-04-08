--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Automatically sets the player's group role based on their active specialization.
-- - Design: Hooks talent and group roster updates to call UnitSetRole when appropriate.
-- - Events: PLAYER_TALENT_UPDATE, GROUP_ROSTER_UPDATE
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Automation")

-- PERF: Localize globals and API functions to minimize lookup overhead.
local _G = _G
local GetSpecialization = GetSpecialization
local GetSpecializationRole = GetSpecializationRole
local GetTime = GetTime
local InCombatLockdown = InCombatLockdown
local IsInGroup = IsInGroup
local IsPartyLFG = IsPartyLFG
local UnitGroupRolesAssigned = UnitGroupRolesAssigned
local UnitSetRole = UnitSetRole

-- ---------------------------------------------------------------------------
-- Constants & State
-- ---------------------------------------------------------------------------
local ROLE_CHANGE_THRESHOLD = 2
local lastRoleChangeTime = 0

-- ---------------------------------------------------------------------------
-- Internal Logic
-- ---------------------------------------------------------------------------
local function changePlayerRole(role)
	-- REASON: Throttles role changes to prevent spamming the server and ensures role is actually different.
	local currentTime = GetTime()
	if (currentTime - lastRoleChangeTime > ROLE_CHANGE_THRESHOLD) and UnitGroupRolesAssigned("player") ~= role then
		UnitSetRole("player", role)
		lastRoleChangeTime = currentTime
	end
end

local function shouldSetupAutoRole()
	-- REASON: Only automate roles for players above level 10 in non-LFG groups while out of combat.
	return K.Level >= 10 and not InCombatLockdown() and IsInGroup() and not IsPartyLFG()
end

-- ---------------------------------------------------------------------------
-- Automation Functions
-- ---------------------------------------------------------------------------
function Module:SetupAutoRole()
	if not shouldSetupAutoRole() then
		return
	end

	local spec = GetSpecialization()
	if spec then
		local role = GetSpecializationRole(spec)
		-- REASON: Automatically set role based on the specialization's intended role (TANK, HEALER, DAMAGER).
		if role and role ~= "NONE" then
			changePlayerRole(role)
		end
	end
end

-- ---------------------------------------------------------------------------
-- Module Registration
-- ---------------------------------------------------------------------------
function Module:CreateAutoSetRole()
	local rolePollPopup = _G.RolePollPopup

	if not C["Automation"].AutoSetRole then
		K:UnregisterEvent("PLAYER_TALENT_UPDATE", self.SetupAutoRole)
		K:UnregisterEvent("GROUP_ROSTER_UPDATE", self.SetupAutoRole)
		-- REASON: Re-enable the standard Blizzard popup if automation is disabled.
		if rolePollPopup and rolePollPopup.RegisterEvent then
			rolePollPopup:RegisterEvent("ROLE_POLL_BEGIN")
		end
		return
	end

	K:RegisterEvent("PLAYER_TALENT_UPDATE", self.SetupAutoRole)
	K:RegisterEvent("GROUP_ROSTER_UPDATE", self.SetupAutoRole)

	-- REASON: Suppress the standard Blizzard role poll popup when automation is handling roles.
	if rolePollPopup and rolePollPopup.UnregisterEvent then
		rolePollPopup:UnregisterEvent("ROLE_POLL_BEGIN")
	end

	self:SetupAutoRole()
end
