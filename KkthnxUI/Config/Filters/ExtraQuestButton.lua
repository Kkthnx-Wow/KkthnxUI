local K, C, L = unpack(select(2, ...))

-- Warlords of Draenor intro quest items which inspired this addon
K.itemBlacklist = {
	[113191] = true,
	[110799] = true,
	[109164] = true,
}

-- Quests with incorrect or missing quest area blobs (questID = mapID)
K.questAreas = {
	-- Global
	[24629] = true,

	-- Icecrown
	[14108] = 170,

	-- Northern Barrens
	[13998] = 11,

	-- Un'Goro Crater
	[24735] = 78,

	-- Darkmoon Island
	[29506] = 407,
	[29510] = 407,
	[29515] = 407,
	[29516] = 407,
	[29517] = 407,

	-- Mulgore
	[24440] = 7,
	[14491] = 7,
	[24456] = 7,
	[24524] = 7,

	-- Mount Hyjal
	[25577] = 198,
}

-- Quests items with incorrect or missing quest area blobs (itemID = mapID)
K.itemAreas = {
	-- Global
	[34862] = true,
	[34833] = true,
	[39700] = true,
	[155915] = true,
	[156474] = true,
	[156477] = true,
	[155918] = true,

	-- Deepholm
	[58167] = 207,
	[60490] = 207,

	-- Ashenvale
	[35237] = 63,

	-- Thousand Needles
	[56011] = 64,

	-- Tanaris
	[52715] = 71,

	-- The Jade Forest
	[84157] = 371,
	[89769] = 371,

	-- Hellfire Peninsula
	[28038] = 100,
	[28132] = 100,

	-- Borean Tundra
	[35352] = 114,
	[34772] = 114,
	[34711] = 114,
	[35288] = 114,
	[34782] = 114,

	-- Dragonblight
	[37881] = 115,
	[37923] = 115,
	[44450] = 115,
	[37887] = 115,

	-- Zul'Drak
	[41161] = 121,
	[39157] = 121,
	[39206] = 121,
	[39238] = 121,
	[39664] = 121,
	[38699] = 121,
	[41390] = 121,

	-- Grizzly Hills
	[38083] = 116,
	[35797] = 116,
	[37716] = 116,
	[35739] = 116,
	[36851] = 116,
	-- [36859] = 116,

	-- Icecrown
	[41265] = 170,

	-- Dalaran (Broken Isles)
	[129047] = 625,

	-- Stormheim
	[128287] = 634,
	[129161] = 634,

	-- Azsuna
	[118330] = 630,

	-- Suramar
	[133882] = 680,

	-- Tiragarde Sound
	[154878] = 895
}

-- Items not properly flagged as a special quest item (questID = itemID)
K.questItems = {
	-- Grizzly Hills
	[11982] = 35734,
	[11991] = 35797,
	[12007] = 35797,
	[12802] = 35797,
	[12068] = 35797,
	[12137] = 36859,
}

-- Items from the above list that needs to be showed when the quest is completed (itemID = flag)
K.questItemsShowComplete = {
	[35797] = true
}
