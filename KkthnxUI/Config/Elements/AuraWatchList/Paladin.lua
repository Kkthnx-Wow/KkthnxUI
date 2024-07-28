local K = KkthnxUI[1]
local Module = K:GetModule("AurasTable")

if K.Class ~= "PALADIN" then
	return
end

local list = {
	["Special Aura"] = { -- 玩家重要光环组
		{ AuraID = 498, UnitID = "player" }, -- 圣佑术
		{ AuraID = 642, UnitID = "player" }, -- 圣盾术
		{ AuraID = 31821, UnitID = "player" }, -- 光环掌握
		{ AuraID = 31884, UnitID = "player" }, -- 复仇之怒
		{ AuraID = 31850, UnitID = "player" }, -- 炽热防御者
		{ AuraID = 54149, UnitID = "player" }, -- 圣光灌注
		{ AuraID = 86659, UnitID = "player" }, -- 远古列王守卫
		{ AuraID = 231895, UnitID = "player" }, -- 征伐
		{ AuraID = 223819, UnitID = "player" }, -- 神圣意志
		{ AuraID = 209785, UnitID = "player" }, -- 正义之火
		{ AuraID = 217020, UnitID = "player" }, -- 狂热
		{ AuraID = 205191, UnitID = "player" }, -- 以眼还眼
		{ AuraID = 221885, UnitID = "player" }, -- 神圣马驹
		{ AuraID = 200652, UnitID = "player" }, -- 提尔的拯救
		{ AuraID = 214202, UnitID = "player" }, -- 律法之则
		{ AuraID = 105809, UnitID = "player" }, -- 神圣复仇者
		{ AuraID = 223316, UnitID = "player" }, -- 狂热殉道者
		{ AuraID = 200025, UnitID = "player" }, -- 美德道标
		{ AuraID = 132403, UnitID = "player" }, -- 正义盾击
		{ AuraID = 152262, UnitID = "player" }, -- 炽天使
		{ AuraID = 221883, UnitID = "player" }, -- 神圣马驹
		{ AuraID = 184662, UnitID = "player", Value = true }, -- 复仇之盾
		{ AuraID = 209388, UnitID = "player", Value = true }, -- 秩序堡垒
		{ AuraID = 267611, UnitID = "player" }, -- 正义裁决
		{ AuraID = 271581, UnitID = "player" }, -- 神圣审判
		{ AuraID = 84963, UnitID = "player" }, -- 异端裁决
		{ AuraID = 280375, UnitID = "player" }, -- 多面防御
		{ AuraID = 216331, UnitID = "player" }, -- 复仇十字军
		{ AuraID = 327225, UnitID = "player", Value = true }, -- 复仇原点
		{ AuraID = 327510, UnitID = "player", Flash = true }, -- 闪耀之光
	},
	["Focus Aura"] = { -- 焦点光环组
		{ AuraID = 53563, UnitID = "focus", Caster = "player" }, -- 圣光道标
		{ AuraID = 156910, UnitID = "focus", Caster = "player" }, -- 信仰道标
	},
	["Spell Cooldown"] = { -- 冷却计时组
		{ SlotID = 13 }, -- 饰品1
		{ SlotID = 14 }, -- 饰品2
		{ SpellID = 31884 }, -- 复仇之怒
		{ SpellID = 31821 }, -- 光环掌握
	},
}

Module:AddNewAuraWatch("PALADIN", list)
