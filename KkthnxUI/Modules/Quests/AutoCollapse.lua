local K, C, L, _ = select(2, ...):unpack()
if C.Automation.AutoCollapse ~= true or IsAddOnLoaded("QuestHelper") == true then return end

local AutoCollapse = CreateFrame("Frame")

local watchFrame
function AutoCollapse:CollapseObjective(event)
	if UnitAffectingCombat("player") then self:RegisterEvent("PLAYER_REGEN_ENABLED", "CollapseObjective") return end

	if IsResting() then
		if (not ObjectiveTrackerFrame.collapsed) then
			ObjectiveTracker_Collapse()
		end
	else
		local instance, instanceType = IsInInstance()
		if instanceType == "pvp" then
			if (not ObjectiveTrackerFrame.collapsed) then
				ObjectiveTrackerFrame.userCollapsed = true
				ObjectiveTracker_Collapse(watchFrame)
				ObjectiveTrackerFrame:Show()
			end
		elseif instanceType == "arena" then
			if (not ObjectiveTrackerFrame.collapsed) then
				ObjectiveTrackerFrame.userCollapsed = true
				ObjectiveTracker_Collapse(watchFrame)
				ObjectiveTrackerFrame:Show()
			end
		elseif instanceType == "party" then
			if (not ObjectiveTrackerFrame.collapsed) then
				ObjectiveTrackerFrame.userCollapsed = true
				ObjectiveTracker_Collapse(watchFrame)
				ObjectiveTrackerFrame:Show()
			end
		elseif instanceType == "raid" then
			if (not ObjectiveTrackerFrame.collapsed) then
				ObjectiveTrackerFrame.userCollapsed = true
				ObjectiveTracker_Collapse(watchFrame)
				ObjectiveTrackerFrame:Show()
			end
		else
			if ObjectiveTrackerFrame.collapsed then
				ObjectiveTrackerFrame.userCollapsed = false
				ObjectiveTracker_Expand(watchFrame)
				ObjectiveTrackerFrame:Show()
			end
		end
	end

	self:UnregisterEvent("PLAYER_REGEN_ENABLED")
end

function AutoCollapse:OnEvent(event)
	if (event == "PLAYER_ENTERING_WORLD") then
		 AutoCollapse:CollapseObjective()
	end

	AutoCollapse:UnregisterEvent("PLAYER_ENTERING_WORLD")
end

AutoCollapse:RegisterEvent("PLAYER_ENTERING_WORLD", "CollapseObjective")
AutoCollapse:RegisterEvent("PLAYER_UPDATE_RESTING", "CollapseObjective")
AutoCollapse:SetScript("OnEvent", AutoCollapse.OnEvent)