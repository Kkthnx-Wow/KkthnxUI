local K = KkthnxUI[1]
local Module = K:GetModule("AurasTable")

if K.Class ~= "WARLOCK" then
	return
end

local list = {
	["Special Aura"] = { -- 玩家重要光环组
		{ AuraID = 89751, UnitID = "pet" }, -- 魔刃风暴
		{ AuraID = 216695, UnitID = "player" }, -- 被折磨的灵魂
		{ AuraID = 104773, UnitID = "player" }, -- 不灭决心
		{ AuraID = 199281, UnitID = "player" }, -- 痛上加痛
		{ AuraID = 196606, UnitID = "player" }, -- 暗影启迪
		{ AuraID = 111400, UnitID = "player" }, -- 爆燃冲刺
		{ AuraID = 115831, UnitID = "pet" }, -- 愤怒风暴
		{ AuraID = 193396, UnitID = "pet" }, -- 恶魔增效
		{ AuraID = 117828, UnitID = "player" }, -- 爆燃
		{ AuraID = 196098, UnitID = "player" }, -- 灵魂收割
		{ AuraID = 205146, UnitID = "player" }, -- 魔性征兆
		{ AuraID = 216708, UnitID = "player" }, -- 逆风收割者
		{ AuraID = 235156, UnitID = "player" }, -- 强化生命分流
		{ AuraID = 108416, UnitID = "player", Value = true }, -- 黑暗契约
		{ AuraID = 264173, UnitID = "player" }, -- 恶魔之核
		{ AuraID = 265273, UnitID = "player" }, -- 恶魔之力
		{ AuraID = 212295, UnitID = "player" }, -- 虚空守卫
		{ AuraID = 267218, UnitID = "player" }, -- 虚空传送门
		{ AuraID = 113858, UnitID = "player" }, -- 黑暗灵魂：动荡
		{ AuraID = 113860, UnitID = "player" }, -- 黑暗灵魂：哀难
		{ AuraID = 264571, UnitID = "player" }, -- 夜幕
		{ AuraID = 266030, UnitID = "player" }, -- 熵能返转
	},
	["Focus Aura"] = { -- 焦点光环组
		{ AuraID = 980, UnitID = "focus", Caster = "player" }, -- 痛楚
		{ AuraID = 146739, UnitID = "focus", Caster = "player" }, -- 腐蚀术
		{ AuraID = 233490, UnitID = "focus", Caster = "player" }, -- 痛苦无常
		{ AuraID = 233496, UnitID = "focus", Caster = "player" }, -- 痛苦无常
		{ AuraID = 233497, UnitID = "focus", Caster = "player" }, -- 痛苦无常
		{ AuraID = 233498, UnitID = "focus", Caster = "player" }, -- 痛苦无常
		{ AuraID = 233499, UnitID = "focus", Caster = "player" }, -- 痛苦无常
		{ AuraID = 157736, UnitID = "focus", Caster = "player" }, -- 献祭
		{ AuraID = 265412, UnitID = "focus", Caster = "player" }, -- 厄运
	},
	["Spell Cooldown"] = { -- 冷却计时组
		{ SlotID = 13 }, -- 饰品1
		{ SlotID = 14 }, -- 饰品2
	},
}

Module:AddNewAuraWatch("WARLOCK", list)
