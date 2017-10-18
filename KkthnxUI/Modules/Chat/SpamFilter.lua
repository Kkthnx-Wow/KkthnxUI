local K, C, L = unpack(select(2, ...))

local _G = _G

local UnitIsInMyGuild = _G.UnitIsInMyGuild

local REPEAT_EVENTS = {
	"CHAT_MSG_SAY",
	"CHAT_MSG_YELL",
	"CHAT_MSG_CHANNEL",
	"CHAT_MSG_EMOTE",
	"CHAT_MSG_TEXT_EMOTE",
}

-- Gold/portals spam filter
local SpamList = K.ChatSpamList
local function SpamMessageFilter(self, event, text, sender)
	if sender == K.Name or UnitIsInMyGuild(sender) then return end
	for _, value in pairs(SpamList) do
		if text:lower():match(value) then
			return true
		end
	end
end

function K:OnEnable()
	if C["Chat"].SpamFilter and not K.IsAddOnEnabled("BadBoy") then
		for _, event in ipairs(REPEAT_EVENTS) do
			ChatFrame_AddMessageEventFilter(event, SpamMessageFilter)
		end
	end
end