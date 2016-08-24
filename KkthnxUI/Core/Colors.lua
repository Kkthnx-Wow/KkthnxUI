local K, C, _ = select(2, ...):unpack()

local _G = _G
local hooksecurefunc = hooksecurefunc
local UnitPowerType = UnitPowerType

BETTER_DISCONNECTED_COLORS = {
	0.1, 0.1, 0.1
}

BETTER_REACTION_COLORS = {
	[1] = { 0.87, 0.37, 0.37 }, -- Hated
	[2] = { 0.87, 0.37, 0.37 }, -- Hostile
	[3] = { 0.87, 0.37, 0.37 }, -- Unfriendly
	[4] = { 0.85, 0.77, 0.36 }, -- Neutral
	[5] = { 0.29, 0.67, 0.30 }, -- Friendly
	[6] = { 0.29, 0.67, 0.30 }, -- Honored
	[7] = { 0.29, 0.67, 0.30 }, -- Revered
	[8] = { 0.29, 0.67, 0.30 }, -- Exalted
}

-- CLASS COLORS
BETTER_RAID_CLASS_COLORS = {
	["DEATHKNIGHT"] = { 0.77, 0.12, 0.24 },
	["DRUID"]       = { 1.00, 0.49, 0.03 },
	["HUNTER"]      = { 0.67, 0.84, 0.45 },
	["MAGE"]        = { 0.41, 0.80, 1.00 },
	["PALADIN"]     = { 0.96, 0.55, 0.73 },
	["PRIEST"]      = { 0.83, 0.83, 0.83 },
	["ROGUE"]       = { 1.00, 0.95, 0.32 },
	["SHAMAN"]      = { 0.16, 0.31, 0.61 },
	["WARLOCK"]     = { 0.58, 0.51, 0.79 },
	["WARRIOR"]     = { 0.78, 0.61, 0.43 },
	["MONK"]        = { 0.00, 1.00, 0.59 },
	["DEMONHUNTER"] = { 0.64, 0.19, 0.79 },
}

BETTER_POWERBAR_COLORS = {
	["MANA"]              = {0.31, 0.45, 0.63},
	["INSANITY"]          = {0.40, 0.00, 0.80},
	["MAELSTROM"]         = {0.00, 0.50, 1.00},
	["LUNAR_POWER"]       = {0.93, 0.51, 0.93},
	["HOLY_POWER"]        = {0.95, 0.90, 0.60},
	["RAGE"]              = {0.69, 0.31, 0.31},
	["FOCUS"]             = {0.71, 0.43, 0.27},
	["ENERGY"]            = {0.65, 0.63, 0.35},
	["CHI"]               = {0.71, 1.00, 0.92},
	["RUNES"]             = {0.55, 0.57, 0.61},
	["SOUL_SHARDS"]       = {0.50, 0.32, 0.55},
	["FURY"]              = {0.78, 0.26, 0.99},
	["PAIN"]              = {1.00, 0.61, 0.00},
	["RUNIC_POWER"]       = {0.00, 0.82, 1.00},
	["AMMOSLOT"]          = {0.80, 0.60, 0.00},
	["FUEL"]              = {0.00, 0.55, 0.50},
	["POWER_TYPE_STEAM"]  = {0.55, 0.57, 0.61},
	["POWER_TYPE_PYRITE"] = {0.60, 0.09, 0.17},
	["ALTPOWER"]          = {0.00, 1.00, 1.00},
}

--[[ CUSTOM POWER COLORS
if C.Unitframe.BetterPowerColors == true then
	_G.PowerBarColor["MANA"] = {r = 79/255, g = 115/255, b = 161/255}
	_G.PowerBarColor["RAGE"] = {r = 199/255, g = 64/255, b = 64/255}
	_G.PowerBarColor["FOCUS"] = {r = 181/255, g = 110/255, b = 69/255}
	_G.PowerBarColor["ENERGY"] = {r = 166/255, g = 161/255, b = 89/255}
	_G.PowerBarColor["RUNIC_POWER"] = {r = 0/255, g = 209/255, b = 255/255}
	_G.PowerBarColor["PAIN"] = {r = 225/255, g = 225/255, b = 225/255}
	_G.PowerBarColor["FURY"] = {r = 227/255, g = 126/255, b = 39/255}
	_G.PowerBarColor["LUNAR_POWER"] = {r = 230/255, g = 219/255, b = 31/255}
	_G.PowerBarColor["INSANITY"] = {r = 140/255, g = 36/255, b = 176/255}
	_G.PowerBarColor["MAELSTROM"] = {r = 0/255, g = 128/255, b = 255/255}
end
]]--

if C.Unitframe.BetterPowerColors == true then
	local function CustomPowerColor(manaBar)
		local powerType = UnitPowerType(manaBar.unit)

		if (powerType == 0) then -- MANA
			manaBar:SetStatusBarColor(79/255, 115/255, 161/255)
		elseif (powerType == 1) then -- RAGE WARRIORS AND DRUID
			manaBar:SetStatusBarColor(199/255, 64/255, 64/255)
		elseif (powerType == 2) then -- FOCUS HUNTER
			manaBar:SetStatusBarColor(181/255, 110/255, 69/255)
		elseif (powerType == 3) then -- ENERGY ROGUE, MONK, AND DRUID
			manaBar:SetStatusBarColor(166/255, 161/255, 89/255)
		elseif (powerType == 6) then -- RUNIC POWER DEATH KNIGHT
			manaBar:SetStatusBarColor(0/255, 209/255, 255/255)
		elseif (powerType == 8) then -- ASTRAL POWER DRUID
			manaBar:SetStatusBarColor(0/255, 219/255, 31/255)
		elseif (powerType == 11) then -- MAELSTROM SHAMAN
			manaBar:SetStatusBarColor(0/255, 128/255, 255/255)
		elseif (powerType == 13) then -- INSANITY SHADOW PRIEST
			manaBar:SetStatusBarColor(140/255, 36/255, 176/255)
		elseif (powerType == 17) then -- VENGEANCE DEMON HUNTER
			manaBar:SetStatusBarColor(227/255, 126/255, 39/255)
		elseif (powerType == 18) then -- HAVOC DEMON HUNTER
			manaBar:SetStatusBarColor(225/255, 225/255, 225/255)
		end
	end

	hooksecurefunc("UnitFrameManaBar_UpdateType", CustomPowerColor)
end