local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("AutoCollapse_ObjectiveTracker", "AceEvent-3.0")

-- Wow Lua
local _G = _G

-- Wow API
local C_Garrison_IsPlayerInGarrison = _G.C_Garrison.IsPlayerInGarrison
local InCombatLockdown = _G.InCombatLockdown
local IsInInstance = _G.IsInInstance
local IsResting = _G.IsResting
local ObjectiveTracker_Expand, ObjectiveTracker_Collapse = _G.ObjectiveTracker_Expand, _G.ObjectiveTracker_Collapse

-- Global variables that we don"t cache, list them here for mikk"s FindGlobals script
-- GLOBALS: ObjectiveTrackerFrame, WorldQuestTrackerAddon

local minimizeButton = _G["ObjectiveTrackerFrame"].HeaderMenu.MinimizeButton

local statedriver = {
	["FULL"] = function(frame)
		ObjectiveTracker_Expand()
		frame:Show()
	end,

	["COLLAPSED"] = function(frame)
		ObjectiveTracker_Collapse()
		frame:Show()
	end,

	["HIDE"] = function(frame)
		frame:Hide()
	end,
}

function Module:ChangeState(event)
	if InCombatLockdown() then
		self:RegisterEvent("PLAYER_REGEN_ENABLED", "ChangeState")
		return
	end

	if event == "PLAYER_REGEN_ENABLED" then
		self:UnregisterEvent("PLAYER_REGEN_ENABLED")
	end

	if C_Garrison_IsPlayerInGarrison(2) then
		statedriver["FULL"](Module.frame)
		-- here be order halls
	elseif C_Garrison_IsPlayerInGarrison(3) then
		statedriver["FULL"](Module.frame)
	elseif IsResting() then
		statedriver["FULL"](Module.frame)
	else
		local instance, instanceType = IsInInstance()
		if instance then
			if instanceType == "pvp" then
				statedriver["COLLAPSED"](Module.frame)
			elseif instanceType == "arena" then
				statedriver["COLLAPSED"](Module.frame)
			elseif instanceType == "party" then
				statedriver["FULL"](Module.frame)
			elseif instanceType == "scenario" then
				statedriver["FULL"](Module.frame)
			elseif instanceType == "raid" then
				statedriver["COLLAPSED"](Module.frame)
			end
		else
			statedriver["FULL"](Module.frame)
		end
	end

	-- if K.IsAddOnEnabled("WorldQuestTracker") then

	-- 	if (not ObjectiveTrackerFrame.initialized) then
	-- 		return
	-- 	end

	-- 	local y = 0
	-- 	for i = 1, #ObjectiveTrackerFrame.MODULES do
	-- 		local module = ObjectiveTrackerFrame.MODULES[i]
	-- 		if (module.Header:IsShown()) then
	-- 			y = y + module.contentsHeight
	-- 		end
	-- 	end
	-- 	if (ObjectiveTrackerFrame.collapsed) then
	-- 		WorldQuestTrackerAddon.TrackerHeight = 20
	-- 	else
	-- 		WorldQuestTrackerAddon.TrackerHeight = y
	-- 	end

	-- 	WorldQuestTrackerAddon.RefreshAnchor()
	-- end
end

function Module:OnEnable()
	if C["Automation"].AutoCollapse ~= true then return end

	Module.frame = ObjectiveTrackerFrame
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "ChangeState")
	self:RegisterEvent("PLAYER_UPDATE_RESTING", "ChangeState")

	Module:ChangeState()
end

function Module:OnDisable()
	Module.frame = nil
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	self:UnregisterEvent("PLAYER_UPDATE_RESTING")
end

K["AutoCollapse"] = Module