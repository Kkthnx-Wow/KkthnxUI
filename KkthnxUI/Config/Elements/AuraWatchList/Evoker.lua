local K = KkthnxUI[1]
local Module = K:GetModule("AurasTable")

if K.Class ~= "EVOKER" then
	return
end

local list = {
	["Player Aura"] = {
		{ AuraID = 370454, UnitID = "player" },
		{ AuraID = 370840, UnitID = "player" },
	},
	["Target Aura"] = {
		{ AuraID = 355689, UnitID = "target", Caster = "player" },
		{ AuraID = 372048, UnitID = "target", Caster = "player" },
		{ AuraID = 370452, UnitID = "target", Caster = "player" },
	},
	["Special Aura"] = {
		{ AuraID = 358267, UnitID = "player" },
		{ AuraID = 375087, UnitID = "player" },
		{ AuraID = 374348, UnitID = "player" },
		{ AuraID = 359618, UnitID = "player" },
		{ AuraID = 369299, UnitID = "player" },
		{ AuraID = 363916, UnitID = "player" },
		{ AuraID = 386353, UnitID = "player" },
		{ AuraID = 386399, UnitID = "player" },
		{ AuraID = 370553, UnitID = "player", Flash = true },
		{ AuraID = 370818, UnitID = "player", Flash = true },
		{ AuraID = 362877, UnitID = "player", Stack = 3 },
		{ AuraID = 370537, UnitID = "player", Flash = true },
		{ AuraID = 371877, UnitID = "player", Value = true },
	},
	["Focus Aura"] = {},
	["Spell Cooldown"] = {
		{ SlotID = 13 },
		{ SlotID = 14 },
	},
}

Module:AddNewAuraWatch("EVOKER", list)
