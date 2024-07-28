local K = KkthnxUI[1]
local Module = K:GetModule("AurasTable")

if K.Class ~= "MAGE" then
	return
end

local list = {
	["Special Aura"] = { -- 玩家重要光环组
		{ AuraID = 66, UnitID = "player" }, -- 隐形术
		{ AuraID = 45438, UnitID = "player" }, -- 寒冰屏障
		{ AuraID = 36032, UnitID = "player" }, -- 奥术充能
		{ AuraID = 12042, UnitID = "player" }, -- 奥术强化
		{ AuraID = 12472, UnitID = "player" }, -- 冰冷血脉
		{ AuraID = 44544, UnitID = "player" }, -- 寒冰指
		{ AuraID = 48108, UnitID = "player" }, -- 炎爆术！
		{ AuraID = 48107, UnitID = "player" }, -- 热力迸发
		{ AuraID = 108843, UnitID = "player" }, -- 炽热疾速
		{ AuraID = 116267, UnitID = "player" }, -- 咒术洪流
		{ AuraID = 116014, UnitID = "player" }, -- 能量符文
		{ AuraID = 108839, UnitID = "player" }, -- 浮冰
		{ AuraID = 205025, UnitID = "player" }, -- 气定神闲
		{ AuraID = 113862, UnitID = "player" }, -- 强化隐形术
		{ AuraID = 194329, UnitID = "player" }, -- 炽烈之咒
		{ AuraID = 190319, UnitID = "player" }, -- 燃烧
		{ AuraID = 212799, UnitID = "player" }, -- 置换
		{ AuraID = 198924, UnitID = "player" }, -- 加速
		{ AuraID = 205473, UnitID = "player" }, -- 冰刺
		{ AuraID = 205766, UnitID = "player" }, -- 刺骨冰寒
		{ AuraID = 209455, UnitID = "player" }, -- 凯尔萨斯的绝招，抱歉护腕
		{ AuraID = 263725, UnitID = "player" }, -- 节能施法
		{ AuraID = 264774, UnitID = "player" }, -- 三之准则
		{ AuraID = 269651, UnitID = "player" }, -- 火焰冲撞
		{ AuraID = 190446, UnitID = "player" }, -- 冰冷智慧
		{ AuraID = 321363, UnitID = "player" }, -- 专注魔法
		{ AuraID = 324220, UnitID = "player" }, -- 死神之躯
	},
	["Focus Aura"] = { -- 焦点光环组
		{ AuraID = 44457, UnitID = "focus", Caster = "player" }, -- 活动炸弹
		{ AuraID = 114923, UnitID = "focus", Caster = "player" }, -- 虚空风暴
	},
	["Spell Cooldown"] = { -- 冷却计时组
		{ SlotID = 13 }, -- 饰品1
		{ SlotID = 14 }, -- 饰品2
		{ TotemID = 1 }, -- 能量符文
		{ SpellID = 12472 }, -- 冰冷血脉
		{ SpellID = 12042 }, -- 奥术强化
		{ SpellID = 190319 }, -- 燃烧
	},
}

Module:AddNewAuraWatch("MAGE", list)
