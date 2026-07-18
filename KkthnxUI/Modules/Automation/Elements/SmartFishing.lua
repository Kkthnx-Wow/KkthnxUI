--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Notes:
-- - Purpose: While fishing: widen soft-target interact, mute ambience, rebind
--   fishing action-bar key to INTERACTTARGET for one-key bobber loot.
-- - Design: Hold Shift when casting to skip. Restores CVars on channel stop,
--   combat (state driver), or logout. Always restore CVars you override.
-- - Events: UNIT_SPELLCAST_SENT, UNIT_SPELLCAST_CHANNEL_START/STOP, PLAYER_LOGOUT
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Automation")

local CreateFrame = CreateFrame
local GetActionInfo = GetActionInfo
local GetBindingKey = GetBindingKey
local InCombatLockdown = InCombatLockdown
local IsShiftKeyDown = IsShiftKeyDown
local RegisterStateDriver = RegisterStateDriver
local SetOverrideBinding = SetOverrideBinding
local ClearOverrideBindings = ClearOverrideBindings
local UnregisterStateDriver = UnregisterStateDriver
local C_Timer_After = C_Timer.After
local C_CVar_GetCVar = C_CVar.GetCVar
local C_CVar_SetCVar = C_CVar.SetCVar

local NUM_ACTIONBAR_BUTTONS = NUM_ACTIONBAR_BUTTONS or 12
local ActionBarButtonNames = ActionButtonUtil and ActionButtonUtil.ActionBarButtonNames

local FISHING_SPELLS = {
	[131474] = true,
	[131476] = true,
	[131490] = true,
	[295727] = true,
	[377895] = true,
	[405274] = true,
	[463743] = true,
	[1224771] = true,
	[1239040] = true,
}

local FISHING_CVARS = {
	Sound_EnableSFX = "1",
	Sound_MasterVolume = "1",
	Sound_MusicVolume = "0",
	Sound_AmbienceVolume = "0",
	Sound_SFXVolume = "1",
	SoftTargetInteract = "3",
	SoftTargetInteractArc = "2",
	SoftTargetInteractRange = "30",
	SoftTargetIconInteract = "1",
	SoftTargetIconGameObject = "1",
}

local handler = CreateFrame("Frame", nil, nil, "SecureHandlerStateTemplate")
handler:SetAttribute("_onstate-combat", [[
	if newstate == "clear" then
		self:ClearBindings()
	end
]])

local storedCVars = {}
local activeFishingSpell
local eventsRegistered = false
local channelStopRegistered = false
local logoutRegistered = false

local function RestoreCVars()
	for name, value in pairs(storedCVars) do
		C_CVar_SetCVar(name, value)
		storedCVars[name] = nil
	end
end

local function ClearFishingBindings()
	C_Timer_After(0, function()
		if handler then
			ClearOverrideBindings(handler)
			UnregisterStateDriver(handler, "combat")
		end
	end)
end

local function StopSmartFishing()
	RestoreCVars()
	ClearFishingBindings()
	activeFishingSpell = nil
	if channelStopRegistered then
		K:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_STOP", Module._SmartFishingChannelStop)
		channelStopRegistered = false
	end
	if logoutRegistered then
		K:UnregisterEvent("PLAYER_LOGOUT", Module._SmartFishingLogout)
		logoutRegistered = false
	end
end

local function ApplyOverrideBindings()
	if not activeFishingSpell or not ActionBarButtonNames or InCombatLockdown() then
		return
	end

	for i = 1, #ActionBarButtonNames do
		local barName = ActionBarButtonNames[i]
		for index = 1, NUM_ACTIONBAR_BUTTONS do
			local button = _G[barName .. index]
			if button and button.action then
				local _, actionID = GetActionInfo(button.action)
				if actionID == activeFishingSpell and button.bindingAction then
					local key1, key2 = GetBindingKey(button.bindingAction)
					if key1 then
						SetOverrideBinding(handler, true, key1, "INTERACTTARGET")
					end
					if key2 then
						SetOverrideBinding(handler, true, key2, "INTERACTTARGET")
					end
				end
			end
		end
	end

	RegisterStateDriver(handler, "combat", "[combat] clear; nothing")
end

local function ApplyFishingCVars()
	for name, value in pairs(FISHING_CVARS) do
		if storedCVars[name] == nil then
			storedCVars[name] = C_CVar_GetCVar(name)
		end
		C_CVar_SetCVar(name, value)
	end
end

-- K:RegisterUnitEvent dispatches (event, unit, ...payload).
function Module._SmartFishingChannelStop(_, _, _, spellID)
	if FISHING_SPELLS[spellID] then
		StopSmartFishing()
	end
end

function Module._SmartFishingLogout()
	RestoreCVars()
end

function Module._SmartFishingChannelStart(_, _, _, spellID)
	if not C["Automation"].SmartFishing or IsShiftKeyDown() or InCombatLockdown() then
		return
	end
	if not FISHING_SPELLS[spellID] then
		return
	end

	ApplyFishingCVars()
	ApplyOverrideBindings()

	if not channelStopRegistered then
		channelStopRegistered = true
		K:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", Module._SmartFishingChannelStop, "player")
	end
	if not logoutRegistered then
		logoutRegistered = true
		K:RegisterEvent("PLAYER_LOGOUT", Module._SmartFishingLogout)
	end
end

function Module._SmartFishingSpellSent(_, _, _, _, spellID)
	if spellID and FISHING_SPELLS[spellID] then
		activeFishingSpell = spellID
	end
end

function Module:CreateSmartFishing()
	if not C["Automation"].SmartFishing then
		if eventsRegistered then
			K:UnregisterEvent("UNIT_SPELLCAST_SENT", Module._SmartFishingSpellSent)
			K:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_START", Module._SmartFishingChannelStart)
			eventsRegistered = false
		end
		StopSmartFishing()
		return
	end

	if eventsRegistered then
		return
	end
	eventsRegistered = true
	K:RegisterUnitEvent("UNIT_SPELLCAST_SENT", Module._SmartFishingSpellSent, "player")
	K:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", Module._SmartFishingChannelStart, "player")
end
