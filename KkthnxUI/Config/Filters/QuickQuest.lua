local K, C = unpack(select(2, ...))
if C["Automation"].AutoQuest ~= true then
	return
end

K.QuickQuest_IgnoreQuestNPC = {
	[101462] = true,	-- Reaves
	[101880] = true,	-- Tak-Tak
	[103792] = true,	-- Griftah <Amazing Amulets>
	[105387] = true,	-- Andurs <Grand Master Pet Tamer>
	[108868] = true,	-- Hunter's order hall
	[111243] = true,	-- Archmage Lan'dalock
	[114719] = true,	-- Trader Caelen
	[119388] = true,	-- Chieftain Hatuun
	[121263] = true,	-- Grand Artificer Romuul
	[124312] = true,	-- High Exarch Turalyon
	[126954] = true,	-- High Exarch Turalyon
	[135690] = true,	-- Dread-Admiral Tattersail
	[141584] = true,	-- Zurvan <Master of Fate>
	[142063] = true,	-- Tezran <Master of Fate>
	[143388] = true,	-- Druza Netherfang <Portal Trainer>
	[14847] = true,		-- Professor Thaddeus Paleo <Darkmoon Cards>
	[150563] = true,	-- Skaggit <Gazlowe's Assistant>
	[150987] = true,	-- Sean Wilkers
	[154534] = true,	-- Flux <The Surge Protector>
	[43929] = true,		-- Blingtron 4000
	[87391] = true,		-- Fate-Twister Seress
	[88570] = true,		-- Fate-Twister Tiklal
	[93538] = true,		-- Dariness the Learned <Archaeology Trainer>
	[98489] = true,		-- Shipwrecked Captive <Grand Master Pet Tamer>
}

K.QuickQuest_IgnoreGossipNPC = {
	-- Bodyguards
	[86682] = true, -- Tormmok
	[86927] = true, -- Delvar Ironfist (Alliance)
	[86933] = true, -- Vivianne (Horde)
	[86934] = true, -- Defender Illona (Alliance)
	[86945] = true, -- Aeda Brightdawn (Horde)
	[86946] = true, -- Talonpriest Ishaal
	[86964] = true, -- Leorajh

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
	[117871] = true, -- War Councilor Victoria (Class Challenges @ Broken Shore)
	[155101] = true, -- Elemental Essence Amalgamator
	[155261] = true, -- Sean Wilkers
	[79740] = true, -- Warmaster Zog (Horde)
	[79953] = true, -- Lieutenant Thorn (Alliance)
	[84268] = true, -- Lieutenant Thorn (Alliance)
	[84511] = true, -- Lieutenant Thorn (Alliance)
	[84684] = true, -- Lieutenant Thorn (Alliance)
}

K.QuickQuest_RogueClassHallInsignia = {
	[93188] = true, -- Mongar
	[96782] = true, -- Lucian Trias
	[97004] = true, -- "Red" Jack Findle
}

K.QuickQuest_FollowerAssignees = {
	[135614] = true, -- Garona Halforcen
	[138708] = true, -- Garona Halforcen
}

K.QuickQuest_DarkmoonNPC = {
	[54334] = true, -- Darkmoon Faire Mystic Mage (Alliance)
	[55382] = true, -- Darkmoon Faire Mystic Mage (Horde)
	[57850] = true, -- Teleportologist Fozlebub
}

K.QuickQuest_ItemBlacklist = {
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
	["38176"] = 122405, -- Scouting Missive: Stonefury Cliffs
	["38177"] = 122403, -- Scouting Missive: Magnarok
	["38178"] = 122402, -- Scouting Missive: Iron Siegeworks
	["38179"] = 122400, -- Scouting Missive: Everbloom Wilds
	["38180"] = 122424, -- Scouting Missive: Broken Precipice
	["38181"] = 122421, -- Scouting Missive: Mok'gol Watchpost
	["38182"] = 122418, -- Scouting Missive: Darktide Roost
	["38183"] = 122416, -- Scouting Missive: Socrethar's Rise
	["38184"] = 122413, -- Scouting Missive: Lost Veil Anzu
	["38185"] = 122411, -- Scouting Missive: Pillars of Fate
	["38186"] = 122408, -- Scouting Missive: Skettis
	["38187"] = 122412, -- Scouting Missive: Shattrath Harbor
	["38189"] = 122401, -- Scouting Missive: Stonefury Cliffs
	["38190"] = 122399, -- Scouting Missive: Magnarok
	["38191"] = 122406, -- Scouting Missive: Iron Siegeworks
	["38192"] = 122404, -- Scouting Missive: Everbloom Wilds
	["38193"] = 122423, -- Scouting Missive: Broken Precipice
	["38194"] = 122420, -- Scouting Missive: Gorian Proving Grounds
	["38195"] = 122422, -- Scouting Missive: Mok'gol Watchpost
	["38196"] = 122417, -- Scouting Missive: Darktide Roost
	["38197"] = 122415, -- Scouting Missive: Socrethar's Rise
	["38198"] = 122414, -- Scouting Missive: Lost Veil Anzu
	["38199"] = 122409, -- Scouting Missive: Pillars of Fate
	["38200"] = 122407, -- Scouting Missive: Skettis
	["38201"] = 122410, -- Scouting Missive: Shattrath Harbor
	["38202"] = 122419, -- Scouting Missive: Gorian Proving Grounds

	-- Misc
	[31664] = 88604, -- Nat's Fishing Journal
}

K.QuickQuest_IgnoreProgressNPC = {
	[119388] = true,
	[124312] = true,
	[126954] = true,
	[127037] = true,
	[141584] = true,
	[150563] = true, -- Skaggit <Gazlowe's Assistant>
}

K.QuickQuest_CashRewards = {
	[45724] = 1e5, -- Champion's Purse
	[64491] = 2e6, -- Royal Reward

	-- Items from the Sixtrigger brothers quest chain in Stormheim
	[138123] = 15, -- Shiny Gold Nugget, 15 copper
	[138125] = 16, -- Crystal Clear Gemstone, 16 copper
	[138127] = 15, -- Mysterious Coin, 15 copper
	[138129] = 11, -- Swatch of Priceless Silk, 11 copper
	[138131] = 24, -- Magical Sprouting Beans, 24 copper
	[138133] = 27, -- Elixir of Endless Wonder, 27 copper
}