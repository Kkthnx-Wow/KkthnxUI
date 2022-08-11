local K = unpack(KkthnxUI)
local Module = K:GetModule("AurasTable")

if K.Class ~= "HUNTER" then
	return
end

-- Hunter's spell monitoring
local list = {
	["Player Aura"] = { -- Player Aura group
		{ AuraID = 136, UnitID = "pet" }, -- heal pet
		{ AuraID = 19577, UnitID = "pet" }, -- coercion
		{ AuraID = 160058, UnitID = "pet" }, -- thick skin
		{ AuraID = 90361, UnitID = "player" }, -- soul healing
		{ AuraID = 35079, UnitID = "player" }, -- misleading
		{ AuraID = 61648, UnitID = "player" }, -- chameleon guardian
		{ AuraID = 199483, UnitID = "player" }, -- disguise
		{ AuraID = 118922, UnitID = "player" }, -- swift as the wind
		{ AuraID = 164857, UnitID = "player" }, -- Survival Expert
		{ AuraID = 186258, UnitID = "player" }, -- Guardian of the Cheetah
		{ AuraID = 246152, UnitID = "player" }, -- barb shot
		{ AuraID = 246851, UnitID = "player" }, -- barb shot
		{ AuraID = 246852, UnitID = "player" }, -- barb shot
		{ AuraID = 246853, UnitID = "player" }, -- barb shot
		{ AuraID = 246854, UnitID = "player" }, -- barb shot
		{ AuraID = 203924, UnitID = "player" }, -- Guardian Barrier
		{ AuraID = 197161, UnitID = "player" }, -- Turtle's guardian restores blood
		{ AuraID = 160007, UnitID = "player" }, -- updraft (two-headed dragon)
		{ AuraID = 260249, UnitID = "player" }, -- predator
		{ AuraID = 231390, UnitID = "player", Combat = true }, -- Trailblazer
		{ AuraID = 164273, UnitID = "player", Combat = true }, -- loner
		{ AuraID = 209997, UnitID = "pet", Flash = true }, -- play dead
	},
	["Target Aura"] = { -- target aura group
		{ AuraID = 3355, UnitID = "target", Caster = "player" }, -- Freeze Trap
		{ AuraID = 5116, UnitID = "target", Caster = "player" }, -- Concussive Shot
		{ AuraID = 19386, UnitID = "target", Caster = "player" }, -- Pterodactyl Sting
		{ AuraID = 24394, UnitID = "target", Caster = "pet" }, -- coercion
		{ AuraID = 321538, UnitID = "target", Caster = "pet" }, -- blood splattered in ten directions
		{ AuraID = 117526, UnitID = "target" }, -- restraint shot
		{ AuraID = 257284, UnitID = "target", Caster = "player" }, -- Hunter's Mark
		{ AuraID = 131894, UnitID = "target", Caster = "player" }, -- Deadly Crow
		{ AuraID = 199803, UnitID = "target", Caster = "player" }, -- precise aiming
		{ AuraID = 195645, UnitID = "target", Caster = "player" }, -- tripping
		{ AuraID = 202797, UnitID = "target", Caster = "player" }, -- Viper Sting
		{ AuraID = 202900, UnitID = "target", Caster = "player" }, -- Scorpion Sting
		{ AuraID = 224729, UnitID = "target", Caster = "player" }, -- burst shot
		{ AuraID = 213691, UnitID = "target", Caster = "player" }, -- dispel shot
		{ AuraID = 162480, UnitID = "target", Caster = "player" }, -- Steel Trap
		{ AuraID = 162487, UnitID = "target", Caster = "player" }, -- Steel Trap
		{ AuraID = 259491, UnitID = "target", Caster = "player" }, -- Serpent Sting
		{ AuraID = 271788, UnitID = "target", Caster = "player" }, -- Serpent Sting
		{ AuraID = 269747, UnitID = "target", Caster = "player" }, -- wildfire bomb
		{ AuraID = 270339, UnitID = "target", Caster = "player" }, -- Scatter bomb
		{ AuraID = 270343, UnitID = "target", Caster = "player" }, -- internal bleeding
		{ AuraID = 271049, UnitID = "target", Caster = "player" }, -- Unrest Bomb
		{ AuraID = 270332, UnitID = "target", Caster = "player", Flash = true }, -- pheromone bomb
		-- {AuraID = 259277, UnitID = "target", Caster = "pet"}, -- Kill command
		{ AuraID = 277959, UnitID = "target", Caster = "player" }, -- steady aim
		{ AuraID = 217200, UnitID = "target", Caster = "player" }, -- barb shot
		{ AuraID = 336746, UnitID = "target", Caster = "player" }, -- Soulcast Embers, Orange
		{ AuraID = 328275, UnitID = "target", Caster = "player" }, -- Mark of the Wild
		{ AuraID = 324149, UnitID = "target", Caster = "player" }, -- Plunder Shot
		{ AuraID = 308498, UnitID = "target", Caster = "player" }, -- Resonating Arrow
		{ AuraID = 333526, UnitID = "target", Caster = "player" }, -- Spike Fruit
	},
	["Special Aura"] = { -- Player important aura group
		{ AuraID = 19574, UnitID = "player" }, -- Wild Fury
		{ AuraID = 54216, UnitID = "player" }, -- the master's call
		{ AuraID = 186257, UnitID = "player" }, -- Cheetah Guardian
		{ AuraID = 186265, UnitID = "player" }, -- Guardian of the tortoise
		{ AuraID = 190515, UnitID = "player" }, -- survival of the fittest
		{ AuraID = 193534, UnitID = "player" }, -- solid focus
		{ AuraID = 194594, UnitID = "player", Flash = true }, -- loaded with live ammunition
		{ AuraID = 118455, UnitID = "pet" }, -- Beast Slash
		{ AuraID = 207094, UnitID = "pet" }, -- Titan Thunder
		{ AuraID = 217200, UnitID = "pet" }, -- ferocious fury
		{ AuraID = 272790, UnitID = "pet" }, -- Rampage
		{ AuraID = 193530, UnitID = "player" }, -- Guardian of the Wild
		{ AuraID = 185791, UnitID = "player" }, -- Call of the Wild
		{ AuraID = 259388, UnitID = "player" }, -- Mongoose Fury
		{ AuraID = 186289, UnitID = "player" }, -- Guardian of the Eagle
		{ AuraID = 201081, UnitID = "player" }, -- Mok'Nathal tactics
		{ AuraID = 194407, UnitID = "player" }, -- spray cobra
		{ AuraID = 208888, UnitID = "player" }, -- Reply from Shadow Hunter, orange head
		{ AuraID = 204090, UnitID = "player" }, -- center the bullseye
		{ AuraID = 208913, UnitID = "player" }, -- Sentinel vision, orange waist
		{ AuraID = 248085, UnitID = "player" }, -- Snake Whisperer's Tongue, Orange Breast
		{ AuraID = 242243, UnitID = "player" }, -- lethal aim, shoot 2T20
		{ AuraID = 246153, UnitID = "player" }, -- precision, fire 4T20
		{ AuraID = 203155, UnitID = "player" }, -- sniper
		{ AuraID = 235712, UnitID = "player", Combat = true }, -- gyro stabilization, orange hand
		{ AuraID = 264735, UnitID = "player" }, -- Survival of the fittest
		{ AuraID = 281195, UnitID = "player" }, -- Survival of the fittest
		{ AuraID = 260242, UnitID = "player" }, -- no missed shots
		{ AuraID = 260395, UnitID = "player" }, -- lethal shot
		{ AuraID = 269502, UnitID = "player" }, -- lethal shot
		{ AuraID = 281036, UnitID = "player" }, -- Dire Beast
		{ AuraID = 260402, UnitID = "player" }, -- two bursts
		{ AuraID = 266779, UnitID = "player" }, -- coordinated attack
		{ AuraID = 260286, UnitID = "player" }, -- Bladed Spear
		{ AuraID = 265898, UnitID = "player" }, -- engagement agreement
		{ AuraID = 268552, UnitID = "player" }, -- Viper Venom
		{ AuraID = 257622, UnitID = "player", Text = "AoE" }, -- skill shot
		{ AuraID = 288613, UnitID = "player" }, -- all hits
		{ AuraID = 274447, UnitID = "player" }, -- A Thousand Miles Eye
		{ AuraID = 260243, UnitID = "player" }, -- shooter
		{ AuraID = 342076, UnitID = "player" }, -- flow
		{ AuraID = 336892, UnitID = "player", Flash = true }, -- The Secret of Unbreakable Vigilance

		{ AuraID = 363760, UnitID = "player", Flash = true }, -- Killing Madness, Beastmaster 4T
		{ AuraID = 363805, UnitID = "player", Flash = true }, -- Crazy Grenadier, Survival 2T
	},
	["Focus Aura"] = { -- focus aura group
		{ AuraID = 3355, UnitID = "focus", Caster = "player" }, -- Freeze Trap
		{ AuraID = 19386, UnitID = "focus", Caster = "player" }, -- pterosaur spike
		{ AuraID = 118253, UnitID = "focus", Caster = "player" }, -- Serpent Sting
		{ AuraID = 194599, UnitID = "focus", Caster = "player" }, -- black arrow
		{ AuraID = 131894, UnitID = "focus", Caster = "player" }, -- Deadly Crow
		{ AuraID = 199803, UnitID = "focus", Caster = "player" }, -- precise aiming
	},
	["Spell Cooldown"] = { -- Cooldown timer group
		{ SlotID = 13 }, -- trinket 1
		{ SlotID = 14 }, -- trinket 2
		{ SpellID = 186265 }, -- Guardian of the tortoise
		{ SpellID = 147362 }, -- counter shot
	},
}

Module:AddNewAuraWatch("HUNTER", list)
