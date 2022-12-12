local K = unpack(KkthnxUI)
local Module = K:GetModule("AurasTable")

if K.Class ~= "PALADIN" then
	return
end

local list = {
	["Player Aura"] = {
		{ AuraID = 188370, UnitID = "player" },
		{ AuraID = 197561, UnitID = "player" },
		{ AuraID = 269571, UnitID = "player" },
		{ AuraID = 114250, UnitID = "player" },
		{ AuraID = 281178, UnitID = "player" },
		{ AuraID = 182104, UnitID = "player" },
	},
	["Target Aura"] = {
		{ AuraID = 853, UnitID = "target", Caster = "player" },
		{ AuraID = 31935, UnitID = "target", Caster = "player" },
		{ AuraID = 53563, UnitID = "target", Caster = "player" },
		{ AuraID = 62124, UnitID = "target", Caster = "player" },
		{ AuraID = 156910, UnitID = "target", Caster = "player" },
		{ AuraID = 183218, UnitID = "target", Caster = "player" },
		{ AuraID = 197277, UnitID = "target", Caster = "player" },
		{ AuraID = 214222, UnitID = "target", Caster = "player" },
		{ AuraID = 205273, UnitID = "target", Caster = "player" },
		{ AuraID = 105421, UnitID = "target", Caster = "player" },
		{ AuraID = 200654, UnitID = "target", Caster = "player" },
		{ AuraID = 223306, UnitID = "target", Caster = "player" },
		{ AuraID = 196941, UnitID = "target", Caster = "player" },
		{ AuraID = 209202, UnitID = "target", Caster = "player" },
		{ AuraID = 204301, UnitID = "target", Caster = "player" },
		{ AuraID = 204079, UnitID = "target", Caster = "player" },
		{ AuraID = 343527, UnitID = "target", Caster = "player" },
	},
	["Special Aura"] = {
		{ AuraID = 498, UnitID = "player" },
		{ AuraID = 642, UnitID = "player" },
		{ AuraID = 31821, UnitID = "player" },
		{ AuraID = 31884, UnitID = "player" },
		{ AuraID = 31850, UnitID = "player" },
		{ AuraID = 54149, UnitID = "player" },
		{ AuraID = 86659, UnitID = "player" },
		{ AuraID = 231895, UnitID = "player" },
		{ AuraID = 223819, UnitID = "player" },
		{ AuraID = 209785, UnitID = "player" },
		{ AuraID = 217020, UnitID = "player" },
		{ AuraID = 205191, UnitID = "player" },
		{ AuraID = 221885, UnitID = "player" },
		{ AuraID = 200652, UnitID = "player" },
		{ AuraID = 214202, UnitID = "player" },
		{ AuraID = 105809, UnitID = "player" },
		{ AuraID = 223316, UnitID = "player" },
		{ AuraID = 200025, UnitID = "player" },
		{ AuraID = 132403, UnitID = "player" },
		{ AuraID = 152262, UnitID = "player" },
		{ AuraID = 221883, UnitID = "player" },
		{ AuraID = 184662, UnitID = "player", Value = true },
		{ AuraID = 209388, UnitID = "player", Value = true },
		{ AuraID = 267611, UnitID = "player" },
		{ AuraID = 271581, UnitID = "player" },
		{ AuraID = 84963, UnitID = "player" },
		{ AuraID = 280375, UnitID = "player" },
		{ AuraID = 216331, UnitID = "player" },
		{ AuraID = 327225, UnitID = "player", Value = true },
		{ AuraID = 327510, UnitID = "player", Flash = true },
	},
	["Focus Aura"] = {
		{ AuraID = 53563, UnitID = "focus", Caster = "player" },
		{ AuraID = 156910, UnitID = "focus", Caster = "player" },
	},
	["Spell Cooldown"] = {
		{ SlotID = 13 },
		{ SlotID = 14 },
		{ SpellID = 31884 },
		{ SpellID = 31821 },
	},
}

Module:AddNewAuraWatch("PALADIN", list)
