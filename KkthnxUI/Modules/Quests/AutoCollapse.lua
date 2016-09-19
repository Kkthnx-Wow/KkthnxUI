local K, C, L, _ = select(2, ...):unpack()
if C.Automation.AutoCollapse ~= true or IsAddOnLoaded("QuestHelper") == true then return end

C["ObjectiveTracker"] = {
	["Enable"] = true,
	["City"] = "COLLAPSED",
	["PvP"] = "HIDDEN",
	["Arena"] = "HIDDEN",
	["Party"] = "COLLAPSED",
	["Raid"] = "COLLAPSED",
}


local CreateFrame = CreateFrame
local IsInInstance = IsInInstance
local InCombatLockdown = InCombatLockdown

-- AUTO COLLAPSE WatchFrame
local AutoCollapse = CreateFrame("Frame")
local Loading = CreateFrame("Frame")
local WatchFrame

local StateDriver = {
	["NONE"] = function(frame)
		ObjectiveTrackerFrame.userCollapsed = false
		ObjectiveTracker_Expand(WatchFrame)
		ObjectiveTrackerFrame:Show()
	end,
	["COLLAPSED"] = function(frame)
		ObjectiveTrackerFrame.userCollapsed = true
		ObjectiveTracker_Collapse(WatchFrame)
		ObjectiveTrackerFrame:Show()
	end,
	["HIDDEN"] = function(frame)
		ObjectiveTrackerFrame:Hide()
	end,
}

function AutoCollapse:ChangeState(event)
	if UnitAffectingCombat("player") then self:RegisterEvent("PLAYER_REGEN_ENABLED", "ChangeState") return end

	if IsResting() then
		StateDriver[C.ObjectiveTracker.City](WatchFrame)
	else
		local instance, instanceType = IsInInstance()
		if instanceType == "pvp" then
			StateDriver[C.ObjectiveTracker.PVP](WatchFrame)
		elseif instanceType == "arena" then
			StateDriver[C.ObjectiveTracker.Arena](WatchFrame)
		elseif instanceType == "party" then
			StateDriver[C.ObjectiveTracker.Party](WatchFrame)
		elseif instanceType == "raid" then
			StateDriver[C.ObjectiveTracker.Raid](WatchFrame)
		else
			StateDriver["NONE"](WatchFrame)
		end
	end

	self:UnregisterEvent("PLAYER_REGEN_ENABLED")
end

function AutoCollapse:UpdateSettings()
	if C.ObjectiveTracker.Enable then
		self:RegisterEvent("PLAYER_ENTERING_WORLD", "ChangeState")
		self:RegisterEvent("PLAYER_UPDATE_RESTING", "ChangeState")
	else
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
		self:UnregisterEvent("PLAYER_UPDATE_RESTING")
	end
end

function AutoCollapse:Initialize()
	WatchFrame = _G["WatchFrame"]
	AutoCollapse:UpdateSettings()
end

function Loading:OnEvent(event)
	if (event == "PLAYER_ENTERING_WORLD") then
		AutoCollapse:Initialize()
	end
end

Loading:RegisterEvent("PLAYER_ENTERING_WORLD")
Loading:SetScript("OnEvent", Loading.OnEvent)