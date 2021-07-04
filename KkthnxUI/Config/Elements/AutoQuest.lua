local _, C = unpack(select(2, ...))

C.AutoQuest = {
	IgnoreQuestNPC = {
		[101462] = true, -- Reaves
		[101880] = true, -- 泰克泰克
		[103792] = true, -- 格里伏塔
		[105387] = true, -- 安杜斯
		[108868] = true, -- Hunter's order hall
		[111243] = true, -- Archmage Lan'dalock
		[114719] = true, -- 商人塞林
		[119388] = true, -- 酋长哈顿
		[121263] = true, -- 大技师罗姆尔
		[124312] = true, -- 图拉扬
		[126954] = true, -- 图拉扬
		[127037] = true, -- 纳毕鲁
		[135690] = true, -- 亡灵舰长
		[141584] = true, -- 祖尔温
		[142063] = true, -- 特兹兰
		[143388] = true, -- 德鲁扎
		[143555] = true, -- 山德·希尔伯曼，祖达萨PVP军需官
		[14847] = true, -- DarkMoon
		[150563] = true, -- 斯卡基特，麦卡贡订单日常
		[150987] = true, -- 肖恩·维克斯，斯坦索姆
		[154534] = true, -- 大杂院阿畅
		[160248] = true, -- 档案员费安，罪魂碎片
		[168430] = true, -- 戴克泰丽丝，格里恩挑战
		[326027] = true, -- 运输站回收生成器DX-82
		[43929] = true, -- 4000
		[87391] = true, -- Fate-Twister Seress
		[88570] = true, -- Fate-Twister Tiklal
		[93538] = true, -- 达瑞妮斯
		[98489] = true, -- 海难俘虏
	},

	IgnoreGossipNPC = {
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
		[150122] = true, -- 荣耀堡法师
		[150131] = true, -- 萨尔玛法师
		[155101] = true, -- 元素精华融合器
		[155261] = true, -- 肖恩·维克斯，斯坦索姆
		[79740] = true, -- Warmaster Zog (Horde)
		[79953] = true, -- Lieutenant Thorn (Alliance)
		[84268] = true, -- Lieutenant Thorn (Alliance)
		[84511] = true, -- Lieutenant Thorn (Alliance)
		[84684] = true, -- Lieutenant Thorn (Alliance)

		[171589] = true, -- 德莱文将军
		[171787] = true, -- 文官阿得赖斯提斯
		[171795] = true, -- 月莓女勋爵
		[171821] = true, -- 德拉卡女男爵
		[172558] = true, -- 艾拉·引路者（导师）
		[172572] = true, -- 瑟蕾丝特·贝利文科（导师）
		[173021] = true, -- 刻符牛头人
		[175513] = true, -- 纳斯利亚审判官，傲慢
	},

	AutoGossipTypes = {
		["taxi"] = true,
		["gossip"] = true,
		["banker"] = true,
		["vendor"] = true,
		["trainer"] = true,
	},

	RogueClassHallInsignia = {
		[93188] = true, -- Mongar
		[96782] = true, -- Lucian Trias
		[97004] = true, -- "Red" Jack Findle
	},

	FollowerAssignees = {
		[135614] = true, -- 马迪亚斯·肖尔大师
		[138708] = true, -- 半兽人迦罗娜
	},

	DarkmoonNPC = {
		[54334] = true, -- Darkmoon Faire Mystic Mage (Alliance)
		[55382] = true, -- Darkmoon Faire Mystic Mage (Horde)
		[57850] = true, -- Teleportologist Fozlebub
	},

	ItemBlacklist = {
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
	},

	CashRewards = {
		[45724] = 1e5, -- Champion's Purse
		[64491] = 2e6, -- Royal Reward

		-- Items from the Sixtrigger brothers quest chain in Stormheim
		[138123] = 15, -- Shiny Gold Nugget, 15 copper
		[138125] = 16, -- Crystal Clear Gemstone, 16 copper
		[138127] = 15, -- Mysterious Coin, 15 copper
		[138129] = 11, -- Swatch of Priceless Silk, 11 copper
		[138131] = 24, -- Magical Sprouting Beans, 24 copper
		[138133] = 27, -- Elixir of Endless Wonder, 27 copper
	},
}