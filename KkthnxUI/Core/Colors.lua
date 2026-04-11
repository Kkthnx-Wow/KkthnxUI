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
	K.Print("Could not find a vaild instance of oUF. Stopping Colors.lua code!")
	return
end

K.Colors = setmetatable({
	-- REASON: Fallback color ensuring UI elements remain visible if a specific color is missing.
	fallback = oUF:CreateColor(1.0, 1.0, 0.8),

	-- ---------------------------------------------------------------------------
	-- Unit Frame Colors
	-- ---------------------------------------------------------------------------

	castbar = {
		CastingColor = oUF:CreateColor(1.0, 0.7, 0.0), -- Orange (casting)
		ChannelingColor = oUF:CreateColor(0.0, 0.8, 0.0), -- Bright green (channeling)
		notInterruptibleColor = oUF:CreateColor(0.7, 0.7, 0.7), -- Gray (not interruptible)
		CompleteColor = oUF:CreateColor(0.0, 1.0, 0.0), -- Bright green (complete)
		FailColor = oUF:CreateColor(1.0, 0.0, 0.0), -- Bright red (failed)
	},

	-- ---------------------------------------------------------------------------
	-- Aura & Debuff Colors
	-- ---------------------------------------------------------------------------

	debuff = {
		none = oUF:CreateColor(0.8, 0.1, 0.1), -- Soft red (no debuff)
		Magic = oUF:CreateColor(0.2, 0.6, 1.0), -- Light blue (magic)
		Curse = oUF:CreateColor(0.8, 0.0, 1.0), -- Bright purple (curse)
		Disease = oUF:CreateColor(0.6, 0.5, 0.0), -- Olive green (disease)
		Poison = oUF:CreateColor(0.0, 0.6, 0.0), -- Bright green (poison)
		[""] = oUF:CreateColor(1.0, 1.0, 1.0), -- White (default)
	},

	-- ---------------------------------------------------------------------------
	-- Mirror Timer Colors
	-- ---------------------------------------------------------------------------

	mirror = {
		EXHAUSTION = oUF:CreateColor(1.0, 0.9, 0.0), -- Soft yellow (exhaustion)
		BREATH = oUF:CreateColor(0.0, 0.5, 1.0), -- Soft blue (breath)
		DEATH = oUF:CreateColor(1.0, 0.7, 0.0), -- Soft orange (death)
		FEIGNDEATH = oUF:CreateColor(1.0, 0.7, 0.0), -- Soft orange (feign death)
	},

	-- ---------------------------------------------------------------------------
	-- NPC & Faction Reaction Colors
	-- ---------------------------------------------------------------------------

	reaction = setmetatable({
		[1] = oUF:CreateColor(0.87, 0.37, 0.37), -- Hated (soft red)
		[2] = oUF:CreateColor(0.87, 0.37, 0.37), -- Hostile (soft red)
		[3] = oUF:CreateColor(0.87, 0.37, 0.37), -- Unfriendly (soft red)
		[4] = oUF:CreateColor(0.85, 0.77, 0.36), -- Neutral (muted yellow)
		[5] = oUF:CreateColor(0.29, 0.67, 0.30), -- Friendly (soft green)
		[6] = oUF:CreateColor(0.29, 0.67, 0.30), -- Honored (soft green)
		[7] = oUF:CreateColor(0.29, 0.67, 0.30), -- Revered (soft green)
		[8] = oUF:CreateColor(0.29, 0.67, 0.30), -- Exalted (soft green)
	}, { __index = reaction }),

	-- ---------------------------------------------------------------------------
	-- Selection & Interaction Colors
	-- ---------------------------------------------------------------------------

	selection = setmetatable({
		[0] = oUF:CreateColor(0.78, 0.25, 0.25), -- Hostile
		[2] = oUF:CreateColor(0.85, 0.76, 0.36), -- Neutral
		[3] = oUF:CreateColor(0.29, 0.67, 0.30), -- Friendly
	}, { __index = selection }),

	-- ---------------------------------------------------------------------------
	-- Power & Resource Colors
	-- ---------------------------------------------------------------------------

	power = setmetatable({
		["ALTPOWER"] = oUF:CreateColor(0.00, 0.85, 0.85), -- Cyan, softened to avoid harshness
		["AMMOSLOT"] = oUF:CreateColor(0.75, 0.60, 0.20), -- Warm earthy brown
		["ARCANE_CHARGES"] = oUF:CreateColor(0.45, 0.75, 0.85), -- Soft sky blue
		["CHI"] = oUF:CreateColor(0.65, 0.90, 0.80), -- Muted teal-green
		["COMBO_POINTS"] = oUF:CreateColor(0.65, 0.30, 0.30), -- NOTE: Fallback for older oUF versions / compatibility.
		["ENERGY"] = oUF:CreateColor(0.60, 0.60, 0.40), -- Softened yellow-brown
		["ESSENCE"] = oUF:CreateColor(0.40, 0.70, 0.80), -- Softened cyan-blue
		["FOCUS"] = oUF:CreateColor(0.70, 0.45, 0.30), -- Warm, softer orange-brown
		["FUEL"] = oUF:CreateColor(0.00, 0.50, 0.50), -- Muted teal, in line with cyan-like tones
		["FURY"] = oUF:CreateColor(0.75, 0.30, 0.90), -- Softened purple-pink, still vivid
		["HOLY_POWER"] = oUF:CreateColor(0.90, 0.85, 0.50), -- Muted golden, reduced brightness
		["INSANITY"] = oUF:CreateColor(0.45, 0.10, 0.80), -- Deep, softer purple
		["LUNAR_POWER"] = oUF:CreateColor(0.85, 0.60, 0.85), -- Pastel purple, softer magenta
		["MAELSTROM"] = oUF:CreateColor(0.00, 0.55, 0.85), -- Deep sky blue
		["MANA"] = oUF:CreateColor(0.35, 0.50, 0.65), -- Muted blue, consistent with others
		["PAIN"] = oUF:CreateColor(0.90, 0.55, 0.20), -- Softer orange, avoiding harshness
		["POWER_TYPE_PYRITE"] = oUF:CreateColor(0.60, 0.20, 0.25), -- Muted dark red
		["POWER_TYPE_STEAM"] = oUF:CreateColor(0.55, 0.55, 0.60), -- Neutral gray, toned down
		["RAGE"] = oUF:CreateColor(0.75, 0.30, 0.30), -- Softened deep red
		["RUNES"] = oUF:CreateColor(0.55, 0.55, 0.60), -- Neutral gray, consistent with Steam
		["RUNIC_POWER"] = oUF:CreateColor(0.00, 0.70, 0.85), -- Deep sky blue, softer cyan
		["SOUL_SHARDS"] = oUF:CreateColor(0.50, 0.35, 0.60), -- Softened purple-gray
		["EBON_MIGHT"] = oUF:CreateColor(0.70, 0.45, 0.30), -- Warm, softer orange-brown
		["UNUSED"] = oUF:CreateColor(0.70, 0.75, 0.80), -- Soft light gray
	}, { __index = power }),

	-- ---------------------------------------------------------------------------
	-- Class Colors
	-- ---------------------------------------------------------------------------

	-- REASON: Softened versions of Blizzard class colors for better scannability.
	class = setmetatable({
		["DEATHKNIGHT"] = oUF:CreateColor(0.70, 0.15, 0.20), -- Deep muted red
		["DEMONHUNTER"] = oUF:CreateColor(0.60, 0.25, 0.75), -- Softer violet
		["DRUID"] = oUF:CreateColor(1.00, 0.45, 0.10), -- Warm earthy orange
		["EVOKER"] = oUF:CreateColor(0.25, 0.55, 0.50), -- Muted teal
		["HUNTER"] = oUF:CreateColor(0.65, 0.80, 0.50), -- Soft olive green
		["MAGE"] = oUF:CreateColor(0.40, 0.75, 1.00), -- Softer sky blue
		["MONK"] = oUF:CreateColor(0.00, 0.90, 0.55), -- Muted bright green
		["PALADIN"] = oUF:CreateColor(0.90, 0.60, 0.70), -- Soft pink
		["PRIEST"] = oUF:CreateColor(0.85, 0.90, 0.95), -- Soft pastel blue
		["ROGUE"] = oUF:CreateColor(1.00, 0.90, 0.35), -- Softened golden yellow
		["SHAMAN"] = oUF:CreateColor(0.20, 0.35, 0.60), -- Deep muted blue
		["WARLOCK"] = oUF:CreateColor(0.55, 0.50, 0.75), -- Softened purple
		["WARRIOR"] = oUF:CreateColor(0.75, 0.55, 0.40), -- Earthy brown
		["UNKNOWN"] = oUF:CreateColor(0.70, 0.75, 0.80), -- Soft light gray
	}, { __index = class }),

	-- ---------------------------------------------------------------------------
	-- Renown & Standing Colors
	-- ---------------------------------------------------------------------------

	faction = setmetatable({
		[1] = oUF:CreateColor(0.75, 0.20, 0.20), -- 1: Soft red
		[2] = oUF:CreateColor(0.75, 0.20, 0.20), -- 2: Soft red (same as 1)
		[3] = oUF:CreateColor(0.70, 0.25, 0.00), -- 3: Muted orange
		[4] = oUF:CreateColor(0.90, 0.70, 0.10), -- 4: Soft golden yellow
		[5] = oUF:CreateColor(0.00, 0.55, 0.15), -- 5: Muted green
		[6] = oUF:CreateColor(0.00, 0.55, 0.15), -- 6: Muted green (same as 5)
		[7] = oUF:CreateColor(0.00, 0.55, 0.15), -- 7: Muted green (same as 5)
		[8] = oUF:CreateColor(0.00, 0.55, 0.15), -- 8: Muted green (same as 5)
		[9] = oUF:CreateColor(0.00, 0.55, 0.15), -- 9: Muted green (same as 5, Paragon)
		[10] = oUF:CreateColor(0.00, 0.70, 0.90), -- 10: Soft teal (Renown)
	}, { __index = faction }),
}, { __index = oUF.colors })
