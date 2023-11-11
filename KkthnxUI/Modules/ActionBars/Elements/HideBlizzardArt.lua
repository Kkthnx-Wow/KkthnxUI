local K = KkthnxUI[1]
local Module = K:GetModule("ActionBar")

local next = next

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
	},

	framesToDisable = {
		MainMenuBar,
		MultiBarBottomLeft,
		MultiBarBottomRight,
		MultiBarLeft,
		MultiBarRight,
		MultiBar5,
		MultiBar6,
		MultiBar7,
		PossessActionBar,
		PetActionBar,
		MicroButtonAndBagsBar,
		StatusTrackingBarManager,
		MainMenuBarVehicleLeaveButton,
		OverrideActionBar,
		OverrideActionBarExpBar,
		OverrideActionBarHealthBar,
		OverrideActionBarPowerBar,
		OverrideActionBarPitchFrame,
	},
}

local function DisableAllScripts(frame)
	for _, script in next, actionbar.eventScripts do
		if frame:HasScript(script) then
			frame:SetScript(script, nil)
		end
	end
end

local function updateTokenVisibility()
	TokenFrame_LoadUI()
	TokenFrame_Update()
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

local function DisableDefaultBarEvents() -- credit: Simpy
	-- MainMenuBar:ClearAllPoints taint during combat
	_G.MainMenuBar.SetPositionForStatusBars = K.Noop

	-- Spellbook open in combat taint, only happens sometimes
	_G.MultiActionBar_HideAllGrids = K.Noop
	_G.MultiActionBar_ShowAllGrids = K.Noop

	-- Shut down some events for things we don't use
	_G.ActionBarController:UnregisterAllEvents()
	_G.ActionBarController:RegisterEvent("SETTINGS_LOADED") -- This is needed for the page controller to spawn properly
	_G.ActionBarController:RegisterEvent("UPDATE_EXTRA_ACTIONBAR") -- This is needed to let the ExtraActionBar show

	_G.ActionBarActionEventsFrame:UnregisterAllEvents()

	-- Used for ExtraActionButton and TotemBar (on Wrath)
	_G.ActionBarButtonEventsFrame:UnregisterAllEvents()
	_G.ActionBarButtonEventsFrame:RegisterEvent("ACTIONBAR_SLOT_CHANGED") -- Needed to let the ExtraActionButton show and Totems to swap
	_G.ActionBarButtonEventsFrame:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN") -- Needed for cooldowns of both

	hooksecurefunc(_G.ActionBarButtonEventsFrame, "RegisterFrame", buttonEventsRegisterFrame)
	buttonEventsRegisterFrame(_G.ActionBarButtonEventsFrame)

	-- Fix keybind error; this prevents the reopening of the GameMenu
	_G.SettingsPanel.TransitionBackOpeningPanel = HideUIPanel
end

function Module:HideBlizz()
	for _, frame in next, actionbar.framesToHide do
		frame:SetParent(K.UIFrameHider)
	end

	for _, frame in next, actionbar.framesToDisable do
		frame:UnregisterAllEvents()
		DisableAllScripts(frame)
	end

	DisableDefaultBarEvents()
	-- Fix maw block anchor
	MainMenuBarVehicleLeaveButton:RegisterEvent("PLAYER_ENTERING_WORLD")
	-- Update token panel
	K:RegisterEvent("CURRENCY_DISPLAY_UPDATE", updateTokenVisibility)

	-- Hide blizzard expbar
	StatusTrackingBarManager:UnregisterAllEvents()
	StatusTrackingBarManager:Hide()
end
