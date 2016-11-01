local K, C, L = select(2, ...):unpack()
if C.Unitframe.Enable ~= true and C.Raidframe.Enable ~= true then return end

local _, ns = ...
local oUF = ns.oUF

local config = ns.config

local function Abbrev(name)
	local newname = (string.len(name) > 18) and string.gsub(name, "%s?(.[\128-\191]*)%S+%s", "%1. ") or name
	return K.ShortenString(newname, 18, false)
end

local timer = {}

oUF.Tags.Events["KkthnxUI:DruidMana"] = "UNIT_POWER UNIT_DISPLAYPOWER UNIT_MAXPOWER"
oUF.Tags.Methods["KkthnxUI:DruidMana"] = function(unit)
	local min, max = UnitPower(unit, SPELL_POWER_MANA), UnitPowerMax(unit, SPELL_POWER_MANA)
	if (min == max) then
		return K.UnitframeValue(min)
	else
		return K.UnitframeValue(min).."/"..K.UnitframeValue(max)
	end
end

oUF.Tags.Methods["KkthnxUI:PvPTimer"] = function(unit)
	local pvpTime = (GetPVPTimer() or 0)/1000
	if (not IsPVPTimerRunning()) or (pvpTime < 1) or (pvpTime > 300) then --999?
		return ""
	end

	return K.FormatTime(math.floor(pvpTime))
end

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

oUF.Tags.Events["KkthnxUI:Name"] = "UNIT_NAME_UPDATE"
oUF.Tags.Methods["KkthnxUI:Name"] = function(unit, realUnit)
	local color
	local unitName, unitRealm = UnitName(realUnit or unit)
	local _, class = UnitClass(realUnit or unit)

	if not unitName then
		local id = unit:match("arena(%d)$")
		if(id) then
			unitName = "Arena "..id
		end
	elseif (unitRealm) and (unitRealm ~= "") then
		unitName = unitName.." (*)"
	end

	if not color then
		color = C.Unitframe.TextNameColor
	end

	return format("|cff%02x%02x%02x%s|r", color[1]*255, color[2]*255, color[3]*255, (Abbrev(unitName)))
end

oUF.Tags.Events["KkthnxUI:NameShort"] = "UNIT_NAME_UPDATE PARTY_LEADER_CHANGED GROUP_ROSTER_UPDATE"
oUF.Tags.Methods["KkthnxUI:NameShort"] = function(unit)
	local Name = UnitName(unit) or UNKNOWN
	local IsLeader = UnitIsGroupLeader(unit)
	local IsAssistant = UnitIsGroupAssistant(unit) or UnitIsRaidOfficer(unit)
	local Assist, Lead = IsAssistant and "[A] " or "", IsLeader and "[L] " or ""
	return K.ShortenString(Lead..Assist..Name, 10, false)
end

oUF.Tags.Events["KkthnxUI:NameMedium"] = "UNIT_NAME_UPDATE"
oUF.Tags.Methods["KkthnxUI:NameMedium"] = function(unit)
	local Name = UnitName(unit) or UNKNOWN
	return K.ShortenString(Name, 15, true)
end
oUF.Tags.Events["KkthnxUI:NameLong"] = "UNIT_NAME_UPDATE"
oUF.Tags.Methods["KkthnxUI:NameLong"] = function(unit)
	local Name = UnitName(unit) or UNKNOWN
	return K.ShortenString(Name, 20, true)
end

oUF.Tags.Events["KkthnxUI:RaidStatus"] = "PLAYER_FLAGS_CHANGED UNIT_CONNECTION"
oUF.Tags.Methods["KkthnxUI:RaidStatus"] = function(unit)
    local name = UnitName(unit) or UNKNOWN

    if (UnitIsAFK(unit) or not UnitIsConnected(unit)) then
        if (not timer[name]) then
            timer[name] = GetTime()
        end

        local time = (GetTime() - timer[name])

        return K.FormatTime(time)
    elseif timer[name] then
        timer[name] = nil
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
