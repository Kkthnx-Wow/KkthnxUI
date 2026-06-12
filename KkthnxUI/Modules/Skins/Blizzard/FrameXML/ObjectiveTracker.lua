--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Skins the Blizzard Objective Tracker frame.
-- - Design: Restyles headers, progress bars, and minimize buttons.
-- - Events: N/A
-----------------------------------------------------------------------------]]

local K, C = _G["KkthnxUI"][1], _G["KkthnxUI"][2]

-- REASON: Localize globals for performance and stack safety.
local _G = _G
local pairs = _G.pairs
local hooksecurefunc = _G.hooksecurefunc

local C_AddOns_IsAddOnLoaded = _G.C_AddOns.IsAddOnLoaded

local function SkinOjectiveTrackerHeaders(header)
	if header and header.Background then
		header.Background:Hide()
	end
end

local function SetCollapsed(header, collapsed)
	local MinimizeButton = header and header.MinimizeButton
	if not MinimizeButton then
		return
	end

	local normalTexture = MinimizeButton:GetNormalTexture()
	local pushedTexture = MinimizeButton:GetPushedTexture()
	if not (normalTexture and pushedTexture) then
		return
	end

	if collapsed then
		normalTexture:SetAtlas("UI-QuestTrackerButton-Secondary-Expand", true)
		pushedTexture:SetAtlas("UI-QuestTrackerButton-Secondary-Expand-Pressed", true)
	else
		normalTexture:SetAtlas("UI-QuestTrackerButton-Secondary-Collapse", true)
		pushedTexture:SetAtlas("UI-QuestTrackerButton-Secondary-Collapse-Pressed", true)
	end
end

local function ReskinBarTemplate(bar)
	-- bar:SetStatusBarTexture(K.GetTexture(C["General"].Texture))
	if bar then
		bar:SetStatusBarColor(K.r, K.g, K.b)
	end
end

local function HandleProgressBar(tracker, key)
	local progressBar = tracker.usedProgressBars and tracker.usedProgressBars[key]
	ReskinBarTemplate(progressBar and progressBar.Bar)
end

local function HandleTimers(tracker, key)
	local timerBar = tracker.usedTimerBars and tracker.usedTimerBars[key]
	ReskinBarTemplate(timerBar and timerBar.Bar)
end

-- REASON: Main entry point for Blizzard Objective Tracker skinning.
C.themes["Blizzard_ObjectiveTracker"] = function()
	if C_AddOns_IsAddOnLoaded("!KalielsTracker") then
		return
	end

	local TrackerFrame = _G["ObjectiveTrackerFrame"]
	local TrackerHeader = TrackerFrame and TrackerFrame.Header
	if TrackerHeader then
		SkinOjectiveTrackerHeaders(TrackerHeader)

		local MinimizeButton = TrackerHeader.MinimizeButton
		if MinimizeButton then
			MinimizeButton:SetSize(16, 16)
			MinimizeButton:SetHighlightAtlas("UI-QuestTrackerButton-Yellow-Highlight", "ADD")

			SetCollapsed(TrackerHeader, TrackerFrame.isCollapsed)
			hooksecurefunc(TrackerHeader, "SetCollapsed", SetCollapsed)
		end
	end

	local trackers = {
		_G["ScenarioObjectiveTracker"],
		_G["UIWidgetObjectiveTracker"],
		_G["CampaignQuestObjectiveTracker"],
		_G["QuestObjectiveTracker"],
		_G["AdventureObjectiveTracker"],
		_G["AchievementObjectiveTracker"],
		_G["MonthlyActivitiesObjectiveTracker"],
		_G["ProfessionsRecipeTracker"],
		_G["BonusObjectiveTracker"],
		_G["WorldQuestObjectiveTracker"],
	}

	for _, tracker in pairs(trackers) do
		if tracker then
			SkinOjectiveTrackerHeaders(tracker.Header)
			if tracker.GetProgressBar then
				hooksecurefunc(tracker, "GetProgressBar", HandleProgressBar)
			end
			if tracker.GetTimerBar then
				hooksecurefunc(tracker, "GetTimerBar", HandleTimers)
			end
		end
	end
end
