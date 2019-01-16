local K, C = unpack(select(2, ...))
if K.CheckAddOnState("QuickQuest") or K.CheckAddOnState("AutoTurnIn") then
	return
end

if C["Automation"].AutoQuest ~= true then
	return
end

K.AutoQuestBlacklistDB  = {
	items = {
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
		[38176] = 122405, -- Scouting Missive: Stonefury Cliffs
		[38177] = 122403, -- Scouting Missive: Magnarok
		[38178] = 122402, -- Scouting Missive: Iron Siegeworks
		[38179] = 122400, -- Scouting Missive: Everbloom Wilds
		[38180] = 122424, -- Scouting Missive: Broken Precipice
		[38181] = 122421, -- Scouting Missive: Mok'gol Watchpost
		[38182] = 122418, -- Scouting Missive: Darktide Roost
		[38183] = 122416, -- Scouting Missive: Socrethar's Rise
		[38184] = 122413, -- Scouting Missive: Lost Veil Anzu
		[38185] = 122411, -- Scouting Missive: Pillars of Fate
		[38186] = 122408, -- Scouting Missive: Skettis
		[38187] = 122412, -- Scouting Missive: Shattrath Harbor
		[38189] = 122401, -- Scouting Missive: Stonefury Cliffs
		[38190] = 122399, -- Scouting Missive: Magnarok
		[38191] = 122406, -- Scouting Missive: Iron Siegeworks
		[38192] = 122404, -- Scouting Missive: Everbloom Wilds
		[38193] = 122423, -- Scouting Missive: Broken Precipice
		[38194] = 122420, -- Scouting Missive: Gorian Proving Grounds
		[38195] = 122422, -- Scouting Missive: Mok'gol Watchpost
		[38196] = 122417, -- Scouting Missive: Darktide Roost
		[38197] = 122415, -- Scouting Missive: Socrethar's Rise
		[38198] = 122414, -- Scouting Missive: Lost Veil Anzu
		[38199] = 122409, -- Scouting Missive: Pillars of Fate
		[38200] = 122407, -- Scouting Missive: Skettis
		[38201] = 122410, -- Scouting Missive: Shattrath Harbor
		[38202] = 122419, -- Scouting Missive: Gorian Proving Grounds

		-- Misc
		[31664] = 88604, -- Nat's Fishing Journal
	}
}

K.IgnoreQuestNPC = {
	[103792] = true, -- Griftah (one of his quests is a scam)
	[111243] = true, -- Archmage Lan"dalock
	[119388] = true, -- Chieftain Hatuun (repeatable resource quest)
	[124312] = true, -- High Exarch Turalyon (repeatable resource quest)
	[126954] = true, -- High Exarch Turalyon (repeatable resource quest)
	[127037] = true, -- Nabiru (repeatable resource quest)
	[141584] = true, -- Zurvan (Seal of Wartorn Fate, Horde)
	[142063] = true, -- Tezran (Seal of Wartorn Fate, Alliance)
	[87391] = true, -- Fate-Twister Seress
	[88570] = true, -- Fate-Twister Tiklal
}

K.IgnoreGossipNPC = {
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
}

K.RogueClassHallInsignia = {
	[93188] = true, -- Mongar
	[96782] = true, -- Lucian Trias
	[97004] = true, -- "Red" Jack Findle
}

K.DarkmoonDailyNPCs = {
	[14841] = true, -- Rinling
	[15303] = true, -- Maxima Blastenheimer
	[54485] = true, -- Jessica Rogers
	[54601] = true, -- Mola
	[54605] = true, -- Finlay Coolshot
	[67370] = true, -- Jeremy Feasel
	[85519] = true, -- Christoph VonFeasel
	[85546] = true, -- Ziggie Sparks
}

K.DarkmoonNPC = {
	[54334] = true, -- Darkmoon Faire Mystic Mage (Alliance)
	[55382] = true, -- Darkmoon Faire Mystic Mage (Horde)
	[57850] = true, -- Teleportologist Fozlebub
}

K.CashRewards = {
	[45724] = 1e5, -- Champion"s Purse, 10 gold
	[64491] = 2e6, -- Royal Reward, 200 gold

	-- Items from the Sixtrigger brothers quest chain in Stormheim
	[138127] = 15, -- Mysterious Coin, 15 copper
	[138129] = 11, -- Swatch of Priceless Silk, 11 copper
	[138131] = 24, -- Magical Sprouting Beans, 24 copper
	[138123] = 15, -- Shiny Gold Nugget, 15 copper
	[138125] = 16, -- Crystal Clear Gemstone, 16 copper
	[138133] = 27, -- Elixir of Endless Wonder, 27 copper
}