local K = unpack(KkthnxUI)
local Module = K:GetModule("AurasTable")

if K.Class ~= "MONK" then
	return
end

local list = {
	["Player Aura"] = {
		{ AuraID = 119085, UnitID = "player" },
		{ AuraID = 101643, UnitID = "player" },
		{ AuraID = 202090, UnitID = "player" },
		{ AuraID = 119611, UnitID = "player" },
		{ AuraID = 195381, UnitID = "player" },
		{ AuraID = 213177, UnitID = "player" },
		{ AuraID = 199407, UnitID = "player" },
	},
	["Target Aura"] = {
		{ AuraID = 115078, UnitID = "target", Caster = "player" },
		{ AuraID = 116189, UnitID = "target", Caster = "player" },
		{ AuraID = 115804, UnitID = "target", Caster = "player" },
		{ AuraID = 115080, UnitID = "target", Caster = "player" },
		{ AuraID = 123586, UnitID = "target", Caster = "player" },
		{ AuraID = 116706, UnitID = "target", Caster = "player" },
		{ AuraID = 205320, UnitID = "target", Caster = "player" },
		{ AuraID = 116841, UnitID = "target", Caster = "player" },
		{ AuraID = 119381, UnitID = "target", Caster = "player" },
		{ AuraID = 116844, UnitID = "target", Caster = "player" },
		{ AuraID = 121253, UnitID = "target", Caster = "player" },
		{ AuraID = 214326, UnitID = "target", Caster = "player" },
		{ AuraID = 123725, UnitID = "target", Caster = "player" },
		{ AuraID = 116849, UnitID = "target", Caster = "player" },
		{ AuraID = 119611, UnitID = "target", Caster = "player" },
		{ AuraID = 191840, UnitID = "target", Caster = "player" },
		{ AuraID = 198909, UnitID = "target", Caster = "player" },
		{ AuraID = 124682, UnitID = "target", Caster = "player" },
	},
	["Special Aura"] = {
		{ AuraID = 125174, UnitID = "player" },
		{ AuraID = 116768, UnitID = "player" },
		{ AuraID = 137639, UnitID = "player" },
		{ AuraID = 122278, UnitID = "player" },
		{ AuraID = 122783, UnitID = "player" },
		{ AuraID = 116844, UnitID = "player" },
		{ AuraID = 152173, UnitID = "player" },
		{ AuraID = 120954, UnitID = "player" },
		{ AuraID = 243435, UnitID = "player" },
		{ AuraID = 215479, UnitID = "player" },
		{ AuraID = 214373, UnitID = "player" },
		{ AuraID = 199888, UnitID = "player" },
		{ AuraID = 116680, UnitID = "player" },
		{ AuraID = 197908, UnitID = "player" },
		{ AuraID = 196741, UnitID = "player" },
		{ AuraID = 228563, UnitID = "player" },
		{ AuraID = 197916, UnitID = "player" },
		{ AuraID = 197919, UnitID = "player" },
		{ AuraID = 116841, UnitID = "player" },
		{ AuraID = 195321, UnitID = "player" },
		{ AuraID = 213341, UnitID = "player" },
		{ AuraID = 235054, UnitID = "player" },
		{ AuraID = 124682, UnitID = "player", Caster = "player" },
		{ AuraID = 261769, UnitID = "player" },
		{ AuraID = 195630, UnitID = "player" },
		{ AuraID = 115295, UnitID = "player", Value = true },
		{ AuraID = 116847, UnitID = "player" },
		{ AuraID = 322507, UnitID = "player", Value = true },
		{ AuraID = 325092, UnitID = "player" },
	},
	["Focus Aura"] = {
		{ AuraID = 115078, UnitID = "focus", Caster = "player" },
		{ AuraID = 119611, UnitID = "focus", Caster = "player" },
	},
	["Spell Cooldown"] = {
		{ SlotID = 13 },
		{ SlotID = 14 },
		{ SpellID = 115203 },
	},
}

Module:AddNewAuraWatch("MONK", list)
