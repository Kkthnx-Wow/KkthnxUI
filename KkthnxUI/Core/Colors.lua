local K, C, _ = select(2, ...):unpack()

local _G = _G

BETTER_DISCONNECTED_COLORS = {
	0.1, 0.1, 0.1
}

BETTER_REACTION_COLORS = {
	[1] = {0.87, 0.37, 0.37}, -- HATED
	[2] = {0.87, 0.37, 0.37}, -- HOSTILE
	[3] = {0.87, 0.37, 0.37}, -- UNFRIENDLY
	[4] = {0.85, 0.77, 0.36}, -- NEUTRAL
	[5] = {0.29, 0.67, 0.30}, -- FRIENDLY
	[6] = {0.29, 0.67, 0.30}, -- HONORED
	[7] = {0.29, 0.67, 0.30}, -- REVERED
	[8] = {0.29, 0.67, 0.30}, -- EXALTED
}

-- CLASS COLORS
BETTER_RAID_CLASS_COLORS = {
	["DEATHKNIGHT"] = {0.77, 0.12, 0.24},
	["DRUID"]       = {1.00, 0.49, 0.03},
	["HUNTER"]      = {0.67, 0.84, 0.45},
	["MAGE"]        = {0.41, 0.80, 1.00},
	["PALADIN"]     = {0.96, 0.55, 0.73},
	["PRIEST"]      = {0.83, 0.83, 0.83},
	["ROGUE"]       = {1.00, 0.95, 0.32},
	["SHAMAN"]      = {0.16, 0.31, 0.61},
	["WARLOCK"]     = {0.58, 0.51, 0.79},
	["WARRIOR"]     = {0.78, 0.61, 0.43},
	["MONK"]        = {0.00, 1.00, 0.59},
	["DEMONHUNTER"] = {0.64, 0.19, 0.79},
}

BETTER_POWERBAR_COLORS = {
	["MANA"]              = {0.31, 0.45, 0.63},
	["INSANITY"]          = {0.40, 0.00, 0.80},
	["MAELSTROM"]         = {0.00, 0.50, 1.00},
	["LUNAR_POWER"]       = {0.93, 0.51, 0.93},
	["HOLY_POWER"]        = {0.95, 0.90, 0.60},
	["RAGE"]              = {0.69, 0.31, 0.31},
	["FOCUS"]             = {0.71, 0.43, 0.27},
	["ENERGY"]            = {0.65, 0.63, 0.35},
	["CHI"]               = {0.71, 1.00, 0.92},
	["RUNES"]             = {0.55, 0.57, 0.61},
	["SOUL_SHARDS"]       = {0.50, 0.32, 0.55},
	["FURY"]              = {0.78, 0.26, 0.99},
	["PAIN"]              = {1.00, 0.61, 0.00},
	["RUNIC_POWER"]       = {0.00, 0.82, 1.00},
	["AMMOSLOT"]          = {0.80, 0.60, 0.00},
	["FUEL"]              = {0.00, 0.55, 0.50},
	["POWER_TYPE_STEAM"]  = {0.55, 0.57, 0.61},
	["POWER_TYPE_PYRITE"] = {0.60, 0.09, 0.17},
	["ALTPOWER"]          = {0.00, 1.00, 1.00},
}

-- CUSTOM POWER COLORS
if C.Unitframe.BetterPowerColors == true then
	_G.PowerBarColor["MANA"] = {r = 0.31, g = 0.45, b = 0.63}
	_G.PowerBarColor["RAGE"] = {r = 0.69, g = 0.31, b = 0.31}
	_G.PowerBarColor["FOCUS"] = {r = 0.71, g = 0.43, b = 0.27}
	_G.PowerBarColor["ENERGY"] = {r = 0.65, g = 0.63, b = 0.35}
	_G.PowerBarColor["RUNIC_POWER"] = {r = 0.00, g = 0.82, b = 1.00}
	_G.PowerBarColor["PAIN"] = {r = 1.00, g = 0.61, b = 0.00}
	_G.PowerBarColor["FURY"] = {r = 0.78, g = 0.26, b = 0.99}
	_G.PowerBarColor["LUNAR_POWER"] = {r = 0.93, g = 0.51, b = 0.93}
	_G.PowerBarColor["INSANITY"] = {r = 0.40, g = 0.00, b = 0.80}
	_G.PowerBarColor["MAELSTROM"] = {r = 0.00, g = 0.50, b = 1.00}
end