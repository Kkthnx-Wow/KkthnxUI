--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/Skins/ObjectiveTracker.lua
	Purpose:
		Tidy the Blizzard quest / objective tracker so it sits quietly in the
		corner: hide the busy header backgrounds, shrink and clean the minimise
		button, and recolour quest progress and timer bars to a single calm colour
		(class colour, or our accent).

		The tracker lives in the load-on-demand Blizzard_ObjectiveTracker, so we
		style on enable if it is already loaded, otherwise wait for its ADDON_LOADED.

		Taint note: the styling is driven purely by hooksecurefunc reactions (on
		SetCollapsed, GetProgressBar, GetTimerBar) plus a one-time header pass. It
		does NOT run from a repeating OnUpdate. An OnUpdate that rewrites the shared
		tracker frames every tick keeps them tainted, so Blizzard's own secure
		container update then runs tainted and the scenario module's Maw buff aura
		read (GetAuraDataByIndex, a secret value on 12.1) errors on events like the
		Coiled Isle curse surge (GitHub #134, #138, #141). Reacting through secure
		hooks stays in an isolated taint context and avoids that. Retail only.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

if not (K.Client and K.Client.IsRetail) then
	return
end

local Module = K:NewModule("ObjectiveTracker")

local _G = _G
local pairs = pairs
local hooksecurefunc = hooksecurefunc
local C_AddOns = C_AddOns

-- Fallback tint when the class-colour option is off.
local ACCENT = { 0.36, 0.55, 0.81 }

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

local function HideHeaderBackground(header)
	if header and header.Background then
		header.Background:Hide()
	end
end

-- Swap the minimise button art for the smaller secondary set so it reads as a
-- quiet chevron. Hooked on SetCollapsed so it tracks the state without us polling.
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

-- Bar recolour reactions. Blizzard hands back the bar it just built or reused, so
-- we re-read it from the tracker's pools (the return value is not passed to a
-- secure hook) and tint it.
local function HandleProgressBar(tracker, key)
	local pb = tracker.usedProgressBars and tracker.usedProgressBars[key]
	ReskinBar(pb and pb.Bar)
end

local function HandleTimerBar(tracker, key)
	local tb = tracker.usedTimerBars and tracker.usedTimerBars[key]
	ReskinBar(tb and tb.Bar)
end

local function SkinHeader(header)
	if not header then
		return
	end
	HideHeaderBackground(header)
	local minimize = header.MinimizeButton
	if minimize then
		minimize:SetSize(16, 16)
		if minimize.SetHighlightAtlas then
			minimize:SetHighlightAtlas("UI-QuestTrackerButton-Yellow-Highlight", "ADD")
		end
		SetCollapsed(header, header.isCollapsed)
		hooksecurefunc(header, "SetCollapsed", SetCollapsed)
	end
end

function Module:Style()
	if self.styled then
		return
	end
	local trackerFrame = _G.ObjectiveTrackerFrame
	if not trackerFrame then
		return
	end
	self.styled = true

	-- ObjectiveTrackerFrame.Header is deliberately left alone. It belongs to the
	-- shared container, not to one sub-tracker, and the container is what drives
	-- every module's update. Styling it (and hooking its SetCollapsed, which then
	-- rewrote its textures from our taint context on every collapse) tainted the
	-- container, so Blizzard's own ObjectiveTrackerContainer update ran tainted and
	-- the scenario module's Maw buff aura read failed downstream (GitHub #143, after
	-- #134, #138, #141). Only per-module sub-trackers are touched below.

	-- The sub-trackers. ScenarioObjectiveTracker AND UIWidgetObjectiveTracker are
	-- deliberately left out: both render their blocks through Blizzard's shared
	-- UI-widget pool, the same pool AreaPOI tooltips and the scenario Maw buff aura
	-- read draw from. Any method call on their blocks or bars taints that pool, and
	-- the taint surfaces later as a secret-value error in a widget layout or in
	-- ScenarioObjectiveTracker:LayoutContents -> ShouldShowMawBuffs -> GetAuraDataByIndex
	-- (GitHub #134, #138, #139, #141). So we never touch them and leave their bars
	-- in Blizzard's own colours.
	local trackers = {
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
			SkinHeader(tracker.Header)

			-- Colour any bars already built, then react to future ones.
			if tracker.usedProgressBars then
				for _, pb in pairs(tracker.usedProgressBars) do
					ReskinBar(pb and pb.Bar)
				end
			end
			if tracker.usedTimerBars then
				for _, tb in pairs(tracker.usedTimerBars) do
					ReskinBar(tb and tb.Bar)
				end
			end
			if tracker.GetProgressBar then
				hooksecurefunc(tracker, "GetProgressBar", HandleProgressBar)
			end
			if tracker.GetTimerBar then
				hooksecurefunc(tracker, "GetTimerBar", HandleTimerBar)
			end
		end
	end
end

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
