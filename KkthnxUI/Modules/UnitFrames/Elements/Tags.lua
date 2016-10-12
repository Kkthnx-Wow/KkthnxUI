local K, C, L = select(2, ...):unpack()
if C.Unitframe.Enable ~= true then return end

local _, ns = ...
local oUF = ns.oUF

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

	local colorL = GetQuestDifficultyColor(level)
	return format("|cff%02x%02x%02x%s|r", colorL.r * 255, colorL.g * 255, colorL.b * 255, level)
end

oUF.Tags.Events["kkthnx:name"] = "UNIT_NAME_UPDATE"
oUF.Tags.Methods["kkthnx:name"] = function(unit, realUnit)
	local color
	local unitName, unitRealm = UnitName(realUnit or unit)
	local _, class = UnitClass(realUnit or unit)

	if not unitName then
		local id = unit:match"arena(%d)$"
		if(id) then
			unitName = "Arena "..id
		end
	elseif (unitRealm) and (unitRealm ~= "") then
		unitName = unitName.." (*)"
	end

	if not color then
		color = C.Unitframe.TextNameColor
	end

	return format("|cff%02x%02x%02x%s|r", color[1]*255, color[2]*255, color[3]*255, unitName)
end