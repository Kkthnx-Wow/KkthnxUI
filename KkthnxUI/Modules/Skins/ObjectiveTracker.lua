--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/Skins/ObjectiveTracker.lua
	Purpose:
		Tidy the Blizzard quest / objective tracker so it sits quietly in the
		corner: hide the busy header backgrounds on the frame and every sub-tracker,
		shrink and clean the minimise button, and recolour quest progress and timer
		bars to a single calm colour (class colour, or our accent).

		The tracker lives in the load-on-demand Blizzard_ObjectiveTracker, so we
		style on enable if it is already loaded, otherwise wait for its ADDON_LOADED.
		Everything is a cosmetic hooksecurefunc, so no taint on the secure tracker.
		Retail only: older flavours use a different quest watch frame.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

if not (K.Client and K.Client.IsRetail) then
	return
end

local Module = K:NewModule("ObjectiveTracker")

local _G = _G
local hooksecurefunc = hooksecurefunc
local C_AddOns = C_AddOns

-- Fallback tint when the class-colour option is off.
local ACCENT = { 0.36, 0.55, 0.81 }

-- ---------------------------------------------------------------------------
-- Colour
-- ---------------------------------------------------------------------------

local function GetBarColor()
	if C.Skins.ObjectiveTrackerClassColor then
		local c = K.ClassColor
		return c.r or c[1], c.g or c[2], c.b or c[3]
	end
	return ACCENT[1], ACCENT[2], ACCENT[3]
end

local function ReskinBar(bar)
	if bar and C.Skins.ObjectiveTracker then
		bar:SetStatusBarColor(GetBarColor())
	end
end

-- ---------------------------------------------------------------------------
-- Header + minimise button
-- ---------------------------------------------------------------------------

local function HideHeaderBackground(header)
	if header and header.Background then
		header.Background:Hide()
	end
end

-- Swap the minimise button art for the smaller secondary set so it reads as a
-- quiet chevron rather than the loud stock button.
local function SetCollapsed(header, collapsed)
	local minimize = header and header.MinimizeButton
	if not minimize then
		return
	end
	local normal = minimize:GetNormalTexture()
	local pushed = minimize:GetPushedTexture()
	if not (normal and pushed) then
		return
	end
	if collapsed then
		normal:SetAtlas("UI-QuestTrackerButton-Secondary-Expand", true)
		pushed:SetAtlas("UI-QuestTrackerButton-Secondary-Expand-Pressed", true)
	else
		normal:SetAtlas("UI-QuestTrackerButton-Secondary-Collapse", true)
		pushed:SetAtlas("UI-QuestTrackerButton-Secondary-Collapse-Pressed", true)
	end
end

-- ---------------------------------------------------------------------------
-- Per-tracker progress / timer bars (created on demand by Blizzard)
-- ---------------------------------------------------------------------------

local function HandleProgressBar(tracker, key)
	local progressBar = tracker.usedProgressBars and tracker.usedProgressBars[key]
	ReskinBar(progressBar and progressBar.Bar)
end

local function HandleTimerBar(tracker, key)
	local timerBar = tracker.usedTimerBars and tracker.usedTimerBars[key]
	ReskinBar(timerBar and timerBar.Bar)
end

-- ---------------------------------------------------------------------------
-- Styling
-- ---------------------------------------------------------------------------

function Module:Style()
	if self.styled then
		return
	end
	local trackerFrame = _G.ObjectiveTrackerFrame
	if not trackerFrame then
		return
	end
	self.styled = true

	local header = trackerFrame.Header
	if header then
		HideHeaderBackground(header)

		local minimize = header.MinimizeButton
		if minimize then
			minimize:SetSize(16, 16)
			if minimize.SetHighlightAtlas then
				minimize:SetHighlightAtlas("UI-QuestTrackerButton-Yellow-Highlight", "ADD")
			end
			SetCollapsed(header, trackerFrame.isCollapsed)
			hooksecurefunc(header, "SetCollapsed", SetCollapsed)
		end
	end

	-- Every sub-tracker that owns a header and progress/timer bar pools.
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

	for i = 1, #trackers do
		local tracker = trackers[i]
		if tracker then
			HideHeaderBackground(tracker.Header)
			if tracker.GetProgressBar then
				hooksecurefunc(tracker, "GetProgressBar", HandleProgressBar)
			end
			if tracker.GetTimerBar then
				hooksecurefunc(tracker, "GetTimerBar", HandleTimerBar)
			end
		end
	end
end

-- ---------------------------------------------------------------------------
-- Lifecycle
-- ---------------------------------------------------------------------------

function Module:ADDON_LOADED(_, addon)
	if addon == "Blizzard_ObjectiveTracker" then
		self:Style()
		self:UnregisterEvent("ADDON_LOADED")
	end
end

function Module:OnEnable()
	if not C.Skins.ObjectiveTracker then
		return
	end
	if C_AddOns and C_AddOns.IsAddOnLoaded("Blizzard_ObjectiveTracker") then
		self:Style()
	else
		self:RegisterEvent("ADDON_LOADED")
	end
end
