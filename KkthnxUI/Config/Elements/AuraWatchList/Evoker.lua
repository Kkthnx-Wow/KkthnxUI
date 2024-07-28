local K = KkthnxUI[1]
local Module = K:GetModule("AurasTable")

if K.Class ~= "EVOKER" then
	return
end

local list = {
	["Special Aura"] = { -- 玩家重要光环组
		{ AuraID = 358267, UnitID = "player" }, -- 悬空
		{ AuraID = 375087, UnitID = "player" }, -- 狂龙之怒
		{ AuraID = 374348, UnitID = "player" }, -- 新生光焰
		{ AuraID = 359618, UnitID = "player" }, -- 精华迸发
		{ AuraID = 369299, UnitID = "player" }, -- 精华迸发
		{ AuraID = 392268, UnitID = "player" }, -- 精华迸发
		{ AuraID = 363916, UnitID = "player" }, -- 黑曜鳞片
		{ AuraID = 386353, UnitID = "player" }, -- 虹彩变换
		{ AuraID = 386399, UnitID = "player" }, -- 虹彩变换
		{ AuraID = 370553, UnitID = "player", Flash = true }, -- 扭转天平
		{ AuraID = 370818, UnitID = "player", Flash = true }, -- 瞬焰
		{ AuraID = 362877, UnitID = "player", Stack = 3 }, -- 时光压缩
		{ AuraID = 370537, UnitID = "player", Flash = true }, -- 静滞
		{ AuraID = 370562, UnitID = "player", Flash = true }, -- 静滞
		{ AuraID = 371877, UnitID = "player", Value = true }, -- 生生不息
		{ AuraID = 395296, UnitID = "player" }, -- 黑檀之力
	},
	["Focus Aura"] = { -- 焦点光环组
		--{AuraID = 772, UnitID = "focus", Caster = "player"}, -- 撕裂
	},
	["Spell Cooldown"] = { -- 冷却计时组
		{ SlotID = 13 }, -- 饰品1
		{ SlotID = 14 }, -- 饰品2
	},
}

Module:AddNewAuraWatch("EVOKER", list)
