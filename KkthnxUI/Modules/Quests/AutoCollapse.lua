local K, C, L, _ = select(2, ...):unpack()
if C.Automation.AutoCollapse ~= true or IsAddOnLoaded("QuestHelper") == true then return end

local CreateFrame = CreateFrame
local IsInInstance = IsInInstance
local InCombatLockdown = InCombatLockdown

-- AUTO COLLAPSE WATCHFRAME
local AutoCollapse = CreateFrame("Frame")
AutoCollapse:RegisterEvent("ZONE_CHANGED_NEW_AREA")
AutoCollapse:RegisterEvent("PLAYER_ENTERING_WORLD")
AutoCollapse:SetScript("OnEvent", function(self, event)
	if IsInInstance() and not ScenarioBlocksFrame:IsVisible() then
		ObjectiveTrackerFrame.collapsed = true
		ObjectiveTracker_Collapse()
	elseif ObjectiveTrackerFrame.collapsed and not InCombatLockdown() then
		ObjectiveTrackerFrame.collapsed = nil
		ObjectiveTracker_Expand()
	end
end)