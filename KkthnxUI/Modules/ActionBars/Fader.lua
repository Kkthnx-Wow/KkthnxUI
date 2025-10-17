local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("ActionBar")

-- Credit: ElvUI

-- Localizing global functions and constants for performance
local _G = _G
local pairs, ipairs, next = pairs, ipairs, next
local UnitAffectingCombat, UnitExists, UnitHealth, UnitHealthMax = UnitAffectingCombat, UnitExists, UnitHealth, UnitHealthMax
local UnitCastingInfo, UnitChannelInfo, UnitHasVehicleUI = UnitCastingInfo, UnitChannelInfo, UnitHasVehicleUI
local CreateFrame, C_Timer = CreateFrame, C_Timer
local InCombatLockdown, RegisterStateDriver = InCombatLockdown, RegisterStateDriver

-- Module state
Module.fadeParent = nil
Module.handledbuttons = {}

--- Safely cancels a C_Timer if it exists and isn't already cancelled.
-- @param timer The timer object to cancel
local function CancelTimer(timer)
	if timer and not timer:IsCancelled() then
		timer:Cancel()
	end
end

--- Clears all active timers from an object.
-- @param object Frame or table containing timer references
local function ClearTimers(object)
	CancelTimer(object.delayTimer)
	object.delayTimer = nil
end

--- Fades out a frame after an optional delay.
-- Respects BarFadeDelay config setting for smooth transitions.
-- @param frame The frame to fade
-- @param timeToFade Duration of fade animation in seconds
-- @param startAlpha Starting alpha value
-- @param endAlpha Target alpha value
local function DelayFadeOut(frame, timeToFade, startAlpha, endAlpha)
	ClearTimers(frame)

	local fadeDelay = C["ActionBar"].BarFadeDelay
	if fadeDelay > 0 then
		frame.delayTimer = C_Timer.NewTimer(fadeDelay, function()
			K.UIFrameFadeOut(frame, timeToFade, startAlpha, endAlpha)
		end)
	else
		K.UIFrameFadeOut(frame, timeToFade, startAlpha, endAlpha)
	end
end

--- Adjusts the bling texture on a cooldown based on alpha visibility.
-- Shows star texture when visible, blank when faded.
-- @param cooldown The cooldown frame to modify
-- @param alpha Current alpha value (>0.5 shows bling)
function Module:FadeBlingTexture(cooldown, alpha)
	if cooldown then
		cooldown:SetBlingTexture(alpha > 0.5 and [[Interface\Cooldown\star4]] or C["Media"].Textures.BlankTexture)
	end
end

--- Updates bling textures for all action buttons based on fade state.
-- @param alpha Target alpha value
function Module:FadeBlings(alpha)
	for _, button in pairs(Module.buttons) do
		Module:FadeBlingTexture(button.cooldown, alpha)
	end
end

--- Handles mouse enter events for action bar buttons.
-- Fades in the action bars unless mouseLock is active.
function Module:Button_OnEnter()
	local fadeParent = Module.fadeParent
	if not fadeParent or fadeParent.mouseLock then
		return
	end

	ClearTimers(fadeParent)
	K.UIFrameFadeIn(fadeParent, 0.2, fadeParent:GetAlpha(), 1)
	Module:FadeBlings(1)
end

--- Handles mouse leave events for action bar buttons.
-- Fades out the action bars unless mouseLock is active.
function Module:Button_OnLeave()
	local fadeParent = Module.fadeParent
	if not fadeParent or fadeParent.mouseLock then
		return
	end

	DelayFadeOut(fadeParent, 0.38, fadeParent:GetAlpha(), C["ActionBar"].BarFadeAlpha)
	Module:FadeBlings(C["ActionBar"].BarFadeAlpha)
end

--- Finds the anchor button for a flyout button to apply fade effects.
-- Traverses parent hierarchy to locate the main action button.
-- @param frame The flyout button frame
-- @return The anchor button if found, nil otherwise
local function flyoutButtonAnchor(frame)
	local parent = frame:GetParent()
	if not parent then
		return nil
	end

	local _, parentAnchorButton = parent:GetPoint()
	if parentAnchorButton and Module.handledbuttons[parentAnchorButton] then
		return parentAnchorButton
	end

	return nil
end

--- Handles mouse enter events for flyout buttons.
-- Applies fade-in effect to the anchor button's parent.
function Module:FlyoutButton_OnEnter()
	local anchor = flyoutButtonAnchor(self)
	if anchor then
		Module:Button_OnEnter()
	end
end

--- Handles mouse leave events for flyout buttons.
-- Applies fade-out effect to the anchor button's parent.
function Module:FlyoutButton_OnLeave()
	local anchor = flyoutButtonAnchor(self)
	if anchor then
		Module:Button_OnLeave()
	end
end

--- Main event handler for fade parent frame.
-- Determines whether bars should be visible based on configured conditions.
-- Checks: combat, target, casting, health, vehicle, action bar grid.
-- @param event The event name that triggered this handler
function Module:FadeParent_OnEvent(event)
	-- Cache config table for better performance
	local config = C["ActionBar"]

	-- Check all configured fade conditions
	local inCombat = config.BarFadeCombat and UnitAffectingCombat("player")
	local hasTarget = config.BarFadeTarget and UnitExists("target")
	local isCasting = config.BarFadeCasting and (UnitCastingInfo("player") or UnitChannelInfo("player"))
	local lowHealth = config.BarFadeHealth and (UnitHealth("player") < UnitHealthMax("player"))
	local inVehicle = config.BarFadeVehicle and UnitHasVehicleUI("player")

	-- Show bars if any condition is met or action bar grid is shown
	if event == "ACTIONBAR_SHOWGRID" or inCombat or hasTarget or isCasting or lowHealth or inVehicle then
		self.mouseLock = true
		ClearTimers(self)
		K.UIFrameFadeIn(self, 0.2, self:GetAlpha(), 1)
		Module:FadeBlings(1)
	else
		self.mouseLock = false
		DelayFadeOut(self, 0.38, self:GetAlpha(), config.BarFadeAlpha)
		Module:FadeBlings(config.BarFadeAlpha)
	end
end

--[[
	Fade condition options table.
	Each option maps a config key to its event registration/unregistration.
	enable: Function to register necessary events
	events: Array of event names for unregistration
]]
local options = {
	BarFadeCombat = {
		enable = function(self)
			self:RegisterEvent("PLAYER_REGEN_ENABLED")
			self:RegisterEvent("PLAYER_REGEN_DISABLED")
			self:RegisterUnitEvent("UNIT_FLAGS", "player")
		end,
		events = { "PLAYER_REGEN_ENABLED", "PLAYER_REGEN_DISABLED", "UNIT_FLAGS" },
	},
	BarFadeTarget = {
		enable = function(self)
			self:RegisterEvent("PLAYER_TARGET_CHANGED")
		end,
		events = { "PLAYER_TARGET_CHANGED" },
	},
	BarFadeCasting = {
		enable = function(self)
			self:RegisterUnitEvent("UNIT_SPELLCAST_START", "player")
			self:RegisterUnitEvent("UNIT_SPELLCAST_STOP", "player")
			self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", "player")
			self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", "player")
		end,
		events = { "UNIT_SPELLCAST_START", "UNIT_SPELLCAST_STOP", "UNIT_SPELLCAST_CHANNEL_START", "UNIT_SPELLCAST_CHANNEL_STOP" },
	},
	BarFadeHealth = {
		enable = function(self)
			self:RegisterUnitEvent("UNIT_HEALTH", "player")
		end,
		events = { "UNIT_HEALTH" },
	},
	BarFadeVehicle = {
		enable = function(self)
			self:RegisterEvent("UNIT_ENTERED_VEHICLE")
			self:RegisterEvent("UNIT_EXITED_VEHICLE")
			self:RegisterEvent("VEHICLE_UPDATE")
		end,
		events = { "UNIT_ENTERED_VEHICLE", "UNIT_EXITED_VEHICLE", "VEHICLE_UPDATE" },
	},
}

--- Updates fade event registrations based on current config settings.
-- Dynamically registers/unregisters events for enabled/disabled fade conditions.
function Module:UpdateFaderSettings()
	local fadeParent = Module.fadeParent
	if not fadeParent then
		return
	end

	local config = C["ActionBar"]
	for key, option in pairs(options) do
		if config[key] then
			-- Register events for enabled options
			if option.enable then
				option.enable(fadeParent)
			end
		else
			-- Unregister events for disabled options
			if option.events and next(option.events) then
				for _, event in ipairs(option.events) do
					fadeParent:UnregisterEvent(event)
				end
			end
		end
	end

	-- Trigger initial fade state evaluation
	Module.FadeParent_OnEvent(fadeParent)
end

-- Map config keys to action bar frame names
local KKUI_ActionBars = {
	["Bar1Fade"] = "KKUI_ActionBar1",
	["Bar2Fade"] = "KKUI_ActionBar2",
	["Bar3Fade"] = "KKUI_ActionBar3",
	["Bar4Fade"] = "KKUI_ActionBar4",
	["Bar5Fade"] = "KKUI_ActionBar5",
	["Bar6Fade"] = "KKUI_ActionBar6",
	["Bar7Fade"] = "KKUI_ActionBar7",
	["Bar8Fade"] = "KKUI_ActionBar8",
	["BarPetFade"] = "KKUI_ActionBarPet",
	["BarStanceFade"] = "KKUI_ActionBarStance",
}

--- Deferred update handler for combat lockdown.
-- Called after combat ends to update fader state safely.
-- @param event The PLAYER_REGEN_ENABLED event name
local function updateAfterCombat(event)
	Module:UpdateFaderState()
	K:UnregisterEvent(event, updateAfterCombat)
end

--- Updates action bar parenting and hooks based on fade configuration.
-- Reparents bars to fadeParent when fade is enabled, UIParent when disabled.
-- Defers updates during combat lockdown to prevent taint.
function Module:UpdateFaderState()
	-- Defer updates during combat to avoid taint/lockdown issues
	if InCombatLockdown() then
		K:RegisterEvent("PLAYER_REGEN_ENABLED", updateAfterCombat)
		return
	end

	local fadeParent = Module.fadeParent
	local config = C["ActionBar"]

	-- Reparent action bars based on fade settings
	for key, name in pairs(KKUI_ActionBars) do
		local bar = _G[name]
		if bar then
			bar:SetParent(config[key] and fadeParent or UIParent)
		end
	end

	-- Hook button events once (prevents duplicate hooks)
	if not Module.isHooked then
		for _, button in ipairs(Module.buttons) do
			button:HookScript("OnEnter", Module.Button_OnEnter)
			button:HookScript("OnLeave", Module.Button_OnLeave)

			Module.handledbuttons[button] = true
		end

		Module.isHooked = true
	end
end

--- Hooks fade scripts to a flyout button.
-- Ensures flyout buttons trigger fade effects on their parent action button.
-- @param button The flyout button to setup
function Module:SetupFlyoutButton(button)
	if not button then
		return
	end

	button:HookScript("OnEnter", Module.FlyoutButton_OnEnter)
	button:HookScript("OnLeave", Module.FlyoutButton_OnLeave)
end

--- Callback for LibActionButton when a new flyout button is created.
-- @param button The newly created flyout button
function Module:LAB_FlyoutCreated(button)
	Module:SetupFlyoutButton(button)
end

--- Sets up fade hooks for all LibActionButton flyout buttons.
-- Hooks existing flyouts and registers callback for future flyouts.
function Module:SetupLABFlyout()
	-- Hook all existing flyout buttons
	for _, button in next, K.LibActionButton.FlyoutButtons do
		Module:SetupFlyoutButton(button)
	end

	-- Register callback for dynamically created flyout buttons
	K.LibActionButton:RegisterCallback("OnFlyoutButtonCreated", Module.LAB_FlyoutCreated)
end

--- Creates and initializes the global action bar fader system.
-- Sets up the fade parent frame, registers events, and configures initial state.
-- Only runs if BarFadeGlobal is enabled in configuration.
function Module:CreateBarFadeGlobal()
	local config = C["ActionBar"]
	if not config.BarFadeGlobal then
		return
	end

	-- Create secure fade parent frame (hides in pet battles)
	local fadeParent = CreateFrame("Frame", "KKUI_BarFader", UIParent, "SecureHandlerStateTemplate")
	RegisterStateDriver(fadeParent, "visibility", "[petbattle] hide; show")
	fadeParent:SetAlpha(config.BarFadeAlpha)

	-- Register action bar grid events
	fadeParent:RegisterEvent("ACTIONBAR_SHOWGRID")
	fadeParent:RegisterEvent("ACTIONBAR_HIDEGRID")
	fadeParent:SetScript("OnEvent", Module.FadeParent_OnEvent)

	-- Store in module namespace for global access
	Module.fadeParent = fadeParent

	-- Initialize fade system
	Module:UpdateFaderSettings()
	Module:UpdateFaderState()
	Module:SetupLABFlyout()
end
