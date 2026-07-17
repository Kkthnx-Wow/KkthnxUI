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
-- BUGFIX: GetSpecializationRole,
-- UnitSetRole, and UnitGroupRolesAssigned (the legacy string-role APIs previously
-- used here) do not appear anywhere in Resources/GlobalAPI.lua — only the Enum-based
-- forms do. Per this addon's own "if not listed, it's deprecated/removed" rule, this
-- feature was very likely broken. Switched to the verified Enum-based APIs.
local GetSpecializationRoleEnum = GetSpecializationRoleEnum
local GetTime = GetTime
local InCombatLockdown = InCombatLockdown
local IsInGroup = IsInGroup
local IsPartyLFG = IsPartyLFG
local UnitGetAvailableRoles = UnitGetAvailableRoles
local UnitGroupRolesAssignedEnum = UnitGroupRolesAssignedEnum
local UnitSetRoleEnum = UnitSetRoleEnum
local AreClassRolesSoftSuggestions = AreClassRolesSoftSuggestions
local CanShowSetRoleButton = CanShowSetRoleButton
local HasLFGRestrictions = HasLFGRestrictions
local C_SpecializationInfo_GetSpecialization = _G.C_SpecializationInfo and _G.C_SpecializationInfo.GetSpecialization
local C_Scenario_IsInScenario = _G.C_Scenario and _G.C_Scenario.IsInScenario

local LFGRole = Enum.LFGRole

-- ---------------------------------------------------------------------------
-- Constants & State
-- ---------------------------------------------------------------------------
local ROLE_CHANGE_THRESHOLD = 2
local MIN_SPEC_LEVEL = 10
local lastRoleChangeTime = 0

-- ---------------------------------------------------------------------------
-- Internal Logic
-- ---------------------------------------------------------------------------
-- REASON: a role can be soft-suggested-only for the
-- player's class/spec; check availability via UnitGetAvailableRoles instead of
-- assuming the spec's default role is always settable.
local function roleIsAvailable(roleEnum)
	if not roleEnum then
		return true
	end
	if AreClassRolesSoftSuggestions and AreClassRolesSoftSuggestions() then
		return true
	end
	local canTank, canHeal, canDps = UnitGetAvailableRoles("player")
	if roleEnum == LFGRole.Tank then
		return canTank
	elseif roleEnum == LFGRole.Healer then
		return canHeal
	elseif roleEnum == LFGRole.Damage then
		return canDps
	end
	return false
end

local function changePlayerRole(role)
	-- REASON: Throttles role changes to prevent spamming the server and ensures role is actually different.
	local currentTime = GetTime()
	if (currentTime - lastRoleChangeTime > ROLE_CHANGE_THRESHOLD) and UnitGroupRolesAssignedEnum("player") ~= role then
		UnitSetRoleEnum("player", role)
		lastRoleChangeTime = currentTime
	end
end

-- REASON: mirrors the actual conditions Blizzard uses
-- before showing its own Set Role UI (CanShowSetRoleButton, HasLFGRestrictions,
-- scenario check) — the previous check only covered level/combat/group/LFG.
local function shouldSetupAutoRole()
	if InCombatLockdown() or not IsInGroup() then
		return false
	end
	if (K.Level or 0) < MIN_SPEC_LEVEL then
		return false
	end
	if CanShowSetRoleButton and not CanShowSetRoleButton() then
		return false
	end
	if IsPartyLFG and IsPartyLFG() then
		return false
	end
	if HasLFGRestrictions and HasLFGRestrictions() then
		return false
	end
	if C_Scenario_IsInScenario and C_Scenario_IsInScenario() then
		return false
	end
	return true
end

-- ---------------------------------------------------------------------------
-- Automation Functions
-- ---------------------------------------------------------------------------
function Module.SetupAutoRole(event)
	if not shouldSetupAutoRole() then
		return
	end

	local spec = C_SpecializationInfo_GetSpecialization and C_SpecializationInfo_GetSpecialization()
	if not spec then
		return
	end

	local role = GetSpecializationRoleEnum(spec)
	-- REASON: Automatically set role based on the specialization's intended role (Tank/Healer/Damage).
	if role and roleIsAvailable(role) then
		changePlayerRole(role)
	end
end

-- ---------------------------------------------------------------------------
-- Module Registration
-- ---------------------------------------------------------------------------
function Module:CreateAutoSetRole()
	local rolePollPopup = _G.RolePollPopup

	if not C["Automation"].AutoSetRole then
		K:UnregisterEvent("PLAYER_TALENT_UPDATE", Module.SetupAutoRole)
		K:UnregisterEvent("GROUP_ROSTER_UPDATE", Module.SetupAutoRole)
		-- REASON: Re-enable the standard Blizzard popup if automation is disabled.
		if rolePollPopup and rolePollPopup.RegisterEvent then
			rolePollPopup:RegisterEvent("ROLE_POLL_BEGIN")
		end
		return
	end

	K:RegisterEvent("PLAYER_TALENT_UPDATE", Module.SetupAutoRole)
	K:RegisterEvent("GROUP_ROSTER_UPDATE", Module.SetupAutoRole)

	-- REASON: Suppress the standard Blizzard role poll popup when automation is handling roles.
	if rolePollPopup and rolePollPopup.UnregisterEvent then
		rolePollPopup:UnregisterEvent("ROLE_POLL_BEGIN")
	end

	Module.SetupAutoRole()
end
