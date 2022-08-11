local K = unpack(KkthnxUI)
local Module = K:GetModule("AurasTable")

if K.Class ~= "SHAMAN" then
	return
end

-- Shaman's spell monitoring
local list = {
	["Player Aura"] = { -- Player Aura group
		{ AuraID = 546, UnitID = "player" }, -- walk on water
		{ AuraID = 195222, UnitID = "player" }, -- Stormwhip
		{ AuraID = 198293, UnitID = "player" }, -- Gale
		{ AuraID = 197211, UnitID = "player" }, -- Air Fury
		{ AuraID = 260881, UnitID = "player" }, -- ghost wolf
		{ AuraID = 192106, UnitID = "player", Timeless = true }, -- Lightning Shield
	},
	["Target Aura"] = { -- target aura group
		{ AuraID = 61295, UnitID = "target", Caster = "player" }, -- torrent
		{ AuraID = 51514, UnitID = "target", Caster = "player" }, -- Hex
		{ AuraID = 210873, UnitID = "target", Caster = "player" }, -- Hex
		{ AuraID = 211004, UnitID = "target", Caster = "player" }, -- Hex
		{ AuraID = 211010, UnitID = "target", Caster = "player" }, -- Hex
		{ AuraID = 211015, UnitID = "target", Caster = "player" }, -- Hex
		{ AuraID = 188389, UnitID = "target", Caster = "player" }, -- Flame Shock
		{ AuraID = 118905, UnitID = "target", Caster = "player" }, -- Lightning Surge Totem
		{ AuraID = 188089, UnitID = "target", Caster = "player" }, -- Earth Spike
		{ AuraID = 197209, UnitID = "target", Caster = "player" }, -- Lightning Rod
		{ AuraID = 207778, UnitID = "target", Caster = "player" }, -- Tribulus
		{ AuraID = 207400, UnitID = "target", Caster = "player" }, -- ancestral vitality
		{ AuraID = 269808, UnitID = "target", Caster = "player" }, -- element exposed
		{ AuraID = 334168, UnitID = "target", Caster = "player" }, -- Lashing Flame
	},
	["Special Aura"] = { -- Player important aura group
		{ AuraID = 73920, UnitID = "player" }, -- Healing Rain
		{ AuraID = 53390, UnitID = "player" }, -- tidal surge
		{ AuraID = 79206, UnitID = "player" }, -- Spirit Walker's Gift
		{ AuraID = 73685, UnitID = "player" }, -- life release
		{ AuraID = 58875, UnitID = "player" }, -- ghost step
		{ AuraID = 77762, UnitID = "player" }, -- lava surge
		{ AuraID = 208416, UnitID = "player" }, -- 100,000 Fire
		{ AuraID = 207527, UnitID = "player" }, -- Mist Ghost
		{ AuraID = 207288, UnitID = "player" }, -- Queen's Blessing
		{ AuraID = 216251, UnitID = "player" }, -- volatility
		{ AuraID = 108281, UnitID = "player" }, -- ancestral guide
		{ AuraID = 114050, UnitID = "player" }, -- Ascension element
		{ AuraID = 114051, UnitID = "player" }, -- Ascension enhancement
		{ AuraID = 114052, UnitID = "player" }, -- Ascension recovery
		{ AuraID = 108271, UnitID = "player" }, -- astral transfer
		{ AuraID = 204945, UnitID = "player" }, -- Wind of Destruction
		{ AuraID = 201846, UnitID = "player" }, -- Stormbringer
		{ AuraID = 199055, UnitID = "player" }, -- Destruction Release
		{ AuraID = 201898, UnitID = "player" }, -- wind song
		{ AuraID = 215785, UnitID = "player" }, -- Searing Hand
		{ AuraID = 191877, UnitID = "player" }, -- vortex force
		{ AuraID = 205495, UnitID = "player" }, -- Storm Guardian
		{ AuraID = 118522, UnitID = "player" }, -- Elemental Blast critical strike
		{ AuraID = 173183, UnitID = "player" }, -- Elemental Impact Haste
		{ AuraID = 173184, UnitID = "player" }, -- Elemental Blast Mastery
		{ AuraID = 210714, UnitID = "player" }, -- Icefury
		{ AuraID = 157504, UnitID = "player", Value = true }, -- Rainstorm Totem
		{ AuraID = 280615, UnitID = "player" }, -- Swift Torrent
		{ AuraID = 273323, UnitID = "player" }, -- Lightning Shield Overload
		{ AuraID = 272737, UnitID = "player" }, -- infinite power
		{ AuraID = 263806, UnitID = "player" }, -- howling wind
		{ AuraID = 191634, UnitID = "player" }, -- Guardian of the Storm
		{ AuraID = 202004, UnitID = "player" }, -- landslide
		{ AuraID = 262652, UnitID = "player" }, -- strong wind
		{ AuraID = 224125, UnitID = "player" }, -- fire
		{ AuraID = 224126, UnitID = "player" }, -- ice
		{ AuraID = 224127, UnitID = "player" }, -- electricity
		{ AuraID = 187878, UnitID = "player" }, -- Destruction Lightning
		{ AuraID = 288675, UnitID = "player" }, -- surging waves
		{ AuraID = 320125, UnitID = "player" }, -- Echo Shock
		{ AuraID = 344179, UnitID = "player", Combat = true }, -- Maelstrom weapon
	},
	["Focus Aura"] = { -- focus aura group
		{ AuraID = 51514, UnitID = "focus", Caster = "player" }, -- Hex
		{ AuraID = 210873, UnitID = "focus", Caster = "player" }, -- Hex
		{ AuraID = 211004, UnitID = "focus", Caster = "player" }, -- Hex
		{ AuraID = 211010, UnitID = "focus", Caster = "player" }, -- Hex
		{ AuraID = 211015, UnitID = "focus", Caster = "player" }, -- Hex
	},
	["Spell Cooldown"] = { -- Cooldown timer group
		{ SlotID = 13 }, -- trinket 1
		{ SlotID = 14 }, -- trinket 2
		{ SpellID = 20608 }, -- respawn
		{ SpellID = 98008 }, -- soul link
		{ SpellID = 114050 }, -- Ascension element
		{ SpellID = 114051 }, -- Ascension enhancement
		{ SpellID = 114052 }, -- Ascension recovery
		{ SpellID = 108280 }, -- Tide of Healing
		{ SpellID = 198506 }, -- feral wolf spirit
	},
}

Module:AddNewAuraWatch("SHAMAN", list)
