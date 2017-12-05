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
		{1022, "BOTTOMRIGHT", {0.2, 0.2, 1}, true},    -- Hand of Protection
		{1044, "BOTTOMRIGHT", {0.89, 0.45, 0}, true},  -- Hand of Freedom
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
		{119611, "TOPLEFT", {0.8, 0.4, 0.8}},    --Renewing Mist
		{124081, "BOTTOMRIGHT", {0.7, 0.4, 0}},  -- Zen Sphere
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
	-- Legion Debuffs
	-- The Emerald Nightmare
	-- Nythendra
	[SpellName(203045)] = 6, -- Infested Ground
	[SpellName(203096)] = 6, -- Rot
	[SpellName(203646)] = 6, -- Burst of Corruption
	[SpellName(204463)] = 6, -- Volatile Rot
	[SpellName(204504)] = 6, -- Infested
	[SpellName(205043)] = 6, -- Infested mind
	-- Elerethe Renferal
	[SpellName(210228)] = 6, -- Dripping Fangs
	[SpellName(210850)] = 6, -- Twisting Shadows
	[SpellName(213124)] = 6, -- Venomous Pool
	[SpellName(215300)] = 6, -- Web of Pain
	[SpellName(215307)] = 6, -- Web of Pain
	[SpellName(215460)] = 6, -- Necrotic Venom
	[SpellName(215489)] = 6, -- Venomous Pool
	[SpellName(218519)] = 6, -- Wind Burn (Mythic)
	-- Il"gynoth, Heart of the Corruption
	[SpellName(208697)] = 6, -- Mind Flay
	[SpellName(208929)] = 6, -- Spew Corruption
	[SpellName(209469)] = 7, -- Touch of Corruption
	[SpellName(210984)] = 6, -- Eye of Fate
	[SpellName(215143)] = 6, -- Cursed Blood
	-- Ursoc
	[SpellName(197943)] = 6, -- Overwhelm
	[SpellName(197980)] = 6, -- Nightmarish Cacophony
	[SpellName(198006)] = 6, -- Focused Gaze
	[SpellName(198108)] = 6, -- Unbalanced
	[SpellName(204859)] = 6, -- Rend Flesh
	[SpellName(205611)] = 6, -- Miasma
	-- Dragons of Nightmare
	[SpellName(203102)] = 6, -- Mark of Ysondre
	[SpellName(203110)] = 7, -- Slumbering Nightmare
	[SpellName(203121)] = 6, -- Mark of Taerar
	[SpellName(203124)] = 6, -- Mark of Lethon
	[SpellName(203125)] = 6, -- Mark of Emeriss
	[SpellName(203770)] = 7, -- Defiled Vines
	[SpellName(203787)] = 7, -- Volatile Infection
	[SpellName(204731)] = 7, -- Wasting Dread
	[SpellName(205341)] = 7, -- Sleeping Fog
	[SpellName(207681)] = 7, -- Nightmare Bloom
	-- Cenarius
	[SpellName(210279)] = 6, -- Creeping Nightmares
	[SpellName(210315)] = 6, -- Nightmare Brambles
	[SpellName(211471)] = 6, -- Scorned Touch
	[SpellName(211507)] = 6, -- Nightmare Javelin
	[SpellName(211612)] = 6, -- Replenishing Roots
	[SpellName(212681)] = 6, -- Cleansed Ground
	[SpellName(213162)] = 6, -- Nightmare Blast
	[SpellName(216516)] = 6, -- Ancient Dream
	-- Xavius
	[SpellName(206005)] = 6, -- Dream Simulacrum
	[SpellName(206109)] = 6, -- Awakening to the Nightmare
	[SpellName(206651)] = 6, -- Darkening Soul
	[SpellName(207409)] = 6, -- Madness
	[SpellName(208385)] = 6, -- Tainted Discharge
	[SpellName(208431)] = 6, -- Corruption: Descent into Madness
	[SpellName(209034)] = 6, -- Bonds of Terror
	[SpellName(209158)] = 6, -- Blackening Soul
	[SpellName(210451)] = 6, -- Bonds of Terror
	[SpellName(211634)] = 6, -- The Infinite Dark
	[SpellName(211802)] = 6, -- Nightmare Blades
	-- Trial of Valor (By Anzor)
	-- Odyn
	[SpellName(227475)] = 6, -- Cleansing Flame
	[SpellName(227490)] = 6, -- Branded
	[SpellName(227491)] = 6, -- Branded
	[SpellName(227498)] = 6, -- Branded
	[SpellName(227499)] = 6, -- Branded
	[SpellName(227500)] = 6, -- Branded
	[SpellName(227781)] = 6, -- Glowing Fragment
	[SpellName(227807)] = 6, -- Storm of Justice
	[SpellName(227959)] = 6, -- Storm of Justice
	[SpellName(228030)] = 6, -- Expel Light
	[SpellName(228030)] = 6, -- Expel Light
	[SpellName(228918)] = 6, -- Stormforged Spear
	[SpellName(231297)] = 6, -- Runic Brand (Mythic Only)
	-- Guarm
	[SpellName(227539)] = 6, -- Fiery Phlegm
	[SpellName(227566)] = 6, -- Salty Spittle
	[SpellName(227570)] = 6, -- Dark Discharge
	[SpellName(228228)] = 5, -- Flame Lick
	[SpellName(228248)] = 7, -- Frost Lick
	[SpellName(228253)] = 6, -- Shadow Lick
	-- Helya
	[SpellName(193367)] = 6, -- Fetid Rot
	[SpellName(202476)] = 6, -- Rabid
	[SpellName(227982)] = 6, -- Bilewater Redox
	[SpellName(228054)] = 6, -- Taint of the Sea
	[SpellName(228058)] = 6, -- Orb of Corrosion
	[SpellName(228519)] = 6, -- Anchor Slam
	[SpellName(228883)] = 7, -- Unholy Reckoning (Trash)
	[SpellName(229119)] = 6, -- Orb of Corruption
	[SpellName(232450)] = 6, -- Corrupted Axion
	-- The Nighthold
	--Trash
	[SpellName(224234)] = 6, -- Ill Fated
	[SpellName(224568)] = 6, -- Mass Supress
	[SpellName(225412)] = 6, -- Mass Siphon
	-- Skorpyron
	[SpellName(204275)] = 6, -- Arcanoslash (Tank)
	[SpellName(204284)] = 6, -- Broken Shard (Protection)
	[SpellName(204483)] = 6, -- Focused Blast (Stun)
	[SpellName(204766)] = 6, -- Energy Surge
	[SpellName(211659)] = 6, -- Arcane Tether (Tank debuff)
	[SpellName(211801)] = 6, -- Volatile Fragments
	[SpellName(214718)] = 6, -- Acidic Fragments
	-- Chronomatic Anomaly
	[SpellName(205653)] = 6, -- Passage of Time
	[SpellName(206607)] = 6, -- Chronometric Particles (Tank stack debuff)
	[SpellName(206609)] = 6, -- Time Release (Heal buff/debuff)
	[SpellName(219966)] = 6, -- Time Release (Heal Absorb Red)
	[SpellName(219965)] = 6, -- Time Release (Heal Absorb Yellow)
	[SpellName(219964)] = 6, -- Time Release (Heal Absorb Green)
	[SpellName(206617)] = 6, -- Time Bomb
	[SpellName(206618)] = 6, -- Time Bomb
	[SpellName(207871)] = 6, -- Vortex (Mythic)
	[SpellName(212099)] = 6, -- Temporal Charge
	-- Trilliax
	[SpellName(206488)] = 6, -- Arcane Seepage
	[SpellName(206641)] = 6, -- Arcane Spear (Tank)
	[SpellName(206798)] = 6, -- Toxic Slice
	[SpellName(206838)] = 6, -- Succulent Feast
	[SpellName(208910)] = 6, -- Arcing Bonds
	[SpellName(214573)] = 6, -- Stuffed
	[SpellName(214583)] = 6, -- Sterilize
	[SpellName(214672)] = 6, -- Annihilation
	-- Spellblade Aluriel
	[SpellName(212492)] = 6, -- Annihilate (Tank)
	[SpellName(212494)] = 6, -- Annihilated (Main Tank debuff)
	[SpellName(212530)] = 6, -- Replicate: Mark of Frost
	[SpellName(212531)] = 6, -- Mark of Frost (marked)
	[SpellName(212587)] = 6, -- Mark of Frost
	[SpellName(212647)] = 6, -- Frostbitten
	[SpellName(212736)] = 6, -- Pool of Frost
	[SpellName(213085)] = 6, -- Frozen Tempest
	[SpellName(213148)] = 6, -- Searing Brand Chosen
	[SpellName(213166)] = 6, -- Searing Brand
	[SpellName(213181)] = 6, -- Searing Brand Stunned
	[SpellName(213278)] = 6, -- Burning Ground
	[SpellName(213504)] = 6, -- Arcane Fog
	[SpellName(213621)] = 6, -- Entombed in Ice
	-- Tichondrius
	[SpellName(206311)] = 6, -- Illusionary Night
	[SpellName(206466)] = 6, -- Essence of Night
	[SpellName(206480)] = 6, -- Carrion Plague
	[SpellName(208230)] = 6, -- Feast of Blood
	[SpellName(212794)] = 6, -- Brand of Argus
	[SpellName(215988)] = 6, -- Carrion Nightmare
	[SpellName(216024)] = 6, -- Volatile Wound
	[SpellName(216027)] = 6, -- Nether Zone
	[SpellName(216039)] = 6, -- Fel Storm
	[SpellName(216040)] = 6, -- Burning Soul
	[SpellName(216685)] = 6, -- Flames of Argus
	[SpellName(216726)] = 6, -- Ring of Shadows
	-- Krosus
	[SpellName(205344)] = 6, -- Orb of Destruction
	[SpellName(206677)] = 6, -- Searing Brand
	-- High Botanist Tel"arn
	[SpellName(218304)] = 6, -- Parasitic Fetter
	[SpellName(218342)] = 6, -- Parasitic Fixate
	[SpellName(218503)] = 6, -- Recursive Strikes (Tank)
	[SpellName(218780)] = 6, -- Plasma Explosion
	[SpellName(218809)] = 6, -- Call of Night
	[SpellName(219235)] = 6, -- Toxic Spores
	-- Star Augur Etraeus
	[SpellName(205649)] = 6, -- Fel Ejection
	[SpellName(205984)] = 6, -- Gravitaional Pull
	[SpellName(206388)] = 6, -- Felburst
	[SpellName(206398)] = 6, -- Felflame
	[SpellName(206464)] = 6, -- Coronal Ejection
	[SpellName(206585)] = 6, -- Absolute Zero
	[SpellName(206589)] = 6, -- Chilled
	[SpellName(206603)] = 6, -- Frozen Solid
	[SpellName(206936)] = 6, -- Icy Ejection
	[SpellName(206965)] = 6, -- Voidburst
	[SpellName(207143)] = 6, -- Void Ejection
	[SpellName(207720)] = 6, -- Witness the Void
	[SpellName(214167)] = 6, -- Gravitaional Pull
	[SpellName(214335)] = 6, -- Gravitaional Pull
	[SpellName(216697)] = 6, -- Frigid Pulse
	-- Grand Magistrix Elisande
	[SpellName(208659)] = 6, -- Arcanetic Ring
	[SpellName(209165)] = 6, -- Slow Time
	[SpellName(209166)] = 6, -- Fast Time
	[SpellName(209244)] = 6, -- Delphuric Beam
	[SpellName(209433)] = 6, -- Spanning Singularity
	[SpellName(209549)] = 6, -- Lingering Burn
	[SpellName(209598)] = 6, -- Conflexive Burst
	[SpellName(209615)] = 6, -- Ablation
	[SpellName(209973)] = 6, -- Ablating Explosion
	[SpellName(211261)] = 6, -- Permaliative Torment
	[SpellName(211887)] = 6, -- Ablated
	-- Gul"dan
	[SpellName(180079)] = 6, -- Felfire Munitions
	[SpellName(206221)] = 6, -- Empowered Bonds of Fel
	[SpellName(206840)] = 6, -- Gaze of Vethriz
	[SpellName(206875)] = 6, -- Fel Obelisk (Tank)
	[SpellName(206896)] = 6, -- Torn Soul
	[SpellName(208802)] = 6, -- Soul Corrosion
	[SpellName(210339)] = 6, -- Time Dilation
	[SpellName(212686)] = 6, -- Flames of Sargeras
	-- Tomb of Sargeras
	-- Goroth
	[SpellName(233279)] = 6, -- Shattering Star
	[SpellName(230345)] = 6, -- Crashing Comet (Dot)
	[SpellName(232249)] = 6, -- Crashing Comet
	[SpellName(231363)] = 6, -- Burning Armor
	[SpellName(234264)] = 6, -- Melted Armor
	[SpellName(233062)] = 6, -- Infernal Burning
	[SpellName(230348)] = 6, -- Fel Pool
	-- Demonic Inquisition
	[SpellName(233430)] = 6, -- Ubearable Torment
	[SpellName(233983)] = 6, -- Echoing Anguish
	[SpellName(248713)] = 6, -- Soul Corruption
	-- Harjatan
	[SpellName(231770)] = 6, -- Drenched
	[SpellName(231998)] = 6, -- Jagged Abrasion
	[SpellName(231729)] = 6, -- Aqueous Burst
	[SpellName(234128)] = 6, -- Driven Assault
	[SpellName(234016)] = 6, -- Driven Assault
	-- Sisters of the Moon
	[SpellName(236603)] = 6, -- Rapid Shot
	[SpellName(236596)] = 6, -- Rapid Shot
	[SpellName(234995)] = 6, -- Lunar Suffusion
	[SpellName(234996)] = 6, -- Umbra Suffusion
	[SpellName(236519)] = 6, -- Moon Burn
	[SpellName(236697)] = 6, -- Deathly Screech
	[SpellName(239264)] = 6, -- Lunar Flare (Tank)
	[SpellName(236712)] = 6, -- Lunar Beacon
	[SpellName(236304)] = 6, -- Incorporeal Shot
	[SpellName(236305)] = 6, -- Incorporeal Shot -- (Heroic)
	[SpellName(236306)] = 6, -- Incorporeal Shot
	[SpellName(237570)] = 6, -- Incorporeal Shot
	[SpellName(248911)] = 6, -- Incorporeal Shot
	[SpellName(236550)] = 6, -- Discorporate (Tank)
	[SpellName(236330)] = 6, -- Astral Vulnerability
	[SpellName(236529)] = 6, -- Twilight Glaive
	[SpellName(236541)] = 6, -- Twilight Glaive
	[SpellName(237561)] = 6, -- Twilight Glaive -- (Heroic)
	[SpellName(237633)] = 6, -- Spectral Glaive
	[SpellName(233263)] = 6, -- Embrace of the Eclipse
	-- Mistress Sassz'ine
	[SpellName(230959)] = 6, -- Concealing Murk
	[SpellName(232732)] = 6, -- Slicing Tornado
	[SpellName(232913)] = 6, -- Befouling Ink
	[SpellName(234621)] = 6, -- Devouring Maw
	[SpellName(230201)] = 6, -- Burden of Pain (Tank)
	[SpellName(230139)] = 6, -- Hydra Shot
	[SpellName(232754)] = 6, -- Hydra Acid
	[SpellName(230920)] = 6, -- Consuming Hunger
	[SpellName(230358)] = 6, -- Thundering Shock
	[SpellName(230362)] = 6, -- Thundering Shock
	-- The Desolate Host
	[SpellName(236072)] = 6, -- Wailing Souls
	[SpellName(236449)] = 6, -- Soulbind
	[SpellName(236515)] = 6, -- Shattering Scream
	[SpellName(235989)] = 6, -- Tormented Cries
	[SpellName(236241)] = 6, -- Soul Rot
	[SpellName(236361)] = 6, -- Spirit Chains
	[SpellName(235968)] = 6, -- Grasping Darkness
	-- Maiden of Vigilance
	[SpellName(235117)] = 6, -- Unstable Soul
	[SpellName(240209)] = 6, -- Unstable Soul
	[SpellName(243276)] = 6, -- Unstable Soul
	[SpellName(249912)] = 6, -- Unstable Soul
	[SpellName(235534)] = 6, -- Creator's Grace
	[SpellName(235538)] = 6, -- Demon's Vigor
	[SpellName(234891)] = 6, -- Wrath of the Creators
	[SpellName(235569)] = 6, -- Hammer of Creation
	[SpellName(235573)] = 6, -- Hammer of Obliteration
	[SpellName(235213)] = 6, -- Light Infusion
	[SpellName(235240)] = 6, -- Fel Infusion
	-- Fallen Avatar
	[SpellName(239058)] = 6, -- Touch of Sargeras
	[SpellName(239739)] = 6, -- Dark Mark
	[SpellName(234059)] = 6, -- Unbound Chaos
	[SpellName(240213)] = 6, -- Chaos Flames
	[SpellName(236604)] = 6, -- Shadowy Blades
	[SpellName(236494)] = 6, -- Desolate (Tank)
	[SpellName(240728)] = 6, -- Tainted Essence
	-- Kil'jaeden
	[SpellName(238999)] = 6, -- Darkness of a Thousand Souls
	[SpellName(239216)] = 6, -- Darkness of a Thousand Souls (Dot)
	[SpellName(239155)] = 6, -- Gravity Squeeze
	[SpellName(234295)] = 6, -- Armageddon Rain
	[SpellName(240908)] = 6, -- Armageddon Blast
	[SpellName(239932)] = 6, -- Felclaws (Tank)
	[SpellName(240911)] = 6, -- Armageddon Hail
	[SpellName(238505)] = 6, -- Focused Dreadflame
	[SpellName(238429)] = 6, -- Bursting Dreadflame
	[SpellName(236710)] = 6, -- Shadow Reflection: Erupting
	[SpellName(241822)] = 6, -- Choking Shadow
	[SpellName(236555)] = 6, -- Deceiver's Veil
	[SpellName(234310)] = 6, -- Armageddon Rain
	-- Antorus, the Burning Throne
	-- Garothi Worldbreaker
	[SpellName(244761)] = 6, -- Annihilation
	[SpellName(246369)] = 6, -- Searing Barrage
	[SpellName(246848)] = 6, -- Luring Destruction
	[SpellName(246220)] = 6, -- Fel Bombardment
	[SpellName(247159)] = 6, -- Luring Destruction
	[SpellName(244122)] = 6, -- Carnage
	-- Felhounds of Sargeras
	[SpellName(245022)] = 6, -- Burning Remnant
	[SpellName(251445)] = 6, -- Smouldering
	[SpellName(251448)] = 6, -- Burning Maw
	[SpellName(244086)] = 6, -- Molten Touch
	[SpellName(244091)] = 6, -- Singed
	[SpellName(244768)] = 6, -- Desolate Gaze
	[SpellName(244767)] = 6, -- Desolate Path
	[SpellName(244471)] = 6, -- Enflame Corruption
	[SpellName(248815)] = 6, -- Enflamed
	[SpellName(244517)] = 6, -- Lingering Flames
	[SpellName(245098)] = 6, -- Decay
	[SpellName(251447)] = 6, -- Corrupting Maw
	[SpellName(244131)] = 6, -- Consuming Sphere
	[SpellName(245024)] = 6, -- Consumed
	[SpellName(244071)] = 6, -- Weight of Darkness
	[SpellName(244578)] = 6, -- Siphon Corruption
	[SpellName(248819)] = 6, -- Siphoned
	-- Antoran High Command
	[SpellName(245121)] = 6, -- Entropic Blast
	[SpellName(244748)] = 6, -- Shocked
	[SpellName(244824)] = 6, -- Warp Field
	[SpellName(244892)] = 6, -- Exploit Weakness
	[SpellName(244172)] = 6, -- Psychic Assault
	[SpellName(244388)] = 6, -- Psychic Scarring
	[SpellName(244420)] = 6, -- Chaos Pulse
	-- Portal Keeper Hasabel
	[SpellName(244016)] = 6, -- Reality Tear
	[SpellName(245157)] = 6, -- Everburning Light
	[SpellName(245075)] = 6, -- Hungering Gloom
	[SpellName(245240)] = 6, -- Oppressive Gloom
	[SpellName(244709)] = 6, -- Fiery Detonation
	[SpellName(246208)] = 6, -- Acidic Web
	[SpellName(246075)] = 6, -- Catastrophic Implosion
	[SpellName(244826)] = 6, -- Fel Miasma
	[SpellName(246316)] = 6, -- Poison Essence
	[SpellName(244849)] = 6, -- Caustic Slime
	[SpellName(245118)] = 6, -- Cloying Shadows
	[SpellName(245050)] = 6, -- Delusions
	[SpellName(245040)] = 6, -- Corrupt
	[SpellName(244926)] = 6, -- Felsilk Wrap
	[SpellName(244607)] = 6, -- Flames of Xoroth
	-- Eonar the Life-Binder
	[SpellName(248326)] = 6, -- Rain of Fel
	[SpellName(248861)] = 6, -- Spear of Doom
	[SpellName(249016)] = 6, -- Feedback - Targeted
	[SpellName(249015)] = 6, -- Feedback - Burning Embers
	[SpellName(249014)] = 6, -- Feedback - Foul Steps
	[SpellName(249017)] = 6, -- Feedback - Arcane Singularity
	-- Imonar the Soulhunter
	[SpellName(248424)] = 6, -- Gathering Power
	[SpellName(247552)] = 6, -- Sleep Canister
	[SpellName(247565)] = 6, -- Slumber Gas
	[SpellName(250224)] = 6, -- Shocked
	[SpellName(248252)] = 6, -- Infernal Rockets
	[SpellName(247687)] = 6, -- Sever
	[SpellName(247716)] = 6, -- Charged Blasts
	[SpellName(250255)] = 6, -- Empowered Shock Lance
	[SpellName(247641)] = 6, -- Stasis Trap
	-- Kin'garoth
	[SpellName(233062)] = 6, -- Infernal Burning
	[SpellName(230345)] = 6, -- Crashing Comet
	[SpellName(244312)] = 6, -- Forging Strike
	[SpellName(246840)] = 6, -- Ruiner
	[SpellName(248061)] = 6, -- Purging Protocol
	[SpellName(246706)] = 6, -- Demolish
	-- Varimathras
	[SpellName(244042)] = 6, -- Marked Prey
	[SpellName(243961)] = 6, -- Misery
	[SpellName(248732)] = 6, -- Echoes of Doom
	[SpellName(244093)] = 6, -- Necrotic Embrace
	-- The Coven of Shivarra
	[SpellName(244899)] = 6, -- Fiery Strike
	[SpellName(245518)] = 6, -- Flashfreeze
	[SpellName(245586)] = 6, -- Chilled Blood
	[SpellName(246763)] = 6, -- Fury of Golganneth
	[SpellName(245674)] = 6, -- Flames of Khaz'goroth
	[SpellName(245910)] = 6, -- Spectral Army of Norgannon
	[SpellName(253520)] = 6, -- Fulminating Pulse
	-- Aggramar
	[SpellName(244291)] = 6, -- Foe Breaker
	[SpellName(245995)] = 6, -- Scorching Blaze
	[SpellName(246014)] = 6, -- Searing Tempest
	[SpellName(244912)] = 6, -- Blazing Eruption
	[SpellName(247135)] = 6, -- Scorched Earth
	[SpellName(247091)] = 6, -- Catalyzed
	[SpellName(245631)] = 6, -- Unchecked Flame
	[SpellName(245916)] = 6, -- Molten Remnants
	-- Argus the Unmaker
	[SpellName(251815)] = 6, -- Edge of Obliteration
	[SpellName(248499)] = 6, -- Sweeping Scythe
	[SpellName(250669)] = 6, -- Soulburst
	[SpellName(251570)] = 6, -- Soulbomb
	[SpellName(248396)] = 6, -- Soulblight
	[SpellName(258039)] = 6, -- Deadly Scythe
	[SpellName(252729)] = 6, -- Cosmic Ray
	[SpellName(256899)] = 6, -- Soul Detonation
	[SpellName(252634)] = 6, -- Cosmic Smash
	[SpellName(252616)] = 6, -- Cosmic Beacon
}