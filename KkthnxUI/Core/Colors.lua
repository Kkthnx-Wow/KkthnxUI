local K = KkthnxUI[1]
local oUF = K.oUF

if not oUF then
	K.Print("Could not find a vaild instance of oUF. Stopping Colors.lua code!")
	return
end

oUF.colors.fallback = { 1, 1, 0.8 }

oUF.colors.castbar = {
	CastingColor = { 1.0, 0.7, 0.0 },
	ChannelingColor = { 0.0, 1.0, 0.0 },
	notInterruptibleColor = { 0.7, 0.7, 0.7 },
	CompleteColor = { 0.0, 1.0, 0.0 },
	FailColor = { 1.0, 0.0, 0.0 },
}

-- Aura Coloring
oUF.colors.debuff = {
	none = { 0.8, 0, 0 },
	Magic = { 0.2, 0.6, 1 },
	Curse = { 0.8, 0, 1 },
	Disease = { 0.6, 0.4, 0 },
	Poison = { 0, 0.6, 0 },
	[""] = { 1, 1, 1 },
}

oUF.colors.mirror = {
	EXHAUSTION = { 1.0, 0.90, 0.0 },
	BREATH = { 0.0, 0.50, 1.0 },
	DEATH = { 1.0, 0.70, 0.0 },
	FEIGNDEATH = { 1.0, 0.70, 0.0 },
}

oUF.colors.reaction = {
	[1] = { 0.87, 0.37, 0.37 }, -- Hated
	[2] = { 0.87, 0.37, 0.37 }, -- Hostile
	[3] = { 0.87, 0.37, 0.37 }, -- Unfriendly
	[4] = { 0.85, 0.77, 0.36 }, -- Neutral
	[5] = { 0.29, 0.67, 0.30 }, -- Friendly
	[6] = { 0.29, 0.67, 0.30 }, -- Honored
	[7] = { 0.29, 0.67, 0.30 }, -- Revered
	[8] = { 0.29, 0.67, 0.30 }, -- Exalted
}

oUF.colors.selection = {
	[0] = { 0.87, 0.37, 0.37 }, -- HOSTILE
	[1] = { 0.87, 0.37, 0.37 }, -- UNFRIENDLY
	[2] = { 0.85, 0.77, 0.36 }, -- NEUTRAL
	[3] = { 0.29, 0.67, 0.30 }, -- FRIENDLY
	[4] = { 0, 0, 1 }, -- PLAYER_SIMPLE
	[5] = { 0, 0, 1 }, -- PLAYER_EXTENDED
	[6] = { 0, 0, 1 }, -- PARTY
	[7] = { 0, 0, 1 }, -- PARTY_PVP
	[8] = { 0, 0, 1 }, -- FRIEND
	[9] = { 0.5, 0.5, 0.5 }, -- DEAD
	[12] = { 1, 1, 0.55 }, -- SELF, buggy
	[13] = { 0, 0.6, 0 }, -- BATTLEGROUND_FRIENDLY_PVP
}

oUF.colors.power = {
	["ALTPOWER"] = { 0.00, 1.00, 1.00 },
	["AMMOSLOT"] = { 0.80, 0.60, 0.00 },
	["ARCANE_CHARGES"] = { 0.41, 0.8, 0.94 },
	["CHI"] = { 0.71, 1.00, 0.92 },
	["COMBO_POINTS"] = { 0.69, 0.31, 0.31 },
	["ENERGY"] = { 0.65, 0.63, 0.35 },
	["FOCUS"] = { 0.71, 0.43, 0.27 },
	["FUEL"] = { 0.00, 0.55, 0.50 },
	["FURY"] = { 0.78, 0.26, 0.99 },
	["HOLY_POWER"] = { 0.95, 0.90, 0.60 },
	["INSANITY"] = { 0.40, 0.00, 0.80 },
	["LUNAR_POWER"] = { 0.93, 0.51, 0.93 },
	["MAELSTROM"] = { 0.00, 0.50, 1.00 },
	["MANA"] = { 0.31, 0.45, 0.63 },
	["PAIN"] = { 1.00, 0.61, 0.00 },
	["POWER_TYPE_PYRITE"] = { 0.60, 0.09, 0.17 },
	["POWER_TYPE_STEAM"] = { 0.55, 0.57, 0.61 },
	["RAGE"] = { 0.78, 0.25, 0.25 },
	["ESSENCE"] = { 100 / 255, 173 / 255, 206 / 255 },
	["RUNES"] = { 0.55, 0.57, 0.61 },
	["RUNIC_POWER"] = { 0, 0.82, 1 },
	["SOUL_SHARDS"] = { 0.50, 0.32, 0.55 },
	["STAGGER"] = {
		{ 0.52, 1.00, 0.52 },
		{ 1.00, 0.98, 0.72 },
		{ 1.00, 0.42, 0.42 },
	},
	["UNUSED"] = { 0.76, 0.79, 0.85 },
}

oUF.colors.class = {
	["DEATHKNIGHT"] = { 0.77, 0.12, 0.24 },
	["DEMONHUNTER"] = { 0.64, 0.19, 0.79 },
	["DRUID"] = { 1.00, 0.49, 0.03 },
	["EVOKER"] = { 0.20, 0.58, 0.50 },
	["HUNTER"] = { 0.67, 0.84, 0.45 },
	["MAGE"] = { 0.41, 0.80, 1.00 },
	["MONK"] = { 0.00, 1.00, 0.59 },
	["PALADIN"] = { 0.96, 0.55, 0.73 },
	["PRIEST"] = { 0.86, 0.92, 0.98 },
	["ROGUE"] = { 1.00, 0.95, 0.32 },
	["SHAMAN"] = { 0.16, 0.31, 0.61 },
	["WARLOCK"] = { 0.58, 0.51, 0.79 },
	["WARRIOR"] = { 0.78, 0.61, 0.43 },
	["UNKNOWN"] = { 0.76, 0.79, 0.85 },
}

oUF.colors.faction = {
	{ r = 0.8, g = 0.3, b = 0.22 }, -- 1
	{ r = 0.8, g = 0.3, b = 0.22 }, -- 2
	{ r = 0.75, g = 0.27, b = 0 }, -- 3
	{ r = 0.9, g = 0.7, b = 0 }, -- 4
	{ r = 0, g = 0.6, b = 0.1 }, -- 5
	{ r = 0, g = 0.6, b = 0.1 }, -- 6
	{ r = 0, g = 0.6, b = 0.1 }, -- 7
	{ r = 0, g = 0.6, b = 0.1 }, -- 8
	{ r = 0, g = 0.6, b = 0.1 }, -- 9 (Paragon)
	{ r = 0, g = 0.74, b = 0.95 }, -- 10 (Renown)
}

K["Colors"] = oUF.colors
