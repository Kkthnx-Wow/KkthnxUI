local K = unpack(KkthnxUI)
local Module = K:GetModule("AurasTable")

if K.Class ~= "WARLOCK" then
	return
end

-- Warlock's spell monitoring
local list = {
	["Player Aura"] = { -- Player Aura group
		{ AuraID = 5697, UnitID = "player" }, -- Endless Breath
		{ AuraID = 48018, UnitID = "player" }, -- Demonic Circle
		{ AuraID = 108366, UnitID = "player" }, -- soul extraction
		{ AuraID = 119899, UnitID = "player" }, -- burn the master
		{ AuraID = 196099, UnitID = "player" }, -- tome of sacrifice
	},
	["Target Aura"] = { -- target aura group
		{ AuraID = 603, UnitID = "target", Caster = "player" }, -- Doomsday
		{ AuraID = 980, UnitID = "target", Caster = "player" }, -- pain
		{ AuraID = 710, UnitID = "target", Caster = "player" }, -- Banish
		{ AuraID = 6358, UnitID = "target", Caster = "pet" }, -- charm
		{ AuraID = 89766, UnitID = "target", Caster = "pet" }, -- great axe throw
		{ AuraID = 6789, UnitID = "target", Caster = "player" }, -- Death Coil
		{ AuraID = 5484, UnitID = "target", Caster = "player" }, -- howl of terror
		{ AuraID = 27243, UnitID = "target", Caster = "player" }, -- Seed of Corruption
		{ AuraID = 17877, UnitID = "target", Caster = "player" }, -- Shadowburn
		{ AuraID = 48181, UnitID = "target", Caster = "player" }, -- haunted
		{ AuraID = 63106, UnitID = "target", Caster = "player" }, -- Life Siphon
		{ AuraID = 30283, UnitID = "target", Caster = "player" }, -- Shadowfury
		{ AuraID = 32390, UnitID = "target", Caster = "player" }, -- Shadow Embrace
		{ AuraID = 80240, UnitID = "target", Caster = "player" }, -- Havoc
		{ AuraID = 146739, UnitID = "target", Caster = "player" }, -- Corruption
		{ AuraID = 316099, UnitID = "target", Caster = "player" }, -- misery
		{ AuraID = 342938, UnitID = "target", Caster = "player" }, -- Unstable Pain (PVP Spread Pain)
		{ AuraID = 118699, UnitID = "target", Caster = "player" }, -- fear
		{ AuraID = 205181, UnitID = "target", Caster = "player" }, -- Shadowflame
		{ AuraID = 157736, UnitID = "target", Caster = "player" }, -- sacrifice
		{ AuraID = 196414, UnitID = "target", Caster = "player" }, -- eradicate
		{ AuraID = 199890, UnitID = "target", Caster = "player" }, -- language curse
		{ AuraID = 199892, UnitID = "target", Caster = "player" }, -- Curse of Weakness
		{ AuraID = 270569, UnitID = "target", Caster = "player" }, -- from shadow
		{ AuraID = 278350, UnitID = "target", Caster = "player" }, -- evil pollution
		{ AuraID = 205179, UnitID = "target", Caster = "player" }, -- spooky ghost
		{ AuraID = 265931, UnitID = "target", Caster = "player" }, -- burn
		{ AuraID = 312321, UnitID = "target", Caster = "player" }, -- Consecrated Souls
		{ AuraID = 325640, UnitID = "target", Caster = "player" }, -- Soul Corruption
		{ AuraID = 322170, UnitID = "target", Caster = "player" }, -- disaster strikes
	},
	["Special Aura"] = { -- Player important aura group
		{ AuraID = 89751, UnitID = "pet" }, -- Felstorm
		{ AuraID = 216695, UnitID = "player" }, -- Tormented Soul
		{ AuraID = 104773, UnitID = "player" }, -- Undying Resolve
		{ AuraID = 199281, UnitID = "player" }, -- pain after pain
		{ AuraID = 196606, UnitID = "player" }, -- Inspired by Shadows
		{ AuraID = 111400, UnitID = "player" }, -- explosive dash
		{ AuraID = 115831, UnitID = "pet" }, -- Storm of Fury
		{ AuraID = 193396, UnitID = "pet" }, -- Demon Amplification
		{ AuraID = 117828, UnitID = "player" }, -- detonation
		{ AuraID = 196098, UnitID = "player" }, -- Soul Harvest
		{ AuraID = 205146, UnitID = "player" }, -- Demonic Omen
		{ AuraID = 216708, UnitID = "player" }, -- Headwind Reaper
		{ AuraID = 235156, UnitID = "player" }, -- Enhanced life splitting
		{ AuraID = 108416, UnitID = "player", Value = true }, -- Dark Pact
		{ AuraID = 264173, UnitID = "player" }, -- Demon Core
		{ AuraID = 265273, UnitID = "player" }, -- Demon Power
		{ AuraID = 212295, UnitID = "player" }, -- Void Guard
		{ AuraID = 267218, UnitID = "player" }, -- Void Portal
		{ AuraID = 113858, UnitID = "player" }, -- Dark Souls: Unrest
		{ AuraID = 113860, UnitID = "player" }, -- Dark Souls: Lamentation
		{ AuraID = 264571, UnitID = "player" }, -- Nightfall
		{ AuraID = 266030, UnitID = "player" }, -- entropy can be reversed
	},
	["Focus Aura"] = { -- focus aura group
		{ AuraID = 980, UnitID = "focus", Caster = "player" }, -- pain
		{ AuraID = 146739, UnitID = "focus", Caster = "player" }, -- Corruption
		{ AuraID = 233490, UnitID = "focus", Caster = "player" }, -- misery
		{ AuraID = 233496, UnitID = "focus", Caster = "player" }, -- misery
		{ AuraID = 233497, UnitID = "focus", Caster = "player" }, -- misery
		{ AuraID = 233498, UnitID = "focus", Caster = "player" }, -- misery
		{ AuraID = 233499, UnitID = "focus", Caster = "player" }, -- misery
		{ AuraID = 157736, UnitID = "focus", Caster = "player" }, -- sacrifice
		{ AuraID = 265412, UnitID = "focus", Caster = "player" }, -- doom
	},
	["Spell Cooldown"] = { -- Cooldown timer group
		{ SlotID = 13 }, -- trinket 1
		{ SlotID = 14 }, -- trinket 2
	},
}

Module:AddNewAuraWatch("WARLOCK", list)
