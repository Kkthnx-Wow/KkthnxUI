local K, C = unpack(select(2, ...))
local Module = K:GetModule("Chat")

local _G = _G
local ipairs = ipairs
local string_match = string.match

local ChatFrame1 = _G.ChatFrame1
local ChatFrame_AddMessageEventFilter = _G.ChatFrame_AddMessageEventFilter
local GetTime = _G.GetTime
local UnitIsInMyGuild = _G.UnitIsInMyGuild

local ERR_LEARN_ABILITY_S = _G.ERR_LEARN_ABILITY_S
local ERR_LEARN_PASSIVE_S = _G.ERR_LEARN_PASSIVE_S
local ERR_LEARN_SPELL_S = _G.ERR_LEARN_SPELL_S
local ERR_PET_LEARN_ABILITY_S = _G.ERR_PET_LEARN_ABILITY_S
local ERR_PET_LEARN_SPELL_S = _G.ERR_PET_LEARN_SPELL_S
local ERR_PET_SPELL_UNLEARNED_S = _G.ERR_PET_SPELL_UNLEARNED_S
local ERR_SPELL_UNLEARNED_S = _G.ERR_SPELL_UNLEARNED_S

K.GeneralChatSpam = {
	"an[au][ls]e?r?%f[%L]",
	"nigg[ae]r?",
	"s%A*k%A*y%A*p%Ae",
}

K.PrivateChatEventSpam = {
	"%-(.*)%|T(.*)|t(.*)|c(.*)%|r",
	"%[(.*)ARENA ANNOUNCER(.*)%]",
	"%[(.*)Announce by(.*)%]",
	"%[(.*)Autobroadcast(.*)%]",
	"%[(.*)BG Queue Announcer(.*)%]",
}

K.PrivateChatNoEventSpam = {}

K.TalentChatSpam = {
	"^"..ERR_LEARN_ABILITY_S:gsub("%%s","(.*)"),
	"^"..ERR_LEARN_SPELL_S:gsub("%%s","(.*)"),
	"^"..ERR_SPELL_UNLEARNED_S:gsub("%%s","(.*)"),
	"^"..ERR_LEARN_PASSIVE_S:gsub("%%s","(.*)"),
	"^"..ERR_PET_SPELL_UNLEARNED_S:gsub("%%s","(.*)"),
	"^"..ERR_PET_LEARN_ABILITY_S:gsub("%%s","(.*)"),
	"^"..ERR_PET_LEARN_SPELL_S:gsub("%%s","(.*)"),
}

function Module:CreateGeneralFilterList()
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

-- RepeatFilter Credits: Goldpaw
function Module:CreateRepeatFilter(_, text, sender)
	if not text or sender == K.Name or UnitIsInMyGuild(sender) then
		return
	end

	-- Initialize the repeat cache
	if not self.repeatThrottle then
		self.repeatThrottle = {}
	end

	-- We use this in all conditionals, let's avoid double function calls!
	local now = GetTime()

	-- Prune away messages that has timed out without repetitions.
	-- This iteration shouldn't cost much when called on every new message,
	-- the database simply won't have time to accumulate very many entries.
	for msg,when in pairs(self.repeatThrottle) do
		if when > now and msg ~= text then
			self.repeatThrottle[msg] = nil
		end
	end

	-- If the timer for this message hasn't been set, or if 10 seconds have passed,
	-- we set the timer to 10 new seconds, show the message once, and return.
	if not self.repeatThrottle[text] or self.repeatThrottle[text] > now then
		self.repeatThrottle[text] = now + 10
		return
	end

	-- If we got here the timer has been set, but it's still too early.
	if self.repeatThrottle[text] < now then
		return true
	end
end

function Module:CreateTalentFilter(_, msg, ...)
	if msg then
		for _, filter in ipairs(K.TalentChatSpam) do
			if string_match(msg, filter) then
				return true
			end
		end
	end

	return false, msg, ...
end

function Module:FilterEventSpam(_, msg, ...)
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

function Module:CreatePrivateFilterList()
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
end

-- Show itemlevel on chat hyperlinks
local function isItemHasLevel(link)
	local name, _, rarity, level, _, _, _, _, _, _, _, classID = GetItemInfo(link)
	if name and level and rarity > 1 and (classID == LE_ITEM_CLASS_WEAPON or classID == LE_ITEM_CLASS_ARMOR) then
		return name, level
	end
end

local function isItemHasGem(link)
	local stats = GetItemStats(link)
	for index in pairs(stats) do
		if string.find(index, "EMPTY_SOCKET_") then
			return "|TInterface\\ItemSocketingFrame\\UI-EmptySocket-Prismatic:0|t"
		end
	end
	return ""
end

local itemCache = {}
local function convertItemLevel(link)
	if itemCache[link] then return itemCache[link] end

	local itemLink = string_match(link, "|Hitem:.-|h")
	if itemLink then
		local name, itemLevel = isItemHasLevel(itemLink)
		if name and itemLevel then
			link = gsub(link, "|h%[(.-)%]|h", "|h["..name.."("..itemLevel..isItemHasGem(itemLink)..")]|h")
			itemCache[link] = link
		end
	end
	return link
end

function Module:UpdateChatItemLevel(_, msg, ...)
	msg = gsub(msg, "(|Hitem:%d+:.-|h.-|h)", convertItemLevel)
	return false, msg, ...
end

function Module:CreateChatFilter()
	if C["Chat"].EnableFilter then
		self:CreateGeneralFilterList()
		self:CreatePrivateFilterList()

		ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", self.CreateRepeatFilter)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_EMOTE", self.CreateRepeatFilter)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_MONSTER_EMOTE", self.CreateRepeatFilter)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_MONSTER_SAY", self.CreateRepeatFilter)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", self.CreateRepeatFilter)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_TEXT_EMOTE", self.CreateRepeatFilter)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", self.CreateRepeatFilter)

		ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", self.CreateTalentFilter)

		ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", self.FilterEventSpam)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_BOSS_EMOTE", self.FilterEventSpam)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", self.FilterEventSpam)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", self.FilterEventSpam)

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

	if C["Chat"].ChatItemLevel then
		ChatFrame_AddMessageEventFilter("CHAT_MSG_LOOT", self.UpdateChatItemLevel)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", self.UpdateChatItemLevel)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", self.UpdateChatItemLevel)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", self.UpdateChatItemLevel)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", self.UpdateChatItemLevel)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", self.UpdateChatItemLevel)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER", self.UpdateChatItemLevel)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID", self.UpdateChatItemLevel)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_LEADER", self.UpdateChatItemLevel)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY", self.UpdateChatItemLevel)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY_LEADER", self.UpdateChatItemLevel)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_GUILD", self.UpdateChatItemLevel)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_BATTLEGROUND", self.UpdateChatItemLevel)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_INSTANCE_CHAT", self.UpdateChatItemLevel)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_INSTANCE_CHAT_LEADER", self.UpdateChatItemLevel)
	end
end