local K, C = unpack(KkthnxUI)
local Module = K:GetModule("Chat")

local _G = _G
local math_max = _G.math.max
local math_min = _G.math.min
local pairs = _G.pairs
local string_gsub = _G.string.gsub
local table_remove = _G.table.remove

local Ambiguate = _G.Ambiguate
local C_BattleNet_GetGameAccountInfoByGUID = _G.C_BattleNet.GetGameAccountInfoByGUID
local C_FriendList_IsFriend = _G.C_FriendList.IsFriend
local ChatFrame_AddMessageEventFilter = _G.ChatFrame_AddMessageEventFilter
local GetTime = _G.GetTime
local IsGUIDInGroup = _G.IsGUIDInGroup
local IsGuildMember = _G.IsGuildMember

C.BadBoys = {} -- debug
local FilterList = {}
local WhiteFilterList = {}
local chatLines = {}
local filterResult = false
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
function Module:CompareStrDiff(sA, sB) -- arrays of bytes
	local len_a, len_b = #sA, #sB
	for j = 0, len_b do
		last[j + 1] = j
	end

	for i = 1, len_a do
		this[1] = i
		for j = 1, len_b do
			this[j + 1] = (sA[i] == sB[j]) and last[j] or (math_min(last[j + 1], this[j], last[j]) + 1)
		end

		for j = 0, len_b do
			last[j + 1] = this[j + 1]
		end
	end

	return this[len_b + 1] / math_max(len_a, len_b)
end

function Module:GetFilterResult(event, msg, name, flag, guid)
	if name == K.Name or (event == "CHAT_MSG_WHISPER" and flag == "GM") or flag == "DEV" then
		return
	elseif guid and (IsGuildMember(guid) or C_BattleNet_GetGameAccountInfoByGUID(guid) or C_FriendList_IsFriend(guid) or IsGUIDInGroup(guid)) then
		return
	end

	if C["Chat"].BlockStranger and event == "CHAT_MSG_WHISPER" then -- Block strangers
		Module.MuteCache[name] = GetTime()
		return true
	end

	if C["Chat"].BlockSpammer and C.BadBoys[name] and C.BadBoys[name] >= 5 then
		return true
	end

	local filterMsg = string_gsub(msg, "|H.-|h(.-)|h", "%1")
	filterMsg = string_gsub(filterMsg, "|c%x%x%x%x%x%x%x%x", "")
	filterMsg = string_gsub(filterMsg, "|r", "")

	-- Trash Filter
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

		if matches == 0 and found then
			return 0
		end
	end

	local matches = 0
	for keyword in pairs(FilterList) do
		if keyword ~= "" then
			local _, count = string_gsub(filterMsg, keyword, "")
			if count > 0 then
				matches = matches + 1
			end
		end
	end

	if matches >= C["Chat"].FilterMatches then
		return true
	end

	-- ECF Repeat Filter
	local msgTable = { name, {}, GetTime() }
	if filterMsg == "" then
		filterMsg = msg
	end

	for i = 1, #filterMsg do
		msgTable[2][i] = filterMsg:byte(i)
	end

	local chatLinesSize = #chatLines
	chatLines[chatLinesSize + 1] = msgTable
	for i = 1, chatLinesSize do
		local line = chatLines[i]
		if line[1] == msgTable[1] and ((event == "CHAT_MSG_CHANNEL" or event == "CHAT_MSG_MONSTER_SAY" and msgTable[3] - line[3] < 0.6) or Module:CompareStrDiff(line[2], msgTable[2]) <= 0.1) then
			table_remove(chatLines, i)
			return true
		end
	end

	if chatLinesSize >= 30 then
		table_remove(chatLines, 1)
	end
end

function Module:UpdateChatFilter(event, msg, author, _, _, _, flag, _, _, _, _, lineID, guid)
	if lineID ~= prevLineID then
		prevLineID = lineID

		local name = Ambiguate(author, "none")
		filterResult = Module:GetFilterResult(event, msg, name, flag, guid)

		if filterResult and filterResult ~= 0 then
			C.BadBoys[name] = (C.BadBoys[name] or 0) + 1
		end

		if filterResult == 0 then
			filterResult = true
		end
	end

	return filterResult
end

function Module:CreateChatFilter()
	if IsAddOnLoaded("EnhancedChatFilter") then
		return
	end

	if C["Chat"].EnableFilter then
		self:UpdateFilterList()
		self:UpdateFilterWhiteList()

		ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", self.UpdateChatFilter)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_EMOTE", self.UpdateChatFilter)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", self.UpdateChatFilter)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_TEXT_EMOTE", self.UpdateChatFilter)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", self.UpdateChatFilter)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", self.UpdateChatFilter)
	end
end
