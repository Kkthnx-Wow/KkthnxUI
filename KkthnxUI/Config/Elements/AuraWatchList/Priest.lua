local K = KkthnxUI[1]
local Module = K:GetModule("AurasTable")

if K.Class ~= "PRIEST" then
	return
end

local list = {
	["Special Aura"] = { -- 玩家重要光环组
		{ AuraID = 17, UnitID = "player", Caster = "player" }, -- 真言术：盾
		{ AuraID = 194384, UnitID = "player", Caster = "player" }, -- 救赎
		{ AuraID = 27827, UnitID = "player" }, -- 救赎之魂
		{ AuraID = 47536, UnitID = "player" }, -- 全神贯注
		{ AuraID = 65081, UnitID = "player" }, -- 身心合一
		{ AuraID = 47585, UnitID = "player" }, -- 消散
		{ AuraID = 15286, UnitID = "player" }, -- 吸血鬼的拥抱
		{ AuraID = 197937, UnitID = "player" }, -- 延宕狂乱
		{ AuraID = 194249, UnitID = "player" }, -- 虚空形态
		{ AuraID = 205372, UnitID = "player" }, -- 虚空射线
		{ AuraID = 193223, UnitID = "player" }, -- 疯入膏肓
		{ AuraID = 196490, UnitID = "player" }, -- 纳鲁之能
		{ AuraID = 114255, UnitID = "player" }, -- 圣光涌动
		{ AuraID = 196644, UnitID = "player" }, -- 图雷的祝福
		{ AuraID = 197030, UnitID = "player" }, -- 圣洁
		{ AuraID = 200183, UnitID = "player" }, -- 神圣化身
		{ AuraID = 197763, UnitID = "player" }, -- 争分夺秒
		{ AuraID = 198069, UnitID = "player" }, -- 阴暗面之力
		{ AuraID = 123254, UnitID = "player" }, -- 命运多舛
		{ AuraID = 211440, UnitID = "player" }, -- 神牧神器
		{ AuraID = 211442, UnitID = "player" }, -- 神牧神器
		{ AuraID = 252848, UnitID = "player" }, -- T21戒律
		{ AuraID = 253437, UnitID = "player" }, -- T21神圣2
		{ AuraID = 253443, UnitID = "player" }, -- T21神圣4
		{ AuraID = 216135, UnitID = "player" }, -- 戒律法袍
		{ AuraID = 271466, UnitID = "player" }, -- 微光屏障
		{ AuraID = 124430, UnitID = "player" }, -- 暗影洞察
		{ AuraID = 197871, UnitID = "player" }, -- 黑暗天使长
	},
	["Focus Aura"] = { -- 焦点光环组
		{ AuraID = 139, UnitID = "focus", Caster = "player" }, -- 恢复
	},
	["Spell Cooldown"] = { -- 冷却计时组
		{ SlotID = 13 }, -- 饰品1
		{ SlotID = 14 }, -- 饰品2
		{ SpellID = 64843 }, -- 神圣赞美诗
		{ SpellID = 33206 }, -- 痛苦压制
	},
}

Module:AddNewAuraWatch("PRIEST", list)
