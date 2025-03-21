local K = KkthnxUI[1]
local Module = K:GetModule("AurasTable")

if K.Class ~= "HUNTER" then
	return
end

local list = {
	["Special Aura"] = { -- 玩家重要光环组
		{ AuraID = 19574, UnitID = "player" }, -- 狂野怒火
		{ AuraID = 54216, UnitID = "player" }, -- 主人的召唤
		{ AuraID = 186257, UnitID = "player" }, -- 猎豹守护
		{ AuraID = 186265, UnitID = "player" }, -- 灵龟守护
		{ AuraID = 190515, UnitID = "player" }, -- 适者生存
		{ AuraID = 193534, UnitID = "player" }, -- 稳固集中
		{ AuraID = 194594, UnitID = "player", Flash = true }, -- 荷枪实弹
		{ AuraID = 118455, UnitID = "pet", Flash = true, Text = "AoE" }, -- 野兽瞬劈斩
		{ AuraID = 207094, UnitID = "pet" }, -- 泰坦之雷
		{ AuraID = 217200, UnitID = "pet" }, -- 凶猛狂暴
		{ AuraID = 272790, UnitID = "pet" }, -- 狂暴
		{ AuraID = 209997, UnitID = "pet", Flash = true }, -- 装死
		{ AuraID = 193530, UnitID = "player" }, -- 野性守护
		{ AuraID = 185791, UnitID = "player" }, -- 荒野呼唤
		{ AuraID = 259388, UnitID = "player" }, -- 猫鼬之怒
		{ AuraID = 186289, UnitID = "player" }, -- 雄鹰守护
		{ AuraID = 201081, UnitID = "player" }, -- 莫克纳萨战术
		{ AuraID = 194407, UnitID = "player" }, -- 喷毒眼镜蛇
		{ AuraID = 208888, UnitID = "player" }, -- 暗影猎手的回复，橙装头
		{ AuraID = 204090, UnitID = "player" }, -- 正中靶心
		{ AuraID = 208913, UnitID = "player" }, -- 哨兵视野，橙腰
		{ AuraID = 248085, UnitID = "player" }, -- 蛇语者之舌，橙胸
		{ AuraID = 242243, UnitID = "player" }, -- 致命瞄准，射击2T20
		{ AuraID = 246153, UnitID = "player" }, -- 精准，射击4T20
		{ AuraID = 203155, UnitID = "player" }, -- 狙击
		{ AuraID = 235712, UnitID = "player", Combat = true }, -- 回转稳定，橙手
		{ AuraID = 264735, UnitID = "player" }, -- 优胜劣汰
		{ AuraID = 281195, UnitID = "player" }, -- 优胜劣汰
		{ AuraID = 260395, UnitID = "player" }, -- 致命射击
		{ AuraID = 269502, UnitID = "player" }, -- 致命射击
		{ AuraID = 281036, UnitID = "player" }, -- 凶暴野兽
		{ AuraID = 400456, UnitID = "player", Flash = true }, -- 齐射
		{ AuraID = 266779, UnitID = "player" }, -- 协调进攻
		{ AuraID = 260286, UnitID = "player" }, -- 利刃之矛
		{ AuraID = 265898, UnitID = "player" }, -- 接战协定
		{ AuraID = 268552, UnitID = "player" }, -- 蝰蛇毒液
		{ AuraID = 257622, UnitID = "player", Text = "AoE" }, -- 技巧射击
		{ AuraID = 288613, UnitID = "player" }, -- 百发百中
		{ AuraID = 274447, UnitID = "player" }, -- 千里之目
		{ AuraID = 260243, UnitID = "player" }, -- 乱射
		{ AuraID = 336892, UnitID = "player", Flash = true }, -- 无懈警戒之秘
		{ AuraID = 388035, UnitID = "player" }, -- 巨熊之韧
		{ AuraID = 392956, UnitID = "player" }, -- 巨熊之韧
		{ AuraID = 407405, UnitID = "player" }, -- 弦之韵律
		{ AuraID = 359844, UnitID = "player" }, -- 荒野的召唤
		{ AuraID = 360952, UnitID = "player" }, -- 协同进攻
		{ AuraID = 459859, UnitID = "player" }, -- 投弹手
		{ AuraID = 388045, UnitID = "player", Flash = true }, -- 警戒
		{ AuraID = 378770, UnitID = "player", Flash = true }, -- 夺命打击
		{ AuraID = 378747, UnitID = "player", Flash = true }, -- 凶暴兽群
		{ AuraID = 459759, UnitID = "player", Flash = true, Stack = 4 }, -- 黑鸦
		{ AuraID = 459689, UnitID = "player", Flash = true, Stack = 5 }, -- 毒蛇钉刺

		{ AuraID = 394366, UnitID = "player" }, -- 密迹寻踪，射击2T
		{ AuraID = 394384, UnitID = "player", Flash = true }, -- 集中瞄准，射击4T
		{ AuraID = 394388, UnitID = "player", Flash = true }, -- 狂野弹幕，生存4T

		{ AuraID = 410147, UnitID = "player", Flash = true }, -- 暴露伤口，生存2T
	},
	["Focus Aura"] = { -- 焦点光环组
		{ AuraID = 3355, UnitID = "focus", Caster = "player" }, -- 冰冻陷阱
		{ AuraID = 19386, UnitID = "focus", Caster = "player" }, -- 翼龙钉刺
		{ AuraID = 118253, UnitID = "focus", Caster = "player" }, -- 毒蛇钉刺
		{ AuraID = 194599, UnitID = "focus", Caster = "player" }, -- 黑箭
		{ AuraID = 131894, UnitID = "focus", Caster = "player" }, -- 夺命黑鸦
		{ AuraID = 199803, UnitID = "focus", Caster = "player" }, -- 精确瞄准
	},
	["Spell Cooldown"] = { -- 冷却计时组
		{ AuraID = 471877, UnitID = "player" }, -- 猎群领袖之嚎
		{ SlotID = 13 }, -- 饰品1
		{ SlotID = 14 }, -- 饰品2
		{ SpellID = 186265 }, -- 灵龟守护
		{ SpellID = 147362 }, -- 反制射击
		{ SpellID = 288613 }, -- 百发百中
	},
}

Module:AddNewAuraWatch("HUNTER", list)
