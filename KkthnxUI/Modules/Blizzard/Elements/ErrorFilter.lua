local K, C = unpack(select(2, ...))
local Module = K:GetModule("Blizzard")

local InCombatLockdown = _G.InCombatLockdown
local UIErrorsFrame = _G.UIErrorsFrame

local KKUI_ERROR_LIST = {
	[ERR_ABILITY_COOLDOWN] = true,
	[ERR_ATTACK_MOUNTED] = true,
	[ERR_OUT_OF_ENERGY] = true,
	[ERR_OUT_OF_FOCUS] = true,
	[ERR_OUT_OF_HEALTH] = true,
	[ERR_OUT_OF_MANA] = true,
	[ERR_OUT_OF_RAGE] = true,
	[ERR_OUT_OF_RANGE] = true,
	[ERR_OUT_OF_RUNES] = true,
	[ERR_OUT_OF_HOLY_POWER] = true,
	[ERR_OUT_OF_RUNIC_POWER] = true,
	[ERR_OUT_OF_SOUL_SHARDS] = true,
	[ERR_OUT_OF_ARCANE_CHARGES] = true,
	[ERR_OUT_OF_COMBO_POINTS] = true,
	[ERR_OUT_OF_CHI] = true,
	[ERR_OUT_OF_POWER_DISPLAY] = true,
	[ERR_SPELL_COOLDOWN] = true,
	[ERR_ITEM_COOLDOWN] = true,
	[SPELL_FAILED_BAD_IMPLICIT_TARGETS] = true,
	[SPELL_FAILED_BAD_TARGETS] = true,
	[SPELL_FAILED_CASTER_AURASTATE] = true,
	[SPELL_FAILED_NO_COMBO_POINTS] = true,
	[SPELL_FAILED_SPELL_IN_PROGRESS] = true,
	[SPELL_FAILED_TARGET_AURASTATE] = true,
	[ERR_NO_ATTACK_TARGET] = true,
}

local isRegistered = true
function Module.ErrorBlocker_OnEvent(event, text)
	if InCombatLockdown() and KKUI_ERROR_LIST[text] then
		if isRegistered then
			UIErrorsFrame:UnregisterEvent(event)
			isRegistered = false
		end
	else
		if not isRegistered then
			UIErrorsFrame:RegisterEvent(event)
			isRegistered = true
		end
	end
end

function Module:CreateErrorFilter()
	if C["General"].HideErrors then
		K:RegisterEvent("UI_ERROR_MESSAGE", self.ErrorBlocker_OnEvent)
	else
		isRegistered = true
		UIErrorsFrame:RegisterEvent("UI_ERROR_MESSAGE")
		K:UnregisterEvent("UI_ERROR_MESSAGE", self.ErrorBlocker_OnEvent)
	end
end