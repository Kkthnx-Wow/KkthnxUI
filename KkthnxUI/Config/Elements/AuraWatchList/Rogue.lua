local K, L = KkthnxUI[1], KkthnxUI[3]
local Module = K:GetModule("AurasTable")

if K.Class ~= "ROGUE" then
	return
end

local list = {
	["Special Aura"] = { -- 玩家重要光环组
		{ AuraID = 1966, UnitID = "player" }, -- 佯攻
		{ AuraID = 5171, UnitID = "player" }, -- 切割
		{ AuraID = 5277, UnitID = "player" }, -- 闪避
		{ AuraID = 11327, UnitID = "player" }, -- 消失
		{ AuraID = 13750, UnitID = "player" }, -- 冲动
		{ AuraID = 13877, UnitID = "player" }, -- 剑刃乱舞
		{ AuraID = 31224, UnitID = "player" }, -- 暗影斗篷
		{ AuraID = 32645, UnitID = "player" }, -- 毒伤
		{ AuraID = 45182, UnitID = "player" }, -- 装死
		{ AuraID = 31665, UnitID = "player" }, -- 敏锐大师
		{ AuraID = 185311, UnitID = "player" }, -- 猩红之瓶
		{ AuraID = 193641, UnitID = "player" }, -- 深谋远虑
		{ AuraID = 115192, UnitID = "player" }, -- 诡诈
		{ AuraID = 193538, UnitID = "player" }, -- 敏锐
		{ AuraID = 121471, UnitID = "player" }, -- 暗影之刃
		{ AuraID = 185422, UnitID = "player" }, -- 影舞
		{ AuraID = 212283, UnitID = "player" }, -- 死亡标记
		{ AuraID = 202754, UnitID = "player" }, -- 隐秘刀刃
		{ AuraID = 193356, UnitID = "player", Text = L["Combo"] }, -- 强势连击，骰子
		{ AuraID = 193357, UnitID = "player", Text = L["Crit"] }, -- 暗鲨涌动，骰子
		{ AuraID = 193358, UnitID = "player", Text = L["Attack Speed"] }, -- 大乱斗，骰子
		{ AuraID = 193359, UnitID = "player", Text = L["CD"] }, -- 双巧手，骰子
		{ AuraID = 199603, UnitID = "player", Text = L["Strike"] }, -- 骷髅黑帆，骰子
		{ AuraID = 199600, UnitID = "player", Text = L["Power"] }, -- 埋藏的宝藏，骰子
		{ AuraID = 202665, UnitID = "player" }, -- 恐惧之刃诅咒
		{ AuraID = 199754, UnitID = "player" }, -- 还击
		{ AuraID = 195627, UnitID = "player" }, -- 可乘之机
		{ AuraID = 121153, UnitID = "player" }, -- 侧袭
		{ AuraID = 256735, UnitID = "player", Combat = true }, -- 刺客大师
		{ AuraID = 271896, UnitID = "player" }, -- 刀锋冲刺
		{ AuraID = 51690, UnitID = "player" }, -- 影舞步
		{ AuraID = 277925, UnitID = "player" }, -- 袖剑旋风
		{ AuraID = 196980, UnitID = "player" }, -- 暗影大师
		{ AuraID = 315496, UnitID = "player" }, -- 切割
		{ AuraID = 343142, UnitID = "player" }, -- 恐惧之刃
		{ AuraID = 381623, UnitID = "player" }, -- 菊花茶
	},
	["Focus Aura"] = { -- 焦点光环组
		{ AuraID = 6770, UnitID = "focus", Caster = "player" }, -- 闷棍
		{ AuraID = 2094, UnitID = "focus", Caster = "player" }, -- 致盲
	},
	["Spell Cooldown"] = { -- 冷却计时组
		{ SlotID = 13 }, -- 饰品1
		{ SlotID = 14 }, -- 饰品2
		{ SpellID = 13750 }, -- 冲动
		{ SpellID = 79140 }, -- 宿敌
		{ SpellID = 121471 }, -- 暗影之刃
	},
}

Module:AddNewAuraWatch("ROGUE", list)
