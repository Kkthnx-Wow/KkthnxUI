local K, C, L = unpack(select(2, ...))
if (GetLocale() ~= "zhCN") then return end

-- Localization for zhCN clients

L.AFKScreen = {
	NoGuild = "无公会",
	Sun = "星期天",
	Mon = "星期一",
	Tue = "星期二",
	Wed = "星期三",
	Thu = "星期四",
	Fri = "星期五",
	Sat = "星期六",
	Jan = "一月",
	Feb = "二月",
	Mar = "三月",
	Apr = "四月",
	May = "五月",
	Jun = "六月",
	Jul = "七月",
	Aug = "八月",
	Sep = "九月",
	Oct = "十月",
	Nov = "十一月",
	Dec = "十二月"
}

L.Announce = {
	FPUse = "%s使用了%s.",
	Interrupted = INTERRUPTED.."%s的\124cff71d5ff\124Hspell:%d:0\124h[%s]\124h\124r!",
	PCAborted = "中止开怪!",
	PCGo = "冲啊!",
	PCMessage = "嘲讽%s倒计时%s..",
	Recieved = "接收自",
	Sapped = "被闷棍",
	SappedBy = "被闷棍:",
	SSThanks = "感谢"
}

L.Auras = {
	MoveBuffs = "移动增益",
	MoveDebuffs = "移动减益",
}

-- Merchant Localization
L.Merchant = {
	NotEnoughMoney = "您没有足够的金钱修理装备!",
	RepairCost = "您的装备修理完毕，共花费",
	SoldTrash = "您的垃圾已经处理完毕，共获得"
}

-- Bindings Localization
L.Bind = {
	Binding = "按键绑定",
	Cleared = "所有按键绑定已被清除",
	Discard = "所有按键绑定的新设置已被取消.",
	Instruct = "将您的鼠标箭头放置在任何需要绑定的动作条空格上，然后按下需要绑定的按键。按下空格键或单击鼠标右键来清除当前动作条空格的按键绑定.",
	Key = "按键",
	NoSet = "未设置按键绑定",
	Saved = "所有按键绑定已被保存.",
	Trigger = "触发"
}

-- Chat Localization
L.Chat = {
	AFK = "|cffff0000[AFK]|r",
	BigChatOff = "大聊天框已停用",
	BigChatOn = "大聊天框已启用",
	DND = "|cffe7e716[DND]|r",
	Guild = "公",
	GuildRecruitment = "招募",
	Instance = "随机",
	InstanceLeader = "随机队长",
	LocalDefense = "本地防御",
	LookingForGroup = "寻求组队",
	Officer = "官",
	Party = "队",
	PartyLeader = "队长",
	Raid = "团",
	RaidLeader = "团长",
	RaidWarning = "团队警告",
}

-- ToggleButton Localization
L.ToggleButton = {
	Config = "打开KkthnxUI设置",
	Functions = "按键功能:",
	LeftClick = "鼠标左键:",
	MiddleClick = "鼠标中键:",
	MoveUI = "移动框体",
	Recount = "打开/关闭Recount",
	RightClick = "鼠标右键:",
	ShiftClick = "Shift+鼠标左键:",
	Skada = "打开/关闭Skada",
}

-- Cooldowns
L.Cooldowns = {
	Cooldowns = "冷却:",
	CombatRes = "战复",
	CombatResRemainder = "战复:",
	NextTime = "下次:"
}

-- DataBars Localization
L.DataBars = {
	ArtifactClick = "鼠标左键:神器面板",
	ArtifactRemaining = "|cffe6cc80剩余:%s|r",
	HonorLeftClick = "|cffcacaca鼠标左键：PVP面板|r",
}

-- DataText Localization
L.DataText = {
	Bandwidth = "带宽:",
	BaseAssault = "已袭击基地:",
	BaseDefend = "已保卫基地:",
	CartControl = "控制矿车:",
	Damage = "伤害:",
	DamageDone = "伤害总计:",
	Death = "死亡:",
	DemolisherDestroy = "摧毁工程车:",
	Download = "下载",
	FlagCapture = "已获得旗帜:",
	FlagReturn = "已归还旗帜:",
	GateDestroy = "已攻破大门:",
	GraveyardAssault = "已攻陷墓地:",
	GraveyardDefend = "已防御墓地:",
	Healing = "治疗: ",
	HealingDone = "治疗总计:",
	HomeLatency = "本地延迟:",
	Honor = "荣誉:",
	HonorableKill = "荣誉击杀:",
	HonorGained = "获得荣誉:",
	KillingBlow = "连杀计数:",
	MemoryUsage = "（按住shift）已使用内存",
	OrbPossession = "拥有宝珠:",
	SavedDungeons = "已锁定地下城",
	SavedRaids = "已锁定团队副本",
	StatsFor = "Stats for ",
	TotalCPU = "总CPU：",
	TotalMemory = "总内存:",
	TowerAssault = "已攻陷防御塔:",
	TowerDefend = "已防守防御塔:",
	VictoryPts = "胜利点数:"
}

-- headers
L.Install = {
	Header1 = "欢迎使用",
	Header2 = "1. 基本",
	Header3 = "2. 角色框体",
	Header4 = "3. 功能",
	Header5 = "4. 您需要了解以下信息！",
	Header6 = "5. 命令",
	Header7 = "6. 结束",
	Header8 = "1. 基本设置",
	Header9 = "2. 社交",
	Header10 = "3. 框体",
	Header11 = "4. 成功！",
	InitLine1 = "感谢您选择KkthnxUI！",
	InitLine2 = "接下来您将被引导安装本UI，只有很少的几个步骤。在每一个步骤您可以选择接受或者跳过我们的一些插件预设。",
	InitLine3 = "您还可以获得简单的教程来了解KkthnxUI的一些功能。",
	InitLine4 = "点击“教程”按钮将会向您介绍本UI，或者直接点击“安装”按钮来略过这一步。",
	Step1Line1 = "这些步骤会加载适合KkthnxUI的系统设置。",
	Step1Line2 = "第一步将加载基本设置。",
	Step1Line3 = "这一步我们|cffff0000强烈建议|r您加载这些基本设置，当然您也可以只加载部分设置。",
	Step1Line4 = "点击“继续”来加载设置，或者点击“忽略”如果您想跳过这一步。",
	Step2Line0 = "检测到您已经安装有另一个聊天窗口插件。我们将跳过这一步。请点击“忽略”继续进行安装。",
	Step2Line1 = "第二步将应用合适的聊天窗口设置。",
	Step2Line2 = "如果您是新用户，我们建议您完成这一步。如果您是老用户，您可以跳过这一步。",
	Step2Line3 = "在应用设置后，您的聊天字体大小可能会很大，这很正常。当您结束安装后字体大小会恢复正常。 It will revert back to normal when you finish with the installation.",
	Step2Line4 = "点击“继续”来加载设置，或者点击“忽略”如果您想跳过这一步。",
	Step3Line1 = "第三步和最后一步将会加载默认的框体位置。",
	Step3Line2 = "我们|cffff0000强烈建议|r新用户完成这一步.",
	Step3Line3 = "",
	Step3Line4 = "点击“继续”来加载设置，或者点击“忽略”如果您想跳过这一步。",
	Step4Line1 = "安装完成。",
	Step4Line2 = "请点击“结束”按钮来重载界面。",
	Step4Line3 = "",
	Step4Line4 = "享受KkthnxUI吧！欢迎与我们在 Discord @ |cff748BD9discord.gg/Kjyebkf|r 上交流",
	ButtonTutorial = "教程",
	ButtonInstall = "安装",
	ButtonNext = "下一步",
	ButtonSkip = "忽略",
	ButtonContinue = "继续",
	ButtonFinish = "结束",
	ButtonClose = "关闭",
	Complete = "安装完成"
}

-- tutorial 1
L.Tutorial = {
	Step1Line1 = "本简易教程将向您展示KkthnxUI的一些功能。",
	Step1Line2 = "在使用本UI前您首先需要了解一些基本点。",
	Step1Line3 = "KkthnxUI的安装器是区分角色的。虽然有些设置是全帐号通用的，在每个新角色开始使用前都需要进行一次安装操作。安装界面会在您登录新角色时自动弹出。此外，一些给“强力”用户使用的选项可以在/KkthnxUI/Config/Settings.lua中找到，而普通玩家也可以在在游戏中输入/KkthnxUI来调取设置界面。",
	Step1Line4 = "我们所说的“强力”玩家是有一定高级计算机知识的玩家（比如LUA编辑），普通玩家一般不具有这一能力，因此我们建议普通玩家在游戏中直接使用设置界面（/KkthnxUI）来对自定义KkthnxUI。",
	Step2Line1 = "KkthnxUI包括一个内置的oUF插件（作者：Haste）。这一插件是屏幕上所有角色框体，增益和减益以及职业资源条的基础。",
	Step2Line2 = "您可以访问wowinterface.com并搜索oUF来获得更多关于它的信息。",
	Step2Line3 = "您可以通过输入/moveui来很方便地移动各框体位置。",
	Step2Line4 = "",
	Step3Line1 = "KkthnxUI对魔兽世界原始界面进行了重新设计。不多也不少刚刚好。基本上在原始界面上您能看到的功能在KkthnxUI中也能找到。此外，KkthnxUI还有一些原始界面中没有的功能，比如自动卖垃圾及自动整理背包。",
	Step3Line2 = "并不是每个玩家都喜欢使用比如伤害统计、BOSS模块、仇恨监视等类型的插件，我们深知这一点。KkthnxUI的设计理念是将其发展为所有职业、所有角色、所有专精、所有游戏方式、所有玩家品味都适合的UI。 这就是为什么KkthnxUI是目前最受欢迎的UI之一。它适合所有人的游戏方式并有很高的可定制性。它也是一款很好的启蒙UI来让初学者们制作自己的UI。自2012年以来，很多玩家将KkthnxUI作为他们自制UI的基础。",
	Step3Line3 = "玩家们可以访问我们的网站或访问www.wowinterface.com来获得更多的模块和功能",
	Step3Line4 = "",
	Step4Line1 = "鼠标指针移至下方动作条上侧或右侧动作条下侧可以更改动作条数量。请点击聊天框右下角的按钮复制聊天窗口文字。",
	Step4Line2 = "80%的状态信息都可以点击打开相应窗口。右键点击好友和公会信息条也有附加功能。",
	Step4Line3 = "一些下拉菜单也被实现了。右键点击背包右上角的X可以显示背包装备情况，右键点击小地图可以调取微型菜单。",
	Step4Line4 = "",
	Step5Line1 = "最后，KkthnxUI还有一些有用的命令可以使用。命令列表如下。",
	Step5Line2 = "/moveui 允许您自由移动很多框体。 /rl 重载界面。",
	Step5Line3 = "/tt 允许您向目标发送密语。 /rc 开始团队检查。 /rd 解散队伍或团队。 /ainv 自动邀请向您发送密语的玩家。 (/ainv off) 关闭自动邀请功能。",
	Step5Line4 = "/gm 打开帮助界面。 /install or /tutorial 加载安装界面。 ",
	Step6Line1 = "教程已经结束。您可以通过输入/tutorial在以后重新调取教程。",
	Step6Line2 = "我建议您查看一下config/config.lua，或输入/KkthnxUI来自定义您理想中的UI。",
	Step6Line3 = "如果您想继续未完成的安装步骤或重置所有设置，您可以继续点击安装按钮！",
	Step6Line4 = "",
	Message1 = "技术支持请访问https://github.com/Kkthnx.",
	Message2 = "您可以右键小地图以打开微型菜单。",
	Message3 = "您可以输入/kb以快速绑定快捷键。",
	Message4 = "您可以输入/focus将当前目标设置为焦点。我们建议您建立相应的宏来使用这项功能。",
	Message5 = "鼠标移动至聊天窗口右下角后会有按钮显示，点击它可以复制聊天窗口内的文字。",
	Message6 = "如果您在使用过程中遇到问题，请关闭除KkthnxUI外的所有插件。请记住KkthnxUI是一个全界面替换插件，您不可以同时运行另一个具有类似功能的插件。",
	Message7 = "您可以右键点击聊天窗口标签并进入设置界面来设置此标签下显示哪些频道的聊天内容。",
	Message8 = "您可以使用/resetui命令来重置所有框体位置。您还可以使用/moveui命令并右键点击某个框体来重置其位置。",
	Message9 = "您需要按住alt键并拖动技能来改变其在动作条中的位置。您可以在动作条设置中更改按键。",
	Message10 = "在鼠标提示设置中启用物品等级功能，之后您将可以在鼠标提示中看到其他玩家的平均装备等级。"
}

-- AutoInvite Localization
L.Invite = {
	Enable = "启用自动邀请",
	Disable = "禁用自动邀请"
}

-- Info Localization
L.Info = {
	Disabnd = "解散团队...",
	Duel = "已拒绝决斗请求自",
	Errors = "没有错误.",
	Invite = "已接受组队邀请自",
	NotInstalled = " 未安装.",
	PetDuel = "已拒绝宠物决斗请求自",
	SettingsALL = "输入/settings all来加载全局设置.",
	SettingsDBM = "输入/settings dbm来加载DBM设置.",
	SettingsMSBT = "输入/settings msbt来加载MSBT设置.",
	SettingsSKADA = "输入/settings skada来加载Skada设置.",
	SkinDisabled1 = "插件",
	SkinDisabled2 = "皮肤已禁用."
}

-- Loot Localization
L.Loot = {
	Announce = "通告",
	Cannot = "无法roll点",
	Chest = ">> 拾取自宝箱",
	Fish = "钓鱼获得",
	Monster = ">> 拾取自",
	Random = "随机玩家",
	Self = "个人拾取",
	ToGuild = " 公会",
	ToInstance = " 随机队伍",
	ToParty = " 队伍",
	ToRaid = " 团队",
	ToSay = " 说"
}

-- Mail Localization
L.Mail = {
	Complete = "全部结束。",
	Messages = "邮件",
	Need = "需要邮箱.",
	Stopped = "已停止.背包已满.",
	Unique = "已停止.在背包或银行中已有拾取唯一的相同物品."
}

-- World Map Localization
L.Map = {
	Fog = "战争迷雾"
}

-- FarmMode Minimap
L.Minimap = {
	FarmModeOn = "采集模式开启",
	FarmModeOff = "采集模式关闭"
}

-- Misc Localization
L.Misc = {
	BuyStack = "Alt左键批量购买",
	Collapse = "The Collapse",
	CopperShort = "|cffeda55fC|r",
	GoldShort = "|cffffd700G|r",
	SilverShort = "|cffc7c7cfS|r",
	TriedToCall = "%s: %s 尝试调用保护函数 '%s'.",
	UIOutdated = "KkthnxUI版本已过期。您可以从Curse.com上下载最新版本。安装Curse App可以自动更新！",
	Undress = "一键脱光"
}

L.Popup = {
	Armory = "英雄榜",
	BlizzardAddOns = "您的一个插件禁用了Blizzard_CompactRaidFrames插件。这可能会引发错误或其他情况。这个插件将被重新启用。",
	BoostUI = "|cffff0000警告|r |n|n这将会通过降低图像质量来优化性能，请在您有|cffff0000FPS|r issues!|r问题时再点击接受！",
	DisableUI = "KkthnxUI在这一分辨率上可能不会正常工作，您想禁用KkthnxUI吗? （如果您想试试其他分辨率请取消）",
	DisbandRaid = "您确定您想解散队伍吗？",
	FixActionbars = "您的动作条有一些问题。您想重载界面来修复问题吗？",
	InstallUI = "感谢您选择|cff3c9bedKkthnxUI|r! |n|n请接受安装来加载设置。",
	ReloadUI = "安装已经完成。请点击“接受”按钮来重载界面。祝您使用|cff3c9bedKkthnxUI|r愉快。|n|n请访问我的GitHub主页|cff3c9bedwww.github.com/kkthnx|r.",
	ResetUI = "您确定您想重置|cff3c9bedKkthnxUI|r的设置吗?",
	ResolutionChanged = "我们检测到您的魔兽世界客户端的分辨率被改变。我们强烈建议您重启游戏。您想继续吗？",
	SettingsAll = "|cffff0000警告|r |n|n这将替换所有被支持插件的设置为|cff3c9bedKkthnxUI|r默认设置。如果您没有安装被支持的插件，这一功能不会对其他插件产生影响。",
	SettingsBW = "需要改变BigWigs各元素的位置。",
	SettingsDBM = "需要改变|cff3c9bedDBM|r计时条的位置。",
}

-- Raid Utility Localization
L.Raid = {
	UtilityDisband = "解散团队",
	DisbandRaid = "您确定您想要解散团队？"
}

-- Tooltip Localization
L.Tooltip = {
	AchievementComplete = "您的状态:已完成",
	AchievementIncomplete = "您的状态:未完成",
	AchievementStatus = "您的状态:",
	ItemCount = "物品数量:",
	ItemID = "物品ID:",
	SpellID = "法术ID:"
}

L.WatchFrame = {
	WowheadLink = "Wowhead链接"
}

L.Welcome = {
	Line1 = "欢迎使用|cff3c9bedKkthnxUI|r v",
	Line2 = "",
	Line3 = "输入/cfg打开设置界面，或访问www.github.com/kkthnx|r",
	Line4 = "",
	Line5 = "一些常见问题可以输入/uihelp来查看。"
}

L.Zone = {
	ArathiBasin = "Arathi Basin",
	Gilneas = "The Battle for Gilneas"
}

L.SlashCommand = {
	Help = {
		"",
		"|cff3c9bed可用命令:|r",
		"--------------------------",
		"/rl - 重载界面。",
		"/rc - 团队检查。",
		"/gm - 打开GM窗口。",
		"/rd - 解散队伍或团队。",
		"/toraid - 转换为队伍或团队。",
		"/teleport - 传送至随机副本。",
		"/spec, /ss - 切换专精。",
		"/frame - 暂无说明。",
		"/farmmode - 小地图变大。",
		"/moveui - 允许自由移动框体。",
		"/resetui - 加载默认设置。",
		"/resetconfig - 重置KkthnxUI_Config设置。",
		"/settings 插件名称(msbt, dbm, skada, all) - 加载msbt，dbm，skada，或以上所有插件的默认设置。",
		"/pulsecd - 冷却模块测试。",
		"/tt - 密语目标。",
		"/ainv - 启用自动邀请。",
		"/cfg - 打开设置界面。",
		"/patch - 显示游戏版本信息",
		"",
		"|cff3c9bed可用隐藏功能:|r",
		"--------------------------",
		"右键点击小地图打开系统微型菜单。",
		"中键点击小地图打开跟踪菜单。",
		"左键点击经验条打开声望面板。",
		"左键点击神器能量条打开神器面板。",
		"按住Alt在鼠标提示上显示玩家装备等级和专精。",
		"按住并滚动鼠标滚轮直接显示聊天窗口最后一行。",
		"复制按钮在聊天窗口右下方。",
		"中键点击复制按钮自动roll点。",
	}
}