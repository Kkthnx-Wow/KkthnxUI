local K, C, L = unpack(select(2, ...))
if C["Chat"].MessageFilter ~= true then return end

local _G = _G
local string_match = string.match
local string_gsub = string.gsub

local BNGetFriendGameAccountInfo = _G.BNGetFriendGameAccountInfo
local BNGetNumFriendGameAccounts = _G.BNGetNumFriendGameAccounts
local BNGetNumFriends = _G.BNGetNumFriends
local GetFriendInfo = _G.GetFriendInfo
local GetNumFriends = _G.GetNumFriends
local GetTime = _G.GetTime
local UnitInParty = _G.UnitInParty
local UnitInRaid = _G.UnitInRaid
local UnitIsInMyGuild = _G.UnitIsInMyGuild

local function setPattern(str)
	if not str then
		return ""
	end
	str = string_gsub(str, "([%(%)])", "%%%1")
	str = string_gsub(str, "%%%d?$?[cs]", "(.+)")
	str = string_gsub(str, "%%%d?$?d", "(%%d+)")
	return str
end

local function isFriend(name)
	if not name then
		return
	end
	if UnitIsInMyGuild(name) or UnitInRaid(name) or UnitInParty(name) then
		return true
	end
	for i = 1, GetNumFriends() do
		if GetFriendInfo(i) == name then
			return true
		end
	end
	local _, numBNFriends = BNGetNumFriends()
	for i = 1, numBNFriends do
		for j = 1, BNGetNumFriendGameAccounts(i) do
			local _, toonName = BNGetFriendGameAccountInfo(i, j)
			if toonName == name then
				return true
			end
		end
	end
end

-- Hide public messages containing Cyrillic or CJK characters
-- Based on BlockChinese, by Ketho
-- https://www.curseforge.com/wow/addons/blockchinese
-- https://www.wowinterface.com/downloads/info20488-BlockChinese.html
-- 208 : Cyrillic
-- 227 : Japanese katakana / hiragana
-- 228 - 233 : Chinese characters and Japanese kanji
-- 234 - 237 : Korean characters
do
	local function filter(frame, event, message)
		if string.find(message, "[\227-\237]") then
			return true
		end
	end

	ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", filter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_EMOTE", filter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", filter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", filter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", filter)
end

-- Hide repeated AFK and DND auto-responses.
-- Based on FilterAFK by Tsigo, and DontBugMe by Moonsorrow and Gnarfoz
-- https://www.wowinterface.com/downloads/info14574.html
do
	local seen = {}
	local when = {}

	local function filter(_, _, message, sender, ...)
		if seen[frame] and seen[frame][sender] and seen[frame][sender] == message and GetTime() - when[sender] < 60 then
			when[sender] = GetTime()
			return true
		end

		if seen[frame] then
			seen[frame][sender] = message
		else
			seen[frame] = { [sender] = message }
		end

		when[sender] = GetTime()
	end

	ChatFrame_AddMessageEventFilter("CHAT_MSG_AFK", filter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_DND", filter)
end

-- Hide crafting spam from non-friend/guild
do
	local spam = setPattern(TRADESKILL_LOG_THIRDPERSON)

	ChatFrame_AddMessageEventFilter("CHAT_MSG_TRADESKILLS", function(_, _, message)
		local who, what = string.match(message, spam)
		if who and what and not isFriend(who) then
			return true
		end
	end)
end

-- Hide achievements from non-friend/guild
do
	local spam = setPattern(ACHIEVEMENT_BROADCAST)

	ChatFrame_AddMessageEventFilter("CHAT_MSG_ACHIEVEMENT", function(_, _, message)
		local who, what = string_match(message, spam)
		if who and what and not isFriend(string_match(who, "%[(.-)%]")) then
			return true
		end
	end)
end

-- Hide spammy system messages
do
	local patterns = {
		-- Auction expired
		setPattern(ERR_AUCTION_EXPIRED_S),
		-- Complaint registered
		setPattern(COMPLAINT_ADDED),
		-- Duel info
		setPattern(DUEL_WINNER_KNOCKOUT),
		setPattern(DUEL_WINNER_RETREAT),
		-- Other people are drunk
		setPattern(DRUNK_MESSAGE_ITEM_OTHER1),
		setPattern(DRUNK_MESSAGE_ITEM_OTHER2),
		setPattern(DRUNK_MESSAGE_ITEM_OTHER3),
		setPattern(DRUNK_MESSAGE_ITEM_OTHER4),
		setPattern(DRUNK_MESSAGE_OTHER1),
		setPattern(DRUNK_MESSAGE_OTHER2),
		setPattern(DRUNK_MESSAGE_OTHER3),
		setPattern(DRUNK_MESSAGE_OTHER4),
		-- Quest verbosity
		setPattern(ERR_QUEST_REWARD_EXP_I),
		setPattern(ERR_QUEST_REWARD_MONEY_S),
		-- Other
		setPattern(ERR_LEARN_TRANSMOG_S),
		setPattern(ERR_ZONE_EXPLORED),
		setPattern(ERR_ZONE_EXPLORED_XP),
	}

	ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", function(_, _, message, ...)
		for i = 1, #patterns do
			if string_match(message, patterns[i]) then
				return true
			end
		end
		message = string_gsub(message, "([^,:|%[%]%s%.]+)%-[^,:|%[%]%s%.]+", "%1") -- remove realm names
		return false, message, ...
	end)
end