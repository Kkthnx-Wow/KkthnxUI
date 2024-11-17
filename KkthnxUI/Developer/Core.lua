local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:NewModule("Developer")

-- Benchmarking global vs. cached access in WoW Lua
local _G = _G
_G.fake1 = 42 -- Set up a global variable

-- Case 1: Direct global access
local start_time = debugprofilestop()
for i = 1, 1e7 do
	local temp = _G.fake1
end
print("Global access:", debugprofilestop() - start_time, "ms")

-- Case 2: Cached access
local fake1 = _G.fake1
start_time = debugprofilestop()
for i = 1, 1e7 do
	local temp = fake1
end
print("Cached access:", debugprofilestop() - start_time, "ms")

K.Devs = {
	["Kkthnx-Area 52"] = true,
	["Kkthnx-Valdrakken"] = true,
}

local function isDeveloper()
	return K.Devs[K.Name .. "-" .. K.Realm]
end
K.isDeveloper = isDeveloper

if not K.isDeveloper then
	return
end

local _G = _G
local ShowUIPanel = ShowUIPanel
local GetInstanceInfo = GetInstanceInfo
local InCombatLockdown = InCombatLockdown

local C_TalkingHead_SetConversationsDeferred = C_TalkingHead.SetConversationsDeferred

local Config_ObjectiveFrameAutoHideInKeystone = true
local Config_ObjectiveFrameAutoHide = true

local function IsQuestTrackerLoaded()
	return C_AddOns.IsAddOnLoaded("!KalielsTracker") or C_AddOns.IsAddOnLoaded("DugisGuideViewerZ")
end

local function IsObjectiveTrackerCollapsed(frame)
	return frame:GetParent() == K.UIFrameHider
end

local function CollapseObjectiveTracker(frame)
	frame:SetParent(K.UIFrameHider)
end

local function ExpandObjectiveTracker(frame)
	frame:SetParent(_G.UIParent)
end

local function AutoHideObjectiveTrackerOnShow()
	local tracker = _G.ObjectiveTrackerFrame
	if tracker and IsObjectiveTrackerCollapsed(tracker) then
		ExpandObjectiveTracker(tracker)
	end
end

local function AutoHideObjectiveTrackerOnHide()
	local tracker = _G.ObjectiveTrackerFrame
	if not tracker or IsObjectiveTrackerCollapsed(tracker) then
		return
	end

	if Config_ObjectiveFrameAutoHideInKeystone then
		CollapseObjectiveTracker(tracker)
	else
		local _, _, difficultyID = GetInstanceInfo()
		if difficultyID ~= 8 then -- ignore hide in keystone runs
			CollapseObjectiveTracker(tracker)
		end
	end
end

local function AutoHideObjectiveTracker()
	local tracker = _G.ObjectiveTrackerFrame
	if not tracker then
		return
	end

	if not AutoHider then
		AutoHider = CreateFrame("Frame", nil, UIParent, "SecureHandlerStateTemplate")
		AutoHider:SetAttribute("_onstate-objectiveHider", "if newstate == 1 then self:Hide() else self:Show() end")
		AutoHider:SetScript("OnHide", AutoHideObjectiveTrackerOnHide)
		AutoHider:SetScript("OnShow", AutoHideObjectiveTrackerOnShow)
	end

	if Config_ObjectiveFrameAutoHide then
		RegisterStateDriver(AutoHider, "objectiveHider", "[@arena1,exists][@arena2,exists][@arena3,exists][@arena4,exists][@arena5,exists][@boss1,exists][@boss2,exists][@boss3,exists][@boss4,exists][@boss5,exists]1;0")
	else
		UnregisterStateDriver(AutoHider, "objectiveHider")
		AutoHideObjectiveTrackerOnShow() -- reshow it when needed
	end
end

local function SplashFrame_OnHide(frame)
	local fromGameMenu = frame.screenInfo and frame.screenInfo.gameMenuRequest
	frame.screenInfo = nil

	C_TalkingHead_SetConversationsDeferred(false)
	_G.AlertFrame:SetAlertsEnabled(true, "splashFrame")

	if fromGameMenu and not frame.showingQuestDialog and not InCombatLockdown() then
		ShowUIPanel(_G.GameMenuFrame)
	end

	frame.showingQuestDialog = nil
end

local function SetupObjectiveTracker()
	AutoHideObjectiveTracker()

	local splash = _G.SplashFrame
	if splash then
		splash:SetScript("OnHide", SplashFrame_OnHide)
	end
end

-- Module's OnEnable function.
function Module:OnEnable()
	if not IsQuestTrackerLoaded() then
		SetupObjectiveTracker()
	end
end
