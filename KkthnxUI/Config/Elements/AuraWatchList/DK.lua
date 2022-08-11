local K = unpack(KkthnxUI)
local Module = K:GetModule("AurasTable")

if K.Class ~= "DEATHKNIGHT" then
	return
end

-- DK's spell monitoring
local list = {
	["Player Aura"] = { -- Player Aura group
		{ AuraID = 3714, UnitID = "player" }, -- Path of Frost
		{ AuraID = 53365, UnitID = "player" }, -- Unholy Power
		{ AuraID = 59052, UnitID = "player" }, -- Hoarfrost
		{ AuraID = 81340, UnitID = "player" }, -- Sudden Doom
		{ AuraID = 111673, UnitID = "pet" }, -- control undead
		{ AuraID = 215377, UnitID = "player" }, -- hungry
		{ AuraID = 219788, UnitID = "player" }, -- where the bones are buried
	},
	["Target Aura"] = { -- target aura group
		{ AuraID = 55078, UnitID = "target", Caster = "player" }, -- Blood Plague
		{ AuraID = 55095, UnitID = "target", Caster = "player" }, -- Frost Blight
		{ AuraID = 56222, UnitID = "target", Caster = "player" }, -- Dark Command
		{ AuraID = 45524, UnitID = "target", Caster = "player" }, -- Frozen Chains
		{ AuraID = 191587, UnitID = "target", Caster = "player" }, -- vicious plague
		{ AuraID = 211793, UnitID = "target", Caster = "player" }, -- Cold Storage Severe Winter
		{ AuraID = 221562, UnitID = "target", Caster = "player" }, -- choking
		{ AuraID = 108194, UnitID = "target", Caster = "player" }, -- choking
		{ AuraID = 206940, UnitID = "target", Caster = "player" }, -- Bloodmark
		{ AuraID = 206977, UnitID = "target", Caster = "player" }, -- Blood Mirror
		{ AuraID = 207167, UnitID = "target", Caster = "player" }, -- Blinding Ice Rain
		{ AuraID = 194310, UnitID = "target", Caster = "player" }, -- Festering Wound
		{ AuraID = 156004, UnitID = "target", Caster = "player" }, -- profanity
		{ AuraID = 191748, UnitID = "target", Caster = "player" }, -- Calamity of the Realms
		{ AuraID = 312202, UnitID = "target", Caster = "player" }, -- Shackle of the Disqualified
	},
	["Special Aura"] = { -- Player important aura group
		{ AuraID = 63560, UnitID = "pet" }, -- dark mutation
		{ AuraID = 47568, UnitID = "player" }, -- Rune weapon boost
		{ AuraID = 49039, UnitID = "player" }, -- Lich Body
		{ AuraID = 81141, UnitID = "player" }, -- Scarlet Scourge
		{ AuraID = 48265, UnitID = "player" }, -- death footsteps
		{ AuraID = 55233, UnitID = "player" }, -- vampire blood
		{ AuraID = 48707, UnitID = "player" }, -- anti-magic shield
		{ AuraID = 81256, UnitID = "player" }, -- Rune Blade Dance
		{ AuraID = 48792, UnitID = "player" }, -- Frozen Fortitude
		{ AuraID = 51271, UnitID = "player" }, -- Pillar of Frost
		{ AuraID = 51124, UnitID = "player" }, -- killing machine
		{ AuraID = 51460, UnitID = "player" }, -- Runic Corruption
		{ AuraID = 195181, UnitID = "player" }, -- Bone Shield
		{ AuraID = 188290, UnitID = "player" }, -- wither and wither
		{ AuraID = 213003, UnitID = "player" }, -- Soul Eater
		{ AuraID = 194679, UnitID = "player" }, -- rune split
		{ AuraID = 194844, UnitID = "player", Flash = true }, -- Bonestorm
		{ AuraID = 207127, UnitID = "player" }, -- Rune Blade of Hunger
		{ AuraID = 207256, UnitID = "player" }, -- annihilation
		{ AuraID = 207319, UnitID = "player" }, -- Shield of Flesh
		{ AuraID = 218100, UnitID = "player" }, -- profanity
		{ AuraID = 196770, UnitID = "player" }, -- Cold Storage Severe Winter
		{ AuraID = 194879, UnitID = "player" }, -- Cold Claw
		{ AuraID = 211805, UnitID = "player" }, -- Storm convergence
		{ AuraID = 152279, UnitID = "player" }, -- Ice Dragon Breath
		{ AuraID = 235599, UnitID = "player" }, -- Grim Heart
		{ AuraID = 246995, UnitID = "player" }, -- Ghoul Master, 2T20
		{ AuraID = 193320, UnitID = "player", Value = true }, -- Eternal Umbilical Cord
		{ AuraID = 219809, UnitID = "player", Value = true }, -- headstone
		{ AuraID = 48743, UnitID = "player", Value = true }, -- Calamity Contract
		{ AuraID = 115989, UnitID = "player" }, -- Dark Swarm
		{ AuraID = 212552, UnitID = "player" }, -- phantom step
		{ AuraID = 207289, UnitID = "player" }, -- evil frenzy
		{ AuraID = 273947, UnitID = "player", Stack = 5, Flash = true }, -- blood confinement
		{ AuraID = 253595, UnitID = "player", Combat = true }, -- Cold Assault
		{ AuraID = 281209, UnitID = "player", Combat = true }, -- Grim Heart
		{ AuraID = 321995, UnitID = "player" }, -- Frost Rune Aura
	},
	["Focus Aura"] = { -- focus aura group
		{ AuraID = 55078, UnitID = "focus", Caster = "player" }, -- Blood Plague
		{ AuraID = 55095, UnitID = "focus", Caster = "player" }, -- Frost Blight
		{ AuraID = 191587, UnitID = "focus", Caster = "player" }, -- vicious plague
	},
	["Spell Cooldown"] = { -- Cooldown timer group
		{ SlotID = 13 }, -- trinket 1
		{ SlotID = 14 }, -- trinket 2
		{ SpellID = 48792 }, -- Frozen Fortitude
		{ SpellID = 49206 }, -- Summons the Gargoyle
	},
}

Module:AddNewAuraWatch("DEATHKNIGHT", list)
