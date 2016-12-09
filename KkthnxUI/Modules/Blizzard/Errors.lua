local K, C, L = select(2, ...):unpack()
if C.Misc.Errors ~= true then return end

-- Wow API
local UIErrorsFrame = UIErrorsFrame

local KkthnxUIError = CreateFrame("Frame")

local FilterList = {
	["LE_GAME_ERR_OUT_OF_ARCANE_CHARGES"] = true,
	["LE_GAME_ERR_OUT_OF_CHI"] = true,
	["LE_GAME_ERR_OUT_OF_COMBO_POINTS"] = true,
	["LE_GAME_ERR_OUT_OF_ENERGY"] = true,
	["LE_GAME_ERR_OUT_OF_FOCUS"] = true,
	["LE_GAME_ERR_OUT_OF_FURY"] = true,
	["LE_GAME_ERR_OUT_OF_HEALTH"] = true,
	["LE_GAME_ERR_OUT_OF_HOLY_POWER"] = true,
	["LE_GAME_ERR_OUT_OF_INSANITY"] = true,
	["LE_GAME_ERR_OUT_OF_LUNAR_POWER"] = true,
	["LE_GAME_ERR_OUT_OF_MAELSTROM"] = true,
	["LE_GAME_ERR_OUT_OF_PAIN"] = true,
	["LE_GAME_ERR_OUT_OF_POWER_DISPLAY"] = true,
	["LE_GAME_ERR_OUT_OF_RAGE"] = true,
	["LE_GAME_ERR_OUT_OF_RANGE"] = true,
	["LE_GAME_ERR_OUT_OF_RUNES"] = true,
	["LE_GAME_ERR_OUT_OF_RUNIC_POWER"] = true,
	["LE_GAME_ERR_OUT_OF_SOUL_SHARDS"] = true,
	["LE_GAME_ERR_SPELL_COOLDOWN"] = true,
	["LE_GAME_ERR_SPELL_FAILED_ANOTHER_IN_PROGRESS"] = true,
	["ERR_ABILITY_COOLDOWN"] = true, -- Ability is not ready yet. (Ability)
	["ERR_BADATTACKFACING"] = true,
	["ERR_BADATTACKPOS"] = true,
	["ERR_INVALID_ATTACK_TARGET"] = true, -- You cannot attack that target.
	["ERR_ITEM_COOLDOWN"] = true,
	["ERR_NO_ATTACK_TARGET"] = true, -- There is nothing to attack.
	["ERR_NOT_IN_COMBAT"] = true,
	["ERR_OUT_OF_ENERGY"] = true, -- Not enough energy. (Err)
	["ERR_OUT_OF_FOCUS"] = true, -- Not enough focus
	["ERR_OUT_OF_RAGE"] = true, -- Not enough rage.
	["ERR_OUT_OF_RANGE"] = true,
	["ERR_SPELL_COOLDOWN"] = true, -- Spell is not ready yet. (Spell)
	["LE_GAME_ERR_ABILITY_COOLDOWN"] = true,
	["SPELL_FAILED_AFFECTING_COMBAT"] = true,
	["SPELL_FAILED_BAD_TARGETS"] = true, -- Invalid target
	["SPELL_FAILED_CASTER_AURASTATE"] = true, -- You can't do that yet. (CasterAura)
	["SPELL_FAILED_MOVING"] = true,
	["SPELL_FAILED_NO_COMBO_POINTS"] = true, -- That ability requires combo points.
	["SPELL_FAILED_NO_ENDURANCE"] = true, -- Not enough endurance
	["SPELL_FAILED_NOT_MOUNTED"] = true, -- You are mounted
	["SPELL_FAILED_NOT_ON_TAXI"] = true, -- You are in flight
	["SPELL_FAILED_SPELL_IN_PROGRESS"] = true, -- Another action is in progress. (Spell)
	["SPELL_FAILED_TARGET_AURASTATE"] = true, -- You can't do that yet. (TargetAura)
	["SPELL_FAILED_TARGETS_DEAD"] = true, -- Your target is dead.
	["SPELL_FAILED_TOO_CLOSE"] = true,
	["SPELL_FAILED_UNIT_NOT_INFRONT"] = true,
}

local function OnUIErrorMessage(self, event, messageType, message)
	local errorName, soundKitID, voiceID = GetGameMessageInfo(messageType)
	if FilterList[errorName] then return end
	UIErrorsFrame:AddMessage(message, 1, .1, .1)
end

UIErrorsFrame:UnregisterEvent("UI_ERROR_MESSAGE")

KkthnxUIError:SetScript("OnEvent", OnUIErrorMessage)
KkthnxUIError:RegisterEvent("UI_ERROR_MESSAGE")