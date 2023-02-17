local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Chat")

local string_gmatch = string.gmatch
local string_gsub = string.gsub
local string_match = string.match
local string_trim = string.trim

-- function to replace emojis
function Module:SetupEmojis(_, msg)
	-- iterate through each word in the message
	for word in string_gmatch(msg, "%s-%S+%s*") do
		-- trim the word to remove leading and trailing whitespaces
		word = string_trim(word)
		-- escape any special characters in the word
		local pattern = string_gsub(word, "([%(%)%.%%%+%-%*%?%[%^%$])", "%%%1")
		-- check if the word is a key in the C.SetEmojiTexture table
		local emoji = C.SetEmojiTexture[pattern]
		-- check if the word appears in the message
		if emoji and string_match(msg, "[%s%p]-" .. pattern .. "[%s%p]*") then
			-- create the texture string for the emoji
			emoji = "|T" .. emoji .. ":14:14|t"
			-- encode the word using K.LibBase64
			local base64 = K.LibBase64:Encode(word)
			-- replace the word in the message with the encoded word and the emoji texture
			msg = string_gsub(msg, "([%s%p]-)" .. pattern .. "([%s%p]*)", (base64 and ("%1|Helvmoji:%%" .. base64 .. "|h|cFFffffff|r|h") or "%1") .. emoji .. "%2")
		end
	end
	return msg
end

-- function to filter the message after it has been encoded
function Module:ApplyEmojis(event, msg, ...)
	-- replace the emojis in the message
	msg = Module:SetupEmojis(event, msg)
	-- return the modified message
	return false, msg, ...
end

function Module:CreateEmojis()
	if not C["Chat"].Emojis then
		return
	end

	local events = {
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

	for _, event in ipairs(events) do
		ChatFrame_AddMessageEventFilter(event, Module.ApplyEmojis)
	end
end
