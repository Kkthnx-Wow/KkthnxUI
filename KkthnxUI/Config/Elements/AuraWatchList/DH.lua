local K = unpack(KkthnxUI)
local Module = K:GetModule("AurasTable")

if K.Class ~= "DEMONHUNTER" then
	return
end

-- DH's spell monitoring
local list = {
	["Player Aura"] = { -- Player Aura group
		{ AuraID = 207693, UnitID = "player" }, -- Soul Feast
	},
	["Target Aura"] = { -- target aura group
		{ AuraID = 198813, UnitID = "target", Caster = "player" }, -- revenge avoidance
		{ AuraID = 179057, UnitID = "target", Caster = "player" }, -- Chaos Nova
		{ AuraID = 207690, UnitID = "target", Caster = "player" }, -- blood drop
		{ AuraID = 206491, UnitID = "target", Caster = "player" }, -- Nemesis
		{ AuraID = 213405, UnitID = "target", Caster = "player" }, -- Warglaive Master
		{ AuraID = 185245, UnitID = "target", Caster = "player" }, -- torture
		{ AuraID = 204490, UnitID = "target", Caster = "player" }, -- Silence Charm
		{ AuraID = 204598, UnitID = "target", Caster = "player" }, -- Flame Charm
		{ AuraID = 204843, UnitID = "target", Caster = "player" }, -- Chain Charm
		{ AuraID = 207407, UnitID = "target", Caster = "player" }, -- Soul Slice
		{ AuraID = 207744, UnitID = "target", Caster = "player" }, -- Fire Brand
		{ AuraID = 207771, UnitID = "target", Caster = "player" }, -- Fire Brand
		{ AuraID = 224509, UnitID = "target", Caster = "player" }, -- ghost bomb
		{ AuraID = 210003, UnitID = "target", Caster = "player" }, -- sharp thorn
		{ AuraID = 207685, UnitID = "target", Caster = "player" }, -- spell of misery
		{ AuraID = 211881, UnitID = "target", Caster = "player" }, -- Fel Burst
		{ AuraID = 247456, UnitID = "target", Caster = "player" }, -- vulnerable
		{ AuraID = 258860, UnitID = "target", Caster = "player" }, -- Dark Flay
		{ AuraID = 268178, UnitID = "target", Caster = "player" }, -- Void Reaver
		{ AuraID = 323802, UnitID = "target", Caster = "player" }, -- Demon Chase
		{ AuraID = 317009, UnitID = "target", Caster = "player" }, -- Brand of Sin
	},
	["Special Aura"] = { -- Player important aura group
		{ AuraID = 162264, UnitID = "player" }, -- Metamorphosis
		{ AuraID = 187827, UnitID = "player" }, -- Metamorphosis
		{ AuraID = 188501, UnitID = "player" }, -- ghost vision
		{ AuraID = 212800, UnitID = "player" }, -- Swift Shadow
		{ AuraID = 203650, UnitID = "player" }, -- ready
		{ AuraID = 196555, UnitID = "player" }, -- Voidwalk
		{ AuraID = 208628, UnitID = "player" }, -- the momentum
		{ AuraID = 247938, UnitID = "player" }, -- Chaos Blade
		{ AuraID = 188499, UnitID = "player" }, -- Blade Dance
		{ AuraID = 210152, UnitID = "player" }, -- Blade Dance
		{ AuraID = 207693, UnitID = "player" }, -- Soul Feast
		{ AuraID = 203819, UnitID = "player" }, -- Demon Spike
		{ AuraID = 212988, UnitID = "player" }, -- Painbringer
		{ AuraID = 208579, UnitID = "player" }, -- Nemesis
		{ AuraID = 208605, UnitID = "player" }, -- Nemesis
		{ AuraID = 208607, UnitID = "player" }, -- Nemesis
		{ AuraID = 208608, UnitID = "player" }, -- Nemesis
		{ AuraID = 208609, UnitID = "player" }, -- Nemesis
		{ AuraID = 208610, UnitID = "player" }, -- Nemesis
		{ AuraID = 208611, UnitID = "player" }, -- Nemesis
		{ AuraID = 208612, UnitID = "player" }, -- Nemesis
		{ AuraID = 208613, UnitID = "player" }, -- Nemesis
		{ AuraID = 208614, UnitID = "player" }, -- Nemesis
		{ AuraID = 247253, UnitID = "player" }, -- blade twist
		{ AuraID = 252165, UnitID = "player" }, -- Havoc T21
		{ AuraID = 216758, UnitID = "player" }, -- Endless Vampire
		{ AuraID = 263648, UnitID = "player", Value = true }, -- Soul Barrier
		{ AuraID = 218561, UnitID = "player", Value = true }, -- siphon energy
		{ AuraID = 258920, UnitID = "player" }, -- sacrificial aura
		{ AuraID = 343312, UnitID = "player" }, -- Furious Gaze
		{ AuraID = 203981, UnitID = "player", Combat = true }, -- Soul Fragment
	},
	["Focus Aura"] = { -- focus aura group
	},
	["Spell Cooldown"] = { -- Cooldown timer group
		{ SlotID = 13 }, -- trinket 1
		{ SlotID = 14 }, -- trinket 2
		{ SpellID = 191427 }, -- Metamorphosis
		{ SpellID = 187827 }, -- Metamorphosis
	},
}

Module:AddNewAuraWatch("DEMONHUNTER", list)
