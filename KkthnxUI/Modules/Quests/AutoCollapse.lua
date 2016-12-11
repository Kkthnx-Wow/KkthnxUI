local K, C, L = unpack(select(2, ...))

local AutoCollapse = CreateFrame("Frame")
AutoCollapse:RegisterEvent("PLAYER_ENTERING_WORLD")
AutoCollapse:SetScript("OnEvent", function(self, event)
	if IsInInstance() then
		ObjectiveTracker_Collapse()
	elseif ObjectiveTrackerFrame.collapsed and not InCombatLockdown() then
		ObjectiveTracker_Expand()
	end
end)