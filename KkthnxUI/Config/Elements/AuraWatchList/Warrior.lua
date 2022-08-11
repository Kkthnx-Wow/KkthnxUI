local K = unpack(KkthnxUI)
local Module = K:GetModule("AurasTable")

if K.Class ~= "WARRIOR" then
	return
end

-- Warrior's spell monitoring
local list = {
	["Player Aura"] = { -- Player Aura group
		{ AuraID = 32216, UnitID = "player" }, -- victory
		{ AuraID = 202602, UnitID = "player" }, -- into battle
		{ AuraID = 200954, UnitID = "player" }, -- war scar
		{ AuraID = 202573, UnitID = "player" }, -- revenge
		{ AuraID = 202574, UnitID = "player" }, -- revenge
	},
	["Target Aura"] = { -- target aura group
		{ AuraID = 355, UnitID = "target", Caster = "player" }, -- taunt
		{ AuraID = 772, UnitID = "target", Caster = "player" }, -- tear
		{ AuraID = 1715, UnitID = "target", Caster = "player" }, -- broken tendon
		{ AuraID = 1160, UnitID = "target", Caster = "player" }, -- Demoralizing Shout
		{ AuraID = 6343, UnitID = "target", Caster = "player" }, -- Thunder Clap
		{ AuraID = 5246, UnitID = "target", Caster = "player" }, -- break the guts
		{ AuraID = 12323, UnitID = "target", Caster = "player" }, -- piercing roar
		{ AuraID = 105771, UnitID = "target", Caster = "player" }, -- Charge: Immobilize
		{ AuraID = 132169, UnitID = "target", Caster = "player" }, -- Storm Hammer
		{ AuraID = 132168, UnitID = "target", Caster = "player" }, -- Shockwave
		{ AuraID = 208086, UnitID = "target", Caster = "player" }, -- Giant Strike
		{ AuraID = 115804, UnitID = "target", Caster = "player" }, -- lethal
		{ AuraID = 280773, UnitID = "target", Caster = "player" }, -- Citybreaker
		{ AuraID = 317491, UnitID = "target", Caster = "player", Value = true }, -- guilty
	},
	["Special Aura"] = { -- Player important aura group
		{ AuraID = 871, UnitID = "player" }, -- shield wall
		{ AuraID = 1719, UnitID = "player" }, -- Battlecry
		{ AuraID = 7384, UnitID = "player", Stack = 2, Flash = true }, -- suppress
		{ AuraID = 12975, UnitID = "player" }, -- Break the boat
		{ AuraID = 85739, UnitID = "player" }, -- Flesh Cleave
		{ AuraID = 46924, UnitID = "player" }, -- Bladestorm
		{ AuraID = 227847, UnitID = "player" }, -- Bladestorm
		{ AuraID = 23920, UnitID = "player" }, -- Spell Reflection
		{ AuraID = 18499, UnitID = "player" }, -- Rampage Fury
		{ AuraID = 52437, UnitID = "player" }, -- sudden death
		{ AuraID = 188783, UnitID = "player" }, -- power of vrykul
		{ AuraID = 207982, UnitID = "player" }, -- focus of rage
		{ AuraID = 132404, UnitID = "player" }, -- shield block
		{ AuraID = 202289, UnitID = "player" }, -- Rampage Revival
		{ AuraID = 107574, UnitID = "player" }, -- God descends
		{ AuraID = 202164, UnitID = "player" }, -- Prancing steps
		{ AuraID = 152277, UnitID = "player" }, -- spoiler
		{ AuraID = 184362, UnitID = "player" }, -- enrage
		{ AuraID = 200953, UnitID = "player" }, -- Rampage
		{ AuraID = 184364, UnitID = "player" }, -- Berserk reply
		{ AuraID = 200986, UnitID = "player" }, -- Warrior of Odin
		{ AuraID = 206333, UnitID = "player" }, -- bloody smell
		{ AuraID = 215570, UnitID = "player" }, -- Destruction
		{ AuraID = 202225, UnitID = "player" }, -- Furious Charge
		{ AuraID = 215572, UnitID = "player" }, -- Riot Berserker
		{ AuraID = 213284, UnitID = "player" }, -- meat grinder
		{ AuraID = 202539, UnitID = "player" }, -- frenzy
		{ AuraID = 118000, UnitID = "player" }, -- Dragon's Roar
		{ AuraID = 209706, UnitID = "player" }, -- smash defense
		{ AuraID = 197690, UnitID = "player" }, -- defensive stance
		{ AuraID = 118038, UnitID = "player" }, -- the sword is in the person
		{ AuraID = 201009, UnitID = "player" }, -- master
		{ AuraID = 225947, UnitID = "player" }, -- Heart of Stone (Orange Ring)
		{ AuraID = 203581, UnitID = "player" }, -- dragon scale
		{ AuraID = 227744, UnitID = "player" }, -- spoiler
		{ AuraID = 209484, UnitID = "player" }, -- tactical advantage
		{ AuraID = 248625, UnitID = "player" }, -- smash defense
		{ AuraID = 248622, UnitID = "player" }, -- Heart attack
		{ AuraID = 190456, UnitID = "player", Value = true }, -- ignore pain
		{ AuraID = 260708, UnitID = "player" }, -- sweep attack
		{ AuraID = 262228, UnitID = "player" }, -- fatal calm
	},
	["Focus Aura"] = { -- focus aura group
		{ AuraID = 772, UnitID = "focus", Caster = "player" }, -- tear
		{ AuraID = 115767, UnitID = "focus", Caster = "player" }, -- serious injury
	},
	["Spell Cooldown"] = { -- Cooldown timer group
		{ SlotID = 13 }, -- trinket 1
		{ SlotID = 14 }, -- trinket 2
	},
}

Module:AddNewAuraWatch("WARRIOR", list)
