local K, C = KkthnxUI[1], KkthnxUI[2]

local _G = _G

local tinsert = table.insert
local pairs = pairs

local function SkinOjectiveTrackerHeaders(header)
	if header and header.Background then
		header.Background:SetAtlas(nil)
	end
end

local function SetCollapsed(header, collapsed)
	local MinimizeButton = header.MinimizeButton
	local normalTexture = MinimizeButton:GetNormalTexture()
	local pushedTexture = MinimizeButton:GetPushedTexture()

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
	bar:SetStatusBarColor(K.r, K.g, K.b)
end

local function HandleProgressBar(tracker, key)
	local progressBar = tracker.usedProgressBars[key]
	local bar = progressBar and progressBar.Bar

	if bar then
		ReskinBarTemplate(bar)
	end
end

local function HandleTimers(tracker, key)
	local timerBar = tracker.usedTimerBars[key]
	local bar = timerBar and timerBar.Bar

	if bar then
		ReskinBarTemplate(bar)
	end
end

C.themes["Blizzard_ObjectiveTracker"] = function()
	if C_AddOns.IsAddOnLoaded("!KalielsTracker") then
		return
	end

	local TrackerFrame = _G.ObjectiveTrackerFrame
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
		_G.ScenarioObjectiveTracker,
		_G.UIWidgetObjectiveTracker,
		_G.CampaignQuestObjectiveTracker,
		_G.QuestObjectiveTracker,
		_G.AdventureObjectiveTracker,
		_G.AchievementObjectiveTracker,
		_G.MonthlyActivitiesObjectiveTracker,
		_G.ProfessionsRecipeTracker,
		_G.BonusObjectiveTracker,
		_G.WorldQuestObjectiveTracker,
	}

	for _, tracker in pairs(trackers) do
		SkinOjectiveTrackerHeaders(tracker.Header)
		hooksecurefunc(tracker, "GetProgressBar", HandleProgressBar)
		hooksecurefunc(tracker, "GetTimerBar", HandleTimers)
	end
end
