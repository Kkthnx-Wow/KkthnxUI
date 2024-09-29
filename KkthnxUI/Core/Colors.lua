local K = KkthnxUI[1]
local oUF = K.oUF

if not oUF then
	K.Print("Could not find a vaild instance of oUF. Stopping Colors.lua code!")
	return
end

oUF.colors.fallback = { 1.0, 1.0, 0.8 } -- Fallback color (light yellow)

oUF.colors.castbar = {
	CastingColor = { 1.0, 0.7, 0.0 }, -- Orange (casting)
	ChannelingColor = { 0.0, 0.8, 0.0 }, -- Bright green (channeling)
	notInterruptibleColor = { 0.7, 0.7, 0.7 }, -- Gray (not interruptible)
	CompleteColor = { 0.0, 1.0, 0.0 }, -- Bright green (complete)
	FailColor = { 1.0, 0.0, 0.0 }, -- Bright red (failed)
}

-- Aura Coloring
oUF.colors.debuff = {
	none = { 0.8, 0.1, 0.1 }, -- Soft red (no debuff)
	Magic = { 0.2, 0.6, 1.0 }, -- Light blue (magic)
	Curse = { 0.8, 0.0, 1.0 }, -- Bright purple (curse)
	Disease = { 0.6, 0.5, 0.0 }, -- Olive green (disease)
	Poison = { 0.0, 0.6, 0.0 }, -- Bright green (poison)
	[""] = { 1.0, 1.0, 1.0 }, -- White (default)
}

oUF.colors.mirror = {
	EXHAUSTION = { 1.0, 0.9, 0.0 }, -- Soft yellow (exhaustion)
	BREATH = { 0.0, 0.5, 1.0 }, -- Soft blue (breath)
	DEATH = { 1.0, 0.7, 0.0 }, -- Soft orange (death)
	FEIGNDEATH = { 1.0, 0.7, 0.0 }, -- Soft orange (feign death)
}

oUF.colors.reaction = {
	[1] = { 0.87, 0.37, 0.37 }, -- Hated (soft red)
	[2] = { 0.87, 0.37, 0.37 }, -- Hostile (soft red)
	[3] = { 0.87, 0.37, 0.37 }, -- Unfriendly (soft red)
	[4] = { 0.85, 0.77, 0.36 }, -- Neutral (muted yellow)
	[5] = { 0.29, 0.67, 0.30 }, -- Friendly (soft green)
	[6] = { 0.29, 0.67, 0.30 }, -- Honored (soft green)
	[7] = { 0.29, 0.67, 0.30 }, -- Revered (soft green)
	[8] = { 0.29, 0.67, 0.30 }, -- Exalted (soft green)
}

oUF.colors.selection = {
	[0] = { 1.00, 0.18, 0.18 }, -- HOSTILE (bright red)
	[1] = { 1.00, 0.51, 0.20 }, -- UNFRIENDLY (soft orange)
	[2] = { 1.00, 0.85, 0.20 }, -- NEUTRAL (muted yellow)
	[3] = { 0.20, 0.71, 0.00 }, -- FRIENDLY (bright green)
	[5] = { 0.40, 0.53, 1.00 }, -- PLAYER_EXTENDED (soft blue)
	[6] = { 0.40, 0.20, 1.00 }, -- PARTY (purple)
	[7] = { 0.73, 0.20, 1.00 }, -- PARTY_PVP (light purple)
	[8] = { 0.20, 1.00, 0.42 }, -- FRIEND (light green)
	[9] = { 0.60, 0.60, 0.60 }, -- DEAD (gray)
	[13] = { 0.10, 0.58, 0.28 }, -- BATTLEGROUND_FRIENDLY_PVP (teal)
}

oUF.colors.power = {
	["ALTPOWER"] = { 0.00, 0.85, 0.85 }, -- Cyan, softened to avoid harshness
	["AMMOSLOT"] = { 0.75, 0.60, 0.20 }, -- Warm earthy brown
	["ARCANE_CHARGES"] = { 0.45, 0.75, 0.85 }, -- Soft sky blue
	["CHI"] = { 0.65, 0.90, 0.80 }, -- Muted teal-green, softening the brightness
	["COMBO_POINTS"] = { 0.65, 0.30, 0.30 }, -- Deep muted red
	["ENERGY"] = { 0.60, 0.60, 0.40 }, -- Softened yellow-brown
	["ESSENCE"] = { 0.40, 0.70, 0.80 }, -- Softened cyan-blue
	["FOCUS"] = { 0.70, 0.45, 0.30 }, -- Warm, softer orange-brown
	["FUEL"] = { 0.00, 0.50, 0.50 }, -- Muted teal, in line with cyan-like tones
	["FURY"] = { 0.75, 0.30, 0.90 }, -- Softened purple-pink, still vivid
	["HOLY_POWER"] = { 0.90, 0.85, 0.50 }, -- Muted golden, reduced brightness
	["INSANITY"] = { 0.45, 0.10, 0.80 }, -- Deep, softer purple
	["LUNAR_POWER"] = { 0.85, 0.60, 0.85 }, -- Pastel purple, softer magenta
	["MAELSTROM"] = { 0.00, 0.55, 0.85 }, -- Deep sky blue
	["MANA"] = { 0.35, 0.50, 0.65 }, -- Muted blue, consistent with others
	["PAIN"] = { 0.90, 0.55, 0.20 }, -- Softer orange, avoiding harshness
	["POWER_TYPE_PYRITE"] = { 0.60, 0.20, 0.25 }, -- Muted dark red
	["POWER_TYPE_STEAM"] = { 0.55, 0.55, 0.60 }, -- Neutral gray, toned down
	["RAGE"] = { 0.75, 0.30, 0.30 }, -- Softened deep red
	["RUNES"] = { 0.55, 0.55, 0.60 }, -- Neutral gray, consistent with Steam
	["RUNIC_POWER"] = { 0.00, 0.70, 0.85 }, -- Deep sky blue, softer cyan
	["SOUL_SHARDS"] = { 0.50, 0.35, 0.60 }, -- Softened purple-gray
	["STAGGER"] = {
		{ 0.50, 0.85, 0.50 }, -- Soft green
		{ 0.90, 0.85, 0.55 }, -- Muted golden yellow
		{ 0.90, 0.45, 0.45 }, -- Softened red
	},
	["UNUSED"] = { 0.70, 0.75, 0.80 }, -- Soft light gray
}

oUF.colors.class = {
	["DEATHKNIGHT"] = { 0.70, 0.15, 0.20 }, -- Deep muted red
	["DEMONHUNTER"] = { 0.60, 0.25, 0.75 }, -- Softer violet
	["DRUID"] = { 1.00, 0.45, 0.10 }, -- Warm earthy orange
	["EVOKER"] = { 0.25, 0.55, 0.50 }, -- Muted teal
	["HUNTER"] = { 0.65, 0.80, 0.50 }, -- Soft olive green
	["MAGE"] = { 0.40, 0.75, 1.00 }, -- Softer sky blue
	["MONK"] = { 0.00, 0.90, 0.55 }, -- Muted bright green
	["PALADIN"] = { 0.90, 0.60, 0.70 }, -- Soft pink
	["PRIEST"] = { 0.85, 0.90, 0.95 }, -- Soft pastel blue
	["ROGUE"] = { 1.00, 0.90, 0.35 }, -- Softened golden yellow
	["SHAMAN"] = { 0.20, 0.35, 0.60 }, -- Deep muted blue
	["WARLOCK"] = { 0.55, 0.50, 0.75 }, -- Softened purple
	["WARRIOR"] = { 0.75, 0.55, 0.40 }, -- Earthy brown
	["UNKNOWN"] = { 0.70, 0.75, 0.80 }, -- Soft light gray
}

oUF.colors.faction = {
	{ r = 0.75, g = 0.20, b = 0.20 }, -- 1: Soft red
	{ r = 0.75, g = 0.20, b = 0.20 }, -- 2: Soft red (same as 1)
	{ r = 0.70, g = 0.25, b = 0.00 }, -- 3: Muted orange
	{ r = 0.90, g = 0.70, b = 0.10 }, -- 4: Soft golden yellow
	{ r = 0.00, g = 0.55, b = 0.15 }, -- 5: Muted green
	{ r = 0.00, g = 0.55, b = 0.15 }, -- 6: Muted green (same as 5)
	{ r = 0.00, g = 0.55, b = 0.15 }, -- 7: Muted green (same as 5)
	{ r = 0.00, g = 0.55, b = 0.15 }, -- 8: Muted green (same as 5)
	{ r = 0.00, g = 0.55, b = 0.15 }, -- 9: Muted green (same as 5, Paragon)
	{ r = 0.00, g = 0.70, b = 0.90 }, -- 10: Soft teal (Renown)
}

K["Colors"] = oUF.colors
