local K = unpack(select(2, ...))
local Module = K:NewModule("ErrorFilter", "AceEvent-3.0")

-- Set Messages To Blacklist.
Module.Filter = {
	[ERR_ABILITY_COOLDOWN] = true,
	[ERR_ATTACK_MOUNTED] = true,
	[ERR_ATTACK_PVP_TARGET_WHILE_UNFLAGGED] = true,
	[ERR_ITEM_COOLDOWN] = true,
	[ERR_LOOT_GONE] = true,
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
	[LOOT_GONE] = true,
	[SPELL_FAILED_BAD_IMPLICIT_TARGETS] = true,
	[SPELL_FAILED_BAD_TARGETS] = true,
	[SPELL_FAILED_CASTER_AURASTATE] = true,
	[SPELL_FAILED_NO_COMBO_POINTS] = true,
	[SPELL_FAILED_SPELL_IN_PROGRESS] = true,
	[SPELL_FAILED_TARGET_AURASTATE] = true,
	-- Firestorm Spam Fixes
	[SPELL_FAILED_CASTER_DEAD] = true,
	[SPELL_FAILED_CASTER_DEAD_FEMALE] = true,
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