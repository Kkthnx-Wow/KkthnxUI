local K, C, L = unpack(select(2, ...))
if C.Raidframe.AuraWatch ~= true or C.Raidframe.Enable ~= true then return end

local _G = _G
local GetSpellInfo = _G.GetSpellInfo

K.RaidBuffs = {
	PRIEST = {
		{41635, "BOTTOMRIGHT", {0.2, 0.7, 0.2}}, -- Prayer of Mending
		{139, "BOTTOMLEFT", {0.4, 0.7, 0.2}}, -- Renew
		{17, "TOPLEFT", {0.81, 0.85, 0.1}, true}, -- Power Word: Shield
	},
	DRUID = {
		{774, "TOPLEFT", {0.8, 0.4, 0.8}}, -- Rejuvenation
		{155777, "LEFT", {0.8, 0.4, 0.8}}, -- Germination
		{8936, "TOPRIGHT", {0.2, 0.8, 0.2}}, -- Regrowth
		{33763, "BOTTOMLEFT", {0.4, 0.8, 0.2}}, -- Lifebloom
		{48438, "BOTTOMRIGHT", {0.8, 0.4, 0}}, -- Wild Growth
	},
	PALADIN = {
		{53563, "TOPLEFT", {0.7, 0.3, 0.7}},	 -- Beacon of Light
		{156910, "TOPRIGHT", {0.7, 0.3, 0.7}},	 -- Beacon of Faith
		{1022, "BOTTOMRIGHT", {0.2, 0.2, 1}, true}, 	 -- Hand of Protection
		{1044, "BOTTOMRIGHT", {0.89, 0.45, 0}, true},	 -- Hand of Freedom
		{6940, "BOTTOMRIGHT", {0.89, 0.1, 0.1}, true},	 -- Hand of Sacrifice
		{114163, "BOTTOMLEFT", {0.81, 0.85, 0.1}, true},	 -- Eternal Flame
	},
	SHAMAN = {
		{61295, "TOPLEFT", {0.7, 0.3, 0.7}}, -- Riptide
	},
	MONK = {
		{119611, "TOPLEFT", {0.8, 0.4, 0.8}},	 -- Renewing Mist
		{116849, "TOPRIGHT", {0.2, 0.8, 0.2}},	 -- Life Cocoon
		{124682, "BOTTOMLEFT", {0.4, 0.8, 0.2}}, -- Enveloping Mist
		{124081, "BOTTOMRIGHT", {0.7, 0.4, 0}}, -- Zen Sphere
	},
	ALL = {
		{14253, "RIGHT", {0, 1, 0}}, -- Abolish Poison
	},
	HUNTER = {},
	DEMONHUNTER = {},
	WARLOCK = {},
	MAGE = {},
	DEATHKNIGHT = {},
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
	-- Il'gynoth, Heart of the Corruption
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
	-- High Botanist Tel'arn
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
	-- Gul'dan
	[SpellName(180079)] = 6, -- Felfire Munitions
	[SpellName(206221)] = 6, -- Empowered Bonds of Fel
	[SpellName(206840)] = 6, -- Gaze of Vethriz
	[SpellName(206875)] = 6, -- Fel Obelisk (Tank)
	[SpellName(206896)] = 6, -- Torn Soul
	[SpellName(208802)] = 6, -- Soul Corrosion
	[SpellName(210339)] = 6, -- Time Dilation
	[SpellName(212686)] = 6, -- Flames of Sargeras
}