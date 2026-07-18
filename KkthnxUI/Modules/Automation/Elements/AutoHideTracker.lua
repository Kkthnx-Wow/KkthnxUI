--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Hide the Objective Tracker during boss encounters and arena matches.
-- - Design: SecureHandlerStateTemplate triggers on [@boss#/@arena#,exists]; insecure
--   OnHide/OnShow reparents the tracker (SetParent is blocked from secure snippets
--   in combat — WoWUIBugs #469). Collapse only when a boss is hostile; friendly
--   escort NPCs on boss1..5 must not hide the tracker.
-- - Events: PLAYER_REGEN_ENABLED (deferred reparent / driver), OnHide/OnShow
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Automation")

local _G = _G
local CreateFrame = CreateFrame
local GetInstanceInfo = GetInstanceInfo
local InCombatLockdown = InCombatLockdown
local RegisterStateDriver = RegisterStateDriver
local ShowUIPanel = ShowUIPanel
local UnregisterStateDriver = UnregisterStateDriver
local UnitExists = _G.UnitExists
local UnitIsEnemy = _G.UnitIsEnemy
local pcall = pcall

local UIParent = UIParent
local DIFFICULTY_KEYSTONE = 8

-- Secure trigger only. Friendly scenario escorts can occupy boss1..5
-- (INSTANCE_ENCOUNTER_ENGAGE_UNIT); Collapse() filters hostility in Lua.
local STATE_CONDITION = "[@arena1,exists][@arena2,exists][@arena3,exists][@arena4,exists][@arena5,exists]"
	.. "[@boss1,exists][@boss2,exists][@boss3,exists][@boss4,exists][@boss5,exists] hide;show"

local C_AddOns_IsAddOnLoaded = C_AddOns and C_AddOns.IsAddOnLoaded
local C_TalkingHead_SetConversationsDeferred = C_TalkingHead and C_TalkingHead.SetConversationsDeferred

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

local function GetTracker()
	return _G.ObjectiveTrackerFrame
end

-- ---------------------------------------------------------------------------
-- Deferred SetParent (combat-safe)
-- ---------------------------------------------------------------------------
local driverPending
local pendingAction
local waitingForCombat
local splashGuarded
local trySetParent

local function applyPending()
	if InCombatLockdown() then
		return
	end

	local tracker = GetTracker()
	if tracker and pendingAction then
		pcall(tracker.SetParent, tracker, pendingAction == "collapse" and K.UIFrameHider or UIParent)
	end

	pendingAction = nil
	waitingForCombat = nil
	K:UnregisterEvent("PLAYER_REGEN_ENABLED", applyPending)
end

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

-- Arena always collapses. Boss tokens only when hostile — never on
-- IsEncounterInProgress alone (friendly escorts can set that flag too).
local function anyArenaUnit()
	for i = 1, 5 do
		if UnitExists("arena" .. i) then
			return true
		end
	end
	return false
end

local function anyHostileBossUnit()
	for i = 1, 5 do
		local unit = "boss" .. i
		-- UnitIsEnemy: SecretArguments only (Resources 12.0.7) — returns are plain.
		if UnitExists(unit) and UnitIsEnemy("player", unit) then
			return true
		end
	end
	return false
end

local function shouldCollapseTracker()
	if anyArenaUnit() then
		return true
	end
	return anyHostileBossUnit()
end

-- ---------------------------------------------------------------------------
-- Collapse / Expand
-- ---------------------------------------------------------------------------
function Module:ObjectiveTracker_AutoHideOnHide()
	local tracker = GetTracker()
	if not tracker or Module:ObjectiveTracker_IsCollapsed(tracker) then
		return
	end

	if not shouldCollapseTracker() then
		return
	end

	-- Keep objectives visible in Mythic+ unless the user opts in.
	local cfg = getTrackerConfig()
	if not cfg.AutoHideInKeystone then
		local _, _, difficultyID = GetInstanceInfo()
		if difficultyID == DIFFICULTY_KEYSTONE then
			return
		end
	end

	Module:ObjectiveTracker_Collapse(tracker)
end

function Module:ObjectiveTracker_AutoHideOnShow()
	local tracker = GetTracker()
	if tracker and Module:ObjectiveTracker_IsCollapsed(tracker) then
		Module:ObjectiveTracker_Expand(tracker)
	end
end

-- ---------------------------------------------------------------------------
-- SplashFrame taint guard
-- ---------------------------------------------------------------------------
-- Reparenting taints ObjectiveTrackerFrame. Blizzard's SplashFrame:OnHide calls
-- ObjectiveTrackerFrame:Update(), which would then run tainted and can poison
-- secure quest-item buttons. Drop that single Update after we have reparented.
local function splashFrameOnHide(frame)
	local fromGameMenu = frame.screenInfo and frame.screenInfo.gameMenuRequest
	frame.screenInfo = nil

	if C_TalkingHead_SetConversationsDeferred then
		C_TalkingHead_SetConversationsDeferred(false)
	end

	if _G.AlertFrame then
		_G.AlertFrame:SetAlertsEnabled(true, "splashFrame")
	end

	-- ObjectiveTrackerFrame:Update() intentionally omitted (taint guard).

	if fromGameMenu and not frame.showingQuestDialog and not InCombatLockdown() then
		ShowUIPanel(_G.GameMenuFrame)
	end

	frame.showingQuestDialog = nil
end

local function ensureSplashGuard()
	if splashGuarded then
		return
	end

	local splash = _G.SplashFrame
	if not splash then
		return
	end

	splashGuarded = true
	splash:SetScript("OnHide", splashFrameOnHide)
end

trySetParent = function(frame, parent, actionName)
	if not frame then
		return
	end

	ensureSplashGuard()

	if pcall(frame.SetParent, frame, parent) then
		return
	end

	pendingAction = actionName
	if not waitingForCombat then
		waitingForCombat = true
		K:RegisterEvent("PLAYER_REGEN_ENABLED", applyPending)
	end
end

-- ---------------------------------------------------------------------------
-- Driver setup
-- ---------------------------------------------------------------------------
do
	local autoHider
	local setupDone

	local function reapplyDriverAfterCombat()
		if InCombatLockdown() then
			return
		end

		driverPending = nil
		K:UnregisterEvent("PLAYER_REGEN_ENABLED", reapplyDriverAfterCombat)
		Module:ObjectiveTracker_AutoHide()
	end

	function Module:ObjectiveTracker_AutoHide()
		-- Boss mods / replacement trackers own this UI — don't fight them.
		if isAddOnLoaded("BigWigs") or isAddOnLoaded("DBM-Core") or isAddOnLoaded("DBM") then
			return
		end
		if Module:ObjectiveTracker_HasQuestTracker() then
			return
		end

		if not GetTracker() then
			return
		end

		if not autoHider then
			autoHider = CreateFrame("Frame", "KkthnxUITrackerAutoHider", UIParent, "SecureHandlerStateTemplate")
			autoHider:SetAttribute(
				"_onstate-trackervis",
				[[
				if newstate == "hide" then
					self:Hide()
				else
					self:Show()
				end
			]]
			)
			autoHider:SetScript("OnHide", function()
				Module:ObjectiveTracker_AutoHideOnHide()
			end)
			autoHider:SetScript("OnShow", function()
				Module:ObjectiveTracker_AutoHideOnShow()
			end)
			setupDone = true
		end

		if InCombatLockdown() then
			if not driverPending then
				driverPending = true
				K:RegisterEvent("PLAYER_REGEN_ENABLED", reapplyDriverAfterCombat)
			end
			return
		end

		local cfg = getTrackerConfig()
		if cfg.AutoHide then
			RegisterStateDriver(autoHider, "trackervis", STATE_CONDITION)
		else
			UnregisterStateDriver(autoHider, "trackervis")
			Module:ObjectiveTracker_AutoHideOnShow()
		end
	end

	function Module:ObjectiveTracker_Setup()
		Module:ObjectiveTracker_AutoHide()
	end

	function Module:CreateAutoHideTracker()
		if Module:ObjectiveTracker_HasQuestTracker() then
			return
		end

		-- Blizzard_ObjectiveTracker is LOD; wait if needed.
		if GetTracker() then
			Module:ObjectiveTracker_Setup()
			return
		end

		if setupDone then
			return
		end

		local waiter = CreateFrame("Frame")
		waiter:RegisterEvent("ADDON_LOADED")
		waiter:SetScript("OnEvent", function(self, _, name)
			if name ~= "Blizzard_ObjectiveTracker" then
				return
			end
			self:UnregisterEvent("ADDON_LOADED")
			self:SetScript("OnEvent", nil)
			if not Module:ObjectiveTracker_HasQuestTracker() then
				Module:ObjectiveTracker_Setup()
			end
		end)
	end
end
