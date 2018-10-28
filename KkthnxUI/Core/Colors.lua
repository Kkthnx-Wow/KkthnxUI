local K = unpack(select(2, ...))

local oUF = oUF or K.oUF

if (not oUF) then
	K.Print("Could not find a vaild instance of oUF. Stopping Colors.lua code!")
	return
end

oUF.colors.status = {
	castColor = {1.0, 0.7, 0.0},
	castNoInterrupt = {0.7, 0.7, 0.7},
}

-- aura coloring
oUF.colors.debuff = {
	none = {204/255, 0/255, 0/255},
	Magic = {51/255, 153/255, 255/255},
	Curse = {204/255, 0/255, 255/255},
	Disease = {153/255, 102/255, 0/255},
	Poison = {0/255, 153/255, 0/255},
	[""] = {0/255, 0/255, 0/255},
}

oUF.colors.reaction = {
	[1] = {0.87, 0.37, 0.37}, -- Hated
	[2] = {0.87, 0.37, 0.37}, -- Hostile
	[3] = {0.87, 0.37, 0.37}, -- Unfriendly
	[4] = {0.85, 0.77, 0.36}, -- Neutral
	[5] = {0.29, 0.67, 0.30}, -- Friendly
	[6] = {0.29, 0.67, 0.30}, -- Honored
	[7] = {0.29, 0.67, 0.30}, -- Revered
	[8] = {0.29, 0.67, 0.30}, -- Exalted
}

oUF.colors.factioncolors = {
	["1"] = {r = 0.87, g = 0.37, b = 0.37}, -- Hated
	["2"] = {r = 0.87, g = 0.37, b = 0.37}, -- Hostile
	["3"] = {r = 0.87, g = 0.37, b = 0.37}, -- Unfriendly
	["4"] = {r = 0.85, g = 0.77, b = 0.36}, -- Neutral
	["5"] = {r = 0.29, g = 0.67, b = 0.30}, -- Friendly
	["6"] = {r = 0.29, g = 0.67, b = 0.30}, -- Honored
	["7"] = {r = 0.29, g = 0.67, b = 0.30}, -- Revered
	["8"] = {r = 0.29, g = 0.67, b = 0.30}, -- Exalted
}

oUF.colors.power = {
	["ALTPOWER"] = {0.00, 1.00, 1.00},
	["AMMOSLOT"] = {204/255, 153/255, 0/255},
	["ARCANE_CHARGES"] = {121/255, 152/255, 192/255},
	["BURNING_EMBERS"] = {151/255, 45/255, 24/255},
	["CHI"] = {0.71, 1.00, 0.92},
	["DEMONIC_FURY"] = {105/255, 53/255, 142/255},
	["ENERGY"] = {0.65, 0.63, 0.35},
	["FOCUS"] = {0.71, 0.43, 0.27},
	["FUEL"] = {0/255, 140/255, 127/255},
	["FURY"] = {201/255, 66/255, 253/255},
	["HAPPINESS"] = {0/255, 255/255, 255/255},
	["HOLY_POWER"] = {0.95, 0.90, 0.60},
	["INSANITY"] = {0.40, 0.00, 0.80},
	["LUNAR_POWER"] = {0.93, 0.51, 0.93},
	["MAELSTROM"] = {0.00, 0.50, 1.00},
	["MANA"] = {0.31, 0.45, 0.63},
	["PAIN"] = {1.00, 0.61, 0.00},
	["POWER_TYPE_BLOOD_POWER"] = {188/255, 0/255, 255/255},
	["POWER_TYPE_FEL_ENERGY"] = {224/255, 250/255, 0/255},
	["POWER_TYPE_HEAT"] = {255/255, 125/255, 0/255},
	["POWER_TYPE_OOZE"] = {193/255, 255/255, 0/255},
	["POWER_TYPE_PYRITE"] = {0/255, 202/255, 255/255},
	["POWER_TYPE_STEAM"] = {242/255, 242/255, 242/255},
	["RAGE"] = {0.69, 0.31, 0.31},
	["RUNES"] = {0.55, 0.57, 0.61},
	["RUNIC_POWER"] = {0.00, 0.82, 1.00},
	["SOUL_SHARDS"] = {0.50, 0.32, 0.55},
	["COMBO_POINTS"] = {
		{0.69, 0.31, 0.31},
		{0.65, 0.42, 0.31},
		{0.65, 0.63, 0.35},
		{0.50, 0.63, 0.35},
		{0.33, 0.63, 0.33},
		{0.03, 0.63, 0.33},
	},
	["STAGGER"] = {
		{132/255, 255/255, 132/255},
		{255/255, 250/255, 183/255},
		{255/255, 107/255, 107/255}
	},
	["UNUSED"] = {195/255, 202/255, 217/255},
}

oUF.colors.class = {
	["DEATHKNIGHT"] = {0.77, 0.12, 0.24},
	["DEMONHUNTER"] = {0.64, 0.19, 0.79},
	["DRUID"] = {1.00, 0.49, 0.03},
	["HUNTER"] = {0.67, 0.84, 0.45},
	["MAGE"] = {0.41, 0.80, 1.00},
	["MONK"] = {0.00, 1.00, 0.59},
	["PALADIN"] = {0.96, 0.55, 0.73},
	["PRIEST"] = {0.86, 0.92, 0.98},
	["ROGUE"] = {1.00, 0.95, 0.32},
	["SHAMAN"] = {0.16, 0.31, 0.61},
	["WARLOCK"] = {0.58, 0.51, 0.79},
	["WARRIOR"] = {0.78, 0.61, 0.43},
}

oUF.colors.totems = {
	{0.13, 0.55, 0.71}, -- Blue
	{0.26, 0.71, 0.13}, -- Green
	{0.58, 0.13, 0.71}, -- Violet
	{0.71, 0.29, 0.13}, -- Red
	{0.71, 0.58, 0.13}, -- Yellow
}

oUF.colors.specpowertypes = {
	["WARRIOR"] = {
		[71] = oUF.colors.power["RAGE"],
		[72] = oUF.colors.power["RAGE"],
		[73] = oUF.colors.power["RAGE"],
	},

	["PALADIN"] = {
		[65] = oUF.colors.power["MANA"],
		[66] = oUF.colors.power["MANA"],
		[70] = oUF.colors.power["HOLY_POWER"],
	},

	["HUNTER"] = {
		[253] = oUF.colors.power["FOCUS"],
		[254] = oUF.colors.power["FOCUS"],
		[255] = oUF.colors.power["FOCUS"],
	},

	["ROGUE"] = {
		[259] = oUF.colors.power["ENERGY"],
		[260] = oUF.colors.power["ENERGY"],
		[261] = oUF.colors.power["ENERGY"],
	},

	["PRIEST"] = {
		[256] = oUF.colors.power["MANA"],
		[257] = oUF.colors.power["MANA"],
		[258] = oUF.colors.power["INSANITY"],
	},

	["DEATHKNIGHT"] = {
		[250] = oUF.colors.power["RUNIC_POWER"],
		[251] = oUF.colors.power["RUNIC_POWER"],
		[252] = oUF.colors.power["RUNIC_POWER"],
	},

	["SHAMAN"] = {
		[262] = oUF.colors.power["MAELSTROM"],
		[263] = oUF.colors.power["MAELSTROM"],
		[264] = oUF.colors.power["MANA"],
	},

	["MAGE"] = {
		[62] = oUF.colors.power["MANA"],
		[63] = oUF.colors.power["MANA"],
		[64] = oUF.colors.power["MANA"],
	},

	["WARLOCK"] = {
		[265] = oUF.colors.power["MANA"],
		[266] = oUF.colors.power["MANA"],
		[267] = oUF.colors.power["MANA"],
	},

	["MONK"] = {
		[268] = oUF.colors.power["ENERGY"],
		[270] = oUF.colors.power["MANA"],
		[269] = oUF.colors.power["ENERGY"],
	},

	["DRUID"] = {
		[102] = oUF.colors.power["LUNAR_POWER"],
		[103] = oUF.colors.power["ENERGY"],
		[104] = oUF.colors.power["RAGE"],
		[105] = oUF.colors.power["MANA"],
	},

	["DEMONHUNTER"] = {
		[577] = oUF.colors.power["FURY"],
		[581] = oUF.colors.power["PAIN"],
	},
}

K["Colors"] = oUF.colors