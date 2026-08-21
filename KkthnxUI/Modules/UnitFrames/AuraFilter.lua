--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/UnitFrames/AuraFilter.lua
	Purpose:
		Which debuff schools the player's class can remove. Used by the group
		dispel highlight. The old whitelist/blacklist aura filters were retired
		when auras moved to Blizzard's CustomAuraContainer on 12.1 (it filters by
		its own filter strings / candidate filters, not our tables), leaving this
		class-dispel lookup as the only piece still needed.
-----------------------------------------------------------------------------]]

local K = KkthnxUI[1]

-- Which debuff schools each class can remove from a friendly unit. A base table
-- (spec nuances aside) good enough to drive the dispel highlight.
local CLASS_DISPEL = {
	PRIEST = { Magic = true, Disease = true },
	PALADIN = { Magic = true, Poison = true, Disease = true },
	SHAMAN = { Magic = true, Curse = true },
	DRUID = { Curse = true, Poison = true, Magic = true },
	MAGE = { Curse = true },
	MONK = { Magic = true, Poison = true, Disease = true },
	EVOKER = { Magic = true, Poison = true, Curse = true },
	WARLOCK = { Magic = true },
}
K.CanDispel = CLASS_DISPEL[K.Class] or {}
