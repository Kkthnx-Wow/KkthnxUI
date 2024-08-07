local K = KkthnxUI[1]
local Module = K:GetModule("AurasTable")

if K.Class ~= "MONK" then
	return
end

local list = {
	["Special Aura"] = { -- 玩家重要光环组
		{ AuraID = 125174, UnitID = "player" }, -- 业报之触
		{ AuraID = 116768, UnitID = "player" }, -- 幻灭踢
		{ AuraID = 137639, UnitID = "player" }, -- 风火雷电
		{ AuraID = 122278, UnitID = "player" }, -- 躯不坏
		{ AuraID = 122783, UnitID = "player" }, -- 散魔功
		{ AuraID = 116844, UnitID = "player" }, -- 平心之环
		{ AuraID = 152173, UnitID = "player" }, -- 屏气凝神
		{ AuraID = 120954, UnitID = "player" }, -- 壮胆酒
		{ AuraID = 243435, UnitID = "player" }, -- 壮胆酒
		{ AuraID = 215479, UnitID = "player" }, -- 铁骨酒
		{ AuraID = 214373, UnitID = "player" }, -- 酒有余香
		{ AuraID = 199888, UnitID = "player" }, -- 神龙之雾
		{ AuraID = 116680, UnitID = "player" }, -- 雷光茶
		{ AuraID = 197908, UnitID = "player" }, -- 法力茶
		{ AuraID = 196741, UnitID = "player" }, -- 连击
		{ AuraID = 228563, UnitID = "player" }, -- 幻灭连击
		{ AuraID = 197916, UnitID = "player" }, -- 生生不息
		{ AuraID = 197919, UnitID = "player" }, -- 生生不息
		{ AuraID = 116841, UnitID = "player" }, -- 迅如猛虎
		{ AuraID = 195321, UnitID = "player" }, -- 转化力量
		{ AuraID = 213341, UnitID = "player" }, -- 胆略
		{ AuraID = 235054, UnitID = "player" }, -- 皇帝的容电皮甲
		{ AuraID = 124682, UnitID = "player", Caster = "player" }, -- 氤氲之雾
		{ AuraID = 261769, UnitID = "player" }, -- 铁布衫
		{ AuraID = 195630, UnitID = "player" }, -- 醉拳大师
		{ AuraID = 115295, UnitID = "player", Value = true }, -- 金钟罩
		{ AuraID = 116847, UnitID = "player" }, -- 碧玉疾风
		{ AuraID = 322507, UnitID = "player", Value = true }, -- 天神酒
		{ AuraID = 325092, UnitID = "player" }, -- 净化真气
	},
	["Focus Aura"] = { -- 焦点光环组
		{ AuraID = 115078, UnitID = "focus", Caster = "player" }, -- 分筋错骨
		{ AuraID = 119611, UnitID = "focus", Caster = "player" }, -- 复苏之雾
	},
	["Spell Cooldown"] = { -- 冷却计时组
		{ SlotID = 13 }, -- 饰品1
		{ SlotID = 14 }, -- 饰品2
		{ SpellID = 115203 }, -- 壮胆酒
	},
}

Module:AddNewAuraWatch("MONK", list)
