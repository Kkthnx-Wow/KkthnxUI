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

oUF.Tags.Events["kkthnx:additionalpower"] = "UNIT_POWER UNIT_DISPLAYPOWER UNIT_MAXPOWER"
oUF.Tags.Methods["kkthnx:additionalpower"] = function(unit)
	local min, max = UnitPower(unit, SPELL_POWER_MANA), UnitPowerMax(unit, SPELL_POWER_MANA)
	if (min == max) then
		return K.UnitframeValue(min)
	else
		return K.UnitframeValue(min).."/"..K.UnitframeValue(max)
	end
end

oUF.Tags.Methods["kkthnx:pvptimer"] = function(unit)
	local pvpTime = (GetPVPTimer() or 0)/1000
	if (not IsPVPTimerRunning()) or (pvpTime < 1) or (pvpTime > 300) then --999?
		return ""
	end

	return K.FormatTime(math.floor(pvpTime))
end

oUF.Tags.Methods["kkthnx:level"] = "UNIT_LEVEL PLAYER_LEVEL_UP"
oUF.Tags.Methods["kkthnx:level"] = function(unit)
	local level = UnitLevel(unit)
	if (level <= 0 or UnitIsCorpse(unit)) and (unit == "player" or unit == "target" or unit == "focus") then
		return "|TInterface\\TargetingFrame\\UI-TargetingFrame-Skull:12:12:0:0|t" -- boss skull icon
	end

	local colorL = GetCreatureDifficultyColor(level)
	return format("|cff%02x%02x%02x%s|r", colorL.r * 255, colorL.g * 255, colorL.b * 255, level)
end

oUF.Tags.Events["kkthnx:name"] = "UNIT_NAME_UPDATE"
oUF.Tags.Methods["kkthnx:name"] = function(unit, realUnit)
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

oUF.Tags.Events["status:raid"] = "PLAYER_FLAGS_CHANGED UNIT_CONNECTION"
oUF.Tags.Methods["status:raid"] = function(unit)
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

oUF.Tags.Events["role:raid"] = "GROUP_ROSTER_UPDATE PLAYER_ROLES_ASSIGNED"
if (not oUF.Tags["role:raid"]) then
    oUF.Tags.Methods["role:raid"] = function(unit)
        local role = UnitGroupRolesAssigned(unit)
        if (role) then
            if (role == "TANK") then
                role = ">"
            elseif (role == "HEALER") then
                role = "+"
            elseif (role == "DAMAGER") then
                role = "-"
            elseif (role == "NONE") then
                role = ""
            end

            return role
        else
            return ""
        end
    end
end

oUF.Tags.Events["name:raid"] = "UNIT_NAME_UPDATE"
oUF.Tags.Methods["name:raid"] = function(unit)
    local name = UnitName(unit) or UNKNOWN

    return K.ShortenString(name, 5)
end
