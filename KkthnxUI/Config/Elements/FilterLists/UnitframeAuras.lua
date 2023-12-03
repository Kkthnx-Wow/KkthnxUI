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
		[409492] = Priority(), -- Afflicted Cry
		----------------------------------------------------------
		----------------- Dragonflight Dungeons ------------------
		----------------------------------------------------------
		-- Dawn of the Infinite
		[413041] = Priority(), -- Sheared Lifespan 1
		[416716] = Priority(), -- Sheared Lifespan 2
		[413013] = Priority(), -- Chronoshear
		[413208] = Priority(), -- Sand Buffeted
		[408084] = Priority(), -- Necrofrost
		[413142] = Priority(), -- Eon Shatter
		[409266] = Priority(), -- Extinction Blast 1
		[414300] = Priority(), -- Extinction Blast 2
		[401667] = Priority(), -- Time Stasis
		[412027] = Priority(), -- Chronal Burn
		[400681] = Priority(), -- Spark of Tyr
		[404141] = Priority(), -- Chrono-faded
		[407147] = Priority(), -- Blight Seep
		[410497] = Priority(), -- Mortal Wounds
		[418009] = Priority(), -- Serrated Arrows
		[407406] = Priority(), -- Corrosion
		[401420] = Priority(), -- Sand Stomp
		[403912] = Priority(), -- Accelerating Time
		[403910] = Priority(), -- Decaying Time
		-- Brackenhide Hollow
		[385361] = Priority(), -- Rotting Sickness
		[378020] = Priority(), -- Gash Frenzy
		[385356] = Priority(), -- Ensnaring Trap
		[373917] = Priority(), -- Decaystrike 1
		[377864] = Priority(), -- Infectious Spit
		[376933] = Priority(), -- Grasping Vines
		[384425] = Priority(), -- Smell Like Meat
		[373912] = Priority(), -- Decaystrike 2
		[373896] = Priority(), -- Withering Rot
		[377844] = Priority(), -- Bladestorm 1
		[378229] = Priority(), -- Marked for Butchery
		[381835] = Priority(), -- Bladestorm 2
		[376149] = Priority(), -- Choking Rotcloud
		[384725] = Priority(), -- Feeding Frenzy
		[385303] = Priority(), -- Teeth Trap
		[368299] = Priority(), -- Toxic Trap
		[384970] = Priority(), -- Scented Meat 1
		[384974] = Priority(), -- Scented Meat 2
		[368091] = Priority(), -- Infected Bite
		[385185] = Priority(), -- Disoriented
		[387210] = Priority(), -- Decaying Strength
		[382808] = Priority(), -- Withering Contagion 1
		[383087] = Priority(), -- Withering Contagion 2
		[382723] = Priority(), -- Crushing Smash
		[382787] = Priority(), -- Decay Claws
		[385058] = Priority(), -- Withering Poison
		[383399] = Priority(), -- Rotting Surge
		[367484] = Priority(), -- Vicious Clawmangle
		[367521] = Priority(), -- Bone Bolt
		[368081] = Priority(), -- Withering
		[374245] = Priority(), -- Rotting Creek
		[367481] = Priority(), -- Bloody Bite
		-- Halls of Infusion
		[387571] = Priority(), -- Focused Deluge
		[383935] = Priority(), -- Spark Volley
		[385555] = Priority(), -- Gulp
		[384524] = Priority(), -- Titanic Fist
		[385963] = Priority(), -- Frost Shock
		[374389] = Priority(), -- Gulp Swog Toxin
		[386743] = Priority(), -- Polar Winds
		[389179] = Priority(), -- Power Overload
		[389181] = Priority(), -- Power Field
		[257274] = Priority(), -- Vile Coating
		[375384] = Priority(), -- Rumbling Earth
		[374563] = Priority(), -- Dazzle
		[389446] = Priority(), -- Nullifying Pulse
		[374615] = Priority(), -- Cheap Shot
		[391610] = Priority(), -- Blinding Winds
		[374724] = Priority(), -- Molten Subduction
		[385168] = Priority(), -- Thunderstorm
		[387359] = Priority(), -- Waterlogged
		[391613] = Priority(), -- Creeping Mold
		[374706] = Priority(), -- Pyretic Burst
		[389443] = Priority(), -- Purifying Blast
		[374339] = Priority(), -- Demoralizing Shout
		[374020] = Priority(), -- Containment Beam
		[391634] = Priority(), -- Deep Chill
		[393444] = Priority(), -- Gushing Wound
		-- Neltharus
		[374534] = Priority(), -- Heated Swings
		[373735] = Priority(), -- Dragon Strike
		[377018] = Priority(), -- Molten Gold
		[374842] = Priority(), -- Blazing Aegis 1
		[392666] = Priority(), -- Blazing Aegis 2
		[375890] = Priority(), -- Magma Eruption
		[396332] = Priority(), -- Fiery Focus
		[389059] = Priority(), -- Slag Eruption
		[376784] = Priority(), -- Flame Vulnerability
		[377542] = Priority(), -- Burning Ground
		[374451] = Priority(), -- Burning Chain
		[372461] = Priority(), -- Imbued Magma
		[378818] = Priority(), -- Magma Conflagration
		[377522] = Priority(), -- Burning Pursuit
		[375204] = Priority(), -- Liquid Hot Magma
		[374482] = Priority(), -- Grounding Chain
		[372971] = Priority(), -- Reverberating Slam
		[384161] = Priority(), -- Mote of Combustion
		[374854] = Priority(), -- Erupted Ground
		[373089] = Priority(), -- Scorching Fusillade
		[372224] = Priority(), -- Dragonbone Axe
		[372570] = Priority(), -- Bold Ambush
		[372459] = Priority(), -- Burning
		[372208] = Priority(), -- Djaradin Lava
		[414585] = Priority(), -- Fiery Demise
		-- Uldaman: Legacy of Tyr
		[368996] = Priority(), -- Purging Flames
		[369792] = Priority(), -- Skullcracker
		[372718] = Priority(), -- Earthen Shards
		[382071] = Priority(), -- Resonating Orb
		[377405] = Priority(), -- Time Sink
		[369006] = Priority(), -- Burning Heat
		[369110] = Priority(), -- Unstable Embers
		[375286] = Priority(), -- Searing Cannonfire
		[372652] = Priority(), -- Resonating Orb
		[377825] = Priority(), -- Burning Pitch
		[369411] = Priority(), -- Sonic Burst
		[382576] = Priority(), -- Scorn of Tyr
		[369366] = Priority(), -- Trapped in Stone
		[369365] = Priority(), -- Curse of Stone
		[369419] = Priority(), -- Venomous Fangs
		[377486] = Priority(), -- Time Blade
		[369818] = Priority(), -- Diseased Bite
		[377732] = Priority(), -- Jagged Bite
		[369828] = Priority(), -- Chomp
		[369811] = Priority(), -- Brutal Slam
		[376325] = Priority(), -- Eternity Zone
		[369337] = Priority(), -- Difficult Terrain
		[376333] = Priority(), -- Temporal Zone
		[377510] = Priority(), -- Stolen Time
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
		---------------- Dragonflight (Season 3) -----------------
		----------------------------------------------------------
		-- Darkheart Thicket
		[198408] = Priority(), -- Nightfall
		[196376] = Priority(), -- Grievous Tear
		[200182] = Priority(), -- Festering Rip
		[200238] = Priority(), -- Feed on the Weak
		[200289] = Priority(), -- Growing Paranoia
		[204667] = Priority(), -- Nightmare Breath
		[204611] = Priority(), -- Crushing Grip
		[199460] = Priority(), -- Falling Rocks
		[200329] = Priority(), -- Overwhelming Terror
		[191326] = Priority(), -- Breath of Corruption
		[204243] = Priority(), -- Tormenting Eye
		[225484] = Priority(), -- Grievous Rip
		[200642] = Priority(), -- Despair
		[199063] = Priority(), -- Strangling Roots
		[198477] = Priority(), -- Fixate
		[204246] = Priority(), -- Tormenting Fear
		[198904] = Priority(), -- Poison Spear
		[200684] = Priority(), -- Nightmare Toxin
		[200243] = Priority(), -- Waking Nightmare
		[200580] = Priority(), -- Maddening Roar
		[200771] = Priority(), -- Propelling Charge
		[200273] = Priority(), -- Cowardice
		[201365] = Priority(), -- Darksoul Drain
		[201839] = Priority(), -- Curse of Isolation
		[201902] = Priority(), -- Scorching Shot
		-- Black Rook Hold
		[202019] = Priority(), -- Shadow Bolt Volley
		[197521] = Priority(), -- Blazing Trail
		[197478] = Priority(), -- Dark Rush
		[197546] = Priority(), -- Brutal Glaive
		[198079] = Priority(), -- Hateful Gaze
		[224188] = Priority(), -- Hateful Charge
		[201733] = Priority(), -- Stinging Swarm
		[194966] = Priority(), -- Soul Echoes
		[198635] = Priority(), -- Unerring Shear
		[225909] = Priority(), -- Soul Venom
		[198501] = Priority(), -- Fel Vomitus
		[198446] = Priority(), -- Fel Vomit
		[200084] = Priority(), -- Soul Blade
		[197821] = Priority(), -- Felblazed Ground
		[203163] = Priority(), -- Sic Bats!
		[199368] = Priority(), -- Legacy of the Ravencrest
		[225732] = Priority(), -- Strike Down
		[199168] = Priority(), -- Itchy!
		[225963] = Priority(), -- Bloodthirsty Leap
		[214002] = Priority(), -- Raven's Dive
		[197974] = Priority(), -- Bonecrushing Strike I
		[200261] = Priority(), -- Bonecrushing Strike II
		[204896] = Priority(), -- Drain Life
		[199097] = Priority(), -- Cloud of Hypnosis
		-- Waycrest Manor
		[260703] = Priority(), -- Unstable Runic Mark
		[261438] = Priority(), -- Wasting Strike
		[261140] = Priority(), -- Virulent Pathogen
		[260900] = Priority(), -- Soul Manipulation I
		[260926] = Priority(), -- Soul Manipulation II
		[260741] = Priority(), -- Jagged Nettles
		[268086] = Priority(), -- Aura of Dread
		[264712] = Priority(), -- Rotten Expulsion
		[271178] = Priority(), -- Ravaging Leap
		[264040] = Priority(), -- Uprooted Thorns
		[265407] = Priority(), -- Dinner Bell
		[265761] = Priority(), -- Thorned Barrage
		[268125] = Priority(), -- Aura of Thorns
		[268080] = Priority(), -- Aura of Apathy
		[264050] = Priority(), -- Infected Thorn
		[260569] = Priority(), -- Wildfire
		[263943] = Priority(), -- Etch
		[264378] = Priority(), -- Fragment Soul
		[267907] = Priority(), -- Soul Thorns
		[264520] = Priority(), -- Severing Serpent
		[264105] = Priority(), -- Runic Mark
		[265881] = Priority(), -- Decaying Touch
		[265882] = Priority(), -- Lingering Dread
		[278456] = Priority(), -- Infest I
		[278444] = Priority(), -- Infest II
		[265880] = Priority(), -- Dread Mark
		-- Atal'Dazar
		[250585] = Priority(), -- Toxic Pool
		[258723] = Priority(), -- Grotesque Pool
		[260668] = Priority(), -- Transfusion I
		[260666] = Priority(), -- Transfusion II
		[255558] = Priority(), -- Tainted Blood
		[250036] = Priority(), -- Shadowy Remains
		[257483] = Priority(), -- Pile of Bones
		[253562] = Priority(), -- Wildfire
		[254959] = Priority(), -- Soulburn
		[255814] = Priority(), -- Rending Maul
		[255582] = Priority(), -- Molten Gold
		[252687] = Priority(), -- Venomfang Strike
		[255041] = Priority(), -- Terrifying Screech
		[255567] = Priority(), -- Frenzied Charge
		[255836] = Priority(), -- Transfusion Boss I
		[255835] = Priority(), -- Transfusion Boss II
		[250372] = Priority(), -- Lingering Nausea
		[257407] = Priority(), -- Pursuit
		[255434] = Priority(), -- Serrated Teeth
		[255371] = Priority(), -- Terrifying Visage
		-- Everbloom
		[427513] = Priority(), -- Noxious Discharge
		[428834] = Priority(), -- Verdant Eruption
		[427510] = Priority(), -- Noxious Charge
		[427863] = Priority(), -- Frostbolt I
		[169840] = Priority(), -- Frostbolt II
		[428084] = Priority(), -- Glacial Fusion
		[426991] = Priority(), -- Blazing Cinders
		[169179] = Priority(), -- Colossal Blow
		[164886] = Priority(), -- Dreadpetal Pollen
		[169445] = Priority(), -- Noxious Eruption
		[164294] = Priority(), -- Unchecked Growth I
		[164302] = Priority(), -- Unchecked Growth II
		[165123] = Priority(), -- Venom Burst
		[169658] = Priority(), -- Poisonous Claws
		[169839] = Priority(), -- Pyroblast
		[164965] = Priority(), -- Choking Vines
		-- Throne of the Tides
		[429048] = Priority(), -- Flame Shock
		[427668] = Priority(), -- Festering Shockwave
		[427670] = Priority(), -- Crushing Claw
		[76363] = Priority(), -- Wave of Corruption
		[426660] = Priority(), -- Razor Jaws
		[426727] = Priority(), -- Acid Barrage
		[428404] = Priority(), -- Blotting Darkness
		[428403] = Priority(), -- Grimy
		[426663] = Priority(), -- Ravenous Pursuit
		[426783] = Priority(), -- Mind Flay
		[75992] = Priority(), -- Lightning Surge
		[428868] = Priority(), -- Putrid Roar
		[428407] = Priority(), -- Blotting Barrage
		[427559] = Priority(), -- Bubbling Ooze
		[76516] = Priority(), -- Poisoned Spear
		[428542] = Priority(), -- Crushing Depths
		[426741] = Priority(), -- Shellbreaker
		[76820] = Priority(), -- Hex
		[426608] = Priority(), -- Null Blast
		[426688] = Priority(), -- Volatile Acid
		[428103] = Priority(), -- Frostbolt
		----------------------------------------------------------
		---------------- Dragonflight (Season 2) -----------------
		----------------------------------------------------------
		-- Freehold
		[258323] = Priority(), -- Infected Wound
		[257775] = Priority(), -- Plague Step
		[257908] = Priority(), -- Oiled Blade
		[257436] = Priority(), -- Poisoning Strike
		[274389] = Priority(), -- Rat Traps
		[274555] = Priority(), -- Scabrous Bites
		[258875] = Priority(), -- Blackout Barrel
		[256363] = Priority(), -- Ripper Punch
		[258352] = Priority(), -- Grapeshot
		[413136] = Priority(), -- Whirling Dagger 1
		[413131] = Priority(), -- Whirling Dagger 2
		-- Neltharion's Lair
		[199705] = Priority(), -- Devouring
		[199178] = Priority(), -- Spiked Tongue
		[210166] = Priority(), -- Toxic Retch 1
		[217851] = Priority(), -- Toxic Retch 2
		[193941] = Priority(), -- Impaling Shard
		[183465] = Priority(), -- Viscid Bile
		[226296] = Priority(), -- Piercing Shards
		[226388] = Priority(), -- Rancid Ooze
		[200154] = Priority(), -- Burning Hatred
		[183407] = Priority(), -- Acid Splatter
		[215898] = Priority(), -- Crystalline Ground
		[188494] = Priority(), -- Rancid Maw
		[192800] = Priority(), -- Choking Dust
		-- Underrot
		[265468] = Priority(), -- Withering Curse
		[278961] = Priority(), -- Decaying Mind
		[259714] = Priority(), -- Decaying Spores
		[272180] = Priority(), -- Death Bolt
		[272609] = Priority(), -- Maddening Gaze
		[269301] = Priority(), -- Putrid Blood
		[265533] = Priority(), -- Blood Maw
		[265019] = Priority(), -- Savage Cleave
		[265377] = Priority(), -- Hooked Snare
		[265625] = Priority(), -- Dark Omen
		[260685] = Priority(), -- Taint of G'huun
		[266107] = Priority(), -- Thirst for Blood
		[260455] = Priority(), -- Serrated Fangs
		-- Vortex Pinnacle
		[87618] = Priority(), -- Static Cling
		[410870] = Priority(), -- Cyclone
		[86292] = Priority(), -- Cyclone Shield
		[88282] = Priority(), -- Upwind of Altairus
		[88286] = Priority(), -- Downwind of Altairus
		[410997] = Priority(), -- Rushing Wind
		[411003] = Priority(), -- Turbulence
		[87771] = Priority(), -- Crusader Strike
		[87759] = Priority(), -- Shockwave
		[88314] = Priority(), -- Twisting Winds
		[76622] = Priority(), -- Sunder Armor
		[88171] = Priority(), -- Hurricane
		[88182] = Priority(), -- Lethargic Poison
		---------------------------------------------------------
		------------ Amirdrassil: The Dream's Hope --------------
		---------------------------------------------------------
		-- Gnarlroot
		[421972] = Priority(), -- Controlled Burn
		[424734] = Priority(), -- Uprooted Agony
		[426106] = Priority(), -- Dreadfire Barrage
		[425002] = Priority(), -- Ember-Charred I
		[421038] = Priority(), -- Ember-Charred II
		-- Igira the Cruel
		[414367] = Priority(), -- Gathering Torment
		[424065] = Priority(), -- Wracking Skewer I
		[416056] = Priority(), -- Wracking Skever II
		[414888] = Priority(), -- BPriorityering Spear
		-- Volcoross
		[419054] = Priority(), -- Molten Venom
		[421207] = Priority(), -- Coiling Flames
		[423494] = Priority(), -- Tidal Blaze
		[423759] = Priority(), -- Serpent's Crucible
		-- Council of Dreams
		[420948] = Priority(), -- Barreling Charge
		[421032] = Priority(), -- Captivating Finale
		[420858] = Priority(), -- Poisonous Javelin
		[418589] = Priority(), -- Polymorph Bomb
		[421031] = Priority(6), -- Song of the Dragon
		[426390] = Priority(), -- Corrosive Pollen
		-- Larodar, Keeper of the Flame
		[425888] = Priority(), -- Igniting Growth
		[426249] = Priority(), -- Blazing Coalescence
		[421594] = Priority(), -- Smoldering Suffocation
		[427299] = Priority(), -- Flash Fire
		[428901] = Priority(), -- Ashen Devastation
		-- Nymue, Weaver of the Cycle
		[427137] = Priority(), -- Threads of Life I
		[427138] = Priority(), -- Threads of Life II
		[426520] = Priority(), -- Weaver's Burden
		[428273] = Priority(), -- Woven Resonance
		-- Smolderon
		[426018] = Priority(), -- Seeking Inferno
		[421455] = Priority(), -- Overheated
		[421643] = Priority(5), -- Emberscar's Mark
		[421656] = Priority(), -- Cauterizing Wound
		[425574] = Priority(), -- Lingering Burn
		-- Tindral Sageswift, Seer of the Flame
		[427297] = Priority(), -- Flame Surge
		[424581] = Priority(), -- Fiery Growth
		[424580] = Priority(), -- Falling Stars
		[424578] = Priority(), -- Blazing Mushroom
		[424579] = Priority(6), -- Suppressive Ember
		[424495] = Priority(), -- Mass Entanblement
		[424665] = Priority(), -- Seed of Flame
		-- Fyrakk the Blazing
		---------------------------------------------------------
		------------ Aberrus, the Shadowed Crucible -------------
		---------------------------------------------------------
		-- Kazzara
		[406530] = Priority(), -- Riftburn
		[402420] = Priority(), -- Molten Scar
		[402253] = Priority(), -- Ray of Anguish
		[406525] = Priority(), -- Dread Rift
		[404743] = Priority(), -- Terror Claws
		-- Molgoth
		[405084] = Priority(), -- Lingering Umbra
		[405645] = Priority(), -- Engulfing Heat
		[405642] = Priority(), -- BPriorityering Twilight
		[402617] = Priority(), -- Blazing Heat
		[401809] = Priority(), -- Corrupting Shadow
		[405394] = Priority(), -- Shadowflame
		[405914] = Priority(), -- Withering Vulnerability 1
		[413597] = Priority(), -- Withering Vulnerability 2
		-- Experimentation of Dracthyr
		[406317] = Priority(), -- Mutilation 1
		[406365] = Priority(), -- Mutilation 2
		[405392] = Priority(), -- Disintegrate 1
		[405423] = Priority(), -- Disintegrate 2
		[406233] = Priority(), -- Deep Breath
		[407327] = Priority(), -- Unstable Essence
		[406313] = Priority(), -- Infused Strikes
		[407302] = Priority(), -- Infused Explosion
		-- Zaqali Invasion
		[408873] = Priority(), -- Heavy Cudgel
		[410353] = Priority(), -- Flaming Cudgel
		[407017] = Priority(), -- Vigorous Gale
		[401407] = Priority(), -- Blazing Spear 1
		[401452] = Priority(), -- Blazing Spear 2
		[409275] = Priority(), -- Magma Flow
		-- Rashok
		[407547] = Priority(), -- Flaming Upsurge
		[407597] = Priority(), -- Earthen Crush
		[405819] = Priority(), -- Searing Slam
		[408857] = Priority(), -- Doom Flame
		-- Zskarn
		[404955] = Priority(), -- Shrapnel Bomb
		[404010] = Priority(), -- Unstable Embers
		[404942] = Priority(), -- Searing Claws
		[403978] = Priority(), -- Blast Wave
		[405592] = Priority(), -- Salvage Parts
		[405462] = Priority(), -- Dragonfire Traps
		[409942] = Priority(), -- Elimination Protocol
		-- Magmorax
		[404846] = Priority(), -- Incinerating Maws 1
		[408955] = Priority(), -- Incinerating Maws 2
		[402994] = Priority(), -- Molten Spittle
		-- Echo of Neltharion
		[409373] = Priority(), -- Disrupt Earth
		[407220] = Priority(), -- Rushing Shadows 1
		[407182] = Priority(), -- Rushing Shadows 2
		[405484] = Priority(), -- Surrendering to Corruption
		[409058] = Priority(), -- Seeping Lava
		[402120] = Priority(), -- Collapsed Earth
		[407728] = Priority(), -- Sundered Shadow
		[401998] = Priority(), -- Calamitous Strike
		[408160] = Priority(), -- Shadow Strike
		[403846] = Priority(), -- Sweeping Shadows
		[401133] = Priority(), -- Wildshift (Druid)
		[401131] = Priority(), -- Wild Summoning (Warlock)
		[401130] = Priority(), -- Wild Magic (Mage)
		[401135] = Priority(), -- Wild Breath (Evoker)
		[408071] = Priority(), -- Shapeshifter's Fervor
		-- Scalecommander Sarkareth
		[403520] = Priority(), -- Embrace of Nothingness
		[401383] = Priority(), -- Oppressing Howl
		[401951] = Priority(), -- Oblivion
		[407496] = Priority(), -- Infinite Duress
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
		[388290] = Priority(4), -- Cyclone
		-- Kurog Grimtotem
		[377780] = Priority(5), -- Skeletal Fractures
		[372514] = Priority(5), -- Frost Bite
		[374554] = Priority(4), -- Lava Pool
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
