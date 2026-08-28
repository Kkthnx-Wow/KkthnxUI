--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/UnitFrames/Colors.lua
	Purpose:
		Our own power and reaction palette, applied over the oUF colour tables so
		every health bar coloured by reaction and every power bar (unit frames and
		nameplates) uses them. Values live in the config so they can be tuned from
		the GUI. K.ApplyUnitColors re-reads them.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

local oUF = K.oUF
local colors = oUF and oUF.colors
if not colors then
	return
end

local pairs = pairs
local Enum = Enum

-- Custom class colours, harmonised for the dark slate theme (mage locked to the
-- #5C8BCF accent). Applied over the oUF class table and exposed as K.ClassColors.
local CLASS = {
	DEATHKNIGHT = { 0.77, 0.12, 0.23 },
	DEMONHUNTER = { 0.64, 0.19, 0.79 },
	DRUID = { 1.00, 0.49, 0.04 },
	EVOKER = { 0.20, 0.58, 0.50 },
	HUNTER = { 0.67, 0.83, 0.45 },
	MAGE = { 0.36, 0.55, 0.81 },
	MONK = { 0.00, 1.00, 0.60 },
	PALADIN = { 0.96, 0.55, 0.73 },
	PRIEST = { 0.90, 0.92, 0.96 },
	ROGUE = { 0.96, 0.85, 0.41 },
	SHAMAN = { 0.00, 0.44, 0.87 },
	WARLOCK = { 0.53, 0.47, 0.84 },
	WARRIOR = { 0.78, 0.61, 0.43 },
}
K.ClassColors = CLASS

-- Power tokens mapped to their numeric PowerType, so both the string lookup oUF
-- does first and the numeric fallback point at our colour.
local POWER_INDEX = {
	MANA = Enum.PowerType.Mana,
	RAGE = Enum.PowerType.Rage,
	FOCUS = Enum.PowerType.Focus,
	ENERGY = Enum.PowerType.Energy,
	RUNIC_POWER = Enum.PowerType.RunicPower,
	LUNAR_POWER = Enum.PowerType.LunarPower,
	MAELSTROM = Enum.PowerType.Maelstrom,
	INSANITY = Enum.PowerType.Insanity,
	FURY = Enum.PowerType.Fury,
	PAIN = Enum.PowerType.Pain,
}

function K.ApplyUnitColors()
	local db = C.Unitframe
	if not db then
		return
	end

	if db.PowerColors then
		for token, c in pairs(db.PowerColors) do
			local color = oUF:CreateColor(c[1], c[2], c[3])
			colors.power[token] = color
			local index = POWER_INDEX[token]
			if index then
				colors.power[index] = color
			end
		end
	end

	if db.ReactionColors then
		for i, c in pairs(db.ReactionColors) do
			colors.reaction[i] = oUF:CreateColor(c[1], c[2], c[3])
		end
	end

	-- Class colours for players on every frame and nameplate.
	for token, c in pairs(CLASS) do
		colors.class[token] = oUF:CreateColor(c[1], c[2], c[3])
	end

	-- Keep the player's own accent (used by chat, AFK screen, etc.) in sync.
	local mine = CLASS[K.Class]
	if mine then
		K.ClassColor = { r = mine[1], g = mine[2], b = mine[3] }
	end
end
