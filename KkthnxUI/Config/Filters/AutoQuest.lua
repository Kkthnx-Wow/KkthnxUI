local K, C = unpack(select(2, ...))
if C["Automation"].AutoQuest ~= true then
	return
end

K.AutoQuestBlockedNPC = {
	-- Ignore specific NPCs for selecting, accepting and turning-in quests (required if automation has consequences)
	[15192] = true, -- Anachronos (Caverns of Time)
	[119388] = true, -- Chieftain Hatuun (Krokul Hovel, Krokuun)
	[6566] = true, -- Estelle Gendry (Heirloom Curator, Undercity)
	[45400] = true, -- Fiona's Caravan (Eastern Plaguelands)
	[18166] = true, -- Khadgar (Allegiance to Aldor/Scryer, Shattrath)
	[55402] = true, -- Korgol Crushskull (Darkmoon Faire, Pit Master)
	[6294] = true, -- Krom Stoutarm (Heirloom Curator, Ironforge)
	[109227] = true, -- Meliah Grayfeather (Tradewind Roost, Highmountain)
	[99183] = true, -- Renegade Ironworker (Tanaan Jungle, repeatable quest)
	[114719] = true, -- Trader Caelen (Obliterum Forge, Dalaran, Broken Isles)

	-- Seals of Fate
	[111243] = true, -- Archmage Lan'dalock (Seal quest, Dalaran)
	[87391] = true, -- Fate-Twister Seress (Seal quest, Stormshield)
	[88570] = true, -- Fate-Twister Tiklal (Seal quest, Horde)
	[142063] = true, -- Tezran (Seal quest, Boralus Harbor, Alliance)
	[141584] = true, -- Zurvan (Seal quest, Dazar'alor, Horde)

	-- Wartime Donations (Alliance)
	[142994] = true, -- Brandal Darkbeard (Boralus)
	[142995] = true, -- Charlane (Boralus)
	[142993] = true, -- Chelsea Strand (Boralus)
	[142998] = true, -- Faella (Boralus)
	[143004] = true, -- Larold Kyne (Boralus)
	[143005] = true, -- Liao (Boralus)
	[143007] = true, -- Mae Wagglewand (Boralus)
	[143008] = true, -- Norber Togglesprocket (Boralus)
	[142685] = true, -- Paymaster Vauldren (Boralus)
	[142700] = true, -- Quartermaster Peregrin (Boralus)
	[142997] = true, -- Senedras (Boralus)

	-- Wartime Donations (Horde)
	[142970] = true, -- Kuma Longhoof (Dazar'alor)
	[142969] = true, -- Logarr (Dazar'alor)
	[142973] = true, -- Mai-Lu (Dazar'alor)
	[142977] = true, -- Meredith Swane (Dazar'alor)
	[142981] = true, -- Merill Redgrave (Dazar'alor)
	[142157] = true, -- Paymaster Grintooth (Dazar'alor)
	[142158] = true, -- Quartermaster Rauka (Dazar'alor)
	[142975] = true, -- Seamstress Vessa (Dazar'alor)
	[142983] = true, -- Swizzle Fizzcrank (Dazar'alor)
	[142992] = true, -- Uma'wi (Dazar'alor)
	[142159] = true -- Zen'kin (Dazar'alor)
}

-- Ignore specific NPCs for selecting quests only (only used for items that have no other purpose)
K.AutoQuestBlockedSelectNPC = {
	[87706] = true, -- Gazmolf Futzwangler (Reputation quests, Nagrand, Draenor)
	[70022] = true, -- Ku'ma (Isle of Giants, Pandaria)
	[12944] = true, -- Lokhtos Darkbargainer (Thorium Brotherhood, Blackrock Depths)
	[87393] = true -- Sallee Silverclamp (Reputation quests, Nagrand, Draenor)
}