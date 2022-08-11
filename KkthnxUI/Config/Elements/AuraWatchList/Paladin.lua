local K = unpack(KkthnxUI)
local Module = K:GetModule("AurasTable")

if K.Class ~= "PALADIN" then
	return
end

-- Paladin's spell monitoring
local list = {
	["Player Aura"] = { -- Player Aura group
		{ AuraID = 188370, UnitID = "player" }, -- dedication
		{ AuraID = 197561, UnitID = "player" }, -- Avenger's Courage
		{ AuraID = 269571, UnitID = "player" }, -- frenzy
		{ AuraID = 114250, UnitID = "player" }, -- self-healing
		{ AuraID = 281178, UnitID = "player" }, -- Sword of Wrath
		{ AuraID = 182104, UnitID = "player" }, -- Shining Light
	},
	["Target Aura"] = { -- target aura group
		{ AuraID = 853, UnitID = "target", Caster = "player" }, -- Hammer of Justice
		{ AuraID = 31935, UnitID = "target", Caster = "player" }, -- Avenger's Shield
		{ AuraID = 53563, UnitID = "target", Caster = "player" }, -- Beacon of Light
		{ AuraID = 62124, UnitID = "target", Caster = "player" }, -- Hand of Reckoning
		{ AuraID = 156910, UnitID = "target", Caster = "player" }, -- Beacon of Faith
		{ AuraID = 183218, UnitID = "target", Caster = "player" }, -- Hand of Hindering
		{ AuraID = 197277, UnitID = "target", Caster = "player" }, -- trial
		{ AuraID = 214222, UnitID = "target", Caster = "player" }, -- trial
		{ AuraID = 205273, UnitID = "target", Caster = "player" }, -- Ashes Awakening
		{ AuraID = 105421, UnitID = "target", Caster = "player" }, -- Blind Light
		{ AuraID = 200654, UnitID = "target", Caster = "player" }, -- Tyr's deliverance
		{ AuraID = 223306, UnitID = "target", Caster = "player" }, -- grant faith
		{ AuraID = 196941, UnitID = "target", Caster = "player" }, -- Judgment of Light
		{ AuraID = 209202, UnitID = "target", Caster = "player" }, -- Eye of Tyr
		{ AuraID = 204301, UnitID = "target", Caster = "player" }, -- Blessed Shield
		{ AuraID = 204079, UnitID = "target", Caster = "player" }, -- Showdown
		{ AuraID = 343527, UnitID = "target", Caster = "player" }, -- execution trial
	},
	["Special Aura"] = { -- Player important aura group
		{ AuraID = 498, UnitID = "player" }, -- Divine Protection
		{ AuraID = 642, UnitID = "player" }, -- Divine Shield
		{ AuraID = 31821, UnitID = "player" }, -- Aura Mastery
		{ AuraID = 31884, UnitID = "player" }, -- Wrath of Vengeance
		{ AuraID = 31850, UnitID = "player" }, -- Fiery Defender
		{ AuraID = 54149, UnitID = "player" }, -- Infusion of Light
		{ AuraID = 86659, UnitID = "player" }, -- Guardian of the Ancient Kings
		{ AuraID = 231895, UnitID = "player" }, -- conquest
		{ AuraID = 223819, UnitID = "player" }, -- Divine Will
		{ AuraID = 209785, UnitID = "player" }, -- fire of justice
		{ AuraID = 217020, UnitID = "player" }, -- frenzy
		{ AuraID = 205191, UnitID = "player" }, -- eye for eye
		{ AuraID = 221885, UnitID = "player" }, -- Holy Colt
		{ AuraID = 200652, UnitID = "player" }, -- Tyr's deliverance
		{ AuraID = 214202, UnitID = "player" }, -- Law of the Law
		{ AuraID = 105809, UnitID = "player" }, -- Holy Avenger
		{ AuraID = 223316, UnitID = "player" }, -- Zealot Martyr
		{ AuraID = 200025, UnitID = "player" }, -- virtue sign
		{ AuraID = 132403, UnitID = "player" }, -- Shield of Justice
		{ AuraID = 152262, UnitID = "player" }, -- Seraph
		{ AuraID = 221883, UnitID = "player" }, -- Holy Colt
		{ AuraID = 184662, UnitID = "player", Value = true }, -- Shield of Vengeance
		{ AuraID = 209388, UnitID = "player", Value = true }, -- Bastion of Order
		{ AuraID = 267611, UnitID = "player" }, -- Justice Judgment
		{ AuraID = 271581, UnitID = "player" }, -- Divine Judgment
		{ AuraID = 84963, UnitID = "player" }, -- heresy verdict
		{ AuraID = 280375, UnitID = "player" }, -- multi-faceted defense
		{ AuraID = 216331, UnitID = "player" }, -- Avenging Crusader
		{ AuraID = 327225, UnitID = "player", Value = true }, -- Origin of Revenge
		{ AuraID = 327510, UnitID = "player", Flash = true }, -- shining light
	},
	["Focus Aura"] = { -- focus aura group
		{ AuraID = 53563, UnitID = "focus", Caster = "player" }, -- Beacon of Light
		{ AuraID = 156910, UnitID = "focus", Caster = "player" }, -- Beacon of Faith
	},
	["Spell Cooldown"] = { -- Cooldown timer group
		{ SlotID = 13 }, -- trinket 1
		{ SlotID = 14 }, -- trinket 2
		{ SpellID = 31884 }, -- Wrath of Vengeance
		{ SpellID = 31821 }, -- Aura Mastery
	},
}

Module:AddNewAuraWatch("PALADIN", list)
