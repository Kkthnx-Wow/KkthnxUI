local K, C, L = select(2, ...):unpack()
if C.Chat.MessageFilter ~= true then return end

-- Wow API
local IsResting = IsResting
local UnitIsInMyGuild = UnitIsInMyGuild
local UnitName = UnitName

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: DRUNK_MESSAGE_ITEM_OTHER3, DRUNK_MESSAGE_ITEM_OTHER4, DRUNK_MESSAGE_OTHER1, DRUNK_MESSAGE_OTHER2
-- GLOBALS: DRUNK_MESSAGE_ITEM_SELF3, DRUNK_MESSAGE_ITEM_SELF4, DRUNK_MESSAGE_SELF1, DRUNK_MESSAGE_SELF2
-- GLOBALS: DRUNK_MESSAGE_OTHER3, DRUNK_MESSAGE_OTHER4, DRUNK_MESSAGE_ITEM_SELF1, DRUNK_MESSAGE_ITEM_SELF2
-- GLOBALS: DRUNK_MESSAGE_SELF3, DRUNK_MESSAGE_SELF4, ERR_PET_LEARN_ABILITY_S, ERR_PET_LEARN_SPELL_S
-- GLOBALS: DUEL_WINNER_KNOCKOUT, DUEL_WINNER_RETREAT, DRUNK_MESSAGE_ITEM_OTHER1, DRUNK_MESSAGE_ITEM_OTHER2
-- GLOBALS: ERR_PET_SPELL_UNLEARNED_S, ERR_LEARN_ABILITY_S, ERR_LEARN_SPELL_S, ERR_LEARN_PASSIVE_S
-- GLOBALS: ERR_SPELL_UNLEARNED_S, ERR_CHAT_THROTTLED

-- Main filters
ChatFrame_AddMessageEventFilter("CHAT_MSG_AFK", function() return true end)
ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL_JOIN", function() return true end)
ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL_LEAVE", function() return true end)
ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL_NOTICE", function() return true end)
ChatFrame_AddMessageEventFilter("CHAT_MSG_DND", function() return true end)
ChatFrame_AddMessageEventFilter("CHAT_MSG_MONSTER_SAY", function() if IsResting() then return true end end)
ChatFrame_AddMessageEventFilter("CHAT_MSG_MONSTER_YELL", function() if IsResting() then return true end end)

DRUNK_MESSAGE_ITEM_OTHER1 = ""
DRUNK_MESSAGE_ITEM_OTHER2 = ""
DRUNK_MESSAGE_ITEM_OTHER3 = ""
DRUNK_MESSAGE_ITEM_OTHER4 = ""
DRUNK_MESSAGE_ITEM_SELF1 = ""
DRUNK_MESSAGE_ITEM_SELF2 = ""
DRUNK_MESSAGE_ITEM_SELF3 = ""
DRUNK_MESSAGE_ITEM_SELF4 = ""
DRUNK_MESSAGE_OTHER1 = ""
DRUNK_MESSAGE_OTHER2 = ""
DRUNK_MESSAGE_OTHER3 = ""
DRUNK_MESSAGE_OTHER4 = ""
DRUNK_MESSAGE_SELF1 = ""
DRUNK_MESSAGE_SELF2 = ""
DRUNK_MESSAGE_SELF3 = ""
DRUNK_MESSAGE_SELF4 = ""
DUEL_WINNER_KNOCKOUT = ""
DUEL_WINNER_RETREAT = ""
ERR_CHAT_THROTTLED = ""
ERR_LEARN_ABILITY_S = ""
ERR_LEARN_PASSIVE_S = ""
ERR_LEARN_SPELL_S = ""
ERR_PET_LEARN_ABILITY_S = ""
ERR_PET_LEARN_SPELL_S = ""
ERR_PET_SPELL_UNLEARNED_S = ""
ERR_SPELL_UNLEARNED_S = ""

-- Repeat filter
local lastMessage
local function RepeatMessageFilter(self, event, text, sender)
	if sender == K.Name or UnitIsInMyGuild(sender) then return end

	if not self.repeatMessages or self.repeatCount > 100 then
		self.repeatCount = 0
		self.repeatMessages = {}
	end

	lastMessage = self.repeatMessages[sender]

	if lastMessage == text then
		return true
	end

	self.repeatMessages[sender] = text
	self.repeatCount = self.repeatCount + 1
end

ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", RepeatMessageFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", RepeatMessageFilter)