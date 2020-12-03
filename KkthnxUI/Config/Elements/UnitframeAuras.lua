local K, C = unpack(select(2, ...))

local _G = _G
local unpack = _G.unpack

local IsPlayerSpell = _G.IsPlayerSpell

local function Defaults(priorityOverride)
	return {
		enable = true,
		priority = priorityOverride or 0,
		stackThreshold = 0
	}
end

-- AuraWatch: List of personal spells to show on unitframes as icon
local function AuraWatch_AddSpell(id, point, color, anyUnit, onlyShowMissing, displayText, textThreshold, xOffset, yOffset)

	local r, g, b = 1, 1, 1
	if color then
		r, g, b = unpack(color)
	end

	return {
		id = id,
		enabled = true,
		point = point or "TOPLEFT",
		color = {r = r, g = g, b = b},
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

C.DebuffsTracking = {}
C.DebuffsTracking["RaidDebuffs"] = {
	type = "Whitelist",
	spells = {
		-- Mythic+ Dungeons
		-- General Affix
		[209858] = Defaults(), -- Necrotic
		[226512] = Defaults(), -- Sanguine
		[240559] = Defaults(), -- Grievous
		[240443] = Defaults(), -- Bursting
		-- Shadowlands Affix
		[342494] = Defaults(), -- Belligerent Boast (Prideful)

		-- Shadowlands Dungeons
		-- Halls of Atonement
		[335338] = Defaults(), -- Ritual of Woe
		[326891] = Defaults(), -- Anguish
		[329321] = Defaults(), -- Jagged Swipe 1
		[344993] = Defaults(), -- Jagged Swipe 2
		[319603] = Defaults(), -- Curse of Stone
		[319611] = Defaults(), -- Turned to Stone
		[325876] = Defaults(), -- Curse of Obliteration
		[326632] = Defaults(), -- Stony Veins
		[323650] = Defaults(), -- Haunting Fixation
		[326874] = Defaults(), -- Ankle Bites
		[340446] = Defaults(), -- Mark of Envy
		-- Mists of Tirna Scithe
		[325027] = Defaults(), -- Bramble Burst
		[323043] = Defaults(), -- Bloodletting
		[322557] = Defaults(), -- Soul Split
		[331172] = Defaults(), -- Mind Link
		[322563] = Defaults(), -- Marked Prey
		[322487] = Defaults(), -- Overgrowth 1
		[322486] = Defaults(), -- Overgrowth 2
		[328756] = Defaults(), -- Repulsive Visage
		[325021] = Defaults(), -- Mistveil Tear
		[321891] = Defaults(), -- Freeze Tag Fixation
		[325224] = Defaults(), -- Anima Injection
		[326092] = Defaults(), -- Debilitating Poison
		[325418] = Defaults(), -- Volatile Acid
		-- Plaguefall
		[336258] = Defaults(), -- Solitary Prey
		[331818] = Defaults(), -- Shadow Ambush
		[329110] = Defaults(), -- Slime Injection
		[325552] = Defaults(), -- Cytotoxic Slash
		[336301] = Defaults(), -- Web Wrap
		[322358] = Defaults(), -- Burning Strain
		[322410] = Defaults(), -- Withering Filth
		[328180] = Defaults(), -- Gripping Infection
		[320542] = Defaults(), -- Wasting Blight
		[340355] = Defaults(), -- Rapid Infection
		[328395] = Defaults(), -- Venompiercer
		[320512] = Defaults(), -- Corroded Claws
		[333406] = Defaults(), -- Assassinate
		[332397] = Defaults(), -- Shroudweb
		[330069] = Defaults(), -- Concentrated Plague
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
		[343504] = Defaults(), -- Dark Grasp
		[343556] = Defaults(), -- Morbid Fixation 1
		[338606] = Defaults(), -- Morbid Fixation 2
		[324381] = Defaults(), -- Chill Scythe
		[320573] = Defaults(), -- Shadow Well
		[333492] = Defaults(), -- Necrotic Ichor
		[334748] = Defaults(), -- Drain FLuids
		[333489] = Defaults(), -- Necrotic Breath
		[320717] = Defaults(), -- Blood Hunger
		-- Theater of Pain
		[333299] = Defaults(), -- Curse of Desolation 1
		[333301] = Defaults(), -- Curse of Desolation 2
		[319539] = Defaults(), -- Soulless
		[326892] = Defaults(), -- Fixate
		[321768] = Defaults(), -- On the Hook
		[323825] = Defaults(), -- Grasping Rift
		[342675] = Defaults(), -- Bone Spear
		[323831] = Defaults(), -- Death Grasp
		[330608] = Defaults(), -- Vile Eruption
		[330868] = Defaults(), -- Necrotic Bolt Volley
		[323750] = Defaults(), -- Vile Gas
		[323406] = Defaults(), -- Jagged Gash
		[330700] = Defaults(), -- Decaying Blight
		[319626] = Defaults(), -- Phantasmal Parasite
		[324449] = Defaults(), -- Manifest Death
		[341949] = Defaults(), -- Withering Blight
		-- Sanguine Depths
		[326827] = Defaults(), -- Dread Bindings
		[326836] = Defaults(), -- Curse of Suppression
		[322554] = Defaults(), -- Castigate
		[321038] = Defaults(), -- Burden Soul
		[328593] = Defaults(), -- Agonize
		[325254] = Defaults(), -- Iron Spikes
		[335306] = Defaults(), -- Barbed Shackles
		[322429] = Defaults(), -- Severing Slice
		[334653] = Defaults(), -- Engorge
		-- Spires of Ascension
		[338729] = Defaults(), -- Charged Stomp
		[338747] = Defaults(), -- Purifying Blast
		[327481] = Defaults(), -- Dark Lance
		[322818] = Defaults(), -- Lost Confidence
		[322817] = Defaults(), -- Lingering Doubt
		[324205] = Defaults(), -- Blinding Flash
		[331251] = Defaults(), -- Deep Connection
		[328331] = Defaults(), -- Forced Confession
		[341215] = Defaults(), -- Volatile Anima
		[323792] = Defaults(), -- Anima Field
		[317661] = Defaults(), -- Insidious Venom
		[330683] = Defaults(), -- Raw Anima
		[328434] = Defaults(), -- Intimidated
		-- De Other Side
		[320786] = Defaults(), -- Power Overwhelming
		[334913] = Defaults(), -- Master of Death
		[325725] = Defaults(), -- Cosmic Artifice
		[328987] = Defaults(), -- Zealous
		[334496] = Defaults(), -- Soporific Shimmerdust
		[339978] = Defaults(), -- Pacifying Mists
		[323692] = Defaults(), -- Arcane Vulnerability
		[333250] = Defaults(), -- Reaver
		[330434] = Defaults(), -- Buzz-Saw 1
		[320144] = Defaults(), -- Buzz-Saw 2
		[331847] = Defaults(), -- W-00F
		[327649] = Defaults(), -- Crushed Soul
		[331379] = Defaults(), -- Lubricate
		[332678] = Defaults(), -- Gushing Wound
		[322746] = Defaults(), -- Corrupted Blood
		[323687] = Defaults(), -- Arcane Lightning
		[323877] = Defaults(), -- Echo Finger Laser X-treme
		[334535] = Defaults(), -- Beak Slice

		-- Castle Nathria
		-- Shriekwing
		[328897] = Defaults(), -- Exsanguinated
		[330713] = Defaults(), -- Reverberating Pain
		[329370] = Defaults(), -- Deadly Descent
		[336494] = Defaults(), -- Echo Screech
		-- Huntsman Altimor
		[335304] = Defaults(), -- Sinseeker
		[334971] = Defaults(), -- Jagged Claws
		[335111] = Defaults(), -- Huntsman's Mark 1
		[335112] = Defaults(), -- Huntsman's Mark 2
		[335113] = Defaults(), -- Huntsman's Mark 3
		[334945] = Defaults(), -- Bloody Thrash
		-- Hungering Destroyer
		[334228] = Defaults(), -- Volatile Ejection
		[329298] = Defaults(), -- Gluttonous Miasma
		-- Lady Inerva Darkvein
		[325936] = Defaults(), -- Shared Cognition
		[335396] = Defaults(), -- Hidden Desire
		[324983] = Defaults(), -- Shared Suffering
		[324982] = Defaults(), -- Shared Suffering (Partner)
		[332664] = Defaults(), -- Concentrate Anima
		[325382] = Defaults(), -- Warped Desires
		-- Sun King's Salvation
		[333002] = Defaults(), -- Vulgar Brand
		[326078] = Defaults(), -- Infuser's Boon
		[325251] = Defaults(), -- Sin of Pride
		-- Artificer Xy'mox
		[327902] = Defaults(), -- Fixate
		[326302] = Defaults(), -- Stasis Trap
		[325236] = Defaults(), -- Glyph of Destruction
		[327414] = Defaults(), -- Possession
		-- The Council of Blood
		[327052] = Defaults(), -- Drain Essence 1
		[327773] = Defaults(), -- Drain Essence 2
		[346651] = Defaults(), -- Drain Essence Mythic
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
		[334765] = Defaults(), -- Heart Rend
		[333377] = Defaults(), -- Wicked Mark
		[334616] = Defaults(), -- Petrified
		[334541] = Defaults(), -- Curse of Petrification
		[339690] = Defaults(), -- Crystalize
		[342655] = Defaults(), -- Volatile Anima Infusion
		[342698] = Defaults(), -- Volatile Anima Infection
		-- Sire Denathrius
		[326851] = Defaults(), -- Blood Price
		[327796] = Defaults(), -- Night Hunter
		[327992] = Defaults(), -- Desolation
		[328276] = Defaults(), -- March of the Penitent
		[326699] = Defaults(), -- Burden of Sin
		[329181] = Defaults(), -- Wracking Pain
		[335873] = Defaults(), -- Rancor
		[329951] = Defaults(), -- Impale

	},
}

-- CC DEBUFFS (TRACKING LIST)
C.DebuffsTracking["CCDebuffs"] = {
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
		[205630] = Defaults(3), -- Illidan's Grasp
		[208618] = Defaults(3), -- Illidan's Grasp (Afterward)
		[213491] = Defaults(4), -- Demonic Trample (it's this one or the other)
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
		[102793] = Defaults(1), -- Ursol's Vortex
		-- Hunter
		[202933] = Defaults(2), -- Spider Sting (it's this one or the other)
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
		[212638] = Defaults(1), -- Tracker's Net
		[200108] = Defaults(1), -- Ranger's Net
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
		[31661] = Defaults(3), -- Dragon's Breath
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
		[232055] = Defaults(4), -- Fists of Fury (it's this one or the other)
		-- Paladin
		[853] = Defaults(3), -- Hammer of Justice
		[20066] = Defaults(3), -- Repentance
		[105421] = Defaults(3), -- Blinding Light
		[31935] = Defaults(2), -- Avenger's Shield
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
C.BuffsTracking = {
	GLOBAL = {},
	PRIEST = {
		[139] = AuraWatch_AddSpell(139, 'BOTTOMLEFT', {0.4, 0.7, 0.2}),			-- Renew
		[17] = AuraWatch_AddSpell(17, 'TOPLEFT', {0.7, 0.7, 0.7}, true), 		-- Power Word: Shield
		[193065] = AuraWatch_AddSpell(193065, 'BOTTOMRIGHT', {0.54, 0.21, 0.78}),	-- Masochism
		[194384] = AuraWatch_AddSpell(194384, 'TOPRIGHT', {1, 1, 0.66}), 			-- Atonement
		[214206] = AuraWatch_AddSpell(214206, 'TOPRIGHT', {1, 1, 0.66}), 			-- Atonement (PvP)
		[33206] = AuraWatch_AddSpell(33206, 'LEFT', {0.47, 0.35, 0.74}, true),		-- Pain Suppression
		[41635] = AuraWatch_AddSpell(41635, 'BOTTOMRIGHT', {0.2, 0.7, 0.2}),		-- Prayer of Mending
		[47788] = AuraWatch_AddSpell(47788, 'LEFT', {0.86, 0.45, 0}, true), 		-- Guardian Spirit
		[6788] = AuraWatch_AddSpell(6788, 'BOTTOMLEFT', {0.89, 0.1, 0.1}), 		-- Weakened Soul
	},
	DRUID = {
		[774] = AuraWatch_AddSpell(774, 'TOPRIGHT', {0.8, 0.4, 0.8}), 			-- Rejuvenation
		[155777] = AuraWatch_AddSpell(155777, 'RIGHT', {0.8, 0.4, 0.8}), 			-- Germination
		[8936] = AuraWatch_AddSpell(8936, 'BOTTOMLEFT', {0.2, 0.8, 0.2}),			-- Regrowth
		[33763] = AuraWatch_AddSpell(33763, 'TOPLEFT', {0.4, 0.8, 0.2}), 			-- Lifebloom
		[188550] = AuraWatch_AddSpell(188550, 'TOPLEFT', {0.4, 0.8, 0.2}),			-- Lifebloom (Shadowlands Legendary)
		[48438] = AuraWatch_AddSpell(48438, 'BOTTOMRIGHT', {0.8, 0.4, 0}),			-- Wild Growth
		[207386] = AuraWatch_AddSpell(207386, 'TOP', {0.4, 0.2, 0.8}), 				-- Spring Blossoms
		[102351] = AuraWatch_AddSpell(102351, 'LEFT', {0.2, 0.8, 0.8}),				-- Cenarion Ward (Initial Buff)
		[102352] = AuraWatch_AddSpell(102352, 'LEFT', {0.2, 0.8, 0.8}),				-- Cenarion Ward (HoT)
		[200389] = AuraWatch_AddSpell(200389, 'BOTTOM', {1, 1, 0.4}),				-- Cultivation
		[203554] = AuraWatch_AddSpell(203554, 'TOP', {1, 1, 0.4}),					-- Focused Growth (PvP)
	},
	PALADIN = {
		[53563] = AuraWatch_AddSpell(53563, 'TOPRIGHT', {0.7, 0.3, 0.7}),			-- Beacon of Light
		[156910] = AuraWatch_AddSpell(156910, 'TOPRIGHT', {0.7, 0.3, 0.7}),			-- Beacon of Faith
		[200025] = AuraWatch_AddSpell(200025, 'TOPRIGHT', {0.7, 0.3, 0.7}),			-- Beacon of Virtue
		[1022] = AuraWatch_AddSpell(1022, 'BOTTOMRIGHT', {0.2, 0.2, 1}, true), 		-- Blessing of Protection
		[1044] = AuraWatch_AddSpell(1044, 'BOTTOMRIGHT', {0.89, 0.45, 0}, true),	-- Blessing of Freedom
		[6940] = AuraWatch_AddSpell(6940, 'BOTTOMRIGHT', {0.89, 0.1, 0.1}, true),	-- Blessing of Sacrifice
		[204018] = AuraWatch_AddSpell(204018, 'BOTTOMRIGHT', {0.2, 0.2, 1}, true),	-- Blessing of Spellwarding
		[223306] = AuraWatch_AddSpell(223306, 'BOTTOMLEFT', {0.7, 0.7, 0.3}),		-- Bestow Faith
		[287280] = AuraWatch_AddSpell(287280, 'TOPLEFT', {0.2, 0.8, 0.2}),			-- Glimmer of Light (T50 Talent)
		[157047] = AuraWatch_AddSpell(157047, 'TOP', {0.15, 0.58, 0.84}),			-- Saved by the Light (T25 Talent)
	},
	SHAMAN = {
		[61295] = AuraWatch_AddSpell(61295, 'TOPRIGHT', {0.7, 0.3, 0.7}),			-- Riptide
		[974] = AuraWatch_AddSpell(974, 'BOTTOMRIGHT', {0.2, 0.2, 1}),				-- Earth Shield
	},
	MONK = {
		[119611] = AuraWatch_AddSpell(119611, 'TOPLEFT', {0.3, 0.8, 0.6}),			-- Renewing Mist
		[116849] = AuraWatch_AddSpell(116849, 'TOPRIGHT', {0.2, 0.8, 0.2}, true),	-- Life Cocoon
		[124682] = AuraWatch_AddSpell(124682, 'BOTTOMLEFT', {0.8, 0.8, 0.25}),		-- Enveloping Mist
		[191840] = AuraWatch_AddSpell(191840, 'BOTTOMRIGHT', {0.27, 0.62, 0.7}),		-- Essence Font
		[116841] = AuraWatch_AddSpell(116841, 'TOP', {0.12, 1.00, 0.53}),			-- Tiger's Lust (Freedom)
		[325209] = AuraWatch_AddSpell(325209, 'BOTTOM', {0.3, 0.8, 0.6}),			-- Enveloping Breath
	},
	ROGUE = {
		[57934] = AuraWatch_AddSpell(57934, 'TOPRIGHT', {0.89, 0.09, 0.05}),		-- Tricks of the Trade
	},
	WARRIOR = {
		[3411] = AuraWatch_AddSpell(3411, 'TOPRIGHT', {0.89, 0.09, 0.05}),			-- Intervene
	},
	PET = {
		-- Warlock Pets
		[193396] = AuraWatch_AddSpell(193396, 'TOPRIGHT', {0.6, 0.2, 0.8}, true),	-- Demonic Empowerment
		-- Hunter Pets
		[272790] = AuraWatch_AddSpell(272790, 'TOPLEFT', {0.89, 0.09, 0.05}, true),	-- Frenzy
		[136] = AuraWatch_AddSpell(136, 'TOPRIGHT', {0.2, 0.8, 0.2}, true),		-- Mend Pet
	},
	HUNTER = {
		[90361] = AuraWatch_AddSpell(90361, 'TOP', {0.34, 0.47, 0.31}),				-- Spirit Mend (HoT)
	},
	DEMONHUNTER = {},
	WARLOCK = {},
	MAGE = {},
	DEATHKNIGHT = {},
}

-- Filter this. Pointless to see.
C.AuraBlackList = {
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

C.ChannelingTicks = {
	[120360] = 15, -- Barrage shooting
	[12051] = 6, -- wake
	[15407] = 6, -- Mental Flay
	[198013] = 10, -- Eye rim
	[198590] = 5, -- Draw soul
	[205021] = 5, -- Frost Ray
	[205065] = 6, -- Void Torrent
	[206931] = 3, -- Blood drinker
	[212084] = 10,	-- Fel Destroy
	[234153] = 5,	-- Draw life
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