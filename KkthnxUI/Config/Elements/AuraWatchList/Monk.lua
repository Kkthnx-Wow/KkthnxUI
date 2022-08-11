local K = unpack(KkthnxUI)
local Module = K:GetModule("AurasTable")

if K.Class ~= "MONK" then
	return
end

-- Monk's spell monitoring
local list = {
	["Player Aura"] = { -- Player Aura group
		{ AuraID = 119085, UnitID = "player" }, -- infuriating burst
		{ AuraID = 101643, UnitID = "player" }, -- Soul dual
		{ AuraID = 202090, UnitID = "player" }, -- Teachings of the Zen Temple
		{ AuraID = 119611, UnitID = "player" }, -- Renewing Mist
		{ AuraID = 195381, UnitID = "player" }, -- Healing Wind
		{ AuraID = 213177, UnitID = "player" }, -- Lee Seok Daekawa
		{ AuraID = 199407, UnitID = "player" }, -- light feet
	},
	["Target Aura"] = { -- target aura group
		{ AuraID = 115078, UnitID = "target", Caster = "player" }, -- Disjointed
		{ AuraID = 116189, UnitID = "target", Caster = "player" }, -- Haozhen Bafang
		{ AuraID = 115804, UnitID = "target", Caster = "player" }, -- lethal wound
		{ AuraID = 115080, UnitID = "target", Caster = "player" }, -- Touch of Samsara
		{ AuraID = 123586, UnitID = "target", Caster = "player" }, -- Serpent in the sky
		{ AuraID = 116706, UnitID = "target", Caster = "player" }, -- King Kong Zhen
		{ AuraID = 205320, UnitID = "target", Caster = "player" }, -- Strike of the Wind Lord
		{ AuraID = 116841, UnitID = "target", Caster = "player" }, -- Swift as a tiger
		{ AuraID = 119381, UnitID = "target", Caster = "player" }, -- sweep the hall
		{ AuraID = 116844, UnitID = "target", Caster = "player" }, -- Ring of Peace
		{ AuraID = 121253, UnitID = "target", Caster = "player" }, -- Drunk Caster
		{ AuraID = 214326, UnitID = "target", Caster = "player" }, -- explode the barrel
		{ AuraID = 123725, UnitID = "target", Caster = "player" }, -- Breath of Fire
		{ AuraID = 116849, UnitID = "target", Caster = "player" }, -- cocoon life
		{ AuraID = 119611, UnitID = "target", Caster = "player" }, -- Mist of Resurrection
		{ AuraID = 191840, UnitID = "target", Caster = "player" }, -- Essence Fountain
		{ AuraID = 198909, UnitID = "target", Caster = "player" }, -- Song of Chi-Ji
		{ AuraID = 124682, UnitID = "target", Caster = "player" }, -- Dense Mist
	},
	["Special Aura"] = { -- Player important aura group
		{ AuraID = 125174, UnitID = "player" }, -- Touch of Karma
		{ AuraID = 116768, UnitID = "player" }, -- blackout kick
		{ AuraID = 137639, UnitID = "player" }, -- Fire and Thunder
		{ AuraID = 122278, UnitID = "player" }, -- body is not bad
		{ AuraID = 122783, UnitID = "player" }, -- Dispel Magic
		{ AuraID = 116844, UnitID = "player" }, -- Ring of Peace
		{ AuraID = 152173, UnitID = "player" }, -- hold your breath
		{ AuraID = 120954, UnitID = "player" }, -- Fortifying Brew
		{ AuraID = 243435, UnitID = "player" }, -- Fortifying Brew
		{ AuraID = 215479, UnitID = "player" }, -- Iron Bone Brew
		{ AuraID = 214373, UnitID = "player" }, -- the wine has a lingering fragrance
		{ AuraID = 199888, UnitID = "player" }, -- Dragon Mist
		{ AuraID = 116680, UnitID = "player" }, -- Lightning Tea
		{ AuraID = 197908, UnitID = "player" }, -- mana tea
		{ AuraID = 196741, UnitID = "player" }, -- combo
		{ AuraID = 228563, UnitID = "player" }, -- blackout combo
		{ AuraID = 197916, UnitID = "player" }, -- endlessly
		{ AuraID = 197919, UnitID = "player" }, -- endlessly
		{ AuraID = 116841, UnitID = "player" }, -- Swift as a tiger
		{ AuraID = 195321, UnitID = "player" }, -- transform power
		{ AuraID = 213341, UnitID = "player" }, -- bold
		{ AuraID = 235054, UnitID = "player" }, -- Emperor's Capacitive Leather Armor
		{ AuraID = 124682, UnitID = "player", Caster = "player" }, -- Dense Mist
		{ AuraID = 261769, UnitID = "player" }, -- Iron Shirt
		{ AuraID = 195630, UnitID = "player" }, -- Drunken Master
		{ AuraID = 115295, UnitID = "player", Value = true }, -- golden bell
		{ AuraID = 116847, UnitID = "player" }, -- Jasper Wind
		{ AuraID = 322507, UnitID = "player", Value = true }, -- Celestial Wine
		{ AuraID = 325092, UnitID = "player" }, -- Purify True Qi
	},
	["Focus Aura"] = { -- focus aura group
		{ AuraID = 115078, UnitID = "focus", Caster = "player" }, -- Distraction
		{ AuraID = 119611, UnitID = "focus", Caster = "player" }, -- Resurrection Mist
	},
	["Spell Cooldown"] = { -- Cooldown timer group
		{ SlotID = 13 }, -- trinket 1
		{ SlotID = 14 }, -- trinket 2
		{ SpellID = 115203 }, -- Fortifying Brew
	},
}

Module:AddNewAuraWatch("MONK", list)
