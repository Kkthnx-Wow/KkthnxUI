local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:NewModule("Developer")

K.Devs = {
	["Kkthnx-Area 52"] = true,
	["Kkthnxbye-Area 52"] = true,
	["Kkthnx-Valdrakken"] = true,
}

local function isDeveloper()
	return K.Devs[K.Name .. "-" .. K.Realm]
end
K.isDeveloper = isDeveloper

if not K.isDeveloper then
	return
end

function K.AddToDevTool(data, name)
	if DevTool then
		DevTool:AddData(data, name)
	end
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

--[[ ============================================================
    SECTION: Chat Message Blocker
    Filters out specific phrases or patterns in chat messages 
    (e.g., monster emotes) based on a configurable list of patterns.
=============================================================== ]]

do
	-- Cache global references for performance
	local string_match = string.match
	local string_gsub = string.gsub
	local ipairs = ipairs
	local ChatFrame_AddMessageEventFilter = ChatFrame_AddMessageEventFilter

	-- Create the ChatFilter object
	local ChatFilter = {}
	ChatFilter.blockedPatterns = {
		"^%s goes into a frenzy!$",
		"^%s attempts to run away in fear!$",
		"^%s collapses but the broken body rises again!$",
	}

	-- Check if a message matches any of the blocked patterns
	function ChatFilter:IsBlockedMessage(message)
		for _, pattern in ipairs(self.blockedPatterns) do
			if string_match(message, string_gsub(pattern, "%%s", ".+")) then
				return true
			end
		end
		return false
	end

	-- Custom chat message filter function
	local function MyChatFilter(self, event, msg, sender, ...)
		if ChatFilter:IsBlockedMessage(msg) then
			return true
		end
		return false
	end

	-- Add the filter for specific chat message events
	ChatFrame_AddMessageEventFilter("CHAT_MSG_MONSTER_EMOTE", MyChatFilter)
end
