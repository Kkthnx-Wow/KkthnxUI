local K, C, L = unpack(select(2, ...))
if C["Raidframe"].AuraWatch ~= true or C["Raidframe"].Enable ~= true then return end

local _G = _G
local GetSpellInfo = _G.GetSpellInfo

K.RaidBuffs = {
	PRIEST = {
		{139, "BOTTOMLEFT", {0.4, 0.7, 0.2}}, -- Renew
		{17, "TOPLEFT", {0.81, 0.85, 0.1}, true}, -- Power Word: Shield
		{194384, "TOPRIGHT", {1, 0, 0.75}}, -- Atonement
		{33206, "LEFT", {227/255, 23/255, 13/255}, true}, -- Pain Suppression
		{41635, "BOTTOMRIGHT", {0.2, 0.7, 0.2}}, -- Prayer of Mending
		{47788, "LEFT", {221/255, 117/255, 0}, true}, -- Guardian Spirit
	},
	DRUID = {
		{102351, "LEFT", {0.2, 0.8, 0.8}}, -- Cenarion Ward (Initial Buff)
		{102352, "LEFT", {0.2, 0.8, 0.8}}, -- Cenarion Ward (HoT)
		{155777, "RIGHT", {0.8, 0.4, 0.8}}, -- Germination
		{188550, "TOPLEFT", {0.4, 0.8, 0.2}}, -- Lifebloom T18 4pc
		{200389, "BOTTOM", {1, 1, 0.4}}, -- Cultivation
		{207386, "TOP", {0.4, 0.2, 0.8}}, -- Spring Blossoms
		{33763, "TOPLEFT", {0.4, 0.8, 0.2}}, -- Lifebloom
		{48438, "BOTTOMRIGHT", {0.8, 0.4, 0}}, -- Wild Growth
		{774, "TOPRIGHT", {0.8, 0.4, 0.8}}, -- Rejuvenation
		{8936, "BOTTOMLEFT", {0.2, 0.8, 0.2}}, -- Regrowth
	},
	PALADIN = {
		{1022, "BOTTOMRIGHT", {0.2, 0.2, 1}, true}, -- Hand of Protection
		{1044, "BOTTOMRIGHT", {0.89, 0.45, 0}, true}, -- Hand of Freedom
		{114163, 'BOTTOMLEFT', {0.87, 0.7, 0.03}},   -- Eternal Flame
		{156910, "TOPRIGHT", {0.7, 0.3, 0.7}},       -- Beacon of Faith
		{53563, "TOPRIGHT", {0.7, 0.3, 0.7}},         -- Beacon of Light
		{6940, "BOTTOMRIGHT", {0.89, 0.1, 0.1}, true}, -- Hand of Sacrifice
	},
	SHAMAN = {
		{61295, "TOPRIGHT", {0.7, 0.3, 0.7}}, -- Riptide
	},
	MONK = {
		{116849, "TOPRIGHT", {0.2, 0.8, 0.2}},   -- Life Cocoon
		{119611, "TOPLEFT", {0.8, 0.4, 0.8}}, --Renewing Mist
		{124081, "BOTTOMRIGHT", {0.7, 0.4, 0}}, -- Zen Sphere
		{124682, "BOTTOMLEFT", {0.4, 0.8, 0.2}}, -- Enveloping Mist
	},
	ROGUE = {
		{57934, "TOPRIGHT", {227/255, 23/255, 13/255}}, -- Tricks of the Trade
	},
	WARRIOR = {
		{114030, "TOPLEFT", {0.2, 0.2, 1}},          -- Vigilance
		{3411, "TOPRIGHT", {227/255, 23/255, 13/255}}, -- Intervene
	},
	ALL = {
		{14253, "RIGHT", {0, 1, 0}}, -- Abolish Poison
	},
	DEATHKNIGHT = {},
	DEMONHUNTER = {},
	HUNTER = {},
	MAGE = {},
	WARLOCK = {},
}

local function SpellName(id)
	local name, _, _, _, _, _, _, _, _ = GetSpellInfo(id)
	if not name then
		print("|cff3c9bedKkthnxUI:|r SpellID is not valid: "..id..". Please check for an updated version, if none exists report to KkthnxUI author.")
		return "Impale"
	else
		return name
	end
end

K.RaidDebuffs = {
	-- The Nighthold
	 -- Skorpyron
	[SpellName(211659)] = 3, -- Arcane Tether
	[SpellName(204483)] = 3, -- Focused Blast
	 -- Chronomatic Anomaly
	[SpellName(206609)] = 3, -- Time Release
	[SpellName(206607)] = 3, -- Chronometric Particles
	 -- Trilliax
	[SpellName(206788)] = 3, -- Toxic Slice
	[SpellName(206641)] = 3, -- Arcane Slash
	 -- Spellblade Aluriel
	[SpellName(212492)] = 3, -- Annihilate
	[SpellName(212494)] = 3, -- Annihilated
	[SpellName(212587)] = 3, -- Mark of Frost
	 -- Tichondrius
	[SpellName(206480)] = 3, -- Carrion Plague
	[SpellName(216040)] = 3, -- Burning Soul
	[SpellName(208230)] = 3, -- Feast of Blood
	 -- Krosus
	[SpellName(206677)] = 3, -- Searing Brand
	 -- High Botanist Tel'arn
	[SpellName(218304)] = 3, -- Parasitic Fetter
	[SpellName(218503)] = 3, -- Recursive Strikes
	 -- Star Augur Etraeus
	[SpellName(206936)] = 3, -- Icy Ejection
	 -- Gul'dan
	[SpellName(206222)] = 3, -- Bonds of Fel
	[SpellName(212568)] = 3, -- Drain
	[SpellName(206875)] = 3, -- Fel Obelisk
	-- Trial of Valor
 	-- Odyn
	[SpellName(198088)] = 3, -- Glowing Fragment
	[SpellName(228915)] = 3, -- Stormforged Spear
	[SpellName(227959)] = 3, -- Storm of Justice
	[SpellName(227475)] = 3, -- Cleansing Flame
 	-- Guarm
	[SpellName(227570)] = 3, -- Dark Discharge
	[SpellName(227566)] = 3, -- Salty Spittle
	[SpellName(227539)] = 3, -- Fiery Phlegm
	[SpellName(228250)] = 4, -- Shadow Lick
	[SpellName(228246)] = 4, -- Frost Lick
	[SpellName(228226)] = 4, -- Flame Lick
	 -- Helya
	[SpellName(228054)] = 3, -- Taint of the Sea
	[SpellName(227982)] = 3, -- Bilewater Redox
	[SpellName(193367)] = 3, -- Fetid Rot
	[SpellName(227903)] = 3, -- Orb of Corruption
	[SpellName(228058)] = 3, -- Orb of Corrosion
	[SpellName(228519)] = 3, -- Anchor Slam
	[SpellName(202476)] = 3, -- Rabid
	[SpellName(232450)] = 3, -- Corrupted Axion
	-- The Emerald Nightmare
 	-- Nythendra
	[SpellName(204504)] = 5, -- Infested
	[SpellName(203096)] = 3, -- Rot
	[SpellName(204463)] = 3, -- Volatile Rot
	[SpellName(203646)] = 4, -- Burst of Corruption
 	-- Il'gynoth, Heart of Corruption
	[SpellName(215845)] = 3, -- Dispersed Spores
	[SpellName(210099)] = 6, -- Fixate
	[SpellName(209469)] = 5, -- Touch of Corruption
	[SpellName(210984)] = 3, -- Eye of Fate
	[SpellName(208697)] = 4, -- Mind Flay
	[SpellName(208929)] = 3, -- Spew Corruption
	[SpellName(215128)] = 3, -- Cursed Blood
 	-- Erethe Renferal
	[SpellName(215582)] = 4, -- Raking Talons
	[SpellName(218519)] = 4, -- Wind Burn
	[SpellName(215307)] = 4, -- Web of Pain
	[SpellName(215449)] = 3, -- Necrotic Venom
	[SpellName(215460)] = 3, -- Necrotic Venom
	[SpellName(210850)] = 4, -- Twisting Shadows
 	-- Ursoc
	[SpellName(197943)] = 3, -- Overwhelm
	[SpellName(204859)] = 4, -- Rend Flesh
	[SpellName(198006)] = 3, -- Focused Gaze
	[SpellName(198108)] = 3, -- Momentum
 	-- Dragons of Nightmare
	[SpellName(207681)] = 4, -- Nightmare Bloom
	[SpellName(203770)] = 3, -- Defiled Vines
	[SpellName(203787)] = 3, -- Volatile Infection
	[SpellName(204044)] = 3, -- Shadow Burst
	[SpellName(205341)] = 3, -- Seeping Fog
	[SpellName(204078)] = 3, -- Bellowing Roar
 	-- Cenarius
	[SpellName(210315)] = 3, -- Nightmare Brambles
	[SpellName(226821)] = 3, -- Desiccating Stomp
	[SpellName(211507)] = 3, -- Nightmare Javelin
	[SpellName(211471)] = 3, -- Scorned Touch
	[SpellName(214529)] = 3, -- Spear of Nightmares
	[SpellName(210279)] = 3, -- Creeping Nightmare
 	-- Xavius
	[SpellName(208431)] = 3, -- Descent into Madness
	[SpellName(206651)] = 3, -- Darkening Soul
	[SpellName(209158)] = 3, -- Blackening Soul
	[SpellName(211802)] = 3, -- Nightmare Blades
	[SpellName(205771)] = 3, -- Tormenting Fixation
	[SpellName(210451)] = 3, -- Bonds of Terror
	[SpellName(224508)] = 3, -- Corruption Meteor

 	-- Legion Dungeon
 	-- Mythic+ Affixes
	[SpellName(221772)] = 5, -- Overflowing
	[SpellName(209858)] = 5, -- Necrotic
	[SpellName(226512)] = 5, -- Sanguine
 	-- Black Rook Hold
 	-- Trash Mobs
	[SpellName(194969)] = 3, -- Soul Echoes
	[SpellName(225962)] = 3, -- Bloodthirsty Leap
	[SpellName(200261)] = 3, -- Bonebreaking Strike
	[SpellName(222397)] = 3, -- Boulder Crush
	[SpellName(214001)] = 3, -- Raven's Dive
 	-- Illysanna Ravencrest
	[SpellName(197546)] = 3, -- Brutal Glaive
	[SpellName(197484)] = 3, -- Dark Rush
	[SpellName(197687)] = 4, -- Eye Beams
	-- Smashspite
	[SpellName(198446)] = 3, -- Fel Vomit
	[SpellName(198245)] = 3, -- Brutal Haymaker
 	-- Lord Ravencrest
	[SpellName(201733)] = 3, -- Stinging Swarm
 	-- Court of Stars
 	-- Trash Mobs
	[SpellName(209413)] = 3, -- Suppress
	[SpellName(209512)] = 3, -- Disrupting Energy
	[SpellName(211473)] = 3, -- Shadow Slash
	[SpellName(211464)] = 3, -- Fel Detonation
	[SpellName(207980)] = 3, -- Disintegration Beam
	[SpellName(207979)] = 3, -- Shockwave
 	-- Advisor Melandrus
	[SpellName(209602)] = 3, -- Blade Surge
	[SpellName(224333)] = 4, -- Enveloping Winds
 	-- Darkheart Thicket
 	-- Trash Mobs
	[SpellName(200620)] = 3, -- Frantic Rip
	[SpellName(225484)] = 3, -- Grievous Rip
	[SpellName(200631)] = 4, -- Unnerving Screech
	[SpellName(201400)] = 3, -- Dread Inferno
	[SpellName(201361)] = 4, -- Darksoul Bite
 	-- Archdruid Glaidalis
	[SpellName(198408)] = 4, -- Nightfall
	[SpellName(196376)] = 3, -- Grievous Tear
 	-- Shade of Xavius
	[SpellName(200289)] = 4, -- Growing Paranoia
	[SpellName(200329)] = 4, -- Overwhelming Terror
	[SpellName(200238)] = 3, -- Feed on the Weak
 	-- Eye of Azshara
 	-- Trash Mobs
	[SpellName(196111)] = 4, -- Jagged Claws
	[SpellName(195561)] = 3, -- Blinding Peck
 	-- Warlord Parjesh
	[SpellName(192094)] = 3, -- Impaling Spear
 	-- Serpentrix
	[SpellName(191855)] = 3, -- Toxic Wound
	[SpellName(191858)] = 4, -- Toxic Puddle
 	-- King Deepbeard
	[SpellName(193018)] = 3, -- Gaseous Bubbles
 	-- Wrath of Azshara
	[SpellName(197365)] = 4, -- Crushing Depths
	[SpellName(192706)] = 3, -- Arcane Bomb
 	-- Halls of Valor
 	-- Trash Mobs
	[SpellName(198605)] = 3, -- Thunderstrike
	[SpellName(199805)] = 3, -- Crackle
	[SpellName(199050)] = 3, -- Mortal Hew
	[SpellName(199341)] = 3, -- Bear Trap
	[SpellName(196194)] = 3, -- Raven's Dive
	[SpellName(199674)] = 3, -- Wicked Dagger
 	-- Hymdall
	[SpellName(193092)] = 3, -- Bloodletting Sweep
 	-- Hyrja
	[SpellName(192048)] = 3, -- Expel Light
 	-- Fenryr
	[SpellName(197556)] = 4, -- Ravenous Leap
	[SpellName(196838)] = 3, -- Scent of Blood
	[SpellName(196497)] = 4, -- Ravenous Leap
 	-- Odyn
	[SpellName(198088)] = 4, -- Glowing Fragment
 	-- Maw of Souls
 	-- Trash Mobs
	[SpellName(201566)] = 3, -- Swirling Muck
	[SpellName(191960)] = 5, -- Barbed Spear
	[SpellName(199061)] = 4, -- Hew Soul
	[SpellName(222397)] = 4, -- Breach Armor
	[SpellName(201397)] = 4, -- Brackwater Blast
	[SpellName(194102)] = 4, -- Poisonous Sludge
 	-- Harbaron
	[SpellName(194325)] = 3, -- Fragment
	[SpellName(194235)] = 4, -- Nether Rip
 	-- Helya
	[SpellName(185539)] = 3, -- Rapid Rupture
 	-- Neltharion's Lair
 	-- Trash Mobs
	[SpellName(226296)] = 3, -- Piercing Shards
	[SpellName(193639)] = 4, -- Bone Chomp
	[SpellName(202181)] = 3, -- Stone Gaze
	[SpellName(186616)] = 3, -- Petrified
	[SpellName(202231)] = 3, -- Leech
	[SpellName(200154)] = 4, -- Burning Hatred
	[SpellName(193585)] = 3, -- Bound
 	-- Rokmora
	[SpellName(192799)] = 3, -- Choking Dust
 	-- Naraxas
	[SpellName(205549)] = 3, -- Rancid Maw
	-- The Arcway
 	-- Trash Mobs
	[SpellName(202156)] = 4, -- Corrosion
	[SpellName(202223)] = 4, -- Consume
	[SpellName(194006)] = 4, -- Ooze Puddle
	[SpellName(210688)] = 3, -- Collapsing Rift
	[SpellName(226269)] = 3, -- Torment
	[SpellName(211756)] = 3, -- Searing Wound
	[SpellName(211217)] = 3, -- Arcane Slicer
	[SpellName(211543)] = 3, -- Devour
 	-- Corstilax
	[SpellName(195791)] = 3, -- Quarantine
 	-- Ivanyr
	[SpellName(196804)] = 3, -- Nether Link
	[SpellName(196562)] = 3, -- Volatile Magic
 	-- Nal'tira
	[SpellName(200040)] = 4, -- Nether Venom
	[SpellName(200227)] = 3, -- Tangled Web
 	-- Advisor Vandros
	[SpellName(220871)] = 3, -- Unstable Mana
 	-- Vault of the Wardens
 	-- Trash Mobs
	[SpellName(191735)] = 3, -- Deafening Screech
	[SpellName(210202)] = 4, -- Foul Stench
	[SpellName(202658)] = 3, -- Drain
	[SpellName(193164)] = 3, -- Gift of the Doomsayer
	[SpellName(202615)] = 3, -- Torment
	[SpellName(193969)] = 3, -- Razors
 	-- Inquisitor Tormentorum
	[SpellName(201488)] = 3, -- Frightening Shout
	[SpellName(225416)] = 3, -- Intercept
	[SpellName(214804)] = 3, -- Seed of Corruption
	[SpellName(201488)] = 3, -- Frightening Shout
 	-- Glazer
	[SpellName(194945)] = 3, -- Lingering Gaze
 	-- Ash'Golm
	[SpellName(192519)] = 3, -- Lava
 	-- Cordana Felsong
	[SpellName(197541)] = 3, -- Detonation
	[SpellName(213583)] = 4, -- Deepening Shadows
 	-- Violet Hold
 	-- Trash Mobs
	[SpellName(204608)] = 3, -- Fel Prison
	[SpellName(204901)] = 3, -- Carrion Swarm
	[SpellName(205097)] = 3, -- Fel Blind
	[SpellName(205096)] = 3, -- Fel Poison
 	-- Anub'esset
	[SpellName(202217)] = 3, -- Mandible Strike
 	-- Blood-Princess Thal'ena
	[SpellName(202779)] = 3, -- Essence of the Blood Princess
 	-- Millificent Manastorm
	[SpellName(201159)] = 3, -- Delta Finger Laser X-treme
 	-- Mindflayer Kaahrj
	[SpellName(197783)] = 3, -- Shadow Crash
 	-- Shivermaw
	[SpellName(201960)] = 3, -- Ice Bomb
	[SpellName(202062)] = 3, -- Frigid Winds
 	-- Lord Malgath
	[SpellName(204962)] = 3, -- Shadow Bomb
 	-- Return to Karazhan
	[SpellName(227404)] = 3, -- Intangible Presence
 	-- Other
	[SpellName(87023)] = 4, -- Cauterize
	[SpellName(94794)] = 4, -- Rocket Fuel Leak
	[SpellName(116888)] = 4, -- Shroud of Purgatory
	[SpellName(121175)] = 2, -- Orb of Power
}