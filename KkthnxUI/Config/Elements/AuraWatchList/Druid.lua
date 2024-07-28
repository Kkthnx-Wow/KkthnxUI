local K = KkthnxUI[1]
local Module = K:GetModule("AurasTable")

if K.Class ~= "DRUID" then
	return
end

local list = {
	["Special Aura"] = { -- 玩家重要光环组
		{ AuraID = 5217, UnitID = "player" }, -- 猛虎之怒
		{ AuraID = 48517, UnitID = "player" }, -- 日蚀
		{ AuraID = 48518, UnitID = "player" }, -- 月蚀
		{ AuraID = 52610, UnitID = "player" }, -- 野蛮咆哮
		{ AuraID = 69369, UnitID = "player" }, -- 掠食者的迅捷
		{ AuraID = 61336, UnitID = "player" }, -- 生存本能
		{ AuraID = 22842, UnitID = "player" }, -- 狂暴回复
		{ AuraID = 93622, UnitID = "player" }, -- 裂伤
		{ AuraID = 22812, UnitID = "player" }, -- 树皮术
		{ AuraID = 16870, UnitID = "player" }, -- 节能施法
		{ AuraID = 135700, UnitID = "player" }, -- 节能施法
		{ AuraID = 106951, UnitID = "player" }, -- 狂暴
		{ AuraID = 210649, UnitID = "player" }, -- 野性本能
		{ AuraID = 192081, UnitID = "player" }, -- 铁鬃
		{ AuraID = 102560, UnitID = "player" }, -- 化身
		{ AuraID = 117679, UnitID = "player" }, -- 化身
		{ AuraID = 102558, UnitID = "player" }, -- 化身
		{ AuraID = 102543, UnitID = "player" }, -- 化身
		{ AuraID = 145152, UnitID = "player" }, -- 血腥爪击
		{ AuraID = 191034, UnitID = "player" }, -- 星辰坠落
		{ AuraID = 194223, UnitID = "player" }, -- 超凡之盟
		{ AuraID = 200851, UnitID = "player" }, -- 沉睡者之怒
		{ AuraID = 213708, UnitID = "player" }, -- 星河守护者
		{ AuraID = 213680, UnitID = "player" }, -- 艾露恩的卫士
		{ AuraID = 155835, UnitID = "player" }, -- 鬃毛倒竖
		{ AuraID = 114108, UnitID = "player" }, -- 丛林之魂
		{ AuraID = 207640, UnitID = "player" }, -- 丰饶
		{ AuraID = 202425, UnitID = "player" }, -- 艾露恩的战士
		{ AuraID = 232378, UnitID = "player" }, -- 星界和谐，奶德2T19
		{ AuraID = 208253, UnitID = "player" }, -- 加尼尔的精华，奶德神器
		{ AuraID = 157228, UnitID = "player" }, -- 枭兽狂乱
		{ AuraID = 224706, UnitID = "player" }, -- 翡翠捕梦者
		{ AuraID = 242232, UnitID = "player" }, -- 星界加速
		{ AuraID = 209406, UnitID = "player" }, -- 欧奈斯的直觉
		{ AuraID = 209407, UnitID = "player" }, -- 欧奈斯的自负
		{ AuraID = 252752, UnitID = "player" }, -- T21野德
		{ AuraID = 253434, UnitID = "player" }, -- T21奶德
		{ AuraID = 252767, UnitID = "player" }, -- T21鸟德
		{ AuraID = 253575, UnitID = "player" }, -- T21熊德
		{ AuraID = 201671, UnitID = "player", Combat = true }, -- 血污毛皮
		{ AuraID = 203975, UnitID = "player", Combat = true }, -- 大地守卫者
		{ AuraID = 252216, UnitID = "player" }, -- 猛虎冲刺
		{ AuraID = 279709, UnitID = "player" }, -- 星辰领主
		{ AuraID = 279943, UnitID = "player" }, -- 锋利兽爪
		{ AuraID = 197721, UnitID = "player" }, -- 繁盛
	},
	["Focus Aura"] = { -- 焦点光环组
		{ AuraID = 774, UnitID = "focus", Caster = "player" }, -- 回春术
		{ AuraID = 8936, UnitID = "focus", Caster = "player" }, -- 愈合
		{ AuraID = 33763, UnitID = "focus", Caster = "player" }, -- 生命绽放
		{ AuraID = 188550, UnitID = "focus", Caster = "player" }, -- 生命绽放，橙装
		{ AuraID = 155777, UnitID = "focus", Caster = "player" }, -- 萌芽
		{ AuraID = 164812, UnitID = "focus", Caster = "player" }, -- 月火术
		{ AuraID = 164815, UnitID = "focus", Caster = "player" }, -- 阳炎术
		{ AuraID = 202347, UnitID = "focus", Caster = "player" }, -- 星辰耀斑
	},
	["Spell Cooldown"] = { -- 冷却计时组
		{ SlotID = 13 }, -- 饰品1
		{ SlotID = 14 }, -- 饰品2
		{ SpellID = 61336 }, -- 生存本能
	},
}

Module:AddNewAuraWatch("DRUID", list)
