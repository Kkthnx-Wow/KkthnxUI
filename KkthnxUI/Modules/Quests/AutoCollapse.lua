local K, C, L, _ = select(2, ...):unpack()

local WatchFrame
local AutoCollapse = CreateFrame("Frame")

if C.Automation.AutoCollapse ~= true or K.IsAddOnEnabled("QuestHelper") == true then
	AutoCollapse:UnregisterEvent("PLAYER_ENTERING_WORLD")
	AutoCollapse:UnregisterEvent("PLAYER_UPDATE_RESTING")
end

AutoCollapse:RegisterEvent("PLAYER_ENTERING_WORLD")
AutoCollapse:RegisterEvent("PLAYER_UPDATE_RESTING")
AutoCollapse:SetScript("OnEvent", function(self, event)
	if UnitAffectingCombat("player") then self:RegisterEvent("PLAYER_REGEN_ENABLED") return end

	if IsResting() then
		ObjectiveTrackerFrame.userCollapsed = true
		ObjectiveTracker_Collapse(WatchFrame)
		ObjectiveTrackerFrame:Show()
	else
		if IsInInstance() then
			ObjectiveTrackerFrame.userCollapsed = true
			ObjectiveTracker_Collapse(WatchFrame)
			ObjectiveTrackerFrame:Show()
		elseif ObjectiveTrackerFrame.collapsed and not InCombatLockdown() then
			ObjectiveTrackerFrame.userCollapsed = false
			ObjectiveTracker_Expand(WatchFrame)
			ObjectiveTrackerFrame:Show()
		else
			ObjectiveTrackerFrame.userCollapsed = false
			ObjectiveTracker_Expand(WatchFrame)
			ObjectiveTrackerFrame:Show()
		end
	end

	self:UnregisterEvent("PLAYER_REGEN_ENABLED")
end)