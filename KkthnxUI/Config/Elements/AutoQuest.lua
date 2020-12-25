local _, C = unpack(select(2, ...))

C.IgnoreQuestNPC = {
	[88570] = true, -- Fate-Twister Tiklal
	[87391] = true, -- Fate-Twister Seress
	[111243] = true, -- Archmage Lan'dalock
	[108868] = true, -- Hunter's order hall
	[101462] = true, -- Reaves
	[43929] = true, -- 4000
	[14847] = true, -- DarkMoon
	[119388] = true, -- Chief Hatton
	[114719] = true, -- Sellin
	[121263] = true, -- Grand Technician Roml
	[126954] = true, -- Turalyan
	[124312] = true, -- Turalyan
	[103792] = true, -- Grivota
	[101880] = true, -- Techtec
	[141584] = true, -- Zulwin
	[142063] = true, -- Tezran
	[143388] = true, -- Druza
	[98489] = true, -- Shipwrecked prisoners
	[135690] = true, -- Undead Captain
	[105387] = true, -- Andus
	[93538] = true, -- Darinis
	[154534] = true, -- Da Za Yuan A Chang
	[150987] = true, -- Sean Vickers, Stratholme
	[150563] = true, -- Skagit, Mechagon orders daily
	[143555] = true, -- Sand Silberman, PVP Quartermaster of Zuldazar
}

C.IgnoreGossipNPC = {
	-- Bodyguards
	[86945] = true, -- Aeda Brightdawn (Horde)
	[86933] = true, -- Vivianne (Horde)
	[86927] = true, -- Delvar Ironfist (Alliance)
	[86934] = true, -- Defender Illona (Alliance)
	[86682] = true, -- Tormmok
	[86964] = true, -- Leorajh
	[86946] = true, -- Talonpriest Ishaal

	-- Sassy Imps
	[95139] = true,
	[95141] = true,
	[95142] = true,
	[95143] = true,
	[95144] = true,
	[95145] = true,
	[95146] = true,
	[95200] = true,
	[95201] = true,

	-- Misc NPCs
	[79740] = true, -- Warmaster Zog (Horde)
	[79953] = true, -- Lieutenant Thorn (Alliance)
	[84268] = true, -- Lieutenant Thorn (Alliance)
	[84511] = true, -- Lieutenant Thorn (Alliance)
	[84684] = true, -- Lieutenant Thorn (Alliance)
	[117871] = true, -- War Councilor Victoria (Class Challenges @ Broken Shore)
	[155101] = true, -- Elemental Essence Fusion
	[155261] = true, -- Sean Vickers, Stratholme
	[150122] = true, -- Honor Hold Mage
	[150131] = true, -- Salma Mage

	[173021] = true, -- Engraved Tauren
	[171589] = true, -- General Draven
	[171787] = true, -- Civil Service Adrianistis
	[171795] = true, -- Lady Moonberry
	[171821] = true, -- Baroness Draka
	[172558] = true, -- Ella Pathfinder (Tutor)
	[172572] = true, -- Celeste Bellevenko (Tutor)
	[175513] = true, -- 纳斯利亚审判官
}

C.RogueClassHallInsignia = {
	[97004] = true, -- "Red" Jack Findle
	[96782] = true, -- Lucian Trias
	[93188] = true, -- Mongar
}

C.FollowerAssignees = {
	[138708] = true, -- Garona the Orc
	[135614] = true, -- Master Matthias Shore
}

C.DarkmoonNPC = {
	[57850] = true, -- Teleportologist Fozlebub
	[55382] = true, -- Darkmoon Faire Mystic Mage (Horde)
	[54334] = true, -- Darkmoon Faire Mystic Mage (Alliance)
}

C.ItemBlacklist = {
	-- Inscription weapons
	[31690] = 79343, -- Inscribed Tiger Staff
	[31691] = 79340, -- Inscribed Crane Staff
	[31692] = 79341, -- Inscribed Serpent Staff

	-- Darkmoon Faire artifacts
	[29443] = 71635, -- Imbued Crystal
	[29444] = 71636, -- Monstrous Egg
	[29445] = 71637, -- Mysterious Grimoire
	[29446] = 71638, -- Ornate Weapon
	[29451] = 71715, -- A Treatise on Strategy
	[29456] = 71951, -- Banner of the Fallen
	[29457] = 71952, -- Captured Insignia
	[29458] = 71953, -- Fallen Adventurer's Journal
	[29464] = 71716, -- Soothsayer's Runes

	-- Tiller Gifts
	["progress_79264"] = 79264, -- Ruby Shard
	["progress_79265"] = 79265, -- Blue Feather
	["progress_79266"] = 79266, -- Jade Cat
	["progress_79267"] = 79267, -- Lovely Apple
	["progress_79268"] = 79268, -- Marsh Lily

	-- Garrison scouting missives
	["38180"] = 122424, -- Scouting Missive: Broken Precipice
	["38193"] = 122423, -- Scouting Missive: Broken Precipice
	["38182"] = 122418, -- Scouting Missive: Darktide Roost
	["38196"] = 122417, -- Scouting Missive: Darktide Roost
	["38179"] = 122400, -- Scouting Missive: Everbloom Wilds
	["38192"] = 122404, -- Scouting Missive: Everbloom Wilds
	["38194"] = 122420, -- Scouting Missive: Gorian Proving Grounds
	["38202"] = 122419, -- Scouting Missive: Gorian Proving Grounds
	["38178"] = 122402, -- Scouting Missive: Iron Siegeworks
	["38191"] = 122406, -- Scouting Missive: Iron Siegeworks
	["38184"] = 122413, -- Scouting Missive: Lost Veil Anzu
	["38198"] = 122414, -- Scouting Missive: Lost Veil Anzu
	["38177"] = 122403, -- Scouting Missive: Magnarok
	["38190"] = 122399, -- Scouting Missive: Magnarok
	["38181"] = 122421, -- Scouting Missive: Mok'gol Watchpost
	["38195"] = 122422, -- Scouting Missive: Mok'gol Watchpost
	["38185"] = 122411, -- Scouting Missive: Pillars of Fate
	["38199"] = 122409, -- Scouting Missive: Pillars of Fate
	["38187"] = 122412, -- Scouting Missive: Shattrath Harbor
	["38201"] = 122410, -- Scouting Missive: Shattrath Harbor
	["38186"] = 122408, -- Scouting Missive: Skettis
	["38200"] = 122407, -- Scouting Missive: Skettis
	["38183"] = 122416, -- Scouting Missive: Socrethar's Rise
	["38197"] = 122415, -- Scouting Missive: Socrethar's Rise
	["38176"] = 122405, -- Scouting Missive: Stonefury Cliffs
	["38189"] = 122401, -- Scouting Missive: Stonefury Cliffs

	-- Misc
	[31664] = 88604, -- Nat's Fishing Journal
}

C.IgnoreProgressNPC = {
	[119388] = true,
	[127037] = true,
	[126954] = true,
	[124312] = true,
	[141584] = true,
	[326027] = true, -- Transport station recycling generator DX-82
	[150563] = true, -- Skagit, Mechagon orders daily
}

C.CashRewards = {
	[45724] = 1e5, -- Champion's Purse
	[64491] = 2e6, -- Royal Reward

	-- Items from the Sixtrigger brothers quest chain in Stormheim
	[138127] = 15, -- Mysterious Coin, 15 copper
	[138129] = 11, -- Swatch of Priceless Silk, 11 copper
	[138131] = 24, -- Magical Sprouting Beans, 24 copper
	[138123] = 15, -- Shiny Gold Nugget, 15 copper
	[138125] = 16, -- Crystal Clear Gemstone, 16 copper
	[138133] = 27, -- Elixir of Endless Wonder, 27 copper
}