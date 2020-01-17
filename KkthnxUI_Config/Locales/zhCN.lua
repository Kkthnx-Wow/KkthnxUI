-- local MissingDesc = "The description for this module/setting is missing. Someone should really remind Kkthnx to do his job!"
local ModuleNewFeature = [[|TInterface\OptionsFrame\UI-OptionsFrame-NewFeatureIcon:0:0:0:0|t]] -- Used for newly implemented features.
-- local PerformanceIncrease = "|n|nDisabling this may slightly increase performance|r" -- For semi-high CPU options
-- local RestoreDefault = "|n|nRight-click to restore to default" -- For color pickers

local _G = _G

_G.KkthnxUIConfig["zhCN"] = {
	-- Menu Groups Display Names
	["GroupNames"] = {
		-- Let's Keep This In Alphabetical Order, Shall We?
		["ActionBar"] = "动作条",
		["Announcements"] = "公告",
		["Auras"] = "光环",
		["Automation"] = "自动操作",
		["Chat"] = "聊天",
		["DataBars"] = "数据条",
		["DataText"] = "数据文本",
		["Filger"] = "法术监视",
		["General"] = "常规",
		["Inventory"] = "存货",
		["Loot"] = "拾取",
		["Minimap"] = "小地图",
		["Misc"] = "杂项",
		["Nameplate"] = "姓名板",
		["Party"] = "小队",
		["PulseCooldown"] = "Pulse Cooldown",
		["QuestNotifier"] = "任务通告",
		["Raid"] = "团队",
		["Skins"] = "皮肤",
		["Tooltip"] = "鼠标提示",
		["UIFonts"] = "字体",
		["UITextures"] = "材质",
		["Unitframe"] = "单位框体",
		["WorldMap"] = "世界地图",
	},

	-- Actionbar Local
	["ActionBar"] = {
		["Cooldowns"] = {
			["Name"] = "显示冷却时间",
			["Desc"] = "在动作条和其他元素上显示冷却时间。",
		},

		["Count"] = {
			["Name"] = "显示物品数量",
			["Desc"] = "在动作条上显示你包里有多少物品。",
		},

		["DecimalCD"] = {
			["Name"] = "冷却时间不足3秒显示小数",
		},

		["DefaultButtonSize"] = {
			["Name"] = "主动作条按钮大小",
		},

		["DisableStancePages"] = {
			["Name"] = "禁用姿态页 (德鲁伊和潜行者)",
		},

		["Enable"] = {
			["Name"] = "启用动作条",
		},

		["EquipBorder"] = {
			["Name"] = "装备边框指示",
			["Desc"] = "为你装备的物品显示一个绿色的边框，并放到你的动作条上。|n|n例如，你把饰品放在动作条上将显示一个绿色边框。",
		},

		["FadeRightBar"] = {
			["Name"] = "渐隐右侧动作条1",
		},

		["FadeRightBar2"] = {
			["Name"] = "渐隐右侧动作条2",
		},

		["HideHighlight"] = {
			["Name"] = "隐藏高亮",
		},

		["Hotkey"] = {
			["Name"] = "显示热键",
		},

		["Macro"] = {
			["Name"] = "显示宏命令",
		},

		["MicroBar"] = {
			["Name"] = "显示系统菜单条",
		},

		["MicroBarMouseover"] = {
			["Name"] = "渐隐系统菜单条",
		},

		["OverrideWA"] = {
			["Name"] = "隐藏WeakAuras的冷却时间",
		},

		["RightButtonSize"] = {
			["Name"] = "右侧动作条按钮大小",
		},

		["StancePetSize"] = {
			["Name"] = "姿态和宠物条按钮大小",
		}
	},

	-- Announcements Local
	["Announcements"] = {
		["PullCountdown"] = {
			["Name"] = "通告倒计时 (/pc #)",
		},

		["SaySapped"] = {
			["Name"] = "通告被闷棍",
		},

		["Interrupt"] = {
			["Name"] = "通告打断施法",
		},

		["RareAlert"] = {
			["Name"] = "Announce Rares, Chests & War Supplies",
		},

		["ItemAlert"] = {
			["Name"] = "Announce Items Being Placed",
		}
	},

	-- Automation Local
	["Automation"] = {
		["AutoBubbles"] = {
			["Name"] = "自动切换聊天泡泡",
			["Desc"] = "切换聊天气泡取决于你的场合.如果你在一个副本或团队中,它会被关闭."
		},

		["AutoCollapse"] = {
			["Name"] = "自动折叠目标追踪器",
		},

		["AutoInvite"] = {
			["Name"] = "自动接受来自好友和公会成员的邀请",
		},

		["AutoDisenchant"] = {
			["Name"] = "按住'ALT'自动分解",
		},

		["AutoQuest"] = {
			["Name"] = "自动接续任务",
		},

		["AutoRelease"] = {
			["Name"] = "在战场和竞技场中自动释放灵魂",
		},

		["AutoResurrect"] = {
			["Name"] = "自动接受复活",
		},

		["AutoResurrectThank"] = {
			["Name"] = "当你被复活时,自动感谢",
		},

		["AutoReward"] = {
			["Name"] = "自动选择任务奖励",
		},

		["AutoSetRole"] = {
			["Name"] = "Auto Set Your Role In Groups",
		},

		["AutoTabBinder"] = {
			["Name"] = "仅使用TAB选择敌对玩家",
		},

		["BuffThanks"] = {
			["Name"] = "感谢玩家给的BUFF（仅开放世界）",
		},

		["BlockMovies"] = {
			["Name"] = "屏蔽你已看过的动画",
		},

		["DeclinePvPDuel"] = {
			["Name"] = "自动拒绝PVP决斗",
		},

		["WhisperInvite"] = {
			["Name"] = "自动邀请关键词",
		},
	},

	-- Bags Local
	["Inventory"] = {
		["AutoSell"] = {
			["Name"] = "自动出售灰色物品",
			["Desc"] = "当访问一个商贩时,自动出售灰色物品.",
		},

		["BagBar"] = {
			["Name"] = "显示背包条",
		},

		["BagBarMouseover"] = {
			["Name"] = "渐隐背包条",
		},

		["Enable"] = {
			["Name"] = "启用",
			["Desc"] = "启用/禁用 背包模块.",
		},

		["ClassRelatedFilter"] = {
			["Name"] = "过滤职业物品",
		},

		["ScrapIcon"] = {
			["Name"] = "Show Scrap Icon",
		},

		["UpgradeIcon"] = {
			["Name"] = "Show Upgrade Icon",
		},

		["QuestItemFilter"] = {
			["Name"] = "过滤任务物品",
		},

		["TradeGoodsFilter"] = {
			["Name"] = "过滤商品/消耗品",
		},

		["BagsWidth"] = {
			["Name"] = "背包宽度",
		},

		["BankWidth"] = {
			["Name"] = "银行宽度",
		},

		["DeleteButton"] = {
			["Name"] = "背包删除按钮",
		},

		["GatherEmpty"] = {
			["Name"] = "将空格收集到一个格中",
		},

		["IconSize"] = {
			["Name"] = "空格图标大小",
		},

		["ItemFilter"] = {
			["Name"] = "物品过滤中",
		},

		["ItemSetFilter"] = {
			["Name"] = "使用物品过滤器",
		},

		["ReverseSort"] = {
			["Name"] = "背包反向排序",
		},

		["ShowNewItem"] = {
			["Name"] = "Show New Item Glow",
		},

		["SpecialBagsColor"] = {
			["Name"] = "显示特殊背包颜色",
			["Desc"] = "显示为特殊背包的颜色:|n|n- |CFFABD473猎人|r 箭袋或弹药包|n- |CFF8787ED术士|r 灵魂碎片包|n- 附魔材料袋|n- 草药包"
		},

		["BagsiLvl"] = {
			["Name"] = "显示物品等级",
			["Desc"] = "显示可装备物品的物品等级",
		},

		["AutoRepair"] = {
			["Name"] = "自动修理",
		},
	},

	-- Auras Local
	["Auras"] = {
		["BuffSize"] = {
			["Name"] = "增益图标大小",
		},

		["BuffsPerRow"] = {
			["Name"] = "增益每行数量",
		},

		["DebuffSize"] = {
			["Name"] = "减益图标大小",
		},

		["DebuffsPerRow"] = {
			["Name"] = "减益每行数量",
		},

		["Enable"] = {
			["Name"] = "启用",
		},

		["Reminder"] = {
			["Name"] = "光环提醒 (怒吼/智力/毒药)",
		},

		["ReverseBuffs"] = {
			["Name"] = "增益向右排列",
		},

		["ReverseDebuffs"] = {
			["Name"] = "减益向右排列",
		},
	},

	-- Chat Local
	["Chat"] = {
		["Background"] = {
			["Name"] = "显示聊天背景",
		},

		["BackgroundAlpha"] = {
			["Name"] = "聊天背景透明度",
		},

		["BlockAddonAlert"] = {
			["Name"] = "屏蔽插件报警",
		},

		["ChatItemLevel"] = {
			["Name"] = "聊天框架中显示物品等级",
		},

		["Enable"] = {
			["Name"] = "启用聊天",
		},

		["EnableFilter"] = {
			["Name"] = "启用聊天过滤器",
		},

		["Fading"] = {
			["Name"] = "渐隐聊天",
		},

		["FadingTimeFading"] = {
			["Name"] = "渐隐聊天时间",
		},

		["FadingTimeVisible"] = {
			["Name"] = "渐隐聊天可视时间",
		},

		["Height"] = {
			["Name"] = "聊天栏高度",
		},

		["QuickJoin"] = {
			["Name"] = "快速加入消息",
			["Desc"] = "显示聊天内可点击的快速加入消息"
		},

		["ScrollByX"] = {
			["Name"] = "滚动 '#' 行",
		},

		["ShortenChannelNames"] = {
			["Name"] = "简写频道名称",
		},

		["TabsMouseover"] = {
			["Name"] = "渐隐聊天标签",
		},

		["WhisperSound"] = {
			["Name"] = "私聊提示音",
		},

		["Width"] = {
			["Name"] = "聊天栏宽度",
		},

	},

	-- Databars Local
	["DataBars"] = {
		["Enable"] = {
			["Name"] = "启用数据条",
		},

		["ExperienceColor"] = {
			["Name"] = "经验条颜色",
		},

		["Height"] = {
			["Name"] = "经验条高度",
		},

		["HonorColor"] = {
			["Name"] = "荣誉条颜色",
		},

		["MouseOver"] = {
			["Name"] = "渐隐数据条",
		},

		["RestedColor"] = {
			["Name"] = "精力充沛条颜色",
		},

		["Text"] = {
			["Name"] = "显示文本",
		},

		["TrackHonor"] = {
			["Name"] = "追踪荣誉",
		},

		["Width"] = {
			["Name"] = "数据条宽度",
		},

	},

	-- DataText Local
	["DataText"] = {
		["Battleground"] = {
			["Name"] = "战场信息",
		},

		["LocalTime"] = {
			["Name"] = "12小时制",
		},

		["System"] = {
			["Name"] = "顯示FPS和延遲",
		},

		["Time"] = {
			["Name"] = "小地图显示时间",
		},

		["Time24Hr"] = {
			["Name"] = "24小时制",
		},
	},

	-- Filger Local
	["Filger"] = {
		["BuffSize"] = {
			["Name"] = "增益大小",
		},

		["CooldownSize"] = {
			["Name"] = "冷却时间大小",
		},

		["DisableCD"] = {
			["Name"] = "禁用冷却时间监视",
		},

		["DisablePvP"] = {
			["Name"] = "禁用PvP监视",
		},

		["Expiration"] = {
			["Name"] = "过期排序",
		},

		["Enable"] = {
			["Name"] = "启用法术监视",
		},

		["MaxTestIcon"] = {
			["Name"] = "最大测试图标",
		},

		["PvPSize"] = {
			["Name"] = "PvP图标大小",
		},

		["ShowTooltip"] = {
			["Name"] = "鼠标悬停显示提示",
		},

		["TestMode"] = {
			["Name"] = "测试模式",
		},
	},

	-- General Local
	["General"] = {
		["AutoScale"] = {
			["Name"] = "自动缩放",
		},
		["ColorTextures"] = {
			["Name"] = "着色 '大部分' KkthnxUI 边框",
		},

		["DisableTutorialButtons"] = {
			["Name"] = "禁用教程按钮",
		},

		["ShowTooltip"] = {
			["Name"] = "修复垃圾收集",
		},

		["FontSize"] = {
			["Name"] = "常规字体大小",
		},

		["HideErrors"] = {
			["Name"] = "隐藏 '一些' UI 错误提示",
		},

		["LagTolerance"] = {
			["Name"] = "自动延迟容忍",
		},

		["MoveBlizzardFrames"] = {
			["Name"] = "移动暴雪框架",
		},

		["ReplaceBlizzardFonts"] = {
			["Name"] = "替换 '一些' 暴雪字体",
		},

		["TexturesColor"] = {
			["Name"] = "材质颜色",
		},

		["Welcome"] = {
			["Name"] = "显示欢迎消息",
		},

		["NumberPrefixStyle"] = {
			["Name"] = "单位框体数字前缀样式",
		},

		["PortraitStyle"] = {
			["Name"] = "单位框体头像样式",
		},
	},

	-- Loot Local
	["Loot"] = {
		["AutoConfirm"] = {
			["Name"] = "自动确认拾取信息",
		},

		["AutoGreed"] = {
			["Name"] = "自动 贪婪/分解 绿色物品",
		},

		["Enable"] = {
			["Name"] = "启用拾取",
		},

		["FastLoot"] = {
			["Name"] = "更快的自动拾取",
		},

		["GroupLoot"] = {
			["Name"] = "启用团队拾取",
		},
	},

	-- Minimap Local
	["Minimap"] = {
		["Calendar"] = {
			["Name"] = "显示日历",
		},

		["Enable"] = {
			["Name"] = "启用小地图",
		},

		["ResetZoom"] = {
			["Name"] = "重置小地图缩放",
		},

		["ResetZoomTime"] = {
			["Name"] = "重置缩放时间",
		},

		["ShowRecycleBin"] = {
			["Name"] = "显示回收站",
		},

		["Size"] = {
			["Name"] = "小地图大小",
		},

		["BlipTexture"] = {
			["Name"] = "信号图标样式",
			["Desc"] = "更改小地图上的小队等图标样式",
		},

		["LocationText"] = {
			["Name"] = "Location Text Style",
			["Desc"] = "Change settings for the display of the location text that is on the minimap.",
		},
	},

	-- Miscellaneous Local
	["Misc"] = {
		["AFKCamera"] = {
			["Name"] = "AFK 镜头",
		},

		["ColorPicker"] = {
			["Name"] = "增强拾色器",
		},

		["EnhancedFriends"] = {
			["Name"] = "增强着色 (好友/公会 +)",
		},

		["GemEnchantInfo"] = {
			["Name"] = "角色/检查 宝石/附魔 信息",
		},

		["ItemLevel"] = {
			["Name"] = "显示 角色/观察 物品等级信息",
		},

		["KillingBlow"] = {
			["Name"] = "显示你的击杀信息",
		},

		["PvPEmote"] = {
			["Name"] = "当你击杀时自动发送表情",
		},

		["ShowWowHeadLinks"] = {
			["Name"] = "在任务日志框体上显示 Wowhead 链接",
		},

		["SlotDurability"] = {
			["Name"] = "显示耐久度百分比",
		},

		["EnchantmentScroll"] = {
			["Name"] = "Create Enchantment Scrolls With A Single Click"

		},

		["ImprovedStats"] = {
			["Name"] = "Display Character Frame Full Stats"

		},

		["NoTalkingHead"] = {
			["Name"] = "Remove And Hide The TalkingHead Frame"

		}
	},

	-- Nameplates Local
	["Nameplates"] = {
		["GoodColor"] = {
			["Name"] = "低仇恨颜色",
		},

		["NearColor"] = {
			["Name"] = "普通仇恨颜色",
		},

		["BadColor"] = {
			["Name"] = "高仇恨颜色",
		},

		["OffTankColor"] = {
			["Name"] = "OT颜色",
		},

		["Clamp"] = {
			["Name"] = "保留姓名板",
			["Desc"] = "在视野之外时,将姓名板留在屏幕顶部."
		},

		["ClassIcons"] = {
			["Name"] = "显示敌对玩家职业图标",
			["Desc"] = "显示敌对玩家的职业图标，以帮助更方便地确定他们是什么职业。 |n|n这对色盲的人很有帮助!"
		},

		["Combat"] = {
			["Name"] = "战斗中显示姓名板",
		},

		["Enable"] = {
			["Name"] = "启用姓名板",
		},

		["HealthValue"] = {
			["Name"] = "显示生命值",
		},

		["Height"] = {
			["Name"] = "姓名板高度",
		},

		["NonTargetAlpha"] = {
			["Name"] = "无目标时姓名板透明度",
		},

		["QuestInfo"] = {
			["Name"] = "显示任务信息图标",
		},

		["SelectedScale"] = {
			["Name"] = "选中的姓名版缩放",
		},

		["ShowFullHealth"] = {
			["Name"] = "显示完整生命值",
		},

		["Smooth"] = {
			["Name"] = "平滑显示条",
		},

		["TankMode"] = {
			["Name"] = "坦克模式",
		},

		["Threat"] = {
			["Name"] = "姓名板仇恨",
		},

		["TrackAuras"] = {
			["Name"] = "监视 增益/减益",
		},

		["Width"] = {
			["Name"] = "姓名板宽度",
		},

		["HealthbarColor"] = {
			["Name"] = "生命条颜色格式",
		},

		["LevelFormat"] = {
			["Name"] = "等级格式显示",
		},

		["TargetArrowMark"] = {
			["Name"] = "显示目标箭头",
		},

		["HealthFormat"] = {
			["Name"] = "生命值格式显示",
		},

		["ShowEnemyCombat"] = {
			["Name"] = "显示敌人战斗",
		},

		["ShowFriendlyCombat"] = {
			["Name"] = "显示友善战斗",
		},

		["LoadDistance"] = {
			["Name"] = "Load Distance",
		},

		["ShowHealPrediction"] = {
			["Name"] = "Show Health Prediction Bars",
		},

		["VerticalSpacing"] = {
			["Name"] = "Vertical Spacing",
		}
	},

	-- Skins Local
	["Skins"] = {
		["ChatBubbles"] = {
			["Name"] = "聊天泡泡皮肤",
		},

		["DBM"] = {
			["Name"] = "DeadlyBossMods皮肤",
		},

		["Details"] = {
			["Name"] = "Details皮肤",
		},

		["Hekili"] = {
			["Name"] = "Hekili皮肤",
		},

		["Skada"] = {
			["Name"] = "Skada皮肤",
		},

		["TalkingHeadBackdrop"] = {
			["Name"] = "显示TalkingHead背景",
		},

		["WeakAuras"] = {
			["Name"] = "WeakAuras皮肤",
		},
	},

	-- Unitframe Local
	["Unitframe"] = {
		["AdditionalPower"] = {
			["Name"] = "显示额外法力条 (|CFFFF7D0A德鲁伊|r)",
		},

		["CastClassColor"] = {
			["Name"] = "施法条显示职业颜色",
		},

		["CastReactionColor"] = {
			["Name"] = "施法条反转颜色",
		},

		["CastbarLatency"] = {
			["Name"] = "显示施法条延迟",
		},

		["Castbars"] = {
			["Name"] = "启用施法条",
		},

		["ClassResources"] = {
			["Name"] = "Show Class Resources",
		},

		["Stagger"] = {
			["Name"] = "Show |CFF00FF96Monk|r Stagger Bar",
		},

		["PlayerPowerPrediction"] = {
			["Name"] = "Show Player Power Prediction",
		},

		["CombatFade"] = {
			["Name"] = "渐隐单位框体",
		},

		["CombatText"] = {
			["Name"] = "显示战斗文本",
		},

		["DebuffHighlight"] = {
			["Name"] = "高亮显示生命值减益",
		},

		["DebuffsOnTop"] = {
			["Name"] = "目标框体上显示减益",
		},

		["Enable"] = {
			["Name"] = "启用单位框体",
		},

		["EnergyTick"] = {
			["Name"] = "显示能量节拍(德鲁伊/潜行者)",
		},

		["GlobalCooldown"] = {
			["Name"] = "显示全局冷却时间",
		},

		["HideTargetofTarget"] = {
			["Name"] = "隐藏目标的目标框体",
		},

		["OnlyShowPlayerDebuff"] = {
			["Name"] = "只显示你的减益",
		},

		["PlayerBuffs"] = {
			["Name"] = "显示玩家框体增益",
		},

		["PlayerCastbarHeight"] = {
			["Name"] = "玩家施法条高度",
		},

		["PlayerCastbarWidth"] = {
			["Name"] = "玩家施法条宽度",
		},

		["PortraitTimers"] = {
			["Name"] = "头像施法计时器",
		},

		["PvPIndicator"] = {
			["Name"] = "显示PVP监视器在 玩家 / 目标",
		},

		["ShowHealPrediction"] = {
			["Name"] = "显示治疗预读状态条",
		},

		["ShowPlayerLevel"] = {
			["Name"] = "显示玩家框体等级",
		},

		["ShowPlayerName"] = {
			["Name"] = "显示玩家框体名称",
		},

		["Smooth"] = {
			["Name"] = "平滑显示条",
		},

		["Swingbar"] = {
			["Name"] = "单位框体武器计时条",
		},

		["SwingbarTimer"] = {
			["Name"] = "单位框体武器计时条计时器",
		},

		["TargetCastbarHeight"] = {
			["Name"] = "目标施法条高度",
		},

		["TargetCastbarWidth"] = {
			["Name"] = "目标施法条宽度",
		},

		["TotemBar"] = {
			["Name"] = "显示图腾条",
		},

		["HealthbarColor"] = {
			["Name"] = "生命条颜色格式",
		},

		["PlayerHealthFormat"] = {
			["Name"] = "玩家生命值格式",
		},

		["PlayerPowerFormat"] = {
			["Name"] = "玩家能量值格式",
		},

		["TargetHealthFormat"] = {
			["Name"] = "目标生命值格式",
		},

		["TargetPowerFormat"] = {
			["Name"] = "目标能量值格式",
		},

		["TargetLevelFormat"] = {
			["Name"] = "目标等级格式",
		},
	},

	-- Arena Local
	["Arena"] = {
		["Castbars"] = {
			["Name"] = "显示施法条",
		},

		["Enable"] = {
			["Name"] = "启用竞技场",
		},

		["Smooth"] = {
			["Name"] = "平滑显示条",
		},
	},

	-- Boss Local
	["Boss"] = {
		["Castbars"] = {
			["Name"] = "显示施法条",
		},

		["Enable"] = {
			["Name"] = "启用Boss",
		},

		["Smooth"] = {
			["Name"] = "平滑显示条",
		},
	},

	-- Party Local
	["Party"] = {
		["Castbars"] = {
			["Name"] = "显示施法条",
		},

		["Enable"] = {
			["Name"] = "启用小队",
		},

		["HorizonParty"] = {
			["Name"] = "Horizontal Party Frames",
		},

		["PortraitTimers"] = {
			["Name"] = "头像施法计时器",
		},

		["ShowBuffs"] = {
			["Name"] = "显示小队增益",
		},

		["ShowHealPrediction"] = {
			["Name"] = "显示预读状态条",
		},

		["ShowPlayer"] = {
			["Name"] = "小队显示玩家",
		},

		["Smooth"] = {
			["Name"] = "平滑显示条",
		},

		["TargetHighlight"] = {
			["Name"] = "高亮显示目标",
		},

		["HealthbarColor"] = {
			["Name"] = "生命条颜色格式",
		},

		["PartyHealthFormat"] = {
			["Name"] = "小队生命值格式",
		},

		["PartyPowerFormat"] = {
			["Name"] = "小队能量值格式",
		},
	},

	["PulseCooldown"] = {
		["Enable"] = {
			["Name"] = "Enable PulseCooldown",
		},

		["HoldTime"] = {
			["Name"] = "How Long To Display",
		},

		["MinTreshold"] = {
			["Name"] = "Minimal Threshold Time",
		},

		["Size"] = {
			["Name"] = "Icon Size",
		},

		["Sound"] = {
			["Name"] = "Play Sound On Pulse",
		},
	},

	-- QuestNotifier Local
	["QuestNotifier"] = {
		["Enable"] = {
			["Name"] = "启用任务通告",
		},

		["QuestProgress"] = {
			["Name"] = "任务进度",
			["Desc"] = "在聊天窗口通告任务进度. 此项可能刷屏,尽量不要激怒队友!",
		},

		["OnlyCompleteRing"] = {
			["Name"] = "仅结束音",
			["Desc"] = "只在任务结束时播放声音"
		},
	},

	-- Raidframe Local
	["Raid"] = {
		["SpecRaidPos"] = {
			["Name"] = "Save Raid Posions Based On Specs",
		},

		["ShowTeamIndex"] = {
			["Name"] = "Show Group Number Team Index",
		},

		["ReverseRaid"] = {
			["Name"] = "Reverse Raid Frame Growth",
		},

		["HorizonRaid"] = {
			["Name"] = "Horizontal Raid Frames",
		},

		["NumGroups"] = {
			["Name"] = "Number Of Groups to Show",
		},

		["AuraDebuffIconSize"] = {
			["Name"] = "光环减益图标大小",
		},

		["AuraWatch"] = {
			["Name"] = "显示AuraWatch图标",
		},

		["AuraWatchIconSize"] = {
			["Name"] = "AuraWatch图标大小",
		},

		["AuraWatchTexture"] = {
			["Name"] = "AuraWatch材质颜色",
		},

		["Enable"] = {
			["Name"] = "启用团队框体",
		},

		["Height"] = {
			["Name"] = "团队框体高度",
		},

		["MainTankFrames"] = {
			["Name"] = "显示主坦克框体",
		},

		["ManabarShow"] = {
			["Name"] = "显示法力条",
		},

		["MaxUnitPerColumn"] = {
			["Name"] = "每行最多数量",
		},

		["RaidUtility"] = {
			["Name"] = "显示团队工具框体",
		},

		["ShowGroupText"] = {
			["Name"] = "显示玩家小队序号",
		},

		["ShowNotHereTimer"] = {
			["Name"] = "显示 离开/勿扰 状态",
		},

		["ShowRolePrefix"] = {
			["Name"] = "显示 治疗/坦克 角色",
		},

		["Smooth"] = {
			["Name"] = "平滑显示条",
		},

		["TargetHighlight"] = {
			["Name"] = "显示高亮的目标",
		},

		["Width"] = {
			["Name"] = "团队框体宽度",
		},

		["HealthbarColor"] = {
			["Name"] = "生命条颜色格式",
		},

		["RaidLayout"] = {
			["Name"] = "团队布局",
		},

		["GroupBy"] = {
			["Name"] = "团队框体排序",
		},

		["HealthFormat"] = {
			["Name"] = "生命值格式显示",
		},
	},

	-- Worldmap Local
	["WorldMap"] = {
		["AlphaWhenMoving"] = {
			["Name"] = "移动时透明度",
		},

		["Coordinates"] = {
			["Name"] = "显示 玩家/鼠标 坐标",
		},

		["FadeWhenMoving"] = {
			["Name"] = "移动时渐隐世界地图",
		},

		["MapScale"] = {
			["Name"] = "世界地图缩放",
		},

		["SmallWorldMap"] = {
			["Name"] = "显示更小的世界地图",
		},

		["WorldMapPlus"] = {
			["Name"] = "显示增强功能",
		},
	},

	-- Tooltip Local
	["Tooltip"] = {
		["AzeriteArmor"] = {
			["Name"] = "Show Azerite Tooltip Traits",
		},

		["ClassColor"] = {
			["Name"] = "按品质显示边框颜色",
		},

		["CombatHide"] = {
			["Name"] = "战斗中隐藏鼠标提示",
		},

		["Cursor"] = {
			["Name"] = "跟随鼠标",
		},

		["FactionIcon"] = {
			["Name"] = "显示阵营图标",
		},

		["HideJunkGuild"] = {
			["Name"] = "缩写公会名称",
		},

		["HideRank"] = {
			["Name"] = "隐藏公会等级",
		},

		["HideRealm"] = {
			["Name"] = "按SHIFT显示服务器名",
		},

		["HideTitle"] = {
			["Name"] = "隐藏单位标题",
		},

		["Icons"] = {
			["Name"] = "物品图标",
		},

		["ShowIDs"] = {
			["Name"] = "显示鼠标提示ID",
		},

		["LFDRole"] = {
			["Name"] = "显示角色分配图标",
		},

		["SpecLevelByShift"] = {
			["Name"] = "按SHIFT显示 专精/物品等级",
		},

		["TargetBy"] = {
			["Name"] = "显示单位关注者",
		},
	},

	-- Fonts Local
	["UIFonts"] = {
		["ActionBarsFonts"] = {
			["Name"] = "动作条",
		},

		["AuraFonts"] = {
			["Name"] = "光环",
		},

		["ChatFonts"] = {
			["Name"] = "聊天",
		},

		["DataBarsFonts"] = {
			["Name"] = "数据条",
		},

		["DataTextFonts"] = {
			["Name"] = "数据文字",
		},

		["FilgerFonts"] = {
			["Name"] = "Filger 字体",
		},

		["GeneralFonts"] = {
			["Name"] = "常规",
		},

		["InventoryFonts"] = {
			["Name"] = "存货",
		},

		["MinimapFonts"] = {
			["Name"] = "小地图",
		},

		["NameplateFonts"] = {
			["Name"] = "姓名板",
		},

		["QuestTrackerFonts"] = {
			["Name"] = "任务追踪器",
		},

		["SkinFonts"] = {
			["Name"] = "皮肤",
		},

		["TooltipFonts"] = {
			["Name"] = "鼠标提示",
		},

		["UnitframeFonts"] = {
			["Name"] = "单位框体",
		},
	},

	-- Textures Local
	["UITextures"] = {
		["DataBarsTexture"] = {
			["Name"] = "数据条",
		},

		["FilgerTextures"] = {
			["Name"] = "法术监视",
		},

		["GeneralTextures"] = {
			["Name"] = "常规",
		},

		["LootTextures"] = {
			["Name"] = "拾取",
		},

		["NameplateTextures"] = {
			["Name"] = "姓名板",
		},

		["QuestTrackerTexture"] = {
			["Name"] = "任务追踪器",
		},

		["SkinTextures"] = {
			["Name"] = "皮肤",
		},

		["TooltipTextures"] = {
			["Name"] = "鼠标提示",
		},

		["UnitframeTextures"] = {
			["Name"] = "单位框体",
		},

		["HealPredictionTextures"] = {
			["Name"] = "治疗预测",
		},
	}
}
