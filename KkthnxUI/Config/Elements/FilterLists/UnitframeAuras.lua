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
		------------------------- General ------------------------
		----------------------------------------------------------
		-- Misc
		[160029] = Priority(), -- Resurrecting (Pending CR)
		----------------------------------------------------------
		-------------------- Mythic+ Specific --------------------
		----------------------------------------------------------
		-- General Affixes
		[226512] = Priority(), -- Sanguine
		[240559] = Priority(), -- Grievous
		[240443] = Priority(), -- Bursting
		[409492] = Priority(), -- Afflicted Cry
		----------------------------------------------------------
		---------------- The War Within Dungeons -----------------
		----------------------------------------------------------
		-- The Stonevault (Season 1)
		[427329] = Priority(), -- Void Corruption
		[435813] = Priority(), -- Void Empowerment
		[423572] = Priority(), -- Void Empowerment
		[424889] = Priority(), -- Seismic Reverberation
		[424795] = Priority(), -- Refracting Beam
		[457465] = Priority(), -- Entropy
		[425974] = Priority(), -- Ground Pound
		[445207] = Priority(), -- Piercing Wail
		[428887] = Priority(), -- Smashed
		[427382] = Priority(), -- Concussive Smash
		[449154] = Priority(), -- Molten Mortar
		[427361] = Priority(), -- Fracture
		[443494] = Priority(), -- Crystalline Eruption
		[424913] = Priority(), -- Volatile Explosion
		[443954] = Priority(), -- Exhaust Vents
		[426308] = Priority(), -- Void Infection
		[429999] = Priority(), -- Flaming Scrap
		[429545] = Priority(), -- Censoring Gear
		[428819] = Priority(), -- Exhaust Vents
		-- City of Threads (Season 1)
		[434722] = Priority(), -- Subjugate
		[439341] = Priority(), -- Splice
		[440437] = Priority(), -- Shadow Shunpo
		[448561] = Priority(), -- Shadows of Doubt
		[440107] = Priority(), -- Knife Throw
		[439324] = Priority(), -- Umbral Weave
		[442285] = Priority(), -- Corrupted Coating
		[440238] = Priority(), -- Ice Sickles
		[461842] = Priority(), -- Oozing Smash
		[434926] = Priority(), -- Lingering Influence
		[440310] = Priority(), -- Chains of Oppression
		[439646] = Priority(), -- Process of Elimination
		[448562] = Priority(), -- Doubt
		[441391] = Priority(), -- Dark Paranoia
		[461989] = Priority(), -- Oozing Smash
		[441298] = Priority(), -- Freezing Blood
		[441286] = Priority(), -- Dark Paranoia
		[452151] = Priority(), -- Rigorous Jab
		[451239] = Priority(), -- Brutal Jab
		[443509] = Priority(), -- Ravenous Swarm
		[443437] = Priority(), -- Shadows of Doubt
		[451295] = Priority(), -- Void Rush
		[443427] = Priority(), -- Web Bolt
		[461630] = Priority(), -- Venomous Spray
		[445435] = Priority(), -- Black Blood
		[443401] = Priority(), -- Venom Strike
		[443430] = Priority(), -- Silk Binding
		[443438] = Priority(), -- Doubt
		[443435] = Priority(), -- Twist Thoughts
		[443432] = Priority(), -- Silk Binding
		[448047] = Priority(), -- Web Wrap
		[451426] = Priority(), -- Gossamer Barrage
		[446718] = Priority(), -- Umbral Weave
		[450055] = Priority(), -- Gutburst
		[450783] = Priority(), -- Perfume Toss
		-- The Dawnbreaker (Season 1)
		[463428] = Priority(), -- Lingering Erosion
		[426736] = Priority(), -- Shadow Shroud
		[434096] = Priority(), -- Sticky Webs
		[453173] = Priority(), -- Collapsing Night
		[426865] = Priority(), -- Dark Orb
		[434090] = Priority(), -- Spinneret's Strands
		[434579] = Priority(), -- Corrosion
		[426735] = Priority(), -- Burning Shadows
		[434576] = Priority(), -- Acidic Stupor
		[452127] = Priority(), -- Animate Shadows
		[438957] = Priority(), -- Acid Pools
		[434441] = Priority(), -- Rolling Acid
		[451119] = Priority(), -- Abyssal Blast
		[453345] = Priority(), -- Abyssal Rot
		[449332] = Priority(), -- Encroaching Shadows
		[431333] = Priority(), -- Tormenting Beam
		[431309] = Priority(), -- Ensnaring Shadows
		[451107] = Priority(), -- Bursting Cocoon
		[434406] = Priority(), -- Rolling Acid
		[431491] = Priority(), -- Tainted Slash
		[434113] = Priority(), -- Spinneret's Strands
		[431350] = Priority(), -- Tormenting Eruption
		[431365] = Priority(), -- Tormenting Ray
		[434668] = Priority(), -- Sparking Arathi Bomb
		[460135] = Priority(), -- Dark Scars
		[451098] = Priority(), -- Tacky Nova
		[450855] = Priority(), -- Dark Orb
		[431494] = Priority(), -- Black Edge
		[451115] = Priority(), -- Terrifying Slam
		[432448] = Priority(), -- Stygian Seed
		-- Ara-Kara, City of Echoes (Season 1)
		[461487] = Priority(), -- Cultivated Poisons
		[432227] = Priority(), -- Venom Volley
		[432119] = Priority(), -- Faded
		[433740] = Priority(), -- Infestation
		[439200] = Priority(), -- Voracious Bite
		[433781] = Priority(), -- Ceaseless Swarm
		[432132] = Priority(), -- Erupting Webs
		[434252] = Priority(), -- Massive Slam
		[432031] = Priority(), -- Grasping Blood
		[438599] = Priority(), -- Bleeding Jab
		[438618] = Priority(), -- Venomous Spit
		[436401] = Priority(), -- AUGH!
		[434830] = Priority(), -- Vile Webbing
		[436322] = Priority(), -- Poison Bolt
		[434083] = Priority(), -- Ambush
		[433843] = Priority(), -- Erupting Webs
		-- The Rookery (Season 2)
		-- Priory of the Sacred Flame (Season 2)
		-- Cinderbrew Meadery (Season 2)
		-- Darkflame Cleft (Season 2)
		----------------------------------------------------------
		--------------- The War Within (Season 1) ----------------
		----------------------------------------------------------
		-- Mists of Tirna Scithe
		[325027] = Priority(), -- Bramble Burst
		[323043] = Priority(), -- Bloodletting
		[322557] = Priority(), -- Soul Split
		[331172] = Priority(), -- Mind Link
		[322563] = Priority(), -- Marked Prey
		[322487] = Priority(), -- Overgrowth 1
		[322486] = Priority(), -- Overgrowth 2
		[328756] = Priority(), -- Repulsive Visage
		[325021] = Priority(), -- Mistveil Tear
		[321891] = Priority(), -- Freeze Tag Fixation
		[325224] = Priority(), -- Anima Injection
		[326092] = Priority(), -- Debilitating Poison
		[325418] = Priority(), -- Volatile Acid
		-- The Necrotic Wake
		[321821] = Priority(), -- Disgusting Guts
		[323365] = Priority(), -- Clinging Darkness
		[338353] = Priority(), -- Goresplatter
		[333485] = Priority(), -- Disease Cloud
		[338357] = Priority(), -- Tenderize
		[328181] = Priority(), -- Frigid Cold
		[320170] = Priority(), -- Necrotic Bolt
		[323464] = Priority(), -- Dark Ichor
		[323198] = Priority(), -- Dark Exile
		[343504] = Priority(), -- Dark Grasp
		[343556] = Priority(), -- Morbid Fixation 1
		[338606] = Priority(), -- Morbid Fixation 2
		[324381] = Priority(), -- Chill Scythe
		[320573] = Priority(), -- Shadow Well
		[333492] = Priority(), -- Necrotic Ichor
		[334748] = Priority(), -- Drain Fluids
		[333489] = Priority(), -- Necrotic Breath
		[320717] = Priority(), -- Blood Hunger
		-- Siege of Boralus
		[257168] = Priority(), -- Cursed Slash
		[272588] = Priority(), -- Rotting Wounds
		[272571] = Priority(), -- Choking Waters
		[274991] = Priority(), -- Putrid Waters
		[275835] = Priority(), -- Stinging Venom Coating
		[273930] = Priority(), -- Hindering Cut
		[257292] = Priority(), -- Heavy Slash
		[261428] = Priority(), -- Hangman's Noose
		[256897] = Priority(), -- Clamping Jaws
		[272874] = Priority(), -- Trample
		[273470] = Priority(), -- Gut Shot
		[272834] = Priority(), -- Viscous Slobber
		[257169] = Priority(), -- Terrifying Roar
		[272713] = Priority(), -- Crushing Slam
		-- Grim Batol
		[449885] = Priority(), -- Shadow Gale 1
		[461513] = Priority(), -- Shadow Gale 2
		[449474] = Priority(), -- Molten Spark
		[456773] = Priority(), -- Twilight Wind
		[448953] = Priority(), -- Rumbling Earth
		[447268] = Priority(), -- Skullsplitter
		[449536] = Priority(), -- Molten Pool
		[450095] = Priority(), -- Curse of Entropy
		[448057] = Priority(), -- Abyssal Corruption
		[451871] = Priority(), -- Mass Temor
		[451613] = Priority(), -- Twilight Flame
		[451378] = Priority(), -- Rive
		[76711] = Priority(), -- Sear Mind
		[462220] = Priority(), -- Blazing Shadowflame
		[451395] = Priority(), -- Corrupt
		[82850] = Priority(), -- Flaming Fixate
		[451241] = Priority(), -- Shadowflame Slash
		[451965] = Priority(), -- Molten Wake
		[451224] = Priority(), -- Enveloping Shadowflame
		---------------------------------------------------------
		------------------- Nerub'ar Palace ---------------------
		---------------------------------------------------------
		-- Ulgrax the Devourer
		[434705] = Priority(), -- Tenderized
		[435138] = Priority(), -- Digestive Acid
		[439037] = Priority(), -- Disembowel
		[439419] = Priority(), -- Stalker Netting
		[434778] = Priority(), -- Brutal Lashings
		[435136] = Priority(), -- Venomous Lash
		[438012] = Priority(), -- Hungering Bellows
		-- The Bloodbound Horror
		[442604] = Priority(), -- Goresplatter
		[445570] = Priority(), -- Unseeming Blight
		[443612] = Priority(), -- Baneful Shift
		[443042] = Priority(), -- Grasp From Beyond
		-- Sikran
		[435410] = Priority(), -- Phase Lunge
		[458277] = Priority(), -- Shattering Sweep
		[438845] = Priority(), -- Expose
		[433517] = Priority(), -- Phase Blades 1
		[434860] = Priority(), -- Phase Blades 2
		[459785] = Priority(), -- Cosmic Residue
		[459273] = Priority(), -- Cosmic Shards
		-- Rasha'nan
		[439785] = Priority(), -- Corrosion
		[439786] = Priority(), -- Rolling Acid 1
		[439790] = Priority(), -- Rolling Acid 2
		[439787] = Priority(), -- Acidic Stupor
		[458067] = Priority(), -- Savage Wound
		[456170] = Priority(), -- Spinneret's Strands 1
		[439783] = Priority(), -- Spinneret's Strands 2
		[439780] = Priority(), -- Sticky Webs
		[439776] = Priority(), -- Acid Pool
		[455287] = Priority(), -- Infested Bite
		-- Eggtender Ovi'nax
		[442257] = Priority(), -- Infest
		[442799] = Priority(), -- Sanguine Overflow
		[441362] = Priority(), -- Volatile Concotion
		[442660] = Priority(), -- Rupture
		[440421] = Priority(), -- Experimental Dosage
		[442250] = Priority(), -- Fixate
		[442437] = Priority(), -- Violent Discharge
		[443274] = Priority(), -- Reverberation
		-- Nexus-Princess Ky'veza
		[440377] = Priority(), -- Void Shredders
		[436870] = Priority(), -- Assassination
		[440576] = Priority(), -- Chasmal Gash
		[437343] = Priority(), -- Queensbane
		[436664] = Priority(), -- Regicide 1
		[436666] = Priority(), -- Regicide 2
		[436671] = Priority(), -- Regicide 3
		[435535] = Priority(), -- Regicide 4
		[436665] = Priority(), -- Regicide 5
		[436663] = Priority(), -- Regicide 6
		-- The Silken Court
		[450129] = Priority(), -- Entropic Desolation
		[449857] = Priority(), -- Impaled
		[438749] = Priority(), -- Scarab Fixation
		[438708] = Priority(), -- Stinging Swarm
		[438218] = Priority(), -- Piercing Strike
		[454311] = Priority(), -- Barbed Webs
		[438773] = Priority(), -- Shattered Shell
		[438355] = Priority(), -- Cataclysmic Entropy
		[438656] = Priority(), -- Venomous Rain
		[441772] = Priority(), -- Void Bolt
		[441788] = Priority(), -- Web Vortex
		[440001] = Priority(), -- Binding Webs
		-- Queen Ansurek
		-- TODO: No raid testing available for this boss
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
		[199042] = Priority(1), -- Thunderstruck
		[236077] = Priority(2), -- Disarm
		[105771] = Priority(2), -- Charge
		-- Racial
		[20549] = Priority(4), -- War Stomp
		[107079] = Priority(4), -- Quaking Palm
	},
}
