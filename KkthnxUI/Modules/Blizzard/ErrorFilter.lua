local K = unpack(select(2, ...))
local Module = K:NewModule("ErrorFilter", "AceEvent-3.0")

-- Set Messages To Blacklist.
Module.Filter = {
	[ERR_ABILITY_COOLDOWN] = true,
	[ERR_ATTACK_FLEEING] = true,
	[ERR_BADATTACKPOS] = true,
	[ERR_GENERIC_NO_TARGET] = true,
	[ERR_INVALID_ATTACK_TARGET] = true,
	[ERR_ITEM_COOLDOWN] = true,
	[ERR_MAIL_DATABASE_ERROR] = true,
	[ERR_NO_ATTACK_TARGET] = true,
	[ERR_NOEMOTEWHILERUNNING] = true,
	[ERR_NOT_EQUIPPABLE] = true,
	[ERR_NOT_IN_COMBAT] = true,
	[ERR_OUT_OF_ARCANE_CHARGES] = true,
	[ERR_OUT_OF_BALANCE_NEGATIVE] = true,
	[ERR_OUT_OF_BALANCE_POSITIVE] = true,
	[ERR_OUT_OF_BURNING_EMBERS] = true,
	[ERR_OUT_OF_CHI] = true,
	[ERR_OUT_OF_DARK_FORCE] = true,
	[ERR_OUT_OF_DEMONIC_FURY] = true,
	[ERR_OUT_OF_ENERGY] = true,
	[ERR_OUT_OF_FOCUS] = true,
	[ERR_OUT_OF_FURY] = true,
	[ERR_OUT_OF_HOLY_POWER] = true,
	[ERR_OUT_OF_LIGHT_FORCE] = true,
	[ERR_OUT_OF_MANA] = true,
	[ERR_OUT_OF_PAIN] = true,
	[ERR_OUT_OF_POWER_DISPLAY] = true,
	[ERR_OUT_OF_RAGE] = true,
	[ERR_OUT_OF_RANGE] = true,
	[ERR_OUT_OF_RUNES] = true,
	[ERR_OUT_OF_RUNIC_POWER] = true,
	[ERR_OUT_OF_SHADOW_ORBS] = true,
	[ERR_OUT_OF_SOUL_SHARDS] = true,
	[ERR_SPELL_COOLDOWN] = true,
	[ERR_SPELL_OUT_OF_RANGE] = true,
	[ERR_TOO_FAR_TO_INTERACT] = true,
	[OUT_OF_ENERGY] = true,
	[OUT_OF_FOCUS] = true,
	[OUT_OF_MANA] = true,
	[OUT_OF_POWER_DISPLAY] = true,
	[OUT_OF_POWER_DISPLAY] = true,
	[OUT_OF_RAGE] = true,
	[SPELL_FAILED_AFFECTING_COMBAT] = true,
	[SPELL_FAILED_AURA_BOUNCED] = true,
	[SPELL_FAILED_BAD_TARGETS] = true,
	[SPELL_FAILED_CANT_DO_THAT_RIGHT_NOW] = true,
	[SPELL_FAILED_CASTER_AURASTATE] = true,
	[SPELL_FAILED_MOVING] = true,
	[SPELL_FAILED_NO_COMBO_POINTS] = true,
	[SPELL_FAILED_NO_ENDURANCE] = true,
	[SPELL_FAILED_NOT_IN_CONTROL] = true,
	[SPELL_FAILED_NOT_INFRONT] = true,
	[SPELL_FAILED_NOT_MOUNTED] = true,
	[SPELL_FAILED_NOT_ON_TAXI] = true,
	[SPELL_FAILED_SPELL_IN_PROGRESS] = true,
	[SPELL_FAILED_TARGET_AURASTATE] = true,
	[SPELL_FAILED_TARGETS_DEAD] = true,
}

function Module:OnEvent(_, _, msg)
	if not self.Filter[msg] then
		UIErrorsFrame:AddMessage(msg, 1, 0, 0)
	end
end

function Module:OnEnable()
	UIErrorsFrame:UnregisterEvent("UI_ERROR_MESSAGE", "OnEvent")
	self:RegisterEvent("UI_ERROR_MESSAGE", "OnEvent")
end