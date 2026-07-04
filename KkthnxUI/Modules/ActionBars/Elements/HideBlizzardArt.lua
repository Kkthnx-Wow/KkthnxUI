--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Suppress Blizzard default action bar art while KKUI bars are active.
-- - Design: Reparents vanilla bar containers to UIFrameHider (reversible via ShowBlizz).
--   Script wiping is limited to chrome-only frames so live disable can restore bars.
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

-- NOTE: Scripts wiped only on chrome frames — not on bar containers we restore live.
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

-- REASON: Reparent-only hide keeps Blizzard bar logic intact for ShowBlizz restore.
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
}

-- REASON: Chrome-only — never wipe action bar container scripts (breaks live restore).
local chromeToDisable = {
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

local function DisableAllScripts(frame)
	for _, script in next, scripts do
		if frame:HasScript(script) then
			frame:SetScript(script, nil)
		end
	end
end

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
	if _G.ActionBarController_OnLoad then
		pcall(_G.ActionBarController_OnLoad, _G.ActionBarController)
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

	for _, frame in next, chromeToDisable do
		if frame then
			frame:UnregisterAllEvents()
			DisableAllScripts(frame)
			if frame == StatusTrackingBarManager then
				frame:Hide()
			end
		end
	end

	DisableDefaultBarEvents()

	MainMenuBarVehicleLeaveButton:RegisterEvent("PLAYER_ENTERING_WORLD")
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

	if StatusTrackingBarManager then
		StatusTrackingBarManager:Show()
		if _G.StatusTrackingBarManager_OnLoad then
			pcall(_G.StatusTrackingBarManager_OnLoad, StatusTrackingBarManager)
		end
	end
end

function Module:IsBlizzActionBarSuppressed()
	return blizzSuppressed
end
