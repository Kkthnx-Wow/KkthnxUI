--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Defines oUF tags for text display on unitframes and nameplates.
-- - Design: Provides dynamic text strings for health, power, names, levels, etc.
-- - Events: Various UNIT_* events, PLAYER_FLAGS_CHANGED, etc.
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local oUF = K.oUF

-- REASON: Localize C-functions (Snake Case)
local select = _G.select
local string_find = _G.string.find
local string_format = _G.string.format

-- REASON: Localize Globals
local AFK = _G.AFK
local ALTERNATE_POWER_INDEX = _G.Enum.PowerType.Alternate or 10
local DEAD = _G.DEAD
local DND = _G.DND
local GetCreatureDifficultyColor = _G.GetCreatureDifficultyColor
local GetCVarBool = _G.GetCVarBool
local GetGuildInfo = _G.GetGuildInfo
local GetNumArenaOpponentSpecs = _G.GetNumArenaOpponentSpecs
local IsInGroup = _G.IsInGroup
local LEVEL = _G.LEVEL
local PLAYER_OFFLINE = _G.PLAYER_OFFLINE
local UnitBattlePetLevel = _G.UnitBattlePetLevel
local UnitClass = _G.UnitClass
local UnitClassification = _G.UnitClassification
local UnitEffectiveLevel = _G.UnitEffectiveLevel
local UnitGroupRolesAssigned = _G.UnitGroupRolesAssigned
local UnitHealth = _G.UnitHealth
local UnitHealthMax = _G.UnitHealthMax
local UnitInParty = _G.UnitInParty
local UnitInPartyIsAI = _G.UnitInPartyIsAI
local UnitInRaid = _G.UnitInRaid
local UnitIsAFK = _G.UnitIsAFK
local UnitIsBattlePetCompanion = _G.UnitIsBattlePetCompanion
local UnitIsConnected = _G.UnitIsConnected
local UnitIsDND = _G.UnitIsDND
local UnitIsDead = _G.UnitIsDead
local UnitIsDeadOrGhost = _G.UnitIsDeadOrGhost
local UnitIsGhost = _G.UnitIsGhost
local UnitIsPlayer = _G.UnitIsPlayer
local UnitIsTapDenied = _G.UnitIsTapDenied
local UnitIsWildBattlePet = _G.UnitIsWildBattlePet
local UnitLevel = _G.UnitLevel
local UnitName = _G.UnitName
local UnitPower = _G.UnitPower
local UnitPowerMax = _G.UnitPowerMax
local UnitPowerType = _G.UnitPowerType
local UnitReaction = _G.UnitReaction
local UnitStagger = _G.UnitStagger
local UnitHealthPercent = _G.UnitHealthPercent or _G.UnitHealth
local UnitHealthMissing = _G.UnitHealthMissing
local UnitPowerPercent = _G.UnitPowerPercent or _G.UnitPower
local UnitPowerMissing = _G.UnitPowerMissing
local TruncateWhenZero = _G.C_StringUtil and _G.C_StringUtil.TruncateWhenZero or function(n)
	return n ~= 0 and n or ""
end

-- REASON: Precomputed atlas strings for role icons to avoid branching and allocations per update.
local ROLE_ATLAS = {
	HEALER = "|A:groupfinder-icon-role-micro-heal:12:12|a",
	TANK = "|A:groupfinder-icon-role-micro-tank:12:12|a",
	-- DAMAGER = "|A:groupfinder-icon-role-micro-dps:16:16|a",
}

-- REASON: Add scantip back, due to issue on ColorMixin.
local scanTip = K.ScanTooltip

-- REASON: Returns color hex string based on health percentage thresholds.
local function GetHealthColor(percentage)
	local r, g, b
	if not K.NotSecretValue(percentage) then
		r, g, b = 1, 1, 1
	elseif percentage < 20 then
		r, g, b = 1, 0.1, 0.1
	elseif percentage < 35 then
		r, g, b = 1, 0.5, 0
	elseif percentage < 80 then
		r, g, b = 1, 0.9, 0.3
	else
		r, g, b = 1, 1, 1
	end
	return K.RGBToHex(r, g, b) .. percentage
end

-- REASON: Formats health value, appending percentage if below 100%.
local function FormatHealthValue(health, percentage)
	local formattedValue = K.ShortValue(health)
	if K.NotSecretValue(percentage) and percentage < 100 then
		formattedValue = formattedValue .. " - " .. GetHealthColor(percentage)
	elseif not K.NotSecretValue(percentage) then
		formattedValue = formattedValue .. " - " .. GetHealthColor(percentage)
	end
	return formattedValue
end

-- REASON: Calculates health percentage and retrieves current health value.
local function GetUnitHealthPerc(unit)
	if _G.UnitHealthPercent then
		local health = UnitHealth(unit)
		local percentage = _G.UnitHealthPercent(unit, true, CurveConstants.ScaleTo100)
		return K.Round(percentage, 1), health
	else
		local health, maxHealth = UnitHealth(unit), UnitHealthMax(unit)
		if maxHealth == 0 then
			return 0, health
		else
			return K.Round(health / maxHealth * 100, 1), health
		end
	end
end

oUF.Tags.Methods["hp"] = function(unit)
	if UnitIsDeadOrGhost(unit) or not UnitIsConnected(unit) then
		return oUF.Tags.Methods["DDG"](unit)
	else
		local percentage, currentHealth = GetUnitHealthPerc(unit)
		if unit == "player" or unit == "target" or unit == "focus" or (unit and unit:sub(1, 5) == "party") then
			return FormatHealthValue(currentHealth, percentage)
		else
			return GetHealthColor(percentage)
		end
	end
end
oUF.Tags.Events["hp"] = "UNIT_HEALTH UNIT_MAXHEALTH UNIT_CONNECTION PLAYER_FLAGS_CHANGED PARTY_MEMBER_ENABLE PARTY_MEMBER_DISABLE"

oUF.Tags.Methods["power"] = function(unit)
	local cur, maxPower = UnitPower(unit), UnitPowerMax(unit)
	local per
	if _G.UnitPowerPercent then
		per = _G.UnitPowerPercent(unit, nil, true, CurveConstants.ScaleTo100)
	else
		per = maxPower == 0 and 0 or (cur / maxPower * 100)
	end
	per = K.Round(per)

	-- REASON: Display power value - percentage for key units, just percentage for others.
	if unit == "player" or unit == "target" or unit == "focus" then
		if K.NotSecretValue(per) and per < 100 and UnitPowerType(unit) == 0 and cur ~= 0 then
			return K.ShortValue(cur) .. " - " .. per
		else
			return K.ShortValue(cur)
		end
	else
		return per
	end
end
oUF.Tags.Events["power"] = "UNIT_POWER_FREQUENT UNIT_MAXPOWER UNIT_DISPLAYPOWER"

oUF.Tags.Methods["color"] = function(unit)
	local class = select(2, UnitClass(unit))
	local reaction = UnitReaction(unit, "player")

	if UnitIsTapDenied(unit) then
		return K.RGBToHex(oUF.colors.tapped)
	elseif UnitIsPlayer(unit) or UnitInPartyIsAI(unit) then
		return K.RGBToHex(K.Colors.class[class])
	elseif reaction then
		return K.RGBToHex(K.Colors.reaction[reaction])
	else
		return K.RGBToHex(1, 1, 1)
	end
end
oUF.Tags.Events["color"] = "UNIT_HEALTH UNIT_MAXHEALTH UNIT_NAME_UPDATE UNIT_FACTION UNIT_CONNECTION PLAYER_FLAGS_CHANGED"

oUF.Tags.Methods["afkdnd"] = function(unit)
	if UnitIsAFK(unit) and K.NotSecretValue(UnitIsAFK(unit)) then
		return "|cffCFCFCF <" .. AFK .. ">|r"
	elseif UnitIsDND(unit) and K.NotSecretValue(UnitIsDND(unit)) then
		return "|cffCFCFCF <" .. DND .. ">|r"
	else
		return ""
	end
end
oUF.Tags.Events["afkdnd"] = "PLAYER_FLAGS_CHANGED"

oUF.Tags.Methods["DDG"] = function(unit)
	if UnitIsDead(unit) then
		return "|cffCFCFCF" .. DEAD .. "|r"
	elseif UnitIsGhost(unit) then
		return "|cffCFCFCF" .. L["Ghost"] .. "|r"
	elseif not UnitIsConnected(unit) and GetNumArenaOpponentSpecs() == 0 then
		return "|cffCFCFCF" .. PLAYER_OFFLINE .. "|r"
	elseif UnitIsAFK(unit) and K.NotSecretValue(UnitIsAFK(unit)) then
		return "|cffCFCFCF <" .. AFK .. ">|r"
	elseif UnitIsDND(unit) and K.NotSecretValue(UnitIsDND(unit)) then
		return "|cffCFCFCF <" .. DND .. ">|r"
	else
		return ""
	end
end

oUF.Tags.Events["DDG"] = "PLAYER_FLAGS_CHANGED UNIT_HEALTH UNIT_MAXHEALTH UNIT_NAME_UPDATE UNIT_CONNECTION"

-- Level tags
oUF.Tags.Methods["fulllevel"] = function(unit)
	if not UnitIsConnected(unit) then
		return "??"
	end

	local level, realLevel, color, str, class
	if UnitIsWildBattlePet(unit) or UnitIsBattlePetCompanion(unit) then
		level = UnitBattlePetLevel(unit)
		realLevel = level
	else
		realLevel = UnitLevel(unit)
		level = UnitEffectiveLevel(unit)
	end
	color = K.RGBToHex(GetCreatureDifficultyColor(level))

	if level > 0 then
		local realTag = level ~= realLevel and "*" or ""
		str = color .. level .. realTag .. "|r"
	else
		str = "|cffff0000??|r"
	end

	class = UnitClassification(unit)
	if class == "worldboss" then
		str = "|cffAF5050Boss|r"
	elseif class == "rareelite" then
		str = str .. "|cffAF5050R|r+"
	elseif class == "elite" then
		str = str .. "|cffAF5050+|r"
	elseif class == "rare" then
		str = str .. "|cffAF5050R|r"
	end

	return str
end
oUF.Tags.Events["fulllevel"] = "UNIT_LEVEL PLAYER_LEVEL_UP UNIT_CLASSIFICATION_CHANGED"

-- RaidFrame tags
oUF.Tags.Methods["raidhp"] = function(unit)
	if UnitIsDeadOrGhost(unit) or not UnitIsConnected(unit) then
		return oUF.Tags.Methods["DDG"](unit)
	elseif C["Raid"].HealthFormat == 2 then
		local per = GetUnitHealthPerc(unit) or 0
		return GetHealthColor(per)
	elseif C["Raid"].HealthFormat == 3 then
		local cur = UnitHealth(unit)
		return K.ShortValue(cur)
	elseif C["Raid"].HealthFormat == 4 then
		if UnitHealthMissing then
			return TruncateWhenZero(K.ShortValue(UnitHealthMissing(unit)))
		else
			local loss = UnitHealthMax(unit) - UnitHealth(unit)
			return TruncateWhenZero(K.ShortValue(loss))
		end
	end
end
oUF.Tags.Events["raidhp"] = "UNIT_HEALTH UNIT_MAXHEALTH UNIT_NAME_UPDATE UNIT_CONNECTION PLAYER_FLAGS_CHANGED"

-- Nameplate tags
oUF.Tags.Methods["nphp"] = function(unit)
	local per, cur = GetUnitHealthPerc(unit)
	if C["Nameplate"].FullHealth then
		return FormatHealthValue(cur, per)
	elseif per < 100 then
		return GetHealthColor(per)
	end
end
oUF.Tags.Events["nphp"] = "UNIT_HEALTH UNIT_MAXHEALTH UNIT_CONNECTION"

oUF.Tags.Methods["nppp"] = function(unit)
	local per = oUF.Tags.Methods["perpp"](unit)
	local color
	if per > 85 then
		color = K.RGBToHex(1, 0.1, 0.1)
	elseif per > 50 then
		color = K.RGBToHex(1, 1, 0.1)
	else
		color = K.RGBToHex(0.8, 0.8, 1)
	end
	per = color .. per .. "|r"

	return per
end
oUF.Tags.Events["nppp"] = "UNIT_POWER_FREQUENT UNIT_MAXPOWER"

-- REASON: Formats nameplate level differently.
oUF.Tags.Methods["nplevel"] = function(unit)
	-- Get the unit's level
	local level = UnitLevel(unit)

	-- Check if the level is valid and not equal to K.Level
	if level and level ~= K.Level then
		-- Check if the level is greater than 0
		if level > 0 then
			-- Get the difficulty color for the level and convert it to a hex value
			level = K.RGBToHex(GetCreatureDifficultyColor(level)) .. level .. "|r "
		else
			-- Set the level to "??", indicating that the level is unknown
			level = "|cffff0000??|r "
		end
	else
		-- Set the level to an empty string
		level = ""
	end

	-- Return the formatted level string
	return level
end

-- Register the new tag method to listen for the following events:
-- UNIT_LEVEL, PLAYER_LEVEL_UP, UNIT_CLASSIFICATION_CHANGED
oUF.Tags.Events["nplevel"] = "UNIT_LEVEL PLAYER_LEVEL_UP UNIT_CLASSIFICATION_CHANGED"

local NPClassifies = {
	rare = "   ",
	elite = "   ",
	rareelite = "   ",
	worldboss = "   ",
}
oUF.Tags.Methods["nprare"] = function(unit)
	local class = UnitClassification(unit)
	return class and NPClassifies[class]
end
oUF.Tags.Events["nprare"] = "UNIT_CLASSIFICATION_CHANGED"

oUF.Tags.Methods["pppower"] = function(unit)
	local cur = UnitPower(unit)
	local per = oUF.Tags.Methods["perpp"](unit) or 0
	if UnitPowerType(unit) == 0 then
		return per
	else
		return cur
	end
end
oUF.Tags.Events["pppower"] = "UNIT_POWER_FREQUENT UNIT_MAXPOWER UNIT_DISPLAYPOWER"

local NameOnlyGuild = false
local NameOnlyTitle = true
-- REASON: Displays guild for players or title for NPCs on nameplates when in NameOnly mode.
oUF.Tags.Methods["npctitle"] = function(unit)
	local isPlayer = UnitIsPlayer(unit)
	if isPlayer and NameOnlyGuild then
		local guildName = GetGuildInfo(unit)
		if guildName then
			return "<" .. guildName .. ">"
		end
	elseif not isPlayer and NameOnlyTitle then
		scanTip:SetOwner(K.UIFrameHider, "ANCHOR_NONE")
		scanTip:SetUnit(unit)

		local textLine = _G[string_format("KKUI_ScanTooltipTextLeft%d", GetCVarBool("colorblindmode") and 3 or 2)]
		local title = textLine and textLine:GetText()
		if title and K.NotSecretValue(title) and not string_find(title, "^" .. LEVEL) then
			return title
		end
	end
end
oUF.Tags.Events["npctitle"] = "UNIT_NAME_UPDATE"

-- REASON: Displays guild name in brackets.
oUF.Tags.Methods["guildname"] = function(unit)
	if not UnitIsPlayer(unit) then
		return
	end

	local guildName = GetGuildInfo(unit)
	if guildName then
		return "<" .. guildName .. ">"
	end
end
oUF.Tags.Events["guildname"] = "UNIT_NAME_UPDATE"

-- REASON: Target of unit name tag.
oUF.Tags.Methods["tarname"] = function(unit)
	local tarUnit = unit .. "target"
	if UnitExists(tarUnit) then
		local tarClass = select(2, UnitClass(tarUnit))
		return K.RGBToHex(K.Colors.class[tarClass]) .. UnitName(tarUnit)
	end
end
oUF.Tags.Events["tarname"] = "UNIT_NAME_UPDATE UNIT_THREAT_SITUATION_UPDATE UNIT_HEALTH"

-- REASON: Alternative power value (e.g. Boss mechanics).
oUF.Tags.Methods["altpower"] = function(unit)
	local cur = UnitPower(unit, ALTERNATE_POWER_INDEX)
	return TruncateWhenZero(cur)
end
oUF.Tags.Events["altpower"] = "UNIT_POWER_UPDATE UNIT_MAXPOWER"

-- REASON: Monk stagger percentage display.
oUF.Tags.Methods["monkstagger"] = function(unit)
	if unit ~= "player" or K.Class ~= "MONK" then
		return
	end

	local cur = UnitStagger(unit) or 0
	local perc = cur / UnitHealthMax(unit)
	if cur == 0 then
		return
	end

	return K.ShortValue(cur) .. " - " .. K.MyClassColor .. K.Round(perc * 100) .. "%"
end
oUF.Tags.Events["monkstagger"] = "UNIT_MAXHEALTH UNIT_AURA"

-- REASON: LFD/LFR Role icon.
oUF.Tags.Methods["lfdrole"] = function(unit)
	if not IsInGroup() then
		return
	end

	if not (UnitInParty(unit) or UnitInRaid(unit)) then
		return
	end

	local role = UnitGroupRolesAssigned(unit)
	if role and role ~= "NONE" and role ~= "DAMAGER" then
		return ROLE_ATLAS[role]
	end
end
oUF.Tags.Events["lfdrole"] = "PLAYER_ROLES_ASSIGNED GROUP_ROSTER_UPDATE"
