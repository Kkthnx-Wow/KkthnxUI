--[[-----------------------------------------------------------------------------
-- System Chat Filter — hide learn/unlearn spam when swapping talents.
-- Prefix match on ERR_LEARN_* / ERR_SPELL_UNLEARNED (locale-stable leading text).
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Chat")

local ChatFrame_AddMessageEventFilter = _G.ChatFrame_AddMessageEventFilter
local ChatFrame_RemoveMessageEventFilter = _G.ChatFrame_RemoveMessageEventFilter
local string_split = string.split

local ERR_LEARN_ABILITY = string_split("%s", _G.ERR_LEARN_ABILITY_S or "")
local ERR_LEARN_PASSIVE = string_split("%s", _G.ERR_LEARN_PASSIVE_S or "")
local ERR_LEARN_SPELL = string_split("%s", _G.ERR_LEARN_SPELL_S or "")
local ERR_SPELL_UNLEARNED = string_split("%s", _G.ERR_SPELL_UNLEARNED_S or "")

local installed

local function ShouldHide(msg)
	if not msg or K.IsSecret(msg) then
		return false
	end
	if #ERR_LEARN_ABILITY > 0 and msg:sub(1, #ERR_LEARN_ABILITY) == ERR_LEARN_ABILITY then
		return true
	end
	if #ERR_LEARN_PASSIVE > 0 and msg:sub(1, #ERR_LEARN_PASSIVE) == ERR_LEARN_PASSIVE then
		return true
	end
	if #ERR_LEARN_SPELL > 0 and msg:sub(1, #ERR_LEARN_SPELL) == ERR_LEARN_SPELL then
		return true
	end
	if #ERR_SPELL_UNLEARNED > 0 and msg:sub(1, #ERR_SPELL_UNLEARNED) == ERR_SPELL_UNLEARNED then
		return true
	end
	return false
end

local function OnSystemMessage(_, _, msg, ...)
	if not C["Chat"].SystemChatFilter then
		return false, msg, ...
	end
	if ShouldHide(msg) then
		return true
	end
	return false, msg, ...
end

function Module:UpdateSystemChatFilter()
	if C["Chat"].SystemChatFilter and not installed then
		ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", OnSystemMessage)
		installed = true
	elseif not C["Chat"].SystemChatFilter and installed then
		ChatFrame_RemoveMessageEventFilter("CHAT_MSG_SYSTEM", OnSystemMessage)
		installed = false
	end
end

function Module:CreateSystemChatFilter()
	Module:UpdateSystemChatFilter()
end
