local K, _, L = unpack(select(2, ...))
local Module = K:GetModule("AurasTable")

local list = {
	["Enchant Aura"] = {	-- 附魔及饰品组
		{AuraID = 354808, UnitID = "player"},	-- 棱彩之光，1万币的小宠物
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
		{AuraID = 307195, UnitID = "player"},	-- 隐秘精魂药水
		{AuraID = 342890, UnitID = "player"},	-- 无拘移动药水
		{AuraID = 322302, UnitID = "player"},	-- 献祭心能药水
		{AuraID = 307160, UnitID = "player"},	-- 硬化暗影药水
		-- 9.0饰品
		{AuraID = 344231, UnitID = "player"},	-- 赤红陈酿
		{AuraID = 345228, UnitID = "player"},	-- 角斗士徽章
		{AuraID = 344662, UnitID = "player"},	-- 碎裂心智
		{AuraID = 345439, UnitID = "player"},	-- 赤红华尔兹
		{AuraID = 345019, UnitID = "player"},	-- 潜伏的掠食者
		{AuraID = 345530, UnitID = "player"},	-- 过载的心能电池
		{AuraID = 345541, UnitID = "player"},	-- 天域涌动
		{AuraID = 336588, UnitID = "player"},	-- 唤醒者的复叶
		{AuraID = 348139, UnitID = "player"},	-- 导师的圣钟
		{AuraID = 311444, UnitID = "player", Value = true},	-- 不屈套牌
		{AuraID = 336465, UnitID = "player", Value = true},	-- 脉冲光辉护盾
		{AuraID = 330366, UnitID = "player", Text = L["Crit"]},	-- 不可思议的量子装置，暴击
		{AuraID = 330367, UnitID = "player", Text = L["Versa"]},	-- 不可思议的量子装置，全能
		{AuraID = 330368, UnitID = "player", Text = L["Haste"]},	-- 不可思议的量子装置，急速
		{AuraID = 330380, UnitID = "player", Text = L["Mastery"]},	-- 不可思议的量子装置，精通
		{AuraID = 351872, UnitID = "player"},	-- 钢铁尖刺
		{AuraID = 355316, UnitID = "player"},	-- 安海尔德之盾
		{AuraID = 356326, UnitID = "player"},	-- 折磨洞察
		{AuraID = 355333, UnitID = "player"},	-- 回收的聚变增幅器
		{AuraID = 357185, UnitID = "player"},	-- 忠诚的力量，低语威能碎片
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
		{AuraID = 345499, UnitID = "player"},	-- 执政官的祝福
		{AuraID = 339461, UnitID = "player"},	-- 猎手坚韧
		{AuraID = 325381, UnitID = "player", Flash = true},	-- 争先打击
		{AuraID = 342774, UnitID = "player"},	-- 繁华原野
		{AuraID = 333218, UnitID = "player"},	-- 废土礼节
		{AuraID = 336885, UnitID = "player"},	-- 抚慰阴影
		{AuraID = 324156, UnitID = "player", Flash = true},	-- 劫掠射击
		{AuraID = 328900, UnitID = "player"},	-- 放下过去
		{AuraID = 333961, UnitID = "player"},	-- 行动的召唤：布隆
		{AuraID = 333943, UnitID = "player"},	-- 源生重槌
		-- 心能
		{AuraID = 357852, UnitID = "player"},	-- 激励
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
		{AuraID = 178207, UnitID = "player"},	-- 狂怒战鼓
		{AuraID = 230935, UnitID = "player"},	-- 高山战鼓
		{AuraID = 256740, UnitID = "player"},	-- 漩涡战鼓
		{AuraID = 309658, UnitID = "player"},	-- 死亡凶蛮战鼓
		{AuraID = 102364, UnitID = "player"},	-- 青铜龙的祝福
		{AuraID = 292686, UnitID = "player"},	-- 制皮鼓
		-- 团队增益或减伤
		{AuraID = 1022, UnitID = "player"},		-- 保护祝福
		{AuraID = 6940, UnitID = "player"},		-- 牺牲祝福
		{AuraID = 1044, UnitID = "player"},		-- 自由祝福
		{AuraID = 10060, UnitID = "player"},	-- 能量灌注
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
		{AuraID = 145629, UnitID = "player"},	-- 反魔法领域
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
		{AuraID = 355732, UnitID = "player"},	-- 融化灵魂
		{AuraID = 356667, UnitID = "player"},	-- 刺骨之寒
		{AuraID = 356925, UnitID = "player"},	-- 屠戮
		{AuraID = 342466, UnitID = "player"},	-- 狂妄吹嘘，S1
		{AuraID = 209858, UnitID = "player"},	-- 死疽溃烂
		{AuraID = 240559, UnitID = "player"},	-- 重伤
		{AuraID = 340880, UnitID = "player"},	-- 傲慢
		{AuraID = 226512, UnitID = "player", Flash = true},	-- 血池
		{AuraID = 240447, UnitID = "player", Flash = true},	-- 践踏
		{AuraID = 240443, UnitID = "player", Flash = true},	-- 爆裂
		-- 5人本
		{AuraID = 327107, UnitID = "player"},	-- 赤红，闪耀光辉
		{AuraID = 340433, UnitID = "player"},	-- 赤红，堕罪之赐
		{AuraID = 324092, UnitID = "player", Flash = true},	-- 赤红，闪耀光辉
		{AuraID = 328737, UnitID = "player", Flash = true},	-- 赤红，光辉残片
		{AuraID = 326891, UnitID = "player", Flash = true},	-- 赎罪大厅，痛楚
		{AuraID = 319603, UnitID = "player", Flash = true},	-- 赎罪大厅，羁石诅咒
		{AuraID = 333299, UnitID = "player"},	-- 伤逝剧场，荒芜诅咒
		{AuraID = 319637, UnitID = "player"},	-- 伤逝剧场，魂魄归体
		{AuraID = 330725, UnitID = "player", Flash = true},	-- 伤逝剧场，暗影易伤
		{AuraID = 336258, UnitID = "player", Flash = true},	-- 凋魂之殇，落单狩猎
		{AuraID = 331399, UnitID = "player"},	-- 凋魂之殇，感染毒雨
		{AuraID = 333353, UnitID = "player"},	-- 凋魂之殇，暗影伏击
		{AuraID = 327401, UnitID = "player", Flash = true},	-- 通灵战潮，共受苦难
		{AuraID = 323471, UnitID = "player", Flash = true},	-- 通灵战潮，切肉飞刀
		{AuraID = 328181, UnitID = "player"},	-- 通灵战潮，凌冽之寒
		{AuraID = 327397, UnitID = "player"},	-- 通灵战潮，严酷命运
		{AuraID = 322681, UnitID = "player"},	-- 通灵战潮，肉钩
		{AuraID = 335161, UnitID = "player"},	-- 通灵战潮，残存心能
		{AuraID = 345323, UnitID = "player", Flash = true},	-- 通灵战潮，勇士之赐
		{AuraID = 320366, UnitID = "player", Flash = true},	-- 通灵战潮，防腐剂
		{AuraID = 322746, UnitID = "player"},	-- 彼界，堕落之血
		{AuraID = 323692, UnitID = "player"},	-- 彼界，奥术易伤
		{AuraID = 331379, UnitID = "player"},	-- 彼界，润滑剂
		{AuraID = 320786, UnitID = "player"},	-- 彼界，势不可挡
		{AuraID = 323687, UnitID = "player", Flash = true},	-- 彼界，奥术闪电
		{AuraID = 327893, UnitID = "player", Flash = true},	-- 彼界，邦桑迪的热情
		{AuraID = 339978, UnitID = "player", Flash = true},	-- 彼界，安抚迷雾
		{AuraID = 323569, UnitID = "player", Flash = true},	-- 彼界，溅洒精魂
		{AuraID = 334496, UnitID = "player"},	-- 彼界，催眠光粉
		{AuraID = 328453, UnitID = "player"},	-- 晋升高塔，压迫
		{AuraID = 335805, UnitID = "player", Flash = true},	-- 晋升高塔，执政官的壁垒
		{AuraID = 325027, UnitID = "player", Flash = true},	-- 仙林，荆棘爆发
		{AuraID = 356011, UnitID = "player"},	-- 集市，光线切分者
		{AuraID = 353421, UnitID = "player"},	-- 集市，精力
		{AuraID = 347949, UnitID = "player", Flash = true},	-- 集市，审讯
		{AuraID = 355915, UnitID = "player"},	-- 集市，约束雕文
		{AuraID = 347771, UnitID = "player"},	-- 集市，加急
		{AuraID = 346962, UnitID = "player", Flash = true},	-- 集市，现金汇款
		{AuraID = 348567, UnitID = "player"},	-- 集市，爵士乐
		{AuraID = 349627, UnitID = "player"},	-- 集市，暴食
		{AuraID = 350010, UnitID = "player", Flash = true},	-- 集市，被吞噬的心能
		{AuraID = 346828, UnitID = "player", Flash = true},	-- 集市，消毒区域
		{AuraID = 355581, UnitID = "player", Flash = true},	-- 集市，连环爆裂
		{AuraID = 346961, UnitID = "player", Flash = true},	-- 集市，净化之地
		{AuraID = 347481, UnitID = "player"},	-- 集市，奥能手里波
		{AuraID = 350013, UnitID = "player"},	-- 集市，暴食盛宴
		{AuraID = 350885, UnitID = "player"},	-- 集市，超光速震荡
		{AuraID = 350804, UnitID = "player"},	-- 集市，坍缩能量
		{AuraID = 349999, UnitID = "player"},	-- 集市，心能引爆
		{AuraID = 359019, UnitID = "player", Flash = true},	-- 集市，快拍提速
		-- 团本
		{AuraID = 342077, UnitID = "player"},	-- 回声定位，咆翼
		{AuraID = 329725, UnitID = "player"},	-- 根除，毁灭者
		{AuraID = 329298, UnitID = "player"},	-- 暴食胀气，毁灭者
		{AuraID = 325936, UnitID = "player"},	-- 共享认知，勋爵
		{AuraID = 346035, UnitID = "player"},	-- 眩目步法，猩红议会
		{AuraID = 331636, UnitID = "player", Flash = true},	-- 黑暗伴舞，猩红议会
		{AuraID = 335293, UnitID = "player"},	-- 锁链联结，泥拳
		{AuraID = 333913, UnitID = "player"},	-- 锁链联结，泥拳
		{AuraID = 327039, UnitID = "player"},	-- 邪恶撕裂，干将
		{AuraID = 344655, UnitID = "player"},	-- 震荡易伤，干将
		{AuraID = 327089, UnitID = "player"},	-- 喂食时间，德纳修斯
		{AuraID = 327796, UnitID = "player"},	-- 午夜猎手，德纳修斯

		{AuraID = 347283, UnitID = "player"},	-- 捕食者之嚎，塔拉格鲁
		{AuraID = 347286, UnitID = "player"},	-- 不散之惧，塔拉格鲁
	},
	["Warning"] = { -- 目标重要光环组
		{AuraID = 355596, UnitID = "target", Flash = true},	-- 橙弓，哀痛箭
		-- 大幻象
		{AuraID = 304975, UnitID = "target", Value = true},	-- 虚空哀嚎，吸收盾
		{AuraID = 319643, UnitID = "target", Value = true},	-- 虚空哀嚎，吸收盾
		-- 大米
		{AuraID = 226510, UnitID = "target"},	-- 血池回血
		{AuraID = 343502, UnitID = "target"},	-- 鼓舞光环
		-- 5人本
		{AuraID = 321754, UnitID = "target", Value = true},	-- 通灵战潮，冰缚之盾
		{AuraID = 343470, UnitID = "target", Value = true},	-- 通灵战潮，碎骨之盾
		{AuraID = 328351, UnitID = "target", Flash = true},	-- 通灵战潮，染血长枪
		{AuraID = 322773, UnitID = "target", Value = true},	-- 彼界，鲜血屏障
		{AuraID = 333227, UnitID = "target", Flash = true},	-- 彼界，不死之怒
		{AuraID = 228626, UnitID = "target"},	-- 彼界，怨灵之瓮
		{AuraID = 324010, UnitID = "target"},	-- 彼界，发射
		{AuraID = 320132, UnitID = "target"},	-- 彼界，暗影之怒
		{AuraID = 320293, UnitID = "target", Value = true},	-- 伤逝剧场，融入死亡
		{AuraID = 331275, UnitID = "target", Flash = true},	-- 伤逝剧场，不灭护卫
		{AuraID = 336449, UnitID = "target"},	-- 凋魂，玛卓克萨斯之墓
		{AuraID = 336451, UnitID = "target"},	-- 凋魂，玛卓克萨斯之壁
		{AuraID = 333737, UnitID = "target"},	-- 凋魂，凝结之疾
		{AuraID = 328175, UnitID = "target"},	-- 凋魂，凝结之疾
		{AuraID = 321368, UnitID = "target", Value = true},	-- 凋魂，冰缚之盾
		{AuraID = 327416, UnitID = "target", Value = true},	-- 晋升，心能回灌
		{AuraID = 345561, UnitID = "target", Value = true},	-- 晋升，生命连结
		{AuraID = 339917, UnitID = "target", Value = true},	-- 晋升，命运之矛
		{AuraID = 323878, UnitID = "target", Flash = true},	-- 晋升，枯竭
		{AuraID = 317936, UnitID = "target"},	-- 晋升，弃誓信条
		{AuraID = 327812, UnitID = "target"},	-- 晋升，振奋英气
		{AuraID = 323149, UnitID = "target"},	-- 仙林，黑暗之拥
		{AuraID = 340191, UnitID = "target", Value = true},	-- 仙林，再生辐光
		{AuraID = 323059, UnitID = "target", Flash = true},	-- 仙林，宗主之怒
		{AuraID = 336499, UnitID = "target"},	-- 仙林，猜谜游戏
		{AuraID = 322569, UnitID = "target"},	-- 仙林，兹洛斯之手
		{AuraID = 326771, UnitID = "target"},	-- 赎罪大厅，岩石监视者
		{AuraID = 326450, UnitID = "target"},	-- 赎罪大厅，忠心的野兽
		{AuraID = 322433, UnitID = "target"},	-- 赤红深渊，石肤术
		{AuraID = 321402, UnitID = "target"},	-- 赤红深渊，饱餐
		{AuraID = 355640, UnitID = "target"},	-- 集市，重装方阵
		{AuraID = 355782, UnitID = "target"},	-- 集市，力量增幅器
		{AuraID = 351086, UnitID = "target"},	-- 集市，势不可挡
		{AuraID = 347840, UnitID = "target"},	-- 集市，野性
		{AuraID = 347992, UnitID = "target"},	-- 集市，回旋防弹衣
		{AuraID = 347840, UnitID = "target"},	-- 集市，野性
		{AuraID = 347015, UnitID = "target", Flash = true},	-- 集市，强化防御
		-- 团本
		{AuraID = 345902, UnitID = "target"},	-- 破裂的联结，猎手
		{AuraID = 334695, UnitID = "target"},	-- 动荡的能量，猎手
		{AuraID = 346792, UnitID = "target"},	-- 罪触之刃，猩红议会
		{AuraID = 331314, UnitID = "target"},	-- 毁灭冲击，泥拳
		{AuraID = 341250, UnitID = "target"},	-- 恐怖暴怒，泥拳
		{AuraID = 329636, UnitID = "target", Flash = true},	-- 坚岩形态，干将
		{AuraID = 329808, UnitID = "target", Flash = true},	-- 坚岩形态，干将
		-- PVP
		{AuraID = 498, UnitID = "target"},		-- 圣佑术
		{AuraID = 642, UnitID = "target"},		-- 圣盾术
		{AuraID = 871, UnitID = "target"},		-- 盾墙
		{AuraID = 5277, UnitID = "target"},		-- 闪避
		{AuraID = 1044, UnitID = "target"},		-- Free blessing
		{AuraID = 6940, UnitID = "target"},		-- Sacrifice blessing
		{AuraID = 1022, UnitID = "target"},		-- Protection blessing
		{AuraID = 19574, UnitID = "target"},	-- Wild rage
		{AuraID = 23920, UnitID = "target"},	-- Spell reflection
		{AuraID = 31884, UnitID = "target"},	-- Vengeful rage
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
		{AuraID = 114050, UnitID = "target"},	-- Rise 元素
		{AuraID = 114051, UnitID = "target"},	-- Rise 增强
		{AuraID = 114052, UnitID = "target"},	-- Rise 恢复
		{AuraID = 204018, UnitID = "target"},	-- Curse Breaking Blessing
		{AuraID = 205191, UnitID = "target"},	-- Eye for an Eye 惩戒
		{AuraID = 104773, UnitID = "target"},	-- Unbreakable determination
		{AuraID = 199754, UnitID = "target"},	-- fight back
		{AuraID = 120954, UnitID = "target"},	-- Courage wine
		{AuraID = 122278, UnitID = "target"},	-- Not bad
		{AuraID = 122783, UnitID = "target"},	-- Demon Skill
		{AuraID = 188499, UnitID = "target"},	-- Blade Dance
		{AuraID = 210152, UnitID = "target"},	-- Blade Dance
		{AuraID = 247938, UnitID = "target"},	-- Chaos Blade
		{AuraID = 212800, UnitID = "target"},	-- Ill shadow
		{AuraID = 162264, UnitID = "target"},	-- Metamorphosis
		{AuraID = 187827, UnitID = "target"},	-- Metamorphosis
		{AuraID = 125174, UnitID = "target"},	-- Karma Touch
		{AuraID = 171607, UnitID = "target"},	-- Love ray
		{AuraID = 228323, UnitID = "target", Value = true},	-- 克罗塔的护盾
	},
	["InternalCD"] = { -- 自定义内置冷却组
		{IntID = 240447, Duration = 20},	-- 大米，践踏
		{IntID = 114018, Duration = 15, OnSuccess = true, UnitID = "all"},	-- 帷幕
		{IntID = 316958, Duration = 30, OnSuccess = true, UnitID = "all"},	-- 红土
	},
}

Module:AddNewAuraWatch("ALL", list)