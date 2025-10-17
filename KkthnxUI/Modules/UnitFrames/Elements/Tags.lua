local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local oUF = K.oUF

local AFK = AFK
local ALTERNATE_POWER_INDEX = Enum.PowerType.Alternate or 10
local DEAD = DEAD
local DND = DND
local GetCreatureDifficultyColor = GetCreatureDifficultyColor
local GetNumArenaOpponentSpecs = GetNumArenaOpponentSpecs
local LEVEL = LEVEL
local PLAYER_OFFLINE = PLAYER_OFFLINE
local UnitBattlePetLevel = UnitBattlePetLevel
local UnitClass = UnitClass
local UnitClassification = UnitClassification
local UnitEffectiveLevel = UnitEffectiveLevel
local UnitGroupRolesAssigned = UnitGroupRolesAssigned
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitIsAFK = UnitIsAFK
local UnitIsBattlePetCompanion = UnitIsBattlePetCompanion
local UnitIsConnected = UnitIsConnected
local UnitIsDND = UnitIsDND
local UnitIsDead = UnitIsDead
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local UnitIsGhost = UnitIsGhost
local UnitIsPlayer = UnitIsPlayer
local UnitIsTapDenied = UnitIsTapDenied
local UnitIsWildBattlePet = UnitIsWildBattlePet
local UnitLevel = UnitLevel
local UnitPower = UnitPower
local UnitPowerType = UnitPowerType
local UnitReaction = UnitReaction
local UnitStagger = UnitStagger

local IsInGroup = IsInGroup
local UnitInParty = UnitInParty
local UnitInRaid = UnitInRaid
local UnitName = UnitName
local GetCVarBool = GetCVarBool
local format = string.format
local strfind = string.find

-- Precomputed atlas strings for role icons to avoid branching and allocations per update
local ROLE_ATLAS = {
	HEALER = "|A:groupfinder-icon-role-micro-heal:12:12|a",
	TANK = "|A:groupfinder-icon-role-micro-tank:12:12|a",
	-- DAMAGER = "|A:groupfinder-icon-role-micro-dps:16:16|a",
}

-- Add scantip back, due to issue on ColorMixin
local scanTip = K.ScanTooltip

local function GetHealthColor(percentage)
	local r, g, b
	if percentage < 20 then
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

local function FormatHealthValue(health, percentage)
	local formattedValue = K.ShortValue(health)
	if percentage < 100 then
		formattedValue = formattedValue .. " - " .. GetHealthColor(percentage)
	end
	return formattedValue
end

local function GetUnitHealthPerc(unit)
	local health, maxHealth = UnitHealth(unit), UnitHealthMax(unit)
	if maxHealth == 0 then
		return 0, health
	else
		return K.Round(health / maxHealth * 100, 1), health
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
	local per = maxPower == 0 and 0 or K.Round(cur / maxPower * 100)

	if unit == "player" or unit == "target" or unit == "focus" then
		if per < 100 and UnitPowerType(unit) == 0 and maxPower ~= 0 then
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
	if UnitIsAFK(unit) then
		return "|cffCFCFCF <" .. AFK .. ">|r"
	elseif UnitIsDND(unit) then
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
	elseif UnitIsAFK(unit) then
		return "|cffCFCFCF <" .. AFK .. ">|r"
	elseif UnitIsDND(unit) then
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
		local loss = UnitHealthMax(unit) - UnitHealth(unit)
		if loss == 0 then
			return
		end
		return K.ShortValue(loss)
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
oUF.Tags.Methods["npctitle"] = function(unit)
	local isPlayer = UnitIsPlayer(unit)
	if isPlayer and NameOnlyGuild then
		local guildName = GetGuildInfo(unit)
		if guildName then
			return "<" .. guildName .. ">"
		end
	elseif not isPlayer and NameOnlyTitle then
		scanTip:SetOwner(UIParent, "ANCHOR_NONE")
		scanTip:SetUnit(unit)

		local textLine = _G[format("KKUI_ScanTooltipTextLeft%d", GetCVarBool("colorblindmode") and 3 or 2)]
		local title = textLine and textLine:GetText()
		if title and not strfind(title, "^" .. LEVEL) then
			return title
		end
	end
end
oUF.Tags.Events["npctitle"] = "UNIT_NAME_UPDATE"

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

oUF.Tags.Methods["tarname"] = function(unit)
	local tarUnit = unit .. "target"
	if UnitExists(tarUnit) then
		local tarClass = select(2, UnitClass(tarUnit))
		return K.RGBToHex(K.Colors.class[tarClass]) .. UnitName(tarUnit)
	end
end
oUF.Tags.Events["tarname"] = "UNIT_NAME_UPDATE UNIT_THREAT_SITUATION_UPDATE UNIT_HEALTH"

-- AltPower value tag
oUF.Tags.Methods["altpower"] = function(unit)
	local cur = UnitPower(unit, ALTERNATE_POWER_INDEX)
	return cur > 0 and cur
end
oUF.Tags.Events["altpower"] = "UNIT_POWER_UPDATE UNIT_MAXPOWER"

-- Monk stagger
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
