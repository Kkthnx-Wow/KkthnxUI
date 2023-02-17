local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Chat")

local math_max = math.max
local math_min = math.min
local pairs = pairs
local string_gsub = string.gsub
local table_remove = table.remove

local Ambiguate = Ambiguate
local C_BattleNet_GetGameAccountInfoByGUID = C_BattleNet.GetGameAccountInfoByGUID
local C_FriendList_IsFriend = C_FriendList.IsFriend
local ChatFrame_AddMessageEventFilter = ChatFrame_AddMessageEventFilter
local GetTime = GetTime
local IsGUIDInGroup = IsGUIDInGroup
local IsGuildMember = IsGuildMember

C.BadBoys = {}

local FilterList = {}
local WhiteFilterList = {}

-- Store chat messages in a table
local chatLines = {}

-- Track the filter result
local filterResult = false

-- Store previous and current values for comparison
local last = {}
local prevLineID = 0
local this = {}

function Module:UpdateFilterList()
	K.SplitList(FilterList, C["Chat"].ChatFilterList, true)
end

function Module:UpdateFilterWhiteList()
	K.SplitList(WhiteFilterList, C["Chat"].ChatFilterWhiteList, true)
end

-- ECF strings compare
-- Input: two strings sA and sB
-- Output: a number representing the difference between sA and sB
function Module:CompareStrDiff(sA, sB)
	-- Get the length of both strings
	local len_a, len_b = #sA, #sB

	-- Initialize the last row of the array with values from 0 to len_b
	for j = 0, len_b do
		last[j + 1] = j
	end

	-- Iterate over each character in sA
	for i = 1, len_a do
		-- Initialize the current row of the array with value i
		this[1] = i

		-- Iterate over each character in sB
		for j = 1, len_b do
			-- Check if the characters in sA and sB match
			-- If they match, the current value is the value from the last row and same column
			-- If they don't match, the current value is the minimum of the values from the last row and the current row plus 1
			this[j + 1] = (sA[i] == sB[j]) and last[j] or (math_min(last[j + 1], this[j], last[j]) + 1)
		end

		-- Update the last row with the current row
		for j = 0, len_b do
			last[j + 1] = this[j + 1]
		end
	end

	-- The difference between sA and sB is given by the value in the last cell of the array divided by the maximum of the lengths of sA and sB
	return this[len_b + 1] / math_max(len_a, len_b)
end

-- This function filters messages in the chat based on various criteria
-- event: type of event that triggers the message (e.g. "CHAT_MSG_CHANNEL", "CHAT_MSG_WHISPER")
-- msg: the message to be filtered
-- name: the name of the sender of the message
-- flag: a flag indicating the source of the message (e.g. "GM", "DEV")
-- guid: a unique identifier of the sender
function Module:GetFilterResult(event, msg, name, flag, guid)
	-- Allow messages from K.Name, GMs, and DEVs
	if name == K.Name or (event == "CHAT_MSG_WHISPER" and flag == "GM") or flag == "DEV" then
		return
	-- Allow messages from guild members, Battle.net friends, and group members
	elseif guid and (IsGuildMember(guid) or C_BattleNet_GetGameAccountInfoByGUID(guid) or C_FriendList_IsFriend(guid) or IsGUIDInGroup(guid)) then
		return
	end

	-- Block strangers when "BlockStranger" option is enabled
	if C["Chat"].BlockStranger and event == "CHAT_MSG_WHISPER" then
		Module.MuteCache[name] = GetTime()
		return true
	end

	-- Block spammers based on "BlockSpammer" option and "BadBoys" list
	if C["Chat"].BlockSpammer and C.BadBoys[name] and C.BadBoys[name] >= 5 then
		return true
	end

	-- Filter message content
	local filterMsg = string_gsub(msg, "|H.-|h(.-)|h", "%1")
	filterMsg = string_gsub(filterMsg, "|c%x%x%x%x%x%x%x%x", "")
	filterMsg = string_gsub(filterMsg, "|r", "")

	-- Trash Filter: Check if message matches keywords in "WhiteFilterList"
	if event == "CHAT_MSG_CHANNEL" then
		local matches = 0
		local found
		for keyword in pairs(WhiteFilterList) do
			if keyword ~= "" then
				found = true
				local _, count = string_gsub(filterMsg, keyword, "")
				if count > 0 then
					matches = matches + 1
				end
			end
		end

		-- Return 0 if no keywords are matched
		if matches == 0 and found then
			return 0
		end
	end

	-- Check if message matches keywords in "FilterList"
	local matches = 0
	for keyword in pairs(FilterList) do
		if keyword ~= "" then
			local _, count = string_gsub(filterMsg, keyword, "")
			if count > 0 then
				matches = matches + 1
			end
		end
	end

	-- Return true if message matches more than or equal to "FilterMatches" keywords
	if matches >= C["Chat"].FilterMatches then
		return true
	end

	-- Repeat messages filtering for chat messages
	-- Initialize the message table with name, character codes, and time
	local msgTable = { name, {}, GetTime() }
	-- If the filtered message is empty, set it to the original message
	if filterMsg == "" then
		filterMsg = msg
	end

	-- Store the character codes of the filtered message in the message table
	for i = 1, #filterMsg do
		msgTable[2][i] = filterMsg:byte(i)
	end

	-- Get the size of the chatLines table
	local chatLinesSize = #chatLines
	-- Add the current message to the chatLines table
	chatLines[chatLinesSize + 1] = msgTable
	-- Loop through the chatLines table to compare with the current message
	for i = 1, chatLinesSize do
		local line = chatLines[i]
		-- If the sender name and the message content are the same or the message difference is less than 0.1, remove the line from the chatLines table and return true
		if line[1] == msgTable[1] and ((event == "CHAT_MSG_CHANNEL" or event == "CHAT_MSG_MONSTER_SAY" and msgTable[3] - line[3] < 0.6) or Module:CompareStrDiff(line[2], msgTable[2]) <= 0.1) then
			table_remove(chatLines, i)
			return true
		end
	end

	-- If the size of the chatLines table is greater than or equal to 30, remove the first line of the table
	if chatLinesSize >= 30 then
		table_remove(chatLines, 1)
	end
end

-- Updates the chat filter
function Module:UpdateChatFilter(event, msg, author, _, _, _, flag, _, _, _, _, lineID, guid)
	-- Check if the lineID is different from the previous lineID
	if lineID ~= prevLineID then
		-- Update the previous lineID
		prevLineID = lineID

		-- Get the author's name, ambiguated to "none"
		local name = Ambiguate(author, "none")

		-- Get the result of the filter for this message
		filterResult = Module:GetFilterResult(event, msg, name, flag, guid)

		-- If the result of the filter is truthy, increment the number of bad messages from this author
		if filterResult then
			C.BadBoys[name] = (C.BadBoys[name] or 0) + 1
		end
	end

	-- Return the filter result
	return filterResult
end

function Module:CreateChatFilter()
	-- Check if the EnhancedChatFilter addon is already loaded
	if IsAddOnLoaded("EnhancedChatFilter") then
		return
	end

	-- Check if the chat filter is enabled in the configuration
	if C["Chat"].EnableFilter then
		-- Call the function to update the filter list
		self:UpdateFilterList()
		-- Call the function to update the white list
		self:UpdateFilterWhiteList()

		-- Add the message event filter for various chat channels
		ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", self.UpdateChatFilter)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_EMOTE", self.UpdateChatFilter)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", self.UpdateChatFilter)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_TEXT_EMOTE", self.UpdateChatFilter)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", self.UpdateChatFilter)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", self.UpdateChatFilter)
	end
end
