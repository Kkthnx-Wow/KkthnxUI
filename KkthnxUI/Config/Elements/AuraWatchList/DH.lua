local K = KkthnxUI[1]
local Module = K:GetModule("AurasTable")

if K.Class ~= "DEMONHUNTER" then
	return
end

local list = {
	["Special Aura"] = { -- 玩家重要光环组
		{ AuraID = 162264, UnitID = "player" }, -- 恶魔变形
		{ AuraID = 187827, UnitID = "player" }, -- 恶魔变形
		{ AuraID = 188501, UnitID = "player" }, -- 幽灵视觉
		{ AuraID = 212800, UnitID = "player" }, -- 疾影
		{ AuraID = 203650, UnitID = "player" }, -- 准备就绪
		{ AuraID = 196555, UnitID = "player" }, -- 虚空行走
		{ AuraID = 208628, UnitID = "player" }, -- 势如破竹
		{ AuraID = 247938, UnitID = "player" }, -- 混乱之刃
		{ AuraID = 188499, UnitID = "player" }, -- 刃舞
		{ AuraID = 210152, UnitID = "player" }, -- 刃舞
		{ AuraID = 207693, UnitID = "player" }, -- 灵魂盛宴
		{ AuraID = 203819, UnitID = "player" }, -- 恶魔尖刺
		{ AuraID = 212988, UnitID = "player" }, -- 痛苦使者
		{ AuraID = 208579, UnitID = "player" }, -- 涅墨西斯
		{ AuraID = 208605, UnitID = "player" }, -- 涅墨西斯
		{ AuraID = 208607, UnitID = "player" }, -- 涅墨西斯
		{ AuraID = 208608, UnitID = "player" }, -- 涅墨西斯
		{ AuraID = 208609, UnitID = "player" }, -- 涅墨西斯
		{ AuraID = 208610, UnitID = "player" }, -- 涅墨西斯
		{ AuraID = 208611, UnitID = "player" }, -- 涅墨西斯
		{ AuraID = 208612, UnitID = "player" }, -- 涅墨西斯
		{ AuraID = 208613, UnitID = "player" }, -- 涅墨西斯
		{ AuraID = 208614, UnitID = "player" }, -- 涅墨西斯
		{ AuraID = 247253, UnitID = "player" }, -- 剑刃扭转
		{ AuraID = 252165, UnitID = "player" }, -- 浩劫T21
		{ AuraID = 216758, UnitID = "player" }, -- 无尽吸血
		{ AuraID = 263648, UnitID = "player", Value = true }, -- 灵魂壁障
		{ AuraID = 218561, UnitID = "player", Value = true }, -- 虹吸能量
		{ AuraID = 258920, UnitID = "player" }, -- 献祭光环
		{ AuraID = 343312, UnitID = "player" }, -- 狂怒凝视
		{ AuraID = 203981, UnitID = "player", Combat = true }, -- 灵魂残片
	},
	["Focus Aura"] = { -- 焦点光环组
	},
	["Spell Cooldown"] = { -- 冷却计时组
		{ SlotID = 13 }, -- 饰品1
		{ SlotID = 14 }, -- 饰品2
		{ SpellID = 191427 }, -- 恶魔变形
		{ SpellID = 187827 }, -- 恶魔变形
	},
}

Module:AddNewAuraWatch("DEMONHUNTER", list)
