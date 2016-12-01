local K, C, L = select(2, ...):unpack()
if C.Nameplates.Enable ~= true then return end

local _, ns = ...
local oUF = ns.oUF

-- Nameplate Tags

oUF.Tags.Methods["NameplateShortCurHP"] = function(unit)
	local hp = UnitHealth(unit)
	if hp == 0 then
		return 0
	else
		return K.ShortValue(hp)
	end
end
oUF.Tags.Events["NameplateShortCurHP"] = "UNIT_HEALTH"

oUF.Tags.Methods["NameplateGetNameColor"] = function(unit)
	local reaction = UnitReaction(unit, "player")
	if UnitIsPlayer(unit) then
		return _TAGS["raidcolor"](unit)
	elseif reaction then
		local c = K.Colors.reaction[reaction]
		return string.format("|cff%02x%02x%02x", c[1] * 255, c[2] * 255, c[3] * 255)
	else
		r, g, b = 0.33, 0.59, 0.33
		return string.format("|cff%02x%02x%02x", r * 255, g * 255, b * 255)
	end
end
oUF.Tags.Events["NameplateGetNameColor"] = "UNIT_POWER UNIT_FLAGS"

oUF.Tags.Methods["NameplateNameLongAbbrev"] = function(unit)
	local name = UnitName(unit)
	local newname = (string.len(name) > 18) and string.gsub(name, "%s?(.[\128-\191]*)%S+%s", "%1. ") or name
	return K.Abbreviate(newname, 18, false)
end
oUF.Tags.Events["NameplateNameLongAbbrev"] = "UNIT_NAME_UPDATE"

oUF.Tags.Methods["NameplateDiffColor"] = function(unit)
	local r, g, b
	local level = UnitLevel(unit)
	if level < 1 then
		r, g, b = 0.69, 0.31, 0.31
	else
		local DiffColor = UnitLevel(unit) - UnitLevel("player")
		if DiffColor >= 5 then
			r, g, b = 0.69, 0.31, 0.31
		elseif DiffColor >= 3 then
			r, g, b = 0.71, 0.43, 0.27
		elseif DiffColor >= -2 then
			r, g, b = 0.84, 0.75, 0.65
		elseif -DiffColor <= GetQuestGreenRange() then
			r, g, b = 0.33, 0.59, 0.33
		else
			r, g, b = 0.55, 0.57, 0.61
		end
	end
	return string.format("|cff%02x%02x%02x", r * 255, g * 255, b * 255)
end
oUF.Tags.Events["NameplateDiffColor"] = "UNIT_LEVEL"

oUF.Tags.Methods["NameplateLevel"] = function(unit)
	local level = UnitLevel(unit)
	if UnitIsWildBattlePet(unit) or UnitIsBattlePetCompanion(unit) then
		level = UnitBattlePetLevel(unit)
	end

	if level == K.Level and c == "normal" then return end
	if level > 0 then
		return level
	else
		return "??"
	end
end
oUF.Tags.Events["NameplateLevel"] = "UNIT_LEVEL PLAYER_LEVEL_UP"