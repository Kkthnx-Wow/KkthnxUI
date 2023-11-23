local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Chat")

-- Simplify string functions usage
local gmatch, gsub, match, trim = string.gmatch, string.gsub, string.match, string.trim

-- List of chat events
local chatEvents = {
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

-- Function to replace emojis in chat messages
function Module:SetupEmojis(_, msg)
	for word in gmatch(msg, "%s-%S+%s*") do
		word = trim(word)
		local pattern = gsub(word, "([%(%)%.%%%+%-%*%?%[%^%$])", "%%%1")
		local emoji = C.SetEmojiTexture[pattern]

		if emoji and match(msg, "[%s%p]-" .. pattern .. "[%s%p]*") then
			emoji = "|T" .. emoji .. ":14:14|t"
			local base64 = K.LibBase64:Encode(word)
			local replacement = base64 and ("%1|Helvmoji:%%" .. base64 .. "|h|cFFffffff|r|h") or "%1"
			msg = gsub(msg, "([%s%p]-)" .. pattern .. "([%s%p]*)", replacement .. emoji .. "%2")
		end
	end
	return msg
end

-- Function to filter and apply emojis to chat messages
function Module:ApplyEmojis(event, msg, ...)
	msg = Module:SetupEmojis(event, msg)
	return false, msg, ...
end

-- Function to initialize emoji application in chat
function Module:CreateEmojis()
	if not C["Chat"].Emojis then
		return
	end

	for _, event in ipairs(chatEvents) do
		ChatFrame_AddMessageEventFilter(event, self.ApplyEmojis)
	end
end
