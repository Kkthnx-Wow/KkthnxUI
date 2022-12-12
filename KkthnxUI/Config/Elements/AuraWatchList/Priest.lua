local K = unpack(KkthnxUI)
local Module = K:GetModule("AurasTable")

if K.Class ~= "PRIEST" then
	return
end

local list = {
	["Player Aura"] = {
		{ AuraID = 586, UnitID = "player" },
		{ AuraID = 45242, UnitID = "player" },
		{ AuraID = 121557, UnitID = "player" },
		{ AuraID = 194022, UnitID = "player" },
		{ AuraID = 214121, UnitID = "player" },
	},
	["Target Aura"] = {
		{ AuraID = 139, UnitID = "target", Caster = "player" },
		{ AuraID = 589, UnitID = "target", Caster = "player" },
		{ AuraID = 8122, UnitID = "target", Caster = "player" },
		{ AuraID = 15487, UnitID = "target", Caster = "player" },
		{ AuraID = 34914, UnitID = "target", Caster = "player" },
		{ AuraID = 41635, UnitID = "target", Caster = "player" },
		{ AuraID = 205369, UnitID = "target", Caster = "player" },
		{ AuraID = 217673, UnitID = "target", Caster = "player" },
		{ AuraID = 208065, UnitID = "target", Caster = "player" },
		{ AuraID = 200196, UnitID = "target", Caster = "player" },
		{ AuraID = 200200, UnitID = "target", Caster = "player" },
		{ AuraID = 214121, UnitID = "target", Caster = "player" },
		{ AuraID = 121557, UnitID = "target", Caster = "player" },
		{ AuraID = 204263, UnitID = "target", Caster = "player" },
		{ AuraID = 194384, UnitID = "target", Caster = "player" },
		{ AuraID = 214621, UnitID = "target", Caster = "player" },
		{ AuraID = 152118, UnitID = "target", Caster = "player" },
		{ AuraID = 204213, UnitID = "target", Caster = "player" },
		{ AuraID = 335467, UnitID = "target", Caster = "player" },
		{ AuraID = 323673, UnitID = "target", Caster = "player" },
		{ AuraID = 342132, UnitID = "target", Caster = "player" },
		{ AuraID = 325203, UnitID = "target", Caster = "player" },
		{ AuraID = 17, UnitID = "target", Caster = "player", Value = true },
		{ AuraID = 208772, UnitID = "target", Caster = "player", Value = true },
		{ AuraID = 271466, UnitID = "target", Caster = "player", Value = true },
	},
	["Special Aura"] = {
		{ AuraID = 17, UnitID = "player", Caster = "player" },
		{ AuraID = 194384, UnitID = "player", Caster = "player" },
		{ AuraID = 27827, UnitID = "player" },
		{ AuraID = 47536, UnitID = "player" },
		{ AuraID = 65081, UnitID = "player" },
		{ AuraID = 47585, UnitID = "player" },
		{ AuraID = 15286, UnitID = "player" },
		{ AuraID = 197937, UnitID = "player" },
		{ AuraID = 194249, UnitID = "player" },
		{ AuraID = 205372, UnitID = "player" },
		{ AuraID = 193223, UnitID = "player" },
		{ AuraID = 196490, UnitID = "player" },
		{ AuraID = 114255, UnitID = "player" },
		{ AuraID = 196644, UnitID = "player" },
		{ AuraID = 197030, UnitID = "player" },
		{ AuraID = 200183, UnitID = "player" },
		{ AuraID = 197763, UnitID = "player" },
		{ AuraID = 198069, UnitID = "player" },
		{ AuraID = 123254, UnitID = "player" },
		{ AuraID = 211440, UnitID = "player" },
		{ AuraID = 211442, UnitID = "player" },
		{ AuraID = 252848, UnitID = "player" },
		{ AuraID = 253437, UnitID = "player" },
		{ AuraID = 253443, UnitID = "player" },
		{ AuraID = 216135, UnitID = "player" },
		{ AuraID = 271466, UnitID = "player" },
		{ AuraID = 124430, UnitID = "player" },
		{ AuraID = 197871, UnitID = "player" },
	},
	["Focus Aura"] = {
		{ AuraID = 139, UnitID = "focus", Caster = "player" },
	},
	["Spell Cooldown"] = {
		{ SlotID = 13 },
		{ SlotID = 14 },
		{ SpellID = 64843 },
		{ SpellID = 33206 },
	},
}

Module:AddNewAuraWatch("PRIEST", list)
