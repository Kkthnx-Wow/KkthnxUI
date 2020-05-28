local K = unpack(select(2, ...))

local _G = _G

local C_EncounterJournal_GetSectionInfo = _G.C_EncounterJournal.GetSectionInfo

-- Spell Whitelist
K.NameplateWhiteList = {
	-- Buffs
	[642] = true, -- Divine Shield
	[1022] = true, -- Blessing of Protection
	[23920] = true, -- Spell Reflection
	[45438] = true, -- Ice Block
	[186265] = true, -- Aspect of the Turtle

	-- Debuffs
	[2094] = true, -- Blind
	[117405] = true, -- Binding Shot
	[127797] = true, -- Ursol's Vortex
	[20549] = true, -- War Stomp
	[107079] = true, -- Quaking Palm
	[272295] = true, -- Bounty Hunted

	-- Dungeons
	[283640] = true, -- Rattled
	[293724] = true, -- Shield Generator
	[298602] = true, -- Smoke Cloud

	[258317] = true, -- Riot Shield
	[257899] = true, -- Painful Motivation, Freedom Town
	[268008] = true, -- Viper temptation, temple
	[260792] = true, -- Dust cloud, temple
	[260416] = true, -- Metamorphosis
	[267981] = true, -- Aura of Protection, Temple of Storms
	[274631] = true, -- Lesser Iron Wall Blessing, Temple of Storms
	[267901] = true, -- Iron Wall Blessing, Temple of Storms
	[276767] = true, -- Devouring the Nether, Temple of Storms
	[268212] = true, -- Small Enchanted Enchantment, Temple of the Storm
	[268186] = true, -- Enchanted Enchantment, Temple of the Storm
	[263246] = true, -- Shield of Lightning, Temple of Storms
	[263276] = true, -- Cover, mine
	[257597] = true, -- Azerite infusion, mining area
	[269302] = true, -- Venomblade, Mine
	[260805] = true, -- Rainbow of Focus, Manor
	[264027] = true, -- Enchanted Candle, Manor
	[258653] = true, -- Psionic Barrier, Atadasa
	[255960] = true, -- Greater Voodoo, Atadasa
	[255967] = true,
	[255968] = true,
	[255970] = true,
	[255972] = true,
	[228318] = true, -- Provoked
	[226510] = true, -- Blood pool
	[277242] = true, -- Symbiosis
	[290026] = true, -- Queen's Decree: Backlash
	[290027] = true,
	[302418] = true, -- Queen's Decree: Unstoppable
	[302419] = true, -- Nether Horizon
	[302421] = true, -- Queen's Decree: Hidden

	-- Raids
	[296389] = true, -- Upsurge, Azshara's Glow
	[296650] = true, -- Hardened Carapace, Lord Ashvan
	[296914] = true, -- Growing Chaos, Ogozoia
	[282209] = true, -- Predator Mark
	[296704] = true, -- Checks and balances, Queen's court
	[295099] = true, -- Penetrating the Dark, Zakul
	[300428] = true, -- Enrage, Azshara
	[297912] = true, -- Tormented
	[300551] = true, -- Enchantment

	[287693] = true, -- Recessive connection, Unat
	[282741] = true, -- Shadow Shell
	[285333] = true, -- Unnatural regeneration
	[285642] = true, -- Gift of Enzos: Chaos

	[283619] = true, -- Tide of Light, Warrior of Light
	[284468] = true, -- Aura of Retribution
	[283933] = true, -- Justice trial
	[284593] = true, -- Penance
	[283583] = true, -- Dedication
	[288294] = true, -- Holy Blessing
	[288298] = true, -- Self-discipline
	[287469] = true, -- Ridicule and prayer
	[287439] = true, -- Divine Hammer
	[286436] = true, -- Emerald Storm, Jadefire Master
	[286425] = true, -- Flame shield
	[287652] = true, -- Overload
	[282098] = true, -- Gift of the Wind, Chosen Order
	[287650] = true, -- Boiling Fury
	[282736] = true, -- Divine Wrath
	[285945] = true, -- Rapid wind
	[286007] = true, -- Dragon Swarm Hunter
	[289162] = true, -- Relentless Immortal, King Raskaja
	[288117] = true, -- Imbued Spirit
	[287297] = true, -- Winding up, master craftsman
	[286558] = true, -- Tide Mask, Storm Wall
	[287995] = true, -- Current shield
	[284997] = true, -- Covered Fist
	[287322] = true, -- Ice barrier, Jaina

	[276093] = true, -- Scarlet Mirror, Zul
	[276299] = true, -- Congestion outbreak, Zul
	[276434] = true, -- Rotten Flesh, Zul
	[276900] = true, -- Critical Blaze, Mithrax the Breaker
	[263482] = true, -- Restructuring shock, Gohorn
	[263284] = true, -- Blood Power, Gohorn
	[268074] = true, -- Dark Intent, Gohorn
	[275204] = true, -- Unstoppable corruption, Gohorn

	[207327] = true, -- Purification and Destruction, Cui Li Aix
	[236513] = true, -- Boneguard Armor, Agglomerate
	[240315] = true, -- Hardened Shell, Hayattan Egg Shield
	[241521] = true, -- Torture Shard
	[250074] = true, -- Purification, Aionar
	[250555] = true, -- Fel Shield, Aionar
	[246504] = true, -- Program launch, Gingaros
	[249863] = true, -- Titan Face, Destruction Witch Club
	[244903] = true, -- Catalysis, Agramar
	[247091] = true, -- Catalysis, Agrammar
	[253021] = true, -- Fate, Argus the Desolate
	[255496] = true, -- Sword of the Universe, Argus the Desolate
	[255478] = true, -- Eternal Blade, Argus the Desolate
	[255418] = true, -- Physically Vulnerable, Argus the Silent
	[255425] = true, -- Frost is vulnerable, Argus the Silent
	[255430] = true, -- Shadow is vulnerable, Argus the Silent
	[255429] = true, -- Flames are vulnerable, Argus the Silent
	[255419] = true, -- Holy and Vulnerable, Argus the Silent
	[255422] = true, -- Naturally Vulnerable, Argus the Silent
	[255433] = true, -- Arcane Vulnerable, Argus the Silent
}

-- Spell Blacklist
K.NameplateBlackList = {
	[15407]		= true, -- Mental flogging
	-- [1490]	= true, -- Chaos Branding
	-- [113746]	= true, -- Mysterious palm
	[51714]		= true, -- Sharp frost
	[199721]	= true, -- Rotten Aura
	[214968]	= true, -- Necro's Aura
	[214975]	= true, -- Heart Suppression Aura
	[273977]	= true, -- Dead Grip
	[276919]	= true, -- Under pressure
	[206930]	= true, -- Heart blow
}

-- ID from Dungeon Journal
-- The number is the GUID. After selecting the target, enter /getnpc to get info
local function GetSectionInfo(id)
	return C_EncounterJournal_GetSectionInfo(id).title
end

-- Custom Special Units
K.NameplateCustomUnits = {
	[120651] = true, -- Explosives
	[141851] = true, -- Spawn of G'huun
	[153377] = true, -- Goop
	[155432] = true, -- Enchanted Emissary <The Queen's Handmaiden>
	[155433] = true, -- Void-Touched Emissary <The Queen's Handmaiden>
	[155434] = true, -- Emissary of the Tides <The Queen's Handmaiden>

	[GetSectionInfo(14544)] = true,	-- Halegarh Mist Watcher
	[GetSectionInfo(14595)] = true,	-- Abyss Stalker
	[GetSectionInfo(16350)] = true,	-- Shadow of Varimathras
	[GetSectionInfo(16588)] = true,	-- Screaming Antitongue

	[GetSectionInfo(17026)] = true,	-- Vertigo wine barrel
	[GetSectionInfo(18007)] = true,	-- Plague Polymer
	[GetSectionInfo(18053)] = true,	-- Soul thorns
	[GetSectionInfo(18078)] = true,	-- Spider Weaver
	[GetSectionInfo(18104)] = true,	-- Scattered Tentacles
	[GetSectionInfo(18232)] = true,	-- Ashvan Gunner
	[GetSectionInfo(18271)] = true,	-- Burst Totem
	[GetSectionInfo(18312)] = true,	-- Blood beast
	[GetSectionInfo(18321)] = true,	-- Entwined Snake Swarm
	[GetSectionInfo(18499)] = true,	-- Clotted blood
	[GetSectionInfo(18540)] = true,	-- Nazmani Blood Warlock
	[GetSectionInfo(18890)] = true,	-- Charzax
	[GetSectionInfo(19019)] = true,	-- Greedy hunter
	[GetSectionInfo(19279)] = true,	-- Charming Siren
	[GetSectionInfo(19393)] = true,	-- Snowfury Soul
	[GetSectionInfo(19656)] = true,	-- Zombie Dust Totem
	--[GetSectionInfo(21209)] = true,	--
}

-- Display the unit of energy value
K.NameplateShowPowerList = {
	[152703] = true, -- Walking Shocker X1, Difficult McCargon
	[155432] = true, -- Magic messenger
	[GetSectionInfo(13015)] = true,	-- Cleaner
	[GetSectionInfo(15903)] = true,	-- Embers of Tessarac
	[GetSectionInfo(18539)] = true,	-- Crusher
	[GetSectionInfo(18540)] = true,	-- Nazmani Blood Warlock
}