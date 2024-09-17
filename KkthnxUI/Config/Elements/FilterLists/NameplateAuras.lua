local C = KkthnxUI[2]

C.NameplateWhiteList = {
	-- Buffs
	[642] = true, -- Divine Shield
	[1022] = true, -- Hand of Protection
	[23920] = true, -- Spell Reflection
	[45438] = true, -- Ice Block
	[186265] = true, -- Shell Shield
	-- Debuffs
	[2094] = true, -- Blind
	[10326] = true, -- Turn Evil
	[20549] = true, -- War Stomp
	[107079] = true, -- Quaking Palm
	[117405] = true, -- Binding Shot
	[127797] = true, -- Ursol's Vortex
	[272295] = true, -- Defile
	-- Mythic+
	[228318] = true, -- Raging
	[226510] = true, -- Sanguine
	[343553] = true, -- Spiteful
	[343502] = true, -- Inspiring
	-- Dungeons
	[113315] = true, -- Temple of the Jade Serpent, Intensity
	[113309] = true, -- Temple of the Jade Serpent, Supreme Power
	[384148] = true, -- Trap, Fernskin
	[200672] = true, -- Crystal Burst, Nest
	[377724] = true, -- Sanguine Ichor, Tyrant
	[413027] = true, -- Titan Barrier, Spires of Ascension
	[258653] = true, -- Soul Barrier, Atal'Dazar
	[255960] = true, -- Empowered Loa's Bargain, Atal'Dazar
	[255967] = true, -- Empowered Loa's Bargain, Atal'Dazar
	[255968] = true, -- Empowered Loa's Bargain, Atal'Dazar
	[255970] = true, -- Empowered Loa's Bargain, Atal'Dazar
	[255972] = true, -- Empowered Loa's Bargain, Atal'Dazar
	[260805] = true, -- Focusing Iris, Plaguefall
	[264027] = true, -- Ward Candle, Plaguefall
	[372824] = true, -- 燃烧锁链，奈萨鲁斯
	-- TWW S1
	[343558] = true, -- 通灵战潮，病态凝视
	[343470] = true, -- 通灵战潮，碎骨之盾
	[328351] = true, -- 通灵战潮，染血长枪
	[323149] = true, -- 仙林，黑暗之拥
	[322569] = true, -- 仙林，兹洛斯之手
}

C.NameplateBlackList = {
	[15407] = true, -- Mind Flay
	[51714] = true, -- Razorice
	[199721] = true, -- Virulent Plague
	[214968] = true, -- Unholy Frenzy
	[214975] = true, -- Mind Freeze
	[273977] = true, -- Grip of the Dead
	[276919] = true, -- Unending Thirst
	[206930] = true, -- Heart Strike
}

C.NameplateCustomUnits = {
	-- Nzoth vision
	[153401] = true, -- K'xir Dominator
	[157610] = true, -- K'xir Dominator
	[156795] = true, -- SI:7 Informant
	-- Dungeons
	[120651] = true, -- M+, Explosive
	[204560] = true, -- M+, Void Entity
	[104251] = true, -- Court of Stars, Sentry
	[196548] = true, -- Arcway, Wandering Branch
	[52019] = true, -- Falling Star, Vortex Pinnacle
	[137103] = true, -- Bloodface, Underrot
	[92538] = true, -- Oil Beetle, Nest
	[190426] = true, -- Decaying Totem, Fernskin
	[190381] = true, -- Rotburst Totem, Fernskin
	[186696] = true, -- Tremor Totem, Tyrant
	[84400] = true, -- 繁盛古树，永茂林地
	[199368] = true, -- 硬化的水晶，碧蓝魔馆
	-- Condemned Demon
	[169430] = true,
	[169428] = true,
	[168932] = true,
	[169425] = true,
	[169429] = true,
	[169421] = true,
	[169426] = true,
	-- TWW S1
	[165251] = true, -- 幻影仙狐，仙林
}

C.NameplateShowPowerList = {
	[56792] = true, -- Temple of the Jade Serpent, Doubtful Delusion
	[171557] = true, -- Huntsman Altimor, Bargast's Shadow
	[165556] = true, -- Sanguine Depths, Instantaneous Manifestation
	[163746] = true, -- Junkyard, Walking Shocker X1
	[114247] = true, -- Karazhan, Curator
}

C.NameplateTargetNPCs = {
	[165251] = true, -- Sylvan Fox
	[174773] = true, -- Spiteful Fiend
}

C.NameplateTrashUnits = {
	[174773] = true, -- M+, Spiteful Shade
	[190174] = true, -- Hypnotic Bat, S4
	[166589] = true, -- Animated Weapon, Crimson
	[169753] = true, -- Hungry Louse, Crimson
	[175677] = true, -- Smuggled Creature, Market
	[190407] = true, -- Wave Fury, Infused Hall
}

C.MajorSpells = {
	[156718] = true, -- Bone Necrosis Burst, Shadowmoon Burial Grounds
	[156776] = true, -- Void Tear, Shadowmoon Burial Grounds
	[398150] = true, -- Domination, Shadowmoon Burial Grounds
	[398206] = true, -- Death Shock, Shadowmoon Burial Grounds
	[152964] = true, -- Void Pulse, Shadowmoon Burial Grounds
	[198595] = true, -- Thundering Missile, Halls of Valor
	[396812] = true, -- Arcane Shock, Academy
	[397889] = true, -- Tidal Eruption, Temple of the Jade Serpent
	[395859] = true, -- Wandering Screech, Temple of the Jade Serpent
	[397878] = true, -- Enchanted Ripple, Temple of the Jade Serpent
	[392451] = true, -- Flash Fire, Ruby Life Pools
	[392452] = true, -- Flash Fire, Ruby Life Pools
	[385536] = true, -- Dance of Flames, Ruby Life Pools
	[372087] = true, -- Fiery Sprint, Ruby Life Pools
	[372735] = true, -- Earth Split, Ruby Life Pools
	[388283] = true, -- Eruption, Blockade Battle
	[387440] = true, -- Blasphemous Roar, Blockade Battle
	[386012] = true, -- Storm Arrow, Blockade Battle
	[374720] = true, -- Devouring Stomp, Azure Vault
	[372222] = true, -- Arcane Cleave, Azure Vault
	[386546] = true, -- Lucid Nemesis, Azure Vault
	[387564] = true, -- Arcane Steam, Azure Vault
	-- S2
	[88186] = true, -- Mist Form, Vortex Pinnacle
	[87779] = true, -- Greater Heal, Vortex Pinnacle
	[87761] = true, -- Inspire, Vortex Pinnacle
	[87762] = true, -- Lightning Lash, Vortex Pinnacle
	[87618] = true, -- Static Grasp, Vortex Pinnacle
	[413385] = true, -- Overload Grounding Field, Vortex Pinnacle
	[411001] = true, -- Deadly Current, Vortex Pinnacle
	[410870] = true, -- Whirlwind, Vortex Pinnacle
	[411012] = true, -- Cold Breath, Vortex Pinnacle
	[388424] = true, -- Storm Fury, Infused Hall
	[391634] = true, -- Extreme Cold Freeze, Infused Hall
	[377341] = true, -- Tide Split, Infused Hall
	[374699] = true, -- Searing, Infused Hall
	[374563] = true, -- Dizziness, Infused Hall
	[388886] = true, -- Turbulence, Infused Hall
	[374339] = true, -- Demoralizing Roar, Infused Hall
	[374045] = true, -- Expulsion, Infused Hall
	[376171] = true, -- Soothing Tide, Infused Hall
	[265091] = true, -- G'huun's Gift, Underrot
	[369811] = true, -- Brutal Smash, Uldaman
	[369675] = true, -- Lightning Chain, Uldaman
	[369573] = true, -- Heavy Arrow, Uldaman
	[369411] = true, -- Sonic Burst, Uldaman
	[369409] = true, -- Cleave, Uldaman
	[369465] = true, -- Stone Hail, Uldaman
	[369466] = true, -- Stone Hail, Uldaman
	[369563] = true, -- Wild Cleave, Uldaman
	[226296] = true, -- Piercing Shard, Nest
	[202075] = true, -- Scorch, Nest
	[193585] = true, -- Binding, Nest
	[257397] = true, -- Healing Salve, Freehold
	[257426] = true, -- Backhand Smash, Freehold
	[257732] = true, -- Deafening Roar, Freehold
	[258777] = true, -- Sea Spray, Freehold
	[257784] = true, -- Frost Shock, Freehold
	[257736] = true, -- Thunderous Roar, Freehold
	[257737] = true, -- Thunderous Roar, Freehold
	[257899] = true, -- Painful Motivation, Freehold
	[265019] = true, -- Cleave, Underrot
	[278961] = true, -- Will Decay, Underrot
	[260894] = true, -- Spreading Corruption, Underrot
	[265540] = true, -- Corrupted Bile, Underrot
	[265542] = true, -- Corrupted Bile, Underrot
	[265089] = true, -- Dark Resurgence, Underrot
	[278755] = true, -- Wailing Despair, Underrot
	[266106] = true, -- Sonic Screech, Underrot
	[272609] = true, -- Mad Gaze, Underrot
	[265433] = true, -- Withering Curse, Underrot
	[382410] = true, -- Withering Arrow, Fernskin
	[367500] = true, -- Grinning Sneer, Fernskin
	[382555] = true, -- Furious Storm, Fernskin
	[382556] = true, -- Furious Storm, Fernskin
	[377950] = true, -- Greater Healing Turbulence, Fernskin
	[381470] = true, -- Eerie Totem, Fernskin
	[381694] = true, -- Decaying Senses, Fernskin
	[388060] = true, -- Stinking Breath, Fernskin
	[383385] = true, -- Rotting Surge, Fernskin
	[382172] = true, -- Necrotic Breath, Fernskin
	[384899] = true, -- Bone Arrow Rain, Fernskin
	[378282] = true, -- Molten Core, Nassarius
	[383651] = true, -- Molten Legion, Nassarius
	[375439] = true, -- Blazing Charge, Nassarius
	[395427] = true, -- Burning Roar, Nassarius
	[376186] = true, -- Bursting Squeeze, Nassarius
	[372223] = true, -- Healing Mud, Nassarius
	[373424] = true, -- Grounding Spear, Nassarius
	[376780] = true, -- Magma Shield, Nassarius
	-- S3
	[411994] = true, -- Time Erosion, Eternal Dawn
	[418200] = true, -- Eternal Burning, Eternal Dawn
	[411300] = true, -- Salted Fish Arrow Rain, Eternal Dawn
	[413607] = true, -- Erosion Volley, Eternal Dawn
	[417011] = true, -- Holy Light Spell, Eternal Dawn
	[169179] = true, -- 巨灵猛击，永茂林地
	-- TWW S1
	[76711] = true, -- 灼烧心智，格瑞姆巴托
	[451871] = true, -- 剧烈震颤，格瑞姆巴托
	[256957] = true, -- 防水甲壳，围攻伯拉勒斯
	[275826] = true, -- 强化怒吼，围攻伯拉勒斯
	[322938] = true, -- 收割精魂，塞茲仙林的迷雾
	[324776] = true, -- 木棘外壳，塞茲仙林的迷雾
	[326046] = true, -- 模拟抗性，塞茲仙林的迷雾
	[340544] = true, -- 再生鼓舞，塞茲仙林的迷雾
	[321828] = true, -- 肉饼蛋糕，塞茲仙林的迷雾
	[340160] = true, -- 辐光之息，塞茲仙林的迷雾
	[324293] = true, -- 刺耳尖啸，通灵战潮
	[338357] = true, -- 暴捶，通灵战潮
	[320596] = true, -- 深重呕吐，通灵战潮
	[327130] = true, -- 修复血肉，通灵战潮
	[328667] = true, -- 寒冰箭雨，通灵战潮
	[334749] = true, -- 排干体液，通灵战潮
	[335143] = true, -- 接骨，通灵战潮
	[338353] = true, -- 瘀液喷撒，通灵战潮
	[433841] = true, -- 毒液箭雨，回响之城
	[434793] = true, -- 共振弹幕，回响之城
	[434802] = true, -- 惊惧尖鸣，回响之城
	[448248] = true, -- 恶臭齐射，回响之城
	[443430] = true, -- 流丝缠缚，千丝之城
	[446086] = true, -- 虚空之波，千丝之城
	[452162] = true, -- 愈合之网，千丝之城
	[432520] = true, -- 暗影屏障，破晨号
	[450756] = true, -- 深渊嗥叫，破晨号
	[451097] = true, -- 流丝护壳，破晨号
	[429109] = true, -- 愈合金属，矶石宝库
	[429545] = true, -- 噤声齿轮，矶石宝库
	[445207] = true, -- 穿透哀嚎，矶石宝库
	[449455] = true, -- 咆哮恐惧，矶石宝库
}
