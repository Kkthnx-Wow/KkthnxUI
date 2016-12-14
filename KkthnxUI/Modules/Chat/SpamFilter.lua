local K, C, L = unpack(select(2, ...))
if C.Chat.SpamFilter ~= true then return end

-- Lua API
local gsub = string.gsub
-- local print = print
local strlower = string.lower
local strmatch = string.match
local strtrim = string.trim
local type = type

-- Wow API
local TRADE = TRADE

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS:

-- Trade channel spam
local reqLatin = not strmatch(GetLocale(), "^[rkz][uoh]")

local prevID, result
local function SpamChatEventFilter(_, _, message, sender, arg3, arg4, arg5, flag, channelID, arg8, channelName, arg10, lineID, senderGUID, ...)
	if lineID == prevID then
		if result == true then
			return true
		else
			return false, result, sender, arg3, arg4, arg5, flag, channelID, arg8, channelName, arg10, lineID, senderGUID, ...
		end
	end
	prevID, result = lineID, true

	-- Don't filter custom channels
	if channelID == 0 or type(channelID) ~= "number" then return end

	local search = strlower(message)

	-- Hide ASCII art crap
	if reqLatin and not strmatch(search, "[a-z]") then
		-- print("No letters")
		return true
	end

	local blacklist = K.SpamFilterBlacklist
	for i = 1, #blacklist do
		if strmatch(search, blacklist[i]) then
			-- print("Blacklisted:", blacklist[i])
			-- print(" ", search)
			return true
		end
	end

	-- Remove extra spaces
	message = strtrim(gsub(message, "%s%s+", " "))

	local whitelist = K.SpamFilterWhitelist
	local pass = #whitelist == 0 or not strmatch(channelName, TRADE)
	if not pass then
		for i = 1, #whitelist do
			if strmatch(search, whitelist[i]) then
				-- print("Whitelisted:", whitelist[i])
				pass = true
				break
			end
		end
	end
	if pass then
		-- print("Passed")
		result = message
		return false, message, sender, arg3, arg4, arg5, flag, channelID, arg8, channelName, arg10, lineID, senderGUID, ...
	end

	-- print("Other:", channelID, search)
	return true
end

ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", SpamChatEventFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", SpamChatEventFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", SpamChatEventFilter)