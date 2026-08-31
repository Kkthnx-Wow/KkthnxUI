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
local UnitName = UnitName
local Ambiguate = Ambiguate
local IsSecret = K.IsSecret

local FILTER_EVENTS = {
	"CHAT_MSG_CHANNEL",
	"CHAT_MSG_SAY",
	"CHAT_MSG_YELL",
}

local WINDOW = 30 -- seconds a message counts as a repeat

function Module:EnableFilter()
	local seen = {}
	local lastSweep = 0
	local player = UnitName("player")

	local function RepeatFilter(_, _, msg, author)
		-- Never touch a secret string (cannot be keyed or compared) or your own
		-- messages, so what you send is always shown even if you repeat it.
		if not msg or not author or IsSecret(msg) or IsSecret(author) then
			return false
		end
		if player and (author == player or Ambiguate(author, "short") == player) then
			return false
		end

		local now = GetTime()

		-- Sweep expired keys now and then so the table does not grow all session.
		if now - lastSweep > WINDOW then
			lastSweep = now
			for key, stamp in pairs(seen) do
				if now - stamp >= WINDOW then
					seen[key] = nil
				end
			end
		end

		local key = author .. "\001" .. msg
		if seen[key] and (now - seen[key]) < WINDOW then
			return true
		end
		seen[key] = now
		return false
	end

	for _, event in ipairs(FILTER_EVENTS) do
		ChatFrame_AddMessageEventFilter(event, RepeatFilter)
	end
end
