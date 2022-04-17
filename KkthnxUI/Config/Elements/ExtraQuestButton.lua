local _, C = unpack(KkthnxUI)

-- Warlords of Draenor intro quest items which inspired this addon
C.ExtraQuestButton_Blacklist = {
	[113191] = true,
	[110799] = true,
	[109164] = true,
}

-- quests that doesn't have a defined area on the map (questID = bool/mapID/{mapID,...})
-- these have low priority during collision
C.ExtraQuestButton_InaccurateQuestAreas = {
	[11731] = { 84, 87, 103 }, -- alliance capitals (missing Darnassus)
	[11921] = { 84, 87, 103 }, -- alliance capitals (missing Darnassus)
	[11922] = { 18, 85, 88, 110 }, -- horde capitals
	[11926] = { 18, 85, 88, 110 }, -- horde capitals
	[12779] = 124, -- Scarlet Enclave (Death Knight starting zone)
	[13998] = 11, -- Northern Barrens
	[14246] = 66, -- Desolace
	[24440] = 7, -- Mulgore
	[24456] = 7, -- Mulgore
	[24524] = 7, -- Mulgore
	[24629] = { 84, 85, 87, 88, 103, 110 }, -- major capitals (missing Darnassus & Undercity)
	[25577] = 198, -- Mount Hyjal
	[29506] = 407, -- Darkmoon Island
	[29510] = 407, -- Darkmoon Island
	[29515] = 407, -- Darkmoon Island
	[29516] = 407, -- Darkmoon Island
	[29517] = 407, -- Darkmoon Island
	[49813] = true, -- anywhere
	[49846] = true, -- anywhere
	[49860] = true, -- anywhere
	[49864] = true, -- anywhere
	[25798] = 64, -- Thousand Needles (TODO: test if we need to associate the item with the zone instead)
	[25799] = 64, -- Thousand Needles (TODO: test if we need to associate the item with the zone instead)
	[34461] = 590, -- Horde Garrison
	[59809] = true,
	[60004] = 118, -- 前夕任务：英勇之举
	[63971] = 1543, -- 法夜突袭，蜗牛践踏
}

-- items that should be used for a quest but aren't (questID = itemID)
-- these have low priority during collision
C.ExtraQuestButton_QuestItems = {
	-- (TODO: test if we need to associate any of these items with a zone directly instead)
	[10129] = 28038, -- Hellfire Peninsula
	[10146] = 28038, -- Hellfire Peninsula
	[10162] = 28132, -- Hellfire Peninsula
	[10163] = 28132, -- Hellfire Peninsula
	[10346] = 28132, -- Hellfire Peninsula
	[10347] = 28132, -- Hellfire Peninsula
	[11617] = 34772, -- Borean Tundra
	[11633] = 34782, -- Borean Tundra
	[11894] = 35288, -- Borean Tundra
	[11982] = 35734, -- Grizzly Hills
	[11986] = 35739, -- Grizzly Hills
	[11989] = 38083, -- Grizzly Hills
	[12026] = 35739, -- Grizzly Hills
	[12415] = 37716, -- Grizzly Hills
	[12007] = 35797, -- Grizzly Hills
	[12456] = 37881, -- Dragonblight
	[12470] = 37923, -- Dragonblight
	[12484] = 38149, -- Grizzly Hills
	[12661] = 41390, -- Zul'Drak
	[12713] = 38699, -- Zul'Drak
	[12861] = 41161, -- Zul'Drak
	[13343] = 44450, -- Dragonblight
	[29821] = 84157, -- Jade Forest
	[31112] = 84157, -- Jade Forest
	[31769] = 89769, -- Jade Forest
	[35237] = 11891, -- Ashenvale
	[36848] = 36851, -- Grizzly Hills
	[37565] = 118330, -- Azsuna
	[39385] = 128287, -- Stormheim
	[39847] = 129047, -- Dalaran (Broken Isles)
	[40003] = 129161, -- Stormheim
	[40965] = 133882, -- Suramar
	[43827] = 129161, -- Stormheim
	[49402] = 154878, -- Tiragarde Sound
	[50164] = 154878, -- Tiragarde Sound
	[51646] = 154878, -- Tiragarde Sound
	[58586] = 174465, -- Venthyr Covenant
	[59063] = 175137, -- Night Fae Covenant
	[59809] = 177904, -- Night Fae Covenant
	[60188] = 178464, -- Night Fae Covenant
	[60649] = 180170, -- Ardenweald
	[60609] = 180008, -- Ardenweald
}

-- items that need to be shown, but not. (itemID = bool/mapID)
C.Complete_ShownItems = {
	[177904] = true,
	[35797] = 116, -- Grizzly Hills
	[41058] = 120, -- Storm Peaks
	[52853] = true, -- Mount Hyjal
	[60273] = 50, -- Northern Stranglethorn Vale
}

-- items that need to be hidden, but not. (itemID = bool/mapID)
C.Complete_HiddenItems = {
	[180899] = true, -- Riding Hook
	[184876] = true, -- Cohesion Crystal
	[186199] = true, -- Lady Moonberry's Wand
	[187012] = true, -- Unbalanced Riftstone
	[187516] = true, -- 菲历姆的锻炉阀门
}
