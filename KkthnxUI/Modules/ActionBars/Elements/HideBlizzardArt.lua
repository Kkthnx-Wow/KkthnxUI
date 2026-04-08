--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Completely suppresses Blizzard's default action bar art and logic.
-- - Design: Unregisters events and clears scripts from vanilla frames to prevent interference.
-----------------------------------------------------------------------------]]

local K = KkthnxUI[1]
local Module = K:GetModule("ActionBar")

-- ---------------------------------------------------------------------------
-- LOCALS & CACHING
-- ---------------------------------------------------------------------------

local _G = _G
local next, tonumber = next, tonumber

-- NOTE: List of scripts to wipe from Blizzard frames to ensure they remain inert.
local scripts = {
	"OnShow",
	"OnHide",
	"OnEvent",
	"OnEnter",
	"OnLeave",
	"OnUpdate",
	"OnValueChanged",
	"OnClick",
	"OnMouseDown",
	"OnMouseUp",
}

-- REASON: These frames are parented to a hidden frame to keep them out of sight.
local framesToHide = {
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
}

-- REASON: These frames have their events and scripts disabled for performance and stability.
local framesToDisable = {
	MainActionBar,
	MultiBarBottomLeft,
	MultiBarBottomRight,
	MultiBarLeft,
	MultiBarRight,
	MultiBar5,
	MultiBar6,
	MultiBar7,
	PossessActionBar,
	PetActionBar,
	StanceBar,
	MicroButtonAndBagsBar,
	StatusTrackingBarManager,
	MainMenuBarVehicleLeaveButton,
	OverrideActionBar,
	OverrideActionBarExpBar,
	OverrideActionBarHealthBar,
	OverrideActionBarPowerBar,
	OverrideActionBarPitchFrame,
}

-- ---------------------------------------------------------------------------
-- HIDE BLIZZARD ART
-- ---------------------------------------------------------------------------

-- REASON: Iteratively removes all interactive capability from a frame.
local function DisableAllScripts(frame)
	for _, script in next, scripts do
		if frame:HasScript(script) then
			frame:SetScript(script, nil)
		end
	end
end

-- NOTE: Filters the ActionButtonEventsFrame to only allow ExtraActionButtons.
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

-- ---------------------------------------------------------------------------
-- EVENT SUPPRESSION
-- ---------------------------------------------------------------------------

-- REASON: Disabling default events is critical to prevent "ghost" action bar changes
-- where the game thinks a bar should be visible or positioned in a specific way.
local function DisableDefaultBarEvents() -- credit: Simpy
	-- NOTE: Shut down some events for things we don't use
	_G.ActionBarController:UnregisterAllEvents()
	_G.ActionBarController:RegisterEvent("SETTINGS_LOADED") -- REASON: Needed for page controller to spawn properly.
	_G.ActionBarController:RegisterEvent("UPDATE_EXTRA_ACTIONBAR") -- REASON: Allows the Extra Action Bar to function.
	_G.ActionBarActionEventsFrame:UnregisterAllEvents()

	-- NOTE: Used for ExtraActionButton and TotemBar (on Wrath/Classic).
	_G.ActionBarButtonEventsFrame:UnregisterAllEvents()
	_G.ActionBarButtonEventsFrame:RegisterEvent("ACTIONBAR_SLOT_CHANGED") -- REASON: Handles swap logic.
	_G.ActionBarButtonEventsFrame:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN") -- REASON: Cooldown synchronization.

	hooksecurefunc(_G.ActionBarButtonEventsFrame, "RegisterFrame", buttonEventsRegisterFrame)
	buttonEventsRegisterFrame(_G.ActionBarButtonEventsFrame)
	MultiActionBar_ShowAllGrid = K.Noop
end

-- ---------------------------------------------------------------------------
-- CORE HIDING LOGIC
-- ---------------------------------------------------------------------------

function Module:HideBlizz()
	-- NOTE: Move frames to our global hider cage.
	for _, frame in next, framesToHide do
		frame:SetParent(K.UIFrameHider)
	end

	-- NOTE: Kill event listening and script execution.
	for _, frame in next, framesToDisable do
		frame:UnregisterAllEvents()
		DisableAllScripts(frame)
	end

	DisableDefaultBarEvents()

	-- NOTE: Resolve specific Blizzard UI edge cases.
	MainMenuBarVehicleLeaveButton:RegisterEvent("PLAYER_ENTERING_WORLD") -- Ensure vehicle leave button can still signal.
	SetCVar("showTokenFrame", 1) -- Force token panel visibility if user configuration is missing.

	-- PERF: Disable the default experience/reputation bars entirely.
	StatusTrackingBarManager:UnregisterAllEvents()
	StatusTrackingBarManager:Hide()
end
