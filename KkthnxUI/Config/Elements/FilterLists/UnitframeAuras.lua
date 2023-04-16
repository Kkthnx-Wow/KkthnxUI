local K, C = KkthnxUI[1], KkthnxUI[2]

local function Priority(priorityOverride)
	return {
		enable = true,
		priority = priorityOverride or 0,
		stackThreshold = 0,
	}
end

C.DebuffsTracking_PvE = {
	["type"] = "Whitelist",
	["spells"] = {
		----------------------------------------------------------
		-------------------- Mythic+ Specific --------------------
		----------------------------------------------------------
		-- General Affixes
		[226512] = Priority(), -- Sanguine
		[240559] = Priority(), -- Grievous
		[240443] = Priority(), -- Bursting
		-- Dragonflight Season 1
		[396369] = Priority(), -- Mark of Lightning
		[396364] = Priority(), -- Mark of Wind
		----------------------------------------------------------
		---------------- Dragonflight (Season 1) -----------------
		----------------------------------------------------------
		-- Court of Stars
		[207278] = Priority(), -- Arcane Lockdown
		[209516] = Priority(), -- Mana Fang
		[209512] = Priority(), -- Disrupting Energy
		[211473] = Priority(), -- Shadow Slash
		[207979] = Priority(), -- Shockwave
		[207980] = Priority(), -- Disintegration Beam 1
		[207981] = Priority(), -- Disintegration Beam 2
		[211464] = Priority(), -- Fel Detonation
		[208165] = Priority(), -- Withering Soul
		[209413] = Priority(), -- Suppress
		[209027] = Priority(), -- Quelling Strike
		-- Halls of Valor
		[197964] = Priority(), -- Runic Brand Orange
		[197965] = Priority(), -- Runic Brand Yellow
		[197963] = Priority(), -- Runic Brand Purple
		[197967] = Priority(), -- Runic Brand Green
		[197966] = Priority(), -- Runic Brand Blue
		[193783] = Priority(), -- Aegis of Aggramar Up
		[196838] = Priority(), -- Scent of Blood
		[199674] = Priority(), -- Wicked Dagger
		[193260] = Priority(), -- Static Field
		[193743] = Priority(), -- Aegis of Aggramar Wielder
		[199652] = Priority(), -- Sever
		[198944] = Priority(), -- Breach Armor
		[215430] = Priority(), -- Thunderstrike 1
		[215429] = Priority(), -- Thunderstrike 2
		[203963] = Priority(), -- Eye of the Storm
		[196497] = Priority(), -- Ravenous Leap
		[193660] = Priority(), -- Felblaze Rush
		-- Shadowmoon Burial Grounds
		[156776] = Priority(), -- Rending Voidlash
		[153692] = Priority(), -- Necrotic Pitch
		[153524] = Priority(), -- Plague Spit
		[154469] = Priority(), -- Ritual of Bones
		[162652] = Priority(), -- Lunar Purity
		[164907] = Priority(), -- Void Cleave
		[152979] = Priority(), -- Soul Shred
		[158061] = Priority(), -- Blessed Waters of Purity
		[154442] = Priority(), -- Malevolence
		[153501] = Priority(), -- Void Blast
		-- Temple of the Jade Serpent
		[396150] = Priority(), -- Feeling of Superiority
		[397878] = Priority(), -- Tainted Ripple
		[106113] = Priority(), -- Touch of Nothingness
		[397914] = Priority(), -- Defiling Mist
		[397904] = Priority(), -- Setting Sun Kick
		[397911] = Priority(), -- Touch of Ruin
		[395859] = Priority(), -- Haunting Scream
		[396093] = Priority(), -- Savage Leap
		[106823] = Priority(), -- Serpent Strike
		[396152] = Priority(), -- Feeling of Inferiority
		[110125] = Priority(), -- Shattered Resolve
		[397797] = Priority(), -- Corrupted Vortex
		-- Ruby Life Pools
		[392406] = Priority(), -- Thunderclap
		[372820] = Priority(), -- Scorched Earth
		[384823] = Priority(), -- Inferno 1
		[373692] = Priority(), -- Inferno 2
		[381862] = Priority(), -- Infernocore
		[372860] = Priority(), -- Searing Wounds
		[373869] = Priority(), -- Burning Touch
		[385536] = Priority(), -- Flame Dance
		[381518] = Priority(), -- Winds of Change
		[372858] = Priority(), -- Searing Blows
		[372682] = Priority(), -- Primal Chill 1
		[373589] = Priority(), -- Primal Chill 2
		[373693] = Priority(), -- Living Bomb
		[392924] = Priority(), -- Shock Blast
		[381515] = Priority(), -- Stormslam
		[396411] = Priority(), -- Primal Overload
		[384773] = Priority(), -- Flaming Embers
		[392451] = Priority(), -- Flashfire
		[372697] = Priority(), -- Jagged Earth
		[372047] = Priority(), -- Flurry
		[372963] = Priority(), -- Chillstorm
		-- The Nokhud Offensive
		[382628] = Priority(), -- Surge of Power
		[386025] = Priority(), -- Tempest
		[381692] = Priority(), -- Swift Stab
		[387615] = Priority(), -- Grasp of the Dead
		[387629] = Priority(), -- Rotting Wind
		[386912] = Priority(), -- Stormsurge Cloud
		[395669] = Priority(), -- Aftershock
		[384134] = Priority(), -- Pierce
		[388451] = Priority(), -- Stormcaller's Fury 1
		[388446] = Priority(), -- Stormcaller's Fury 2
		[395035] = Priority(), -- Shatter Soul
		[376899] = Priority(), -- Crackling Cloud
		[384492] = Priority(), -- Hunter's Mark
		[376730] = Priority(), -- Stormwinds
		[376894] = Priority(), -- Crackling Upheaval
		[388801] = Priority(), -- Mortal Strike
		[376827] = Priority(), -- Conductive Strike
		[376864] = Priority(), -- Static Spear
		[375937] = Priority(), -- Rending Strike
		[376634] = Priority(), -- Iron Spear
		-- The Azure Vault
		[388777] = Priority(), -- Oppressive Miasma
		[386881] = Priority(), -- Frost Bomb
		[387150] = Priority(), -- Frozen Ground
		[387564] = Priority(), -- Mystic Vapors
		[385267] = Priority(), -- Crackling Vortex
		[386640] = Priority(), -- Tear Flesh
		[374567] = Priority(), -- Explosive Brand
		[374523] = Priority(), -- Arcane Roots
		[375596] = Priority(), -- Erratic Growth Channel
		[375602] = Priority(), -- Erratic Growth
		[370764] = Priority(), -- Piercing Shards
		[384978] = Priority(), -- Dragon Strike
		[375649] = Priority(), -- Infused Ground
		[387151] = Priority(), -- Icy Devastator
		[377488] = Priority(), -- Icy Bindings
		[374789] = Priority(), -- Infused Strike
		[371007] = Priority(), -- Splintering Shards
		[375591] = Priority(), -- Sappy Burst
		[385409] = Priority(), -- Ouch, ouch, ouch!
		[386549] = Priority(), -- Waking Bane
		-- Algeth'ar Academy
		[389033] = Priority(), -- Lasher Toxin
		[391977] = Priority(), -- Oversurge
		[386201] = Priority(), -- Corrupted Mana
		[389011] = Priority(), -- Overwhelming Power
		[387932] = Priority(), -- Astral Whirlwind
		[396716] = Priority(), -- Splinterbark
		[388866] = Priority(), -- Mana Void
		[386181] = Priority(), -- Mana Bomb
		[388912] = Priority(), -- Severing Slash
		[377344] = Priority(), -- Peck
		[376997] = Priority(), -- Savage Peck
		[388984] = Priority(), -- Vicious Ambush
		[388544] = Priority(), -- Barkbreaker
		[377008] = Priority(), -- Deafening Screech
		----------------------------------------------------------
		---------------- Dragonflight (Season 2) -----------------
		----------------------------------------------------------
		-- Brackenhide Hollow
		-- Halls of Infusion
		-- Neltharus
		-- Uldaman: Legacy of Tyr
		---------------------------------------------------------
		---------------- Vault of the Incarnates ----------------
		---------------------------------------------------------
		-- Eranog
		[370648] = Priority(5), -- Primal Flow
		[390715] = Priority(6), -- Primal Rifts
		[370597] = Priority(6), -- Kill Order
		-- Terros
		[382776] = Priority(5), -- Awakened Earth 1
		[381253] = Priority(5), -- Awakened Earth 2
		[386352] = Priority(3), -- Rock Blast
		[382458] = Priority(6), -- Resonant Aftermath
		-- The Primal Council
		[371624] = Priority(5), -- Conductive Mark
		[372027] = Priority(4), -- Slashing Blaze
		[374039] = Priority(4), -- Meteor Axe
		-- Sennarth, the Cold Breath
		[371976] = Priority(4), -- Chilling Blast
		[372082] = Priority(5), -- Enveloping Webs
		[374659] = Priority(4), -- Rush
		[374104] = Priority(5), -- Wrapped in Webs Slow
		[374503] = Priority(6), -- Wrapped in Webs Stun
		[373048] = Priority(3), -- Suffocating Webs
		-- Dathea, Ascended
		[391686] = Priority(5), -- Conductive Mark
		[378277] = Priority(2), -- Elemental Equilbrium
		[388290] = Priority(4), -- Cyclone
		-- Kurog Grimtotem
		[377780] = Priority(5), -- Skeletal Fractures
		[372514] = Priority(5), -- Frost Bite
		[374554] = Priority(4), -- Lava Pool
		[374709] = Priority(4), -- Seismic Rupture
		[374023] = Priority(6), -- Searing Carnage
		[374427] = Priority(6), -- Ground Shatter
		[390920] = Priority(5), -- Shocking Burst
		[372458] = Priority(6), -- Below Zero
		-- Broodkeeper Diurna
		[388920] = Priority(6), -- Frozen Shroud
		[378782] = Priority(5), -- Mortal Wounds
		[378787] = Priority(5), -- Crushing Stoneclaws
		[375620] = Priority(6), -- Ionizing Charge
		[375578] = Priority(4), -- Flame Sentry
		-- Raszageth the Storm-Eater
		[381615] = Priority(6), -- Static Charge
		[399713] = Priority(6), -- Magnetic Charge
		[385073] = Priority(5), -- Ball Lightning
		[377467] = Priority(6), -- Fulminating Charge
	},
}

C.DebuffsTracking_PvP = {
	["type"] = "Whitelist",
	["spells"] = {
		-- Evoker
		[355689] = Priority(2), -- Landslide
		[370898] = Priority(1), -- Permeating Chill
		[360806] = Priority(3), -- Sleep Walk
		-- Death Knight
		[47476] = Priority(2), -- Strangulate
		[108194] = Priority(4), -- Asphyxiate UH
		[221562] = Priority(4), -- Asphyxiate Blood
		[207171] = Priority(4), -- Winter is Coming
		[206961] = Priority(3), -- Tremble Before Me
		[207167] = Priority(4), -- Blinding Sleet
		[212540] = Priority(1), -- Flesh Hook (Pet)
		[91807] = Priority(1), -- Shambling Rush (Pet)
		[204085] = Priority(1), -- Deathchill
		[233395] = Priority(1), -- Frozen Center
		[212332] = Priority(4), -- Smash (Pet)
		[212337] = Priority(4), -- Powerful Smash (Pet)
		[91800] = Priority(4), -- Gnaw (Pet)
		[91797] = Priority(4), -- Monstrous Blow (Pet)
		[210141] = Priority(3), -- Zombie Explosion
		-- Demon Hunter
		[207685] = Priority(4), -- Sigil of Misery
		[217832] = Priority(3), -- Imprison
		[221527] = Priority(5), -- Imprison (Banished version)
		[204490] = Priority(2), -- Sigil of Silence
		[179057] = Priority(3), -- Chaos Nova
		[211881] = Priority(4), -- Fel Eruption
		[205630] = Priority(3), -- Illidan's Grasp
		[208618] = Priority(3), -- Illidan's Grasp (Afterward)
		[213491] = Priority(4), -- Demonic Trample 1
		[208645] = Priority(4), -- Demonic Trample 2
		-- Druid
		[81261] = Priority(2), -- Solar Beam
		[5211] = Priority(4), -- Mighty Bash
		[163505] = Priority(4), -- Rake
		[203123] = Priority(4), -- Maim
		[202244] = Priority(4), -- Overrun
		[99] = Priority(4), -- Incapacitating Roar
		[33786] = Priority(5), -- Cyclone
		[45334] = Priority(1), -- Immobilized
		[102359] = Priority(1), -- Mass Entanglement
		[339] = Priority(1), -- Entangling Roots
		[2637] = Priority(1), -- Hibernate
		[102793] = Priority(1), -- Ursol's Vortex
		-- Hunter
		[202933] = Priority(2), -- Spider Sting 1
		[233022] = Priority(2), -- Spider Sting 2
		[213691] = Priority(4), -- Scatter Shot
		[19386] = Priority(3), -- Wyvern Sting
		[3355] = Priority(3), -- Freezing Trap
		[203337] = Priority(5), -- Freezing Trap (PvP Talent)
		[209790] = Priority(3), -- Freezing Arrow
		[24394] = Priority(4), -- Intimidation
		[117526] = Priority(4), -- Binding Shot
		[190927] = Priority(1), -- Harpoon
		[201158] = Priority(1), -- Super Sticky Tar
		[162480] = Priority(1), -- Steel Trap
		[212638] = Priority(1), -- Tracker's Net
		[200108] = Priority(1), -- Ranger's Net
		-- Mage
		[61721] = Priority(3), -- Rabbit
		[61305] = Priority(3), -- Black Cat
		[28272] = Priority(3), -- Pig
		[28271] = Priority(3), -- Turtle
		[126819] = Priority(3), -- Porcupine
		[161354] = Priority(3), -- Monkey
		[161353] = Priority(3), -- Polar Bear
		[61780] = Priority(3), -- Turkey
		[161355] = Priority(3), -- Penguin
		[161372] = Priority(3), -- Peacock
		[277787] = Priority(3), -- Direhorn
		[277792] = Priority(3), -- Bumblebee
		[118] = Priority(3), -- Polymorph
		[82691] = Priority(3), -- Ring of Frost
		[31661] = Priority(3), -- Dragon's Breath
		[122] = Priority(1), -- Frost Nova
		[33395] = Priority(1), -- Freeze
		[157997] = Priority(1), -- Ice Nova
		[228600] = Priority(1), -- Glacial Spike
		[198121] = Priority(1), -- Frostbite
		-- Monk
		[119381] = Priority(4), -- Leg Sweep
		[202346] = Priority(4), -- Double Barrel
		[115078] = Priority(4), -- Paralysis
		[198909] = Priority(3), -- Song of Chi-Ji
		[202274] = Priority(3), -- Incendiary Brew
		[233759] = Priority(2), -- Grapple Weapon
		[123407] = Priority(1), -- Spinning Fire Blossom
		[116706] = Priority(1), -- Disable
		[232055] = Priority(4), -- Fists of Fury
		-- Paladin
		[853] = Priority(3), -- Hammer of Justice
		[20066] = Priority(3), -- Repentance
		[105421] = Priority(3), -- Blinding Light
		[31935] = Priority(2), -- Avenger's Shield
		[217824] = Priority(2), -- Shield of Virtue
		[205290] = Priority(3), -- Wake of Ashes
		-- Priest
		[9484] = Priority(3), -- Shackle Undead
		[200196] = Priority(4), -- Holy Word: Chastise
		[200200] = Priority(4), -- Holy Word: Chastise
		[226943] = Priority(3), -- Mind Bomb
		[605] = Priority(5), -- Mind Control
		[8122] = Priority(3), -- Psychic Scream
		[15487] = Priority(2), -- Silence
		[64044] = Priority(1), -- Psychic Horror
		[453] = Priority(5), -- Mind Soothe
		-- Rogue
		[2094] = Priority(4), -- Blind
		[6770] = Priority(4), -- Sap
		[1776] = Priority(4), -- Gouge
		[1330] = Priority(2), -- Garrote - Silence
		[207777] = Priority(2), -- Dismantle
		[408] = Priority(4), -- Kidney Shot
		[1833] = Priority(4), -- Cheap Shot
		[207736] = Priority(5), -- Shadowy Duel (Smoke effect)
		[212182] = Priority(5), -- Smoke Bomb
		-- Shaman
		[51514] = Priority(3), -- Hex
		[211015] = Priority(3), -- Hex (Cockroach)
		[211010] = Priority(3), -- Hex (Snake)
		[211004] = Priority(3), -- Hex (Spider)
		[210873] = Priority(3), -- Hex (Compy)
		[196942] = Priority(3), -- Hex (Voodoo Totem)
		[269352] = Priority(3), -- Hex (Skeletal Hatchling)
		[277778] = Priority(3), -- Hex (Zandalari Tendonripper)
		[277784] = Priority(3), -- Hex (Wicker Mongrel)
		[118905] = Priority(3), -- Static Charge
		[77505] = Priority(4), -- Earthquake (Knocking down)
		[118345] = Priority(4), -- Pulverize (Pet)
		[204399] = Priority(3), -- Earthfury
		[204437] = Priority(3), -- Lightning Lasso
		[157375] = Priority(4), -- Gale Force
		[64695] = Priority(1), -- Earthgrab
		-- Warlock
		[710] = Priority(5), -- Banish
		[6789] = Priority(3), -- Mortal Coil
		[118699] = Priority(3), -- Fear
		[6358] = Priority(3), -- Seduction (Succub)
		[171017] = Priority(4), -- Meteor Strike (Infernal)
		[22703] = Priority(4), -- Infernal Awakening (Infernal CD)
		[30283] = Priority(3), -- Shadowfury
		[89766] = Priority(4), -- Axe Toss
		[233582] = Priority(1), -- Entrenched in Flame
		-- Warrior
		[5246] = Priority(4), -- Intimidating Shout
		[132169] = Priority(4), -- Storm Bolt
		[132168] = Priority(4), -- Shockwave
		[199085] = Priority(4), -- Warpath
		[105771] = Priority(1), -- Charge
		[199042] = Priority(1), -- Thunderstruck
		[236077] = Priority(2), -- Disarm
		-- Racial
		[20549] = Priority(4), -- War Stomp
		[107079] = Priority(4), -- Quaking Palm
	},
}
