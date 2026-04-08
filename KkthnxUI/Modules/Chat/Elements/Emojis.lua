--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Replaces text-based emojis (e.g., :smile:) with graphical textures in chat.
-- - Design: Uses ChatFrame message filters to iterate over words and match them against an emoji database.
-- - Events: CHAT_MSG_SAY, CHAT_MSG_WHISPER, CHAT_MSG_GUILD, etc.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Chat")

-- PERF: Localize globals and API functions to reduce lookup overhead.
local ChatFrame_AddMessageEventFilter = _G.ChatFrame_AddMessageEventFilter
local ipairs = ipairs
local string_gmatch = string.gmatch
local string_gsub = string.gsub
local string_match = string.match
local string_trim = string.trim

-- ---------------------------------------------------------------------------
-- Constants
-- ---------------------------------------------------------------------------
local CHAT_EVENTS = {
	"CHAT_MSG_BN_WHISPER",
	"CHAT_MSG_BN_WHISPER_INFORM",
	"CHAT_MSG_CHANNEL",
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

-- ---------------------------------------------------------------------------
-- Emoji Logic
-- ---------------------------------------------------------------------------
function Module:SetupEmojis(_, msg)
	-- REASON: Scans the message for words that match defined emoji patterns and replaces them with textures.
	for word in string_gmatch(msg, "%s-%S+%s*") do
		word = string_trim(word)
		local pattern = string_gsub(word, "([%(%)%.%%%+%-%*%?%[%^%$])", "%%%1")
		local emojiTexture = C.SetEmojiTexture[pattern]

		if emojiTexture and string_match(msg, "[%s%p]-" .. pattern .. "[%s%p]*") then
			-- REASON: Wraps the texture in a hyperlinked invisible tag to allow the original text to be copied.
			local textureString = "|T" .. emojiTexture .. ":14:14|t"
			local base64Code = K.LibBase64:Encode(word)
			local replacementFormat = base64Code and ("%1|Helvmoji:%%" .. base64Code .. "|h|cFFffffff|r|h") or "%1"
			msg = string_gsub(msg, "([%s%p]-)" .. pattern .. "([%s%p]*)", replacementFormat .. textureString .. "%2")
		end
	end
	return msg
end

function Module:ApplyEmojis(event, msg, ...)
	-- REASON: Interface for the ChatFrame filter system; returns the modified message.
	msg = Module:SetupEmojis(event, msg)
	return false, msg, ...
end

-- ---------------------------------------------------------------------------
-- Initialization
-- ---------------------------------------------------------------------------
function Module:CreateEmojis()
	-- REASON: Registration entry point; hooks all specified chat events to the emoji filter.
	if not C["Chat"].Emojis then
		return
	end

	for _, event in ipairs(CHAT_EVENTS) do
		ChatFrame_AddMessageEventFilter(event, self.ApplyEmojis)
	end
end
