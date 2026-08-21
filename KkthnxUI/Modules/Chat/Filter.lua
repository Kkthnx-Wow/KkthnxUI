--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/Chat/Filter.lua
	Purpose:
		A light spam filter: drop a message that is identical to one the same
		author sent in the public channels within the last half minute. Only the
		noisy public channels are filtered so guild, party, and whispers are never
		touched.
-----------------------------------------------------------------------------]]

local K = KkthnxUI[1]

local Module = K:GetModule("Chat")

local GetTime = GetTime

local FILTER_EVENTS = {
	"CHAT_MSG_CHANNEL",
	"CHAT_MSG_SAY",
	"CHAT_MSG_YELL",
}

function Module:EnableFilter()
	local seen = {}

	local function RepeatFilter(_, _, msg, author)
		if not msg or not author then
			return false
		end
		local key = author .. "\001" .. msg
		local now = GetTime()
		if seen[key] and (now - seen[key]) < 30 then
			return true
		end
		seen[key] = now
		return false
	end

	for _, event in ipairs(FILTER_EVENTS) do
		ChatFrame_AddMessageEventFilter(event, RepeatFilter)
	end
end
