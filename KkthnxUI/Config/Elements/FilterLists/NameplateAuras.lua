local C = KkthnxUI[2]

C.NameplateWhiteList = {
	-- Buffs
	[642] = true, -- Divine Shield
	[1022] = true, -- hand of protection
	[23920] = true, -- spell reflection
	[45438] = true, -- Ice Barrier
	[186265] = true, -- Guardian of the Spirit Turtle
	-- Debuffs
	[2094] = true, -- blind
	[10326] = true, -- super evil
	[20549] = true, -- War Stomp
	[107079] = true, -- Trembling Mountain Palm
	[117405] = true, -- bound shot
	[127797] = true, -- Ursol Whirlwind
	[272295] = true, -- bounty
	-- Mythic+
	[228318] = true, -- enrage
	[226510] = true, -- blood pool
	[343553] = true, -- Resentment of Ten Thousand Eaters
	[343502] = true, -- Inspirational aura
	-- Dungeons
	[113315] = true, -- Qinglong Temple, strong
	[113309] = true, -- Qinglong Temple, the highest energy
}

C.NameplateBlackList = {
	[15407] = true, -- Mind Flay
	[51714] = true, -- Sharp Frost
	[199721] = true, -- Rotten Aura
	[214968] = true, -- necrotic aura
	[214975] = true, -- Heart suppression aura
	[273977] = true, -- Grasp of the Dead
	[276919] = true, -- under pressure
	[206930] = true, -- Heart Strike
}

C.NameplateCustomUnits = {
	-- Nzoth vision
	[153401] = true, --K'thir Dominator
	[157610] = true, -- K'thir Dominator
	[156795] = true, -- SI:7 informant
	-- Dungeons
	[120651] = true, -- rice, explosives
	[174773] = true, -- Rice, Vicious Shadowfiend
	[104251] = true, -- Court of Stars, Sentinels
	[196548] = true, -- Ancient Tree Branches, Academy
	[52019] = true, -- Falling Nova, Top of the Whirling Cloud
	[137103] = true, -- Bloodface Beast, Abyss
	[92538] = true, -- oil spray maggots, nests
	-- Condemned Demon
	[169430] = true,
	[169428] = true,
	[168932] = true,
	[169425] = true,
	[169429] = true,
	[169421] = true,
	[169426] = true,
}

C.NameplateShowPowerList = {
	[56792] = true, -- Qinglong Temple, suspicious image
	[171557] = true, -- Ardimor the Hunter, Shadow of Bagast
	[165556] = true, -- Crimson abyss, instant concrete
	[163746] = true, -- Junkyard, Walking Shocker X1
	[114247] = true, -- on card, curator
}

C.NameplateTargetNPCs = {
	[165251] = true, -- Xianlin Fox
	[174773] = true, -- Malice
}

C.NameplateTrashUnits = {
	[166589] = true, -- living weapon, crimson
	[169753] = true, -- hungry louse, red
	[175677] = true, -- smuggled creature, bazaar
	[190174] = true, -- hypnotic bat, S4
}

C.MajorSpells = {
	[156718] = true, -- Necrosis Burst, Shadowmoon Graveyard
	[156776] = true, -- Void Rend, Shadowmoon Graveyard
	[398150] = true, -- Domination, Shadowmoon Graveyard
	[398206] = true, -- Death Shock, Shadowmoon Graveyard
	[152964] = true, -- Void Pulse, Shadowmoon Graveyard
	[198595] = true, -- Thunderbolt, Hall of Valor
	[396812] = true, -- Arcane Blast, Academy
	[397889] = true, -- The tide broke out, Qinglong Temple
	[395859] = true, -- Wandering Screech, Dragon Temple
	[397878] = true, -- Enchanted ripples, Qinglong Temple
	[392451] = true, -- Flashfire, Ruby
	[392452] = true, -- Sparkle, Ruby
	[385536] = true, -- Flame Dancer, Ruby
	[372087] = true, -- Blazing Dash, Ruby
	[372735] = true, -- Earthcrack, Ruby
	[388283] = true, -- eruption, blocking battle
	[387440] = true, -- Blasphemous Roar, Snipe
	[386012] = true, -- Stormbolt, siege
	[374720] = true, -- Devouring Stomp, Azure
	[372222] = true, -- Arcane Cleave, Azure
	[386546] = true, -- Sober nemesis, Azure
	[387564] = true, -- arcane steam, azure
	-- DF Season 2
	[88186] = true, -- mist form, peak of swirling clouds
	[87779] = true, -- Greater Healing, Cloud Peak
	[87761] = true, -- Encouragement, Spinning Cloud Peak
	[87762] = true, -- Lightning Lash, Cloudtop
	[87618] = true, -- Static Grip, Top of the Whirling Cloud
	[413385] = true, -- Overload Ground Field, Spinning Cloud Summit
	[411001] = true, -- Deadly Electricity, Spiral Cloud Peak
	[410870] = true, -- the whirlwind, the top of the whirling cloud
	[411012] = true, -- Cold Breath, Cloud Peak
	[369411] = true, -- Sonic Burst, Uldaman
	[369409] = true, -- Cleave, Uldaman
	[369465] = true, -- Stone Hail, Uldaman
	[369466] = true, -- Stone Hail, Uldaman
	[388424] = true, -- Stormrage, Hall of Infusion
	[391634] = true, -- arctic freezing, empowering halls
	[377341] = true, -- Wave Split, Infused Hall
	[374699] = true, -- moxibustion, infusion hall
	[376171] = true, -- Comforting tide, infused hall
	[374563] = true, -- stuns, empowers halls
	[265091] = true, -- Gift of G'huun, the Deep
	[369811] = true, -- Brutal Swipe, Uldaman
	[369675] = true, -- Chain Lightning, Uldaman
	[369573] = true, -- Heavy Arrow, Uldaman
	[226296] = true, -- piercing shards, lair
	[202075] = true, -- burn, lair
	[193585] = true, -- bondage, lair
	[257397] = true, -- Healing Salve, Freehold
	[257426] = true, -- Backhand Slam, Freehold
	[257732] = true, -- Deafening Roar, Freehold
	[258777] = true, -- Sea Jet, Freehold
	[257784] = true, -- Frostshock, Freehold
	[257736] = true, -- Howling wind and thunder, free town
	[257737] = true, -- Howling wind and thunder, free town
	[265019] = true, -- Cleave, Deep
	[278961] = true, -- Declining Will, The Abyss
	[260894] = true, -- Spreading Corruption, The Abyss
	[265540] = true, -- Corrupted Bile, The Abyss
	[265542] = true, -- Corrupted Bile, The Abyss
	[265089] = true, -- Darkness Revives, Abyss
	[278755] = true, -- howling despair, the abyss
	[266106] = true, -- Sonic Screech, Abyss
	[272609] = true, -- Crazy Gaze, Abyss
	[265433] = true, -- Curse of Blight, Abyss
	[382410] = true, -- Blight Arrow, Fern Bark
	[367500] = true, -- ferocious sneer, fern bark
	[382555] = true, -- Furious Storm, Bracken Bark
	[382556] = true, -- Furious Storm, Bracken Bark
	[377950] = true, -- Strong Healing Turbulence, Fern Bark
	[381470] = true, -- Bewitching Totem, Fern Bark
	[381694] = true, -- Sensation of Decay, Fern Bark
	[388060] = true, -- Foul Breath, Fern Bark
	[383385] = true, -- Rotting Surge, Fern Bark
	[382172] = true, -- Necrotic Breath, Fern Bark
	[378282] = true, -- Molten Core, Neltharus
	[383651] = true, -- Molten Legion, Neltharus
	[375439] = true, -- Blazing Charge, Neltharus
	[395427] = true, -- Burning Roar, Neltharus
	[376186] = true, -- Burst Squeeze, Neltharus
	[372223] = true, -- Healing Dirt, Neltharus
	[373424] = true, -- Spear of the Earth, Neltharus
	[376780] = true, -- Magma Shield, Neltharus
}
