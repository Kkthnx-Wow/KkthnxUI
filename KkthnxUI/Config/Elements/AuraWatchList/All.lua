local K, _, L = unpack(select(2, ...))
local Module = K:GetModule("AurasTable")
--[[
>>> When adding custom, pay attention to the format, pay attention to commas, pay attention to letter case<<<
The settings below ALL are common settings for all professions. For other situations, please add them under your profession. When you add, pay attention to whether it is repeated.
Each group represents:
Player Aura is a small buff group on his avatar, used to monitor those less important buffs;
Special Aura, is the larger buff group on your profile picture, used to monitor the slightly important buff;
Target Aura, is the buff group on the target avatar, used to monitor the debuff you need in the cycle;
Focus Aura is the buff group of the focus, used to monitor the buff and debuff of the focus target;
Spell Cooldown is a cooling time monitoring group, used to monitor jewelry, rings, skill CDs, etc.;
Enchant Aura is a buff group triggered by various ethnic skills, potions, and accessories;
Raid Buff is a group of important buffs of the team, used to monitor bloodthirsty, aura, team damage reduction, etc.;
Raid Debuff, a debuff group that appears in team battles, is used to monitor roll calls that appear in battles, etc.;
Warnings are buffs and debuffs that need to be paid attention to on the target. They can be used to monitor the vulnerability of the BOSS, the opponent's PVP abilities, and so on.

Meaning of number:
AuraID, supports BUFF and DEBUFF, when it is triggered in the game, please move your mouse to check the ID, or query the database yourself;
SpellID is only used to monitor the CD of the skill. You can see the ID by directly clicking on the skill. In most cases, it is different from the BUFF/DEBUFF ID after it is triggered;
ItemID, CD used to monitor items, such as Hearthstone, etc.;
SlotID, the cooling time of each part of the equipment bar, commonly used are 11/12 rings, 6 belts, 15 cloaks, and 13/14 accessories column (only active accessories);
TotemID, monitor the duration of the totem, the monk’s Xuan Niu is the number 1 totem, and the shaman 1-4 corresponds to 4 totems;
UnitID is the target you want to monitor. It supports pet pet, player's own player, target target and focus;

Various filtering methods:
Caster is the releaser of the spell. If you do not indicate it, anyone who releases the spell will be monitored, such as hunter's mark, elemental curse, etc.;
	Stack is the number of layers of some spells. If it is not marked, the whole process will be monitored. If it is marked, it will only be displayed after reaching the number of layers. For example, DK blood charge will only be prompted after 10 layers;
	Value, enabled when it is true, used to monitor specific values ​​of BUFF/DEBUFF, such as priest’s shield, DK’s blood shield, etc.;
	Timeless, for example, Shaman’s Lightning Shield, because it lasts for 1 hour, there is no need to monitor the time all the time. When Timeless is enabled, only the number of layers is monitored;
	Combat, when activated, the buff will only be monitored during combat, such as hunter's sniper training, shaman's lightning shield;
	Text, when enabled, it will be reminded with text under the BUFF icon, and the priority is lower than Value. For example, you can use this text to remind you when you need to get out of the crowd in a BUFF;
	Flash, when enabled, the icon will be highlighted in a circle;

	Instructions for use of the built-in CD:
	{IntID = 208052, Duration = 30, ItemID = 132452}, - Severs’s secret
	{IntID = 98008, Duration = 30, OnSuccess = true, UnitID = "all"}, - Soul Link
	IntID, the spell or skill ID when the timing bar is triggered;
	Duration, the duration of the custom timing bar;
	ItemID, the name displayed on the timing bar, if it is not filled in, the Buff name when triggered will be used directly;
	OnSuccess, the trigger used to monitor the successful casting of the skill, and the timing bar will be activated only when the skill is successfully cast. If you don’t fill it in, the timing bar will be triggered when you get the spell aura;
	UnitID, used to filter the source of the target spell, the default is the player. If set to all, all members of the team/team will be monitored.
	]]

-- 全职业的相关监控
local list = {
	["Enchant Aura"] = {	-- 附魔及饰品组
		-- 种族天赋
		{AuraID = 26297, UnitID = "player"},	-- 狂暴 巨魔
		{AuraID = 20572, UnitID = "player"},	-- 血性狂怒 兽人
		{AuraID = 33697, UnitID = "player"},	-- 血性狂怒 兽人
		{AuraID = 292463, UnitID = "player"},	-- 帕库之拥 赞达拉
		-- 9.0药水
		{AuraID = 307159, UnitID = "player"},	-- 幽魂敏捷药水
		{AuraID = 307162, UnitID = "player"},	-- 幽魂智力药水
		{AuraID = 307163, UnitID = "player"},	-- 幽魂耐力药水
		{AuraID = 307164, UnitID = "player"},	-- 幽魂力量药水
		{AuraID = 307494, UnitID = "player"},	-- 强化驱魔药水
		{AuraID = 307495, UnitID = "player"},	-- 幻影火焰药水
		{AuraID = 307496, UnitID = "player"},	-- 神圣觉醒药水
		{AuraID = 307497, UnitID = "player"},	-- 死亡偏执药水
		{AuraID = 344314, UnitID = "player"},	-- 心华之速药水
		-- 9.0饰品
		{AuraID = 345228, UnitID = "player"},	-- 角斗士徽章
		{AuraID = 344662, UnitID = "player"},	-- 碎裂心智
		{AuraID = 345439, UnitID = "player"},	-- 赤红华尔兹
		{AuraID = 345019, UnitID = "player"},	-- 潜伏的掠食者
		{AuraID = 345530, UnitID = "player"},	-- 过载的心能电池
		{AuraID = 345541, UnitID = "player"},	-- 天域涌动
		{AuraID = 336588, UnitID = "player"},	-- 唤醒者的复叶
		{AuraID = 311444, UnitID = "player", Value = true},	-- 不屈套牌
		{AuraID = 336465, UnitID = "player", Value = true},	-- 脉冲光辉护盾
		-- 盟约
		{AuraID = 331937, UnitID = "player", Flash = true},	-- 沉醉
		{AuraID = 323546, UnitID = "player"},	-- 饕餮狂乱
		{AuraID = 326860, UnitID = "player"},	-- 陨落僧众
		{AuraID = 310143, UnitID = "player", Combat = true},-- 灵魂变形
		{AuraID = 327104, UnitID = "player"},	-- 妖魂踏
		{AuraID = 327710, UnitID = "player"},	-- 善行法夜
		{AuraID = 328933, UnitID = "player"},	-- 法夜输灵
		{AuraID = 328281, UnitID = "player"},	-- 凛冬祝福
		{AuraID = 328282, UnitID = "player"},	-- 阳春祝福
		{AuraID = 328620, UnitID = "player"},	-- 仲夏祝福
		{AuraID = 328622, UnitID = "player"},	-- 暮秋祝福
		{AuraID = 324867, UnitID = "player", Value = true},	-- 血肉铸造
		{AuraID = 328204, UnitID = "player"},	-- 征服者之锤
		{AuraID = 325748, UnitID = "player"},	-- 激变蜂群
		{AuraID = 315443, UnitID = "player"},	-- 憎恶附肢
		{AuraID = 325299, UnitID = "player"},	-- 屠戮箭
		{AuraID = 327164, UnitID = "player"},	-- 始源之潮
		{AuraID = 325216, UnitID = "player"},	-- 骨尘酒
		{AuraID = 343672, UnitID = "player"},	-- 征服者之狂
		{AuraID = 324220, UnitID = "player"},	-- 死神之躯
		{AuraID = 311648, UnitID = "player"},	-- 云集之雾
		{AuraID = 323558, UnitID = "player"},	-- 申斥回响2
		{AuraID = 323559, UnitID = "player"},	-- 申斥回响3
		{AuraID = 323560, UnitID = "player"},	-- 申斥回响4
		{AuraID = 338142, UnitID = "player"},	-- 自审强化
		{AuraID = 310454, UnitID = "player"},	-- 精序兵戈
		{AuraID = 325013, UnitID = "player"},	-- 晋升者之赐
		{AuraID = 308495, UnitID = "player"},	-- 共鸣箭
		{AuraID = 328908, UnitID = "player"},	-- 战斗冥想
		-- 炼金石
		{AuraID = 60233, UnitID = "player"},	-- 敏捷
		{AuraID = 60229, UnitID = "player"},	-- 力量
		{AuraID = 60234, UnitID = "player"},	-- 智力
		-- WoD橙戒
		{AuraID = 187616, UnitID = "player"},	-- 尼萨姆斯，智力
		{AuraID = 187617, UnitID = "player"},	-- 萨克图斯，坦克
		{AuraID = 187618, UnitID = "player"},	-- 伊瑟拉鲁斯，治疗
		{AuraID = 187619, UnitID = "player"},	-- 索拉苏斯，力量
		{AuraID = 187620, UnitID = "player"},	-- 玛鲁斯，敏捷
		-- 传家宝饰品
		{AuraID = 201405, UnitID = "player"},	-- 力量
		{AuraID = 201408, UnitID = "player"},	-- 敏捷
		{AuraID = 201410, UnitID = "player"},	-- 智力
		{AuraID = 202052, UnitID = "player", Value = true},		-- 坦克
	},
	["Raid Buff"] = {		-- 团队增益组
		{AuraID = 54861, UnitID = "player"},	-- 火箭靴，工程
		-- 嗜血相关
		{AuraID = 2825, UnitID = "player"},		-- 嗜血
		{AuraID = 32182, UnitID = "player"},	-- 英勇
		{AuraID = 80353, UnitID = "player"},	-- 时间扭曲
		{AuraID = 264667, UnitID = "player"},	-- 原始狂怒
		{AuraID = 178207, UnitID = "player"},	-- 鼓
		{AuraID = 230935, UnitID = "player"},	-- 高山战鼓
		{AuraID = 256740, UnitID = "player"},	-- 漩涡战鼓
		{AuraID = 102364, UnitID = "player"},	-- 青铜龙的祝福
		{AuraID = 292686, UnitID = "player"},	-- 制皮鼓
		-- 团队增益或减伤
		{AuraID = 1022, UnitID = "player"},		-- 保护祝福
		{AuraID = 6940, UnitID = "player"},		-- 牺牲祝福
		{AuraID = 1044, UnitID = "player"},		-- 自由祝福
		{AuraID = 77761, UnitID = "player"},	-- 狂奔怒吼
		{AuraID = 77764, UnitID = "player"},	-- 狂奔怒吼
		{AuraID = 31821, UnitID = "player"},	-- 光环掌握
		{AuraID = 97463, UnitID = "player"},	-- 命令怒吼
		{AuraID = 64843, UnitID = "player"},	-- 神圣赞美诗
		{AuraID = 64901, UnitID = "player"},	-- 希望象征
		{AuraID = 81782, UnitID = "player"},	-- 真言术：障
		{AuraID = 29166, UnitID = "player"},	-- 激活
		{AuraID = 47788, UnitID = "player"},	-- 守护之魂
		{AuraID = 33206, UnitID = "player"},	-- 痛苦压制
		{AuraID = 53563, UnitID = "player"},	-- 圣光道标
		{AuraID = 98007, UnitID = "player"},	-- 灵魂链接图腾
		{AuraID = 223658, UnitID = "player"},	-- 捍卫
		{AuraID = 115310, UnitID = "player"},	-- 五气归元
		{AuraID = 116849, UnitID = "player"},	-- 作茧缚命
		{AuraID = 204018, UnitID = "player"},	-- 破咒祝福
		{AuraID = 102342, UnitID = "player"},	-- 铁木树皮
		{AuraID = 156910, UnitID = "player"},	-- 信仰道标
		{AuraID = 192082, UnitID = "player"},	-- 狂风图腾
		{AuraID = 201633, UnitID = "player"},	-- 大地图腾
		{AuraID = 207498, UnitID = "player"},	-- 先祖护佑
		{AuraID = 238698, UnitID = "player"},	-- 吸血光环
		{AuraID = 209426, UnitID = "player"},	-- 幻影打击
		{AuraID = 114018, UnitID = "player", Flash = true},	-- 帷幕
		{AuraID = 115834, UnitID = "player", Flash = true},
	},
	["Raid Debuff"] = {		-- 团队减益组
		-- 大幻象
		{AuraID = 311390, UnitID = "player"},	-- 疯狂：昆虫恐惧症，幻象
		{AuraID = 306583, UnitID = "player"},	-- 灌铅脚步
		{AuraID = 313698, UnitID = "player", Flash = true},	-- 泰坦之赐
		-- 常驻词缀
		{AuraID = 209858, UnitID = "player"},	-- 死疽溃烂
		{AuraID = 240559, UnitID = "player"},	-- 重伤
		{AuraID = 340880, UnitID = "player"},	-- 傲慢
		{AuraID = 226512, UnitID = "player"},	-- 血池
		{AuraID = 240447, UnitID = "player", Flash = true},	-- 践踏
		{AuraID = 240443, UnitID = "player", Flash = true},	-- 爆裂
		-- 5人本
		{AuraID = 327107, UnitID = "player"},	-- 赤红，闪耀光辉
		{AuraID = 333299, UnitID = "player"},	-- 伤逝剧场，荒芜诅咒
		{AuraID = 319637, UnitID = "player"},	-- 伤逝剧场，魂魄归体
		{AuraID = 336258, UnitID = "player", Flash = true},	-- 凋魂之殇，落单狩猎
		{AuraID = 327401, UnitID = "player", Flash = true},	-- 通灵战潮，共受苦难
		{AuraID = 327397, UnitID = "player"},	-- 通灵战潮，严酷命运
		{AuraID = 322681, UnitID = "player"},	-- 通灵战潮，肉钩
		{AuraID = 322746, UnitID = "player"},	-- 彼界，堕落之血
		{AuraID = 327893, UnitID = "player", Flash = true},	-- 彼界，邦桑迪的热情
		{AuraID = 339978, UnitID = "player", Flash = true},	-- 彼界，安抚迷雾
		{AuraID = 323569, UnitID = "player", Flash = true},	-- 彼界，溅洒精魂
		{AuraID = 335805, UnitID = "player", Flash = true},	-- 晋升高塔，执政官的壁垒

	},
	["Warning"] = { -- 目标重要光环组
		-- 大幻象
		{AuraID = 304975, UnitID = "target", Value = true},	-- 虚空哀嚎，吸收盾
		{AuraID = 319643, UnitID = "target", Value = true},	-- 虚空哀嚎，吸收盾
		-- 大米
		{AuraID = 226510, UnitID = "target"},	-- 血池回血
		-- 9.0副本
		{AuraID = 322773, UnitID = "target", Value = true},	-- 彼界，鲜血屏障
		{AuraID = 320293, UnitID = "target", Value = true},	-- 伤逝剧场，融入死亡
		{AuraID = 321368, UnitID = "target", Value = true},	-- 凋魂，冰缚之盾
		{AuraID = 327416, UnitID = "target", Value = true},	-- 堡垒，心能回灌
		-- PVP
		{AuraID = 498, UnitID = "target"},		-- 圣佑术
		{AuraID = 642, UnitID = "target"},		-- 圣盾术
		{AuraID = 871, UnitID = "target"},		-- 盾墙
		{AuraID = 5277, UnitID = "target"},		-- 闪避
		{AuraID = 1044, UnitID = "target"},		-- 自由祝福
		{AuraID = 6940, UnitID = "target"},		-- 牺牲祝福
		{AuraID = 1022, UnitID = "target"},		-- 保护祝福
		{AuraID = 19574, UnitID = "target"},	-- 狂野怒火
		{AuraID = 23920, UnitID = "target"},	-- 法术反射
		{AuraID = 31884, UnitID = "target"},	-- 复仇之怒
		{AuraID = 33206, UnitID = "target"},	-- 痛苦压制
		{AuraID = 45438, UnitID = "target"},	-- 寒冰屏障
		{AuraID = 47585, UnitID = "target"},	-- 消散
		{AuraID = 47788, UnitID = "target"},	-- 守护之魂
		{AuraID = 48792, UnitID = "target"},	-- 冰封之韧
		{AuraID = 48707, UnitID = "target"},	-- 反魔法护罩
		{AuraID = 61336, UnitID = "target"},	-- 生存本能
		{AuraID = 197690, UnitID = "target"},	-- 防御姿态
		{AuraID = 147833, UnitID = "target"},	-- 援护
		{AuraID = 186265, UnitID = "target"},	-- 灵龟守护
		{AuraID = 113862, UnitID = "target"},	-- 强化隐形术
		{AuraID = 118038, UnitID = "target"},	-- 剑在人在
		{AuraID = 114050, UnitID = "target"},	-- 升腾 元素
		{AuraID = 114051, UnitID = "target"},	-- 升腾 增强
		{AuraID = 114052, UnitID = "target"},	-- 升腾 恢复
		{AuraID = 204018, UnitID = "target"},	-- 破咒祝福
		{AuraID = 205191, UnitID = "target"},	-- 以眼还眼 惩戒
		{AuraID = 104773, UnitID = "target"},	-- 不灭决心
		{AuraID = 199754, UnitID = "target"},	-- 还击
		{AuraID = 120954, UnitID = "target"},	-- 壮胆酒
		{AuraID = 122278, UnitID = "target"},	-- 躯不坏
		{AuraID = 122783, UnitID = "target"},	-- 散魔功
		{AuraID = 188499, UnitID = "target"},	-- 刃舞
		{AuraID = 210152, UnitID = "target"},	-- 刃舞
		{AuraID = 247938, UnitID = "target"},	-- 混乱之刃
		{AuraID = 212800, UnitID = "target"},	-- 疾影
		{AuraID = 162264, UnitID = "target"},	-- 恶魔变形
		{AuraID = 187827, UnitID = "target"},	-- 恶魔变形
		{AuraID = 125174, UnitID = "target"},	-- 业报之触
		{AuraID = 171607, UnitID = "target"},	-- 爱情光线
		{AuraID = 228323, UnitID = "target", Value = true},	-- 克罗塔的护盾
	},
	["InternalCD"] = { -- 自定义内置冷却组
		{IntID = 240447, Duration = 20},	-- 大米，践踏
		{IntID = 114018, Duration = 15, OnSuccess = true, UnitID = "all"},	-- 帷幕
	},
}

Module:AddNewAuraWatch("ALL", list)