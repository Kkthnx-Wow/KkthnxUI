local K, C = unpack(select(2, ...))

local _G = _G
local ipairs = ipairs
local string_match = string.match

local ChatFrame1 = _G.ChatFrame1
local ChatFrame_AddMessageEventFilter = _G.ChatFrame_AddMessageEventFilter

local function CreateGeneralFilterList()
	-- This is to clear away startup messages that has no events connected to them
	local AddMessage = ChatFrame1.AddMessage
	ChatFrame1.AddMessage = function(self, msg, ...)
		if msg then
			for _, filter in ipairs(K.GeneralChatSpam) do
				if string_match(msg, filter) then
					return
				end
			end
		end

		return AddMessage(self, msg, ...)
	end
end

if C["Chat"].Filter then
	CreateGeneralFilterList() -- Load it as soon as possible.
end

local function CreatePrivateFilterList()
	-- This is to clear away startup messages that has no events connected to them
	local AddMessage = ChatFrame1.AddMessage
	ChatFrame1.AddMessage = function(self, msg, ...)
		if msg then
			for _, filter in ipairs(K.PrivateChatNoEventSpam) do
				if string_match(msg, filter) then
					return
				end
			end
		end

		return AddMessage(self, msg, ...)
	end

	local function FilterEventSpam(_, _, msg, ...)
		if msg then
			for _, filter in ipairs(K.PrivateChatEventSpam) do
				if string_match(msg, filter) then
					-- Debugging
					-- print("blocked the message: ", msg)
					-- print("using the filter:", filter)
					return true
				end
			end
			-- uncomment to break the chat
			-- for development purposes only. weird stuff happens when used.
			-- msg = string_gsub(msg, "|", "||")
		end

		return false, msg, ...
	end
	ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", FilterEventSpam)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_BOSS_EMOTE", FilterEventSpam)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", FilterEventSpam)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", FilterEventSpam)

	-- Filter out failed attempts at server commands,
	-- typically coming from people who recently migrated from monster-wow.
	ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", function(_, _, msg, ...)
		if msg then
			if string_match(msg, "^%.(.*)") then
				return true
			end
		end

		return false, msg, ...
	end)
end

if K.IsFirestorm and C["Firestorm"].ChatFilter then
	CreatePrivateFilterList() -- Load it as soon as possible.
end