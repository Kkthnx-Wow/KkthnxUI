--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Universal action bar fading and visibility management.
-- - Design: Reparents bars to a global fader frame to handle bulk alpha transitions.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("ActionBar")

-- NOTE: Credit: ElvUI

-- ---------------------------------------------------------------------------
-- LOCALS & CACHING
-- ---------------------------------------------------------------------------

-- PERF: Cache globals and unit info APIs for frequent update cycles.
local _G = _G
local pairs, ipairs, next = pairs, ipairs, next
local UnitAffectingCombat, UnitExists, UnitHealth, UnitHealthMax = UnitAffectingCombat, UnitExists, UnitHealth, UnitHealthMax
local UnitCastingInfo, UnitChannelInfo, UnitHasVehicleUI = UnitCastingInfo, UnitChannelInfo, UnitHasVehicleUI
local CreateFrame, C_Timer = CreateFrame, C_Timer
local InCombatLockdown, RegisterStateDriver = InCombatLockdown, RegisterStateDriver
local IsSecret = K.IsSecret

-- NOTE: Module state management.
Module.fadeParent = nil
Module.handledbuttons = {}

-- ---------------------------------------------------------------------------
-- FADER HELPERS
-- ---------------------------------------------------------------------------

-- REASON: Safely cancels a C_Timer to avoid script errors if a timer is already expired.
local function CancelTimer(timer)
	if timer and not timer:IsCancelled() then
		timer:Cancel()
	end
end

local function ClearTimers(object)
	CancelTimer(object.delayTimer)
	object.delayTimer = nil
end

-- REASON: Provides a smooth exit from mouse-over state by delaying the fade-out.
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

-- REASON: Cooldown "bling" textures (flashes) often ignore parent alpha,
-- so we swap them to blank when the bar is faded to maintain immersion.
function Module:FadeBlingTexture(cooldown, alpha)
	if cooldown then
		cooldown:SetBlingTexture(alpha > 0.5 and [[Interface\Cooldown\star4]] or C["Media"].Textures.BlankTexture)
	end
end

function Module:FadeBlings(alpha)
	for _, button in ipairs(Module.buttons) do
		Module:FadeBlingTexture(button.cooldown, alpha)
	end
end

-- ---------------------------------------------------------------------------
-- EVENT HANDLERS
-- ---------------------------------------------------------------------------

function Module:Button_OnEnter()
	local fadeParent = Module.fadeParent
	if not fadeParent or fadeParent.mouseLock then
		return
	end

	ClearTimers(fadeParent)
	K.UIFrameFadeIn(fadeParent, 0.2, fadeParent:GetAlpha(), 1)
	Module:FadeBlings(1)
end

function Module:Button_OnLeave()
	local fadeParent = Module.fadeParent
	if not fadeParent or fadeParent.mouseLock then
		return
	end

	DelayFadeOut(fadeParent, 0.38, fadeParent:GetAlpha(), C["ActionBar"].BarFadeAlpha)
	Module:FadeBlings(C["ActionBar"].BarFadeAlpha)
end

-- NOTE: Traverse hierarchy to find the main action button associated with a flyout.
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

function Module:FlyoutButton_OnEnter()
	local anchor = flyoutButtonAnchor(self)
	if anchor then
		Module:Button_OnEnter()
	end
end

function Module:FlyoutButton_OnLeave()
	local anchor = flyoutButtonAnchor(self)
	if anchor then
		Module:Button_OnLeave()
	end
end

-- REASON: Evaluates game state (combat, target, HP) to force bars to stay visible.
function Module:FadeParent_OnEvent(event)
	local config = C["ActionBar"]

	local inCombat = config.BarFadeCombat and UnitAffectingCombat("player")
	local hasTarget = config.BarFadeTarget and UnitExists("target")
	local isCasting = config.BarFadeCasting and (UnitCastingInfo("player") or UnitChannelInfo("player"))
	local lowHealth = false
	if config.BarFadeHealth then
		local health, healthMax = UnitHealth("player"), UnitHealthMax("player")
		if not IsSecret(health) and not IsSecret(healthMax) then
			lowHealth = health < healthMax
		end
	end
	local inCombat_Regen = event == "PLAYER_REGEN_DISABLED" -- NOTE: Immediate response to combat entry.
	local inVehicle = config.BarFadeVehicle and UnitHasVehicleUI("player")

	-- NOTE: mouseLock=true prevents OnLeave from fading the bars while a condition is active.
	if event == "ACTIONBAR_SHOWGRID" or inCombat or hasTarget or isCasting or lowHealth or inVehicle or inCombat_Regen then
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

-- ---------------------------------------------------------------------------
-- STATE MANAGEMENT
-- ---------------------------------------------------------------------------

-- NOTE: Map config keys to their corresponding event groups for dynamic registration.
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

function Module:UpdateFaderSettings()
	local fadeParent = Module.fadeParent
	if not fadeParent then
		return
	end

	local config = C["ActionBar"]
	for key, option in pairs(options) do
		if config[key] then
			if option.enable then
				option.enable(fadeParent)
			end
		else
			if option.events and next(option.events) then
				for _, event in ipairs(option.events) do
					fadeParent:UnregisterEvent(event)
				end
			end
		end
	end

	Module.FadeParent_OnEvent(fadeParent)
end

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

local function updateAfterCombat(event)
	Module:UpdateFaderState()
	K:UnregisterEvent(event, updateAfterCombat)
end

-- REASON: Synchronizes bar parenting with the fader frame based on user settings.
function Module:UpdateFaderState()
	-- WARNING: Direct parent changes during combat can cause secure system taint.
	if InCombatLockdown() then
		K:RegisterEvent("PLAYER_REGEN_ENABLED", updateAfterCombat)
		return
	end

	local fadeParent = Module.fadeParent
	local config = C["ActionBar"]

	-- NOTE: Bars that are NOT set to fade are returned to UIParent for normal behavior.
	for key, name in pairs(KKUI_ActionBars) do
		local bar = _G[name]
		if bar then
			bar:SetParent(config[key] and fadeParent or UIParent)
		end
	end

	-- NOTE: Apply interaction hooks once to all detectable action buttons.
	if not Module.isHooked then
		for _, button in ipairs(Module.buttons) do
			button:HookScript("OnEnter", Module.Button_OnEnter)
			button:HookScript("OnLeave", Module.Button_OnLeave)

			Module.handledbuttons[button] = true
		end

		Module.isHooked = true
	end
end

-- ---------------------------------------------------------------------------
-- INITIALIZATION
-- ---------------------------------------------------------------------------

function Module:SetupFlyoutButton(button)
	if not button then
		return
	end

	button:HookScript("OnEnter", Module.FlyoutButton_OnEnter)
	button:HookScript("OnLeave", Module.FlyoutButton_OnLeave)
end

function Module:LAB_FlyoutCreated(button)
	Module:SetupFlyoutButton(button)
end

-- REASON: Ensures flyout menus (e.g. portals, mounts) also trigger the fader logic.
function Module:SetupLABFlyout()
	for _, button in next, K.LibActionButton.FlyoutButtons do
		Module:SetupFlyoutButton(button)
	end

	K.LibActionButton:RegisterCallback("OnFlyoutButtonCreated", Module.LAB_FlyoutCreated)
end

-- REASON: Creates the core fader controller. Built as a secure frame to handle
-- visibility during Pet Battles automatically.
function Module:CreateBarFadeGlobal()
	local config = C["ActionBar"]
	if not config.BarFadeGlobal then
		return
	end

	local fadeParent = CreateFrame("Frame", "KKUI_BarFader", UIParent, "SecureHandlerStateTemplate")
	RegisterStateDriver(fadeParent, "visibility", "[petbattle] hide; show")
	fadeParent:SetAlpha(config.BarFadeAlpha)

	fadeParent:RegisterEvent("ACTIONBAR_SHOWGRID")
	fadeParent:RegisterEvent("ACTIONBAR_HIDEGRID")
	fadeParent:SetScript("OnEvent", Module.FadeParent_OnEvent)

	Module.fadeParent = fadeParent

	Module:UpdateFaderSettings()
	Module:UpdateFaderState()
	Module:SetupLABFlyout()
end
