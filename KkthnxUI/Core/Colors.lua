--[[-----------------------------------------------------------------------------
Addon: KkthnxUI
Author: Josh "Kkthnx" Russell
Notes:
- Purpose: Custom color definitions for oUF and unit frames.
- Design: Uses a consistent, softened palette for better UI readability.
-----------------------------------------------------------------------------]]

local K = KkthnxUI[1]
local oUF = K.oUF

if not oUF then
	K.Print("Could not find a valid instance of oUF. Stopping Colors.lua code!")
	return
end

-- REASON: Fallback color ensuring UI elements remain visible if a specific color is missing.
oUF.colors.fallback = { 1.0, 1.0, 0.8 }

-- ---------------------------------------------------------------------------
-- Unit Frame Colors
-- ---------------------------------------------------------------------------

oUF.colors.castbar = {
	CastingColor = { 1.0, 0.7, 0.0 }, -- Orange (casting)
	ChannelingColor = { 0.0, 0.8, 0.0 }, -- Bright green (channeling)
	notInterruptibleColor = { 0.7, 0.7, 0.7 }, -- Gray (not interruptible)
	CompleteColor = { 0.0, 1.0, 0.0 }, -- Bright green (complete)
	FailColor = { 1.0, 0.0, 0.0 }, -- Bright red (failed)
}

-- ---------------------------------------------------------------------------
-- Aura & Debuff Colors
-- ---------------------------------------------------------------------------

oUF.colors.debuff = {
	none = { 0.8, 0.1, 0.1 }, -- Soft red (no debuff)
	Magic = { 0.2, 0.6, 1.0 }, -- Light blue (magic)
	Curse = { 0.8, 0.0, 1.0 }, -- Bright purple (curse)
	Disease = { 0.6, 0.5, 0.0 }, -- Olive green (disease)
	Poison = { 0.0, 0.6, 0.0 }, -- Bright green (poison)
	[""] = { 1.0, 1.0, 1.0 }, -- White (default)
}

-- ---------------------------------------------------------------------------
-- Mirror Timer Colors
-- ---------------------------------------------------------------------------

oUF.colors.mirror = {
	EXHAUSTION = { 1.0, 0.9, 0.0 }, -- Soft yellow (exhaustion)
	BREATH = { 0.0, 0.5, 1.0 }, -- Soft blue (breath)
	DEATH = { 1.0, 0.7, 0.0 }, -- Soft orange (death)
	FEIGNDEATH = { 1.0, 0.7, 0.0 }, -- Soft orange (feign death)
}

-- ---------------------------------------------------------------------------
-- NPC & Faction Reaction Colors
-- ---------------------------------------------------------------------------

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

-- ---------------------------------------------------------------------------
-- Selection & Interaction Colors
-- ---------------------------------------------------------------------------

oUF.colors.selection = {
	[0] = { 0.78, 0.25, 0.25 },
	[2] = { 0.85, 0.76, 0.36 },
	[3] = { 0.29, 0.67, 0.30 },
}

-- ---------------------------------------------------------------------------
-- Power & Resource Colors
-- ---------------------------------------------------------------------------

oUF.colors.power = {
	["ALTPOWER"] = { 0.00, 0.85, 0.85 }, -- Cyan, softened to avoid harshness
	["AMMOSLOT"] = { 0.75, 0.60, 0.20 }, -- Warm earthy brown
	["ARCANE_CHARGES"] = { 0.45, 0.75, 0.85 }, -- Soft sky blue
	["CHI"] = { 0.65, 0.90, 0.80 }, -- Muted teal-green
	["COMBO_POINTS"] = { 0.65, 0.30, 0.30 }, -- NOTE: Fallback for older oUF versions / compatibility.
	["COMBO_POINTS_GRADUATED"] = {
		{ 0.75, 0.31, 0.31 }, -- 1 point: Red
		{ 0.78, 0.56, 0.31 }, -- 2 points: Red-orange
		{ 0.81, 0.81, 0.31 }, -- 3 points: Yellow
		{ 0.56, 0.78, 0.31 }, -- 4 points: Yellow-green
		{ 0.43, 0.76, 0.31 }, -- 5 points: Light green
		{ 0.31, 0.75, 0.31 }, -- 6 points: Green
		{ 0.36, 0.81, 0.54 }, -- 7 points: Teal-green
	},
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
	["EBON_MIGHT"] = { 0.70, 0.45, 0.30 }, -- Warm, softer orange-brown
	["STAGGER"] = {
		{ 0.50, 0.85, 0.50 }, -- Soft green
		{ 0.90, 0.85, 0.55 }, -- Muted golden yellow
		{ 0.90, 0.45, 0.45 }, -- Softened red
	},
	["UNUSED"] = { 0.70, 0.75, 0.80 }, -- Soft light gray
}

-- ---------------------------------------------------------------------------
-- Class Colors
-- ---------------------------------------------------------------------------

-- REASON: Softened versions of Blizzard class colors for better scannability.
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

-- ---------------------------------------------------------------------------
-- Renown & Standing Colors
-- ---------------------------------------------------------------------------

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

-- ---------------------------------------------------------------------------
-- ColorMixin upgrade (MIDNIGHT 12.0)
-- ---------------------------------------------------------------------------

-- REASON: The bundled oUF's default Health/Power UpdateColor now expects
-- ColorMixin-based objects and calls color:GetRGB() (plus color:GetAtlas() /
-- color:GetCurve() for power). KkthnxUI defines its palette as plain {r,g,b}
-- arrays, which lack those methods and threw "attempt to call a nil value" in
-- oUF/elements/health.lua:183. We upgrade the tables oUF reads into real
-- ColorMixins via the library's own oUF:CreateColor, while keeping the numeric
-- [1]/[2]/[3] access that the rest of KkthnxUI (K.UnitColor, K.RGBToHex, etc.)
-- relies on. The vendored library is never edited.
local function UpgradeColor(rgb)
	if type(rgb) ~= "table" or rgb.GetRGB then
		return rgb
	end

	local r, g, b = rgb[1], rgb[2], rgb[3]
	if type(r) ~= "number" then
		return rgb
	end

	-- NOTE: oUF:CreateColor only rescales when a component is > 1, so our 0-1
	-- values pass through unchanged.
	local color = oUF:CreateColor(r, g, b)
	color[1], color[2], color[3] = r, g, b
	return color
end

local function UpgradeColorTable(t)
	if type(t) ~= "table" then
		return
	end

	for key, value in next, t do
		if type(value) == "table" and type(value[1]) == "table" then
			-- nested palettes (graduated combo points, stagger stages)
			for i = 1, #value do
				value[i] = UpgradeColor(value[i])
			end
		else
			t[key] = UpgradeColor(value)
		end
	end
end

UpgradeColorTable(oUF.colors.class)
UpgradeColorTable(oUF.colors.reaction)
UpgradeColorTable(oUF.colors.selection)
UpgradeColorTable(oUF.colors.power)

-- REASON: Replacing oUF.colors.power wholesale (above) dropped the numeric
-- Enum.PowerType fallback indices the vendored oUF normally adds. The oUF Power
-- element resolves color as power[token] -> power[type] -> power.MANA, so when the
-- string token lookup misses (e.g. Midnight secret/empty token, alt power, vehicles)
-- it fell through to MANA's muted blue for every bar. Re-point the numeric indices
-- at our existing ColorMixins (same objects), mirroring oUF's colors.lua, without
-- editing the library.
do
	local Enum = _G.Enum
	local power = oUF.colors.power
	local numericByToken = {
		[Enum and Enum.PowerType and Enum.PowerType.Mana or 0] = "MANA",
		[Enum and Enum.PowerType and Enum.PowerType.Rage or 1] = "RAGE",
		[Enum and Enum.PowerType and Enum.PowerType.Focus or 2] = "FOCUS",
		[Enum and Enum.PowerType and Enum.PowerType.Energy or 3] = "ENERGY",
		[Enum and Enum.PowerType and Enum.PowerType.ComboPoints or 4] = "COMBO_POINTS",
		[Enum and Enum.PowerType and Enum.PowerType.Runes or 5] = "RUNES",
		[Enum and Enum.PowerType and Enum.PowerType.RunicPower or 6] = "RUNIC_POWER",
		[Enum and Enum.PowerType and Enum.PowerType.SoulShards or 7] = "SOUL_SHARDS",
		[Enum and Enum.PowerType and Enum.PowerType.LunarPower or 8] = "LUNAR_POWER",
		[Enum and Enum.PowerType and Enum.PowerType.HolyPower or 9] = "HOLY_POWER",
		[Enum and Enum.PowerType and Enum.PowerType.Maelstrom or 11] = "MAELSTROM",
		[Enum and Enum.PowerType and Enum.PowerType.Chi or 12] = "CHI",
		[Enum and Enum.PowerType and Enum.PowerType.Insanity or 13] = "INSANITY",
		[Enum and Enum.PowerType and Enum.PowerType.ArcaneCharges or 16] = "ARCANE_CHARGES",
		[Enum and Enum.PowerType and Enum.PowerType.Fury or 17] = "FURY",
		[Enum and Enum.PowerType and Enum.PowerType.Pain or 18] = "PAIN",
		[Enum and Enum.PowerType and Enum.PowerType.Essence or 19] = "ESSENCE",
	}

	for index, token in next, numericByToken do
		if power[token] and power[index] == nil then
			power[index] = power[token]
		end
	end

	-- ALTERNATE power has no custom token in our palette; alias it to ALTPOWER.
	local altIndex = Enum and Enum.PowerType and Enum.PowerType.Alternate or 10
	if power.ALTPOWER and power[altIndex] == nil then
		power[altIndex] = power.ALTPOWER
	end
end

-- REASON: Expose the finalized oUF color table to the KkthnxUI engine.
K["Colors"] = oUF.colors
