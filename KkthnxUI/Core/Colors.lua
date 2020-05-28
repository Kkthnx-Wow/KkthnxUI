local K = unpack(select(2, ...))
local oUF = oUF or K.oUF

if (not oUF) then
	K.Print("Could not find a vaild instance of oUF. Stopping Colors.lua code!")
	return
end

oUF.colors.fallback = {1, 1, 0.8}

oUF.colors.castbar = {
	CastingColor = {0.26, 0.53, 1.0},
	ChannelingColor = {0.26, 0.53, 1.0},
	notInterruptibleColor = {0.78, 0.25, 0.25},
	CompleteColor = {0.1, 0.8, 0},
	FailColor = {1, 0.1, 0},
}

-- Aura Coloring
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

oUF.colors.selection = {
	[0] = {r = 254/255, g = 045/255, b = 045/255}, -- HOSTILE
	[1] = {r = 255/255, g = 129/255, b = 050/255}, -- UNFRIENDLY
	[2] = {r = 255/255, g = 217/255, b = 050/255}, -- NEUTRAL
	[3] = {r = 050/255, g = 180/255, b = 000/255}, -- FRIENDLY
	[5] = {r = 102/255, g = 136/255, b = 255/255}, -- PLAYER_EXTENDED
	[6] = {r = 102/255, g = 050/255, b = 255/255}, -- PARTY
	[7] = {r = 187/255, g = 050/255, b = 255/255}, -- PARTY_PVP
	[8] = {r = 050/255, g = 255/255, b = 108/255}, -- FRIEND
	[9] = {r = 153/255, g = 153/255, b = 153/255}, -- DEAD
	[13] = {r = 025/255, g = 147/255, b = 072/255}, -- BATTLEGROUND_FRIENDLY_PVP
}

--oUF.colors.runes = {
--	[1] = {0.69, 0.31, 0.31},
--	[2] = {0.41, 0.80, 1.00},
--	[3] = {173 / 255, 235 / 255, 66 / 255},
--}

oUF.colors.power = {
	["ALTPOWER"] = {0.00, 1.00, 1.00},
	["AMMOSLOT"] = {0.80, 0.60, 0.00},
	["ARCANE_CHARGES"] = {0.41, 0.8, 0.94},
	["CHI"] = {0.71, 1.00, 0.92},
	-- ["COMBO_POINTS"] = {0.69, 0.31, 0.31},
	["ENERGY"] = {0.65, 0.63, 0.35},
	["FOCUS"] = {0.71, 0.43, 0.27},
	["FUEL"] = {0.00, 0.55, 0.50},
	["FURY"] = {0.78, 0.26, 0.99},
	["HOLY_POWER"] = {0.95, 0.90, 0.60},
	["INSANITY"] = {0.40, 0.00, 0.80},
	["LUNAR_POWER"] = {0.93, 0.51, 0.93},
	["MAELSTROM"] = {0.00, 0.50, 1.00},
	["MANA"] = {0.31, 0.45, 0.63},
	["PAIN"] = {1.00, 0.61, 0.00},
	["POWER_TYPE_PYRITE"] = {0.60, 0.09, 0.17},
	["POWER_TYPE_STEAM"] = {0.55, 0.57, 0.61},
	["RAGE"] = {0.78, 0.25, 0.25},
	["RUNES"] = {0.55, 0.57, 0.61},
	["RUNIC_POWER"] = {0, 0.82, 1},
	["SOUL_SHARDS"] = {0.50, 0.32, 0.55},
	["COMBO_POINTS"] = {
		[1] = {0.69, 0.31, 0.31},
		[2] = {0.65, 0.42, 0.31},
		[3] = {0.65, 0.63, 0.35},
		[4] = {0.50, 0.63, 0.35},
		[5] = {0.33, 0.63, 0.33},
		[6] = {0.03, 0.63, 0.33},
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
	[1] = oUF.colors.class[K.Class], -- Totem 1
	[2] = oUF.colors.class[K.Class], -- Totem 2
	[3] = oUF.colors.class[K.Class], -- Totem 3
	[4] = oUF.colors.class[K.Class], -- Totem 4
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