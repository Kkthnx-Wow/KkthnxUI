local K, C, L, _ = select(2, ...):unpack()
if C.CombatText.Enable ~= true then return end

--[[
	The best way to add or delete spell is to go at www.wowhead.com, search for a spell.
	Example: Blizzard -> http://www.wowhead.com/spell=42208
	Take the number ID at the end of the URL, and add it to the list
--]]

-- General filter outgoing healing
if C.CombatText.Healing then
	K.healfilter = {}
	K.healfilter[143924] = true		-- Leech
end

-- General merge outgoing damage
if C.CombatText.MergeAoeSpam then
	K.merge = {}
	K.aoespam = {}
	K.aoespam[6603] = 3				-- Auto Attack
	K.aoespam[148008] = 3			-- Essence of Yu'lon (Legedary Cloak)
	K.aoespam[148009] = 3			-- Spirit of Chi-Ji (Legedary Cloak)
	K.aoespam[149276] = 3			-- Flurry of Xuen (Legedary Cloak)
	K.aoespam[147891] = 3			-- Flurry of Xuen (Legedary Cloak)
	K.aoespam[187626] = 1			-- Maalus (Legedary Ring)
	K.aoespam[187625] = 1			-- Nithramus (Legedary Ring)
	K.aoespam[187624] = 1			-- Thorasus (Legedary Ring)
	K.aoespam[184075] = 3			-- Doom Nova (Prophecy of Fear)
	K.aoespam[183950] = 3			-- Darklight Ray (Unblinking Gaze of Sethe)
	K.aoespam[184256] = 3			-- Fel Burn (Empty Drinking Horn)
	K.aoespam[184248] = 3			-- Fel Cleave (Discordant Chorus)
	K.aoespam[195222] = 4			-- Stormlash
	K.aoespam[195256] = 4			-- Stormlash
end

-- Class config
if K.Class == "DEATHKNIGHT" then
	if C.CombatText.MergeAoeSpam then
		--BETA K.aoespam[168828] = 3		-- Necrosis
		--BETA K.aoespam[155159] = 3		-- Necrotic Plague
		K.aoespam[55095] = 3		-- Frost Fever
		K.aoespam[55078] = 3		-- Blood Plague
		K.aoespam[50842] = 0		-- Blood Boil
		K.aoespam[49184] = 0		-- Howling Blast
		K.aoespam[52212] = 3		-- Death and Decay
		K.aoespam[50401] = 3		-- Razorice
		K.aoespam[91776] = 3		-- Claw (Ghoul)
		K.aoespam[49020] = 0		-- Obliterate
		K.aoespam[49143] = 0		-- Frost Strike
		--BETA K.aoespam[45462] = 0		-- Plague Strike
		K.aoespam[49998] = 0		-- Death Strike
		K.aoespam[156000] = 3		-- Defile
		K.aoespam[155166] = 3		-- Mark of Sindragosa
		K.aoespam[55090] = 0		-- Scourge Strike
		K.merge[66198] = 49020		-- Obliterate Off-Hand
		K.merge[66196] = 49143		-- Frost Strike Off-Hand
		--BETA K.merge[66216] = 45462		-- Plague Strike Off-Hand
		K.merge[66188] = 49998		-- Death Strike Off-Hand
		K.merge[70890] = 55090		-- Scourge Strike (Shadow damage)
	end
	if C.CombatText.Healing then
		K.healfilter[53365] = true	-- Unholy Strength
		K.healfilter[119980] = true	-- Conversion
	end
elseif K.Class == "DRUID" then
	if C.CombatText.MergeAoeSpam then
		-- Healing spells
		K.aoespam[774] = 3			-- Rejuvenation
		K.aoespam[48438] = 3		-- Wild Growth
		K.aoespam[8936] = 3			-- Regrowth
		K.aoespam[33763] = 3		-- Lifebloom
		K.aoespam[157982] = 3		-- Tranquility
		K.aoespam[81269] = 3		-- Wild Mushroom
		K.aoespam[124988] = 3		-- Nature's Vigil
		--BETA K.aoespam[162359] = 3		-- Genesis
		K.aoespam[144876] = 3		-- Spark of Life (T16)
		K.aoespam[155777] = 3		-- Rejuvenation (Germination)
		-- Damaging spells
		K.aoespam[164812] = 3		-- Moonfire
		K.aoespam[164815] = 3		-- Sunfire
		--BETA K.aoespam[42231] = 3		-- Hurricane
		--BETA K.aoespam[106998] = 3		-- Astral Storm
		--BETA K.aoespam[50288] = 3		-- Starfall
		K.aoespam[61391] = 0		-- Typhoon
		K.aoespam[155722] = 3		-- Rake
		K.aoespam[33917] = 0		-- Mangle
		K.aoespam[106785] = 0		-- Swipe
		--BETA K.aoespam[33745] = 3		-- Lacerate
		K.aoespam[77758] = 3		-- Thrash (Bear Form)
		K.aoespam[106830] = 3		-- Thrash (Cat Form)
		K.aoespam[1079] = 3			-- Rip
		K.aoespam[124991] = 3		-- Nature's Vigil
		--BETA K.aoespam[152221] = 3		-- Stellar Flare
		K.aoespam[155625] = 3		-- Moonfire (Cat Form)
	end
	if C.CombatText.Healing then
		K.healfilter[145109] = true	-- Ysera's Gift (Self)
		K.healfilter[145110] = true	-- Ysera's Gift
		--BETA K.healfilter[68285] = true	-- Leader of the Pack
	end
elseif K.Class == "HUNTER" then
	if C.CombatText.MergeAoeSpam then
		K.aoespam[2643] = 0			-- Multi-Shot
		K.aoespam[118253] = 3		-- Serpent Sting
		K.aoespam[13812] = 3		-- Explosive Trap
		--BETA K.aoespam[53301] = 3		-- Explosive Shot
		K.aoespam[118459] = 3		-- Beast Cleave
		K.aoespam[120699] = 3		-- Lynx Rush
		K.aoespam[120361] = 3		-- Barrage
		K.aoespam[131900] = 3		-- A Murder of Crows
		--BETA K.aoespam[3674] = 3			-- Black Arrow
		K.aoespam[121414] = 3		-- Glaive Toss
		K.aoespam[162543] = 3		-- Poisoned Ammo
		K.aoespam[162541] = 3		-- Incendiary Ammo
		K.aoespam[34655] = 3		-- Deadly Poison (Trap)
		K.aoespam[93433] = 3		-- Burrow Attack (Worm)
		K.aoespam[92380] = 3		-- Froststorm Breath (Chimaera)
		K.merge[120761] = 121414	-- Glaive Toss
	end
	if C.CombatText.Healing then
		--BETA K.healfilter[51753] = true	-- Camouflage
	end
elseif K.Class == "MAGE" then
	if C.CombatText.MergeAoeSpam then
		K.aoespam[217694] = 3.5		-- Living Bomb
		K.aoespam[44461] = 3		-- Living Bomb (AoE)
		K.aoespam[2120] = 3			-- Flamestrike
		K.aoespam[12654] = 3		-- Ignite
		K.aoespam[31661] = 0		-- Dragon's Breath
		K.aoespam[190356] = 3		-- Blizzard
		K.aoespam[122] = 0			-- Frost Nova
		K.aoespam[1449] = 0			-- Arcane Explosion
		K.aoespam[120] = 0			-- Cone of Cold
		K.aoespam[114923] = 3		-- Nether Tempest
		K.aoespam[114954] = 3		-- Nether Tempest (AoE)
		K.aoespam[7268] = 1.6		-- Arcane Missiles
		K.aoespam[113092] = 0		-- Frost Bomb
		K.aoespam[44425] = 0		-- Arcane Barrage
		K.aoespam[84721] = 3		-- Frozen Orb
		K.aoespam[148022] = 3		-- Icicle (Mastery)
		K.aoespam[31707] = 3		-- Waterbolt (Pet)
		K.aoespam[30455] = 0		-- Ice Lance
		K.aoespam[115611] = 6		-- Temporal Ripples
		K.aoespam[157981] = 1		-- Blast Wave
		K.aoespam[157997] = 1		-- Ice Nova
		K.aoespam[157980] = 1		-- Supernova
		K.aoespam[135029] = 3		-- Water Jet (Pet)
		K.aoespam[155152] = 3		-- Prismatic Crystal
		K.aoespam[153596] = 3		-- Comet Storm
		K.aoespam[153640] = 3		-- Arcane Orb
		K.aoespam[157977] = 0		-- Unstable Magic (Fire)
		K.aoespam[157978] = 0		-- Unstable Magic (Frost)
		K.aoespam[157979] = 0		-- Unstable Magic (Arcane)
		K.aoespam[153564] = 3		-- Meteor
		K.aoespam[155158] = 3		-- Meteor Burn
		K.aoespam[224637] = 1.6		-- Phoenix's Flames
		K.aoespam[205345] = 4		-- Conflagration Flare Up
		K.aoespam[226757] = 4		-- Conflagration
		K.aoespam[198928] = 1.2		-- Cinderstorm
		K.aoespam[194316] = 3		-- Cauterizing Blink
		K.aoespam[88084] = 3		-- Arcane Blast (Mirror Image)
		K.aoespam[59638] = 3		-- Frostbolt (Mirror Image)
	end
elseif K.Class == "MONK" then
	if C.CombatText.MergeAoeSpam then
		-- Healing spells
		K.aoespam[119611] = 3		-- Renewing Mist
		--BETA K.aoespam[132120] = 3		-- Enveloping Mist
		K.aoespam[115175] = 3		-- Soothing Mist
		--BETA K.aoespam[125953] = 3		-- Soothing Mist (Statue)
		--BETA K.aoespam[126890] = 3		-- Eminence
		-- K.merge[159621] = 126890	-- Eminence
		-- K.merge[117895] = 126890	-- Eminence (Statue)
		--BETA K.aoespam[117640] = 3		-- Spinning Crane Kick
		K.aoespam[132463] = 3		-- Chi Wave
		K.aoespam[130654] = 3		-- Chi Burst
		K.aoespam[124081] = 3		-- Zen Sphere
		--BETA K.aoespam[124101] = 3		-- Zen Sphere: Detonate
		K.aoespam[116670] = 0		-- Uplift
		--BETA K.aoespam[157590] = 3		-- Breath of the Serpent
		--BETA K.aoespam[159620] = 3		-- Chi Explosion
		-- K.merge[157681] = 159620	-- Chi Explosion
		-- K.merge[173438] = 159620	-- Chi Explosion
		-- K.merge[182078] = 159620	-- Chi Explosion
		-- K.merge[173439] = 159620	-- Chi Explosion
		K.aoespam[178173] = 3		-- Gift of the Ox
		-- Damaging spells
		K.aoespam[117952] = 3		-- Crackling Jade Lightning
		K.aoespam[117418] = 3		-- Fists of Fury
		--BETA K.aoespam[128531] = 3		-- Blackout Kick (DoT)
		K.aoespam[121253] = 0		-- Keg Smash
		K.aoespam[115181] = 0		-- Breath of Fire
		K.aoespam[123725] = 3		-- Breath of Fire (DoT)
		K.aoespam[107270] = 3		-- Spinning Crane Kick
		K.aoespam[123586] = 3		-- Flying Serpent Kick
		K.aoespam[132467] = 3		-- Chi Wave
		K.aoespam[148135] = 3		-- Chi Burst
		--BETA K.aoespam[124098] = 3		-- Zen Sphere
		--BETA K.aoespam[125033] = 3		-- Zen Sphere: Detonate
		K.aoespam[158221] = 3		-- Hurricane Strike
		--BETA K.aoespam[152174] = 3		-- Chi Explosion
		-- K.merge[157680] = 152174	-- Chi Explosion
		--BETA K.aoespam[157676] = 1		-- Chi Explosion
	end
elseif K.Class == "PALADIN" then
	if C.CombatText.MergeAoeSpam then
		-- Healing spells
		--BETA K.aoespam[20167] = 3		-- Seal of Insight
		--BETA K.aoespam[123530] = 3		-- Battle Insight
		K.aoespam[53652] = 3		-- Beacon of Light
		K.aoespam[85222] = 0		-- Light of Dawn
		--BETA K.aoespam[82327] = 0		-- Holy Radiance
		--BETA K.aoespam[121129] = 0		-- Daybreak
		K.aoespam[114163] = 3		-- Eternal Flame
		K.aoespam[114852] = 0		-- Holy Prism
		K.aoespam[119952] = 3		-- Arcing Light
		--BETA K.aoespam[114917] = 3		-- Stay of Execution
		K.aoespam[144581] = 3		-- Blessing of the Guardians (T16)
		--BETA K.aoespam[159375] = 3		-- Shining Protector
		-- Damaging spells
		K.aoespam[81297] = 3		-- Consecration
		--BETA K.aoespam[119072] = .5		-- Holy Wrath
		K.aoespam[53385] = 0		-- Divine Storm
		--BETA K.aoespam[122032] = 0		-- Exorcism (Glyph)
		--BETA K.aoespam[31803] = 3		-- Censure
		--BETA K.aoespam[42463] = 3		-- Seal of Truth
		--BETA K.aoespam[101423] = 3		-- Seal of Righteousness
		K.aoespam[88263] = 0		-- Hammer of the Righteous
		--BETA K.aoespam[96172] = 3		-- Hand of Light (Mastery)
		K.aoespam[31935] = .5		-- Avenger's Shield
		K.aoespam[114871] = 0		-- Holy Prism
		K.aoespam[114919] = 3		-- Arcing Light
		--BETA K.aoespam[114916] = 3		-- Execution Sentence
		K.aoespam[86704] = 0		-- Ancient Fury
		K.aoespam[157122] = 3		-- Holy Shield
		K.merge[53595] = 88263		-- Hammer of the Righteous
	end
	if C.CombatText.Healing then
		--BETA K.healfilter[115547] = true	-- Glyph of Avenging Wrath
	end
elseif K.Class == "PRIEST" then
	if C.CombatText.MergeAoeSpam then
		-- Healing spells
		K.aoespam[47750] = 3		-- Penance
		--BETA K.aoespam[23455] = 0		-- Holy Nova
		K.aoespam[139] = 3			-- Renew
		K.aoespam[596] = 0			-- Prayer of Healing
		K.aoespam[64844] = 3		-- Divine Hymn
		K.aoespam[32546] = 3		-- Binding Heal
		K.aoespam[77489] = 3		-- Echo of Light
		K.aoespam[34861] = 0		-- Circle of Healing
		K.aoespam[33110] = 3		-- Prayer of Mending
		--BETA K.aoespam[88686] = 3		-- Holy Word: Sanctuary
		K.aoespam[81751] = 3		-- Atonement
		K.aoespam[120692] = 3		-- Halo
		--BETA K.aoespam[121148] = 3		-- Cascade
		K.aoespam[110745] = 3		-- Divine Star
		K.merge[94472] = 81751		-- Atonement
		-- Damaging spells
		K.aoespam[186723] = 3		-- Penance
		K.merge[47666] = 186723		-- Penance
		K.aoespam[132157] = 0		-- Holy Nova
		K.aoespam[589] = 3			-- Shadow Word: Pain
		K.aoespam[34914] = 3		-- Vampiric Touch
		--BETA K.aoespam[2944] = 3			-- Devouring Plague
		K.aoespam[15407] = 3		-- Mind Flay
		K.aoespam[49821] = 3		-- Mind Sear
		K.aoespam[14914] = 3		-- Holy Fire
		K.aoespam[129250] = 3		-- Power Word: Solace
		K.aoespam[120696] = 3		-- Halo
		--BETA K.aoespam[127628] = 3		-- Cascade
		K.aoespam[122128] = 3		-- Divine Star
		--BETA K.aoespam[129197] = 3		-- Insanity
		K.aoespam[148859] = 3		-- Shadowy Apparition
		--BETA K.merge[158831] = 2944		-- Devouring Plague
	end
	if C.CombatText.Healing then
		--BETA K.healfilter[127626] = true	-- Devouring Plague
		K.healfilter[15290] = true	-- Vampiric Embrace
	end
elseif K.Class == "ROGUE" then
	if C.CombatText.MergeAoeSpam then
		K.aoespam[51723] = 0		-- Fan of Knives
		--BETA K.aoespam[122233] = 3		-- Crimson Tempest (DoT)
		K.aoespam[2818] = 3			-- Deadly Poison
		K.aoespam[8680] = 3			-- Wound Poison
		K.aoespam[22482] = 3		-- Blade Flurry
		K.aoespam[16511] = 3		-- Hemorrhage
		K.aoespam[5374] = 0			-- Mutilate
		K.aoespam[86392] = 3		-- Main Gauche
		--BETA K.aoespam[157607] = 3		-- Instant Poison
		K.aoespam[57841] = 3		-- Killing Spree
		K.aoespam[1943] = 3			-- Rupture
		K.aoespam[152150] = 3		-- Death from Above
		K.aoespam[114014] = 3		-- Shuriken Toss
		--BETA K.aoespam[137584] = 3		-- Shuriken Toss
		K.merge[27576] = 5374		-- Mutilate Off-Hand
		K.merge[113780] = 2818		-- Deadly Poison
		--BETA K.merge[168908] = 16511		-- Hemorrhage
		--BETA K.merge[121411] = 122233	-- Crimson Tempest
		K.merge[57842] = 57841		-- Killing Spree Off-Hand
		--BETA K.merge[137585] = 137584	-- Shuriken Toss Off-hand
	end
elseif K.Class == "SHAMAN" then
	if C.CombatText.MergeAoeSpam then
		-- Healing spells
		K.aoespam[73921] = 3		-- Healing Rain
		K.aoespam[52042] = 3		-- Healing Stream Totem
		K.aoespam[1064] = 3			-- Chain Heal
		K.aoespam[61295] = 3		-- Riptide
		K.aoespam[98021] = 3		-- Spirit Link
		K.aoespam[114911] = 3		-- Ancestral Guidance
		K.aoespam[114942] = 3		-- Healing Tide
		K.aoespam[114083] = 3		-- Restorative Mists
		--BETA K.aoespam[157333] = 3		-- Soothing Winds
		K.aoespam[157503] = 1		-- Cloudburst
		-- Damaging spells
		K.aoespam[421] = 1			-- Chain Lightning
		--BETA K.merge[168477] = 421		-- Chain Lightning (Multi)
		K.aoespam[8349] = 0			-- Fire Nova
		K.aoespam[77478] = 3		-- Earhquake
		K.aoespam[51490] = 0		-- Thunderstorm
		K.aoespam[8187] = 3			-- Magma Totem
		K.aoespam[188389] = 3			-- Flame Shock
		K.aoespam[25504] = 3		-- Windfury Attack
		K.aoespam[10444] = 3		-- Flametongue Attack
		K.aoespam[3606] = 3			-- Searing Bolt
		K.aoespam[170379] = 3		-- Molten Earth
		K.aoespam[114074] = 1		-- Lava Beam
		--BETA K.merge[168489] = 114074	-- Lava Beam (Multi)
		K.aoespam[32175] = 0		-- Stormstrike
		K.merge[32176] = 32175		-- Stormstrike Off-Hand
		K.aoespam[114089] = 3		-- Windlash
		K.merge[114093] = 114089	-- Windlash Off-Hand
		K.aoespam[115357] = 0		-- Windstrike
		K.merge[115360] = 115357	-- Windstrike Off-Hand
		--BETA K.aoespam[177601] = 3		-- Liquid Magma
		K.aoespam[157331] = 3		-- Wind Gust
	end
elseif K.Class == "WARLOCK" then
	if C.CombatText.MergeAoeSpam then
		K.aoespam[27243] = 3		-- Seed of Corruption
		K.aoespam[27285] = 3		-- Seed of Corruption (AoE)
		--BETA K.aoespam[87385] = 3		-- Seed of Corruption (Soulburn)
		K.aoespam[146739] = 3		-- Corruption
		K.aoespam[30108] = 3		-- Unstable Affliction
		K.aoespam[348] = 3			-- Immolate
		K.aoespam[980] = 3			-- Agony
		K.aoespam[63106] = 3		-- Siphon Life
		K.aoespam[205246] = 3		-- Phantom Singularity
		K.aoespam[80240] = 3		-- Havoc
		K.aoespam[42223] = 3		-- Rain of Fire
		K.aoespam[689] = 3			-- Drain Life
		--BETA K.aoespam[5857] = 3			-- Hellfire
		--BETA K.aoespam[129476] = 3		-- Immolation Aura
		--BETA K.aoespam[103103] = 3		-- Drain Soul
		K.aoespam[86040] = 3		-- Hand of Gul'dan
		--BETA K.aoespam[124915] = 3		-- Chaos Wave
		--BETA K.aoespam[47960] = 3		-- Shadowflame
		K.aoespam[30213] = 3		-- Legion Strike (Felguard)
		K.aoespam[89753] = 3		-- Felstorm (Felguard)
		K.aoespam[20153] = 3		-- Immolation (Infrenal)
		--BETA K.aoespam[114654] = 0		-- Incinerate
		--BETA K.aoespam[108685] = 0		-- Conflagrate
		K.aoespam[22703] = 0		-- Infernal Awakening
		K.aoespam[171017] = 0		-- Meteor Strike (Infrenal)
		K.aoespam[104318] = 3		-- Fel Firebolt
		K.aoespam[3110] = 3			-- Firebolt (Imp)
		K.aoespam[152108] = 1		-- Cataclysm
		K.aoespam[171018] = 1		-- Meteor Strike
		K.aoespam[85692] = 3		-- Doom Bolt (Doomguard)
		K.aoespam[54049] = 3		-- Shadow Bite (Felhunter)
		K.aoespam[6262] = 3			-- Healthstone
		K.aoespam[3716] = 3			-- Torment (Voidwalker)
		K.merge[157736] = 348		-- Immolate
		--BETA K.merge[108686] = 348		-- Immolate
		--BETA K.merge[131737] = 980		-- Agony (Drain Soul)
		--BETA K.merge[131740] = 146739	-- Corruption (Drain Soul)
		--BETA K.merge[131736] = 30108		-- Unstable Affliction (Drain Soul)
	end
	if C.CombatText.Healing then
		K.healfilter[63106] = true	-- Siphon Life
		--BETA K.healfilter[89653] = true	-- Drain Life
		K.healfilter[108359] = true	-- Dark Regeneration
	end
elseif K.Class == "WARRIOR" then
	if C.CombatText.MergeAoeSpam then
		K.aoespam[46968] = 0		-- Shockwave
		K.aoespam[6343] = 0			-- Thunder Clap
		K.aoespam[1680] = 0			-- Whirlwind
		K.aoespam[115767] = 3		-- Deep Wounds
		K.aoespam[50622] = 3		-- Bladestorm
		K.aoespam[52174] = 0		-- Heroic Leap
		K.aoespam[118000] = 0		-- Dragon Roar
		--BETA K.aoespam[76858] = 3		-- Opportunity Strike
		K.aoespam[113344] = 3		-- Bloodbath
		K.aoespam[96103] = 0		-- Raging Blow
		K.aoespam[6572] = 0			-- Revenge
		K.aoespam[5308] = 0			-- Execute
		K.aoespam[772] = 3			-- Rend
		K.aoespam[156287] = 3		-- Ravager
		K.merge[44949] = 1680		-- Whirlwind Off-Hand
		K.merge[85384] = 96103		-- Raging Blow Off-Hand
		K.merge[95738] = 50622		-- Bladestorm Off-Hand
		K.merge[163558] = 5308		-- Execute Off-Hand
		--BETA K.merge[94009] = 772		-- Rend
	end
	if C.CombatText.Healing then
		K.healfilter[117313] = true	-- Bloodthirst Heal
		--BETA K.healfilter[55694] = true	-- Enraged Regeneration
		--BETA K.healfilter[159363] = true	-- Blood Craze
	end
end