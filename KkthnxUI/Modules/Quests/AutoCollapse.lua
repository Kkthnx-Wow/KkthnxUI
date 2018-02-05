local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("AutoCollapse", "AceEvent-3.0")

-- Sourced: ElvUI Shadow & Light (Darth_Predator, Repooc)

-- Wow Lua
local _G = _G

-- Wow API
local C_Garrison_IsPlayerInGarrison = _G.C_Garrison.IsPlayerInGarrison
local InCombatLockdown = _G.InCombatLockdown
local IsInInstance = _G.IsInInstance
local IsResting = _G.IsResting
local ObjectiveTracker_Expand, ObjectiveTracker_Collapse = _G.ObjectiveTracker_Expand, _G.ObjectiveTracker_Collapse

local minimizeButton = _G["ObjectiveTrackerFrame"].HeaderMenu.MinimizeButton

local statedriver = {
	["FULL"] = function(frame)
		ObjectiveTracker_Expand()
		minimizeButton.text:SetText("-")
		frame:Show()
	end,

	["COLLAPSED"] = function(frame)
		ObjectiveTracker_Collapse()
		minimizeButton.text:SetText("+")
		frame:Show()
	end,

	["HIDE"] = function(frame)
		frame:Hide()
	end,
}

function Module:ChangeState(event)
	if InCombatLockdown() and event ~= "PLAYER_REGEN_DISABLED" then
		return
	end

	local inCombat = event == "PLAYER_REGEN_DISABLED" and true or false

	if inCombat and C["Quests"].Combat.Value ~= "NONE" then
		statedriver[C["Quests"].Combat.Value](Module.frame)
	elseif C_Garrison_IsPlayerInGarrison(2) then
		statedriver[C["Quests"].Garrison.Value](Module.frame)
	elseif C_Garrison_IsPlayerInGarrison(3) then --here be order halls
		statedriver[C["Quests"].Orderhall.Value](Module.frame)
	elseif IsResting() then
		statedriver[C["Quests"].Rested.Value](Module.frame)
	else
		local instance, instanceType = IsInInstance()
		if instance then
			if instanceType == "pvp" then
				statedriver[C["Quests"].Battleground.Value](Module.frame)
			elseif instanceType == "arena" then
				statedriver[C["Quests"].Arena.Value](Module.frame)
			elseif instanceType == "party" then
				statedriver[C["Quests"].Dungeon.Value](Module.frame)
			elseif instanceType == "scenario" then
				statedriver[C["Quests"].Scenario.Value](Module.frame)
			elseif instanceType == "raid" then
				statedriver[C["Quests"].Raid.Value](Module.frame)
			end
		else
			statedriver["FULL"](Module.frame)
		end
	end
end

function Module:OnEnable()
	if C["Quests"].AutoCollapse ~= true then return end

	Module.frame = ObjectiveTrackerFrame
	self:RegisterEvent("LOADING_SCREEN_DISABLED", "ChangeState")
	self:RegisterEvent("PLAYER_UPDATE_RESTING", "ChangeState")
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA", "ChangeState")
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "ChangeState")
	self:RegisterEvent("PLAYER_REGEN_DISABLED", "ChangeState")

	Module:ChangeState()
end

K["AutoCollapse"] = Module