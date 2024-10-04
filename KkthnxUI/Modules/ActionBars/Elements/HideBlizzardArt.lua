local K = KkthnxUI[1]
local Module = K:GetModule("ActionBar")

local _G = _G
local pairs = pairs
local strmatch = string.match

local MainMenuBar = _G.MainMenuBar
local StatusTrackingBarManager = _G.StatusTrackingBarManager
local ActionBarController = _G.ActionBarController
local ActionBarActionEventsFrame = _G.ActionBarActionEventsFrame
local ActionBarButtonEventsFrame = _G.ActionBarButtonEventsFrame
local SettingsPanel = _G.SettingsPanel
local MainMenuBarVehicleLeaveButton = _G.MainMenuBarVehicleLeaveButton

local actionbar = {
	eventScripts = {
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
	},

	framesToHide = {
		MainMenuBar,
		_G.MultiBarBottomLeft,
		_G.MultiBarBottomRight,
		_G.MultiBarLeft,
		_G.MultiBarRight,
		_G.MultiBar5,
		_G.MultiBar6,
		_G.MultiBar7,
		_G.OverrideActionBar,
		_G.PossessActionBar,
		_G.PetActionBar,
	},

	framesToDisable = {
		MainMenuBar,
		_G.MultiBarBottomLeft,
		_G.MultiBarBottomRight,
		_G.MultiBarLeft,
		_G.MultiBarRight,
		_G.MultiBar5,
		_G.MultiBar6,
		_G.MultiBar7,
		_G.PossessActionBar,
		_G.PetActionBar,
		_G.MicroButtonAndBagsBar,
		StatusTrackingBarManager,
		MainMenuBarVehicleLeaveButton,
		_G.OverrideActionBar,
		_G.OverrideActionBarExpBar,
		_G.OverrideActionBarHealthBar,
		_G.OverrideActionBarPowerBar,
		_G.OverrideActionBarPitchFrame,
	},
}

local function DisableAllScripts(frame)
	for _, script in ipairs(actionbar.eventScripts) do
		if frame:HasScript(script) then
			frame:SetScript(script, nil)
		end
	end
end

local function buttonEventsRegisterFrame(self, added)
	local frames = self.frames
	for index = #frames, 1, -1 do
		local frame = frames[index]
		if not added or frame == added then
			if not strmatch(frame:GetName(), "ExtraActionButton%d") then
				table.remove(frames, index)
			end

			if frame == added then
				break
			end
		end
	end
end

local function DisableDefaultBarEvents()
	-- Disable unused events for ActionBarController and other frames
	ActionBarController:UnregisterAllEvents()
	ActionBarController:RegisterEvent("SETTINGS_LOADED")
	ActionBarController:RegisterEvent("UPDATE_EXTRA_ACTIONBAR")

	ActionBarActionEventsFrame:UnregisterAllEvents()

	ActionBarButtonEventsFrame:UnregisterAllEvents()
	ActionBarButtonEventsFrame:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
	ActionBarButtonEventsFrame:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN")

	hooksecurefunc(ActionBarButtonEventsFrame, "RegisterFrame", buttonEventsRegisterFrame)
	buttonEventsRegisterFrame(ActionBarButtonEventsFrame)
end

function Module:HideBlizz()
	for _, frame in pairs(actionbar.framesToHide) do
		frame:SetParent(K.UIFrameHider)
	end

	for _, frame in pairs(actionbar.framesToDisable) do
		frame:UnregisterAllEvents()
		DisableAllScripts(frame)
	end

	DisableDefaultBarEvents()

	-- Fix for the vehicle leave button
	MainMenuBarVehicleLeaveButton:RegisterEvent("PLAYER_ENTERING_WORLD")

	-- Update token panel, some alts may hide token as default
	SetCVar("showTokenFrame", 1)

	-- Hide Blizzard experience bar
	StatusTrackingBarManager:UnregisterAllEvents()
	StatusTrackingBarManager:Hide()
end
