local K, C, L = unpack(select(2, ...))
if C.Misc.Errors ~= true then return end

-- Wow API
local UIErrorsFrame = UIErrorsFrame

local KkthnxUIError = CreateFrame("Frame")

local FilterList = {
	[ERR_ABILITY_COOLDOWN] = true, -- Ability is not ready yet.
	[ERR_ATTACK_FLEEING] = true,
	[ERR_ATTACK_MOUNTED] = true, -- Can't attack while mounted.
	[ERR_ATTACK_STUNNED] = true, -- Can't attack while stunned.
	[ERR_BADATTACKFACING] = true, -- You are facing the wrong way!
	[ERR_BADATTACKPOS] = true, 	-- You are too far away!
	[ERR_CLIENT_LOCKED_OUT] = true, -- You can't do that right now.
	[ERR_GENERIC_NO_TARGET] = true, -- You have no target.
	[ERR_INVALID_ATTACK_TARGET] = true, -- You cannot attack that target.
	[ERR_ITEM_COOLDOWN] = true,
	[ERR_MAIL_DATABASE_ERROR] = true,
	[ERR_MUST_EQUIP_ITEM] = true, -- You must equip that item to use it.
	[ERR_NO_ATTACK_TARGET] = true, -- There is nothing to attack.
	[ERR_NOEMOTEWHILERUNNING] = true,
	[ERR_NOT_EQUIPPABLE] = true,
	[ERR_NOT_IN_COMBAT] = true,
	[ERR_OUT_OF_ARCANE_CHARGES] = true,
	[ERR_OUT_OF_BALANCE_NEGATIVE] = true,
	[ERR_OUT_OF_BALANCE_POSITIVE] = true,
	[ERR_OUT_OF_BURNING_EMBERS] = true,
	[ERR_OUT_OF_CHI] = true, -- Not enough chi
	[ERR_OUT_OF_DARK_FORCE] = true,
	[ERR_OUT_OF_DEMONIC_FURY] = true,
	[ERR_OUT_OF_ENERGY] = true, -- Not enough energy
	[ERR_OUT_OF_FOCUS] = true, -- Not enough focus
	[ERR_OUT_OF_FURY] = true,
	[ERR_OUT_OF_HOLY_POWER] = true,
	[ERR_OUT_OF_LIGHT_FORCE] = true,
	[ERR_OUT_OF_MANA] = true,
	[ERR_OUT_OF_PAIN] = true,
	[ERR_OUT_OF_POWER_DISPLAY] = true,
	[ERR_OUT_OF_RAGE] = true, -- Not enough rage
	[ERR_OUT_OF_RANGE] = true, -- Out of range.
	[ERR_OUT_OF_RUNES] = true, -- Not enough runes
	[ERR_OUT_OF_RUNIC_POWER] = true, -- Not enough runic power
	[ERR_OUT_OF_SHADOW_ORBS] = true,
	[ERR_OUT_OF_SOUL_SHARDS] = true,
	[ERR_SPELL_COOLDOWN] = true, -- Spell is not ready yet.
	[ERR_SPELL_OUT_OF_RANGE] = true,
	[ERR_TOO_FAR_TO_INTERACT] = true,
	[INTERRUPTED] = true, -- Another action is in progress
	[SPELL_FAILED_AFFECTING_COMBAT] = true,
	[SPELL_FAILED_AURA_BOUNCED] = true,
	[SPELL_FAILED_BAD_IMPLICIT_TARGETS] = true, -- No target
	[SPELL_FAILED_BAD_TARGETS] = true, -- Invalid target
	[SPELL_FAILED_CANT_DO_THAT_RIGHT_NOW] = true,
	[SPELL_FAILED_CASTER_AURASTATE] = true, -- You can't do that yet. (CasterAura)
	[SPELL_FAILED_CUSTOM_ERROR_153] = true, -- You have insufficient Blood Charges.
	[SPELL_FAILED_CUSTOM_ERROR_154] = true, -- No fully depleted runes.
	[SPELL_FAILED_CUSTOM_ERROR_159] = true, -- Both Frost Fever and Blood Plague must be present on the target.
	[SPELL_FAILED_MOVING] = true,
	[SPELL_FAILED_NO_COMBO_POINTS] = true, -- That ability requires combo points.
	[SPELL_FAILED_NO_ENDURANCE] = true, -- Not enough endurance
	[SPELL_FAILED_NOT_IN_CONTROL] = true,
	[SPELL_FAILED_NOT_INFRONT] = true,
	[SPELL_FAILED_NOT_MOUNTED] = true, -- You are mounted
	[SPELL_FAILED_NOT_ON_TAXI] = true, -- You are in flight
	[SPELL_FAILED_SPELL_IN_PROGRESS] = true, -- Another action is in progress
	[SPELL_FAILED_STUNNED] = true, -- Can't do that while stunned
	[SPELL_FAILED_TARGET_AURASTATE] = true, -- You can't do that yet. (TargetAura)
	[SPELL_FAILED_TARGETS_DEAD] = true, -- Your target is dead.
	[SPELL_FAILED_TOO_CLOSE] = true,
	[SPELL_FAILED_UNIT_NOT_INFRONT] = true, -- Target needs to be in front of you.
}

local function OnUIErrorMessage(self, event, messageType, message)
	local errorName, soundKitID, voiceID = GetGameMessageInfo(messageType)
	if FilterList[errorName] then return end
	UIErrorsFrame:AddMessage(message, 1, .1, .1)
end

UIErrorsFrame:UnregisterEvent("UI_ERROR_MESSAGE")

KkthnxUIError:SetScript("OnEvent", OnUIErrorMessage)
KkthnxUIError:RegisterEvent("UI_ERROR_MESSAGE")