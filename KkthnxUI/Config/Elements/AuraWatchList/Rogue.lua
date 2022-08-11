local K, _, L = unpack(KkthnxUI)
local Module = K:GetModule("AurasTable")

if K.Class ~= "ROGUE" then
	return
end

-- Rogue's spell monitoring
local list = {
	["Player Aura"] = { -- Player Aura group
		{ AuraID = 1784, UnitID = "player" }, -- sneak
		{ AuraID = 115191, UnitID = "player" }, -- sneak
		{ AuraID = 2983, UnitID = "player" }, -- sprint
		{ AuraID = 36554, UnitID = "player" }, -- shadow step
		{ AuraID = 197603, UnitID = "player" }, -- Embrace of Darkness
		{ AuraID = 270070, UnitID = "player" }, -- Hidden Blade
	},
	["Target Aura"] = { -- target aura group
		{ AuraID = 408, UnitID = "target", Caster = "player" }, -- kidney shot
		{ AuraID = 703, UnitID = "target", Caster = "player" }, -- throat lock
		{ AuraID = 1833, UnitID = "target", Caster = "player" }, -- sneak attack
		{ AuraID = 6770, UnitID = "target", Caster = "player" }, -- sap
		{ AuraID = 2094, UnitID = "target", Caster = "player" }, -- blind
		{ AuraID = 1330, UnitID = "target", Caster = "player" }, -- throat lock
		{ AuraID = 1776, UnitID = "target", Caster = "player" }, -- Gouge
		{ AuraID = 1943, UnitID = "target", Caster = "player" }, -- split
		{ AuraID = 79140, UnitID = "target", Caster = "player" }, -- old enemy
		{ AuraID = 16511, UnitID = "target", Caster = "player" }, -- bleeding
		{ AuraID = 192759, UnitID = "target", Caster = "player" }, -- Calamity of the King
		{ AuraID = 192425, UnitID = "target", Caster = "player" }, -- Toxin Impulse
		{ AuraID = 200803, UnitID = "target", Caster = "player" }, -- Painful Venom
		{ AuraID = 137619, UnitID = "target", Caster = "player" }, -- death marker
		{ AuraID = 195452, UnitID = "target", Caster = "player" }, -- Nightblade
		{ AuraID = 209786, UnitID = "target", Caster = "player" }, -- Redmaw's Bite
		{ AuraID = 196958, UnitID = "target", Caster = "player" }, -- Shadow Strike
		{ AuraID = 196937, UnitID = "target", Caster = "player" }, -- ghost attack
		{ AuraID = 192925, UnitID = "target", Caster = "player" }, -- blood of the assassin
		{ AuraID = 245389, UnitID = "target", Caster = "player" }, -- Venomous Blade
		{ AuraID = 121411, UnitID = "target", Caster = "player" }, -- Crimson Storm
		{ AuraID = 255909, UnitID = "target", Caster = "player" }, -- bullying
		{ AuraID = 316220, UnitID = "target", Caster = "player" }, -- Insight into weaknesses
		{ AuraID = 315341, UnitID = "target", Caster = "player" }, -- center eyebrow
		{ AuraID = 328305, UnitID = "target", Caster = "player" }, -- Septic Blade
		{ AuraID = 323654, UnitID = "target", Caster = "player" }, -- Flagellation
		{ AuraID = 324073, UnitID = "target", Caster = "player" }, -- serrated spur
	},
	["Special Aura"] = { -- Player important aura group
		{ AuraID = 1966, UnitID = "player" }, -- feint
		{ AuraID = 5171, UnitID = "player" }, -- cut
		{ AuraID = 5277, UnitID = "player" }, -- dodge
		{ AuraID = 11327, UnitID = "player" }, -- disappear
		{ AuraID = 13750, UnitID = "player" }, -- impulse
		{ AuraID = 13877, UnitID = "player" }, -- Blade Flurry
		{ AuraID = 31224, UnitID = "player" }, -- Shadow Cloak
		{ AuraID = 32645, UnitID = "player" }, -- Poison
		{ AuraID = 45182, UnitID = "player" }, -- play dead
		{ AuraID = 31665, UnitID = "player" }, -- Master Keen
		{ AuraID = 185311, UnitID = "player" }, -- Crimson Vial
		{ AuraID = 193641, UnitID = "player" }, -- forethought
		{ AuraID = 115192, UnitID = "player" }, -- deceit
		{ AuraID = 193538, UnitID = "player" }, -- keen
		{ AuraID = 121471, UnitID = "player" }, -- Shadowblade
		{ AuraID = 185422, UnitID = "player" }, -- shadow dance
		{ AuraID = 212283, UnitID = "player" }, -- death marker
		{ AuraID = 202754, UnitID = "player" }, -- Stealth Blade
		{ AuraID = 193356, UnitID = "player", Text = L["Combo"] }, -- strong combo, dice
		{ AuraID = 193357, UnitID = "player", Text = L["Crit"] }, -- Shark surge, dice
		{ AuraID = 193358, UnitID = "player", Text = L["AttackSpeed"] }, -- ARAM, dice
		{ AuraID = 193359, UnitID = "player", Text = L["CD"] }, -- two-handed, dice
		{ AuraID = 199603, UnitID = "player", Text = L["Strike"] }, -- skeleton black sail, dice
		{ AuraID = 199600, UnitID = "player", Text = L["Power"] }, -- buried treasure, dice
		{ AuraID = 202665, UnitID = "player" }, -- Dreadblade Curse
		{ AuraID = 199754, UnitID = "player" }, -- fight back
		{ AuraID = 195627, UnitID = "player" }, -- opportunity
		{ AuraID = 121153, UnitID = "player" }, -- side attack
		{ AuraID = 256735, UnitID = "player", Combat = true }, -- Master Assassin
		{ AuraID = 271896, UnitID = "player" }, -- Blade Dash
		{ AuraID = 51690, UnitID = "player" }, -- shadow dance
		{ AuraID = 277925, UnitID = "player" }, -- Hidden Blade Whirlwind
		{ AuraID = 196980, UnitID = "player" }, -- Shadow Master
		{ AuraID = 315496, UnitID = "player" }, -- cut
		{ AuraID = 343142, UnitID = "player" }, -- Dreadblade
	},
	["Focus Aura"] = { -- focus aura group
		{ AuraID = 6770, UnitID = "focus", Caster = "player" }, -- sap
		{ AuraID = 2094, UnitID = "focus", Caster = "player" }, -- blind
	},
	["Spell Cooldown"] = { -- Cooldown timer group
		{ SlotID = 13 }, -- trinket 1
		{ SlotID = 14 }, -- trinket 2
		{ SpellID = 13750 }, -- impulsive
		{ SpellID = 79140 }, -- old enemy
		{ SpellID = 121471 }, -- Shadowblade
	},
}

Module:AddNewAuraWatch("ROGUE", list)
