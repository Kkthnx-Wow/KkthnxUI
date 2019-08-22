local K, C = unpack(select(2, ...))
local Module = K:GetModule("Blizzard")

local ERR_ABILITY_COOLDOWN = _G.ERR_ABILITY_COOLDOWN
local ERR_ATTACK_MOUNTED = _G.ERR_ATTACK_MOUNTED
local ERR_ITEM_COOLDOWN = _G.ERR_ITEM_COOLDOWN
local ERR_NO_ATTACK_TARGET = _G.ERR_NO_ATTACK_TARGET
local ERR_OUT_OF_ARCANE_CHARGES = _G.ERR_OUT_OF_ARCANE_CHARGES
local ERR_OUT_OF_CHI = _G.ERR_OUT_OF_CHI
local ERR_OUT_OF_COMBO_POINTS = _G.ERR_OUT_OF_COMBO_POINTS
local ERR_OUT_OF_ENERGY = _G.ERR_OUT_OF_ENERGY
local ERR_OUT_OF_FOCUS = _G.ERR_OUT_OF_FOCUS
local ERR_OUT_OF_HEALTH = _G.ERR_OUT_OF_HEALTH
local ERR_OUT_OF_HOLY_POWER = _G.ERR_OUT_OF_HOLY_POWER
local ERR_OUT_OF_MANA = _G.ERR_OUT_OF_MANA
local ERR_OUT_OF_POWER_DISPLAY = _G.ERR_OUT_OF_POWER_DISPLAY
local ERR_OUT_OF_RAGE = _G.ERR_OUT_OF_RAGE
local ERR_OUT_OF_RANGE = _G.ERR_OUT_OF_RANGE
local ERR_OUT_OF_RUNES = _G.ERR_OUT_OF_RUNES
local ERR_OUT_OF_RUNIC_POWER = _G.ERR_OUT_OF_RUNIC_POWER
local ERR_OUT_OF_SOUL_SHARDS = _G.ERR_OUT_OF_SOUL_SHARDS
local ERR_SPELL_COOLDOWN = _G.ERR_SPELL_COOLDOWN
local InCombatLockdown = _G.InCombatLockdown
local SPELL_FAILED_BAD_IMPLICIT_TARGETS = _G.SPELL_FAILED_BAD_IMPLICIT_TARGETS
local SPELL_FAILED_BAD_TARGETS = _G.SPELL_FAILED_BAD_TARGETS
local SPELL_FAILED_CASTER_AURASTATE = _G.SPELL_FAILED_CASTER_AURASTATE
local SPELL_FAILED_NO_COMBO_POINTS = _G.SPELL_FAILED_NO_COMBO_POINTS
local SPELL_FAILED_SPELL_IN_PROGRESS = _G.SPELL_FAILED_SPELL_IN_PROGRESS
local SPELL_FAILED_TARGET_AURASTATE = _G.SPELL_FAILED_TARGET_AURASTATE
local UIErrorsFrame = _G.UIErrorsFrame

local UI_ERROR_LIST = { -- Lets hope 'UI_ERROR_LIST' is not going to be used one day. :o
	[ERR_ABILITY_COOLDOWN] = true,
	[ERR_ATTACK_MOUNTED] = true,
	[ERR_ITEM_COOLDOWN] = true,
	[ERR_NO_ATTACK_TARGET] = true,
	[ERR_OUT_OF_ARCANE_CHARGES] = true,
	[ERR_OUT_OF_CHI] = true,
	[ERR_OUT_OF_COMBO_POINTS] = true,
	[ERR_OUT_OF_ENERGY] = true,
	[ERR_OUT_OF_FOCUS] = true,
	[ERR_OUT_OF_HEALTH] = true,
	[ERR_OUT_OF_HOLY_POWER] = true,
	[ERR_OUT_OF_MANA] = true,
	[ERR_OUT_OF_POWER_DISPLAY] = true,
	[ERR_OUT_OF_RAGE] = true,
	[ERR_OUT_OF_RANGE] = true,
	[ERR_OUT_OF_RUNES] = true,
	[ERR_OUT_OF_RUNIC_POWER] = true,
	[ERR_OUT_OF_SOUL_SHARDS] = true,
	[ERR_SPELL_COOLDOWN] = true,
	[SPELL_FAILED_BAD_IMPLICIT_TARGETS] = true,
	[SPELL_FAILED_BAD_TARGETS] = true,
	[SPELL_FAILED_CASTER_AURASTATE] = true,
	[SPELL_FAILED_NO_COMBO_POINTS] = true,
	[SPELL_FAILED_SPELL_IN_PROGRESS] = true,
	[SPELL_FAILED_TARGET_AURASTATE] = true,
}

local isRegistered = true
function Module.ErrorBlocker_OnEvent(event, text)
	if InCombatLockdown() and UI_ERROR_LIST[text] then
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