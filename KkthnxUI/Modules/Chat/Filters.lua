local K, C = unpack(select(2, ...))

local _G = _G
local ipairs = ipairs
local string_match = string.match

local ChatFrame1 = _G.ChatFrame1
local ChatFrame_AddMessageEventFilter = _G.ChatFrame_AddMessageEventFilter
local UnitIsInMyGuild = _G.UnitIsInMyGuild

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

if C["Chat"].Filter then
	local lastMessage
	local function CreateRepeatFilter(self, _, text, sender)
		if sender == K.Name or UnitIsInMyGuild(sender) then
			return
		end

		-- Initialize the repeat cache
		if not self.repeatMessages then
			self.repeatMessages = {msg = {}, count = {}}
		end

		-- Initialize the counter for the current sender
		if not self.repeatMessages.count[sender] then
			self.repeatMessages.count[sender] = 0
		end

		-- Compare the previous message from the sender (if any) to the current text
		lastMessage = self.repeatMessages.msg[sender]
		if lastMessage and lastMessage == text then

			-- We have a match, so increase the count from this sender
			self.repeatMessages.count[sender] = self.repeatMessages.count[sender] + 1

			-- We're above the limit, so we filter it out
			if self.repeatMessages.count[sender] > 100 then
				return true
			end
		else
			-- Store the message in the cache for the next time,
			-- but only do this if the above was false.
			-- No need storing the same text twice,
			-- nor any need for the extra table lookup overhead.
			self.repeatMessages.msg[sender] = text
		end
	end

	ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", CreateRepeatFilter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_EMOTE", CreateRepeatFilter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_MESSAGE", CreateRepeatFilter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_MONSTER_EMOTE", CreateRepeatFilter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_MONSTER_SAY", CreateRepeatFilter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", CreateRepeatFilter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_TEXT_EMOTE", CreateRepeatFilter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", CreateRepeatFilter)

	local TalentFilterMatches = {
		"^"..ERR_LEARN_ABILITY_S:gsub("%%s","(.*)"),
		"^"..ERR_LEARN_SPELL_S:gsub("%%s","(.*)"),
		"^"..ERR_SPELL_UNLEARNED_S:gsub("%%s","(.*)"),
		"^"..ERR_LEARN_PASSIVE_S:gsub("%%s","(.*)"),
		"^"..ERR_PET_SPELL_UNLEARNED_S:gsub("%%s","(.*)"),
		"^"..ERR_PET_LEARN_ABILITY_S:gsub("%%s","(.*)"),
		"^"..ERR_PET_LEARN_SPELL_S:gsub("%%s","(.*)"),
	}

	local function CreateTalentFilter(_, _, msg, ...)
		for _, m in ipairs(TalentFilterMatches) do
			if msg:find(m) then
				return true
			end
		end

		return false, msg, ...
	end
	ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", CreateTalentFilter)
end