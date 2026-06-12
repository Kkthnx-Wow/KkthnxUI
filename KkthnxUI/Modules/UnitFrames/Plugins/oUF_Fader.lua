--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Handles unit frame fading based on various conditions (combat, range, etc.).
-- - Design: Based on oUF_Fader by Slakah.
-- - Events: PLAYER_REGEN_ENABLED, PLAYER_TARGET_CHANGED, UNIT_HEALTH, etc.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local oUF = K.oUF

-- REASON: Localize frequently used APIs and utilities for performance
local _G = _G
local assert = _G.assert
local rawget = _G.rawget
local setmetatable = _G.setmetatable
local string_format = _G.string.format
local string_gmatch = _G.string.gmatch
local string_match = _G.string.match
local type = _G.type

local C_PvP_GetZonePVPInfo = _G.C_PvP.GetZonePVPInfo
local IsInInstance = _G.IsInInstance
local UnitCanAttack = _G.UnitCanAttack
local UnitCastingInfo = _G.UnitCastingInfo
local UnitChannelInfo = _G.UnitChannelInfo
local UnitExists = _G.UnitExists
local UnitHealth = _G.UnitHealth
local UnitHealthMax = _G.UnitHealthMax
local UnitIsDeadOrGhost = _G.UnitIsDeadOrGhost
local UnitOnTaxi = _G.UnitOnTaxi
local UnitPower = _G.UnitPower
local UnitPowerMax = _G.UnitPowerMax
local UnitPowerType = _G.UnitPowerType

local IsStealthed = _G.IsStealthed
local IsFlying = _G.IsFlying
local IsResting = _G.IsResting
local InCombatLockdown = _G.InCombatLockdown
local ipairs = _G.ipairs

local eventFrame = CreateFrame("Frame")
local objects = {}
local timer = 0

-- Events
local events = setmetatable({
	Combat = "PLAYER_REGEN_ENABLED:PLAYER_REGEN_DISABLED",
	PlayerTarget = "PLAYER_TARGET_CHANGED",
	PlayerHostileTarget = "PLAYER_TARGET_CHANGED",
	UnitTarget = "UNIT_TARGET",
	UnitHostileTarget = "UNIT_TARGET",
	Resting = "PLAYER_UPDATE_RESTING",
	Flying = "UNIT_FLAGS",
	PlayerTaxi = "UNIT_FLAGS",
	UnitTaxi = "UNIT_FLAGS",
	PlayerMaxHealth = "UNIT_HEALTH",
	UnitMaxHealth = "UNIT_HEALTH",
	PlayerMaxMana = "UNIT_POWER_UPDATE",
	UnitMaxMana = "UNIT_POWER_UPDATE",
	Stealth = "UPDATE_STEALTH",
	PlayerNotMaxHealth = "UNIT_HEALTH",
	PlayerNotMaxMana = "UNIT_POWER_UPDATE",
	Casting = "UNIT_SPELLCAST_START:UNIT_SPELLCAST_FAILED:UNIT_SPELLCAST_STOP:UNIT_SPELLCAST_INTERRUPTED:UNIT_SPELLCAST_CHANNEL_START:UNIT_SPELLCAST_CHANNEL_STOP",
	Arena = "ZONE_CHANGED_NEW_AREA",
	Instance = "PLAYER_ENTERING_WORLD",
}, {
	__index = function(events, k)
		local cond = string_match(k, "not(.+)")
		assert(rawget(events, cond), string_format("Missing event for condition %s", k))
		events[k] = events[cond]
		return events[cond]
	end,
})

-- Conditions
local conditions = setmetatable({
	PlayerHostileTarget = function()
		return UnitCanAttack("player", "target")
	end,

	UnitHostileTarget = function(_, unit)
		return unit and UnitCanAttack(unit, unit .. "target")
	end,

	PlayerTarget = function()
		return UnitExists("target")
	end,

	UnitTarget = function(_, unit)
		return unit and UnitExists(unit .. "target")
	end,

	PlayerTaxi = function()
		return UnitOnTaxi("player")
	end,

	UnitTaxi = function(_, unit)
		return unit and UnitOnTaxi(unit)
	end,

	UnitMaxHealth = function(_, unit)
		return unit and not UnitIsDeadOrGhost(unit) and UnitHealth(unit) == UnitHealthMax(unit)
	end,

	PlayerMaxHealth = function(_, unit)
		return unit and not UnitIsDeadOrGhost("player") and UnitHealth("player") == UnitHealthMax("player")
	end,

	UnitMaxMana = function(_, unit)
		return unit and not UnitIsDeadOrGhost(unit) and UnitPower(unit) == UnitPowerMax(unit)
	end,

	PlayerMaxMana = function(_, unit)
		return unit and not UnitIsDeadOrGhost("player") and UnitPower("player") == UnitPowerMax("player")
	end,

	Stealth = IsStealthed,
	Flying = IsFlying,
	Resting = IsResting,
	Combat = InCombatLockdown,

	PlayerNotMaxHealth = function(_, unit)
		return unit and UnitHealth("player") ~= UnitHealthMax("player")
	end,

	PlayerNotMaxMana = function(_, unit)
		local _, powerTypeString = UnitPowerType("player")
		if powerTypeString ~= "RAGE" and powerTypeString ~= "RUNIC_POWER" then
			return unit and UnitPower("player") ~= UnitPowerMax("player")
		end
	end,

	Casting = function(_, unit)
		return unit and (UnitCastingInfo(unit) or UnitChannelInfo(unit))
	end,

	Arena = function(_, unit)
		return unit and C_PvP_GetZonePVPInfo() == "arena"
	end,

	Instance = function(_, unit)
		return unit and IsInInstance() == true
	end,
}, {
	__index = function(t, k)
		local cond = string_match(k, "not(.+)")
		assert(rawget(t, cond), string_format("Missing condition %s", k))
		t[k] = function(...)
			return not t[cond](...)
		end
		return t[k]
	end,
})

function eventFrame:RegisterCondition(name, func, event)
	assert(type(name) == "string", string_format('Bad argument #1 to "RegisterCondition" (string expected, got %s)', type(name)))
	assert(type(func) == "function", string_format('Bad argument #2 to "RegisterCondition" (function expected, got %s)', type(func)))
	assert(type(event) == "string", string_format('Bad argument #3 to "RegisterCondition" (string expected, got %s)', type(event)))

	conditions[name] = func
	events[name] = event
end

-- REASON: Reusable static hover handlers to avoid dynamic function closure allocations in UpdateAlpha.
local function Fader_OnEnter(self)
	self:SetAlpha(1)
	_G.UnitFrame_OnEnter(self)
end

local function Fader_OnLeave(self)
	self:SetAlpha(self.faderAlpha or self.NormalAlpha or 1)
	_G.UnitFrame_OnLeave(self)
end

-- Update the Alpha or obj
-- PERF: Avoid re-creating function closures for OnEnter/OnLeave. Storing 'alpha' as 'obj.faderAlpha'.
local function UpdateAlpha(obj)
	local alpha
	for _, tbl in ipairs(obj.Fader) do
		for cond, condalpha in pairs(tbl) do
			if conditions[cond](obj, obj.unit) then
				alpha = not alpha and condalpha or condalpha > alpha and condalpha or alpha
			end
		end

		if alpha then
			break
		end
	end

	alpha = alpha or obj.NormalAlpha
	if obj.Range then
		obj.inRangeAlpha = alpha
		obj.outsideRangeAlpha = alpha * obj.outsideRangeAlphaPerc
	end

	obj.faderAlpha = alpha
	if not obj:IsMouseOver() then
		obj:SetAlpha(alpha)
	end
end

-- PERF: Use fast numerical loop to iterate over objects.
local function OnUpdate(addon, elasped) -- I do this because it's easier than passing events to conditions
	if not C["Unitframe"].CombatFade then
		return
	end

	timer = timer + elasped
	if timer > 0.1 then
		timer = 0
		for i = 1, #objects do
			UpdateAlpha(objects[i])
		end
		addon:Hide()
	end
end

oUF:RegisterInitCallback(function(obj)
	local fader = obj.Fader
	if fader then
		for _, tbl in ipairs(fader) do
			for name in pairs(tbl) do
				for event in string_gmatch(events[name], "[^:]+") do
					eventFrame:RegisterEvent(event)
				end
			end
		end

		obj.NormalAlpha = obj.NormalAlpha or obj:GetAlpha()
		obj.outsideRangeAlphaPerc = obj.outsideRangeAlphaPerc or obj.outsideRangeAlpha

		-- Set scripts once during initialization to avoid dynamic allocations
		obj:SetScript("OnEnter", Fader_OnEnter)
		obj:SetScript("OnLeave", Fader_OnLeave)

		UpdateAlpha(obj)
		objects[#objects + 1] = obj
	end
end)
eventFrame:SetScript("OnEvent", eventFrame.Show)
eventFrame:SetScript("OnUpdate", OnUpdate)

eventFrame.Conditions = conditions
eventFrame.Events = events
oUF.Fader = eventFrame
