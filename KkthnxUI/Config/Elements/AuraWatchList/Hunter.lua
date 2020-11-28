local K = unpack(select(2, ...))
local Module = K:GetModule("AurasTable")

-- Hunter's spell monitoring
local list = {
	["Player Aura"] = { -- Player Halo Group
		{AuraID = 136, UnitID = "pet"}, -- Treat pets
		{AuraID = 19577, UnitID = "pet"}, -- Coercion
		{AuraID = 160058, UnitID = "pet"}, -- Thick skin
		{AuraID = 90361, UnitID = "player"}, -- Soul healing
		{AuraID = 35079, UnitID = "player"}, -- Misleading
		{AuraID = 61648, UnitID = "player"}, -- Guardian of the Chameleon
		{AuraID = 199483, UnitID = "player"}, -- camouflage
		{AuraID = 118922, UnitID = "player"}, -- As fast as the wind
		{AuraID = 164857, UnitID = "player"}, -- Survival expert
		{AuraID = 186258, UnitID = "player"}, -- Guardian of the Cheetah
		{AuraID = 246152, UnitID = "player"}, -- Barbed shot
		{AuraID = 246851, UnitID = "player"}, -- Barbed shot
		{AuraID = 246852, UnitID = "player"}, -- Barbed shot
		{AuraID = 246853, UnitID = "player"}, -- Barbed shot
		{AuraID = 246854, UnitID = "player"}, -- Barbed shot
		{AuraID = 203924, UnitID = "player"}, -- Guarding the barrier
		{AuraID = 197161, UnitID = "player"}, -- Guardian of the Spirit Turtle
		{AuraID = 160007, UnitID = "player"}, -- Updraft (two-headed dragon)
		{AuraID = 231390, UnitID = "player", Combat = true}, -- pioneer
		{AuraID = 164273, UnitID = "player", Combat = true}, -- Solo
		{AuraID = 209997, UnitID = "pet", Flash = true}, -- Play dead
	},

	["Target Aura"] = { -- Target halo group
		{AuraID = 3355, UnitID = "target", Caster = "player"}, -- Frozen trap
		{AuraID = 5116, UnitID = "target", Caster = "player"}, -- Shock shot
		{AuraID = 19386, UnitID = "target", Caster = "player"}, -- Pterodactyl Spike
		{AuraID = 24394, UnitID = "target", Caster = "pet"}, -- Coercion
		{AuraID = 117526, UnitID = "target"}, -- Bondage shooting
		{AuraID = 257284, UnitID = "target"}, -- Hunter's Mark
		{AuraID = 131894, UnitID = "target", Caster = "player"}, -- Deadly Crow
		{AuraID = 199803, UnitID = "target", Caster = "player"}, -- Precise aiming
		{AuraID = 195645, UnitID = "target", Caster = "player"}, -- Trip
		{AuraID = 202797, UnitID = "target", Caster = "player"}, -- Viper Sting
		{AuraID = 202900, UnitID = "target", Caster = "player"}, -- Scorpion Sting
		{AuraID = 224729, UnitID = "target", Caster = "player"}, -- Burst shot
		{AuraID = 213691, UnitID = "target", Caster = "player"}, -- Scatter shot
		{AuraID = 162480, UnitID = "target", Caster = "player"}, -- Steel trap
		{AuraID = 162487, UnitID = "target", Caster = "player"}, -- Steel trap
		{AuraID = 259491, UnitID = "target", Caster = "player"}, -- Viper Sting
		{AuraID = 271788, UnitID = "target", Caster = "player"}, -- Viper Sting
		{AuraID = 269747, UnitID = "target", Caster = "player"}, -- Wildfire bomb
		{AuraID = 270339, UnitID = "target", Caster = "player"}, -- Scatter bomb
		{AuraID = 270343, UnitID = "target", Caster = "player"}, -- Internal bleeding
		{AuraID = 271049, UnitID = "target", Caster = "player"}, -- Turbulence bomb
		{AuraID = 270332, UnitID = "target", Caster = "player"}, -- Pheromone Bomb
		{AuraID = 259277, UnitID = "target", Caster = "pet"}, -- Kill order
		{AuraID = 277959, UnitID = "target", Caster = "player"}, -- Steady aim
		{AuraID = 217200, UnitID = "target", Caster = "player"}, -- Barbed shot
		{AuraID = 336746, UnitID = "target", Caster = "player"}, -- Soul forged embers, orange outfit
		{AuraID = 328275, UnitID = "target", Caster = "player"}, -- Mark of the Wild
		{AuraID = 324149, UnitID = "target", Caster = "player"}, -- Looting shot
		{AuraID = 308498, UnitID = "target", Caster = "player"}, -- Resonance arrow
	},

	["Special Aura"] = {	-- Important halo group for players
		{AuraID = 19574, UnitID = "player"}, -- Wild rage
		{AuraID = 54216, UnitID = "player"}, -- Master's call
		{AuraID = 186257, UnitID = "player"}, -- Guardian of the Cheetah
		{AuraID = 186265, UnitID = "player"}, -- Guardian of the Turtle
		{AuraID = 190515, UnitID = "player"}, -- Survival of the fittest
		{AuraID = 193534, UnitID = "player"}, -- Solid concentration
		{AuraID = 194594, UnitID = "player", Flash = true},	-- Live ammunition
		{AuraID = 118455, UnitID = "pet"}, -- Beast Cleave
		{AuraID = 207094, UnitID = "pet"}, -- Titan Thunder
		{AuraID = 217200, UnitID = "pet"}, -- Ferocious rage
		{AuraID = 272790, UnitID = "pet"}, -- violent
		{AuraID = 193530, UnitID = "player"}, -- Guardian of the Wild
		{AuraID = 185791, UnitID = "player"}, -- Call of the Wilderness
		{AuraID = 259388, UnitID = "player"}, -- Meerkat Fury
		{AuraID = 186289, UnitID = "player"}, -- Aspect of the Eagle
		{AuraID = 201081, UnitID = "player"}, -- Moknazar Tactics
		{AuraID = 194407, UnitID = "player"}, -- Poisonous Cobra
		{AuraID = 208888, UnitID = "player"}, -- Shadow Hunter's reply, orange head
		{AuraID = 204090, UnitID = "player"}, -- Hit the bullseye
		{AuraID = 208913, UnitID = "player"}, -- Sentinel vision, orange waist
		{AuraID = 248085, UnitID = "player"}, -- Snake Whisperer's Tongue, Orange Breast
		{AuraID = 242243, UnitID = "player"}, -- Lethal aim, shoot 2T20
		{AuraID = 246153, UnitID = "player"}, -- Accurate, shooting 4T20
		{AuraID = 203155, UnitID = "player"}, -- Sniper
		{AuraID = 235712, UnitID = "player", Combat = true}, -- Stable rotation, orange hand
		{AuraID = 264735, UnitID = "player"}, -- Survival of the fittest
		{AuraID = 260242, UnitID = "player", Flash = true}, -- No frills
		{AuraID = 260395, UnitID = "player"}, -- Deadly shot
		{AuraID = 269502, UnitID = "player"}, -- Deadly shot
		{AuraID = 281036, UnitID = "player"}, -- Ferocious beast
		{AuraID = 260402, UnitID = "player"}, -- Second burst
		{AuraID = 266779, UnitID = "player"}, -- Coordinated attack
		{AuraID = 260286, UnitID = "player"}, -- Bladed Spear
		{AuraID = 265898, UnitID = "player"}, -- Engagement agreement
		{AuraID = 268552, UnitID = "player"}, -- Viper Venom
		{AuraID = 260249, UnitID = "player"}, -- Predator
		{AuraID = 257622, UnitID = "player", Text = "AoE"}, -- Skill shooting
		{AuraID = 288613, UnitID = "player"}, -- crack shot
		{AuraID = 274447, UnitID = "player"}, -- Thousand Miles Eye
		{AuraID = 260243, UnitID = "player"}, -- Shooting
		{AuraID = 342076, UnitID = "player"}, -- Xingyun Liushui
	},

	["Focus Aura"] = { -- Focus halo group
		{AuraID = 3355, UnitID = "focus", Caster = "player"}, -- Frozen trap
		{AuraID = 19386, UnitID = "focus", Caster = "player"}, -- Pterodactyl Spike
		{AuraID = 118253, UnitID = "focus", Caster = "player"}, -- Viper Sting
		{AuraID = 194599, UnitID = "focus", Caster = "player"},	-- Black arrow
		{AuraID = 131894, UnitID = "focus", Caster = "player"},	-- Deadly Crow
		{AuraID = 199803, UnitID = "focus", Caster = "player"},	-- Precise aiming
	},

	["Spell Cooldown"] = { -- Cooling timing group
		{SlotID = 13}, -- Accessories 1
		{SlotID = 14}, -- Accessories 2
		{SpellID = 186265},	-- Guardian of the Turtle
		{SpellID = 147362},	-- Counter shooting
	},
}

Module:AddNewAuraWatch("HUNTER", list)