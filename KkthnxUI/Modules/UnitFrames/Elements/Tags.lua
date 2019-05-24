local K = unpack(select(2, ...))
local oUF = oUF or K.oUF

if not oUF then
	K.Print("Could not find a vaild instance of oUF. Tags.lua code!")
	return
end

local _G = _G
local math_floor = math.floor
local string_find = string.find
local string_format = string.format
local string_lower = string.lower
local string_match = string.match
local string_sub = string.sub
local string_gmatch = string.gmatch

local C_PetJournal_GetPetTeamAverageLevel = C_PetJournal.GetPetTeamAverageLevel
local DEAD = _G.DEAD
local GHOST = _G.GetLocale() == "deDE" and "Geist" or _G.GetSpellInfo(8326)
local GetComboPoints = _G.GetComboPoints
local GetQuestGreenRange = _G.GetQuestGreenRange
local GetRelativeDifficultyColor = _G.GetRelativeDifficultyColor
local GetSpecialization = _G.GetSpecialization
local GetThreatStatusColor = _G.GetThreatStatusColor
local HEALER = _G.HEALER
local IsInGroup = _G.IsInGroup
local PLAYER_OFFLINE = _G.PLAYER_OFFLINE
local QuestDifficultyColors = _G.QuestDifficultyColors
local SPEC_MAGE_ARCANE = _G.SPEC_MAGE_ARCANE
local SPEC_MONK_WINDWALKER = _G.SPEC_MONK_WINDWALKER
local SPEC_PALADIN_RETRIBUTION = _G.SPEC_PALADIN_RETRIBUTION
local TANK = _G.TANK
local UNITNAME_SUMMON_TITLE17 = _G.UNITNAME_SUMMON_TITLE17
local UNKNOWN = _G.UNKNOWN
local UnitBattlePetLevel = _G.UnitBattlePetLevel
local UnitClass = _G.UnitClass
local UnitClassification = _G.UnitClassification
local UnitDetailedThreatSituation = _G.UnitDetailedThreatSituation
local UnitEffectiveLevel = _G.UnitEffectiveLevel
local UnitExists = _G.UnitExists
local UnitGroupRolesAssigned = _G.UnitGroupRolesAssigned
local UnitHasVehicleUI = _G.UnitHasVehicleUI
local UnitHealth = _G.UnitHealth
local UnitHealthMax = _G.UnitHealthMax
local UnitIsAFK = _G.UnitIsAFK
local UnitIsBattlePetCompanion = _G.UnitIsBattlePetCompanion
local UnitIsConnected = _G.UnitIsConnected
local UnitIsDead = _G.UnitIsDead
local UnitIsFriend = _G.UnitIsFriend
local UnitIsGhost = _G.UnitIsGhost
local UnitIsGroupAssistant = _G.UnitIsGroupAssistant
local UnitIsGroupLeader = _G.UnitIsGroupLeader
local UnitIsPlayer = _G.UnitIsPlayer
local UnitIsRaidOfficer = _G.UnitIsRaidOfficer
local UnitIsUnit = _G.UnitIsUnit
local UnitIsWildBattlePet = _G.UnitIsWildBattlePet
local UnitLevel = _G.UnitLevel
local UnitPower = _G.UnitPower
local UnitPowerMax = _G.UnitPowerMax
local UnitPowerType = _G.UnitPowerType
local UnitReaction = _G.UnitReaction

local function UnitName(unit)
	local name, realm = _G.UnitName(unit)

	if (name == UNKNOWN and K.Class == "MONK") and UnitIsUnit(unit, "pet") then
		name = string_format(UNITNAME_SUMMON_TITLE17, _G.UnitName("player"))
	end

	if realm and realm ~= "" then
		return name, realm
	else
		return name
	end
end

local function UnitNameAbbrev(name)
	local letters, lastWord = "", string_match(name, ".+%s(.+)$")
	if lastWord then
		for word in string_gmatch(name, ".-%s") do
			local firstLetter = string_sub(gsub(word, "^[%s%p]*", ""), 1, 1)
			if firstLetter ~= string_lower(firstLetter) then
				letters = string_format("%s%s. ", letters, firstLetter)
			end
		end
		name = string_format("%s%s", letters, lastWord)
	end
	return name
end

-- KkthnxUI Unitframe Tags
oUF.Tags.Events["KkthnxUI:GetNameColor"] = "UNIT_NAME_UPDATE UNIT_FACTION"
oUF.Tags.Methods["KkthnxUI:GetNameColor"] = function(unit)
	local unitReaction = UnitReaction(unit, "player")
	local _, unitClass = UnitClass(unit)
	if (UnitIsPlayer(unit)) then
		local class = K.Colors.class[unitClass]
		if not class then
			return nil
		end
		return Hex(class[1], class[2], class[3])
	elseif (unitReaction) then
		local reaction = K.Colors.reaction[unitReaction]
		return Hex(reaction[1], reaction[2], reaction[3])
	else
		return Hex(255 / 255, 255 / 255, 255 / 255)
	end
end

oUF.Tags.Events["KkthnxUI:GroupNumber"] = "GROUP_ROSTER_UPDATE PLAYER_ROLES_ASSIGNED ROLE_CHANGED_INFORM PARTY_LEADER_CHANGED"
oUF.Tags.Methods["KkthnxUI:GroupNumber"] = function(unit)
if not UnitInRaid("player") then return end
	for i = 1, GetNumGroupMembers() do
		local name, _, subgroup = GetRaidRosterInfo(i)
			if (name == K.Name) then
				return "Group " .. subgroup
			end
	end
end

oUF.Tags.Events["KkthnxUI:AltPowerCurrent"] = "UNIT_POWER UNIT_MAXPOWER"
oUF.Tags.Methods["KkthnxUI:AltPowerCurrent"] = function(unit)
	local cur = UnitPower(unit, 0)
	local max = UnitPowerMax(unit, 0)

	if (UnitPowerType(unit) ~= 0 and cur ~= max) then
		return math_floor(cur / max * 100)
	end
end

oUF.Tags.Events["KkthnxUI:DifficultyColor"] = "UNIT_LEVEL PLAYER_LEVEL_UP UNIT_CONNECTION"
oUF.Tags.Methods["KkthnxUI:DifficultyColor"] = function(unit)
	local r, g, b
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

oUF.Tags.Events["KkthnxUI:ClassificationColor"] = "UNIT_CLASSIFICATION_CHANGED"
oUF.Tags.Methods["KkthnxUI:ClassificationColor"] = function(unit)
	local classification = UnitClassification(unit)
	if (classification == "rare" or classification == "elite") then
		return Hex(0.69, 0.31, 0.31) -- Red
	elseif (classification == "rareelite" or classification == "worldboss") then
		return Hex(0.69, 0.31, 0.31) -- Red
	end
end

oUF.Tags.Events["KkthnxUI:HealthCurrent"] = "UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH UNIT_CONNECTION PLAYER_FLAGS_CHANGED"
oUF.Tags.Methods["KkthnxUI:HealthCurrent"] = function(unit)
	local status =
	UnitIsDead(unit) and "|cffFFFFFF" .. DEAD .. "|r" or UnitIsGhost(unit) and "|cffFFFFFF" .. GHOST .. "|r" or
	not UnitIsConnected(unit) and "|cffFFFFFF" .. PLAYER_OFFLINE .. "|r"
	if (status) then
		return status
	else
		return K.GetFormattedText("CURRENT", UnitHealth(unit), UnitHealthMax(unit))
	end
end

oUF.Tags.Events["KkthnxUI:HealthPercent"] = "UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH UNIT_CONNECTION PLAYER_FLAGS_CHANGED"
oUF.Tags.Methods["KkthnxUI:HealthPercent"] = function(unit)
	local status =
	UnitIsDead(unit) and "|cffFFFFFF" .. DEAD .. "|r" or UnitIsGhost(unit) and "|cffFFFFFF" .. GHOST .. "|r" or
	not UnitIsConnected(unit) and "|cffFFFFFF" .. PLAYER_OFFLINE .. "|r"
	if (status) then
		return status
	else
		return K.GetFormattedText("PERCENT", UnitHealth(unit), UnitHealthMax(unit))
	end
end

oUF.Tags.Events["KkthnxUI:PercentCut"] = "UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH UNIT_CONNECTION PLAYER_FLAGS_CHANGED"
oUF.Tags.Methods["KkthnxUI:PercentCut"] = function(unit)	
	local m = UnitHealthMax(unit)
	local status =
		UnitIsDead(unit) and "|cffFFFFFF" .. DEAD .. "|r" or UnitIsGhost(unit) and "|cffFFFFFF" .. GHOST .. "|r" or
		not UnitIsConnected(unit) and "|cffFFFFFF" .. PLAYER_OFFLINE .. "|r"
	if (status) then
		return status
	elseif (m == 0) then
		return 0
	else
		return math.floor(UnitHealth(unit) / m * 100 + 0.5).."%"
	end
end

oUF.Tags.Events["KkthnxUI:HealthCurrent-Percent"] = "UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH UNIT_CONNECTION PLAYER_FLAGS_CHANGED"
oUF.Tags.Methods["KkthnxUI:HealthCurrent-Percent"] = function(unit)
	local status =
	UnitIsDead(unit) and "|cffFFFFFF" .. DEAD .. "|r" or UnitIsGhost(unit) and "|cffFFFFFF" .. GHOST .. "|r" or
	not UnitIsConnected(unit) and "|cffFFFFFF" .. PLAYER_OFFLINE .. "|r"
	if (status) then
		return status
	else
		return K.GetFormattedText("CURRENT_PERCENT", UnitHealth(unit), UnitHealthMax(unit))
	end
end

oUF.Tags.Events["KkthnxUI:HealthDeficit"] = "UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH UNIT_CONNECTION PLAYER_FLAGS_CHANGED"
oUF.Tags.Methods["KkthnxUI:HealthDeficit"] = function(unit)
	local status =
	UnitIsDead(unit) and "|cffFFFFFF" .. DEAD .. "|r" or UnitIsGhost(unit) and "|cffFFFFFF" .. GHOST .. "|r" or
	not UnitIsConnected(unit) and "|cffFFFFFF" .. PLAYER_OFFLINE .. "|r"
	if (status) then
		return status
	else
		return K.GetFormattedText("DEFICIT", UnitHealth(unit), UnitHealthMax(unit))
	end
end

oUF.Tags.Events["KkthnxUI:PowerCurrent"] = "UNIT_DISPLAYPOWER UNIT_POWER_FREQUENT UNIT_MAXPOWER"
oUF.Tags.Methods["KkthnxUI:PowerCurrent"] = function(unit)
	local pType = UnitPowerType(unit)
	local min = UnitPower(unit, pType)

	return min == 0 and nil or K.GetFormattedText("CURRENT", min, UnitPowerMax(unit, pType))
end

oUF.Tags.Events["KkthnxUI:Level"] = "UNIT_LEVEL PLAYER_LEVEL_UP UNIT_CONNECTION"
oUF.Tags.Methods["KkthnxUI:Level"] = function(unit)
	if (UnitClassification(unit) == "worldboss") then
		return
	end

	local level = UnitBattlePetLevel(unit)
	if (not level or level == 0) then
		level = UnitEffectiveLevel(unit)
	end

	if (level == UnitEffectiveLevel("player")) then
		return
	end

	if (level < 0) then
		return "??"
	end

	return level
end

oUF.Tags.Events["KkthnxUI:SmartLevel"] = "UNIT_LEVEL PLAYER_LEVEL_UP UNIT_CONNECTION"
oUF.Tags.Methods["KkthnxUI:SmartLevel"] = function(unit)
	if not UnitExists(unit) then
		return
	end

	local level = UnitLevel(unit)
	if (UnitIsWildBattlePet(unit) or UnitIsBattlePetCompanion(unit)) then
		return UnitBattlePetLevel(unit)
	elseif level == UnitLevel("player") then
		return nil
	elseif (level > 0) then
		return level
	else
		return "??"
	end
end

oUF.Tags.Events["KkthnxUI:NameAbbrev"] = "UNIT_NAME_UPDATE"
oUF.Tags.Methods["KkthnxUI:NameAbbrev"] = function(unit)
	local NameAbbrev = UnitName(unit) or UNKNOWN

	if NameAbbrev and string_find(NameAbbrev, "%s") then
		NameAbbrev = UnitNameAbbrev(NameAbbrev)
	end

	return NameAbbrev ~= nil and K.ShortenString(NameAbbrev, 20, true) or "" -- The value 20 controls how many characters are allowed in the name before it gets truncated. Change it to fit your needs.
end

oUF.Tags.Events["KkthnxUI:NameVeryShort"] = "UNIT_NAME_UPDATE"
oUF.Tags.Methods["KkthnxUI:NameVeryShort"] = function(unit)
	local NameVeryShort = UnitName(unit) or UNKNOWN
	return NameVeryShort ~= nil and K.ShortenString(NameVeryShort, 5, true) or ""
end

oUF.Tags.Events["KkthnxUI:NameShort"] = "UNIT_NAME_UPDATE"
oUF.Tags.Methods["KkthnxUI:NameShort"] = function(unit)
	local NameShort = UnitName(unit) or UNKNOWN
	return NameShort ~= nil and K.ShortenString(NameShort, 10, true) or ""
end

oUF.Tags.Events["KkthnxUI:NameMedium"] = "UNIT_NAME_UPDATE"
oUF.Tags.Methods["KkthnxUI:NameMedium"] = function(unit)
	local NameMedium = UnitName(unit) or UNKNOWN
	return NameMedium ~= nil and K.ShortenString(NameMedium, 15, true) or ""
end

oUF.Tags.Events["KkthnxUI:NameLong"] = "UNIT_NAME_UPDATE"
oUF.Tags.Methods["KkthnxUI:NameLong"] = function(unit)
	local NameLong = UnitName(unit) or UNKNOWN
	return NameLong ~= nil and K.ShortenString(NameLong, 20, true) or ""
end

oUF.Tags.Events["KkthnxUI:AFK"] = "PLAYER_FLAGS_CHANGED"
oUF.Tags.Methods["KkthnxUI:AFK"] = function(unit)
	local isAFK = UnitIsAFK(unit)
	if isAFK then
		return _G.CHAT_FLAG_AFK
	else
		return nil
	end
end

oUF.Tags.Events["KkthnxUI:ThreatPercent"] = "UNIT_THREAT_LIST_UPDATE GROUP_ROSTER_UPDATE"
oUF.Tags.Methods["KkthnxUI:ThreatPercent"] = function(unit)
	local _, _, percent = UnitDetailedThreatSituation("player", unit)
	if (percent and percent > 0) and (IsInGroup() or UnitExists("pet")) then
		return string_format("%.0f%%", percent)
	else
		return nil
	end
end

oUF.Tags.Events["KkthnxUI:ThreatColor"] = "UNIT_THREAT_LIST_UPDATE GROUP_ROSTER_UPDATE"
oUF.Tags.Methods["KkthnxUI:ThreatColor"] = function(unit)
	local _, status = UnitDetailedThreatSituation("player", unit)
	if (status) and (IsInGroup() or UnitExists("pet")) then
		return Hex(GetThreatStatusColor(status))
	else
		return nil
	end
end

oUF.Tags.Events["KkthnxUI:Leader"] = "UNIT_NAME_UPDATE PARTY_LEADER_CHANGED GROUP_ROSTER_UPDATE"
oUF.Tags.Methods["KkthnxUI:Leader"] = function(unit)
	local IsLeader = UnitIsGroupLeader(unit)
	local IsAssistant = UnitIsGroupAssistant(unit) or UnitIsRaidOfficer(unit)
	local Assist, Lead = IsAssistant and "|cffffd100[A]|r " or "", IsLeader and "|cffffd100[L]|r " or ""

	return (Lead .. Assist)
end

oUF.Tags.Events["KkthnxUI:Role"] = "GROUP_ROSTER_UPDATE PLAYER_ROLES_ASSIGNED ROLE_CHANGED_INFORM"
oUF.Tags.Methods["KkthnxUI:Role"] = function(unit)
	local role = UnitGroupRolesAssigned(unit)
	local roleString = ""
	local IsTank = TANK or UNKNOWN
	local IsHealer = HEALER or UNKNOWN
	local Tank, Healer = IsTank and "|cff0099CC[T]|r " or "", IsHealer and "|cff00FF00[H]|r " or ""

	if (role == "TANK") then
		roleString = Tank
	elseif (role == "HEALER") then
		roleString = Healer
	end

	return roleString
end

-- Raid Tags
oUF.Tags.Events["KkthnxUI:RaidStatus"] = "UNIT_MAXHEALTH UNIT_HEALTH_FREQUENT UNIT_CONNECTION"
oUF.Tags.Methods["KkthnxUI:RaidStatus"] = function(unit)
	local Offline = not UnitIsConnected(unit) and "offline"
	if Offline then
		return Offline
	end

	local Dead = (UnitIsDead(unit) and "dead") or (UnitIsGhost(unit) and "ghost")
	if Dead then
		return Dead
	end

	local MaxHealth = UnitHealthMax(unit)
	local CurrentHealth = UnitHealth(unit)

	if CurrentHealth == MaxHealth or CurrentHealth == 0 or MaxHealth == 0 then
		return
	elseif UnitIsFriend("player", unit) then
		return "-" .. K.ShortValue(MaxHealth - CurrentHealth)
	else
		return string_format("%.1f", CurrentHealth / MaxHealth * 100) .. "%"
	end
end

oUF.Tags.Events["KkthnxUI:ClassPower"] = "UNIT_POWER_FREQUENT PLAYER_TARGET_CHANGED UNIT_POWER SPELLS_CHANGED RUNE_POWER_UPDATE"
oUF.Tags.Methods["KkthnxUI:ClassPower"] = function()
	local PlayerClass = K.Class
	local num, max, color

	if (PlayerClass == "MONK") then
		if (GetSpecialization() == SPEC_MONK_WINDWALKER or 3) then
			num = UnitPower("player", Enum.PowerType.Chi)
			max = UnitPowerMax("player", Enum.PowerType.Chi)
			color = "00CC99"

			if (num == max) then
				color = "008FF7"
			end
		end
	elseif (PlayerClass == "WARLOCK") then
		num = UnitPower("player", Enum.PowerType.SoulShards)
		max = UnitPowerMax("player", Enum.PowerType.SoulShards)
		color = "A15CFF"

		if (num == max) then
			color = "FF1A30"
		end
	elseif (PlayerClass == "PALADIN") then
		if (GetSpecialization() == SPEC_PALADIN_RETRIBUTION or 3) then
			num = UnitPower("player", Enum.PowerType.HolyPower)
			max = UnitPowerMax("player", Enum.PowerType.HolyPower)
			color = "FFFF7D"

			if (num == max) then
				color = "FF1A30"
			end
		end
	elseif (PlayerClass == "MAGE") then
		if (GetSpecialization() == SPEC_MAGE_ARCANE or 1) then
			num = UnitPower("player", Enum.PowerType.ArcaneCharges)
			max = UnitPowerMax("player", Enum.PowerType.ArcaneCharges)
			color = "A950CA"

			if (num == max) then
				color = "EE3053"
			end
		end
	else -- Combo Points
		if (UnitHasVehicleUI("player")) then
			num = GetComboPoints("vehicle", "target")
		else
			num = GetComboPoints("player", "target")
			max = UnitPowerMax("player", Enum.PowerType.ComboPoints)
			color = "FFFF66"

			if (num == max) then
				color = "FF1A30"
			end
		end
	end

	if (num and num > 0) then
		return string_format("|cff%s%d|r", color, num)
	end
end