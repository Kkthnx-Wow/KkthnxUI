local K = unpack(KkthnxUI)
local Module = K:GetModule("AurasTable")

if K.Class ~= "PRIEST" then
	return
end

-- Priest's spell monitoring
local list = {
	["Player Aura"] = { -- Player Aura group
		{ AuraID = 586, UnitID = "player" }, -- fade
		{ AuraID = 45242, UnitID = "player" }, -- focus will
		{ AuraID = 121557, UnitID = "player" }, -- Feather of Heaven
		{ AuraID = 194022, UnitID = "player" }, -- strong willed
		{ AuraID = 214121, UnitID = "player" }, -- Unity of mind and body
	},
	["Target Aura"] = { -- target aura group
		{ AuraID = 139, UnitID = "target", Caster = "player" }, -- restore
		{ AuraID = 589, UnitID = "target", Caster = "player" }, -- Shadow Word: Pain
		{ AuraID = 8122, UnitID = "target", Caster = "player" }, -- Mind Scream
		{ AuraID = 15487, UnitID = "target", Caster = "player" }, -- silence
		{ AuraID = 34914, UnitID = "target", Caster = "player" }, -- Vampire Touch
		{ AuraID = 41635, UnitID = "target", Caster = "player" }, -- prayer of healing
		{ AuraID = 205369, UnitID = "target", Caster = "player" }, -- mind bomb
		{ AuraID = 217673, UnitID = "target", Caster = "player" }, -- Mind Spike
		{ AuraID = 208065, UnitID = "target", Caster = "player" }, -- Light of Toure
		{ AuraID = 200196, UnitID = "target", Caster = "player" }, -- Holy Word: Punishment
		{ AuraID = 200200, UnitID = "target", Caster = "player" }, -- Holy Word: Punishment
		{ AuraID = 214121, UnitID = "target", Caster = "player" }, -- Oneness of mind and body
		{ AuraID = 121557, UnitID = "target", Caster = "player" }, -- Feather of Heaven
		{ AuraID = 204263, UnitID = "target", Caster = "player" }, -- Flash field
		{ AuraID = 194384, UnitID = "target", Caster = "player" }, -- redemption
		{ AuraID = 214621, UnitID = "target", Caster = "player" }, -- sectarian differences
		{ AuraID = 152118, UnitID = "target", Caster = "player" }, -- will insight
		{ AuraID = 204213, UnitID = "target", Caster = "player" }, -- purify evil
		{ AuraID = 335467, UnitID = "target", Caster = "player" }, -- Devouring Plague
		{ AuraID = 323673, UnitID = "target", Caster = "player" }, -- mind control
		{ AuraID = 342132, UnitID = "target", Caster = "player" }, -- Wrathful Night
		{ AuraID = 325203, UnitID = "target", Caster = "player" }, -- Unholy Infusion
		{ AuraID = 17, UnitID = "target", Caster = "player", Value = true }, -- Power Word: Shield
		{ AuraID = 208772, UnitID = "target", Caster = "player", Value = true }, -- Smite
		{ AuraID = 271466, UnitID = "target", Caster = "player", Value = true }, -- Shimmer Barrier
	},
	["Special Aura"] = { -- Player important aura group
		{ AuraID = 17, UnitID = "player", Caster = "player" }, -- Power Word: Shield
		{ AuraID = 194384, UnitID = "player", Caster = "player" }, -- redemption
		{ AuraID = 27827, UnitID = "player" }, -- Soul of Redemption
		{ AuraID = 47536, UnitID = "player" }, -- full attention
		{ AuraID = 65081, UnitID = "player" }, -- Unity of mind and body
		{ AuraID = 47585, UnitID = "player" }, -- dissipate
		{ AuraID = 15286, UnitID = "player" }, -- Vampire's Embrace
		{ AuraID = 197937, UnitID = "player" }, -- lingering frenzy
		{ AuraID = 194249, UnitID = "player" }, -- Voidform
		{ AuraID = 205372, UnitID = "player" }, -- Void Ray
		{ AuraID = 193223, UnitID = "player" }, -- insane
		{ AuraID = 196490, UnitID = "player" }, -- Power of the Naaru
		{ AuraID = 114255, UnitID = "player" }, -- Surge of Light
		{ AuraID = 196644, UnitID = "player" }, -- Toure's blessing
		{ AuraID = 197030, UnitID = "player" }, -- holy
		{ AuraID = 200183, UnitID = "player" }, -- Divine Avatar
		{ AuraID = 197763, UnitID = "player" }, -- race against time
		{ AuraID = 198069, UnitID = "player" }, -- power of the dark side
		{ AuraID = 123254, UnitID = "player" }, -- ill-fated
		{ AuraID = 211440, UnitID = "player" }, -- Faun Artifact
		{ AuraID = 211442, UnitID = "player" }, -- Faun Artifact
		{ AuraID = 252848, UnitID = "player" }, -- T21 Discipline
		{ AuraID = 253437, UnitID = "player" }, -- T21 Holy 2
		{ AuraID = 253443, UnitID = "player" }, -- T21 Holy 4
		{ AuraID = 216135, UnitID = "player" }, -- Robe of Commandments
		{ AuraID = 271466, UnitID = "player" }, -- twilight barrier
		{ AuraID = 124430, UnitID = "player" }, -- Shadow Insight
		{ AuraID = 197871, UnitID = "player" }, -- Dark Archangel
	},
	["Focus Aura"] = { -- focus aura group
		{ AuraID = 139, UnitID = "focus", Caster = "player" }, -- resume
	},
	["Spell Cooldown"] = { -- Cooldown timer group
		{ SlotID = 13 }, -- trinket 1
		{ SlotID = 14 }, -- trinket 2
		{ SpellID = 64843 }, -- Holy Hymn
		{ SpellID = 33206 }, -- Pain Suppression
	},
}

Module:AddNewAuraWatch("PRIEST", list)
