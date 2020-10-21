local K = unpack(select(2, ...))

local _G = _G
local unpack = _G.unpack

local IsPlayerSpell = _G.IsPlayerSpell

local function Defaults(priorityOverride)
	return {["enable"] = true, ["priority"] = priorityOverride or 0, ["stackThreshold"] = 0}
end

-- AuraWatch: List of personal spells to show on unitframes as icon
function K:AuraWatch_AddSpell(id, point, color, anyUnit, onlyShowMissing, displayText, textThreshold, xOffset, yOffset)

	local r, g, b = 1, 1, 1
	if color then
		r, g, b = unpack(color)
	end

	return {
		id = id,
		enabled = true,
		point = point or "TOPLEFT",
		color = { r = r, g = g, b = b },
		anyUnit = anyUnit or false,
		onlyShowMissing = onlyShowMissing or false,
		displayText = displayText or false,
		textThreshold = textThreshold or -1,
		xOffset = xOffset or 0,
		yOffset = yOffset or 0,
		style = "coloredIcon",
		sizeOffset = 0,
	}
end

K.DebuffsTracking = {}
K.DebuffsTracking["RaidDebuffs"] = {
	type = "Whitelist",
	spells = {
		-- Mythic+ Dungeons
		-- General Affix
		[209858] = Defaults(), -- Necrotic
		[226512] = Defaults(), -- Sanguine
		[240559] = Defaults(), -- Grievous
		[240443] = Defaults(), -- Bursting
		-- 8.3 Affix
		[314531] = Defaults(), -- Tear Flesh
		[314308] = Defaults(), -- Spirit Breaker
		[314478] = Defaults(), -- Cascading Terror
		[314483] = Defaults(), -- Cascading Terror
		[314592] = Defaults(), -- Mind Flay
		[314406] = Defaults(), -- Crippling Pestilence
		[314411] = Defaults(), -- Lingering Doubt
		[314565] = Defaults(), -- Defiled Ground
		[314392] = Defaults(), -- Vile Corruption
		-- Shadowlands
		[342494] = Defaults(), -- Belligerent Boast (Prideful)

		-- Shadowlands Dungeons
		-- Halls of Atonement
		[335338] = Defaults(), -- Ritual of Woe
		[326891] = Defaults(), -- Anguish
		[329321] = Defaults(), -- Jagged Swipe
		[319603] = Defaults(), -- Curse of Stone
		[319611] = Defaults(), -- Turned to Stone
		[325876] = Defaults(), -- Curse of Obliteration
		[326632] = Defaults(), -- Stony Veins
		[323650] = Defaults(), -- Haunting Fixation
		[326874] = Defaults(), -- Ankle Bites
		-- Mists of Tirna Scithe
		[325027] = Defaults(), -- Bramble Burst
		[323043] = Defaults(), -- Bloodletting
		[322557] = Defaults(), -- Soul Split
		[331172] = Defaults(), -- Mind Link
		[322563] = Defaults(), -- Marked Prey
		-- Plaguefall
		[336258] = Defaults(), -- Solitary Prey
		[331818] = Defaults(), -- Shadow Ambush
		[329110] = Defaults(), -- Slime Injection
		[325552] = Defaults(), -- Cytotoxic Slash
		[336301] = Defaults(), -- Web Wrap
		-- The Necrotic Wake
		[321821] = Defaults(), -- Disgusting Guts
		[323365] = Defaults(), -- Clinging Darkness
		[338353] = Defaults(), -- Goresplatter
		[333485] = Defaults(), -- Disease Cloud
		[338357] = Defaults(), -- Tenderize
		[328181] = Defaults(), -- Frigid Cold
		[320170] = Defaults(), -- Necrotic Bolt
		[323464] = Defaults(), -- Dark Ichor
		[323198] = Defaults(), -- Dark Exile
		-- Theater of Pain
		[333299] = Defaults(), -- Curse of Desolation
		[319539] = Defaults(), -- Soulless
		[326892] = Defaults(), -- Fixate
		[321768] = Defaults(), -- On the Hook
		[323825] = Defaults(), -- Grasping Rift
		-- Sanguine Depths
		[326827] = Defaults(), -- Dread Bindings
		[326836] = Defaults(), -- Curse of Suppression
		[322554] = Defaults(), -- Castigate
		[321038] = Defaults(), -- Burden Soul
		-- Spires of Ascension
		[338729] = Defaults(), -- Charged Stomp
		[338747] = Defaults(), -- Purifying Blast
		[327481] = Defaults(), -- Dark Lance
		[322818] = Defaults(), -- Lost Confidence
		[322817] = Defaults(), -- Lingering Doubt
		-- De Other Side
		[320786] = Defaults(), -- Power Overwhelming
		[334913] = Defaults(), -- Master of Death
		[325725] = Defaults(), -- Cosmic Artifice
		[328987] = Defaults(), -- Zealous
		[334496] = Defaults(), -- Soporific Shimmerdust
		[339978] = Defaults(), -- Pacifying Mists
		[323692] = Defaults(), -- Arcane Vulnerability
		[333250] = Defaults(), -- Reaver

		-- BFA Dungeons
		-- Freehold
		[258323] = Defaults(), -- Infected Wound
		[257775] = Defaults(), -- Plague Step
		[257908] = Defaults(), -- Oiled Blade
		[257436] = Defaults(), -- Poisoning Strike
		[274389] = Defaults(), -- Rat Traps
		[274555] = Defaults(), -- Scabrous Bites
		[258875] = Defaults(), -- Blackout Barrel
		[256363] = Defaults(), -- Ripper Punch
		-- Shrine of the Storm
		[264560] = Defaults(), -- Choking Brine
		[268233] = Defaults(), -- Electrifying Shock
		[268322] = Defaults(), -- Touch of the Drowned
		[268896] = Defaults(), -- Mind Rend
		[268104] = Defaults(), -- Explosive Void
		[267034] = Defaults(), -- Whispers of Power
		[276268] = Defaults(), -- Heaving Blow
		[264166] = Defaults(), -- Undertow
		[264526] = Defaults(), -- Grasp of the Depths
		[274633] = Defaults(), -- Sundering Blow
		[268214] = Defaults(), -- Carving Flesh
		[267818] = Defaults(), -- Slicing Blast
		[268309] = Defaults(), -- Unending Darkness
		[268317] = Defaults(), -- Rip Mind
		[268391] = Defaults(), -- Mental Assault
		[274720] = Defaults(), -- Abyssal Strike
		-- Siege of Boralus
		[257168] = Defaults(), -- Cursed Slash
		[272588] = Defaults(), -- Rotting Wounds
		[272571] = Defaults(), -- Choking Waters
		[274991] = Defaults(), -- Putrid Waters
		[275835] = Defaults(), -- Stinging Venom Coating
		[273930] = Defaults(), -- Hindering Cut
		[257292] = Defaults(), -- Heavy Slash
		[261428] = Defaults(), -- Hangman"s Noose
		[256897] = Defaults(), -- Clamping Jaws
		[272874] = Defaults(), -- Trample
		[273470] = Defaults(), -- Gut Shot
		[272834] = Defaults(), -- Viscous Slobber
		[257169] = Defaults(), -- Terrifying Roar
		[272713] = Defaults(), -- Crushing Slam
		-- Tol Dagor
		[258128] = Defaults(), -- Debilitating Shout
		[265889] = Defaults(), -- Torch Strike
		[257791] = Defaults(), -- Howling Fear
		[258864] = Defaults(), -- Suppression Fire
		[257028] = Defaults(), -- Fuselighter
		[258917] = Defaults(), -- Righteous Flames
		[257777] = Defaults(), -- Crippling Shiv
		[258079] = Defaults(), -- Massive Chomp
		[258058] = Defaults(), -- Squeeze
		[260016] = Defaults(), -- Itchy Bite
		[257119] = Defaults(), -- Sand Trap
		[260067] = Defaults(), -- Vicious Mauling
		[258313] = Defaults(), -- Handcuff
		[259711] = Defaults(), -- Lockdown
		[256198] = Defaults(), -- Azerite Rounds: Incendiary
		[256101] = Defaults(), -- Explosive Burst (mythic)
		[256105] = Defaults(), -- Explosive Burst (mythic+)
		[256044] = Defaults(), -- Deadeye
		[256474] = Defaults(), -- Heartstopper Venom
		-- Waycrest Manor
		[260703] = Defaults(), -- Unstable Runic Mark
		[263905] = Defaults(), -- Marking Cleave
		[265880] = Defaults(), -- Dread Mark
		[265882] = Defaults(), -- Lingering Dread
		[264105] = Defaults(), -- Runic Mark
		[264050] = Defaults(), -- Infected Thorn
		[261440] = Defaults(), -- Virulent Pathogen
		[263891] = Defaults(), -- Grasping Thorns
		[264378] = Defaults(), -- Fragment Soul
		[266035] = Defaults(), -- Bone Splinter
		[266036] = Defaults(), -- Drain Essence
		[260907] = Defaults(), -- Soul Manipulation
		[260741] = Defaults(), -- Jagged Nettles
		[264556] = Defaults(), -- Tearing Strike
		[265760] = Defaults(), -- Thorned Barrage
		[260551] = Defaults(), -- Soul Thorns
		[263943] = Defaults(), -- Etch
		[265881] = Defaults(), -- Decaying Touch
		[261438] = Defaults(), -- Wasting Strike
		[268202] = Defaults(), -- Death Lens
		[278456] = Defaults(), -- Infest
		[264153] = Defaults(), -- Spit
		-- AtalDazar
		[252781] = Defaults(), -- Unstable Hex
		[250096] = Defaults(), -- Wracking Pain
		[250371] = Defaults(), -- Lingering Nausea
		[253562] = Defaults(), -- Wildfire
		[255582] = Defaults(), -- Molten Gold
		[255041] = Defaults(), -- Terrifying Screech
		[255371] = Defaults(), -- Terrifying Visage
		[252687] = Defaults(), -- Venomfang Strike
		[254959] = Defaults(), -- Soulburn
		[255814] = Defaults(), -- Rending Maul
		[255421] = Defaults(), -- Devour
		[255434] = Defaults(), -- Serrated Teeth
		[256577] = Defaults(), -- Soulfeast
		-- Kings Rest
		[270492] = Defaults(), -- Hex
		[267763] = Defaults(), -- Wretched Discharge
		[276031] = Defaults(), -- Pit of Despair
		[265773] = Defaults(), -- Spit Gold
		[270920] = Defaults(), -- Seduction
		[270865] = Defaults(), -- Hidden Blade
		[271564] = Defaults(), -- Embalming Fluid
		[270507] = Defaults(), -- Poison Barrage
		[267273] = Defaults(), -- Poison Nova
		[270003] = Defaults(), -- Suppression Slam
		[270084] = Defaults(), -- Axe Barrage
		[267618] = Defaults(), -- Drain Fluids
		[267626] = Defaults(), -- Dessication
		[270487] = Defaults(), -- Severing Blade
		[266238] = Defaults(), -- Shattered Defenses
		[266231] = Defaults(), -- Severing Axe
		[266191] = Defaults(), -- Whirling Axes
		[272388] = Defaults(), -- Shadow Barrage
		[271640] = Defaults(), -- Dark Revelation
		[268796] = Defaults(), -- Impaling Spear
		[268419] = Defaults(), -- Gale Slash
		[269932] = Defaults(), -- Gust Slash
		-- Motherlode
		[263074] = Defaults(), -- Festering Bite
		[280605] = Defaults(), -- Brain Freeze
		[257337] = Defaults(), -- Shocking Claw
		[270882] = Defaults(), -- Blazing Azerite
		[268797] = Defaults(), -- Transmute: Enemy to Goo
		[259856] = Defaults(), -- Chemical Burn
		[269302] = Defaults(), -- Toxic Blades
		[280604] = Defaults(), -- Iced Spritzer
		[257371] = Defaults(), -- Tear Gas
		[257544] = Defaults(), -- Jagged Cut
		[268846] = Defaults(), -- Echo Blade
		[262794] = Defaults(), -- Energy Lash
		[262513] = Defaults(), -- Azerite Heartseeker
		[260829] = Defaults(), -- Homing Missle (travelling)
		[260838] = Defaults(), -- Homing Missle (exploded)
		[263637] = Defaults(), -- Clothesline
		-- Temple of Sethraliss
		[269686] = Defaults(), -- Plague
		[268013] = Defaults(), -- Flame Shock
		[268008] = Defaults(), -- Snake Charm
		[273563] = Defaults(), -- Neurotoxin
		[272657] = Defaults(), -- Noxious Breath
		[267027] = Defaults(), -- Cytotoxin
		[272699] = Defaults(), -- Venomous Spit
		[263371] = Defaults(), -- Conduction
		[272655] = Defaults(), -- Scouring Sand
		[263914] = Defaults(), -- Blinding Sand
		[263958] = Defaults(), -- A Knot of Snakes
		[266923] = Defaults(), -- Galvanize
		[268007] = Defaults(), -- Heart Attack
		-- Underrot
		[265468] = Defaults(), -- Withering Curse
		[278961] = Defaults(), -- Decaying Mind
		[259714] = Defaults(), -- Decaying Spores
		[272180] = Defaults(), -- Death Bolt
		[272609] = Defaults(), -- Maddening Gaze
		[269301] = Defaults(), -- Putrid Blood
		[265533] = Defaults(), -- Blood Maw
		[265019] = Defaults(), -- Savage Cleave
		[265377] = Defaults(), -- Hooked Snare
		[265625] = Defaults(), -- Dark Omen
		[260685] = Defaults(), -- Taint of G"huun
		[266107] = Defaults(), -- Thirst for Blood
		[260455] = Defaults(), -- Serrated Fangs
		-- Operation Mechagon
		[291928] = Defaults(), -- Giga-Zap
		[292267] = Defaults(), -- Giga-Zap
		[302274] = Defaults(), -- Fulminating Zap
		[298669] = Defaults(), -- Taze
		[295445] = Defaults(), -- Wreck
		[294929] = Defaults(), -- Blazing Chomp
		[297257] = Defaults(), -- Electrical Charge
		[294855] = Defaults(), -- Blossom Blast
		[291972] = Defaults(), -- Explosive Leap
		[285443] = Defaults(), -- "Hidden" Flame Cannon
		[291974] = Defaults(), -- Obnoxious Monologue
		[296150] = Defaults(), -- Vent Blast
		[298602] = Defaults(), -- Smoke Cloud
		[296560] = Defaults(), -- Clinging Static
		[297283] = Defaults(), -- Cave In
		[291914] = Defaults(), -- Cutting Beam
		[302384] = Defaults(), -- Static Discharge
		[294195] = Defaults(), -- Arcing Zap
		[299572] = Defaults(), -- Shrink
		[300659] = Defaults(), -- Consuming Slime
		[300650] = Defaults(), -- Suffocating Smog
		[301712] = Defaults(), -- Pounce
		[299475] = Defaults(), -- B.O.R.K
		[293670] = Defaults(), -- Chain Blade

		-- Castle Nathria
		-- Shriekwing
		[328897] = Defaults(), -- Exsanguinated
		[330713] = Defaults(), -- Reverberating Pain
		[329370] = Defaults(), -- Deadly Descent
		[336494] = Defaults(), -- Echo Screech
		-- Huntsman Altimor
		[335304] = Defaults(), -- Sinseeker
		[334971] = Defaults(), -- Jagged Claws
		[335113] = Defaults(), -- Huntsman"s Mark 1
		[335112] = Defaults(), -- Huntsman"s Mark 2
		[335111] = Defaults(), -- Huntsman"s Mark 3
		[334945] = Defaults(), -- Bloody Thrash
		-- Hungering Destroyer
		[334228] = Defaults(), -- Volatile Ejection
		[329298] = Defaults(), -- Gluttonous Miasma
		-- Lady Inerva Darkvein
		[325936] = Defaults(), -- Shared Cognition
		[335396] = Defaults(), -- Hidden Desire
		[324983] = Defaults(), -- Shared Suffering
		[324982] = Defaults(), -- Shared Suffering Partner
		[332664] = Defaults(), -- Concentrate Anima
		[325382] = Defaults(), -- Warped Desires
		-- Sun King"s Salvation
		[333002] = Defaults(), -- Vulgar Brand
		[326078] = Defaults(), -- Infuser"s Boon
		[325251] = Defaults(), -- Sin of Pride
		-- Artificer Xy"mox
		[327902] = Defaults(), -- Fixate
		[326302] = Defaults(), -- Stasis Trap
		[325236] = Defaults(), -- Glyph of Destruction
		[327414] = Defaults(), -- Possession
		-- The Council of Blood
		[327773] = Defaults(), -- Drain Essence 1
		[327052] = Defaults(), -- Drain Essence 2
		[328334] = Defaults(), -- Tactical Advance
		[330848] = Defaults(), -- Wrong Moves
		[331706] = Defaults(), -- Scarlet Letter
		[331636] = Defaults(), -- Dark Recital 1
		[331637] = Defaults(), -- Dark Recital 2
		-- Sludgefist
		[335470] = Defaults(), -- Chain Slam
		[339181] = Defaults(), -- Chain Slam (Root)
		[331209] = Defaults(), -- Hateful Gaze
		[335293] = Defaults(), -- Chain Link
		[335270] = Defaults(), -- Chain This One!
		[335295] = Defaults(), -- Shattering Chain
		-- Stone Legion Generals
		[334498] = Defaults(), -- Seismic Upheaval
		[337643] = Defaults(), -- Unstable Footing
		[334765] = Defaults(), -- Stone Shatterer
		[333377] = Defaults(), -- Wicked Mark
		[334616] = Defaults(), -- Petrified
		[334541] = Defaults(), -- Curse of Petrification
		-- Sire Denathrius
		[326851] = Defaults(), -- Blood Price
		[327798] = Defaults(), -- Night Hunter
		[327992] = Defaults(), -- Desolation
		[328276] = Defaults(), -- March of the Penitent
		[326699] = Defaults(), -- Burden of Sin

		-- Uldir
		-- MOTHER
		[268277] = Defaults(), -- Purifying Flame
		[268253] = Defaults(), -- Surgical Beam
		[268095] = Defaults(), -- Cleansing Purge
		[267787] = Defaults(), -- Sundering Scalpel
		[268198] = Defaults(), -- Clinging Corruption
		[267821] = Defaults(), -- Defense Grid
		-- Vectis
		[265127] = Defaults(), -- Lingering Infection
		[265178] = Defaults(), -- Mutagenic Pathogen
		[265206] = Defaults(), -- Immunosuppression
		[265212] = Defaults(), -- Gestate
		[265129] = Defaults(), -- Omega Vector
		[267160] = Defaults(), -- Omega Vector
		[267161] = Defaults(), -- Omega Vector
		[267162] = Defaults(), -- Omega Vector
		[267163] = Defaults(), -- Omega Vector
		[267164] = Defaults(), -- Omega Vector
		-- Mythrax
		[272536] = Defaults(), -- Imminent Ruin
		[274693] = Defaults(), -- Essence Shear
		[272407] = Defaults(), -- Oblivion Sphere
		-- Fetid Devourer
		[262313] = Defaults(), -- Malodorous Miasma
		[262292] = Defaults(), -- Rotting Regurgitation
		[262314] = Defaults(), -- Deadly Disease
		-- Taloc
		[270290] = Defaults(), -- Blood Storm
		[275270] = Defaults(), -- Fixate
		[271224] = Defaults(), -- Plasma Discharge
		[271225] = Defaults(), -- Plasma Discharge
		-- Zul
		[273365] = Defaults(), -- Dark Revelation
		[273434] = Defaults(), -- Pit of Despair
		[272018] = Defaults(), -- Absorbed in Darkness
		[274358] = Defaults(), -- Rupturing Blood
		-- Zekvoz
		[265237] = Defaults(), -- Shatter
		[265264] = Defaults(), -- Void Lash
		[265360] = Defaults(), -- Roiling Deceit
		[265662] = Defaults(), -- Corruptor"s Pact
		[265646] = Defaults(), -- Will of the Corruptor
		-- G"huun
		[263436] = Defaults(), -- Imperfect Physiology
		[263227] = Defaults(), -- Putrid Blood
		[263372] = Defaults(), -- Power Matrix
		[272506] = Defaults(), -- Explosive Corruption
		[267409] = Defaults(), -- Dark Bargain
		[267430] = Defaults(), -- Torment
		[263235] = Defaults(), -- Blood Feast
		[270287] = Defaults(), -- Blighted Ground

		-- Battle of Dazar"alor
		-- Champions of the Light
		[283573] = Defaults(), -- Sacred Blade
		[283617] = Defaults(), -- Wave of Light
		[283651] = Defaults(), -- Blinding Faith
		[284595] = Defaults(), -- Penance
		[283582] = Defaults(), -- Consecration
		-- Grong
		[285998] = Defaults(), -- Ferocious Roar
		[283069] = Defaults(), -- Megatomic Fire
		[285671] = Defaults(), -- Crushed
		[285875] = Defaults(), -- Rending Bite
		-- Jaina
		[285253] = Defaults(), -- Ice Shard
		[287993] = Defaults(), -- Chilling Touch
		[287365] = Defaults(), -- Searing Pitch
		[288038] = Defaults(), -- Marked Target
		[285254] = Defaults(), -- Avalanche
		[287626] = Defaults(), -- Grasp of Frost
		[287490] = Defaults(), -- Frozen Solid
		[287199] = Defaults(), -- Ring of Ice
		[288392] = Defaults(), -- Vengeful Seas
		-- Stormwall Blockade
		[284369] = Defaults(), -- Sea Storm
		[284410] = Defaults(), -- Tempting Song
		[284405] = Defaults(), -- Tempting Song
		[284121] = Defaults(), -- Thunderous Boom
		[286680] = Defaults(), -- Roiling Tides
		-- Opulence
		[286501] = Defaults(), -- Creeping Blaze
		[283610] = Defaults(), -- Crush
		[289383] = Defaults(), -- Chaotic Displacement
		[285479] = Defaults(), -- Flame Jet
		[283063] = Defaults(), -- Flames of Punishment
		[283507] = Defaults(), -- Volatile Charge
		-- King Rastakhan
		[284995] = Defaults(), -- Zombie Dust
		[285349] = Defaults(), -- Plague of Fire
		[285044] = Defaults(), -- Toad Toxin
		[284831] = Defaults(), -- Scorching Detonation
		[289858] = Defaults(), -- Crushed
		[284662] = Defaults(), -- Seal of Purification
		[284676] = Defaults(), -- Seal of Purification
		[285178] = Defaults(), -- Serpent"s Breath
		[285010] = Defaults(), -- Poison Toad Slime
		-- Jadefire Masters
		[282037] = Defaults(), -- Rising Flames
		[284374] = Defaults(), -- Magma Trap
		[285632] = Defaults(), -- Stalking
		[288151] = Defaults(), -- Tested
		[284089] = Defaults(), -- Successful Defense
		[286988] = Defaults(), -- Searing Embers
		-- Mekkatorque
		[288806] = Defaults(), -- Gigavolt Blast
		[289023] = Defaults(), -- Enormous
		[286646] = Defaults(), -- Gigavolt Charge
		[288939] = Defaults(), -- Gigavolt Radiation
		[284168] = Defaults(), -- Shrunk
		[286516] = Defaults(), -- Anti-Tampering Shock
		[286480] = Defaults(), -- Anti-Tampering Shock
		[284214] = Defaults(), -- Trample
		-- Conclave of the Chosen
		[284663] = Defaults(), -- Bwonsamdi"s Wrath
		[282444] = Defaults(), -- Lacerating Claws
		[282592] = Defaults(), -- Bleeding Wounds
		[282209] = Defaults(), -- Mark of Prey
		[285879] = Defaults(), -- Mind Wipe
		[282135] = Defaults(), -- Crawling Hex
		[286060] = Defaults(), -- Cry of the Fallen
		[282447] = Defaults(), -- Kimbul"s Wrath
		[282834] = Defaults(), -- Kimbul"s Wrath
		[286811] = Defaults(), -- Akunda"s Wrath
		[286838] = Defaults(), -- Static Orb

		-- Crucible of Storms
		-- The Restless Cabal
		[282386] = Defaults(), -- Aphotic Blast
		[282384] = Defaults(), -- Shear Mind
		[282566] = Defaults(), -- Promises of Power
		[282561] = Defaults(), -- Dark Herald
		[282432] = Defaults(), -- Crushing Doubt
		[282589] = Defaults(), -- Mind Scramble
		[292826] = Defaults(), -- Mind Scramble
		-- Uu"nat
		[284851] = Defaults(), -- Touch of the End
		[286459] = Defaults(), -- Feedback: Void
		[286457] = Defaults(), -- Feedback: Ocean
		[286458] = Defaults(), -- Feedback: Storm
		[285367] = Defaults(), -- Piercing Gaze of N"Zoth
		[284733] = Defaults(), -- Embrace of the Void
		[284722] = Defaults(), -- Umbral Shell
		[285345] = Defaults(), -- Maddening Eyes of N"Zoth
		[285477] = Defaults(), -- Obscurity
		[285652] = Defaults(), -- Insatiable Torment

		-- Eternal Palace
		-- Lady Ashvane
		[296693] = Defaults(), -- Waterlogged
		[296725] = Defaults(), -- Barnacle Bash
		[296942] = Defaults(), -- Arcing Azerite
		[296938] = Defaults(), -- Arcing Azerite
		[296941] = Defaults(), -- Arcing Azerite
		[296939] = Defaults(), -- Arcing Azerite
		[296943] = Defaults(), -- Arcing Azerite
		[296940] = Defaults(), -- Arcing Azerite
		[296752] = Defaults(), -- Cutting Coral
		[297333] = Defaults(), -- Briny Bubble
		[297397] = Defaults(), -- Briny Bubble
		-- Abyssal Commander Sivara
		[300701] = Defaults(), -- Rimefrost
		[300705] = Defaults(), -- Septic Taint
		[294847] = Defaults(), -- Unstable Mixture
		[295850] = Defaults(), -- Delirious
		[295421] = Defaults(), -- Overflowing Venom
		[295348] = Defaults(), -- Overflowing Chill
		[295807] = Defaults(), -- Frozen
		[300883] = Defaults(), -- Inversion Sickness
		[295705] = Defaults(), -- Toxic Bolt
		[295704] = Defaults(), -- Frost Bolt
		[294711] = Defaults(), -- Frost Mark
		[294715] = Defaults(), -- Toxic Brand
		-- The Queens Court
		[301830] = Defaults(), -- Pashmar"s Touch
		[296851] = Defaults(), -- Fanatical Verdict
		[297836] = Defaults(), -- Potent Spark
		[297586] = Defaults(), -- Suffering
		[304410] = Defaults(), -- Repeat Performance
		[299914] = Defaults(), -- Frenetic Charge
		[303306] = Defaults(), -- Sphere of Influence
		[300545] = Defaults(), -- Mighty Rupture
		-- Radiance of Azshara
		[296566] = Defaults(), -- Tide Fist
		[296737] = Defaults(), -- Arcane Bomb
		[296746] = Defaults(), -- Arcane Bomb
		[295920] = Defaults(), -- Ancient Tempest
		[296462] = Defaults(), -- Squall Trap
		-- Orgozoa
		[298156] = Defaults(), -- Desensitizing Sting
		[298306] = Defaults(), -- Incubation Fluid
		-- Blackwater Behemoth
		[292127] = Defaults(), -- Darkest Depths
		[292138] = Defaults(), -- Radiant Biomass
		[292167] = Defaults(), -- Toxic Spine
		[301494] = Defaults(), -- Piercing Barb
		-- Zaqul
		[295495] = Defaults(), -- Mind Tether
		[295480] = Defaults(), -- Mind Tether
		[295249] = Defaults(), -- Delirium Realm
		[303819] = Defaults(), -- Nightmare Pool
		[293509] = Defaults(), -- Manifest Nightmares
		[295327] = Defaults(), -- Shattered Psyche
		[294545] = Defaults(), -- Portal of Madness
		[298192] = Defaults(), -- Dark Beyond
		[292963] = Defaults(), -- Dread
		[300133] = Defaults(), -- Snapped
		-- Queen Azshara
		[298781] = Defaults(), -- Arcane Orb
		[297907] = Defaults(), -- Cursed Heart
		[302999] = Defaults(), -- Arcane Vulnerability
		[302141] = Defaults(), -- Beckon
		[299276] = Defaults(), -- Sanction
		[303657] = Defaults(), -- Arcane Burst
		[298756] = Defaults(), -- Serrated Edge
		[301078] = Defaults(), -- Charged Spear
		[298014] = Defaults(), -- Cold Blast
		[298018] = Defaults(), -- Frozen

		-- Ny"alotha
		-- Wrathion
		[313255] = Defaults(), -- Creeping Madness (Slow Effect)
		[306163] = Defaults(), -- Incineration
		[306015] = Defaults(), -- Searing Armor [tank]
		-- Maut
		[307805] = Defaults(), -- Devour Magic
		[314337] = Defaults(), -- Ancient Curse
		[306301] = Defaults(), -- Forbidden Mana
		[314992] = Defaults(), -- Darin Essence
		[307399] = Defaults(), -- Shadow Claws [tank]
		-- Prophet Skitra
		[306387] = Defaults(), -- Shadow Shock
		[313276] = Defaults(), -- Shred Psyche
		-- Dark Inquisitor
		[306311] = Defaults(), -- Soul Flay
		[312406] = Defaults(), -- Void Woken
		[311551] = Defaults(), -- Abyssal Strike [tank]
		-- Hivemind
		[313461] = Defaults(), -- Corrosion
		[313672] = Defaults(), -- Acid Pool
		[313460] = Defaults(), -- Nullification
		-- Shadhar
		[307471] = Defaults(), -- Crush [tank]
		[307472] = Defaults(), -- Dissolve [tank]
		[307358] = Defaults(), -- Debilitating Spit
		[306928] = Defaults(), -- Umbral Breath
		[312530] = Defaults(), -- Entropic Breath
		[306929] = Defaults(), -- Bubbling Breath
		[318078] = Defaults(), -- Fixated
		-- Drest
		[310406] = Defaults(), -- Void Glare
		[310277] = Defaults(), -- Volatile Seed [tank]
		[310309] = Defaults(), -- Volatile Vulnerability
		[310358] = Defaults(), -- Mutterings of Insanity
		[310552] = Defaults(), -- Mind Flay
		[310478] = Defaults(), -- Void Miasma
		-- Ilgy
		[309961] = Defaults(), -- Eye of Nzoth [tank]
		[310322] = Defaults(), -- Morass of Corruption
		[311401] = Defaults(), -- Touch of the Corruptor
		[314396] = Defaults(), -- Cursed Blood
		[275269] = Defaults(), -- Fixate
		[312486] = Defaults(), -- Recurring Nightmare
		-- Vexiona
		[307317] = Defaults(), -- Encroaching Shadows
		[307359] = Defaults(), -- Despair
		[315932] = Defaults(), -- Brutal Smash
		[307218] = Defaults(), -- Twilight Decimator
		[307284] = Defaults(), -- Terrifying Presence
		[307421] = Defaults(), -- Annihilation
		[307019] = Defaults(), -- Void Corruption [tank]
		-- Raden
		[306819] = Defaults(), -- Nullifying Strike [tank]
		[306279] = Defaults(), -- Insanity Exposure
		[315258] = Defaults(), -- Dread Inferno
		[306257] = Defaults(), -- Unstable Vita
		[313227] = Defaults(), -- Decaying Wound
		[310019] = Defaults(), -- Charged Bonds
		[316065] = Defaults(), -- Corrupted Existence
		-- Carapace
		[315954] = Defaults(), -- Black Scar [tank]
		[306973] = Defaults(), -- Madness
		[316848] = Defaults(), -- Adaptive Membrane
		[307044] = Defaults(), -- Nightmare Antibody
		[313364] = Defaults(), -- Mental Decay
		[317627] = Defaults(), -- Infinite Void
		-- Nzoth
		[318442] = Defaults(), -- Paranoia
		[313400] = Defaults(), -- Corrupted Mind
		[313793] = Defaults(), -- Flames of Insanity
		[316771] = Defaults(), -- Mindwrack
		[314889] = Defaults(), -- Probe Mind
		[317112] = Defaults(), -- Evoke Anguish
		[318976] = Defaults(), -- Stupefying Glare
	},
}

-- CC DEBUFFS (TRACKING LIST)
K.DebuffsTracking["CCDebuffs"] = {
	type = "Whitelist",
	spells = {
		-- Death Knight
		[47476] = Defaults(2), -- Strangulate
		[108194] = Defaults(4), -- Asphyxiate UH
		[221562] = Defaults(4), -- Asphyxiate Blood
		[207171] = Defaults(4), -- Winter is Coming
		[206961] = Defaults(3), -- Tremble Before Me
		[207167] = Defaults(4), -- Blinding Sleet
		[212540] = Defaults(1), -- Flesh Hook (Pet)
		[91807] = Defaults(1), -- Shambling Rush (Pet)
		[204085] = Defaults(1), -- Deathchill
		[233395] = Defaults(1), -- Frozen Center
		[212332] = Defaults(4), -- Smash (Pet)
		[212337] = Defaults(4), -- Powerful Smash (Pet)
		[91800] = Defaults(4), -- Gnaw (Pet)
		[91797] = Defaults(4), -- Monstrous Blow (Pet)
		[210141] = Defaults(3), -- Zombie Explosion
		-- Demon Hunter
		[207685] = Defaults(4), -- Sigil of Misery
		[217832] = Defaults(3), -- Imprison
		[221527] = Defaults(5), -- Imprison (Banished version)
		[204490] = Defaults(2), -- Sigil of Silence
		[179057] = Defaults(3), -- Chaos Nova
		[211881] = Defaults(4), -- Fel Eruption
		[205630] = Defaults(3), -- Illidan"s Grasp
		[208618] = Defaults(3), -- Illidan"s Grasp (Afterward)
		[213491] = Defaults(4), -- Demonic Trample (it"s this one or the other)
		[208645] = Defaults(4), -- Demonic Trample
		-- Druid
		[81261] = Defaults(2), -- Solar Beam
		[5211] = Defaults(4), -- Mighty Bash
		[163505] = Defaults(4), -- Rake
		[203123] = Defaults(4), -- Maim
		[202244] = Defaults(4), -- Overrun
		[99] = Defaults(4), -- Incapacitating Roar
		[33786] = Defaults(5), -- Cyclone
		[209753] = Defaults(5), -- Cyclone Balance
		[45334] = Defaults(1), -- Immobilized
		[102359] = Defaults(1), -- Mass Entanglement
		[339] = Defaults(1), -- Entangling Roots
		[2637] = Defaults(1), -- Hibernate
		[102793] = Defaults(1), -- Ursol"s Vortex
		-- Hunter
		[202933] = Defaults(2), -- Spider Sting (it"s this one or the other)
		[233022] = Defaults(2), -- Spider Sting
		[213691] = Defaults(4), -- Scatter Shot
		[19386] = Defaults(3), -- Wyvern Sting
		[3355] = Defaults(3), -- Freezing Trap
		[203337] = Defaults(5), -- Freezing Trap (Survival PvPT)
		[209790] = Defaults(3), -- Freezing Arrow
		[24394] = Defaults(4), -- Intimidation
		[117526] = Defaults(4), -- Binding Shot
		[190927] = Defaults(1), -- Harpoon
		[201158] = Defaults(1), -- Super Sticky Tar
		[162480] = Defaults(1), -- Steel Trap
		[212638] = Defaults(1), -- Tracker"s Net
		[200108] = Defaults(1), -- Ranger"s Net
		-- Mage
		[61721] = Defaults(3), -- Rabbit (Poly)
		[61305] = Defaults(3), -- Black Cat (Poly)
		[28272] = Defaults(3), -- Pig (Poly)
		[28271] = Defaults(3), -- Turtle (Poly)
		[126819] = Defaults(3), -- Porcupine (Poly)
		[161354] = Defaults(3), -- Monkey (Poly)
		[161353] = Defaults(3), -- Polar bear (Poly)
		[61780] = Defaults(3), -- Turkey (Poly)
		[161355] = Defaults(3), -- Penguin (Poly)
		[161372] = Defaults(3), -- Peacock (Poly)
		[277787] = Defaults(3), -- Direhorn (Poly)
		[277792] = Defaults(3), -- Bumblebee (Poly)
		[118] = Defaults(3), -- Polymorph
		[82691] = Defaults(3), -- Ring of Frost
		[31661] = Defaults(3), -- Dragon"s Breath
		[122] = Defaults(1), -- Frost Nova
		[33395] = Defaults(1), -- Freeze
		[157997] = Defaults(1), -- Ice Nova
		[228600] = Defaults(1), -- Glacial Spike
		[198121] = Defaults(1), -- Forstbite
		-- Monk
		[119381] = Defaults(4), -- Leg Sweep
		[202346] = Defaults(4), -- Double Barrel
		[115078] = Defaults(4), -- Paralysis
		[198909] = Defaults(3), -- Song of Chi-Ji
		[202274] = Defaults(3), -- Incendiary Brew
		[233759] = Defaults(2), -- Grapple Weapon
		[123407] = Defaults(1), -- Spinning Fire Blossom
		[116706] = Defaults(1), -- Disable
		[232055] = Defaults(4), -- Fists of Fury (it"s this one or the other)
		-- Paladin
		[853] = Defaults(3), -- Hammer of Justice
		[20066] = Defaults(3), -- Repentance
		[105421] = Defaults(3), -- Blinding Light
		[31935] = Defaults(2), -- Avenger"s Shield
		[217824] = Defaults(2), -- Shield of Virtue
		[205290] = Defaults(3), -- Wake of Ashes
		-- Priest
		[9484] = Defaults(3), -- Shackle Undead
		[200196] = Defaults(4), -- Holy Word: Chastise
		[200200] = Defaults(4), -- Holy Word: Chastise
		[226943] = Defaults(3), -- Mind Bomb
		[605] = Defaults(5), -- Mind Control
		[8122] = Defaults(3), -- Psychic Scream
		[15487] = Defaults(2), -- Silence
		[64044] = Defaults(1), -- Psychic Horror
		-- Rogue
		[2094] = Defaults(4), -- Blind
		[6770] = Defaults(4), -- Sap
		[1776] = Defaults(4), -- Gouge
		[1330] = Defaults(2), -- Garrote - Silence
		[207777] = Defaults(2), -- Dismantle
		[199804] = Defaults(4), -- Between the Eyes
		[408] = Defaults(4), -- Kidney Shot
		[1833] = Defaults(4), -- Cheap Shot
		[207736] = Defaults(5), -- Shadowy Duel (Smoke effect)
		[212182] = Defaults(5), -- Smoke Bomb
		-- Shaman
		[51514] = Defaults(3), -- Hex
		[211015] = Defaults(3), -- Hex (Cockroach)
		[211010] = Defaults(3), -- Hex (Snake)
		[211004] = Defaults(3), -- Hex (Spider)
		[210873] = Defaults(3), -- Hex (Compy)
		[196942] = Defaults(3), -- Hex (Voodoo Totem)
		[269352] = Defaults(3), -- Hex (Skeletal Hatchling)
		[277778] = Defaults(3), -- Hex (Zandalari Tendonripper)
		[277784] = Defaults(3), -- Hex (Wicker Mongrel)
		[118905] = Defaults(3), -- Static Charge
		[77505] = Defaults(4), -- Earthquake (Knocking down)
		[118345] = Defaults(4), -- Pulverize (Pet)
		[204399] = Defaults(3), -- Earthfury
		[204437] = Defaults(3), -- Lightning Lasso
		[157375] = Defaults(4), -- Gale Force
		[64695] = Defaults(1), -- Earthgrab
		-- Warlock
		[710] = Defaults(5), -- Banish
		[6789] = Defaults(3), -- Mortal Coil
		[118699] = Defaults(3), -- Fear
		[6358] = Defaults(3), -- Seduction (Succub)
		[171017] = Defaults(4), -- Meteor Strike (Infernal)
		[22703] = Defaults(4), -- Infernal Awakening (Infernal CD)
		[30283] = Defaults(3), -- Shadowfury
		[89766] = Defaults(4), -- Axe Toss
		[233582] = Defaults(1), -- Entrenched in Flame
		-- Warrior
		[5246] = Defaults(4), -- Intimidating Shout
		[7922] = Defaults(4), -- Warbringer
		[132169] = Defaults(4), -- Storm Bolt
		[132168] = Defaults(4), -- Shockwave
		[199085] = Defaults(4), -- Warpath
		[105771] = Defaults(1), -- Charge
		[199042] = Defaults(1), -- Thunderstruck
		[236077] = Defaults(2), -- Disarm
		-- Racial
		[20549] = Defaults(4), -- War Stomp
		[107079] = Defaults(4), -- Quaking Palm
	},
}

-- Raid Buffs (Squared Aura Tracking List)
K.BuffsTracking = {
	PRIEST = {
		[194384] = K:AuraWatch_AddSpell(194384, "TOPRIGHT", {1, 1, 0.66}), -- Atonement
		[214206] = K:AuraWatch_AddSpell(214206, "TOPRIGHT", {1, 1, 0.66}), -- Atonement (PvP)
		[41635] = K:AuraWatch_AddSpell(41635, "BOTTOMRIGHT", {0.2, 0.7, 0.2}), -- Prayer of Mending
		[193065] = K:AuraWatch_AddSpell(193065, "BOTTOMRIGHT", {0.54, 0.21, 0.78}), -- Masochism
		[139] = K:AuraWatch_AddSpell(139, "BOTTOMLEFT", {0.4, 0.7, 0.2}), -- Renew
		[6788] = K:AuraWatch_AddSpell(6788, "BOTTOMLEFT", {0.89, 0.1, 0.1}), -- Weakened Soul
		[17] = K:AuraWatch_AddSpell(17, "TOPLEFT", {0.7, 0.7, 0.7}, true), -- Power Word: Shield
		[47788] = K:AuraWatch_AddSpell(47788, "LEFT", {0.86, 0.45, 0}, true), -- Guardian Spirit
		[33206] = K:AuraWatch_AddSpell(33206, "LEFT", {0.47, 0.35, 0.74}, true),		-- Pain Suppression
	},
	DRUID = {
		[774] = K:AuraWatch_AddSpell(774, "TOPRIGHT", {0.8, 0.4, 0.8}), -- Rejuvenation
		[155777] = K:AuraWatch_AddSpell(155777, "RIGHT", {0.8, 0.4, 0.8}), -- Germination
		[8936] = K:AuraWatch_AddSpell(8936, "BOTTOMLEFT", {0.2, 0.8, 0.2}), -- Regrowth
		[33763] = K:AuraWatch_AddSpell(33763, "TOPLEFT", {0.4, 0.8, 0.2}), -- Lifebloom (Normal version)
		[188550] = K:AuraWatch_AddSpell(188550, "TOPLEFT", {0.4, 0.8, 0.2}), -- Lifebloom (Legendary version)
		[48438] = K:AuraWatch_AddSpell(48438, "BOTTOMRIGHT", {0.8, 0.4, 0}), -- Wild Growth
		[207386] = K:AuraWatch_AddSpell(207386, "TOP", {0.4, 0.2, 0.8}), -- Spring Blossoms
		[102351] = K:AuraWatch_AddSpell(102351, "LEFT", {0.2, 0.8, 0.8}), -- Cenarion Ward (Initial Buff)
		[102352] = K:AuraWatch_AddSpell(102352, "LEFT", {0.2, 0.8, 0.8}), -- Cenarion Ward (HoT)
		[200389] = K:AuraWatch_AddSpell(200389, "BOTTOM", {1, 1, 0.4}), -- Cultivation
	},
	PALADIN = {
		[53563] = K:AuraWatch_AddSpell(53563, "TOPRIGHT", {0.7, 0.3, 0.7}), -- Beacon of Light
		[156910] = K:AuraWatch_AddSpell(156910, "TOPRIGHT", {0.7, 0.3, 0.7}), -- Beacon of Faith
		[200025] = K:AuraWatch_AddSpell(200025, "TOPRIGHT", {0.7, 0.3, 0.7}), -- Beacon of Virtue
		[1022] = K:AuraWatch_AddSpell(1022, "BOTTOMRIGHT", {0.2, 0.2, 1}, true), -- Hand of Protection
		[1044] = K:AuraWatch_AddSpell(1044, "BOTTOMRIGHT", {0.89, 0.45, 0}, true), -- Hand of Freedom
		[6940] = K:AuraWatch_AddSpell(6940, "BOTTOMRIGHT", {0.89, 0.1, 0.1}, true), -- Hand of Sacrifice
		[223306] = K:AuraWatch_AddSpell(223306, "BOTTOMLEFT", {0.7, 0.7, 0.3}), -- Bestow Faith
		[287280] = K:AuraWatch_AddSpell(287280, "TOPLEFT", {0.2, 0.8, 0.2}), -- Glimmer of Light (Artifact HoT)
	},
	SHAMAN = {
		[61295] = K:AuraWatch_AddSpell(61295, "TOPRIGHT", {0.7, 0.3, 0.7}), -- Riptide
		[974] = K:AuraWatch_AddSpell(974, "BOTTOMRIGHT", {0.2, 0.2, 1}), -- Earth Shield
	},
	MONK = {
		[119611] = K:AuraWatch_AddSpell(119611, "TOPLEFT", {0.3, 0.8, 0.6}), -- Renewing Mist
		[116849] = K:AuraWatch_AddSpell(116849, "TOPRIGHT", {0.2, 0.8, 0.2}, true),	-- Life Cocoon
		[124682] = K:AuraWatch_AddSpell(124682, "BOTTOMLEFT", {0.8, 0.8, 0.25}), -- Enveloping Mist
		[191840] = K:AuraWatch_AddSpell(191840, "BOTTOMRIGHT", {0.27, 0.62, 0.7}), -- Essence Font
	},
	ROGUE = {
		[57934] = K:AuraWatch_AddSpell(57934, "TOPRIGHT", {0.89, 0.09, 0.05}), -- Tricks of the Trade
	},
	WARRIOR = {
		[114030] = K:AuraWatch_AddSpell(114030, "TOPLEFT", {0.2, 0.2, 1}), -- Vigilance
		[3411] = K:AuraWatch_AddSpell(3411, "TOPRIGHT", {0.89, 0.09, 0.05}), -- Intervene
	},
	PET = {
		-- Warlock Pets
		[193396] = K:AuraWatch_AddSpell(193396, "TOPRIGHT", {0.6, 0.2, 0.8}, true),	-- Demonic Empowerment
		-- Hunter Pets
		[272790] = K:AuraWatch_AddSpell(272790, "TOPLEFT", {0.89, 0.09, 0.05}, true), -- Frenzy
		[136] = K:AuraWatch_AddSpell(136, "TOPRIGHT", {0.2, 0.8, 0.2}, true) -- Mend Pet
	},
	HUNTER = {},
	DEMONHUNTER = {},
	WARLOCK = {},
	MAGE = {},
	DEATHKNIGHT = {},
}

-- Filter this. Pointless to see.
K.AuraBlackList = {
	[113942] = true, -- Demonic: Gateway
	[117870] = true, -- Touch of The Titans
	[123981] = true, -- Perdition
	[124273] = true, -- Stagger
	[124274] = true, -- Stagger
	[124275] = true, -- Stagger
	[126434] = true, -- Tushui Champion
	[126436] = true, -- Huojin Champion
	[131493] = true, -- B.F.F. Friends forever!
	[143625] = true, -- Brawling Champion
	[15007] = true, -- Ress Sickness
	[170616] = true, -- Pet Deserter
	[182957] = true, -- Treasures of Stormheim
	[182958] = true, -- Treasures of Azsuna
	[185719] = true, -- Treasures of Val"sharah
	[186401] = true, -- Sign of the Skirmisher
	[186403] = true, -- Sign of Battle
	[186404] = true, -- Sign of the Emissary
	[186406] = true, -- Sign of the Critter
	[188741] = true, -- Treasures of Highmountain
	[199416] = true, -- Treasures of Suramar
	[225787] = true, -- Sign of the Warrior
	[225788] = true, -- Sign of the Emissary
	[227723] = true, -- Mana Divining Stone
	[231115] = true, -- Treasures of Broken Shore
	[233641] = true, -- Legionfall Commander
	[23445] = true, -- Evil Twin
	[237137] = true, -- Knowledgeable
	[237139] = true, -- Power Overwhelming
	[239645] = true, -- Fel Treasures
	[239647] = true, -- Epic Hunter
	[239648] = true, -- Forces of the Order
	[239966] = true, -- War Effort
	[239967] = true, -- Seal Your Fate
	[239968] = true, -- Fate Smiles Upon You
	[239969] = true, -- Netherstorm
	[240979] = true, -- Reputable
	[240980] = true, -- Light As a Feather
	[240985] = true, -- Reinforced Reins
	[240986] = true, -- Worthy Champions
	[240987] = true, -- Well Prepared
	[240989] = true, -- Heavily Augmented
	[24755] = true, -- Tricked or Treated
	[25163] = true, -- Oozeling"s Disgusting Aura
	[26013] = true, -- Deserter
	[36032] = true, -- Arcane Charge
	[36893] = true, -- Transporter Malfunction
	[36900] = true, -- Soul Split: Evil!
	[36901] = true, -- Soul Split: Good
	[39953] = true, -- A"dal"s Song of Battle
	[41425] = true, -- Hypothermia
	[44212] = true, -- Jack-o"-Lanterned!
	[55711] = true, -- Weakened Heart
	[57723] = true, -- Exhaustion (heroism debuff)
	[57724] = true, -- Sated (lust debuff)
	[57819] = true, -- Argent Champion
	[57820] = true, -- Ebon Champion
	[57821] = true, -- Champion of the Kirin Tor
	[58539] = true, -- Watcher"s Corpse
	[71041] = true, -- Dungeon Deserter
	[72968] = true, -- Precious"s Ribbon
	[80354] = true, -- Temporal Displacement (timewarp debuff)
	[8326] = true, -- Ghost
	[85612] = true, -- Fiona"s Lucky Charm
	[85613] = true, -- Gidwin"s Weapon Oil
	[85614] = true, -- Tarenar"s Talisman
	[85615] = true, -- Pamela"s Doll
	[85616] = true, -- Vex"tul"s Armbands
	[85617] = true, -- Argus" Journal
	[85618] = true, -- Rimblat"s Stone
	[85619] = true, -- Beezil"s Cog
	[8733] = true, -- Blessing of Blackfathom
	[89140] = true, -- Demonic Rebirth: Cooldown
	[93337] = true, -- Champion of Ramkahen
	[93339] = true, -- Champion of the Earthen Ring
	[93341] = true, -- Champion of the Guardians of Hyjal
	[93347] = true, -- Champion of Therazane
	[93368] = true, -- Champion of the Wildhammer Clan
	[93795] = true, -- Stormwind Champion
	[93805] = true, -- Ironforge Champion
	[93806] = true, -- Darnassus Champion
	[93811] = true, -- Exodar Champion
	[93816] = true, -- Gilneas Champion
	[93821] = true, -- Gnomeregan Champion
	[93825] = true, -- Orgrimmar Champion
	[93827] = true, -- Darkspear Champion
	[93828] = true, -- Silvermoon Champion
	[93830] = true, -- Bilgewater Champion
	[94158] = true, -- Champion of the Dragonmaw Clan
	[94462] = true, -- Undercity Champion
	[94463] = true, -- Thunder Bluff Champion
	[95809] = true, -- Insanity debuff (hunter pet heroism: ancient hysteria)
	[97340] = true, -- Guild Champion
	[97341] = true, -- Guild Champion
	[97821] = true -- Void-Touched
}

K.ChannelingTicks = {
	[12051] = 3, -- Evocation
	[15407] = 4, -- Mind Flay
	[198590] = 5, -- Drain Soul
	[205021] = 5, -- Ray of Frost
	[205065] = 6, -- Void Torrent
	[234153] = 5, -- Drain Life
	[291944] = 6, -- Regeneratin"
	[47758] = 3, -- Penance
	[5143] = 5, -- Arcane Missiles
	[64843] = 4, -- Divine Hymn
	[740] = 4, -- Tranquility
	[755] = 3, -- Health Funnel
	[314791] = 4, -- Changeable Phantom Energy
}

if K.Class == "PRIEST" then
	local penanceID = 47758
	local function updateTicks()
		local numTicks = 3
		if IsPlayerSpell(193134) then
			numTicks = 4
		end

		K.ChannelingTicks[penanceID] = numTicks
	end

	K:RegisterEvent("PLAYER_ENTERING_WORLD", updateTicks)
	K:RegisterEvent("PLAYER_TALENT_UPDATE", updateTicks)
end