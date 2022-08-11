local K = unpack(KkthnxUI)
local Module = K:GetModule("AurasTable")

if K.Class ~= "DRUID" then
	return
end

-- Druid's spell monitoring
local list = {
	["Player Aura"] = { -- Player Aura group
		{ AuraID = 5215, UnitID = "player" }, -- sneak
		{ AuraID = 1850, UnitID = "player" }, -- dash
		{ AuraID = 137452, UnitID = "player" }, -- wild displacement
		{ AuraID = 102416, UnitID = "player" }, -- Wild Charge: swimming speed
		{ AuraID = 774, UnitID = "player", Caster = "player" }, -- Rejuvenation
		{ AuraID = 8936, UnitID = "player", Caster = "player" }, -- heal
		{ AuraID = 33763, UnitID = "player", Caster = "player" }, -- Lifebloom
		{ AuraID = 188550, UnitID = "player", Caster = "player" }, -- Lifebloom, Orange
		{ AuraID = 48438, UnitID = "player", Caster = "player" }, -- wild growth
		{ AuraID = 102351, UnitID = "player", Caster = "player" }, -- Cenarion Ward
		{ AuraID = 155777, UnitID = "player", Caster = "player" }, -- sprout
	},
	["Target Aura"] = { -- target aura group
		{ AuraID = 99, UnitID = "target", Caster = "player" }, -- Incapacitating Roar
		{ AuraID = 339, UnitID = "target", Caster = "player" }, -- Entangling roots
		{ AuraID = 774, UnitID = "target", Caster = "player" }, -- Rejuvenation
		{ AuraID = 1079, UnitID = "target", Caster = "player" }, -- split
		{ AuraID = 5211, UnitID = "target", Caster = "player" }, -- Brute force punch
		{ AuraID = 6795, UnitID = "target", Caster = "player" }, -- growl
		{ AuraID = 8936, UnitID = "target", Caster = "player" }, -- heal
		{ AuraID = 50259, UnitID = "target", Caster = "player" }, -- Wild Charge: Stun
		{ AuraID = 45334, UnitID = "target", Caster = "player" }, -- Wild Charge: Immobilize
		{ AuraID = 33763, UnitID = "target", Caster = "player" }, -- lifebloom
		{ AuraID = 188550, UnitID = "target", Caster = "player" }, -- Lifebloom, Orange
		{ AuraID = 48438, UnitID = "target", Caster = "player" }, -- wild growth
		{ AuraID = 61391, UnitID = "target", Caster = "player" }, -- typhoon
		{ AuraID = 81261, UnitID = "target", Caster = "player" }, -- Sunlight
		{ AuraID = 155722, UnitID = "target", Caster = "player" }, -- Rake
		{ AuraID = 203123, UnitID = "target", Caster = "player" }, -- chop
		{ AuraID = 106830, UnitID = "target", Caster = "player" }, -- Thrash
		{ AuraID = 192090, UnitID = "target", Caster = "player" }, -- Thrash
		{ AuraID = 164812, UnitID = "target", Caster = "player" }, -- Moonfire
		{ AuraID = 155625, UnitID = "target", Caster = "player" }, -- Moonfire
		{ AuraID = 164815, UnitID = "target", Caster = "player" }, -- Sunfire
		{ AuraID = 102359, UnitID = "target", Caster = "player" }, -- mass wrap
		{ AuraID = 202347, UnitID = "target", Caster = "player" }, -- star flare
		{ AuraID = 127797, UnitID = "target", Caster = "player" }, -- Ursol Whirlwind
		{ AuraID = 208253, UnitID = "target", Caster = "player" }, -- Essence of Garnier
		{ AuraID = 155777, UnitID = "target", Caster = "player" }, -- sprout
		{ AuraID = 102342, UnitID = "target", Caster = "player" }, -- Ironwood Bark
		{ AuraID = 102351, UnitID = "target", Caster = "player" }, -- Cenarion Ward
		{ AuraID = 200389, UnitID = "target", Caster = "player" }, -- Cultivation
	},
	["Special Aura"] = { -- Player important aura group
		{ AuraID = 5217, UnitID = "player" }, -- Tiger's Fury
		{ AuraID = 48517, UnitID = "player" }, -- Eclipse
		{ AuraID = 48518, UnitID = "player" }, -- eclipse
		{ AuraID = 52610, UnitID = "player" }, -- Savage Roar
		{ AuraID = 69369, UnitID = "player" }, -- Swiftness of the Predator
		{ AuraID = 61336, UnitID = "player" }, -- survival instinct
		{ AuraID = 22842, UnitID = "player" }, -- Berserk reply
		{ AuraID = 93622, UnitID = "player" }, -- laceration
		{ AuraID = 22812, UnitID = "player" }, -- barkskin
		{ AuraID = 16870, UnitID = "player" }, -- energy-saving spellcasting
		{ AuraID = 135700, UnitID = "player" }, -- energy saving spellcasting
		{ AuraID = 106951, UnitID = "player" }, -- Rampage
		{ AuraID = 210649, UnitID = "player" }, -- wild instinct
		{ AuraID = 192081, UnitID = "player" }, -- Ironfur
		{ AuraID = 102560, UnitID = "player" }, -- avatar
		{ AuraID = 117679, UnitID = "player" }, -- avatar
		{ AuraID = 102558, UnitID = "player" }, -- avatar
		{ AuraID = 102543, UnitID = "player" }, -- avatar
		{ AuraID = 145152, UnitID = "player" }, -- Bloody Claw
		{ AuraID = 191034, UnitID = "player" }, -- Starfall
		{ AuraID = 194223, UnitID = "player" }, -- Aura of Aura
		{ AuraID = 200851, UnitID = "player" }, -- Wrath of the Sleeper
		{ AuraID = 213708, UnitID = "player" }, -- Guardian of the Galaxy
		{ AuraID = 213680, UnitID = "player" }, -- Guardian of Elune
		{ AuraID = 155835, UnitID = "player" }, -- the mane is standing on end
		{ AuraID = 114108, UnitID = "player" }, -- Soul of the Jungle
		{ AuraID = 207640, UnitID = "player" }, -- Abundance
		{ AuraID = 202425, UnitID = "player" }, -- Warrior of Elune
		{ AuraID = 232378, UnitID = "player" }, -- Astral Harmony, Milk Germany 2T19
		{ AuraID = 208253, UnitID = "player" }, -- Essence of Garnier, Artifact of Nyde
		{ AuraID = 157228, UnitID = "player" }, -- Wildkin Frenzy
		{ AuraID = 224706, UnitID = "player" }, -- Emerald Dreamcatcher
		{ AuraID = 242232, UnitID = "player" }, -- astral acceleration
		{ AuraID = 209406, UnitID = "player" }, -- Ounas's intuition
		{ AuraID = 209407, UnitID = "player" }, -- Ounas's conceit
		{ AuraID = 252752, UnitID = "player" }, -- T21 Wild Germany
		{ AuraID = 253434, UnitID = "player" }, -- T21 Naid
		{ AuraID = 252767, UnitID = "player" }, -- T21 Bird Germany
		{ AuraID = 253575, UnitID = "player" }, -- T21 Xiong De
		{ AuraID = 201671, UnitID = "player", Combat = true }, -- Bloodstained Fur
		{ AuraID = 203975, UnitID = "player", Combat = true }, -- Earth Guardian
		{ AuraID = 252216, UnitID = "player" }, -- tiger dash
		{ AuraID = 279709, UnitID = "player" }, -- Star Lord
		{ AuraID = 279943, UnitID = "player" }, -- sharp claws
		{ AuraID = 197721, UnitID = "player" }, -- flourish
	},
	["Focus Aura"] = { -- focus aura group
		{ AuraID = 774, UnitID = "focus", Caster = "player" }, -- Rejuvenation
		{ AuraID = 8936, UnitID = "focus", Caster = "player" }, -- heal
		{ AuraID = 33763, UnitID = "focus", Caster = "player" }, -- life bloom
		{ AuraID = 188550, UnitID = "focus", Caster = "player" }, -- lifebloom, orange
		{ AuraID = 155777, UnitID = "focus", Caster = "player" }, -- sprout
		{ AuraID = 164812, UnitID = "focus", Caster = "player" }, -- Moonfire
		{ AuraID = 164815, UnitID = "focus", Caster = "player" }, -- Sunfire
		{ AuraID = 202347, UnitID = "focus", Caster = "player" }, -- star flare
	},
	["Spell Cooldown"] = { -- Cooldown timer group
		{ SlotID = 13 }, -- trinket 1
		{ SlotID = 14 }, -- trinket 2
		{ SpellID = 61336 }, -- survival instinct
	},
}

Module:AddNewAuraWatch("DRUID", list)
