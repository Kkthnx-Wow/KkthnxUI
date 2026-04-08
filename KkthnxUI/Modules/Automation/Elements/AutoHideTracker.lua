--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Automatically hides the Objective Tracker during combat or specific encounters (Boss/Arena).
-- - Design: Uses a SecureHandlerStateTemplate state driver to securely toggle visibility during combat lockdown.
-- - Events: PLAYER_REGEN_ENABLED (deferred), OnHide/OnShow (AutoHider)
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Automation")

-- PERF: Localize globals to reduce lookup overhead.
local _G = _G
local CreateFrame = CreateFrame
local GetInstanceInfo = GetInstanceInfo
local InCombatLockdown = InCombatLockdown
local RegisterStateDriver = RegisterStateDriver
local ShowUIPanel = ShowUIPanel
local UnregisterStateDriver = UnregisterStateDriver
local pcall = pcall

local UIParent = UIParent

local C_AddOns_IsAddOnLoaded = C_AddOns and C_AddOns.IsAddOnLoaded
local C_TalkingHead_SetConversationsDeferred = C_TalkingHead and C_TalkingHead.SetConversationsDeferred

-- ---------------------------------------------------------------------------
-- Constants & Configuration
-- ---------------------------------------------------------------------------
local DEFAULTS = {
	AutoHide = true,
	AutoHideInKeystone = false,
}

local function getTrackerConfig()
	local cfg = C and C.Misc and C.Misc.ObjectiveTracker
	return cfg or DEFAULTS
end

local function isAddOnLoaded(name)
	if C_AddOns_IsAddOnLoaded then
		return C_AddOns_IsAddOnLoaded(name)
	end
	return _G.IsAddOnLoaded and _G.IsAddOnLoaded(name)
end

-- ---------------------------------------------------------------------------
-- Deferred Action System
-- ---------------------------------------------------------------------------
-- REASON: Parent swapping frames can be blocked in combat; this deferred system ensures actions are applied safely.
local pendingAction

local function applyPending()
	if not pendingAction or InCombatLockdown() then
		return
	end

	local tracker = _G.ObjectiveTrackerFrame
	if not tracker then
		pendingAction = nil
		return
	end

	if pendingAction == "collapse" then
		pcall(tracker.SetParent, tracker, K.UIFrameHider)
	elseif pendingAction == "expand" then
		pcall(tracker.SetParent, tracker, UIParent)
	end

	pendingAction = nil
	if Module.UnregisterEvent then
		Module:UnregisterEvent("PLAYER_REGEN_ENABLED", applyPending)
	end
end

local function trySetParent(frame, parent, actionName)
	-- REASON: Defer SetParent calls if they are blocked by combat lockdown to prevent UI errors/taint.
	if not frame then
		return
	end

	local ok = pcall(frame.SetParent, frame, parent)
	if not ok then
		pendingAction = actionName
		if Module.RegisterEvent then
			Module:RegisterEvent("PLAYER_REGEN_ENABLED", applyPending)
		end
	end
end

-- ---------------------------------------------------------------------------
-- Objective Tracker Helpers
-- ---------------------------------------------------------------------------
function Module:ObjectiveTracker_HasQuestTracker()
	return isAddOnLoaded("KalielsTracker") or isAddOnLoaded("DugisGuideViewerZ")
end

function Module:ObjectiveTracker_IsCollapsed(frame)
	return frame and frame:GetParent() == K.UIFrameHider
end

function Module:ObjectiveTracker_Collapse(frame)
	trySetParent(frame, K.UIFrameHider, "collapse")
end

function Module:ObjectiveTracker_Expand(frame)
	trySetParent(frame, UIParent, "expand")
end

-- ---------------------------------------------------------------------------
-- Auto-Hide Logic
-- ---------------------------------------------------------------------------
function Module:ObjectiveTracker_AutoHideOnHide()
	local tracker = _G.ObjectiveTrackerFrame
	if not tracker or Module:ObjectiveTracker_IsCollapsed(tracker) then
		return
	end

	local cfg = getTrackerConfig()

	-- REASON: Determine if tracker should be collapsed based on config and instance difficulty.
	if cfg.AutoHideInKeystone then
		Module:ObjectiveTracker_Collapse(tracker)
	else
		local _, _, difficultyID = GetInstanceInfo()
		if difficultyID ~= 8 then -- Ignore hide in keystone runs if configured
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

-- ---------------------------------------------------------------------------
-- SplashFrame Logic
-- ---------------------------------------------------------------------------
-- REASON: Overriding SplashFrame behaviour to prevent tainted updates to the Objective Tracker.
local function splashFrameOnHide(frame)
	local fromGameMenu = frame.screenInfo and frame.screenInfo.gameMenuRequest
	frame.screenInfo = nil

	if C_TalkingHead_SetConversationsDeferred then
		C_TalkingHead_SetConversationsDeferred(false)
	end

	if _G.AlertFrame then
		_G.AlertFrame:SetAlertsEnabled(true, "splashFrame")
	end

	-- WARNING: _G.ObjectiveTrackerFrame:Update() is intentionally omitted to avoid taint.

	if fromGameMenu and not frame.showingQuestDialog and not InCombatLockdown() then
		ShowUIPanel(_G.GameMenuFrame)
	end

	frame.showingQuestDialog = nil
end

-- ---------------------------------------------------------------------------
-- Module Initialization
-- ---------------------------------------------------------------------------
do
	local autoHider

	function Module:ObjectiveTracker_AutoHide()
		if isAddOnLoaded("BigWigs") or isAddOnLoaded("DBM-Core") or isAddOnLoaded("DBM") then
			return
		end

		if not _G.ObjectiveTrackerFrame then
			return
		end

		if not autoHider then
			autoHider = CreateFrame("Frame", nil, UIParent, "SecureHandlerStateTemplate")
			autoHider:SetAttribute("_onstate-objectiveHider", "if newstate == 1 then self:Hide() else self:Show() end")

			autoHider:SetScript("OnHide", function()
				Module:ObjectiveTracker_AutoHideOnHide()
			end)

			autoHider:SetScript("OnShow", function()
				Module:ObjectiveTracker_AutoHideOnShow()
			end)
		end

		local cfg = getTrackerConfig()
		if cfg.AutoHide then
			-- REASON: Registers state driver to hide tracker during boss encounters or arena via secure state.
			RegisterStateDriver(autoHider, "objectiveHider", "[@arena1,exists][@arena2,exists][@arena3,exists][@arena4,exists][@arena5,exists]" .. "[@boss1,exists][@boss2,exists][@boss3,exists][@boss4,exists][@boss5,exists] 1;0")
		else
			UnregisterStateDriver(autoHider, "objectiveHider")
			Module:ObjectiveTracker_AutoHideOnShow()
		end
	end
end

function Module:ObjectiveTracker_Setup()
	Module:ObjectiveTracker_AutoHide()

	local splash = _G.SplashFrame
	if splash then
		splash:SetScript("OnHide", splashFrameOnHide)
	end
end

function Module:CreateAutoHideTracker()
	if not Module:ObjectiveTracker_HasQuestTracker() then
		Module:ObjectiveTracker_Setup()
	end
end
