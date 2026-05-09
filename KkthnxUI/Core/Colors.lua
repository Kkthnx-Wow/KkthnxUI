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
	K.Print("|cffff0000[Colors.lua]|r Could not find a valid instance of oUF. Stopping Colors.lua code!")
	return
end

-- ---------------------------------------------------------------------------
-- Override oUF.colors directly so all oUF elements use our custom colors
-- ---------------------------------------------------------------------------

-- Store reference for KkthnxUI access
K.Colors = oUF.colors

-- REASON: Fallback color ensuring UI elements remain visible if a specific color is missing.
oUF.colors.fallback = oUF:CreateColor(1.0, 1.0, 0.8)

-- ---------------------------------------------------------------------------
-- Unit Frame Colors
-- ---------------------------------------------------------------------------

oUF.colors.castbar = {
	CastingColor = oUF:CreateColor(1.0, 0.7, 0.0), -- Orange (casting)
	ChannelingColor = oUF:CreateColor(0.0, 0.8, 0.0), -- Bright green (channeling)
	notInterruptibleColor = oUF:CreateColor(0.7, 0.7, 0.7), -- Gray (not interruptible)
	CompleteColor = oUF:CreateColor(0.0, 1.0, 0.0), -- Bright green (complete)
	FailColor = oUF:CreateColor(1.0, 0.0, 0.0), -- Bright red (failed)
}

-- ---------------------------------------------------------------------------
-- Aura & Debuff Colors
-- ---------------------------------------------------------------------------

oUF.colors.debuff = {
	none = oUF:CreateColor(0.8, 0.1, 0.1), -- Soft red (no debuff)
	Magic = oUF:CreateColor(0.2, 0.6, 1.0), -- Light blue (magic)
	Curse = oUF:CreateColor(0.8, 0.0, 1.0), -- Bright purple (curse)
	Disease = oUF:CreateColor(0.6, 0.5, 0.0), -- Olive green (disease)
	Poison = oUF:CreateColor(0.0, 0.6, 0.0), -- Bright green (poison)
	[""] = oUF:CreateColor(1.0, 1.0, 1.0), -- White (default)
}

-- ---------------------------------------------------------------------------
-- Mirror Timer Colors
-- ---------------------------------------------------------------------------

oUF.colors.mirror = {
	EXHAUSTION = oUF:CreateColor(1.0, 0.9, 0.0), -- Soft yellow (exhaustion)
	BREATH = oUF:CreateColor(0.0, 0.5, 1.0), -- Soft blue (breath)
	DEATH = oUF:CreateColor(1.0, 0.7, 0.0), -- Soft orange (death)
	FEIGNDEATH = oUF:CreateColor(1.0, 0.7, 0.0), -- Soft orange (feign death)
}

-- ---------------------------------------------------------------------------
-- NPC & Faction Reaction Colors
-- ---------------------------------------------------------------------------

oUF.colors.reaction[1] = oUF:CreateColor(0.87, 0.37, 0.37) -- Hated (soft red)
oUF.colors.reaction[2] = oUF:CreateColor(0.87, 0.37, 0.37) -- Hostile (soft red)
oUF.colors.reaction[3] = oUF:CreateColor(0.87, 0.37, 0.37) -- Unfriendly (soft red)
oUF.colors.reaction[4] = oUF:CreateColor(0.85, 0.77, 0.36) -- Neutral (muted yellow)
oUF.colors.reaction[5] = oUF:CreateColor(0.29, 0.67, 0.30) -- Friendly (soft green)
oUF.colors.reaction[6] = oUF:CreateColor(0.29, 0.67, 0.30) -- Honored (soft green)
oUF.colors.reaction[7] = oUF:CreateColor(0.29, 0.67, 0.30) -- Revered (soft green)
oUF.colors.reaction[8] = oUF:CreateColor(0.29, 0.67, 0.30) -- Exalted (soft green)

-- ---------------------------------------------------------------------------
-- Power & Resource Colors
-- ---------------------------------------------------------------------------

oUF.colors.power.ALTPOWER = oUF:CreateColor(0.00, 0.85, 0.85) -- Cyan
oUF.colors.power.AMMOSLOT = oUF:CreateColor(0.75, 0.60, 0.20) -- Warm earthy brown
oUF.colors.power.ARCANE_CHARGES = oUF:CreateColor(0.45, 0.75, 0.85) -- Soft sky blue
oUF.colors.power.CHI = oUF:CreateColor(0.65, 0.90, 0.80) -- Muted teal-green
oUF.colors.power.COMBO_POINTS = oUF:CreateColor(0.65, 0.30, 0.30) -- Fallback
oUF.colors.power.ENERGY = oUF:CreateColor(0.60, 0.60, 0.40) -- Softened yellow-brown
oUF.colors.power.ESSENCE = oUF:CreateColor(0.40, 0.70, 0.80) -- Softened cyan-blue
oUF.colors.power.FOCUS = oUF:CreateColor(0.70, 0.45, 0.30) -- Warm, softer orange-brown
oUF.colors.power.FUEL = oUF:CreateColor(0.00, 0.50, 0.50) -- Muted teal
oUF.colors.power.FURY = oUF:CreateColor(0.75, 0.30, 0.90) -- Softened purple-pink
oUF.colors.power.HOLY_POWER = oUF:CreateColor(0.90, 0.85, 0.50) -- Muted golden
oUF.colors.power.INSANITY = oUF:CreateColor(0.45, 0.10, 0.80) -- Deep, softer purple
oUF.colors.power.LUNAR_POWER = oUF:CreateColor(0.85, 0.60, 0.85) -- Pastel purple
oUF.colors.power.MAELSTROM = oUF:CreateColor(0.00, 0.55, 0.85) -- Deep sky blue
oUF.colors.power.MANA = oUF:CreateColor(0.35, 0.50, 0.65) -- Muted blue
oUF.colors.power.PAIN = oUF:CreateColor(0.90, 0.55, 0.20) -- Softer orange
oUF.colors.power.POWER_TYPE_PYRITE = oUF:CreateColor(0.60, 0.20, 0.25) -- Muted dark red
oUF.colors.power.POWER_TYPE_STEAM = oUF:CreateColor(0.55, 0.55, 0.60) -- Neutral gray
oUF.colors.power.RAGE = oUF:CreateColor(0.75, 0.30, 0.30) -- Softened deep red
oUF.colors.power.RUNES = oUF:CreateColor(0.55, 0.55, 0.60) -- Neutral gray
oUF.colors.power.RUNIC_POWER = oUF:CreateColor(0.00, 0.70, 0.85) -- Deep sky blue
oUF.colors.power.SOUL_SHARDS = oUF:CreateColor(0.50, 0.35, 0.60) -- Softened purple-gray
oUF.colors.power.EBON_MIGHT = oUF:CreateColor(0.70, 0.45, 0.30) -- Warm, softer orange-brown
oUF.colors.power.UNUSED = oUF:CreateColor(0.70, 0.75, 0.80) -- Soft light gray

-- REASON: Update integer indices to point to our new color objects
-- oUF sets these up at load time pointing to original colors
oUF.colors.power[0] = oUF.colors.power.MANA
oUF.colors.power[1] = oUF.colors.power.RAGE
oUF.colors.power[2] = oUF.colors.power.FOCUS
oUF.colors.power[3] = oUF.colors.power.ENERGY
oUF.colors.power[4] = oUF.colors.power.COMBO_POINTS
oUF.colors.power[5] = oUF.colors.power.RUNES
oUF.colors.power[6] = oUF.colors.power.RUNIC_POWER
oUF.colors.power[7] = oUF.colors.power.SOUL_SHARDS
oUF.colors.power[8] = oUF.colors.power.LUNAR_POWER
oUF.colors.power[9] = oUF.colors.power.HOLY_POWER
oUF.colors.power[10] = oUF.colors.power.ALTPOWER
oUF.colors.power[11] = oUF.colors.power.MAELSTROM
oUF.colors.power[12] = oUF.colors.power.CHI
oUF.colors.power[13] = oUF.colors.power.INSANITY
oUF.colors.power[16] = oUF.colors.power.ARCANE_CHARGES
oUF.colors.power[17] = oUF.colors.power.FURY
oUF.colors.power[18] = oUF.colors.power.PAIN
oUF.colors.power[19] = oUF.colors.power.ESSENCE

-- ---------------------------------------------------------------------------
-- Class Colors
-- ---------------------------------------------------------------------------

-- REASON: Softened versions of Blizzard class colors for better scannability.
oUF.colors.class.DEATHKNIGHT = oUF:CreateColor(0.70, 0.15, 0.20) -- Deep muted red
oUF.colors.class.DEMONHUNTER = oUF:CreateColor(0.60, 0.25, 0.75) -- Softer violet
oUF.colors.class.DRUID = oUF:CreateColor(1.00, 0.45, 0.10) -- Warm earthy orange
oUF.colors.class.EVOKER = oUF:CreateColor(0.25, 0.55, 0.50) -- Muted teal
oUF.colors.class.HUNTER = oUF:CreateColor(0.65, 0.80, 0.50) -- Soft olive green
oUF.colors.class.MAGE = oUF:CreateColor(0.40, 0.75, 1.00) -- Softer sky blue
oUF.colors.class.MONK = oUF:CreateColor(0.00, 0.90, 0.55) -- Muted bright green
oUF.colors.class.PALADIN = oUF:CreateColor(0.90, 0.60, 0.70) -- Soft pink
oUF.colors.class.PRIEST = oUF:CreateColor(0.85, 0.90, 0.95) -- Soft pastel blue
oUF.colors.class.ROGUE = oUF:CreateColor(1.00, 0.90, 0.35) -- Softened golden yellow
oUF.colors.class.SHAMAN = oUF:CreateColor(0.20, 0.35, 0.60) -- Deep muted blue
oUF.colors.class.WARLOCK = oUF:CreateColor(0.55, 0.50, 0.75) -- Softened purple
oUF.colors.class.WARRIOR = oUF:CreateColor(0.75, 0.55, 0.40) -- Earthy brown
oUF.colors.class.UNKNOWN = oUF:CreateColor(0.70, 0.75, 0.80) -- Soft light gray
