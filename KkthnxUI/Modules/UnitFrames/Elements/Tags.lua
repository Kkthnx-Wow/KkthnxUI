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
local UnitExists = _G.UnitExists
local UnitLevel = _G.UnitLevel
local UnitName = _G.UnitName
local UnitPower = _G.UnitPower
local UnitPowerMax = _G.UnitPowerMax
local UnitPowerType = _G.UnitPowerType
local UnitReaction = _G.UnitReaction
local UnitStagger = _G.UnitStagger
local UnitPowerDisplayMod = _G.UnitPowerDisplayMod
local Enum = _G.Enum

-- REASON: Precomputed atlas strings for role icons to avoid branching and allocations per update.
local ROLE_ATLAS = {
	HEALER = "|A:groupfinder-icon-role-micro-heal:12:12|a",
	TANK = "|A:groupfinder-icon-role-micro-tank:12:12|a",
	-- DAMAGER = "|A:groupfinder-icon-role-micro-dps:16:16|a",
}

-- REASON: Add scantip back, due to issue on ColorMixin.
local scanTip = K.ScanTooltip

-- REASON: Precomputed static strings for common tags to avoid repeated concatenation.
local DEAD_STRING = "|cffCFCFCF" .. DEAD .. "|r"
local GHOST_STRING = "|cffCFCFCF" .. L["Ghost"] .. "|r"
local OFFLINE_STRING = "|cffCFCFCF" .. PLAYER_OFFLINE .. "|r"
local AFK_STRING = "|cffCFCFCF <" .. AFK .. ">|r"
local DND_STRING = "|cffCFCFCF <" .. DND .. ">|r"
local UNKNOWN_LEVEL_STRING = "|cffff0000??|r"
local BOSS_STRING = "|cffAF5050Boss|r"

-- PERF: unit tokens are stable ("party1", "raid3", ...); cache derived "...target"
-- strings so tag hot paths stop allocating every UNIT_HEALTH fire.
local targetTokenCache = {}
local function GetTargetToken(unit)
	local token = targetTokenCache[unit]
	if not token then
		token = unit .. "target"
		targetTokenCache[unit] = token
	end
	return token
end

-- PERF: health gradient tags rebuild the same hex+percent string for the same
-- rounded percentage across many frames; cache by integer percent bucket.
local healthColorCache = {}
local function GetHealthColor(percentage)
	local bucket = K.Round(percentage)
	local cached = healthColorCache[bucket]
	if cached then
		return cached
	end

	local r, g, b = oUF:ColorGradient(percentage, 100, 1, 0.1, 0.1, 1, 0.5, 0, 1, 0.9, 0.3, 1, 1, 1)
	cached = K.RGBToHex(r, g, b) .. bucket
	healthColorCache[bucket] = cached
	return cached
end

local IsSecret = K.IsSecret
local NotSecret = K.NotSecret

local function SafeShortValue(value)
	if value == nil then
		return
	end

	-- SECRET (12.0): Secret numbers cannot pass through K.ShortValue because it
	-- performs comparisons/arithmetic. Blizzard's AbbreviateNumbers is safe and
	-- returns a secret string that can be routed to FontString:SetText by oUF tags.
	if IsSecret(value) then
		return AbbreviateNumbers(value)
	end

	return K.ShortValue(value)
end

-- REASON: Formats health value, appending percentage if below 100%.
local function FormatHealthValue(health, percentage)
	local formattedValue = SafeShortValue(health)
	if formattedValue and percentage and percentage < 100 then
		formattedValue = string_format("%s - %s", formattedValue, GetHealthColor(percentage))
	end
	return formattedValue
end

-- REASON: Calculates health percentage and retrieves current health value.
local function GetUnitHealthPerc(unit)
	local health, maxHealth = UnitHealth(unit), UnitHealthMax(unit)
	if IsSecret(health) or IsSecret(maxHealth) then
		return nil, health
	end

	if maxHealth == 0 then
		return 0, health
	else
		return K.Round(health / maxHealth * 100, 1), health
	end
end

oUF.Tags.Methods["hp"] = function(unit)
	local connected = UnitIsConnected(unit)
	if NotSecret(connected) and not connected then
		return oUF.Tags.Methods["DDG"](unit)
	end

	local dead = UnitIsDeadOrGhost(unit)
	if NotSecret(dead) and dead then
		return oUF.Tags.Methods["DDG"](unit)
	else
		local percentage, currentHealth = GetUnitHealthPerc(unit)
		if unit == "player" or unit == "target" or unit == "focus" or unit:sub(1, 5) == "party" then
			return FormatHealthValue(currentHealth, percentage)
		elseif percentage then
			return GetHealthColor(percentage)
		end
	end
end
oUF.Tags.Events["hp"] = "UNIT_HEALTH UNIT_MAXHEALTH UNIT_CONNECTION PLAYER_FLAGS_CHANGED PARTY_MEMBER_ENABLE PARTY_MEMBER_DISABLE"

oUF.Tags.Methods["power"] = function(unit)
	local cur, maxPower = UnitPower(unit), UnitPowerMax(unit)
	if IsSecret(cur) or IsSecret(maxPower) then
		if unit == "player" or unit == "target" or unit == "focus" then
			return SafeShortValue(cur)
		end
		return
	end

	local per = maxPower == 0 and 0 or K.Round(cur / maxPower * 100)

	-- REASON: Display power value - percentage for key units, just percentage for others.
	if unit == "player" or unit == "target" or unit == "focus" then
		if per < 100 and UnitPowerType(unit) == 0 and maxPower ~= 0 then
			return string_format("%s - %s", SafeShortValue(cur), per)
		else
			return SafeShortValue(cur)
		end
	else
		return per
	end
end
oUF.Tags.Events["power"] = "UNIT_POWER_FREQUENT UNIT_MAXPOWER UNIT_DISPLAYPOWER"

oUF.Tags.Methods["color"] = function(unit)
	-- SECRET (12.0): boss/instance units hide identity, so these return secret
	-- booleans/values that can't be branched on or used as table keys. Fall back to
	-- white whenever a read is secret (mirrors K.UnitColor's safe fallback).
	local tapped = UnitIsTapDenied(unit)
	if NotSecret(tapped) and tapped then
		return K.RGBToHex(oUF.colors.tapped)
	end

	local isPlayer = UnitIsPlayer(unit)
	if IsSecret(isPlayer) then
		return K.RGBToHex(1, 1, 1)
	end

	if not isPlayer then
		local isAI = UnitInPartyIsAI(unit)
		if IsSecret(isAI) then
			return K.RGBToHex(1, 1, 1)
		end
		isPlayer = isAI
	end

	if isPlayer then
		local class = select(2, UnitClass(unit))
		if class and NotSecret(class) then
			return K.RGBToHex(K.Colors.class[class])
		end
		return K.RGBToHex(1, 1, 1)
	end

	local reaction = UnitReaction(unit, "player")
	if reaction and NotSecret(reaction) then
		return K.RGBToHex(K.Colors.reaction[reaction])
	end

	local r, g, b = K.GetNpcReactionColor(unit)
	if r then
		return K.RGBToHex(r, g, b)
	end

	return K.RGBToHex(1, 1, 1)
end
oUF.Tags.Events["color"] = "UNIT_HEALTH UNIT_MAXHEALTH UNIT_NAME_UPDATE UNIT_FACTION UNIT_CONNECTION PLAYER_FLAGS_CHANGED"

oUF.Tags.Methods["afkdnd"] = function(unit)
	-- SECRET (12.0): UnitIsAFK/UnitIsDND return secret booleans on boss/instance
	-- units and must not be boolean-tested directly.
	local afk = UnitIsAFK(unit)
	if NotSecret(afk) and afk then
		return AFK_STRING
	end

	local dnd = UnitIsDND(unit)
	if NotSecret(dnd) and dnd then
		return DND_STRING
	end

	return ""
end
oUF.Tags.Events["afkdnd"] = "PLAYER_FLAGS_CHANGED"

oUF.Tags.Methods["DDG"] = function(unit)
	-- SECRET (12.0): all of these state APIs can return secret booleans on
	-- restricted units; gate each before the boolean test.
	local dead = UnitIsDead(unit)
	if NotSecret(dead) and dead then
		return DEAD_STRING
	end

	local ghost = UnitIsGhost(unit)
	if NotSecret(ghost) and ghost then
		return GHOST_STRING
	end

	local connected = UnitIsConnected(unit)
	if NotSecret(connected) and not connected and GetNumArenaOpponentSpecs() == 0 then
		return OFFLINE_STRING
	end

	local afk = UnitIsAFK(unit)
	if NotSecret(afk) and afk then
		return AFK_STRING
	end

	local dnd = UnitIsDND(unit)
	if NotSecret(dnd) and dnd then
		return DND_STRING
	end

	return ""
end

oUF.Tags.Events["DDG"] = "PLAYER_FLAGS_CHANGED UNIT_HEALTH UNIT_MAXHEALTH UNIT_NAME_UPDATE UNIT_CONNECTION"

-- ---------------------------------------------------------------------------
-- Level Tags
-- ---------------------------------------------------------------------------
oUF.Tags.Methods["fulllevel"] = function(unit)
	local connected = UnitIsConnected(unit)
	if NotSecret(connected) and not connected then
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

	if IsSecret(level) or IsSecret(realLevel) then
		return UNKNOWN_LEVEL_STRING
	end

	color = K.RGBToHex(GetCreatureDifficultyColor(level))

	if level > 0 then
		local realTag = level ~= realLevel and "*" or ""
		str = color .. level .. realTag .. "|r"
	else
		str = UNKNOWN_LEVEL_STRING
	end

	class = UnitClassification(unit)
	if class and NotSecret(class) then
		if class == "worldboss" then
			str = BOSS_STRING
		elseif class == "rareelite" then
			str = str .. "|cffAF5050R|r+"
		elseif class == "elite" then
			str = str .. "|cffAF5050+|r"
		elseif class == "rare" then
			str = str .. "|cffAF5050R|r"
		end
	end

	return str
end
oUF.Tags.Events["fulllevel"] = "UNIT_LEVEL PLAYER_LEVEL_UP UNIT_CLASSIFICATION_CHANGED"

-- ---------------------------------------------------------------------------
-- RaidFrame Tags
-- ---------------------------------------------------------------------------
oUF.Tags.Methods["raidhp"] = function(unit)
	local connected = UnitIsConnected(unit)
	if NotSecret(connected) and not connected then
		return oUF.Tags.Methods["DDG"](unit)
	end

	local dead = UnitIsDeadOrGhost(unit)
	if NotSecret(dead) and dead then
		return oUF.Tags.Methods["DDG"](unit)
	end

	local format = C["Raid"].HealthFormat
	if format == 1 then
		return ""
	elseif format == 2 then
		local per = GetUnitHealthPerc(unit)
		if per then
			return GetHealthColor(per)
		end
	elseif format == 3 then
		local cur = UnitHealth(unit)
		return SafeShortValue(cur)
	elseif format == 4 then
		local health, maxHealth = UnitHealth(unit), UnitHealthMax(unit)
		if IsSecret(health) or IsSecret(maxHealth) then
			return
		end

		local loss = maxHealth - health
		if loss == 0 then
			return
		end
		return SafeShortValue(loss)
	end
end
oUF.Tags.Events["raidhp"] = "UNIT_HEALTH UNIT_MAXHEALTH UNIT_NAME_UPDATE UNIT_CONNECTION PLAYER_FLAGS_CHANGED"

-- ---------------------------------------------------------------------------
-- Nameplate Tags
-- ---------------------------------------------------------------------------
oUF.Tags.Methods["nphp"] = function(unit)
	local connected = UnitIsConnected(unit)
	if NotSecret(connected) and not connected then
		return
	end

	local dead = UnitIsDeadOrGhost(unit)
	if NotSecret(dead) and dead then
		return
	end

	local per, cur = GetUnitHealthPerc(unit)
	if C["Nameplate"].FullHealth then
		return FormatHealthValue(cur, per)
	elseif per and per < 100 then
		return GetHealthColor(per)
	end
end
oUF.Tags.Events["nphp"] = "UNIT_HEALTH UNIT_MAXHEALTH UNIT_CONNECTION"

local NP_POWER_HIGH = K.RGBToHex(1, 0.1, 0.1)
local NP_POWER_MED = K.RGBToHex(1, 1, 0.1)
local NP_POWER_LOW = K.RGBToHex(0.8, 0.8, 1)

oUF.Tags.Methods["nppp"] = function(unit)
	local cur, maxPower = UnitPower(unit), UnitPowerMax(unit)
	if IsSecret(cur) or IsSecret(maxPower) then
		return UnitPowerType(unit) == 0 and nil or SafeShortValue(cur)
	end

	local per = maxPower == 0 and 0 or K.Round(cur / maxPower * 100)
	local color
	if per > 85 then
		color = NP_POWER_HIGH
	elseif per > 50 then
		color = NP_POWER_MED
	else
		color = NP_POWER_LOW
	end
	return string_format("%s%s|r", color, per)
end
oUF.Tags.Events["nppp"] = "UNIT_POWER_FREQUENT UNIT_MAXPOWER"

-- REASON: Formats nameplate level differently, hiding the text if it matches the player's level to reduce clutter.
oUF.Tags.Methods["nplevel"] = function(unit)
	local level = UnitLevel(unit)
	if IsSecret(level) then
		return ""
	end

	if level and level ~= K.Level then
		if level > 0 then
			level = K.RGBToHex(GetCreatureDifficultyColor(level)) .. level .. "|r "
		else
			level = UNKNOWN_LEVEL_STRING .. " "
		end
	else
		level = ""
	end

	return level
end

oUF.Tags.Events["nplevel"] = "UNIT_LEVEL PLAYER_LEVEL_UP UNIT_CLASSIFICATION_CHANGED"

local NPClassifies = {
	rare = "   ",
	elite = "   ",
	rareelite = "   ",
	worldboss = "   ",
}
oUF.Tags.Methods["nprare"] = function(unit)
	local class = UnitClassification(unit)
	if NotSecret(class) and class then
		return NPClassifies[class]
	end
end
oUF.Tags.Events["nprare"] = "UNIT_CLASSIFICATION_CHANGED"

oUF.Tags.Methods["pppower"] = function(unit)
	local cur = UnitPower(unit)
	local maxPower = UnitPowerMax(unit)
	if IsSecret(cur) or IsSecret(maxPower) then
		return UnitPowerType(unit) == 0 and nil or SafeShortValue(cur)
	end

	local per = maxPower == 0 and 0 or K.Round(cur / maxPower * 100)
	if UnitPowerType(unit) == 0 then
		return per
	else
		return SafeShortValue(cur)
	end
end
oUF.Tags.Events["pppower"] = "UNIT_POWER_FREQUENT UNIT_MAXPOWER UNIT_DISPLAYPOWER"

local NameOnlyGuild = false
local NameOnlyTitle = true

-- PERF: Lazy-cache left tooltip lines to avoid high-frequency string format and dynamic lookups on _G.
-- REASON: Resolving these once lazily guarantees load-order safety while completely eliminating memory allocations.
local tooltipLine2, tooltipLine3

-- REASON: Displays guild for players or title for NPCs on nameplates when in NameOnly mode.
oUF.Tags.Methods["npctitle"] = function(unit)
	-- SECRET (12.0): on restricted nameplates UnitIsPlayer returns a secret boolean
	-- that cannot be branched on, so bail when the identity is hidden.
	local isPlayer = UnitIsPlayer(unit)
	if IsSecret(isPlayer) then
		return
	end

	if isPlayer and NameOnlyGuild then
		local guildName = GetGuildInfo(unit)
		if guildName and K.NotSecret(guildName) then
			return string_format("<%s>", guildName)
		end
	elseif not isPlayer and NameOnlyTitle then
		scanTip:SetOwner(K.UIFrameHider, "ANCHOR_NONE")
		scanTip:SetUnit(unit)

		if not tooltipLine2 then
			tooltipLine2 = _G.KKUI_ScanTooltipTextLeft2
			tooltipLine3 = _G.KKUI_ScanTooltipTextLeft3
		end

		local textLine = GetCVarBool("colorblindmode") and tooltipLine3 or tooltipLine2
		local title = textLine and textLine:GetText()
		-- SECRET (12.0): the scanned title string can be secret in instances;
		-- string_find performs a string conversion that errors on secret strings.
		if title and K.NotSecret(title) and not string_find(title, "^" .. LEVEL) then
			return title
		end
	end
end
oUF.Tags.Events["npctitle"] = "UNIT_NAME_UPDATE"

-- REASON: Displays guild name in brackets.
oUF.Tags.Methods["guildname"] = function(unit)
	local isPlayer = UnitIsPlayer(unit)
	if not (NotSecret(isPlayer) and isPlayer) then
		return
	end

	local guildName = GetGuildInfo(unit)
	if guildName and NotSecret(guildName) then
		return string_format("<%s>", guildName)
	end
end
oUF.Tags.Events["guildname"] = "UNIT_NAME_UPDATE"

-- REASON: Target of unit name tag.
oUF.Tags.Methods["tarname"] = function(unit)
	local tarUnit = GetTargetToken(unit)
	local exists = UnitExists(tarUnit)
	if NotSecret(exists) and not exists then
		return
	end

	local name = UnitName(tarUnit)
	if not name then
		return
	end

	-- SECRET (12.0): class-colored concatenation is unsafe on secret names.
	if IsSecret(name) then
		return name
	end

	local tarClass = select(2, UnitClass(tarUnit))
	if tarClass and NotSecret(tarClass) then
		return string_format("%s%s", K.RGBToHex(K.Colors.class[tarClass]), name)
	end

	return name
end
oUF.Tags.Events["tarname"] = "UNIT_NAME_UPDATE UNIT_THREAT_SITUATION_UPDATE UNIT_HEALTH"

-- REASON: Alternative power value (e.g. Boss mechanics).
oUF.Tags.Methods["altpower"] = function(unit)
	local cur = UnitPower(unit, ALTERNATE_POWER_INDEX)
	if IsSecret(cur) then
		return SafeShortValue(cur)
	end

	return cur > 0 and cur
end
oUF.Tags.Events["altpower"] = "UNIT_POWER_UPDATE UNIT_MAXPOWER"

-- REASON: Monk stagger percentage display.
oUF.Tags.Methods["monkstagger"] = function(unit)
	if unit ~= "player" or K.Class ~= "MONK" then
		return
	end

	local cur = UnitStagger(unit) or 0
	local maxHealth = UnitHealthMax(unit)
	if IsSecret(cur) or IsSecret(maxHealth) then
		return SafeShortValue(cur)
	end

	if cur == 0 or maxHealth == 0 then
		return
	end

	local perc = cur / maxHealth
	return string_format("%s - %s%s%%", SafeShortValue(cur), K.MyClassColor, K.Round(perc * 100))
end
oUF.Tags.Events["monkstagger"] = "UNIT_MAXHEALTH UNIT_AURA"

local POWER_COMBO = Enum.PowerType.ComboPoints
local POWER_HOLY = Enum.PowerType.HolyPower
local POWER_CHI = Enum.PowerType.Chi
local POWER_ESSENCE = Enum.PowerType.Essence
local POWER_ARCANE = Enum.PowerType.ArcaneCharges
local POWER_SOUL = Enum.PowerType.SoulShards
local POWER_ENERGY = Enum.PowerType.Energy

local C_UnitAuras_GetAuraDataBySpellID = C_UnitAuras and C_UnitAuras.GetAuraDataBySpellID
local C_UnitAuras_GetPlayerAuraBySpellID = C_UnitAuras and C_UnitAuras.GetPlayerAuraBySpellID
local C_Spell_GetSpellMaxCumulativeAuraApplications = C_Spell and C_Spell.GetSpellMaxCumulativeAuraApplications

local SPELL_ICICLES = 205473
local SPELL_MAELSTROM_WEAPON = 344179
local SPELL_TIP_OF_THE_SPEAR = 260286
local SPELL_DARK_HEART = 1225789
local SPELL_VOID_METAMORPHOSIS = 1217607
local SPELL_SILENCE_THE_WHISPERS = 1227702

local function GetAuraBySpellID(unit, spellID)
	if unit == "player" and C_UnitAuras_GetPlayerAuraBySpellID then
		return C_UnitAuras_GetPlayerAuraBySpellID(spellID)
	end
	if C_UnitAuras_GetAuraDataBySpellID then
		return C_UnitAuras_GetAuraDataBySpellID(unit, spellID)
	end
end

local function GetAuraApplicationCount(unit, spellID)
	local aura = GetAuraBySpellID(unit, spellID)
	if not aura then
		return 0
	end

	local count = aura.applications
	if count == nil or IsSecret(count) then
		return count
	end

	return count
end

local function GetAuraMaxApplications(spellID)
	if not (spellID and C_Spell_GetSpellMaxCumulativeAuraApplications) then
		return
	end
	return C_Spell_GetSpellMaxCumulativeAuraApplications(spellID)
end

local function GetUnitClassPowerValues(unit)
	if not UnitExists(unit) then
		return
	end

	local _, class = UnitClass(unit)
	if IsSecret(class) or not class then
		return
	end

	if class == "ROGUE" then
		return UnitPower(unit, POWER_COMBO), UnitPowerMax(unit, POWER_COMBO)
	end

	if class == "DRUID" then
		local powerType = UnitPowerType(unit)
		if NotSecret(powerType) and powerType == POWER_ENERGY then
			return UnitPower(unit, POWER_COMBO), UnitPowerMax(unit, POWER_COMBO)
		end
		return
	end

	if class == "PALADIN" then
		return UnitPower(unit, POWER_HOLY), UnitPowerMax(unit, POWER_HOLY)
	end

	if class == "MONK" then
		return UnitPower(unit, POWER_CHI), UnitPowerMax(unit, POWER_CHI)
	end

	if class == "EVOKER" then
		return UnitPower(unit, POWER_ESSENCE), UnitPowerMax(unit, POWER_ESSENCE)
	end

	if class == "MAGE" then
		local icicles = GetAuraApplicationCount(unit, SPELL_ICICLES)
		if icicles == nil or IsSecret(icicles) then
			if icicles then
				return icicles, GetAuraMaxApplications(SPELL_ICICLES)
			end
		elseif icicles > 0 then
			return icicles, GetAuraMaxApplications(SPELL_ICICLES)
		end
		return UnitPower(unit, POWER_ARCANE), UnitPowerMax(unit, POWER_ARCANE)
	end

	if class == "WARLOCK" then
		local cur = UnitPower(unit, POWER_SOUL, true)
		if IsSecret(cur) then
			return cur, UnitPowerMax(unit, POWER_SOUL)
		end
		local mod = UnitPowerDisplayMod(POWER_SOUL)
		if mod and mod > 0 and not IsSecret(mod) then
			cur = cur / mod
		end
		return cur, UnitPowerMax(unit, POWER_SOUL)
	end

	if class == "HUNTER" then
		return GetAuraApplicationCount(unit, SPELL_TIP_OF_THE_SPEAR), GetAuraMaxApplications(SPELL_TIP_OF_THE_SPEAR)
	end

	if class == "SHAMAN" then
		return GetAuraApplicationCount(unit, SPELL_MAELSTROM_WEAPON), GetAuraMaxApplications(SPELL_MAELSTROM_WEAPON)
	end

	if class == "DEMONHUNTER" then
		if GetAuraBySpellID(unit, SPELL_VOID_METAMORPHOSIS) then
			return GetAuraApplicationCount(unit, SPELL_SILENCE_THE_WHISPERS), GetAuraMaxApplications(SPELL_SILENCE_THE_WHISPERS)
		end
		return GetAuraApplicationCount(unit, SPELL_DARK_HEART), GetAuraMaxApplications(SPELL_DARK_HEART)
	end
end

local function FormatClassPowerTag(cur, max)
	if cur == nil then
		return
	end
	if IsSecret(cur) or IsSecret(max) then
		return SafeShortValue(cur)
	end
	if max and max > 0 then
		return string_format("%s/%s", SafeShortValue(cur), SafeShortValue(max))
	end
	return SafeShortValue(cur)
end

oUF.Tags.Methods["cpoints"] = function(unit)
	if not UnitExists(unit) then
		return
	end

	local cur = UnitPower(unit, POWER_COMBO)
	local max = UnitPowerMax(unit, POWER_COMBO)
	return FormatClassPowerTag(cur, max)
end
oUF.Tags.Events["cpoints"] = "UNIT_POWER_FREQUENT UNIT_MAXPOWER PLAYER_TARGET_CHANGED"

oUF.Tags.Methods["classpower"] = function(unit)
	local cur, max = GetUnitClassPowerValues(unit)
	return FormatClassPowerTag(cur, max)
end
oUF.Tags.Events["classpower"] = "UNIT_POWER_FREQUENT UNIT_MAXPOWER UNIT_AURA PLAYER_TARGET_CHANGED PLAYER_SPECIALIZATION_CHANGED"

-- REASON: LFD/LFR Role icon.
oUF.Tags.Methods["lfdrole"] = function(unit)
	if not IsInGroup() then
		return
	end

	local inParty = UnitInParty(unit)
	local inRaid = UnitInRaid(unit)
	if not ((NotSecret(inParty) and inParty) or (NotSecret(inRaid) and inRaid)) then
		return
	end

	local role = UnitGroupRolesAssigned(unit)
	if role and role ~= "NONE" and role ~= "DAMAGER" then
		return ROLE_ATLAS[role]
	end
end
oUF.Tags.Events["lfdrole"] = "PLAYER_ROLES_ASSIGNED GROUP_ROSTER_UPDATE"
