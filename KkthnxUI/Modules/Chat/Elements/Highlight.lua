--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Notes:
-- - Purpose: Highlights the player's own name and guild tags in chat.
-- - Design: ChatFrame_AddMessageEventFilter; live toggle removes the same handle.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Chat")

local string_gsub = string.gsub
local ipairs = ipairs
local ChatFrame_AddMessageEventFilter = ChatFrame_AddMessageEventFilter
local ChatFrame_RemoveMessageEventFilter = ChatFrame_RemoveMessageEventFilter

local HIGHLIGHT_COLOR = "|cff669DFF"
local GUILD_COLOR = "|cff40ff40"

local namePattern
local guildPattern = "(<[^>]+>)"
local filtersInstalled = false

local function GetNamePattern(name)
	local escaped = name:gsub("([%(%)%.%%%+%-%*%?%[%^%$])", "%%%1")
	return "%f[%a]" .. escaped .. "%f[%A]"
end

local function HighlightFilter(_, _, msg, ...)
	if not msg then
		return
	end

	local changed = false

	if C["Chat"].HighlightPlayer then
		if not namePattern then
			namePattern = GetNamePattern(K.Name)
		end
		local newMsg, count = string_gsub(msg, namePattern, HIGHLIGHT_COLOR .. "%0|r")
		if count > 0 then
			msg = newMsg
			changed = true
		end
	end

	if C["Chat"].HighlightGuild then
		local newMsg, count = string_gsub(msg, guildPattern, GUILD_COLOR .. "%1|r")
		if count > 0 then
			msg = newMsg
			changed = true
		end
	end

	if changed then
		return false, msg, ...
	end
end

local events = {
	"CHAT_MSG_BN_WHISPER",
	"CHAT_MSG_BN_WHISPER_INFORM",
	"CHAT_MSG_CHANNEL",
	"CHAT_MSG_COMMUNITIES_CHANNEL",
	"CHAT_MSG_GUILD",
	"CHAT_MSG_INSTANCE_CHAT",
	"CHAT_MSG_INSTANCE_CHAT_LEADER",
	"CHAT_MSG_OFFICER",
	"CHAT_MSG_PARTY",
	"CHAT_MSG_PARTY_LEADER",
	"CHAT_MSG_RAID",
	"CHAT_MSG_RAID_LEADER",
	"CHAT_MSG_RAID_WARNING",
	"CHAT_MSG_SAY",
	"CHAT_MSG_WHISPER",
	"CHAT_MSG_WHISPER_INFORM",
	"CHAT_MSG_YELL",
}

function Module:UpdateChatHighlight()
	local enable = C["Chat"].Enable and (C["Chat"].HighlightPlayer or C["Chat"].HighlightGuild)
	if enable and not filtersInstalled then
		for _, event in ipairs(events) do
			ChatFrame_AddMessageEventFilter(event, HighlightFilter)
		end
		filtersInstalled = true
	elseif not enable and filtersInstalled then
		for _, event in ipairs(events) do
			ChatFrame_RemoveMessageEventFilter(event, HighlightFilter)
		end
		filtersInstalled = false
	end
end

function Module:CreateChatHighlight()
	Module:UpdateChatHighlight()
end
