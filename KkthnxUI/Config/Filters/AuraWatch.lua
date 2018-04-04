local K, C, L = unpack(select(2, ...))
if C["Raidframe"].AuraWatch ~= true or C["Raidframe"].Enable ~= true then return end

local _G = _G
local GetSpellInfo = _G.GetSpellInfo
local unpack = unpack
local print = print

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
		-- print("|cff3c9bedKkthnxUI:|r SpellID is not valid: "..id..". Please check for an updated version, if none exists report to KkthnxUI author.")
		return "Impale"
	else
		return name
	end
end

K.RaidDebuffs = {
	 -- Legion Raids

	 -- Antorus, the Burning Throne
	 -- Garothi Worldbreaker
	[SpellName(244590)] = 3, -- Molten Hot Fel
	[SpellName(244761)] = 3, -- Annihilation
	[SpellName(246920)] = 3, -- Haywire Decimation
	[SpellName(246369)] = 3, -- Searing Barrage
	[SpellName(246848)] = 3, -- Luring Destruction
	[SpellName(246220)] = 3, -- Fel Bombardment
	[SpellName(247159)] = 3, -- Luring Destruction
	[SpellName(244122)] = 3, -- Carnage
	[SpellName(244410)] = 3, -- Decimation
	[SpellName(245294)] = 3, -- Empowered Decimation
	[SpellName(246368)] = 3, -- Searing Barrage

	 -- Felhounds of Sargeras
	[SpellName(245022)] = 3, -- Burning Remnant
	[SpellName(251445)] = 3, -- Smouldering
	[SpellName(251448)] = 3, -- Burning Maw
	[SpellName(244086)] = 5, -- Molten Touch
	[SpellName(244091)] = 3, -- Singed
	[SpellName(244768)] = 3, -- Desolate Gaze
	[SpellName(244767)] = 3, -- Desolate Path
	[SpellName(244471)] = 4, -- Enflame Corruption
	[SpellName(248815)] = 4, -- Enflamed
	[SpellName(244517)] = 3, -- Lingering Flames
	[SpellName(245098)] = 3, -- Decay
	[SpellName(251447)] = 3, -- Corrupting Maw
	[SpellName(244131)] = 3, -- Consuming Sphere
	[SpellName(245024)] = 3, -- Consumed
	[SpellName(244071)] = 3, -- Weight of Darkness
	[SpellName(244578)] = 3, -- Siphon Corruption
	[SpellName(248819)] = 3, -- Siphoned
	[SpellName(254429)] = 3, -- Weight of Darkness
	[SpellName(244072)] = 3, -- Molten Touch

	 -- Antoran High Command
	[SpellName(245121)] = 3, -- Entropic Blast
	[SpellName(244748)] = 3, -- Shocked
	[SpellName(244824)] = 3, -- Warp Field
	[SpellName(244892)] = 3, -- Exploit Weakness
	[SpellName(244172)] = 3, -- Psychic Assault
	[SpellName(244388)] = 3, -- Psychic Scarring
	[SpellName(244420)] = 3, -- Chaos Pulse
	[SpellName(254771)] = 3, -- Disruption Field
	[SpellName(257974)] = 5, -- Chaos Pulse
	[SpellName(244910)] = 3, -- Felshield
	[SpellName(244737)] = 6, -- Shock Grenade

	 -- Portal Keeper Hasabel
	[SpellName(244016)] = 3, -- Reality Tear
	[SpellName(245157)] = 3, -- Everburning Light
	[SpellName(245075)] = 3, -- Hungering Gloom
	[SpellName(245240)] = 3, -- Oppressive Gloom
	[SpellName(244709)] = 3, -- Fiery Detonation
	[SpellName(246208)] = 3, -- Acidic Web
	[SpellName(246075)] = 3, -- Catastrophic Implosion
	[SpellName(244826)] = 3, -- Fel Miasma
	[SpellName(246316)] = 3, -- Poison Essence
	[SpellName(244849)] = 3, -- Caustic Slime
	[SpellName(245118)] = 3, -- Cloying Shadows
	[SpellName(245050)] = 3, -- Delusions
	[SpellName(245040)] = 3, -- Corrupt
	[SpellName(244607)] = 3, -- Flames of Xoroth
	[SpellName(244915)] = 3, -- Leech Essence
	[SpellName(244926)] = 3, -- Felsilk Wrap
	[SpellName(244949)] = 3, -- Felsilk Wrap
	[SpellName(244613)] = 3, -- Everburning Flames

	 -- Eonar the Life-Binder
	[SpellName(248326)] = 3, -- Rain of Fel
	[SpellName(248861)] = 5, -- Spear of Doom
	[SpellName(249016)] = 3, -- Feedback - Targeted
	[SpellName(249015)] = 3, -- Feedback - Burning Embers
	[SpellName(249014)] = 3, -- Feedback - Foul Steps
	[SpellName(249017)] = 3, -- Feedback - Arcane Singularity
	[SpellName(250693)] = 3, -- Arcane Buildup
	[SpellName(250691)] = 3, -- Burning Embers
	[SpellName(248795)] = 3, -- Fel Wake
	[SpellName(248332)] = 4, -- Rain of Fel
	[SpellName(250140)] = 3, -- Foul Steps

	 -- Imonar the Soulhunter
	[SpellName(248424)] = 3, -- Gathering Power
	[SpellName(247552)] = 5, -- Sleep Canister
	[SpellName(247565)] = 5, -- Slumber Gas
	[SpellName(250224)] = 3, -- Shocked
	[SpellName(248252)] = 3, -- Infernal Rockets
	[SpellName(247687)] = 3, -- Sever
	[SpellName(247716)] = 3, -- Charged Blasts
	[SpellName(247367)] = 4, -- Shock Lance
	[SpellName(250255)] = 3, -- Empowered Shock Lance
	[SpellName(247641)] = 4, -- Stasis Trap
	[SpellName(255029)] = 5, -- Sleep Canister
	[SpellName(248321)] = 3, -- Conflagration
	[SpellName(247932)] = 3, -- Shrapnel Blast
	[SpellName(248070)] = 3, -- Empowered Shrapnel Blast
	[SpellName(254183)] = 5, -- Seared Skin

	 -- Kin'garoth
	[SpellName(233062)] = 3, -- Infernal Burning
	[SpellName(230345)] = 3, -- Crashing Comet
	[SpellName(244312)] = 5, -- Forging Strike
	[SpellName(246840)] = 3, -- Ruiner
	[SpellName(248061)] = 3, -- Purging Protocol
	[SpellName(249686)] = 3, -- Reverberating Decimation
	[SpellName(246706)] = 6, -- Demolish
	[SpellName(246698)] = 6, -- Demolish
	[SpellName(245919)] = 3, -- Meteor Swarm
	[SpellName(245770)] = 3, -- Decimation

	 -- Varimathras
	[SpellName(244042)] = 5, -- Marked Prey
	[SpellName(243961)] = 5, -- Misery
	[SpellName(248732)] = 3, -- Echoes of Doom
	[SpellName(243973)] = 3, -- Torment of Shadows
	[SpellName(244005)] = 3, -- Dark Fissure
	[SpellName(244093)] = 6, -- Necrotic Embrace
	[SpellName(244094)] = 6, -- Necrotic Embrace

	 -- The Coven of Shivarra
	[SpellName(244899)] = 4, -- Fiery Strike
	[SpellName(245518)] = 4, -- Flashfreeze
	[SpellName(245586)] = 5, -- Chilled Blood
	[SpellName(246763)] = 3, -- Fury of Golganneth
	[SpellName(245674)] = 3, -- Flames of Khaz'goroth
	[SpellName(245671)] = 3, -- Flames of Khaz'goroth
	[SpellName(245910)] = 3, -- Spectral Army of Norgannon
	[SpellName(253520)] = 3, -- Fulminating Pulse
	[SpellName(245634)] = 3, -- Whirling Saber
	[SpellName(253020)] = 3, -- Storm of Darkness
	[SpellName(245921)] = 3, -- Spectral Army of Norgannon
	[SpellName(250757)] = 3, -- Cosmic Glare

	 -- Aggramar
	[SpellName(244291)] = 3, -- Foe Breaker
	[SpellName(255060)] = 3, -- Empowered Foe Breaker
	[SpellName(245995)] = 4, -- Scorching Blaze
	[SpellName(246014)] = 3, -- Searing Tempest
	[SpellName(244912)] = 3, -- Blazing Eruption
	[SpellName(247135)] = 3, -- Scorched Earth
	[SpellName(247091)] = 3, -- Catalyzed
	[SpellName(245631)] = 3, -- Unchecked Flame
	[SpellName(245916)] = 3, -- Molten Remnants
	[SpellName(245990)] = 4, -- Taeshalach's Reach
	[SpellName(254452)] = 3, -- Ravenous Blaze
	[SpellName(244736)] = 3, -- Wake of Flame
	[SpellName(247079)] = 3, -- Empowered Flame Rend

	 -- Argus the Unmaker
	[SpellName(251815)] = 3, -- Edge of Obliteration
	[SpellName(248499)] = 4, -- Sweeping Scythe
	[SpellName(250669)] = 5, -- Soulburst
	[SpellName(251570)] = 6, -- Soulbomb
	[SpellName(248396)] = 6, -- Soulblight
	[SpellName(258039)] = 3, -- Deadly Scythe
	[SpellName(252729)] = 3, -- Cosmic Ray
	[SpellName(256899)] = 4, -- Soul Detonation
	[SpellName(252634)] = 4, -- Cosmic Smash
	[SpellName(252616)] = 4, -- Cosmic Beacon
	[SpellName(255200)] = 3, -- Aggramar's Boon
	[SpellName(255199)] = 4, -- Avatar of Aggramar
	[SpellName(258647)] = 3, -- Gift of the Sea
	[SpellName(253901)] = 3, -- Strength of the Sea
	[SpellName(257299)] = 4, -- Ember of Rage
	[SpellName(248167)] = 3, -- Death Fog
	[SpellName(258646)] = 3, -- Gift of the Sky
	[SpellName(253903)] = 3, -- Strength of the Sky

	-- Tomb of Sargeras
	 -- Goroth
	[SpellName(231363)] = 3, -- Burning Armor
	[SpellName(233279)] = 3, -- Shattering Star
	[SpellName(230345)] = 3, -- Crashing Comet
	[SpellName(234346)] = 4, -- Fel Eruption
	 -- Demonic Inquisition
	[SpellName(233983)] = 3, -- Echoing Anguish
	[SpellName(233895)] = 3, -- Suffocating Dark
	[SpellName(233430)] = 3, -- Unbearable Torment
	 -- Harjatan
	[SpellName(231998)] = 3, -- Jagged Abrasion
	[SpellName(231770)] = 4, -- Drenched
	[SpellName(231729)] = 3, -- Aqueous Burst
	[SpellName(231768)] = 3, -- Drenching Waters
	 -- Sisters of the Moon
	[SpellName(236516)] = 3, -- Twilight Volley
	[SpellName(236519)] = 3, -- Moon Burn
	[SpellName(239264)] = 3, -- Lunar Fire
	[SpellName(236712)] = 3, -- Lunar Beacon
	[SpellName(236550)] = 3, -- Discorporate
	[SpellName(237561)] = 4, -- Twilight Glaive
	[SpellName(233263)] = 4, -- Embrace of the Eclipse
	[SpellName(236596)] = 5, -- Rapid Shot
	 -- Mistress Sassz'ine
	[SpellName(230201)] = 3, -- Burden of Pain
	[SpellName(230139)] = 3, -- Hydra Shot
	[SpellName(230358)] = 3, -- Thundering Shock
	[SpellName(232913)] = 3, -- Befouling Ink
	[SpellName(230920)] = 3, -- Consuming Hunger
	[SpellName(232732)] = 3, -- Slicing Tornado
	 -- The Desolate Host
	[SpellName(235907)] = 3, -- Collapsing Fissure
	[SpellName(235989)] = 3, -- Tormented Cries
	[SpellName(235933)] = 3, -- Spear of Anguish
	[SpellName(235968)] = 3, -- Grasping Darkness
	[SpellName(236340)] = 3, -- Crush Mind
	[SpellName(236449)] = 3, -- Soulbind
	[SpellName(236515)] = 3, -- Shattering Scream
	[SpellName(236241)] = 3, -- Soul Rot
	 -- Maiden of Vigilance
	 -- [SpellName(235213)] = 4, -- Light Infusion
	 -- [SpellName(235240)] = 4, -- Fel Infusion
	[SpellName(240209)] = 3, -- Unstable Soul
	 -- Fallen Avatar
	[SpellName(236494)] = 3, -- Desolate
	[SpellName(236604)] = 3, -- Shadowy Blades
	[SpellName(234059)] = 3, -- Unbound Chaos
	[SpellName(239058)] = 3, -- Touch of Sargeras
	[SpellName(239739)] = 3, -- Dark Mark
	[SpellName(242017)] = 3, -- Black Winds
	[SpellName(240728)] = 3, -- Tainted Essence
	 -- Kil'Jaeden
	[SpellName(236710)] = 3, -- Shadow Reflection: Erupting
	[SpellName(236378)] = 3, -- Shadow Reflection: Wailing
	[SpellName(238429)] = 3, -- Bursting Dreadflame
	[SpellName(238505)] = 3, -- Focused Dreadflame
	[SpellName(239155)] = 3, -- Gravity Squeeze
	[SpellName(239253)] = 3, -- Flaming Orb
	[SpellName(239130)] = 3, -- Tear Rift
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