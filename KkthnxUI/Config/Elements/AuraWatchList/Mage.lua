local K = unpack(KkthnxUI)
local Module = K:GetModule("AurasTable")

if K.Class ~= "MAGE" then
	return
end

-- Mage's spell monitoring
local list = {
	["Player Aura"] = { -- Player Aura group
		{ AuraID = 130, UnitID = "player" }, -- slow down
		{ AuraID = 32612, UnitID = "player" }, -- invisibility
		{ AuraID = 87023, UnitID = "player" }, -- cautery
		{ AuraID = 11426, UnitID = "player" }, -- Frost Armor
		{ AuraID = 235313, UnitID = "player" }, -- Flame Shield
		{ AuraID = 235450, UnitID = "player" }, -- Prismatic Barrier
		{ AuraID = 110960, UnitID = "player" }, -- Enhanced Invisibility
		{ AuraID = 157644, UnitID = "player" }, -- Enhanced Fireworks
	},
	["Target Aura"] = { -- target aura group
		{ AuraID = 118, UnitID = "target", Caster = "player" }, -- Polymorph
		{ AuraID = 122, UnitID = "target", Caster = "player" }, -- Frost Nova
		{ AuraID = 12654, UnitID = "target", Caster = "player" }, -- Ignite
		{ AuraID = 11366, UnitID = "target", Caster = "player" }, -- Pyroblast
		{ AuraID = 31661, UnitID = "target", Caster = "player" }, -- Dragon's Breath
		{ AuraID = 82691, UnitID = "target", Caster = "player" }, -- Ring of Frost
		{ AuraID = 31589, UnitID = "target", Caster = "player" }, -- slow down
		{ AuraID = 33395, UnitID = "target", Caster = "pet" }, -- Freeze
		{ AuraID = 28271, UnitID = "target", Caster = "player" }, -- Polymorph
		{ AuraID = 28272, UnitID = "target", Caster = "player" }, -- Polymorph
		{ AuraID = 61305, UnitID = "target", Caster = "player" }, -- Polymorph
		{ AuraID = 61721, UnitID = "target", Caster = "player" }, -- Polymorph
		{ AuraID = 61780, UnitID = "target", Caster = "player" }, -- Polymorph
		{ AuraID = 126819, UnitID = "target", Caster = "player" }, -- Polymorph
		{ AuraID = 161353, UnitID = "target", Caster = "player" }, -- Polymorph
		{ AuraID = 161354, UnitID = "target", Caster = "player" }, -- Polymorph
		{ AuraID = 161355, UnitID = "target", Caster = "player" }, -- Polymorph
		{ AuraID = 161372, UnitID = "target", Caster = "player" }, -- Polymorph
		{ AuraID = 157981, UnitID = "target", Caster = "player" }, -- shockwave
		{ AuraID = 217694, UnitID = "target", Caster = "player" }, -- active bomb
		{ AuraID = 114923, UnitID = "target", Caster = "player" }, -- Netherstorm
		{ AuraID = 205708, UnitID = "target", Caster = "player" }, -- Frostbolt
		{ AuraID = 212792, UnitID = "target", Caster = "player" }, -- pick of ice
		{ AuraID = 157997, UnitID = "target", Caster = "player" }, -- Ice Nova
		{ AuraID = 210134, UnitID = "target", Caster = "player" }, -- Arcane Corruption
		{ AuraID = 199786, UnitID = "target", Caster = "player" }, -- Glacial Spike
		{ AuraID = 210824, UnitID = "target", Caster = "player" }, -- Touch of the Archmage
		{ AuraID = 307443, UnitID = "target", Caster = "player" }, -- Destruction Spark
		{ AuraID = 314793, UnitID = "target", Caster = "player" }, -- Mirror of Torment
	},
	["Special Aura"] = { -- Player important aura group
		{ AuraID = 66, UnitID = "player" }, -- invisibility
		{ AuraID = 45438, UnitID = "player" }, -- Ice Barrier
		{ AuraID = 36032, UnitID = "player" }, -- Arcane Charge
		{ AuraID = 12042, UnitID = "player" }, -- Arcane Augment
		{ AuraID = 12472, UnitID = "player" }, -- icy blood
		{ AuraID = 44544, UnitID = "player" }, -- Fingers of Frost
		{ AuraID = 48108, UnitID = "player" }, -- Pyroblast!
		{ AuraID = 48107, UnitID = "player" }, -- heat burst
		{ AuraID = 108843, UnitID = "player" }, -- Fiery Speed
		{ AuraID = 116267, UnitID = "player" }, -- torrent of conjuration
		{ AuraID = 116014, UnitID = "player" }, -- energy rune
		{ AuraID = 108839, UnitID = "player" }, -- ice floes
		{ AuraID = 205025, UnitID = "player" }, -- calm down
		{ AuraID = 113862, UnitID = "player" }, -- Enhanced Invisibility
		{ AuraID = 194329, UnitID = "player" }, -- Blazing Curse
		{ AuraID = 190319, UnitID = "player" }, -- burn
		{ AuraID = 212799, UnitID = "player" }, -- permutation
		{ AuraID = 198924, UnitID = "player" }, -- speed up
		{ AuraID = 205473, UnitID = "player" }, -- Ice Spike
		{ AuraID = 205766, UnitID = "player" }, -- Biting Chill
		{ AuraID = 209455, UnitID = "player" }, -- Kael'thas' trick, sorry bracers
		{ AuraID = 263725, UnitID = "player" }, -- energy saving spellcasting
		{ AuraID = 264774, UnitID = "player" }, -- Rule of Three
		{ AuraID = 269651, UnitID = "player" }, -- Fire Crash
		{ AuraID = 190446, UnitID = "player" }, -- Cold Wisdom
		{ AuraID = 321363, UnitID = "player" }, -- focus magic
		{ AuraID = 324220, UnitID = "player" }, -- body of death
	},
	["Focus Aura"] = { -- focus aura group
		{ AuraID = 44457, UnitID = "focus", Caster = "player" }, -- active bomb
		{ AuraID = 114923, UnitID = "focus", Caster = "player" }, -- Netherstorm
	},
	["Spell Cooldown"] = { -- Cooldown timer group
		{ SlotID = 13 }, -- trinket 1
		{ SlotID = 14 }, -- trinket 2
		{ TotemID = 1 }, -- energy rune
		{ SpellID = 12472 }, -- icy blood
		{ SpellID = 12042 }, -- Arcane Enhancement
		{ SpellID = 190319 }, -- burn
	},
}

Module:AddNewAuraWatch("MAGE", list)
