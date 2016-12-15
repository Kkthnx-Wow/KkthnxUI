local K, C, L = unpack(select(2, ...))
if C.Unitframe.Enable ~= true and C.Raidframe.Enable ~= true then return end

-- Lua API
local floor = math.floor
local format = string.format

-- Wow API
local GetPVPTimer = GetPVPTimer
local GetQuestDifficultyColor = GetQuestDifficultyColor
local GetTime = GetTime
local IsPVPTimerRunning = IsPVPTimerRunning
local UnitClass = UnitClass
local UnitGroupRolesAssigned = UnitGroupRolesAssigned
local UnitIsAFK = UnitIsAFK
local UnitIsConnected = UnitIsConnected
local UnitLevel = UnitLevel
local UnitName = UnitName
local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax

-- Global variables that we don"t cache, list them here for mikk"s FindGlobals script
-- GLOBALS: SPELL_POWER_MANA, UNKNOWN

local _, ns = ...
local oUF = ns.oUF

oUF.Tags.Events["KkthnxUI:GetNameColor"] = "UNIT_POWER"
oUF.Tags.Methods["KkthnxUI:GetNameColor"] = function(unit)
	local Reaction = UnitReaction(unit, "player")
	if (UnitIsPlayer(unit)) then
		return _TAGS["raidcolor"](unit)
	elseif (Reaction) then
		local c = K.Colors.reaction[Reaction]
		return string.format("|cff%02x%02x%02x", c[1] * 255, c[2] * 255, c[3] * 255)
	else
		return string.format("|cff%02x%02x%02x", .84 * 255, .75 * 255, .65 * 255)
	end
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

oUF.Tags.Events["KkthnxUI:Level"] = "UNIT_LEVEL PLAYER_LEVEL_UP"
oUF.Tags.Methods["KkthnxUI:Level"] = function(unit)
	local r, g, b
	local Level = UnitLevel(unit)
	local Color = GetQuestDifficultyColor(Level)

	if (Level < 0) then
		r, g, b = 1, 0, 0
		Level = "??"
	elseif (Level == 0) then
		r, g, b = Color.r, Color.g, Color.b
		Level = "?"
	else
		r, g, b = Color.r, Color.g, Color.b
		Level = Level
	end

	return format("|cff%02x%02x%02x%s|r", r * 255, g * 255, b * 255, Level)
end

oUF.Tags.Events["KkthnxUI:NameVeryShort"] = "UNIT_NAME_UPDATE"
oUF.Tags.Methods["KkthnxUI:NameVeryShort"] = function(unit)
	local Name = UnitName(unit) or UNKNOWN

	return K.UTF8Sub(Name, 4, true)
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
	if not UnitIsPlayer(unit) then return; end
	local guid = UnitGUID(unit)
	if (UnitIsAFK(unit)) then
		if not unitStatus[guid] or unitStatus[guid] and unitStatus[guid][1] ~= "AFK" then
			unitStatus[guid] = {"AFK", GetTime()}
		end
	elseif(UnitIsDND(unit)) then
		if not unitStatus[guid] or unitStatus[guid] and unitStatus[guid][1] ~= "DND" then
			unitStatus[guid] = {"DND", GetTime()}
		end
	elseif(UnitIsDead(unit)) or (UnitIsGhost(unit))then
		if not unitStatus[guid] or unitStatus[guid] and unitStatus[guid][1] ~= "Dead" then
			unitStatus[guid] = {"Dead", GetTime()}
		end
	elseif(not UnitIsConnected(unit)) then
		if not unitStatus[guid] or unitStatus[guid] and unitStatus[guid][1] ~= "Offline" then
			unitStatus[guid] = {"Offline", GetTime()}
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
if (not oUF.Tags["KkthnxUI:RaidRole"]) then
	oUF.Tags.Methods["KkthnxUI:RaidRole"] = function(unit)
		local Role = UnitGroupRolesAssigned(unit)
		if (Role) then
			if (Role == "TANK") then
				Role = ">"
			elseif (Role == "HEALER") then
				Role = "+"
			elseif (Role == "DAMAGER") then
				Role = "-"
			elseif (Role == "NONE") then
				Role = ""
			end

			return Role
		else
			return ""
		end
	end
end