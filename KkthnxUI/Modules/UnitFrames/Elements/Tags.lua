local K, C, L = unpack(select(2, ...))
if C.Unitframe.Enable ~= true and C.Raidframe.Enable ~= true and C.Nameplates.Enable ~= true then return end

-- Lua API
local _G = _G
local floor = math.floor
local format = string.format
local gsub = string.gsub
local strlen = string.len

-- Wow API
local C_PetJournal_GetPetTeamAverageLevel = C_PetJournal.GetPetTeamAverageLevel
local GetPVPTimer = GetPVPTimer
local GetQuestDifficultyColor = GetQuestDifficultyColor
local GetQuestGreenRange = GetQuestGreenRange
local GetRelativeDifficultyColor = GetRelativeDifficultyColor
local GetTime = GetTime
local IsPVPTimerRunning = IsPVPTimerRunning
local QuestDifficultyColors = QuestDifficultyColors
local UnitBattlePetLevel = UnitBattlePetLevel
local UnitClass = UnitClass
local UnitClassification = UnitClassification
local UnitEffectiveLevel = UnitEffectiveLevel
local UnitGroupRolesAssigned = UnitGroupRolesAssigned
local UnitGUID = UnitGUID
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitIsAFK = UnitIsAFK
local UnitIsBattlePetCompanion = UnitIsBattlePetCompanion
local UnitIsConnected = UnitIsConnected
local UnitIsDND = UnitIsDND
local UnitIsPlayer = UnitIsPlayer
local UnitIsPVP = UnitIsPVP
local UnitIsPVPFreeForAll = UnitIsPVPFreeForAll
local UnitIsUnit = UnitIsUnit
local UnitIsWildBattlePet = UnitIsWildBattlePet
local UnitLevel = UnitLevel
local UnitName = UnitName
local UNITNAME_SUMMON_TITLE17 = UNITNAME_SUMMON_TITLE17
local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax
local UnitReaction = UnitReaction

-- Global variables that we don"t cache, list them here for mikk"s FindGlobals script
-- GLOBALS: SPELL_POWER_MANA, UNKNOWN, Hex, Role, _TAGS, r, g, b, u

local _, ns = ...
local oUF = ns.oUF or oUF

local function UnitName(unit)
	local name, realm = _G.UnitName(unit)
	if name == UNKNOWN and K.Class == "MONK" and UnitIsUnit(unit, "pet") then
		name = UNITNAME_SUMMON_TITLE17:format(_G.UnitName("player"))
	else
		return name, realm
	end
end

-- KkthnxUI Unitframe Tags
oUF.Tags.Events["KkthnxUI:GetNameColor"] = "UNIT_NAME_UPDATE"
oUF.Tags.Methods["KkthnxUI:GetNameColor"] = function(unit)
	local unitReaction = UnitReaction(unit, "player")
	local _, unitClass = UnitClass(unit)
	if (UnitIsPlayer(unit)) then
		local class = K.Colors.class[unitClass]
		if not class then return "" end
		return Hex(class[1], class[2], class[3])
	elseif (unitReaction) then
		local reaction = K.Colors.reaction[unitReaction]
		return Hex(reaction[1], reaction[2], reaction[3])
	else
		return "|cffc2c2c2"
	end
end

-- We will just use this for now.
oUF.Tags.Events["KkthnxUI:NameColor"] = "UNIT_NAME_UPDATE"
oUF.Tags.Methods["KkthnxUI:NameColor"] = function(unit)
	return format("|cff%02x%02x%02x", 1 * 255, 1 * 255, 1 * 255)
end

oUF.Tags.Events["KkthnxUI:DruidMana"] = "UNIT_POWER UNIT_DISPLAYPOWER UNIT_MAXPOWER"
oUF.Tags.Methods["KkthnxUI:DruidMana"] = function(unit)
	local min, max = UnitPower(unit, SPELL_POWER_MANA), UnitPowerMax(unit, SPELL_POWER_MANA)
	if (min == max) then
		return K.UnitframeValue(min)
	else
		return K.UnitframeValue(min).."/"..K.UnitframeValue(max)
	end
end

oUF.Tags.OnUpdateThrottle["KkthnxUI:PvPTimer"] = 1
oUF.Tags.Methods["KkthnxUI:PvPTimer"] = function(unit)
	if (UnitIsPVPFreeForAll(unit) or UnitIsPVP(unit)) then
		local pvpTime = (GetPVPTimer() or 0)/1000
		if (not IsPVPTimerRunning()) or (pvpTime < 1) or (pvpTime > 300) then --999?
			return ""
		end

		return K.FormatTime(floor(pvpTime))
	end
end

oUF.Tags.Events["KkthnxUI:DifficultyColor"] = "UNIT_LEVEL PLAYER_LEVEL_UP"
oUF.Tags.Methods["KkthnxUI:DifficultyColor"] = function(unit)
	local r, g, b = 0.55, 0.57, 0.61
	if (UnitIsWildBattlePet(unit) or UnitIsBattlePetCompanion(unit)) then
		local level = UnitBattlePetLevel(unit)
		local teamLevel = C_PetJournal_GetPetTeamAverageLevel()
		if teamLevel < level or teamLevel > level then
			local c = GetRelativeDifficultyColor(teamLevel, level)
			r, g, b = c.r, c.g, c.b
		else
			local c = QuestDifficultyColors["difficult"]
			r, g, b = c.r, c.g, c.b
		end
	else
		local DiffColor = UnitLevel(unit) - UnitLevel("player")
		if (DiffColor >= 5) then
			r, g, b = 0.69, 0.31, 0.31
		elseif (DiffColor >= 3) then
			r, g, b = 0.71, 0.43, 0.27
		elseif (DiffColor >= -2) then
			r, g, b = 0.84, 0.75, 0.65
		elseif (-DiffColor <= GetQuestGreenRange()) then
			r, g, b = 0.33, 0.59, 0.33
		else
			r, g, b = 0.55, 0.57, 0.61
		end
	end
	return Hex(r, g, b)
end

oUF.Tags.Events["KkthnxUI:ClassificationShort"] = "UNIT_CLASSIFICATION_CHANGED"
oUF.Tags.Methods["KkthnxUI:ClassificationShort"] = function(unit)
	local c = UnitClassification(u)
	if(c == "rare") then
		return "R"
	elseif(c == "rareelite") then
		return "R+"
	elseif(c == "elite") then
		return "+"
	elseif(c == "worldboss") then
		return "B"
	elseif(c == "minus") then
		return "-"
	end
end

oUF.Tags.Events["KkthnxUI:ClassificationColor"] = "UNIT_CLASSIFICATION_CHANGED"
oUF.Tags.Methods["KkthnxUI:ClassificationColor"] = function(unit)
	local c = UnitClassification(unit)
	if(c == "rare" or c == "elite") then
		return Hex(1, 0.5, 0.25) --Orange
	elseif(c == "rareelite" or c == "worldboss") then
		return Hex(1, 0, 0) --Red
	end
end

oUF.Tags.Events["KkthnxUI:Level"] = "UNIT_LEVEL PLAYER_LEVEL_UP"
oUF.Tags.Methods["KkthnxUI:Level"] = function(unit)
	local level = UnitEffectiveLevel(unit)

	if UnitIsWildBattlePet(unit) or UnitIsBattlePetCompanion(unit) then
		level = UnitBattlePetLevel(unit)
	end

	if level > 0 then
		return level
	else
		return "??"
	end
end

oUF.Tags.Events["KkthnxUI:NameVeryShort"] = "UNIT_NAME_UPDATE"
oUF.Tags.Methods["KkthnxUI:NameVeryShort"] = function(unit)
	local Name = UnitName(unit) or UNKNOWN
	return K.UTF8Sub(Name, 5, true)
end

oUF.Tags.Events["KkthnxUI:NameShort"] = "UNIT_NAME_UPDATE"
oUF.Tags.Methods["KkthnxUI:NameShort"] = function(unit)
	local Name = UnitName(unit) or UNKNOWN
	return K.UTF8Sub(Name, 8, true)
end

oUF.Tags.Events["KkthnxUI:NameMedium"] = "UNIT_NAME_UPDATE"
oUF.Tags.Methods["KkthnxUI:NameMedium"] = function(unit)
	local Name = UnitName(unit) or UNKNOWN
	return K.UTF8Sub(Name, 15, true)
end

oUF.Tags.Events["KkthnxUI:NameLong"] = "UNIT_NAME_UPDATE"
oUF.Tags.Methods["KkthnxUI:NameLong"] = function(unit)
	local Name = UnitName(unit) or UNKNOWN
	return K.UTF8Sub(Name, 20, true)
end

local unitStatus = {}
oUF.Tags.OnUpdateThrottle["KkthnxUI:StatusTimer"] = 1
oUF.Tags.Methods["KkthnxUI:StatusTimer"] = function(unit)
	if not UnitIsPlayer(unit) then return end
	local guid = UnitGUID(unit)
	if (UnitIsAFK(unit)) then
		if not unitStatus[guid] or unitStatus[guid] and unitStatus[guid][1] ~= "AFK" then
			unitStatus[guid] = {"AFK", GetTime()}
		end
	elseif(UnitIsDND(unit)) then
		if not unitStatus[guid] or unitStatus[guid] and unitStatus[guid][1] ~= "DND" then
			unitStatus[guid] = {"DND", GetTime()}
		end
	else
		unitStatus[guid] = nil
	end
	if unitStatus[guid] ~= nil then
		local status = unitStatus[guid][1]
		local timer = GetTime() - unitStatus[guid][2]
		local mins = floor(timer / 60)
		local secs = floor(timer - (mins * 60))
		return ("%s (%01.f:%02.f)"):format(status, mins, secs)
	else
		return ""
	end
end

oUF.Tags.Events["KkthnxUI:RaidRole"] = "GROUP_ROSTER_UPDATE PLAYER_ROLES_ASSIGNED"
oUF.Tags.Methods["KkthnxUI:RaidRole"] = function(unit)
	local role = UnitGroupRolesAssigned(unit)
	if role then
		if role == "TANK" then
			return "|cff0070DET|r"
		elseif role == "HEALER" then
			return "|cff00CC12H|r"
		elseif role == "DAMAGER" then
			return "" -- We do not need to be spammed :D
		elseif role == "NONE" then
			return ""
		end

		return Role
	else
		return ""
	end
end

-- KkthnxUI Nameplate Tags
oUF.Tags.Events["NameplateNameLong"] = "UNIT_NAME_UPDATE"
oUF.Tags.Methods["NameplateNameLong"] = function(unit)
	local name = UnitName(unit)
	return K.UTF8Sub(name, 18, true)
end

oUF.Tags.Events["NameplateNameLongAbbrev"] = "UNIT_NAME_UPDATE"
oUF.Tags.Methods["NameplateNameLongAbbrev"] = function(unit)
	local name = UnitName(unit)
	local newname = (strlen(name) > 18) and gsub(name, "%s?(.[\128-\191]*)%S+%s", "%1. ") or name
	return K.UTF8Sub(newname, 18, false)
end

-- oUF.Tags.Events["NameplateLevelDiffColor"] = "UNIT_LEVEL"
-- oUF.Tags.Methods["NameplateLevelDiffColor"] = function(unit)
-- 	local r, g, b
-- 	local level = UnitLevel(unit)
-- 	if level < 1 then
-- 		r, g, b = 0.69, 0.31, 0.31
-- 	else
-- 		local DiffColor = UnitLevel(unit) - UnitLevel("player")
-- 		if DiffColor >= 5 then
-- 			r, g, b = 0.69, 0.31, 0.31
-- 		elseif DiffColor >= 3 then
-- 			r, g, b = 0.71, 0.43, 0.27
-- 		elseif DiffColor >= -2 then
-- 			r, g, b = 0.84, 0.75, 0.65
-- 		elseif -DiffColor <= GetQuestGreenRange() then
-- 			r, g, b = 0.33, 0.59, 0.33
-- 		else
-- 			r, g, b = 0.55, 0.57, 0.61
-- 		end
-- 	end
-- 	return format("|cff%02x%02x%02x", r * 255, g * 255, b * 255)
-- end

-- oUF.Tags.Events["NameplateLevel"] = "UNIT_LEVEL PLAYER_LEVEL_UP"
-- oUF.Tags.Methods["NameplateLevel"] = function(unit)
-- 	local level = UnitLevel(unit)
-- 	local c = UnitClassification(unit)
-- 	if UnitIsWildBattlePet(unit) or UnitIsBattlePetCompanion(unit) then
-- 		level = UnitBattlePetLevel(unit)
-- 	end
--
-- 	if level == K.Level and c == "normal" then return end
-- 	if level > 0 then
-- 		return level
-- 	else
-- 		return "??"
-- 	end
-- end

oUF.Tags.Events["NameplateNameColor"] = "UNIT_POWER UNIT_FLAGS"
oUF.Tags.Methods["NameplateNameColor"] = function(unit)
	local reaction = UnitReaction(unit, "player")
	if not UnitIsUnit("player", unit) and UnitIsPlayer(unit) and (reaction and reaction >= 5) then
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

oUF.Tags.Events["NameplateHealth"] = "UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH NAME_PLATE_UNIT_ADDED"
oUF.Tags.Methods["NameplateHealth"] = function(unit)
	local hp = UnitHealth(unit)
	local maxhp = UnitHealthMax(unit)
	if maxhp == 0 then
		return 0
	else
		return ("%s - %d%%"):format(K.ShortValue(hp), hp / maxhp * 100 + 0.5)
	end
end