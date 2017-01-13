local K, C, L = unpack(select(2, ...))
if C.Automation.AutoCollapse ~= true then return end

-- Wow API
local UnitAffectingCombat = UnitAffectingCombat
local IsResting = IsResting
local IsInInstance = IsInInstance

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: ObjectiveTrackerFrame, ObjectiveTracker_Expand, ObjectiveTracker_Collapse

local watchFrame

local statedriver = {
	["NONE"] = function(frame)
		ObjectiveTrackerFrame.userCollapsed = false
		ObjectiveTracker_Expand(watchFrame)
		ObjectiveTrackerFrame:Show()
	end,
	["COLLAPSED"] = function(frame)
		ObjectiveTrackerFrame.userCollapsed = true
		ObjectiveTracker_Collapse(watchFrame)
		ObjectiveTrackerFrame:Show()
	end,
	-- ["HIDDEN"] = function(frame)
	-- 	ObjectiveTrackerFrame:Hide()
	-- end,
}

local AutoCollapse = CreateFrame("Frame")
AutoCollapse:RegisterEvent("PLAYER_ENTERING_WORLD")
AutoCollapse:RegisterEvent("PLAYER_UPDATE_RESTING")
AutoCollapse:SetScript("OnEvent", function(self, event)
	if UnitAffectingCombat("player") then self:RegisterEvent("PLAYER_REGEN_ENABLED") return end

	if IsResting() then
		statedriver["COLLAPSED"](watchFrame)
	else
		local instance, instanceType = IsInInstance()
		if instanceType == "pvp" then
			statedriver["COLLAPSED"](watchFrame)
		elseif instanceType == "arena" then
			statedriver["COLLAPSED"](watchFrame)
		elseif instanceType == "party" then
			statedriver["COLLAPSED"](watchFrame)
		elseif instanceType == "raid" then
			statedriver["COLLAPSED"](watchFrame)
		else
			statedriver["NONE"](watchFrame)
		end
	end

	if event == "PLAYER_REGEN_ENABLED" then
		self:UnregisterEvent("PLAYER_REGEN_ENABLED")
	end
end)