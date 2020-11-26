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
		-- 饰品附魔
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

		-- 旧版本
		{AuraID = 229206, UnitID = "player"},	-- 延时之力
		{AuraID = 251231, UnitID = "player"},	-- 钢肤药水
		{AuraID = 279151, UnitID = "player"},	-- 智力药水
		{AuraID = 279152, UnitID = "player"},	-- 敏捷药水
		{AuraID = 279153, UnitID = "player"},	-- 力量药水
		{AuraID = 279154, UnitID = "player"},	-- 耐力药水

		{AuraID = 298155, UnitID = "player"},	-- 超强钢肤药水
		{AuraID = 298152, UnitID = "player"},	-- 超强智力药水
		{AuraID = 298146, UnitID = "player"},	-- 超强敏捷药水
		{AuraID = 298154, UnitID = "player"},	-- 超强力量药水
		{AuraID = 298153, UnitID = "player"},	-- 超强耐力药水

		{AuraID = 298225, UnitID = "player"},	-- 邻位强化药水
		{AuraID = 298317, UnitID = "player"},	-- 专注决心药水
		{AuraID = 300714, UnitID = "player"},	-- 无拘之怒药水
		{AuraID = 300741, UnitID = "player"},	-- 狂野愈合药水

		{AuraID = 188024, UnitID = "player"},	-- 天行药水
		{AuraID = 250878, UnitID = "player"},	-- 轻足药水
		{AuraID = 290365, UnitID = "player"},	-- 辉煌蓝宝石
		{AuraID = 277179, UnitID = "player"},	-- 角斗士勋章
		{AuraID = 277181, UnitID = "player"},	-- 角斗士徽记
		{AuraID = 277187, UnitID = "player"},	-- 角斗士纹章
		{AuraID = 277185, UnitID = "player"},	-- 角斗士徽章
		{AuraID = 286342, UnitID = "player", Value = true},	-- 角斗士的护徽
		{AuraID = 275765, UnitID = "player"},	-- 艾泽里特强化
		{AuraID = 271194, UnitID = "player"},	-- 火炮
		{AuraID = 273992, UnitID = "player"},	-- 灵魂之速
		{AuraID = 273955, UnitID = "player"},	-- 望远镜视野
		{AuraID = 267612, UnitID = "player"},	-- 迅击风暴
		{AuraID = 268887, UnitID = "player"},	-- 迅捷远航
		{AuraID = 268893, UnitID = "player"},	-- 迅捷远航
		{AuraID = 268854, UnitID = "player"},	-- 全能远航
		{AuraID = 268856, UnitID = "player"},	-- 全能远航
		{AuraID = 268904, UnitID = "player"},	-- 致命远航
		{AuraID = 268905, UnitID = "player"},	-- 致命远航
		{AuraID = 268898, UnitID = "player"},	-- 精湛远航
		{AuraID = 268899, UnitID = "player"},	-- 精湛远航
		{AuraID = 264957, UnitID = "player"},	-- 急速瞄准镜
		{AuraID = 264878, UnitID = "player"},	-- 爆击瞄准镜
		{AuraID = 267685, UnitID = "player"},	-- 元素洪流
		{AuraID = 274472, UnitID = "player"},	-- 狂战士之怒
		{AuraID = 268769, UnitID = "player"},	-- 标记死穴
		{AuraID = 267179, UnitID = "player"},	-- 瓶中的电荷
		{AuraID = 278070, UnitID = "player"},	-- 泰坦过载
		{AuraID = 271103, UnitID = "player"},	-- 莱赞的微光之眼
		{AuraID = 273942, UnitID = "player"},	-- 提振精神
		{AuraID = 268518, UnitID = "player"},	-- 狂风风铃
		{AuraID = 265946, UnitID = "player", Value = true},	-- 仪式裹手
		{AuraID = 278143, UnitID = "player"},	-- 血珠狂怒
		{AuraID = 278381, UnitID = "player"},	-- 海上风暴
		{AuraID = 273974, UnitID = "player"},	-- 洛阿意志
		{AuraID = 271105, UnitID = "player"},	-- 屠夫之眼
		{AuraID = 271107, UnitID = "player"},	-- 金色光泽
		{AuraID = 278231, UnitID = "player"},	-- 森林之王的愤怒
		{AuraID = 278267, UnitID = "player"},	-- 森林之王的智慧
		{AuraID = 268311, UnitID = "player", Flash = true},	-- 唤风者之赐
		{AuraID = 285489, UnitID = "player"},	-- 黑喉之力
		{AuraID = 278317, UnitID = "player"},	-- 末日余波
		{AuraID = 278806, UnitID = "player"},	-- 雄狮谋略
		{AuraID = 278249, UnitID = "player"},	-- 刀叶风暴
		{AuraID = 287916, UnitID = "player", Stack = 6, Flash = true, Combat = true},	-- 反应堆
		{AuraID = 287917, UnitID = "player"},	-- 振荡过载
		{AuraID = 265954, UnitID = "player"},	-- 黄金之触
		{AuraID = 268439, UnitID = "player"},	-- 共鸣之心
		{AuraID = 278225, UnitID = "player"},	-- 缚魂巫毒瘤节
		{AuraID = 278388, UnitID = "player"},	-- 永冻护壳之心
		{AuraID = 274430, UnitID = "player", Text = L["Haste"]},	-- 永不间断的时钟，急速
		{AuraID = 274431, UnitID = "player", Text = L["Mastery"]},	-- 精通
		--{AuraID = 267325, UnitID = "player", Text = L["Mastery"]},	-- 注铅骰子，精通
		--{AuraID = 267326, UnitID = "player", Text = L["Mastery"]},	-- 精通
		--{AuraID = 267327, UnitID = "player", Text = L["Haste"]},	-- 急速
		--{AuraID = 267329, UnitID = "player", Text = L["Haste"]},	-- 急速
		--{AuraID = 267330, UnitID = "player", Text = L["Crit"]},	-- 爆击
		--{AuraID = 267331, UnitID = "player", Text = L["Crit"]},	-- 爆击
		{AuraID = 280573, UnitID = "player", Combat = true},	-- 重组阵列
		{AuraID = 289523, UnitID = "player", Combat = true},	-- 耀辉之光
		{AuraID = 295408, UnitID = "player"},	-- 险恶赐福
		{AuraID = 273988, UnitID = "player"},	-- 原始本能
		{AuraID = 285475, UnitID = "player"},	-- 卡亚矿涌流
		{AuraID = 306242, UnitID = "player"},	-- 红卡重置
		{AuraID = 285482, UnitID = "player"},	-- 海巨人的凶猛
		{AuraID = 303570, UnitID = "player", Flash = true},	-- 锋锐珊瑚
		{AuraID = 303568, UnitID = "target", Caster = "player"},	-- 锋锐珊瑚
		{AuraID = 301624, UnitID = "target", Caster = "player"},	-- 颤栗毒素
		{AuraID = 302565, UnitID = "target", Caster = "player"},	-- 导电墨汁
		{AuraID = 296962, UnitID = "player"},	-- 艾萨拉饰品
		{AuraID = 315787, UnitID = "player", Caster = "player"},	-- 生命充能
		-- 艾泽里特特质
		{AuraID = 274598, UnitID = "player"},	-- 冲击大师
		{AuraID = 277960, UnitID = "player"},	-- 神经电激
		{AuraID = 280852, UnitID = "player"},	-- 解放者之力
		{AuraID = 266047, UnitID = "player"},	-- 激励咆哮
		{AuraID = 280409, UnitID = "player"},	-- 血祭之力
		{AuraID = 279902, UnitID = "player"},	-- 不稳定的烈焰
		{AuraID = 281843, UnitID = "player"},	-- 汇帆
		{AuraID = 280204, UnitID = "player"},	-- 徘徊的灵魂
		{AuraID = 273685, UnitID = "player"},	-- 缜密计谋
		{AuraID = 273714, UnitID = "player"},	-- 争分夺秒
		{AuraID = 274443, UnitID = "player"},	-- 死亡之舞
		{AuraID = 280433, UnitID = "player"},	-- 呼啸狂沙
		{AuraID = 271711, UnitID = "player"},	-- 压倒能量
		{AuraID = 272733, UnitID = "player"},	-- 弦之韵律
		{AuraID = 280780, UnitID = "player"},	-- 战斗荣耀
		{AuraID = 280787, UnitID = "player"},	-- 反击之怒
		{AuraID = 280385, UnitID = "player"},	-- 压力渐增
		{AuraID = 273842, UnitID = "player"},	-- 深渊秘密
		{AuraID = 273843, UnitID = "player"},	-- 深渊秘密
		{AuraID = 280412, UnitID = "player"},	-- 激励兽群
		{AuraID = 274596, UnitID = "player"},	-- 冲击大师
		{AuraID = 277969, UnitID = "player"},	-- 迅疾爪击
		{AuraID = 273264, UnitID = "player"},	-- 怒火升腾
		{AuraID = 280653, UnitID = "player"},	-- 工程特质，变小
		{AuraID = 280654, UnitID = "player"},	-- 工程特质，变大
		{AuraID = 273525, UnitID = "player"},	-- 大难临头
		{AuraID = 274373, UnitID = "player"},	-- 溃烂之力
		{AuraID = 280170, UnitID = "player", Value = true},	-- 假死盾
		-- 艾泽里特精华
		{AuraID = 302932, UnitID = "player", Flash = true},	-- 无畏之力
		{AuraID = 297126, UnitID = "player"},	-- 仇敌之血
		{AuraID = 297168, UnitID = "player"},	-- 仇敌之血
		{AuraID = 304056, UnitID = "player"},	-- 斗争
		{AuraID = 298343, UnitID = "player"},	-- 清醒梦境
		{AuraID = 295855, UnitID = "player"},	-- 艾泽拉斯守护者
		{AuraID = 295248, UnitID = "player"},	-- 专注能量
		{AuraID = 298357, UnitID = "player"},	-- 清醒梦境之忆
		{AuraID = 302731, UnitID = "player", Flash = true},	-- 空间涟漪
		{AuraID = 302952, UnitID = "player"},	-- 现实流转
		{AuraID = 295137, UnitID = "player", Flash = true},	-- 源血
		{AuraID = 311203, UnitID = "player"},	-- 光荣时刻
		{AuraID = 311202, UnitID = "player"},	-- 收割火焰
		{AuraID = 312915, UnitID = "player"},	-- 共生姿态
		{AuraID = 295354, UnitID = "player"},	-- 精华协议
		-- 腐蚀
		{AuraID = 316823, UnitID = "player"},	-- 虚空仪式
		{AuraID = 318211, UnitID = "player"},	-- 活力涌动
		{AuraID = 318219, UnitID = "player"},	-- 致命之势
		{AuraID = 317020, UnitID = "player", Flash = true, Combat = true},	-- 虚空回响
		{AuraID = 318378, UnitID = "player", Flash = true},	-- 坚定决心，橙披
		{AuraID = 317859, UnitID = "player"},	-- 龙族强化，橙披
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
		{AuraID = 295413, UnitID = "player", Stack = 20, Flash = true},	-- 苦楚
		{AuraID = 315176, UnitID = "player"},	-- 贪婪触须
		{AuraID = 315161, UnitID = "player"},	-- 腐化之眼
		{AuraID = 319695, UnitID = "player", Flash = true},	-- 壮美幻象
		-- 5人本
		{AuraID = 311390, UnitID = "player"},	-- 疯狂：昆虫恐惧症，幻象
		{AuraID = 306583, UnitID = "player"},	-- 灌铅脚步
		{AuraID = 313698, UnitID = "player", Flash = true},	-- 泰坦之赐

		{AuraID = 314478, UnitID = "player"},	-- 倾泻恐惧
		{AuraID = 314483, UnitID = "player"},	-- 倾泻恐惧
		{AuraID = 314411, UnitID = "player"},	-- 疑云密布
		{AuraID = 314406, UnitID = "player"},	-- 致残疾病
		{AuraID = 314565, UnitID = "player", Flash = true},	-- 亵渎大地
		{AuraID = 314392, UnitID = "player", Flash = true},	-- 邪恶腐化物
		{AuraID = 314308, UnitID = "player", Flash = true},	-- 灵魂毁灭
		{AuraID = 209858, UnitID = "player"},	-- 死疽溃烂
		{AuraID = 240559, UnitID = "player"},	-- 重伤
		{AuraID = 340880, UnitID = "player"},	-- 傲慢
		{AuraID = 314531, UnitID = "player"},	-- 撕扯血肉
		{AuraID = 302420, UnitID = "player"},	-- 女王法令：隐藏
		{AuraID = 240443, UnitID = "player", Flash = true},	-- 爆裂
		{AuraID = 226512, UnitID = "player"},	-- 血池
		{AuraID = 240447, UnitID = "player", Flash = true},	-- 践踏

		{AuraID = 333299, UnitID = "player"},	-- 伤逝剧场，荒芜诅咒
		{AuraID = 319637, UnitID = "player"},	-- 伤逝剧场，魂魄归体
		{AuraID = 336258, UnitID = "player", Flash = true},	-- 凋魂之殇，落单狩猎
		{AuraID = 327401, UnitID = "player", Flash = true},	-- 通灵战潮，共受苦难
		{AuraID = 327397, UnitID = "player"},	-- 通灵战潮，严酷命运
		{AuraID = 322681, UnitID = "player"},	-- 通灵战潮，肉钩
		{AuraID = 322746, UnitID = "player"},	-- 彼界，堕落之血
		{AuraID = 339978, UnitID = "player", Flash = true},	-- 彼界，安抚迷雾
		{AuraID = 323569, UnitID = "player", Flash = true},	-- 彼界，溅洒精魂
		{AuraID = 335805, UnitID = "player", Flash = true},	-- 晋升高塔，执政官的壁垒

		{AuraID = 260954, UnitID = "player"},	-- 铁之凝视，围攻
		{AuraID = 272421, UnitID = "player"},	-- 瞄准火炮，围攻
		{AuraID = 265773, UnitID = "player"},	-- 吐金，诸王
		{AuraID = 271564, UnitID = "player", Flash = true},	-- 防腐液，诸王
		{AuraID = 271640, UnitID = "player"},	-- 黑暗启示，诸王
		{AuraID = 274507, UnitID = "player"},	-- 湿滑肥皂，自由镇
		{AuraID = 266923, UnitID = "player"},	-- 充电，神庙
		{AuraID = 273563, UnitID = "player", Text = L["Freeze"]},	-- 神经毒素，神庙
		{AuraID = 269686, UnitID = "player"},	-- 瘟疫，神庙
		{AuraID = 257407, UnitID = "player"},	-- 追踪，阿塔达萨
		{AuraID = 250585, UnitID = "player", Flash = true},	-- 剧毒之池，阿塔达萨
		{AuraID = 258723, UnitID = "player", Flash = true},	-- 怪诞之池，阿塔达萨
		{AuraID = 258058, UnitID = "player"},	-- 挤压，托尔达戈
		{AuraID = 260067, UnitID = "player"},	-- 恶毒槌击，托尔达戈
		{AuraID = 273226, UnitID = "player"},	-- 腐烂孢子，孢林
		{AuraID = 269838, UnitID = "player", Flash = true},	-- 邪恶污染，孢林
		{AuraID = 259718, UnitID = "player"},	-- 颠覆
		{AuraID = 276297, UnitID = "player"},	-- 虚空种子，风暴神殿
		{AuraID = 274438, UnitID = "player", Flash = true},	-- 风暴
		{AuraID = 276286, UnitID = "player"},	-- 切割旋风
		{AuraID = 267818, UnitID = "player"},	-- 切割冲击
		{AuraID = 268086, UnitID = "player", Text = L["Move"]},	-- 恐怖光环，庄园
		{AuraID = 298602, UnitID = "player"},	-- 烟云，麦卡贡
		{AuraID = 293724, UnitID = "player"},	-- 护盾发生器
		{AuraID = 297257, UnitID = "player"},	-- 电荷充能
		{AuraID = 303885, UnitID = "player"},	-- 爆裂喷发
		{AuraID = 291928, UnitID = "player"},	-- 超荷电磁炮
		{AuraID = 292267, UnitID = "player"},	-- 超荷电磁炮
		{AuraID = 305699, UnitID = "player"},	-- 锁定
		{AuraID = 302274, UnitID = "player"},	-- 爆裂冲击
		{AuraID = 298669, UnitID = "player"},	-- 跳电
		{AuraID = 294929, UnitID = "player"},	-- 烈焰撕咬
		{AuraID = 291937, UnitID = "player", Flash = true},	-- 垃圾掩体
		{AuraID = 259533, UnitID = "player", Flash = true},	-- 艾泽里特催化剂，暴富
		-- 尼奥罗萨
		-- 黑龙帝王拉希奥
		{AuraID = 306015, UnitID = "player"},	-- 灼烧护甲
		{AuraID = 306163, UnitID = "player"},	-- 万物尽焚
		{AuraID = 313959, UnitID = "player", Flash = true},	-- 灼热气泡
		{AuraID = 307053, UnitID = "player", Flash = true},	-- 岩浆池
		{AuraID = 314347, UnitID = "player"},	-- 毒扼
		-- 玛乌特
		{AuraID = 307399, UnitID = "player"},	-- 暗影之伤
		{AuraID = 307806, UnitID = "player"},	-- 吞噬魔法
		{AuraID = 307586, UnitID = "player"},	-- 噬魔深渊
		{AuraID = 306301, UnitID = "player"},	-- 禁忌法力
		{AuraID = 315025, UnitID = "player"},	-- 远古诅咒
		{AuraID = 314993, UnitID = "player", Flash = true},	-- 吸取精华
		-- 先知斯基特拉
		{AuraID = 308059, UnitID = "player"},	-- 暗影震击
		{AuraID = 307950, UnitID = "player", Flash = true},	-- 心智剥离
		-- 黑暗审判官夏奈什
		{AuraID = 311551, UnitID = "player"},	-- 深渊打击
		{AuraID = 312406, UnitID = "player"},	-- 虚空觉醒
		{AuraID = 314298, UnitID = "player", Flash = true},	-- 末日迫近
		{AuraID = 316211, UnitID = "player"},	-- 恐惧浪潮
		-- 主脑
		{AuraID = 313461, UnitID = "player"},	-- 腐蚀
		{AuraID = 315311, UnitID = "player"},	-- 毁灭
		{AuraID = 313672, UnitID = "player", Flash = true},	-- 酸液池
		{AuraID = 314593, UnitID = "player"},	-- 麻痹毒液
		-- 无厌者夏德哈
		{AuraID = 307471, UnitID = "player"},	-- 碾压
		{AuraID = 307472, UnitID = "player"},	-- 融解
		{AuraID = 306928, UnitID = "player"},	-- 幽影吐息
		{AuraID = 306930, UnitID = "player"},	-- 熵能暗息
		{AuraID = 314736, UnitID = "player", Flash = true},	-- 气泡流溢
		{AuraID = 318078, UnitID = "player", Flash = true, Text = L["Get Out"]},	-- 锁定
		-- 德雷阿佳丝
		{AuraID = 310277, UnitID = "player"},	-- 动荡之种
		{AuraID = 310309, UnitID = "player"},	-- 动荡易伤
		{AuraID = 310361, UnitID = "player"},	-- 不羁狂乱
		{AuraID = 308377, UnitID = "player"},	-- 虚化脓液
		{AuraID = 317001, UnitID = "player"},	-- 暗影排异
		{AuraID = 310563, UnitID = "player"},	-- 背叛低语
		{AuraID = 310567, UnitID = "player"},	-- 背叛者
		-- 伊格诺斯，重生之蚀
		{AuraID = 309961, UnitID = "player"},	-- 恩佐斯之眼
		{AuraID = 311367, UnitID = "player"},	-- 腐蚀者之触
		{AuraID = 310322, UnitID = "player", Flash = true},	-- 梦魇腐蚀
		{AuraID = 313759, UnitID = "player"},	-- 诅咒之血
		-- 维克修娜
		{AuraID = 307359, UnitID = "player"},	-- 绝望
		{AuraID = 307020, UnitID = "player"},	-- 暮光之息
		{AuraID = 307019, UnitID = "player"},	-- 虚空腐蚀
		{AuraID = 306981, UnitID = "player"},	-- 虚空之赐
		{AuraID = 310224, UnitID = "player"},	-- 毁灭
		{AuraID = 307314, UnitID = "player"},	-- 渗透暗影
		{AuraID = 307343, UnitID = "player"},	-- 暗影残渣
		{AuraID = 307645, UnitID = "player"},	-- 黑暗之心
		{AuraID = 315932, UnitID = "player"},	-- 蛮力重击
		-- 虚无者莱登
		{AuraID = 313977, UnitID = "player"},	-- 虚空诅咒，小怪
		{AuraID = 306184, UnitID = "player", Value = true},	-- 释放的虚空
		{AuraID = 306819, UnitID = "player"},	-- 虚化重击
		{AuraID = 306279, UnitID = "player"},	-- 动荡暴露
		{AuraID = 306637, UnitID = "player"},	-- 不稳定的虚空爆发
		{AuraID = 309777, UnitID = "player"},	-- 虚空污秽
		{AuraID = 313227, UnitID = "player"},	-- 腐坏伤口
		{AuraID = 310019, UnitID = "player"},	-- 充能锁链
		{AuraID = 310022, UnitID = "player"},	-- 充能锁链
		{AuraID = 315252, UnitID = "player"},	-- 恐怖炼狱
		{AuraID = 316065, UnitID = "player"},	-- 腐化存续
		-- 恩佐斯的外壳
		{AuraID = 307832, UnitID = "player"},	-- 恩佐斯的仆从
		{AuraID = 313334, UnitID = "player"},	-- 恩佐斯之赐
		{AuraID = 315954, UnitID = "player"},	-- 漆黑伤疤
		{AuraID = 307044, UnitID = "player"},	-- 梦魇抗原
		{AuraID = 307011, UnitID = "player"},	-- 疯狂繁衍
		{AuraID = 307061, UnitID = "player"},	-- 菌丝生长
		{AuraID = 306973, UnitID = "player"},	-- 疯狂炸弹
		{AuraID = 306984, UnitID = "player"},	-- 狂乱炸弹
		-- 腐蚀者恩佐斯
		{AuraID = 308996, UnitID = "player"},	-- 恩佐斯的仆从
		{AuraID = 313609, UnitID = "player"},	-- 恩佐斯之赐
		{AuraID = 309991, UnitID = "player"},	-- 痛楚
		{AuraID = 316711, UnitID = "player"},	-- 意志摧毁
		{AuraID = 313400, UnitID = "player"},	-- 堕落心灵
		{AuraID = 316542, UnitID = "player"},	-- 妄念
		{AuraID = 316541, UnitID = "player"},	-- 妄念
		{AuraID = 310042, UnitID = "player"},	-- 混乱爆发
		{AuraID = 313793, UnitID = "player"},	-- 狂乱之火
		{AuraID = 313610, UnitID = "player"},	-- 精神腐烂
		{AuraID = 311392, UnitID = "player"},	-- 心灵之握
		{AuraID = 310073, UnitID = "player"},	-- 心灵之握
		{AuraID = 317112, UnitID = "player"},	-- 激荡痛楚
		-- 永恒王宫
		-- 深渊指挥官西瓦拉
		{AuraID = 295795, UnitID = "player", Flash = true, Text = L["Move"]},	-- 冻结之血
		{AuraID = 295796, UnitID = "player", Flash = true, Text = L["Freeze"]},	-- 漫毒之血
		{AuraID = 295807, UnitID = "player"},	-- 冻结之血
		{AuraID = 295850, UnitID = "player"},	-- 癫狂
		{AuraID = 294847, UnitID = "player"},	-- 不稳定混合物
		{AuraID = 300883, UnitID = "player"},	-- 倒置之疾
		{AuraID = 300701, UnitID = "player"},	-- 白霜
		{AuraID = 300705, UnitID = "player"},	-- 脓毒污染
		{AuraID = 295348, UnitID = "player"},	-- 溢流寒霜
		{AuraID = 295421, UnitID = "player"},	-- 溢流毒液
		{AuraID = 300961, UnitID = "player", Flash = true},	-- 冰霜之地
		{AuraID = 300962, UnitID = "player", Flash = true},	-- 败血之地
		-- 黑水巨鳗
		{AuraID = 298428, UnitID = "player"},	-- 暴食
		{AuraID = 292127, UnitID = "player", Flash = true},	-- 墨黑深渊
		{AuraID = 292138, UnitID = "player"},	-- 辐光生物质
		{AuraID = 292133, UnitID = "player"},	-- 生物体荧光
		{AuraID = 301968, UnitID = "player"},	-- 生物体荧光，小怪
		{AuraID = 292167, UnitID = "player"},	-- 剧毒脊刺
		{AuraID = 301180, UnitID = "player"},	-- 冲流
		{AuraID = 298595, UnitID = "player"},	-- 发光的钉刺
		{AuraID = 292307, UnitID = "player", Flash = true},	-- 深渊凝视
		-- 艾萨拉之辉
		{AuraID = 296566, UnitID = "player"},	-- 海潮之拳
		{AuraID = 296737, UnitID = "player", Flash = true},	-- 奥术炸弹
		{AuraID = 296746, UnitID = "player"},	-- 奥术炸弹
		{AuraID = 299152, UnitID = "player"},	-- 翻滚之水
		-- 艾什凡女勋爵
		{AuraID = 303630, UnitID = "player"},	-- 爆裂之黯，小怪
		{AuraID = 296725, UnitID = "player"},	-- 壶蔓猛击
		{AuraID = 296693, UnitID = "player"},	-- 浸水
		{AuraID = 296752, UnitID = "player"},	-- 锋利的珊瑚
		{AuraID = 296938, UnitID = "player"},	-- 艾泽里特弧光
		{AuraID = 296941, UnitID = "player"},
		{AuraID = 296942, UnitID = "player"},
		{AuraID = 296939, UnitID = "player"},
		{AuraID = 296940, UnitID = "player"},
		{AuraID = 296943, UnitID = "player"},
		-- 奥戈佐亚
		{AuraID = 298156, UnitID = "player"},	-- 麻痹钉刺
		{AuraID = 298459, UnitID = "player"},	-- 羊水喷发
		{AuraID = 295779, UnitID = "player", Flash = true},	-- 水舞长枪
		{AuraID = 300244, UnitID = "player", Flash = true},	-- 狂怒急流
		-- 女王法庭
		{AuraID = 297585, UnitID = "player"}, -- 服从或受苦
		{AuraID = 301830, UnitID = "player"}, -- 帕什玛之触
		{AuraID = 301832, UnitID = "player"}, -- 疯狂热诚
		{AuraID = 296851, UnitID = "player", Flash = true, Text = L["Get Out"]}, -- 狂热裁决
		{AuraID = 299914, UnitID = "player"}, -- 狂热冲锋
		{AuraID = 300545, UnitID = "player"}, -- 力量决裂
		{AuraID = 304409, UnitID = "player", Flash = true}, -- 重复行动
		{AuraID = 304410, UnitID = "player", Flash = true}, -- 重复行动
		{AuraID = 304128, UnitID = "player", Text = L["Move"]}, -- 缓刑
		{AuraID = 297586, UnitID = "player", Flash = true}, -- 承受折磨
		-- 扎库尔，尼奥罗萨先驱
		{AuraID = 298192, UnitID = "player", Flash = true}, -- 黑暗虚空
		{AuraID = 295480, UnitID = "player"}, -- 心智锁链
		{AuraID = 295495, UnitID = "player"},
		{AuraID = 300133, UnitID = "player", Flash = true}, -- 折断
		{AuraID = 292963, UnitID = "player"}, -- 惊惧
		{AuraID = 293509, UnitID = "player", Flash = true}, -- 惊惧
		{AuraID = 295327, UnitID = "player", Flash = true}, -- 碎裂心智
		{AuraID = 296018, UnitID = "player", Flash = true}, -- 癫狂惊惧
		{AuraID = 296015, UnitID = "player"}, -- 腐蚀谵妄
		-- 艾萨拉女王
		{AuraID = 297907, UnitID = "player", Flash = true}, -- 诅咒之心
		{AuraID = 299251, UnitID = "player"}, -- 服从！
		{AuraID = 299249, UnitID = "player"}, -- 受苦！
		{AuraID = 299255, UnitID = "player"}, -- 出列！
		{AuraID = 299254, UnitID = "player"}, -- 集合！
		{AuraID = 299252, UnitID = "player"}, -- 前进！
		{AuraID = 299253, UnitID = "player"}, -- 停留！
		{AuraID = 298569, UnitID = "player"}, -- 干涸灵魂
		{AuraID = 298014, UnitID = "player"}, -- 冰爆
		{AuraID = 298018, UnitID = "player", Flash = true}, -- 冻结
		{AuraID = 298756, UnitID = "player"}, -- 锯齿之锋
		{AuraID = 298781, UnitID = "player"}, -- 奥术宝珠
		{AuraID = 303825, UnitID = "player", Flash = true}, -- 溺水
		{AuraID = 302999, UnitID = "player"}, -- 奥术易伤
		{AuraID = 303657, UnitID = "player", Flash = true}, -- 奥术震爆
		-- 风暴熔炉
		{AuraID = 282384, UnitID = "player"},	-- 精神割裂，无眠秘党
		{AuraID = 282566, UnitID = "player"},	-- 力量应许
		{AuraID = 282561, UnitID = "player"},	-- 黑暗通报者
		{AuraID = 282432, UnitID = "player", Text = L["Get Out"]},	-- 粉碎之疑
		{AuraID = 282621, UnitID = "player"},	-- 终焉见证
		{AuraID = 282743, UnitID = "player"},	-- 风暴湮灭
		{AuraID = 282738, UnitID = "player"},	-- 虚空之拥
		{AuraID = 282589, UnitID = "player"},	-- 脑髓侵袭
		{AuraID = 287876, UnitID = "player"},	-- 黑暗吞噬
		{AuraID = 282540, UnitID = "player"},	-- 死亡化身
		{AuraID = 284851, UnitID = "player"},	-- 末日之触，乌纳特
		{AuraID = 285652, UnitID = "player"},	-- 贪食折磨
		{AuraID = 285685, UnitID = "player"},	-- 恩佐斯之赐：疯狂
		{AuraID = 284804, UnitID = "player"},	-- 深渊护持
		{AuraID = 285477, UnitID = "player"},	-- 渊黯
		{AuraID = 285367, UnitID = "player"},	-- 恩佐斯的穿刺凝视
		{AuraID = 284733, UnitID = "player", Flash = true},	-- 虚空之拥
		-- 达萨罗之战
		{AuraID = 283573, UnitID = "player"},	-- 圣洁之刃，圣光勇士
		{AuraID = 285671, UnitID = "player"},	-- 碾碎，丛林之王格洛恩
		{AuraID = 285998, UnitID = "player"},	-- 凶狠咆哮
		{AuraID = 285875, UnitID = "player"},	-- 撕裂噬咬
		{AuraID = 283069, UnitID = "player", Flash = true},	-- 原子烈焰
		{AuraID = 286434, UnitID = "player", Flash = true},	-- 死疽之核
		{AuraID = 289406, UnitID = "player"},	-- 蛮兽压掷
		{AuraID = 286988, UnitID = "player"},	-- 炽热余烬，玉火大师
		{AuraID = 284374, UnitID = "player"},	-- 熔岩陷阱
		{AuraID = 282037, UnitID = "player"},	-- 升腾之焰
		{AuraID = 286379, UnitID = "player"},	-- 炎爆术
		{AuraID = 285632, UnitID = "player"},	-- 追踪
		{AuraID = 288151, UnitID = "player"},	-- 考验后遗症
		{AuraID = 284089, UnitID = "player"},	-- 成功防御
		{AuraID = 287424, UnitID = "player"},	-- 窃贼的报应，丰灵
		{AuraID = 284527, UnitID = "player"},	-- 坚毅宝石
		{AuraID = 284556, UnitID = "player"},	-- 暗影触痕
		{AuraID = 284573, UnitID = "player"},	-- 顺风之力
		{AuraID = 284664, UnitID = "player"},	-- 炽热
		{AuraID = 284798, UnitID = "player"},	-- 极度炽热
		{AuraID = 284802, UnitID = "player", Flash = true},	-- 闪耀光环
		{AuraID = 284817, UnitID = "player"},	-- 地之根系
		{AuraID = 284881, UnitID = "player"},	-- 怒意释放
		{AuraID = 283507, UnitID = "player", Text = L["Get Out"], Flash = true},	-- 爆裂充能
		{AuraID = 287648, UnitID = "player", Text = L["Get Out"], Flash = true},	-- 爆裂充能
		{AuraID = 287072, UnitID = "player", Text = L["Get Out"], Flash = true},	-- 液态黄金
		{AuraID = 284424, UnitID = "player", Flash = true},	-- 灼烧之地
		{AuraID = 285014, UnitID = "player", Flash = true},	-- 金币雨
		{AuraID = 285479, UnitID = "player", Flash = true},	-- 烈焰喷射
		{AuraID = 283947, UnitID = "player", Flash = true},	-- 烈焰喷射
		{AuraID = 289383, UnitID = "player", Flash = true},	-- 混沌位移
		{AuraID = 291146, UnitID = "player", Text = L["Freeze"], Flash = true},	-- 混沌位移
		{AuraID = 284470, UnitID = "player", Text = L["Freeze"], Flash = true},	-- 昏睡妖术
		{AuraID = 282444, UnitID = "player"},	-- 裂爪猛击，神选者教团
		{AuraID = 286838, UnitID = "player"},	-- 静电之球
		{AuraID = 285879, UnitID = "player"},	-- 记忆清除
		{AuraID = 282135, UnitID = "player"},	-- 恶意妖术
		{AuraID = 282209, UnitID = "player", Flash = true},	-- 掠食印记
		{AuraID = 286821, UnitID = "player", Text = L["Get Out"], Flash = true},	-- 阿昆达的愤怒
		{AuraID = 284831, UnitID = "player", Text = L["Get Out"], Flash = true},	-- 炽焰引爆，拉斯塔哈大王
		{AuraID = 284662, UnitID = "player", Text = L["Get Out"], Flash = true},	-- 净化之印
		{AuraID = 290450, UnitID = "player", Text = L["Get Out"], Flash = true},	-- 净化之印
		{AuraID = 289858, UnitID = "player"},	-- 碾压
		{AuraID = 284740, UnitID = "player"},	-- 重斧掷击
		{AuraID = 284781, UnitID = "player"},	-- 重斧掷击
		{AuraID = 285195, UnitID = "player"},	-- 寂灭凋零
		{AuraID = 288449, UnitID = "player"},	-- 死亡之门
		{AuraID = 284376, UnitID = "player"},	-- 死亡的存在
		{AuraID = 285349, UnitID = "player"},	-- 赤焰瘟疫
		{AuraID = 287147, UnitID = "player", Flash = true},	-- 恐惧收割
		{AuraID = 284168, UnitID = "player"},	-- 缩小，大工匠梅卡托克
		{AuraID = 282182, UnitID = "player"},	-- 毁灭加农炮
		{AuraID = 286516, UnitID = "player"},	-- 反干涉震击
		{AuraID = 286480, UnitID = "player"},	-- 反干涉震击
		{AuraID = 287167, UnitID = "player"},	-- 基因解组
		{AuraID = 286105, UnitID = "player"},	-- 干涉
		{AuraID = 286646, UnitID = "player", Text = L["Get Out"], Flash = true},	-- 千兆伏特充能
		{AuraID = 285075, UnitID = "player", Flash = true},	-- 冰封潮汐池，风暴之墙阻击战
		{AuraID = 284121, UnitID = "player", Flash = true},	-- 雷霆轰鸣
		{AuraID = 285000, UnitID = "player"},	-- 海藻缠裹
		{AuraID = 285350, UnitID = "player", Flash = true},	-- 风暴哀嚎
		{AuraID = 285426, UnitID = "player", Flash = true},	-- 风暴哀嚎
		{AuraID = 287490, UnitID = "player"},	-- 冻结，吉安娜
		{AuraID = 287993, UnitID = "player"},	-- 寒冰之触
		{AuraID = 285253, UnitID = "player"},	-- 寒冰碎片
		{AuraID = 288394, UnitID = "player"},	-- 热量
		{AuraID = 288212, UnitID = "player"},	-- 舷侧攻击
		{AuraID = 288374, UnitID = "player"},	-- 破城者炮击
		-- 奥迪尔
		{AuraID = 271224, UnitID = "player", Text = L["Get Out"], Flash = true},	-- 赤红迸发，塔罗克
		{AuraID = 271225, UnitID = "player", Text = L["Get Out"], Flash = true},
		{AuraID = 278888, UnitID = "player", Text = L["Get Out"], Flash = true},
		{AuraID = 278889, UnitID = "player", Text = L["Get Out"], Flash = true},
		{AuraID = 267787, UnitID = "player"},	-- 消毒打击，纯净圣母
		{AuraID = 262313, UnitID = "player"},	-- 恶臭沼气，腐臭吞噬者
		{AuraID = 265237, UnitID = "player"},	-- 粉碎，泽克沃兹
		{AuraID = 265264, UnitID = "player"},	-- 虚空鞭笞，泽克沃兹
		{AuraID = 265360, UnitID = "player", Text = L["Get Out"], Flash = true},	-- 翻滚欺诈，泽克沃兹
		{AuraID = 265662, UnitID = "player"},	-- 腐化者的契约，泽克沃兹
		{AuraID = 265127, UnitID = "player"},	-- 持续感染，维克提斯
		{AuraID = 265129, UnitID = "player"},	-- 终极菌体，维克提斯
		{AuraID = 267160, UnitID = "player"},
		{AuraID = 267161, UnitID = "player"},
		{AuraID = 274990, UnitID = "player", Flash = true},	-- 破裂损伤，维克提斯
		{AuraID = 273434, UnitID = "player"},	-- 绝望深渊，祖尔
		{AuraID = 274271, UnitID = "player"},	-- 死亡之愿，祖尔
		{AuraID = 273365, UnitID = "player", Text = L["Get Out"], Flash = true},	-- 黑暗启示，祖尔
		{AuraID = 272146, UnitID = "player"},	-- 毁灭，拆解者
		{AuraID = 272536, UnitID = "player", Text = L["Get Out"], Flash = true},	-- 毁灭迫近，拆解者
		{AuraID = 274262, UnitID = "player", Text = L["Get Out"], Flash = true},	-- 爆炸腐蚀，戈霍恩
		{AuraID = 267409, UnitID = "player"},	-- 黑暗交易，戈霍恩
		{AuraID = 263227, UnitID = "player"},	-- 腐败之血，戈霍恩
		{AuraID = 267700, UnitID = "player"},	-- 戈霍恩的凝视，戈霍恩
		{AuraID = 273405, UnitID = "player"},	-- 黑暗交易，戈霍恩
	},
	["Warning"] = {			-- Target important halo group
		-- phantom
		{AuraID = 304975, UnitID = "target", Value = true},	-- 虚空哀嚎，吸收盾
		{AuraID = 319643, UnitID = "target", Value = true},	-- Howling Void, Absorbing Shield
		-- Rice
		{AuraID = 226510, UnitID = "target"},	-- Blood pool
		-- 9.0 copies
		{AuraID = 322773, UnitID = "target", Value = true},	-- The other world, the blood barrier
		{AuraID = 320293, UnitID = "target", Value = true},	-- Theater of the Death, Melting into Death
		-- 8.0 copies
		{AuraID = 300011, UnitID = "target"},	-- Force Field Shield, Mechagon
		{AuraID = 257458, UnitID = "target"},	-- Liberty Town Tail King Vulnerable
		{AuraID = 260512, UnitID = "target"},	-- Soul harvest, temple
		{AuraID = 277965, UnitID = "target"},	-- Heavy munitions, siege 1
		{AuraID = 273721, UnitID = "target"},
		{AuraID = 256493, UnitID = "target"},	-- Burning Azerite, Mine 1
		{AuraID = 271867, UnitID = "target"},	-- Krypton gold wins, mining area 1
		-- 尼奥罗萨
		{AuraID = 313175, UnitID = "target"},	-- Hardened core, Wrathion
		{AuraID = 306005, UnitID = "target"},	-- Obsidian Skin, Maut
		{AuraID = 313208, UnitID = "target"},	-- Invisible Vision, Prophet Skitra
		{AuraID = 312329, UnitID = "target"},	-- Gobble, Shadha the Insatiable
		{AuraID = 312595, UnitID = "target"},	-- Explosive and corrosive, Dre Ajas
		{AuraID = 312750, UnitID = "target"},	-- Summon Nightmare, Raiden the Void
		{AuraID = 306990, UnitID = "target", Value = true},	-- Suitable outer membrane, Enzos shell
		{AuraID = 310126, UnitID = "target"},	-- Mind Shell, N'Zoth
		{AuraID = 312155, UnitID = "target"},	-- Fragmented self
		{AuraID = 313184, UnitID = "target"},	-- Synaptic shock
		-- 永恒王宫
		{AuraID = 296389, UnitID = "target"},	-- Upper Swirl, Radiance of Azshara
		{AuraID = 304951, UnitID = "target"},	-- Focus energy
		{AuraID = 295916, UnitID = "target"},	-- Ancient Storm
		{AuraID = 296650, UnitID = "target", Value = true},	-- Hardened Carapace, Lady Ashvane
		{AuraID = 299575, UnitID = "target"},	-- Commander's Wrath, Queen's Court
		{AuraID = 296716, UnitID = "target", Flash = true},	-- Checks and balances, Queen's Court
		{AuraID = 295099, UnitID = "target"},	-- Through the darkness, Zakkur
		-- Storm Forge
		{AuraID = 282741, UnitID = "target", Value = true},	-- Shadow Shell, the Secret Party of Sleepless
		{AuraID = 284722, UnitID = "target", Value = true},	-- Shadow Shell, Unat
		{AuraID = 287693, UnitID = "target", Flash = true},	-- Implicit connection
		{AuraID = 286310, UnitID = "target"},	-- Void Shield
		{AuraID = 285333, UnitID = "target"},	-- Unnatural regeneration
		{AuraID = 285642, UnitID = "target"},	-- Gift of N'Zoth: Hysteria
		-- Battle of Dazaro
		{AuraID = 284459, UnitID = "target"},	-- Fanatic, Warrior of Light
		{AuraID = 284436, UnitID = "target"},	-- Seal of Liquidation
		{AuraID = 282113, UnitID = "target"},	-- Vengeful fury
		{AuraID = 281936, UnitID = "target"},	-- Angry, Glorn, King of the Jungle
		{AuraID = 286425, UnitID = "target", Value = true},	-- Flame Shield, Master of Jade Fire
		{AuraID = 286436, UnitID = "target"},	-- Emerald Storm
		{AuraID = 284614, UnitID = "target"},	-- Focus on hostility, Fengling
		{AuraID = 284943, UnitID = "target"},	-- greedy
		{AuraID = 285945, UnitID = "target", Flash = true},	-- Fast Wind, Order of the Chosen
		{AuraID = 285893, UnitID = "target"},	-- Wild maul
		{AuraID = 282079, UnitID = "target"},	-- God's contract
		{AuraID = 284377, UnitID = "target"},	-- Without interest, King Rastakhan
		{AuraID = 284446, UnitID = "target"},	-- Blessing of Bonsanti
		{AuraID = 289169, UnitID = "target"},	-- Blessing of Bonsanti
		{AuraID = 284613, UnitID = "target"},	-- Natural dead field
		{AuraID = 286051, UnitID = "target"},	-- Faster than light, great craftsman
		{AuraID = 289699, UnitID = "target", Flash = true},	-- Power increase
		{AuraID = 286558, UnitID = "target", Value = true},	-- Tide Mask, Storm Wall
		{AuraID = 287995, UnitID = "target", Value = true},	-- Current shield
		{AuraID = 287322, UnitID = "target"},	-- Ice barrier, Jaina
		-- Uldir
		{AuraID = 271965, UnitID = "target"},	-- Energy Shutdown, Tarok
		{AuraID = 277548, UnitID = "target"},	-- Smash the darkness, mobs
		{AuraID = 278218, UnitID = "target"},	-- Call of the Void, Zek'voz
		{AuraID = 278220, UnitID = "target"},	-- Void detachment, Zekworth
		{AuraID = 265264, UnitID = "target"},	-- Void Flogging, Zek'voz
		{AuraID = 273432, UnitID = "target"},	-- Shadowbound, Zul
		{AuraID = 273288, UnitID = "target"},	-- Whirling pulsation, Zul
		{AuraID = 274230, UnitID = "target"},	-- Annihilate the Veil, Mythrax the Unraveler
		{AuraID = 276900, UnitID = "target"},	-- Critical Blaze, Mythrax the Unraveler
		{AuraID = 279013, UnitID = "target"},	-- Fragmented Essence, Mythrax the Deconstructor
		{AuraID = 263504, UnitID = "target"},	-- Restructuring shock, G'huun
		{AuraID = 273251, UnitID = "target"},	-- Restructuring shock, G'huun
		{AuraID = 263372, UnitID = "target"},	-- Energy Matrix, G'huun
		{AuraID = 270447, UnitID = "target"},	-- Corruption grows, G'huun
		{AuraID = 263217, UnitID = "target"},	-- Blood Shield, G'huun
		{AuraID = 275129, UnitID = "target"},	-- Bloated obesity, G'huun
		-- PVP
		{AuraID = 498, UnitID = "target"},		-- Holy Blessing
		{AuraID = 642, UnitID = "target"},		-- Holy Shield
		{AuraID = 871, UnitID = "target"},		-- Shield wall
		{AuraID = 5277, UnitID = "target"},		-- dodge
		{AuraID = 1044, UnitID = "target"},		-- Free blessing
		{AuraID = 6940, UnitID = "target"},		-- Sacrifice blessing
		{AuraID = 1022, UnitID = "target"},		-- Protection blessing
		{AuraID = 19574, UnitID = "target"},	-- Wild anger
		{AuraID = 23920, UnitID = "target"},	-- Spell reflection
		{AuraID = 31884, UnitID = "target"},	-- Vengeful fury
		{AuraID = 33206, UnitID = "target"},	-- Pain suppression
		{AuraID = 45438, UnitID = "target"},	-- Ice barrier
		{AuraID = 47585, UnitID = "target"},	-- dissipate
		{AuraID = 47788, UnitID = "target"},	-- Guardian Soul
		{AuraID = 48792, UnitID = "target"},	-- Frozen Toughness
		{AuraID = 48707, UnitID = "target"},	-- Anti-magic shield
		{AuraID = 61336, UnitID = "target"},	-- Survival instinct
		{AuraID = 197690, UnitID = "target"},	-- Defensive posture
		{AuraID = 147833, UnitID = "target"},	-- Aid
		{AuraID = 186265, UnitID = "target"},	-- Guardian of the Turtle
		{AuraID = 113862, UnitID = "target"},	-- Enhanced invisibility
		{AuraID = 118038, UnitID = "target"},	-- The sword is here
		{AuraID = 114050, UnitID = "target"},	-- Rise element
		{AuraID = 114051, UnitID = "target"},	-- Rise Enhance
		{AuraID = 114052, UnitID = "target"},	-- Rise restore
		{AuraID = 204018, UnitID = "target"},	-- Curse Breaking Blessing
		{AuraID = 205191, UnitID = "target"},	-- Eye for an Eye discipline
		{AuraID = 104773, UnitID = "target"},	-- Unbreakable determination
		{AuraID = 199754, UnitID = "target"},	-- fight back
		{AuraID = 120954, UnitID = "target"},	-- Courage wine
		{AuraID = 122278, UnitID = "target"},	-- Not bad
		{AuraID = 122783, UnitID = "target"},	-- Sanmo
		{AuraID = 188499, UnitID = "target"},	-- Blade Dance
		{AuraID = 210152, UnitID = "target"},	-- Blade Dance
		{AuraID = 247938, UnitID = "target"},	-- Chaos Blade
		{AuraID = 212800, UnitID = "target"},	-- Ill shadow
		{AuraID = 162264, UnitID = "target"},	-- Metamorphosis
		{AuraID = 187827, UnitID = "target"},	-- Metamorphosis
		{AuraID = 125174, UnitID = "target"},	-- Karma Touch
		{AuraID = 171607, UnitID = "target"},	-- Love ray
		{AuraID = 228323, UnitID = "target", Value = true},	-- Crota's Shield
	},
	["InternalCD"] = { -- Custom built-in cooling group
		{IntID = 240447, Duration = 20},	-- trample
		{IntID = 295840, Duration = 30, OnSuccess = true},	-- Guardian of Azeroth
		{IntID = 114018, Duration = 15, OnSuccess = true, UnitID = "all"},	-- Curtain
	},
}

Module:AddNewAuraWatch("ALL", list)