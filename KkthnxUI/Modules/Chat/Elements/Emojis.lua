local K, C = unpack(KkthnxUI)
local Module = K:GetModule("Chat")

local _G = _G
local string_gmatch = _G.string.gmatch
local string_gsub = _G.string.gsub
local string_match = _G.string.match
local string_trim = _G.string.trim

local ChatFrame_AddMessageEventFilter = _G.ChatFrame_AddMessageEventFilter

-- replace emojis
function Module:SetupEmojis(_, msg)
	for word in string_gmatch(msg, "%s-%S+%s*") do
		word = string_trim(word)
		local pattern = string_gsub(word, "([%(%)%.%%%+%-%*%?%[%^%$])", "%%%1")
		local emoji = C.SetEmojiTexture[pattern]

		if emoji and string_match(msg, "[%s%p]-" .. pattern .. "[%s%p]*") then
			emoji = "|T" .. emoji .. ":14:14|t"
			local base64 = K.LibBase64:Encode(word)
			msg = string_gsub(msg, "([%s%p]-)" .. pattern .. "([%s%p]*)", (base64 and ("%1|Helvmoji:%%" .. base64 .. "|h|cFFffffff|r|h") or "%1") .. emoji .. "%2")
		end
	end
	return msg
end

-- filter the message thats sent after the encoded string
function Module:ApplyEmojis(event, msg, ...)
	msg = Module:SetupEmojis(event, msg)
	return false, msg, ...
end

function Module:CreateEmojis()
	if not C["Chat"].Emojis then
		return
	end

	ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER", Module.ApplyEmojis)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER_INFORM", Module.ApplyEmojis)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", Module.ApplyEmojis)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_GUILD", Module.ApplyEmojis)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_INSTANCE_CHAT", Module.ApplyEmojis)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_INSTANCE_CHAT_LEADER", Module.ApplyEmojis)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_OFFICER", Module.ApplyEmojis)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY", Module.ApplyEmojis)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY_LEADER", Module.ApplyEmojis)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID", Module.ApplyEmojis)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_LEADER", Module.ApplyEmojis)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_WARNING", Module.ApplyEmojis)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", Module.ApplyEmojis)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", Module.ApplyEmojis)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", Module.ApplyEmojis)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", Module.ApplyEmojis)
end
