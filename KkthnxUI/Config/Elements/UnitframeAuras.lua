local K, C = unpack(KkthnxUI)

local function Priority(priorityOverride)
	return {
		enable = true,
		priority = priorityOverride or 0,
		stackThreshold = 0,
	}
end

-- Raid Debuffs
C.DebuffsTracking_PvE = {
	["type"] = "Whitelist",
	["spells"] = {
		----------------------------------------------------------
		-------------------- Mythic+ Specific --------------------
		----------------------------------------------------------
		-- General Affixes
		[209858] = Priority(), -- Necrotic
		[226512] = Priority(), -- Sanguine
		[240559] = Priority(), -- Grievous
		[240443] = Priority(), -- Bursting
		-- Shadowlands Season 2
		[356667] = Priority(6), -- Biting Cold 1
		[356666] = Priority(6), -- Biting Cold 2
		[355732] = Priority(6), -- Melt Soul
		[356925] = Priority(6), -- Carnage
		[358777] = Priority(6), -- Bindings of Misery
		-- Shadowlands Season 3
		[368241] = Priority(3), -- Decrypted Urh Cypher
		[368244] = Priority(4), -- Urh Cloaking Field
		[368240] = Priority(3), -- Decrypted Wo Cypher
		[368239] = Priority(3), -- Decrypted Vy Cypher
		[366297] = Priority(6), -- Deconstruct (Tank Debuff)
		[366288] = Priority(6), -- Force Slam (Stun)
		----------------------------------------------------------
		---------------- Old Dungeons (for 9.2.5) ----------------
		----------------------------------------------------------
		-- Operation Mechagon
		[291928] = Priority(), -- Giga-Zap
		[292267] = Priority(), -- Giga-Zap
		[302274] = Priority(), -- Fulminating Zap
		[298669] = Priority(), -- Taze
		[295445] = Priority(), -- Wreck
		[294929] = Priority(), -- Blazing Chomp
		[297257] = Priority(), -- Electrical Charge
		[294855] = Priority(), -- Blossom Blast
		[291972] = Priority(), -- Explosive Leap
		[285443] = Priority(), -- 'Hidden' Flame Cannon
		[291974] = Priority(), -- Obnoxious Monologue
		[296150] = Priority(), -- Vent Blast
		[298602] = Priority(), -- Smoke Cloud
		[296560] = Priority(), -- Clinging Static
		[297283] = Priority(), -- Cave In
		[291914] = Priority(), -- Cutting Beam
		[302384] = Priority(), -- Static Discharge
		[294195] = Priority(), -- Arcing Zap
		[299572] = Priority(), -- Shrink
		[300659] = Priority(), -- Consuming Slime
		[300650] = Priority(), -- Suffocating Smog
		[301712] = Priority(), -- Pounce
		[299475] = Priority(), -- B.O.R.K
		[293670] = Priority(), -- Chain Blade
		----------------------------------------------------------
		------------------ Shadowlands Dungeons ------------------
		----------------------------------------------------------
		-- Tazavesh, the Veiled Market
		[350804] = Priority(), -- Collapsing Energy
		[350885] = Priority(), -- Hyperlight Jolt
		[351101] = Priority(), -- Energy Fragmentation
		[346828] = Priority(), -- Sanitizing Field
		[355641] = Priority(), -- Scintillate
		[355451] = Priority(), -- Undertow
		[355581] = Priority(), -- Crackle
		[349999] = Priority(), -- Anima Detonation
		[346961] = Priority(), -- Purging Field
		[351956] = Priority(), -- High-Value Target
		[346297] = Priority(), -- Unstable Explosion
		[347728] = Priority(), -- Flock!
		[356408] = Priority(), -- Ground Stomp
		[347744] = Priority(), -- Quickblade
		[347481] = Priority(), -- Shuri
		[355915] = Priority(), -- Glyph of Restraint
		[350134] = Priority(), -- Infinite Breath
		[350013] = Priority(), -- Gluttonous Feast
		[355465] = Priority(), -- Boulder Throw
		[346116] = Priority(), -- Shearing Swings
		[356011] = Priority(), -- Beam Splicer
		-- Halls of Atonement
		[335338] = Priority(), -- Ritual of Woe
		[326891] = Priority(), -- Anguish
		[329321] = Priority(), -- Jagged Swipe 1
		[344993] = Priority(), -- Jagged Swipe 2
		[319603] = Priority(), -- Curse of Stone
		[319611] = Priority(), -- Turned to Stone
		[325876] = Priority(), -- Curse of Obliteration
		[326632] = Priority(), -- Stony Veins
		[323650] = Priority(), -- Haunting Fixation
		[326874] = Priority(), -- Ankle Bites
		[340446] = Priority(), -- Mark of Envy
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
		-- Plaguefall
		[336258] = Priority(), -- Solitary Prey
		[331818] = Priority(), -- Shadow Ambush
		[329110] = Priority(), -- Slime Injection
		[325552] = Priority(), -- Cytotoxic Slash
		[336301] = Priority(), -- Web Wrap
		[322358] = Priority(), -- Burning Strain
		[322410] = Priority(), -- Withering Filth
		[328180] = Priority(), -- Gripping Infection
		[320542] = Priority(), -- Wasting Blight
		[340355] = Priority(), -- Rapid Infection
		[328395] = Priority(), -- Venompiercer
		[320512] = Priority(), -- Corroded Claws
		[333406] = Priority(), -- Assassinate
		[332397] = Priority(), -- Shroudweb
		[330069] = Priority(), -- Concentrated Plague
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
		-- Theater of Pain
		[333299] = Priority(), -- Curse of Desolation 1
		[333301] = Priority(), -- Curse of Desolation 2
		[319539] = Priority(), -- Soulless
		[326892] = Priority(), -- Fixate
		[321768] = Priority(), -- On the Hook
		[323825] = Priority(), -- Grasping Rift
		[342675] = Priority(), -- Bone Spear
		[323831] = Priority(), -- Death Grasp
		[330608] = Priority(), -- Vile Eruption
		[330868] = Priority(), -- Necrotic Bolt Volley
		[323750] = Priority(), -- Vile Gas
		[323406] = Priority(), -- Jagged Gash
		[330700] = Priority(), -- Decaying Blight
		[319626] = Priority(), -- Phantasmal Parasite
		[324449] = Priority(), -- Manifest Death
		[341949] = Priority(), -- Withering Blight
		-- Sanguine Depths
		[326827] = Priority(), -- Dread Bindings
		[326836] = Priority(), -- Curse of Suppression
		[322554] = Priority(), -- Castigate
		[321038] = Priority(), -- Burden Soul
		[328593] = Priority(), -- Agonize
		[325254] = Priority(), -- Iron Spikes
		[335306] = Priority(), -- Barbed Shackles
		[322429] = Priority(), -- Severing Slice
		[334653] = Priority(), -- Engorge
		-- Spires of Ascension
		[338729] = Priority(), -- Charged Stomp
		[323195] = Priority(), -- Purifying Blast
		[327481] = Priority(), -- Dark Lance
		[322818] = Priority(), -- Lost Confidence
		[322817] = Priority(), -- Lingering Doubt
		[324205] = Priority(), -- Blinding Flash
		[331251] = Priority(), -- Deep Connection
		[328331] = Priority(), -- Forced Confession
		[341215] = Priority(), -- Volatile Anima
		[323792] = Priority(), -- Anima Field
		[317661] = Priority(), -- Insidious Venom
		[330683] = Priority(), -- Raw Anima
		[328434] = Priority(), -- Intimidated
		-- De Other Side
		[320786] = Priority(), -- Power Overwhelming
		[334913] = Priority(), -- Master of Death
		[325725] = Priority(), -- Cosmic Artifice
		[328987] = Priority(), -- Zealous
		[334496] = Priority(), -- Soporific Shimmerdust
		[339978] = Priority(), -- Pacifying Mists
		[323692] = Priority(), -- Arcane Vulnerability
		[333250] = Priority(), -- Reaver
		[330434] = Priority(), -- Buzz-Saw 1
		[320144] = Priority(), -- Buzz-Saw 2
		[331847] = Priority(), -- W-00F
		[327649] = Priority(), -- Crushed Soul
		[331379] = Priority(), -- Lubricate
		[332678] = Priority(), -- Gushing Wound
		[322746] = Priority(), -- Corrupted Blood
		[323687] = Priority(), -- Arcane Lightning
		[323877] = Priority(), -- Echo Finger Laser X-treme
		[334535] = Priority(), -- Beak Slice
		--------------------------------------------------------
		-------------------- Castle Nathria --------------------
		--------------------------------------------------------
		-- Shriekwing
		[328897] = Priority(), -- Exsanguinated
		[330713] = Priority(), -- Reverberating Pain
		[329370] = Priority(), -- Deadly Descent
		[336494] = Priority(), -- Echo Screech
		[346301] = Priority(), -- Bloodlight
		[342077] = Priority(), -- Echolocation
		-- Huntsman Altimor
		[335304] = Priority(), -- Sinseeker
		[334971] = Priority(), -- Jagged Claws
		[335111] = Priority(), -- Huntsman's Mark 3
		[335112] = Priority(), -- Huntsman's Mark 2
		[335113] = Priority(), -- Huntsman's Mark 1
		[334945] = Priority(), -- Vicious Lunge
		[334852] = Priority(), -- Petrifying Howl
		[334695] = Priority(), -- Destabilize
		-- Hungering Destroyer
		[334228] = Priority(), -- Volatile Ejection
		[329298] = Priority(), -- Gluttonous Miasma
		-- Lady Inerva Darkvein
		[325936] = Priority(), -- Shared Cognition
		[335396] = Priority(), -- Hidden Desire
		[324983] = Priority(), -- Shared Suffering
		[324982] = Priority(), -- Shared Suffering (Partner)
		[332664] = Priority(), -- Concentrate Anima
		[325382] = Priority(), -- Warped Desires
		-- Sun King's Salvation
		[333002] = Priority(), -- Vulgar Brand
		[326078] = Priority(), -- Infuser's Boon
		[325251] = Priority(), -- Sin of Pride
		[341475] = Priority(), -- Crimson Flurry
		[341473] = Priority(), -- Crimson Flurry Teleport
		[328479] = Priority(), -- Eyes on Target
		[328889] = Priority(), -- Greater Castigation
		-- Artificer Xy'mox
		[327902] = Priority(), -- Fixate
		[326302] = Priority(), -- Stasis Trap
		[325236] = Priority(), -- Glyph of Destruction
		[327414] = Priority(), -- Possession
		[328468] = Priority(), -- Dimensional Tear 1
		[328448] = Priority(), -- Dimensional Tear 2
		[340860] = Priority(), -- Withering Touch
		-- The Council of Blood
		[327052] = Priority(), -- Drain Essence 1
		[327773] = Priority(), -- Drain Essence 2
		[346651] = Priority(), -- Drain Essence Mythic
		[328334] = Priority(), -- Tactical Advance
		[330848] = Priority(), -- Wrong Moves
		[331706] = Priority(), -- Scarlet Letter
		[331636] = Priority(), -- Dark Recital 1
		[331637] = Priority(), -- Dark Recital 2
		-- Sludgefist
		[335470] = Priority(), -- Chain Slam
		[339181] = Priority(), -- Chain Slam (Root)
		[331209] = Priority(), -- Hateful Gaze
		[335293] = Priority(), -- Chain Link
		[335270] = Priority(), -- Chain This One!
		[342419] = Priority(), -- Chain Them! 1
		[342420] = Priority(), -- Chain Them! 2
		[335295] = Priority(), -- Shattering Chain
		[332572] = Priority(), -- Falling Rubble
		-- Stone Legion Generals
		[334498] = Priority(), -- Seismic Upheaval
		[337643] = Priority(), -- Unstable Footing
		[334765] = Priority(), -- Heart Rend
		[334771] = Priority(), -- Heart Hemorrhage
		[333377] = Priority(), -- Wicked Mark
		[334616] = Priority(), -- Petrified
		[334541] = Priority(), -- Curse of Petrification
		[339690] = Priority(), -- Crystalize
		[342655] = Priority(), -- Volatile Anima Infusion
		[342698] = Priority(), -- Volatile Anima Infection
		[343881] = Priority(), -- Serrated Tear
		-- Sire Denathrius
		[326851] = Priority(), -- Blood Price
		[327796] = Priority(), -- Night Hunter
		[327992] = Priority(), -- Desolation
		[328276] = Priority(), -- March of the Penitent
		[326699] = Priority(), -- Burden of Sin
		[329181] = Priority(), -- Wracking Pain
		[335873] = Priority(), -- Rancor
		[329951] = Priority(), -- Impale
		[327039] = Priority(), -- Feeding Time
		[332794] = Priority(), -- Fatal Finesse
		[334016] = Priority(), -- Unworthy
		--------------------------------------------------------
		---------------- Sanctum of Domination -----------------
		--------------------------------------------------------
		-- The Tarragrue
		[347283] = Priority(5), -- Predator's Howl
		[347286] = Priority(5), -- Unshakeable Dread
		[346986] = Priority(3), -- Crushed Armor
		[347269] = Priority(6), -- Chains of Eternity
		[346985] = Priority(3), -- Overpower
		-- Eye of the Jailer
		[350606] = Priority(4), -- Hopeless Lethargy
		[355240] = Priority(5), -- Scorn
		[355245] = Priority(5), -- Ire
		[349979] = Priority(2), -- Dragging Chains
		[348074] = Priority(3), -- Assailing Lance
		[351827] = Priority(6), -- Spreading Misery
		[355143] = Priority(6), -- Deathlink
		[350763] = Priority(6), -- Annihilating Glare
		-- The Nine
		[350287] = Priority(2), -- Song of Dissolution
		[350542] = Priority(6), -- Fragments of Destiny
		[350202] = Priority(3), -- Unending Strike
		[350475] = Priority(5), -- Pierce Soul
		[350555] = Priority(3), -- Shard of Destiny
		[350109] = Priority(5), -- Brynja's Mournful Dirge
		[350483] = Priority(6), -- Link Essence
		[350039] = Priority(5), -- Arthura's Crushing Gaze
		[350184] = Priority(5), -- Daschla's Mighty Impact
		[350374] = Priority(5), -- Wings of Rage
		-- Remnant of Ner'zhul
		[350073] = Priority(2), -- Torment
		[349890] = Priority(5), -- Suffering
		[350469] = Priority(6), -- Malevolence
		[354634] = Priority(6), -- Spite 1
		[354479] = Priority(6), -- Spite 2
		[354534] = Priority(6), -- Spite 3
		-- Soulrender Dormazain
		[353429] = Priority(2), -- Tormented
		[353023] = Priority(3), -- Torment
		[351787] = Priority(5), -- Agonizing Spike
		[350647] = Priority(5), -- Brand of Torment
		[350422] = Priority(6), -- Ruinblade
		[350851] = Priority(6), -- Vessel of Torment
		[354231] = Priority(6), -- Soul Manacles
		[348987] = Priority(6), -- Warmonger Shackle 1
		[350927] = Priority(6), -- Warmonger Shackle 2
		-- Painsmith Raznal
		[356472] = Priority(5), -- Lingering Flames
		[355505] = Priority(6), -- Shadowsteel Chains 1
		[355506] = Priority(6), -- Shadowsteel Chains 2
		[348456] = Priority(6), -- Flameclasp Trap
		[356870] = Priority(2), -- Flameclasp Eruption
		[355568] = Priority(6), -- Cruciform Axe
		[355786] = Priority(5), -- Blackened Armor
		[355526] = Priority(6), -- Spiked
		-- Guardian of the First Ones
		[352394] = Priority(5), -- Radiant Energy
		[350496] = Priority(6), -- Threat Neutralization
		[347359] = Priority(6), -- Suppression Field
		[355357] = Priority(6), -- Obliterate
		[350732] = Priority(5), -- Sunder
		[352833] = Priority(6), -- Disintegration
		-- Fatescribe Roh-Kalo
		[354365] = Priority(5), -- Grim Portent
		[350568] = Priority(5), -- Call of Eternity
		[353435] = Priority(6), -- Overwhelming Burden
		[351680] = Priority(6), -- Invoke Destiny
		[353432] = Priority(6), -- Burden of Destiny
		[353693] = Priority(6), -- Unstable Accretion
		[350355] = Priority(6), -- Fated Conjunction
		[353931] = Priority(2), -- Twist Fate
		-- Kel'Thuzad
		[346530] = Priority(2), -- Frozen Destruction
		[354289] = Priority(2), -- Sinister Miasma
		[347454] = Priority(6), -- Oblivion's Echo 1
		[347518] = Priority(6), -- Oblivion's Echo 2
		[347292] = Priority(6), -- Oblivion's Echo 3
		[348978] = Priority(6), -- Soul Exhaustion
		[355389] = Priority(6), -- Relentless Haunt (Fixate)
		[357298] = Priority(6), -- Frozen Binds
		[355137] = Priority(5), -- Shadow Pool
		[348638] = Priority(4), -- Return of the Damned
		[348760] = Priority(6), -- Frost Blast
		-- Sylvanas Windrunner
		[349458] = Priority(2), -- Domination Chains
		[347704] = Priority(2), -- Veil of Darkness
		[347607] = Priority(5), -- Banshee's Mark
		[347670] = Priority(5), -- Shadow Dagger
		[351117] = Priority(5), -- Crushing Dread
		[351870] = Priority(5), -- Haunting Wave
		[351253] = Priority(5), -- Banshee Wail
		[351451] = Priority(6), -- Curse of Lethargy
		[351092] = Priority(6), -- Destabilize 1
		[351091] = Priority(6), -- Destabilize 2
		[348064] = Priority(6), -- Wailing Arrow
		----------------------------------------------------------
		-------------- Sepulcher of the First Ones ---------------
		----------------------------------------------------------
		-- Vigilant Guardian
		[364447] = Priority(3), -- Dissonance
		[364904] = Priority(6), -- Anti-Matter
		[364881] = Priority(5), -- Matter Disolution
		[360415] = Priority(5), -- Defenseless
		[360412] = Priority(4), -- Exposed Core
		[366393] = Priority(5), -- Searing Ablation
		-- Skolex, the Insatiable Ravener
		[364522] = Priority(2), -- Devouring Blood
		[359976] = Priority(2), -- Riftmaw
		[359981] = Priority(2), -- Rend
		[360098] = Priority(3), -- Warp Sickness
		[366070] = Priority(3), -- Volatile Residue
		-- Artificer Xy'mox
		[364030] = Priority(3), -- Debilitating Ray
		[365681] = Priority(2), -- System Shock
		[363413] = Priority(4), -- Forerunner Rings A
		[364604] = Priority(4), -- Forerunner Rings B
		[362615] = Priority(6), -- Interdimensional Wormhole Player 1
		[362614] = Priority(6), -- Interdimensional Wormhole Player 2
		[362803] = Priority(5), -- Glyph of Relocation
		-- Dausegne, The Fallen Oracle
		[361751] = Priority(2), -- Disintegration Halo
		[364289] = Priority(2), -- Staggering Barrage
		[361018] = Priority(2), -- Staggering Barrage Mythic 1
		[360960] = Priority(2), -- Staggering Barrage Mythic 2
		[361225] = Priority(2), -- Encroaching Dominion
		[361966] = Priority(2), -- Infused Strikes
		-- Prototype Pantheon
		[365306] = Priority(2), -- Invigorating Bloom
		[361689] = Priority(3), -- Wracking Pain
		[366232] = Priority(4), -- Animastorm
		[364839] = Priority(2), -- Sinful Projection
		[360259] = Priority(5), -- Gloom Bolt
		[362383] = Priority(5), -- Anima Bolt
		[362352] = Priority(6), -- Pinned
		-- Lihuvim, Principle Architect
		[360159] = Priority(5), -- Unstable Protoform Energy
		[363681] = Priority(3), -- Deconstructing Blast
		[363676] = Priority(4), -- Deconstructing Energy Player 1
		[363795] = Priority(4), -- Deconstructing Energy Player 2
		[464312] = Priority(5), -- Ephemeral Barrier
		-- Halondrus the Reclaimer
		[361309] = Priority(3), -- Lightshatter Beam
		[361002] = Priority(4), -- Ephemeral Fissure
		[360114] = Priority(4), -- Ephemeral Fissure II
		-- Anduin Wrynn
		[365293] = Priority(2), -- Befouled Barrier
		[363020] = Priority(3), -- Necrotic Claws
		[365021] = Priority(5), -- Wicked Star (marked)
		[365024] = Priority(6), -- Wicked Star (hit)
		[365445] = Priority(3), -- Scarred Soul
		[365008] = Priority(4), -- Psychic Terror
		[366849] = Priority(6), -- Domination Word: Pain
		-- Lords of Dread
		[360148] = Priority(5), -- Bursting Dread
		[360012] = Priority(4), -- Cloud of Carrion
		[360146] = Priority(4), -- Fearful Trepidation
		[360241] = Priority(6), -- Unsettling Dreams
		-- Rygelon
		[362206] = Priority(6), -- Event Horizon
		[362137] = Priority(4), -- Corrupted Wound
		[361548] = Priority(5), -- Dark Eclipse
		-- The Jailer
		[362075] = Priority(6), -- Domination
		[365150] = Priority(6), -- Rune of Domination
		[363893] = Priority(5), -- Martyrdom
		[363886] = Priority(5), -- Imprisonment
		[365219] = Priority(5), -- Chains of Anguish
		[366285] = Priority(6), -- Rune of Compulsion
		[363332] = Priority(5), -- Unbreaking Grasp
	},
}

-- Dispell Debuffs
C.DebuffsTracking_PvP = {
	["type"] = "Whitelist",
	["spells"] = {
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
		[213491] = Priority(4), -- Demonic Trample (it's this one or the other)
		[208645] = Priority(4), -- Demonic Trample
		-- Druid
		[81261] = Priority(2), -- Solar Beam
		[5211] = Priority(4), -- Mighty Bash
		[163505] = Priority(4), -- Rake
		[203123] = Priority(4), -- Maim
		[202244] = Priority(4), -- Overrun
		[99] = Priority(4), -- Incapacitating Roar
		[33786] = Priority(5), -- Cyclone
		[209753] = Priority(5), -- Cyclone Balance
		[45334] = Priority(1), -- Immobilized
		[102359] = Priority(1), -- Mass Entanglement
		[339] = Priority(1), -- Entangling Roots
		[2637] = Priority(1), -- Hibernate
		[102793] = Priority(1), -- Ursol's Vortex
		-- Hunter
		[202933] = Priority(2), -- Spider Sting (it's this one or the other)
		[233022] = Priority(2), -- Spider Sting
		[213691] = Priority(4), -- Scatter Shot
		[19386] = Priority(3), -- Wyvern Sting
		[3355] = Priority(3), -- Freezing Trap
		[203337] = Priority(5), -- Freezing Trap (Survival PvPT)
		[209790] = Priority(3), -- Freezing Arrow
		[24394] = Priority(4), -- Intimidation
		[117526] = Priority(4), -- Binding Shot
		[190927] = Priority(1), -- Harpoon
		[201158] = Priority(1), -- Super Sticky Tar
		[162480] = Priority(1), -- Steel Trap
		[212638] = Priority(1), -- Tracker's Net
		[200108] = Priority(1), -- Ranger's Net
		-- Mage
		[61721] = Priority(3), -- Rabbit (Poly)
		[61305] = Priority(3), -- Black Cat (Poly)
		[28272] = Priority(3), -- Pig (Poly)
		[28271] = Priority(3), -- Turtle (Poly)
		[126819] = Priority(3), -- Porcupine (Poly)
		[161354] = Priority(3), -- Monkey (Poly)
		[161353] = Priority(3), -- Polar bear (Poly)
		[61780] = Priority(3), -- Turkey (Poly)
		[161355] = Priority(3), -- Penguin (Poly)
		[161372] = Priority(3), -- Peacock (Poly)
		[277787] = Priority(3), -- Direhorn (Poly)
		[277792] = Priority(3), -- Bumblebee (Poly)
		[118] = Priority(3), -- Polymorph
		[82691] = Priority(3), -- Ring of Frost
		[31661] = Priority(3), -- Dragon's Breath
		[122] = Priority(1), -- Frost Nova
		[33395] = Priority(1), -- Freeze
		[157997] = Priority(1), -- Ice Nova
		[228600] = Priority(1), -- Glacial Spike
		[198121] = Priority(1), -- Forstbite
		-- Monk
		[119381] = Priority(4), -- Leg Sweep
		[202346] = Priority(4), -- Double Barrel
		[115078] = Priority(4), -- Paralysis
		[198909] = Priority(3), -- Song of Chi-Ji
		[202274] = Priority(3), -- Incendiary Brew
		[233759] = Priority(2), -- Grapple Weapon
		[123407] = Priority(1), -- Spinning Fire Blossom
		[116706] = Priority(1), -- Disable
		[232055] = Priority(4), -- Fists of Fury (it's this one or the other)
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
		-- Rogue
		[2094] = Priority(4), -- Blind
		[6770] = Priority(4), -- Sap
		[1776] = Priority(4), -- Gouge
		[1330] = Priority(2), -- Garrote - Silence
		[207777] = Priority(2), -- Dismantle
		[199804] = Priority(4), -- Between the Eyes
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
		[7922] = Priority(4), -- Warbringer
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

-- Buffs that really we dont need to see
C.DebuffsTracking_Blacklist = {
	type = "Blacklist",
	spells = {
		[36900] = Priority(), -- Soul Split: Evil!
		[36901] = Priority(), -- Soul Split: Good
		[36893] = Priority(), -- Transporter Malfunction
		[97821] = Priority(), -- Void-Touched
		[36032] = Priority(), -- Arcane Charge
		[8733] = Priority(), -- Blessing of Blackfathom
		[25771] = Priority(), -- Forbearance (Pally: Divine Shield, Blessing of Protection, and Lay on Hands)
		[57724] = Priority(), -- Sated (lust debuff)
		[57723] = Priority(), -- Exhaustion (heroism debuff)
		[80354] = Priority(), -- Temporal Displacement (timewarp debuff)
		[95809] = Priority(), -- Insanity debuff (hunter pet heroism: ancient hysteria)
		[58539] = Priority(), -- Watcher's Corpse
		[26013] = Priority(), -- Deserter
		[71041] = Priority(), -- Dungeon Deserter
		[41425] = Priority(), -- Hypothermia
		[55711] = Priority(), -- Weakened Heart
		[8326] = Priority(), -- Ghost
		[23445] = Priority(), -- Evil Twin
		[24755] = Priority(), -- Tricked or Treated
		[25163] = Priority(), -- Oozeling's Disgusting Aura
		[124275] = Priority(), -- Stagger
		[124274] = Priority(), -- Stagger
		[124273] = Priority(), -- Stagger
		[117870] = Priority(), -- Touch of The Titans
		[123981] = Priority(), -- Perdition
		[15007] = Priority(), -- Ress Sickness
		[113942] = Priority(), -- Demonic: Gateway
		[89140] = Priority(), -- Demonic Rebirth: Cooldown
		[287825] = Priority(), -- Lethargy debuff (fight or flight)
		[206662] = Priority(), -- Experience Eliminated (in range)
		[306600] = Priority(), -- Experience Eliminated (oor - 5m)
		[348443] = Priority(), -- Experience Eliminated
		[206151] = Priority(), -- Challenger's Burden
		[322695] = Priority(), -- Drained
	},
}

C.ChannelingTicks = {
	[120360] = 15, -- Barrage shooting
	[12051] = 6, -- wake
	[15407] = 6, -- Mental Flay
	[198013] = 10, -- Eye rim
	[198590] = 5, -- Draw soul
	[205021] = 5, -- Frost Ray
	[205065] = 6, -- Void Torrent
	[206931] = 3, -- Blood drinker
	[212084] = 10, -- Fel Destroy
	[234153] = 5, -- Draw life
	[257044] = 7, -- Rapid fire
	[291944] = 6, -- Rebirth, Zandalari troll
	[314791] = 4, -- Changeable phantom energy
	[324631] = 8, -- Forging of flesh and blood, covenant
	[47757] = 3, -- Penance
	[47758] = 3, -- Penance
	[48045] = 6, -- Mental burn
	[5143] = 4, -- Arcane Missile
	[64843] = 4, -- Holy hymn
	[740] = 4, -- peaceful
	[755] = 5, -- Life channel
	[64902] = 5, -- Symbol of Hope (Mana Hymn)
}

if K.Class == "PRIEST" then
	local function updateTicks()
		local numTicks = 3
		if IsPlayerSpell(193134) then
			numTicks = 4
		end

		C.ChannelingTicks[47757] = numTicks
		C.ChannelingTicks[47758] = numTicks
	end

	K:RegisterEvent("PLAYER_LOGIN", updateTicks)
	K:RegisterEvent("PLAYER_TALENT_UPDATE", updateTicks)
end
