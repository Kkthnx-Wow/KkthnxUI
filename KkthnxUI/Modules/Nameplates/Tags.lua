local K, C, L = select(2, ...):unpack()
if C.Nameplates.Enable ~= true then return end

local _, ns = ...
local oUF = ns.oUF

-- Lua API
local format = string.format
local gsub = string.gsub
local strlen = string.len

-- Wow API
local GetQuestGreenRange = GetQuestGreenRange
local UnitBattlePetLevel = UnitBattlePetLevel
local UnitClassification = UnitClassification
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitIsBattlePetCompanion = UnitIsBattlePetCompanion
local UnitIsPlayer = UnitIsPlayer
local UnitIsUnit = UnitIsUnit
local UnitIsWildBattlePet = UnitIsWildBattlePet
local UnitLevel = UnitLevel
local UnitName = UnitName
local UnitReaction = UnitReaction

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: _TAGS, r, g, b

-- Nameplate Tags
oUF.Tags.Methods["NameplateNameLongAbbrev"] = function(unit)
	local name = UnitName(unit)
	local newname = (strlen(name) > 18) and gsub(name, "%s?(.[\128-\191]*)%S+%s", "%1. ") or name
	return K.Abbreviate(newname, 18, false)
end
oUF.Tags.Events["NameplateNameLongAbbrev"] = "UNIT_NAME_UPDATE"

oUF.Tags.Methods["NameplateDiffColor"] = function(unit)
	local r, g, b
	local level = UnitLevel(unit)
	if level < 1 then
		r, g, b = 0.69, 0.31, 0.31
	else
		local DiffColor = UnitLevel(unit) - UnitLevel("player")
		if DiffColor >= 5 then
			r, g, b = 0.69, 0.31, 0.31
		elseif DiffColor >= 3 then
			r, g, b = 0.71, 0.43, 0.27
		elseif DiffColor >= -2 then
			r, g, b = 0.84, 0.75, 0.65
		elseif -DiffColor <= GetQuestGreenRange() then
			r, g, b = 0.33, 0.59, 0.33
		else
			r, g, b = 0.55, 0.57, 0.61
		end
	end
	return format("|cff%02x%02x%02x", r * 255, g * 255, b * 255)
end
oUF.Tags.Events["NameplateDiffColor"] = "UNIT_LEVEL"

oUF.Tags.Methods["NameplateLevel"] = function(unit)
	local level = UnitLevel(unit)
	local c = UnitClassification(unit)
	if UnitIsWildBattlePet(unit) or UnitIsBattlePetCompanion(unit) then
		level = UnitBattlePetLevel(unit)
	end

	if level == K.Level and c == "normal" then return end
	if level > 0 then
		return level
	else
		return "??"
	end
end
oUF.Tags.Events["NameplateLevel"] = "UNIT_LEVEL PLAYER_LEVEL_UP"

oUF.Tags.Methods["NameplateNameColor"] = function(unit)
	local reaction = UnitReaction(unit, "player")
	if not UnitIsUnit("player", unit) and UnitIsPlayer(unit) and reaction >= 5 then
		local c = K.Colors.power["MANA"]
		return format("|cff%02x%02x%02x", c[1] * 255, c[2] * 255, c[3] * 255)
	elseif UnitIsPlayer(unit) then
		return _TAGS["raidcolor"](unit)
	elseif reaction then
		local c = K.Colors.reaction[reaction]
		return format("|cff%02x%02x%02x", c[1] * 255, c[2] * 255, c[3] * 255)
	else
		r, g, b = 0.33, 0.59, 0.33
		return format("|cff%02x%02x%02x", r * 255, g * 255, b * 255)
	end
end
oUF.Tags.Events["NameplateNameColor"] = "UNIT_POWER UNIT_FLAGS"

oUF.Tags.Methods["NameplateHealth"] = function(unit)
	local hp = UnitHealth(unit)
	local maxhp = UnitHealthMax(unit)
	if maxhp == 0 then
		return 0
	else
		return ("%s - %d%%"):format(K.ShortValue(hp), hp / maxhp * 100 + 0.5)
	end
end
oUF.Tags.Events["NameplateHealth"] = "UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH NAME_PLATE_UNIT_ADDED"