local K, C = unpack(KkthnxUI)
local oUF = K.oUF

--	Based on oUF_Fader(by Slakah)

local assert = assert
local rawget = rawget
local setmetatable = setmetatable
local string_format = string.format
local string_gmatch = string.gmatch
local string_match = string.match
local type = type

local GetZonePVPInfo = GetZonePVPInfo
local IsInInstance = IsInInstance
local UnitCanAttack = UnitCanAttack
local UnitCastingInfo = UnitCastingInfo
local UnitChannelInfo = UnitChannelInfo
local UnitExists = UnitExists
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local UnitOnTaxi = UnitOnTaxi
local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax
local UnitPowerType = UnitPowerType

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
		return unit and GetZonePVPInfo() == "arena"
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

-- Update the Alpha or obj
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

	obj:SetAlpha(alpha)
	obj:SetScript("OnEnter", function(self)
		self:SetAlpha(1)
		_G.UnitFrame_OnEnter(obj)
	end)

	obj:SetScript("OnLeave", function(self)
		self:SetAlpha(alpha)
		_G.UnitFrame_OnLeave(obj)
	end)
end

local function OnUpdate(addon, elasped) -- I do this because it's easier than passing events to conditions
	if not C["Unitframe"].CombatFade then
		return
	end

	timer = timer + elasped
	if timer > 0.1 then
		timer = 0
		for _, v in ipairs(objects) do
			UpdateAlpha(v)
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
		UpdateAlpha(obj)
		objects[#objects + 1] = obj
	end
end)
eventFrame:SetScript("OnEvent", eventFrame.Show)
eventFrame:SetScript("OnUpdate", OnUpdate)

eventFrame.Conditions = conditions
eventFrame.Events = events
oUF.Fader = eventFrame
