local K = KkthnxUI[1]
local Module = K:GetModule("AurasTable")

if K.Class ~= "SHAMAN" then
	return
end

local list = {
	["Special Aura"] = { -- 玩家重要光环组
		{ AuraID = 73920, UnitID = "player" }, -- 治疗之雨
		{ AuraID = 53390, UnitID = "player" }, -- 潮汐奔涌
		{ AuraID = 79206, UnitID = "player" }, -- 灵魂行者的恩赐
		{ AuraID = 73685, UnitID = "player" }, -- 生命释放
		{ AuraID = 58875, UnitID = "player" }, -- 幽魂步
		{ AuraID = 77762, UnitID = "player" }, -- 熔岩奔腾
		{ AuraID = 208416, UnitID = "player" }, -- 十万火急
		{ AuraID = 207527, UnitID = "player" }, -- 迷雾幽灵
		{ AuraID = 207288, UnitID = "player" }, -- 女王的祝福
		{ AuraID = 216251, UnitID = "player" }, -- 波动
		{ AuraID = 108281, UnitID = "player" }, -- 先祖指引
		{ AuraID = 114050, UnitID = "player" }, -- 升腾 元素
		{ AuraID = 114051, UnitID = "player" }, -- 升腾 增强
		{ AuraID = 114052, UnitID = "player" }, -- 升腾 恢复
		{ AuraID = 108271, UnitID = "player" }, -- 星界转移
		{ AuraID = 204945, UnitID = "player" }, -- 毁灭之风
		{ AuraID = 201846, UnitID = "player" }, -- 风暴使者
		{ AuraID = 199055, UnitID = "player" }, -- 毁灭释放
		{ AuraID = 201898, UnitID = "player" }, -- 风歌
		{ AuraID = 215785, UnitID = "player" }, -- 灼热之手
		{ AuraID = 191877, UnitID = "player" }, -- 漩涡之力
		{ AuraID = 205495, UnitID = "player" }, -- 风暴守护者
		{ AuraID = 118522, UnitID = "player" }, -- 元素冲击 爆击
		{ AuraID = 173183, UnitID = "player" }, -- 元素冲击 急速
		{ AuraID = 173184, UnitID = "player" }, -- 元素冲击 精通
		{ AuraID = 210714, UnitID = "player" }, -- 冰怒
		{ AuraID = 157504, UnitID = "player", Value = true }, -- 暴雨图腾
		{ AuraID = 280615, UnitID = "player" }, -- 迅捷洪流
		{ AuraID = 273323, UnitID = "player" }, -- 闪电护盾超载
		{ AuraID = 272737, UnitID = "player" }, -- 无穷力量
		{ AuraID = 263806, UnitID = "player" }, -- 呼啸狂风
		{ AuraID = 191634, UnitID = "player" }, -- 风暴守护者
		{ AuraID = 202004, UnitID = "player" }, -- 山崩
		{ AuraID = 262652, UnitID = "player" }, -- 强风
		{ AuraID = 224125, UnitID = "player" }, -- 火
		{ AuraID = 224126, UnitID = "player" }, -- 冰
		{ AuraID = 224127, UnitID = "player" }, -- 电
		{ AuraID = 187878, UnitID = "player" }, -- 毁灭闪电
		{ AuraID = 288675, UnitID = "player" }, -- 浪潮汹涌
		{ AuraID = 320125, UnitID = "player" }, -- 回响震击
		{ AuraID = 344179, UnitID = "player", Combat = true }, -- 漩涡武器
	},
	["Focus Aura"] = { -- 焦点光环组
		{ AuraID = 51514, UnitID = "focus", Caster = "player" }, -- 妖术
		{ AuraID = 210873, UnitID = "focus", Caster = "player" }, -- 妖术
		{ AuraID = 211004, UnitID = "focus", Caster = "player" }, -- 妖术
		{ AuraID = 211010, UnitID = "focus", Caster = "player" }, -- 妖术
		{ AuraID = 211015, UnitID = "focus", Caster = "player" }, -- 妖术
	},
	["Spell Cooldown"] = { -- 冷却计时组
		{ SlotID = 13 }, -- 饰品1
		{ SlotID = 14 }, -- 饰品2
		{ SpellID = 20608 }, -- 复生
		{ SpellID = 98008 }, -- 灵魂链接
		{ SpellID = 114050 }, -- 升腾 元素
		{ SpellID = 114051 }, -- 升腾 增强
		{ SpellID = 114052 }, -- 升腾 恢复
		{ SpellID = 108280 }, -- 治疗之潮
		{ SpellID = 198506 }, -- 野性狼魂
	},
}

Module:AddNewAuraWatch("SHAMAN", list)
