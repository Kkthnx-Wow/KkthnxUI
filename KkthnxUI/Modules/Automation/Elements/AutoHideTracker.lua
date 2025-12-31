local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Automation")

-- KkthnxUI: Objective Tracker Auto-Hide (combat-friendly)
-- Notes:
-- - Reason: Secure state driver handles hide/show decisions in combat.
-- - Reason: Parent swap may taint on some clients; attempt immediately, defer on failure.

-- Global caches (performance / consistency)
local _G = _G

local CreateFrame = CreateFrame
local RegisterStateDriver = RegisterStateDriver
local UnregisterStateDriver = UnregisterStateDriver
local InCombatLockdown = InCombatLockdown
local GetInstanceInfo = GetInstanceInfo
local ShowUIPanel = ShowUIPanel
local pcall = pcall

local UIParent = _G.UIParent

local C_AddOns_IsAddOnLoaded = C_AddOns and C_AddOns.IsAddOnLoaded
local C_TalkingHead_SetConversationsDeferred = C_TalkingHead and C_TalkingHead.SetConversationsDeferred

-- Config (prefer C; fallback to local defaults)
local Defaults = {
	AutoHide = true,
	AutoHideInKeystone = false,
}

local function GetTrackerConfig()
	local cfg = C and C.Misc and C.Misc.ObjectiveTracker
	return cfg or Defaults
end

local function IsAddOnLoaded(name)
	if C_AddOns_IsAddOnLoaded then
		return C_AddOns_IsAddOnLoaded(name)
	end
	return _G.IsAddOnLoaded and _G.IsAddOnLoaded(name)
end

-- Deferred apply (only used if parent swap gets blocked in combat)
local PendingAction -- "collapse" | "expand"

local function ApplyPending()
	if not PendingAction or InCombatLockdown() then
		return
	end

	local tracker = _G.ObjectiveTrackerFrame
	if not tracker then
		PendingAction = nil
		return
	end

	if PendingAction == "collapse" then
		pcall(tracker.SetParent, tracker, K.UIFrameHider)
	elseif PendingAction == "expand" then
		pcall(tracker.SetParent, tracker, UIParent)
	end

	PendingAction = nil
	if Module.UnregisterEvent then
		Module:UnregisterEvent("PLAYER_REGEN_ENABLED", ApplyPending)
	end
end

local function TrySetParent(frame, parent, actionName)
	-- Reason: Allow immediate attempt in combat; if blocked/taints, defer until combat ends.
	if not frame then
		return
	end

	local ok = pcall(frame.SetParent, frame, parent)
	if not ok then
		PendingAction = actionName
		if Module.RegisterEvent then
			Module:RegisterEvent("PLAYER_REGEN_ENABLED", ApplyPending)
		end
	end
end

-- Core helpers
function Module:ObjectiveTracker_HasQuestTracker()
	return IsAddOnLoaded("KalielsTracker") or IsAddOnLoaded("DugisGuideViewerZ")
end

function Module:ObjectiveTracker_IsCollapsed(frame)
	return frame and frame:GetParent() == K.UIFrameHider
end

function Module:ObjectiveTracker_Collapse(frame)
	TrySetParent(frame, K.UIFrameHider, "collapse")
end

function Module:ObjectiveTracker_Expand(frame)
	TrySetParent(frame, UIParent, "expand")
end

-- AutoHide handlers
function Module:ObjectiveTracker_AutoHideOnHide()
	local tracker = _G.ObjectiveTrackerFrame
	if not tracker or Module:ObjectiveTracker_IsCollapsed(tracker) then
		return
	end

	local cfg = GetTrackerConfig()

	if cfg.AutoHideInKeystone then
		Module:ObjectiveTracker_Collapse(tracker)
	else
		local _, _, difficultyID = GetInstanceInfo()
		if difficultyID ~= 8 then -- ignore hide in keystone runs
			Module:ObjectiveTracker_Collapse(tracker)
		end
	end
end

function Module:ObjectiveTracker_AutoHideOnShow()
	local tracker = _G.ObjectiveTrackerFrame
	if tracker and Module:ObjectiveTracker_IsCollapsed(tracker) then
		Module:ObjectiveTracker_Expand(tracker)
	end
end

-- Clone of SplashFrameMixin:OnHide() with ObjectiveTrackerFrame:Update removed
local function SplashFrame_OnHide(frame)
	local fromGameMenu = frame.screenInfo and frame.screenInfo.gameMenuRequest
	frame.screenInfo = nil

	if C_TalkingHead_SetConversationsDeferred then
		C_TalkingHead_SetConversationsDeferred(false)
	end

	if _G.AlertFrame then
		_G.AlertFrame:SetAlertsEnabled(true, "splashFrame")
	end

	-- _G.ObjectiveTrackerFrame:Update() -- intentionally removed (taint prevention)

	if fromGameMenu and not frame.showingQuestDialog and not InCombatLockdown() then
		ShowUIPanel(_G.GameMenuFrame)
	end

	frame.showingQuestDialog = nil
end

do
	local AutoHider

	function Module:ObjectiveTracker_AutoHide()
		if IsAddOnLoaded("BigWigs") or IsAddOnLoaded("DBM-Core") or IsAddOnLoaded("DBM") then
			return
		end

		if not _G.ObjectiveTrackerFrame then
			return
		end

		if not AutoHider then
			AutoHider = CreateFrame("Frame", nil, UIParent, "SecureHandlerStateTemplate")
			AutoHider:SetAttribute("_onstate-objectiveHider", "if newstate == 1 then self:Hide() else self:Show() end")

			AutoHider:SetScript("OnHide", function()
				Module:ObjectiveTracker_AutoHideOnHide()
			end)

			AutoHider:SetScript("OnShow", function()
				Module:ObjectiveTracker_AutoHideOnShow()
			end)
		end

		local cfg = GetTrackerConfig()
		if cfg.AutoHide then
			RegisterStateDriver(AutoHider, "objectiveHider", "[@arena1,exists][@arena2,exists][@arena3,exists][@arena4,exists][@arena5,exists]" .. "[@boss1,exists][@boss2,exists][@boss3,exists][@boss4,exists][@boss5,exists] 1;0")
		else
			UnregisterStateDriver(AutoHider, "objectiveHider")
			Module:ObjectiveTracker_AutoHideOnShow()
		end
	end
end

function Module:ObjectiveTracker_Setup()
	Module:ObjectiveTracker_AutoHide()

	local splash = _G.SplashFrame
	if splash then
		splash:SetScript("OnHide", SplashFrame_OnHide)
	end
end

function Module:CreateAutoHideTracker()
	if not Module:ObjectiveTracker_HasQuestTracker() then
		Module:ObjectiveTracker_Setup()
	end
end
