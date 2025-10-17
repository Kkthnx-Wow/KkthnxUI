local K, C = KkthnxUI[1], KkthnxUI[2]

local function Priority(priorityOverride, stackThreshold)
	return {
		enable = true,
		priority = priorityOverride or 0,
		stackThreshold = stackThreshold or 0,
	}
end

C.DebuffsTracking_PvE = {
	["type"] = "Whitelist",
	["spells"] = {
		-- Manaforge Omega
		-- Plexus Sentinel
		[1219459] = Priority(3), -- Manifest Matrices
		[1219607] = Priority(3), -- Eradicating Salvo
		[1218625] = Priority(3), -- Displacement Matrix
		-- Loom'ithar
		[1226311] = Priority(5), -- Infusion Tether
		[1237212] = Priority(4), -- Piercing Strand
		[1226721] = Priority(6), -- Silken Snare
		[1247045] = Priority(3), -- Hyper Infusion
		[1237307] = Priority(3), -- Lair Weaving
		-- Soulbinder Naazindhri
		[1227276] = Priority(3), -- Soulfray Annihilation
		[1226827] = Priority(3), -- Soulrend Orb
		[1227052] = Priority(3), -- Void Burst
		-- Forgeweaver Araz
		[1234324] = Priority(3), -- Photon Blast
		[1228214] = Priority(3), -- Astral Harvest
		[1243901] = Priority(3), -- Void Harvest
		-- The Soul Hunters
		[1227847] = Priority(3), -- The Hunt
		[1241946] = Priority(3), -- Frailty
		-- Fractillus
		[1233411] = Priority(3), -- Crystalline Shockwave
		-- Nexus-King Salhadaar
		[1227549] = Priority(3), -- Banishment
		[1226362] = Priority(3), -- Twilight Scar
		[1228056] = Priority(3), -- Reap
		-- Dimensius, the All-Devouring
		[1239270] = Priority(3), -- Voidwarding
		[1250055] = Priority(3), -- Voidgrasp
		[1243699] = Priority(3), -- Spatial Fragment
		[1249425] = Priority(3), -- Mass Destruction

		-- Liberation of Undermine
		-- Vexie and the Geargrinders
		[465865] = Priority(3), -- Tank Buster
		[459669] = Priority(3), -- Spew Oil
		-- Cauldron of Carnage
		[1213690] = Priority(3), -- Molten Phlegm
		[1214009] = Priority(3), -- Voltaic Image
		-- Rik Reverb
		[1217122] = Priority(3), -- Lingering Voltage
		[468119] = Priority(3), -- Resonant Echoes
		[467044] = Priority(3), -- Faulty Zap
		-- Stix Bunkjunker
		[461536] = Priority(3), -- Rolling Rubbish
		[1217954] = Priority(3), -- Meltdown
		[465346] = Priority(3), -- Sorted
		[466748] = Priority(3), -- Infected Bite
		-- Sprocketmonger Lockenstock
		[1218342] = Priority(3), -- Unstable Shrapnel
		[465917] = Priority(3), -- Gravi-Gunk
		[471308] = Priority(3), -- Blisterizer Mk. II
		-- The One-Armed Bandit
		[471927] = Priority(3), -- Withering Flames
		[460420] = Priority(3), -- Crushed!
		-- Mug'Zee, Heads of Security
		[466476] = Priority(3), -- Frostshatter Boots
		[466509] = Priority(3), -- Stormfury Finger Gun
		[1215488] = Priority(3), -- Disintegration Beam
		-- Chrome King Gallywix
		[466154] = Priority(3), -- Blast Burns
		[466834] = Priority(4), -- Shock Barrage
		[469362] = Priority(4), -- Charged Giga Bomb

		-- Nerub'ar Palace
		-- Ulgrax the Devourer
		[434705] = Priority(3), -- Tenderized
		[435138] = Priority(3), -- Digestive Acid
		[439037] = Priority(3), -- Disembowel
		[439419] = Priority(3), -- Stalker Netting
		[434778] = Priority(3), -- Brutal Lashings
		[435136] = Priority(3), -- Venomous Lash
		[438012] = Priority(3), -- Hungering Bellows
		-- The Bloodbound Horror
		[442604] = Priority(3), -- Goresplatter
		[445570] = Priority(3), -- Unseeming Blight
		[443612] = Priority(3), -- Baneful Shift
		[443042] = Priority(3), -- Grasp From Beyond
		-- Sikran
		[435410] = Priority(3), -- Phase Lunge
		[458277] = Priority(3), -- Shattering Sweep
		[438845] = Priority(3), -- Expose
		[433517] = Priority(3), -- Phase Blades
		[459785] = Priority(3), -- Cosmic Residue
		[459273] = Priority(3), -- Cosmic Shards
		-- Rasha'nan
		[439785] = Priority(3), -- Corrosion
		[439786] = Priority(3), -- Rolling Acid
		[439787] = Priority(3), -- Acidic Stupor
		[458067] = Priority(3), -- Savage Wound
		[456170] = Priority(3), -- Spinneret's Strands
		[439780] = Priority(3), -- Sticky Webs
		[439776] = Priority(3), -- Acid Pool
		[455287] = Priority(3), -- Infested Bite
		-- Eggtender Ovi'nax
		[442257] = Priority(3), -- Infest
		[442799] = Priority(3), -- Sanguine Overflow
		[441362] = Priority(3), -- Volatile Concotion
		[442660] = Priority(3), -- Rupture
		[440421] = Priority(3), -- Experimental Dosage
		[442250] = Priority(3), -- Fixate
		[442437] = Priority(3), -- Violent Discharge
		[443274] = Priority(3), -- Reverberation
		-- Nexus-Princess Ky'veza
		[440377] = Priority(3), -- Void Shredders
		[436870] = Priority(3), -- Assassination
		[440576] = Priority(3), -- Chasmal Gash
		[437343] = Priority(3), -- Queensbane
		[436664] = Priority(3), -- Regicide
		-- The Silken Court
		[450129] = Priority(3), -- Entropic Desolation
		[449857] = Priority(3), -- Impaled
		[438749] = Priority(3), -- Scarab Fixation
		[438708] = Priority(3), -- Stinging Swarm
		[454311] = Priority(3), -- Barbed Webs
		[438773] = Priority(3), -- Shattered Shell
		[438355] = Priority(3), -- Cataclysmic Entropy
		[438656] = Priority(3), -- Venomous Rain
		[441772] = Priority(3), -- Void Bolt
		[441788] = Priority(3), -- Web Vortex
		[440001] = Priority(3), -- Binding Webs
		[438218] = Priority(3), -- Piercing Strike
		-- Queen Ansurek
		[441865] = Priority(3), -- Royal Shackles
		[436800] = Priority(3), -- Liquefy
		[455404] = Priority(3), -- Feast
		[439829] = Priority(3), -- Silken Tomb
		[437586] = Priority(3), -- Reactive Toxin

		-- Dungeon Debuffs
		-- The War Within Season 1
		[440313] = Priority(6), -- Void Rift

		-- The Rookery (Season 2)
		[429493] = Priority(3), -- Unstable Corruption
		[424739] = Priority(3), -- Chaotic Corruption
		[426160] = Priority(3), -- Dark Gravity
		[1214324] = Priority(3), -- Crashing Thunder
		[424966] = Priority(3), -- Lingering Void
		[467907] = Priority(3), -- Festering Void
		[458082] = Priority(3), -- Stormrider's Charge
		[472764] = Priority(3), -- Void Extraction
		[427616] = Priority(3), -- Energized Barrage
		[430814] = Priority(3), -- Attracting Shadows
		[430179] = Priority(3), -- Seeping Corruption
		[1214523] = Priority(3), -- Feasting Void

		-- Priory of the Sacred Flame (Season 2)
		[424414] = Priority(3), -- Pierce Armor
		[423015] = Priority(3), -- Castigator's Shield
		[447439] = Priority(3), -- Savage Mauling
		[425556] = Priority(3), -- Sanctified Ground
		[428170] = Priority(3), -- Blinding Light
		[448492] = Priority(3), -- Thunderclap
		[427621] = Priority(3), -- Impale
		[446403] = Priority(3), -- Sacrificial Flame
		[451764] = Priority(3), -- Radiant Flame
		[424426] = Priority(3), -- Lunging Strike
		[448787] = Priority(3), -- Purification
		[435165] = Priority(3), -- Blazing Strike
		[448515] = Priority(3), -- Divine Judgment
		[427635] = Priority(3), -- Grievous Rip
		[427897] = Priority(3), -- Heat Wave
		[424430] = Priority(3), -- Consecration
		[453461] = Priority(3), -- Caltrops
		[427900] = Priority(3), -- Molten Pool

		-- Cinderbrew Meadery (Season 2)
		[441397] = Priority(3), -- Bee Venom
		[431897] = Priority(3), -- Rowdy Yell
		[442995] = Priority(3), -- Swarming Surprise
		[437956] = Priority(3), -- Erupting Inferno
		[434773] = Priority(3), -- Mean Mug
		[438975] = Priority(3), -- Shredding Sting
		[463220] = Priority(3), -- Volatile Keg
		[449090] = Priority(3), -- Reckless Delivery
		[437721] = Priority(3), -- Boiling Flames
		[441179] = Priority(3), -- Oozing Honey
		[434707] = Priority(3), -- Cinderbrew Toss
		[445180] = Priority(3), -- Crawling Brawl
		[442589] = Priority(3), -- Beeswax
		[435789] = Priority(3), -- Cindering Wounds
		[432182] = Priority(3), -- Throw Cinderbrew
		[436644] = Priority(3), -- Burning Ricochet
		[436624] = Priority(3), -- Cash Cannon
		[439325] = Priority(3), -- Burning Fermentation
		[432196] = Priority(3), -- Hot Honey
		[439586] = Priority(3), -- Fluttering Wing
		[440141] = Priority(3), -- Honey Marinade

		-- Darkflame Cleft (Season 2)
		[426943] = Priority(3), -- Rising Gloom
		[427015] = Priority(3), -- Shadowblast
		[422648] = Priority(3), -- Darkflame Pickaxe
		[1218308] = Priority(3), -- Enkindling Inferno
		[422245] = Priority(3), -- Rock Buster
		[423693] = Priority(3), -- Luring Candleflame
		[421638] = Priority(3), -- Wicklighter Barrage
		[424223] = Priority(3), -- Incite Flames
		[421146] = Priority(3), -- Throw Darkflame
		[427180] = Priority(3), -- Fear of the Gloom
		[424322] = Priority(3), -- Explosive Flame
		[420307] = Priority(3), -- Candlelight
		[422806] = Priority(3), -- Smothering Shadows
		[469620] = Priority(3), -- Creeping Shadow
		[443694] = Priority(3), -- Crude Weapons
		[428019] = Priority(3), -- Flashpoint
		[423501] = Priority(3), -- Wild Wallop
		[426277] = Priority(3), -- One-Hand Headlock
		[423654] = Priority(3), -- Ouch!
		[421653] = Priority(3), -- Cursed Wax
		[421067] = Priority(3), -- Molten Wax
		[426883] = Priority(3), -- Bonk!
		[440653] = Priority(3), -- Surging Flamethrower

		-- Operation: Floodgate (Season 2)
		[462737] = Priority(3), -- Black Blood Wound
		[1213803] = Priority(3), -- Nailed
		[468672] = Priority(3), -- Pinch
		[468616] = Priority(3), -- Leaping Spark
		[469799] = Priority(3), -- Overcharge
		[469811] = Priority(3), -- Backwash
		[468680] = Priority(3), -- Crabsplosion
		[473051] = Priority(3), -- Rushing Tide
		[474351] = Priority(3), -- Shreddation Sawblade
		[465830] = Priority(3), -- Warp Blood
		[468723] = Priority(3), -- Shock Water
		[474388] = Priority(3), -- Flamethrower
		[472338] = Priority(3), -- Surveyed Ground
		[462771] = Priority(3), -- Surveying Beam
		[473836] = Priority(3), -- Electrocrush
		[470038] = Priority(3), -- Razorchoke Vines
		[473713] = Priority(3), -- Kinetic Explosive Gel
		[468811] = Priority(3), -- Gigazap
		[466188] = Priority(3), -- Thunder Punch
		[460965] = Priority(3), -- Barreling Charge
		[472878] = Priority(3), -- Sludge Claws
		[473224] = Priority(3), -- Sonic Boom

		-- The Stonevault (Season 1)
		[427329] = Priority(3), -- Void Corruption
		[435813] = Priority(3), -- Void Empowerment
		[423572] = Priority(3), -- Void Empowerment
		[424889] = Priority(3), -- Seismic Reverberation
		[424795] = Priority(3), -- Refracting Beam
		[457465] = Priority(3), -- Entropy
		[425974] = Priority(3), -- Ground Pound
		[445207] = Priority(3), -- Piercing Wail
		[428887] = Priority(3), -- Smashed
		[427382] = Priority(3), -- Concussive Smash
		[449154] = Priority(3), -- Molten Mortar
		[427361] = Priority(3), -- Fracture
		[443494] = Priority(3), -- Crystalline Eruption
		[424913] = Priority(3), -- Volatile Explosion
		[443954] = Priority(3), -- Exhaust Vents
		[426308] = Priority(3), -- Void Infection
		[429999] = Priority(3), -- Flaming Scrap
		[429545] = Priority(3), -- Censoring Gear
		[428819] = Priority(3), -- Exhaust Vents

		-- City of Threads (Season 1)
		[434722] = Priority(3), -- Subjugate
		[439341] = Priority(3), -- Splice
		[440437] = Priority(3), -- Shadow Shunpo
		[448561] = Priority(3), -- Shadows of Doubt
		[440107] = Priority(3), -- Knife Throw
		[439324] = Priority(3), -- Umbral Weave
		[442285] = Priority(3), -- Corrupted Coating
		[440238] = Priority(3), -- Ice Sickles
		[461842] = Priority(3), -- Oozing Smash
		[434926] = Priority(3), -- Lingering Influence
		[440310] = Priority(3), -- Chains of Oppression
		[439646] = Priority(3), -- Process of Elimination
		[448562] = Priority(3), -- Doubt
		[441391] = Priority(3), -- Dark Paranoia
		[461989] = Priority(3), -- Oozing Smash
		[441298] = Priority(3), -- Freezing Blood
		[441286] = Priority(3), -- Dark Paranoia
		[452151] = Priority(3), -- Rigorous Jab
		[451239] = Priority(3), -- Brutal Jab
		[443509] = Priority(3), -- Ravenous Swarm
		[443437] = Priority(3), -- Shadows of Doubt
		[451295] = Priority(3), -- Void Rush
		[443427] = Priority(3), -- Web Bolt
		[461630] = Priority(3), -- Venomous Spray
		[445435] = Priority(3), -- Black Blood
		[443401] = Priority(3), -- Venom Strike
		[443430] = Priority(3), -- Silk Binding
		[443438] = Priority(3), -- Doubt
		[443435] = Priority(3), -- Twist Thoughts
		[443432] = Priority(3), -- Silk Binding
		[448047] = Priority(3), -- Web Wrap
		[451426] = Priority(3), -- Gossamer Barrage
		[446718] = Priority(3), -- Umbral Weave
		[450055] = Priority(3), -- Gutburst
		[450783] = Priority(3), -- Perfume Toss

		-- The Dawnbreaker (Season 1)
		[463428] = Priority(3), -- Lingering Erosion
		[426736] = Priority(3), -- Shadow Shroud
		[434096] = Priority(3), -- Sticky Webs
		[453173] = Priority(3), -- Collapsing Night
		[426865] = Priority(3), -- Dark Orb
		[434090] = Priority(3), -- Spinneret's Strands
		[434579] = Priority(3), -- Corrosion
		[426735] = Priority(3), -- Burning Shadows
		[434576] = Priority(3), -- Acidic Stupor
		[452127] = Priority(3), -- Animate Shadows
		[438957] = Priority(3), -- Acid Pools
		[434441] = Priority(3), -- Rolling Acid
		[451119] = Priority(3), -- Abyssal Blast
		[453345] = Priority(3), -- Abyssal Rot
		[449332] = Priority(3), -- Encroaching Shadows
		[431333] = Priority(3), -- Tormenting Beam
		[431309] = Priority(3), -- Ensnaring Shadows
		[451107] = Priority(3), -- Bursting Cocoon
		[434406] = Priority(3), -- Rolling Acid
		[431491] = Priority(3), -- Tainted Slash
		[434113] = Priority(3), -- Spinneret's Strands
		[431350] = Priority(3), -- Tormenting Eruption
		[431365] = Priority(3), -- Tormenting Ray
		[434668] = Priority(3), -- Sparking Arathi Bomb
		[460135] = Priority(3), -- Dark Scars
		[451098] = Priority(3), -- Tacky Nova
		[450855] = Priority(3), -- Dark Orb
		[431494] = Priority(3), -- Black Edge
		[451115] = Priority(3), -- Terrifying Slam
		[432448] = Priority(3), -- Stygian Seed

		-- Ara-Kara, City of Echoes (Season 1)
		[461487] = Priority(3), -- Cultivated Poisons
		[432227] = Priority(3), -- Venom Volley
		[432119] = Priority(3), -- Faded
		[433740] = Priority(3), -- Infestation
		[439200] = Priority(3), -- Voracious Bite
		[433781] = Priority(3), -- Ceaseless Swarm
		[432132] = Priority(3), -- Erupting Webs
		[434252] = Priority(3), -- Massive Slam
		[432031] = Priority(3), -- Grasping Blood
		[438599] = Priority(3), -- Bleeding Jab
		[438618] = Priority(3), -- Venomous Spit
		[436401] = Priority(3), -- AUGH!
		[434830] = Priority(3), -- Vile Webbing
		[436322] = Priority(3), -- Poison Bolt
		[434083] = Priority(3), -- Ambush
		[433843] = Priority(3), -- Erupting Webs

		-- Previous Expansion Dungeons (Season 2)
		-- Theater of Pain
		[333299] = Priority(3), -- Curse of Desolation
		[319539] = Priority(3), -- Soulless
		[326892] = Priority(3), -- Fixate
		[321768] = Priority(3), -- On the Hook
		[323825] = Priority(3), -- Grasping Rift
		[342675] = Priority(3), -- Bone Spear
		[323831] = Priority(3), -- Death Grasp
		[330608] = Priority(3), -- Vile Eruption
		[330868] = Priority(3), -- Necrotic Bolt Volley
		[323750] = Priority(3), -- Vile Gas
		[323406] = Priority(3), -- Jagged Gash
		[330700] = Priority(3), -- Decaying Blight
		[319626] = Priority(3), -- Phantasmal Parasite
		[324449] = Priority(3), -- Manifest Death
		[341949] = Priority(3), -- Withering Blight
		[333861] = Priority(3), -- Ricocheting Blade
		[1223804] = Priority(3), -- Well of Darkness

		-- The MOTHERLODE!!
		[263074] = Priority(4), -- Festering Bite
		[280605] = Priority(4), -- Brain Freeze
		[257337] = Priority(4), -- Shocking Claw
		[270882] = Priority(5), -- Blazing Azerite
		[268797] = Priority(4), -- Transmute: Enemy to Goo
		[259856] = Priority(4), -- Chemical Burn
		[269302] = Priority(3), -- Toxic Blades
		[280604] = Priority(3), -- Iced Spritzer
		[257371] = Priority(4), -- Tear Gas
		[257544] = Priority(4), -- Jagged Cut
		[268846] = Priority(4), -- Echo Blade
		[262794] = Priority(5), -- Energy Lash
		[262513] = Priority(5), -- Azerite Heartseeker
		[260838] = Priority(5), -- Homing Missle
		[263637] = Priority(4), -- Clothesline

		-- Operation: Mechagon
		[291928] = Priority(3), -- Giga-Zap
		[302274] = Priority(3), -- Fulminating Zap
		[298669] = Priority(3), -- Taze
		[295445] = Priority(3), -- Wreck
		[294929] = Priority(3), -- Blazing Chomp
		[297257] = Priority(3), -- Electrical Charge
		[294855] = Priority(3), -- Blossom Blast
		[291972] = Priority(3), -- Explosive Leap
		[285443] = Priority(3), -- "Hidden" Flame Cannon
		[291974] = Priority(3), -- Obnoxious Monologue
		[296150] = Priority(3), -- Vent Blast
		[298602] = Priority(3), -- Smoke Cloud
		[296560] = Priority(3), -- Clinging Static
		[297283] = Priority(3), -- Cave In
		[291914] = Priority(3), -- Cutting Beam
		[302384] = Priority(3), -- Static Discharge

		-- Previous Expansion Dungeons (Season 1)
		-- Mists of Tirna Scithe
		[325027] = Priority(3), -- Bramble Burst
		[323043] = Priority(3), -- Bloodletting
		[322557] = Priority(3), -- Soul Split
		[331172] = Priority(3), -- Mind Link
		[322563] = Priority(3), -- Marked Prey
		[322487] = Priority(3), -- Overgrowth
		[328756] = Priority(3), -- Repulsive Visage
		[325021] = Priority(3), -- Mistveil Tear
		[321891] = Priority(3), -- Freeze Tag Fixation
		[325224] = Priority(3), -- Anima Injection
		[326092] = Priority(3), -- Debilitating Poison
		[325418] = Priority(3), -- Volatile Acid

		-- The Necrotic Wake
		[321821] = Priority(3), -- Disgusting Guts
		[323365] = Priority(3), -- Clinging Darkness
		[338353] = Priority(3), -- Goresplatter
		[333485] = Priority(3), -- Disease Cloud
		[338357] = Priority(3), -- Tenderize
		[328181] = Priority(3), -- Frigid Cold
		[320170] = Priority(3), -- Necrotic Bolt
		[323464] = Priority(3), -- Dark Ichor
		[323198] = Priority(3), -- Dark Exile
		[343504] = Priority(3), -- Dark Grasp
		[343556] = Priority(3), -- Morbid Fixation
		[324381] = Priority(3), -- Chill Scythe
		[320573] = Priority(3), -- Shadow Well
		[333492] = Priority(3), -- Necrotic Ichor
		[334748] = Priority(3), -- Drain Fluids
		[333489] = Priority(3), -- Necrotic Breath
		[320717] = Priority(3), -- Blood Hunger

		-- Siege of Boralus
		[257168] = Priority(3), -- Cursed Slash
		[272588] = Priority(3), -- Rotting Wounds
		[272571] = Priority(3), -- Choking Waters
		[274991] = Priority(3), -- Putrid Waters
		[275835] = Priority(3), -- Stinging Venom Coating
		[273930] = Priority(3), -- Hindering Cut
		[257292] = Priority(3), -- Heavy Slash
		[261428] = Priority(3), -- Hangman's Noose
		[256897] = Priority(3), -- Clamping Jaws
		[272874] = Priority(3), -- Trample
		[273470] = Priority(3), -- Gut Shot
		[272834] = Priority(3), -- Viscous Slobber
		[257169] = Priority(3), -- Terrifying Roar
		[272713] = Priority(3), -- Crushing Slam

		-- Grim Batol
		[449885] = Priority(3), -- Shadow Gale
		[449474] = Priority(3), -- Molten Spark
		[456773] = Priority(3), -- Twilight Wind
		[448953] = Priority(3), -- Rumbling Earth
		[447268] = Priority(3), -- Skullsplitter
		[449536] = Priority(3), -- Molten Pool
		[450095] = Priority(3), -- Curse of Entropy
		[448057] = Priority(3), -- Abyssal Corruption
		[451871] = Priority(3), -- Mass Temor
		[451613] = Priority(3), -- Twilight Flame
		[451378] = Priority(3), -- Rive
		[76711] = Priority(3), -- Sear Mind
		[462220] = Priority(3), -- Blazing Shadowflame
		[451395] = Priority(3), -- Corrupt
		[82850] = Priority(3), -- Flaming Fixate
		[451241] = Priority(3), -- Shadowflame Slash
		[451965] = Priority(3), -- Molten Wake
		[451224] = Priority(3), -- Enveloping Shadowflame

		-- Others
		[87023] = Priority(4), -- Cauterize
		[94794] = Priority(4), -- Rocket Fuel Leak
		[116888] = Priority(4), -- Shroud of Purgatory
		[121175] = Priority(2), -- Orb of Power (PvP)
		[160029] = Priority(3), -- Resurrecting (Pending CR)
		[225080] = Priority(3), -- Reincarnation (Ankh ready)
		[255234] = Priority(3), -- Totemic Revival
	},
}

C.DebuffsTracking_PvP = {
	["type"] = "Whitelist",
	["spells"] = {
		-- Death Knight
		[47476] = Priority(2), -- Strangulate
		[108194] = Priority(4), -- Asphyxiate
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
		[204490] = Priority(4), -- Sigil of Silence
		[179057] = Priority(3), -- Chaos Nova
		[211881] = Priority(4), -- Fel Eruption
		[205630] = Priority(3), -- Illidan's Grasp
		[213491] = Priority(4), -- Demonic Trample
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
		-- Evoker
		[355689] = Priority(4), -- Landslide
		[370898] = Priority(1), -- Permeating Chill
		[360806] = Priority(3), -- Sleep Walk
		-- Hunter
		[202933] = Priority(4), -- Spider Sting
		[213691] = Priority(4), -- Scatter Shot
		[19386] = Priority(3), -- Wyvern Sting
		[3355] = Priority(3), -- Freezing Trap
		[209790] = Priority(3), -- Freezing Arrow
		[24394] = Priority(4), -- Intimidation
		[117526] = Priority(4), -- Binding Shot
		[190927] = Priority(1), -- Harpoon
		[201158] = Priority(1), -- Super Sticky Tar
		[162480] = Priority(1), -- Steel Trap
		[212638] = Priority(1), -- Tracker's Net
		[200108] = Priority(1), -- Ranger's Net
		-- Mage
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
		[233759] = Priority(4), -- Grapple Weapon
		[123407] = Priority(1), -- Spinning Fire Blossom
		[116706] = Priority(1), -- Disable
		[232055] = Priority(4), -- Fists of Fury
		-- Paladin
		[853] = Priority(3), -- Hammer of Justice
		[20066] = Priority(3), -- Repentance
		[105421] = Priority(3), -- Blinding Light
		[31935] = Priority(2), -- Avenger's Shield
		[217824] = Priority(4), -- Shield of Virtue
		[205290] = Priority(3), -- Wake of Ashes
		-- Priest
		[9484] = Priority(3), -- Shackle Undead
		[200196] = Priority(4), -- Holy Word: Chastise
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
		[207777] = Priority(4), -- Dismantle
		[408] = Priority(4), -- Kidney Shot
		[1833] = Priority(4), -- Cheap Shot
		[207736] = Priority(5), -- Shadowy Duel (Smoke effect)
		[212182] = Priority(5), -- Smoke Bomb
		-- Shaman
		[51514] = Priority(3), -- Hex
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
		[236077] = Priority(4), -- Disarm
		-- Racial
		[20549] = Priority(4), -- War Stomp
		[107079] = Priority(4), -- Quaking Palm
	},
}
