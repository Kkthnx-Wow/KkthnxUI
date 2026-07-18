--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Suppress Blizzard default action bar art while KKUI bars are active.
-- - Design: Reparents bar containers + chrome to UIFrameHider (reversible via ShowBlizz).
--   Do NOT wipe chrome scripts/events — MicroMenu lesson: live disable must restore.
-----------------------------------------------------------------------------]]

local K = KkthnxUI[1]
local Module = K:GetModule("ActionBar")

-- ---------------------------------------------------------------------------
-- LOCALS & CACHING
-- ---------------------------------------------------------------------------

local _G = _G
local next = next
local pcall = pcall
local strmatch = string.match
local UIParent = UIParent

local savedParents = {}
local blizzSuppressed = false
local origShowAllGrids
local buttonEventsHooked

-- REASON: Reparent-only hide keeps Blizzard bar + chrome logic intact for ShowBlizz.
local framesToSuppress = {
	MainActionBar,
	MultiBarBottomLeft,
	MultiBarBottomRight,
	MultiBarLeft,
	MultiBarRight,
	MultiBar5,
	MultiBar6,
	MultiBar7,
	OverrideActionBar,
	PossessActionBar,
	PetActionBar,
	StanceBar,
	-- Chrome: reparent instead of DisableAllScripts/UnregisterAllEvents so live
	-- disable→enable restores vehicle leave, XP bar, micro bag bar, etc.
	MicroButtonAndBagsBar,
	StatusTrackingBarManager,
	MainMenuBarVehicleLeaveButton,
	OverrideActionBarExpBar,
	OverrideActionBarHealthBar,
	OverrideActionBarPowerBar,
	OverrideActionBarPitchFrame,
}

-- ---------------------------------------------------------------------------
-- HELPERS
-- ---------------------------------------------------------------------------

local function buttonEventsRegisterFrame(self, added)
	local frames = self.frames
	for index = #frames, 1, -1 do
		local frame = frames[index]
		local wasAdded = frame == added
		if not added or wasAdded then
			if not strmatch(frame:GetName(), "ExtraActionButton%d") then
				self.frames[index] = nil
			end

			if wasAdded then
				break
			end
		end
	end
end

local function DisableDefaultBarEvents()
	_G.ActionBarController:UnregisterAllEvents()
	_G.ActionBarController:RegisterEvent("SETTINGS_LOADED")
	_G.ActionBarController:RegisterEvent("UPDATE_EXTRA_ACTIONBAR")

	_G.ActionBarActionEventsFrame:UnregisterAllEvents()

	_G.ActionBarButtonEventsFrame:UnregisterAllEvents()
	_G.ActionBarButtonEventsFrame:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
	_G.ActionBarButtonEventsFrame:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN")

	if not buttonEventsHooked then
		buttonEventsHooked = true
		hooksecurefunc(_G.ActionBarButtonEventsFrame, "RegisterFrame", buttonEventsRegisterFrame)
		buttonEventsRegisterFrame(_G.ActionBarButtonEventsFrame)
	end

	if not origShowAllGrids then
		origShowAllGrids = MultiActionBar_ShowAllGrids
	end
	MultiActionBar_ShowAllGrids = K.Noop
end

local function RestoreDefaultBarEvents()
	-- ActionBarController_OnLoad re-wires controller events after Hide stripped them.
	if _G.ActionBarController_OnLoad then
		pcall(_G.ActionBarController_OnLoad, _G.ActionBarController)
	end

	-- Hide called UnregisterAllEvents on these; OnLoad re-registers the full set
	-- (spellcast unit events, usable, glow, etc.) without wiping registered frames.
	local actionEvents = _G.ActionBarActionEventsFrame
	if actionEvents and actionEvents.OnLoad then
		local savedFrames = actionEvents.frames
		pcall(actionEvents.OnLoad, actionEvents)
		if savedFrames then
			actionEvents.frames = savedFrames
		end
	end

	local buttonEvents = _G.ActionBarButtonEventsFrame
	if buttonEvents and buttonEvents.OnLoad then
		local savedFrames = buttonEvents.frames
		pcall(buttonEvents.OnLoad, buttonEvents)
		if savedFrames then
			buttonEvents.frames = savedFrames
		end
		-- Hide kept only SLOT_CHANGED + UPDATE_COOLDOWN; OnLoad restores the rest.
	end

	if origShowAllGrids then
		MultiActionBar_ShowAllGrids = origShowAllGrids
		origShowAllGrids = nil
	end
end

local function RefreshBlizzardBars()
	if _G.ActionBarController_UpdateAll then
		pcall(_G.ActionBarController_UpdateAll, true)
	end
	if _G.MultiActionBar_Update then
		pcall(_G.MultiActionBar_Update)
	end
	if _G.MainMenuBarArtFrame and _G.MainMenuBarArtFrame.Show then
		_G.MainMenuBarArtFrame:Show()
	end
end

-- ---------------------------------------------------------------------------
-- HIDE / SHOW BLIZZARD BARS
-- ---------------------------------------------------------------------------

function Module:HideBlizz()
	if blizzSuppressed then
		return
	end
	blizzSuppressed = true

	for _, frame in next, framesToSuppress do
		if frame then
			if not savedParents[frame] then
				savedParents[frame] = frame:GetParent()
			end
			frame:SetParent(K.UIFrameHider)
		end
	end

	DisableDefaultBarEvents()
	SetCVar("showTokenFrame", 1)
end

function Module:ShowBlizz()
	if not blizzSuppressed then
		return
	end
	blizzSuppressed = false

	for _, frame in next, framesToSuppress do
		if frame then
			local parent = savedParents[frame]
			frame:SetParent(parent or UIParent)
			frame:Show()
			savedParents[frame] = nil
		end
	end

	RestoreDefaultBarEvents()
	RefreshBlizzardBars()

	-- Status tracking + vehicle leave may need a nudge after reparent.
	if StatusTrackingBarManager and _G.StatusTrackingBarManager_OnLoad then
		pcall(_G.StatusTrackingBarManager_OnLoad, StatusTrackingBarManager)
	end
	if MainMenuBarVehicleLeaveButton then
		MainMenuBarVehicleLeaveButton:RegisterEvent("PLAYER_ENTERING_WORLD")
		MainMenuBarVehicleLeaveButton:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
		MainMenuBarVehicleLeaveButton:RegisterEvent("UPDATE_VEHICLE_ACTIONBAR")
		MainMenuBarVehicleLeaveButton:RegisterEvent("UPDATE_OVERRIDE_ACTIONBAR")
	end
end

function Module:IsBlizzActionBarSuppressed()
	return blizzSuppressed
end
