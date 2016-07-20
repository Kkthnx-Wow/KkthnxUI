local K, C, _ = select(2, ...):unpack()

local _G = _G
local PowerBarColor = PowerBarColor
local RAID_CLASS_COLORS = RAID_CLASS_COLORS

-- Custom Faction Colors
BETTER_FACTION_BAR_COLORS = {
	[1] = {r = 217/255, g = 69/255, b = 69/255},
	[2] = {r = 217/255, g = 69/255, b = 69/255},
	[3] = {r = 217/255, g = 69/255, b = 69/255},
	[4] = {r = 217/255, g = 196/255, b = 92/255},
	[5] = {r = 84/255, g = 150/255, b = 84/255},
	[6] = {r = 84/255, g = 150/255, b = 84/255},
	[7] = {r = 84/255, g = 150/255, b = 84/255},
	[8] = {r = 84/255, g = 150/255, b = 84/255},
}

-- Class Colors
RAID_CLASS_COLORS = {
	["HUNTER"] = {r = 255/255, g = 255/255, b = 255/255},
	["WARLOCK"] = {r = 148/255, g = 130/255, b = 201/255},
	["PRIEST"] = {r = 220/255, g = 235/255, b = 250/255},
	["PALADIN"] = {r = 245/255, g = 140/255, b = 186/255},
	["MAGE"] = {r = 105/255, g = 204/255, b = 240/255},
	["ROGUE"] = {r = 255/255, g = 245/255, b = 105/255},
	["DRUID"] = {r = 255/255, g = 125/255, b = 10/255},
	["SHAMAN"] = {r = 0/255, g = 112/255, b = 222/255},
	["WARRIOR"] = {r = 199/255, g = 156/255, b = 110/255},
	["DEATHKNIGHT"] = {r = 196/255, g = 30/255 , b = 59/255},
}

-- Custom Power Colors
if C.Unitframe.BetterPowerColors == true then
	_G.PowerBarColor["RAGE"] = {r = 199/255, g = 64/255, b = 64/255}
	_G.PowerBarColor["FOCUS"] = {r = 181/255, g = 110/255, b = 69/255}
	_G.PowerBarColor["MANA"] = {r = 79/255, g = 115/255, b = 161/255}
	_G.PowerBarColor["ENERGY"] = {r = 166/255, g = 161/255, b = 89/255}
	_G.PowerBarColor["RUNES"] = {r = 128/255, g = 128/255, b = 128/255}
	_G.PowerBarColor["RUNIC_POWER"] = {r = 0/255, g = 209/255, b = 255/255}
end