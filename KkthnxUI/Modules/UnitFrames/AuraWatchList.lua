--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/UnitFrames/AuraWatchList.lua
	Purpose:
		The default tracked auras for the corner Aura Watch on party and raid
		frames. Keyed by class, then by spell id. Each entry places a small dot
		or icon in one corner of the frame so a healer can read their own heals
		over time at a glance.

		Entry fields:
			corner - "TOPLEFT" | "TOPRIGHT" | "BOTTOMLEFT" | "BOTTOMRIGHT" | "CENTER"
			color  - dot colour {r, g, b} (dot style only)
			style  - "dot" (default) or "icon" (shows the spell icon and its swipe)
			mine   - true to only light up when the aura is ours

		These are sensible starting points. The list lives in one table so it is
		easy to extend per class without touching the element code.
-----------------------------------------------------------------------------]]

local K = KkthnxUI[1]

-- Shorthand dot colours so the table below reads cleanly.
local GREEN = { 0.4, 0.85, 0.4 }
local BLUE = { 0.4, 0.7, 1 }
local GOLD = { 0.95, 0.75, 0.35 }
local PINK = { 0.95, 0.5, 0.75 }
local TEAL = { 0.35, 0.85, 0.8 }

K.AuraWatchList = {
	DRUID = {
		[774] = { corner = "TOPLEFT", color = GREEN, mine = true }, -- Rejuvenation
		[8936] = { corner = "TOPRIGHT", color = GOLD, mine = true }, -- Regrowth
		[33763] = { corner = "BOTTOMLEFT", color = TEAL, mine = true }, -- Lifebloom
		[48438] = { corner = "BOTTOMRIGHT", color = BLUE, mine = true }, -- Wild Growth
	},
	PRIEST = {
		[139] = { corner = "TOPLEFT", color = GREEN, mine = true }, -- Renew
		[17] = { corner = "TOPRIGHT", color = GOLD, mine = true }, -- Power Word: Shield
		[41635] = { corner = "BOTTOMLEFT", color = BLUE, mine = true }, -- Prayer of Mending
		[194384] = { corner = "BOTTOMRIGHT", color = PINK, mine = true }, -- Atonement
	},
	SHAMAN = {
		[61295] = { corner = "TOPLEFT", color = BLUE, mine = true }, -- Riptide
		[974] = { corner = "TOPRIGHT", color = GOLD, mine = true }, -- Earth Shield
	},
	PALADIN = {
		[53563] = { corner = "TOPLEFT", color = GOLD, mine = true }, -- Beacon of Light
		[156910] = { corner = "TOPRIGHT", color = GOLD, mine = true }, -- Beacon of Faith
	},
	MONK = {
		[119611] = { corner = "TOPLEFT", color = TEAL, mine = true }, -- Renewing Mist
		[124682] = { corner = "TOPRIGHT", color = GREEN, mine = true }, -- Enveloping Mist
	},
	EVOKER = {
		[366155] = { corner = "TOPLEFT", color = BLUE, mine = true }, -- Reversion
		[364343] = { corner = "TOPRIGHT", color = PINK, mine = true }, -- Echo
	},
}

-- The active list for the player's class, or an empty table for classes with no
-- defaults, so the element can index it without a nil check.
K.AuraWatch = K.AuraWatchList[K.Class] or {}
