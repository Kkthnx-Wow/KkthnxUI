local K, C, L = unpack(select(2, ...))
if C.Unitframe.Enable ~= true and C.Raidframe.Enable ~= true and C.Nameplates.Enable ~= true then return end

local _, ns = ...
local oUF = ns.oUF or oUF
assert(oUF, "KkthnxUI was unable to locate oUF.")

-- Lua API
local _G = _G
local format = format
local math_floor = math.floor
local string_format = string.format
local string_gsub = string.gsub
local string_len = string.len

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
local UnitIsCorpse = UnitIsCorpse
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

local function UnitName(unit)
	local name, realm = _G.UnitName(unit)
	if name == UNKNOWN and K.Class == "MONK" and UnitIsUnit(unit, "pet") then
		name = UNITNAME_SUMMON_TITLE17:format(_G.UnitName("player"))
	else
		return name, realm
	end
end

-- KkthnxUI Unitframe Tags
oUF.Tags.Events["KkthnxUI:GetNameColor"] = "UNIT_NAME_UPDATE UNIT_POWER"
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
oUF.Tags.Events["KkthnxUI:NameColor"] = "UNIT_NAME_UPDATE UNIT_POWER"
oUF.Tags.Methods["KkthnxUI:NameColor"] = function(unit)
	return string_format("|cff%02x%02x%02x", 1 * 255, 1 * 255, 1 * 255)
end

oUF.Tags.Events["KkthnxUI:DruidMana"] = "UNIT_POWER UNIT_MAXPOWER"
oUF.Tags.Methods["KkthnxUI:DruidMana"] = function(unit)
	local min, max = UnitPower(unit, SPELL_POWER_MANA), UnitPowerMax(unit, SPELL_POWER_MANA)
	if (min == max) then
		return K.ShortValue(min)
	else
		return K.ShortValue(min).."/"..K.ShortValue(max)
	end
end

oUF.Tags.OnUpdateThrottle["KkthnxUI:PvPTimer"] = 1
oUF.Tags.Methods["KkthnxUI:PvPTimer"] = function(unit)
	if (UnitIsPVPFreeForAll(unit) or UnitIsPVP(unit)) then
		local pvpTime = (GetPVPTimer() or 0)/1000
		if (not IsPVPTimerRunning()) or (pvpTime < 1) or (pvpTime > 300) then --999?
			return ""
		end

		return K.FormatTime(math_floor(pvpTime))
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
		local DiffColor = UnitLevel(unit) - UnitLevel('player')
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

oUF.Tags.Events["KkthnxUI:ClassificationColor"] = "UNIT_CLASSIFICATION_CHANGED"
oUF.Tags.Methods["KkthnxUI:ClassificationColor"] = function(unit)
	local c = UnitClassification(unit)
	if(c == "rare" or c == "elite") then
		return Hex(0.69, 0.31, 0.31) -- Red
	elseif(c == "rareelite" or c == "worldboss") then
		return Hex(0.69, 0.31, 0.31) -- Red
	end
end

oUF.Tags.Events["KkthnxUI:Level"] = "UNIT_LEVEL PLAYER_LEVEL_UP"
oUF.Tags.Methods["KkthnxUI:Level"] = function(unit)
	local level = UnitLevel(unit)

	if (UnitIsWildBattlePet(unit) or UnitIsBattlePetCompanion(unit)) then
		return UnitBattlePetLevel(unit)
	elseif (level > 0) then
		return level
	else
		return "??"
	end
end

oUF.Tags.Events["KkthnxUI:NameVeryShort"] = "UNIT_NAME_UPDATE"
oUF.Tags.Methods["KkthnxUI:NameVeryShort"] = function(unit)
	local Name = UnitName(unit) or UNKNOWN
	return Name ~= nil and K.UTF8Sub(Name, 5, true) or ""
end

oUF.Tags.Events["KkthnxUI:NameShort"] = "UNIT_NAME_UPDATE"
oUF.Tags.Methods["KkthnxUI:NameShort"] = function(unit)
	local Name = UnitName(unit) or UNKNOWN
	return Name ~= nil and K.UTF8Sub(Name, 8, true) or ""
end

oUF.Tags.Events["KkthnxUI:NameMedium"] = "UNIT_NAME_UPDATE"
oUF.Tags.Methods["KkthnxUI:NameMedium"] = function(unit)
	local Name = UnitName(unit) or UNKNOWN
	return Name ~= nil and K.UTF8Sub(Name, 15, true) or ""
end

oUF.Tags.Events["KkthnxUI:NameLong"] = "UNIT_NAME_UPDATE"
oUF.Tags.Methods["KkthnxUI:NameLong"] = function(unit)
	local Name = UnitName(unit) or UNKNOWN
	return Name ~= nil and K.UTF8Sub(Name, 20, true) or ""
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
		local mins = math_floor(timer / 60)
		local secs = math_floor(timer - (mins * 60))
		return ("%s (%01.f:%02.f)"):format(status, mins, secs)
	else
		return ""
	end
end

oUF.Tags.Events["KkthnxUI:RaidRole"] = "GROUP_ROSTER_UPDATE PLAYER_ROLES_ASSIGNED"
oUF.Tags.Methods["KkthnxUI:RaidRole"] = function(unit)
	local role = UnitGroupRolesAssigned(unit)
	local string = ""

	if role then
		if role == "TANK" then
			string = "|cff0099CCT|r"
		elseif role == "HEALER" then
			string = "|cff00FF00H|r"
		end

		return string
	end
end

-- </ Nameplate Tags > --
oUF.Tags.Events["KkthnxUI:NameplateLevel"] = "UNIT_LEVEL PLAYER_LEVEL_UP"
oUF.Tags.Methods["KkthnxUI:NameplateLevel"] = function(unit)
	local level = UnitLevel(unit)
	local classification = UnitClassification(unit)

	if (UnitIsWildBattlePet(unit) or UnitIsBattlePetCompanion(unit)) then
		return UnitBattlePetLevel(unit)
	end

	if level == K.Level and classification == "normal" then
		return " "
	elseif (level > 0) then
		return level
	else
		return "??"
	end
end

oUF.Tags.Events["KkthnxUI:NameplateNameLong"] = "UNIT_NAME_UPDATE"
oUF.Tags.Methods["KkthnxUI:NameplateNameLong"] = function(unit)
	local name = UnitName(unit)
	return K.UTF8Sub(name, 18, true)
end

oUF.Tags.Events["KkthnxUI:NameplateNameLongAbbrev"] = "UNIT_NAME_UPDATE"
oUF.Tags.Methods["KkthnxUI:NameplateNameLongAbbrev"] = function(unit)
	local name = UnitName(unit)
	local newname = (string_len(name) > 18) and string_gsub(name, "%s?(.[\128-\191]*)%S+%s", "%1. ") or name
	return K.UTF8Sub(newname, 18, false)
end

oUF.Tags.Events["KkthnxUI:NameplateNameColor"] = "UNIT_POWER UNIT_FLAGS"
oUF.Tags.Methods["KkthnxUI:NameplateNameColor"] = function(unit)
	local reaction = UnitReaction(unit, "player")
	if not UnitIsUnit("player", unit) and UnitIsPlayer(unit) and (reaction and reaction >= 5) then
		local color = K.Colors.power["MANA"]
		return string_format("|cff%02x%02x%02x", color[1] * 255, color[2] * 255, color[3] * 255)
	elseif UnitIsPlayer(unit) then
		return _TAGS["raidcolor"](unit)
	elseif reaction then
		local color = K.Colors.reaction[reaction]
		return string_format("|cff%02x%02x%02x", color[1] * 255, color[2] * 255, color[3] * 255)
	else
		r, g, b = 0.33, 0.59, 0.33
		return string_format("|cff%02x%02x%02x", r * 255, g * 255, b * 255)
	end
end

oUF.Tags.Events["KkthnxUI:NameplateHealth"] = "UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH NAME_PLATE_UNIT_ADDED"
oUF.Tags.Methods["KkthnxUI:NameplateHealth"] = function(unit)
	local health = UnitHealth(unit)
	local maxhealth = UnitHealthMax(unit)
	if maxhealth == 0 then
		return 0
	else
		return ("%s - %d%%"):format(K.ShortValue(health), health / maxhealth * 100 + 0.5)
	end
end