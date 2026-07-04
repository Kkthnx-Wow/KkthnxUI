--[[-----------------------------------------------------------------------------
-- Live GUI refresh for player buff/debuff frame layout.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Auras")

local LAYOUT_KEYS = {
	BuffSize = true,
	BuffsPerRow = true,
	DebuffSize = true,
	DebuffsPerRow = true,
	ReverseBuffs = true,
	ReverseDebuffs = true,
	TotemSize = true,
	VerticalTotems = true,
}

local function OnAurasSetting(configPath)
	local key = configPath:match("^Auras%.(.+)$")
	if not key then
		return
	end

	if LAYOUT_KEYS[key] then
		if key == "TotemSize" or key == "VerticalTotems" then
			if Module.UpdateTotemBar then
				Module:UpdateTotemBar()
			end
		elseif Module.UpdateAuraLayout then
			Module:UpdateAuraLayout()
		end
	elseif key == "Enable" then
		Module:SetAurasEnabled(C["Auras"].Enable)
	elseif key == "HideBlizBuff" then
		if Module.HideBlizBuff then
			Module:HideBlizBuff()
		end
	elseif key == "Totems" then
		if Module.UpdateTotemBar then
			Module:UpdateTotemBar()
		end
	end
end

K:RegisterSettingPrefixCallback("Auras.", OnAurasSetting)
