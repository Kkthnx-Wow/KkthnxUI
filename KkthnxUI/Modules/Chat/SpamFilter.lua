local K, C, L = unpack(select(2, ...))
if C.Chat.SpamFilter ~= true then return end

-- Lua API
local pairs = pairs

-- Wow API
local UnitIsInMyGuild = UnitIsInMyGuild
local UnitName = UnitName

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: ChatFrame_AddMessageEventFilter

-- Trade channel spam
local function TradeFilter(self, event, text, sender)
	if (K.SpamFilterList and K.SpamFilterList[1]) then
		for _, value in pairs(K.SpamFilterList) do
			if sender == K.Name or UnitIsInMyGuild(sender) then return end
			if (text:find(value)) or text:lower():match(value) then
				-- print(text, value)
				return true
			end
		end
	end
end

ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", TradeFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", TradeFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", TradeFilter)