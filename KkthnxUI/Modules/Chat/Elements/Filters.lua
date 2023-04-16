local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Chat")

local gsub = string.gsub
local pairs, ipairs = pairs, ipairs
local min, max, tremove = math.min, math.max, table.remove
local IsGuildMember, C_FriendList_IsFriend, IsGUIDInGroup = IsGuildMember, C_FriendList.IsFriend, IsGUIDInGroup
local Ambiguate, GetTime = Ambiguate, GetTime
local C_BattleNet_GetGameAccountInfoByGUID = C_BattleNet.GetGameAccountInfoByGUID

-- Filter Chat symbols
local msgSymbols = { "`", "～", "＠", "＃", "^", "＊", "！", "？", "。", "|", " ", "—", "——", "￥", "’", "‘", "“", "”", "【", "】", "『", "』", "《", "》", "〈", "〉", "（", "）", "〔", "〕", "、", "，", "：", ",", "_", "/", "~" }

local FilterList = {}
function Module:UpdateFilterList()
	K.SplitList(FilterList, C["Chat"].ChatFilterList, true)
end

local WhiteFilterList = {}
function Module:UpdateFilterWhiteList()
	K.SplitList(WhiteFilterList, C["Chat"].ChatFilterWhiteList, true)
end

-- ECF strings compare
local last, this = {}, {}
function Module:CompareStrDiff(sA, sB) -- arrays of bytes
	local len_a, len_b = #sA, #sB
	for j = 0, len_b do
		last[j + 1] = j
	end
	for i = 1, len_a do
		this[1] = i
		for j = 1, len_b do
			this[j + 1] = (sA[i] == sB[j]) and last[j] or (min(last[j + 1], this[j], last[j]) + 1)
		end
		for j = 0, len_b do
			last[j + 1] = this[j + 1]
		end
	end
	return this[len_b + 1] / max(len_a, len_b)
end

C.BadBoys = {} -- debug
local chatLines, prevLineID, filterResult = {}, 0, false

local debugprint = true
function Module:GetFilterResult(event, msg, name, flag, guid)
	if name == K.Name or (event == "CHAT_MSG_WHISPER" and flag == "GM") or flag == "DEV" then
		-- Ignore messages from self, GMs in whispers, and developers
		if debugprint then
			print("Ignoring message from self/GM/developer:", msg, "Name:", name, "Flag:", flag)
		end
		return
	elseif guid and (IsGuildMember(guid) or C_BattleNet_GetGameAccountInfoByGUID(guid) or C_FriendList_IsFriend(guid) or IsGUIDInGroup(guid)) then
		-- Ignore messages from guild members, friends, and group members
		if debugprint then
			print("Ignoring message from guild member/friend/group member:", msg, "GUID:", guid)
		end
		return
	end

	if C["Chat"].BlockStranger and event == "CHAT_MSG_WHISPER" then -- Block strangers
		Module.MuteCache[name] = GetTime()
		if debugprint then
			print("Blocking message from stranger:", msg, "Name:", name)
		end
		return true
	end

	if C["Chat"].BlockSpammer and C.BadBoys[name] and C.BadBoys[name] >= 5 then
		if debugprint then
			print("Blocking message from spammer:", msg, "Name:", name, "BadBoys[name]:", C.BadBoys[name])
		end
		return true
	end

	local filterMsg = gsub(msg, "|H.-|h(.-)|h", "%1")
	filterMsg = gsub(filterMsg, "|c%x%x%x%x%x%x%x%x", "")
	filterMsg = gsub(filterMsg, "|r", "")

	if filterMsg == "" then
		-- Ignore empty messages
		if debugprint then
			print("Ignoring empty message")
		end
		return
	end

	-- Trash Filter
	for _, symbol in ipairs(msgSymbols) do
		filterMsg = gsub(filterMsg, symbol, "")
	end
	if debugprint then
		print("Filtering symbols:", msgSymbols, "Filter message:", filterMsg)
	end

	if event == "CHAT_MSG_CHANNEL" then
		local matches = 0
		local found
		for keyword in pairs(WhiteFilterList) do
			if keyword ~= "" then
				found = true
				local _, count = gsub(filterMsg, keyword, "")
				if count > 0 then
					matches = matches + 1
					if debugprint then
						print("Found white filter keyword:", keyword, "count:", count)
					end
				end
			end
		end
		if matches == 0 and found then
			if debugprint then
				print("No matches found in white filter list")
			end
			return 0
		end
	end

	local matches = 0
	for keyword in pairs(FilterList) do
		if keyword ~= "" then
			local _, count = gsub(filterMsg, keyword, "")
			if count > 0 then
				matches = matches + 1
				if debugprint then
					print("Found filter keyword:", keyword, "count:", count)
				end
			end
		end
	end

	if matches >= C["Chat"].FilterMatches then
		if debugprint then
			print("Matched filter count:", matches, "Filter matches required:", C["Chat"].FilterMatches)
		end
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
		if line[1] == msgTable[1] and ((event == "CHAT_MSG_CHANNEL" and msgTable[3] - line[3] < 0.6) or Module:CompareStrDiff(line[2], msgTable[2]) <= 0.1) then
			if debugprint then
				print("Repeat message detected! Chat line removed.")
			end
			tremove(chatLines, i)
			return true
		end
	end
	if chatLinesSize >= 30 then
		if debugprint then
			print("Chat lines limit reached! Oldest chat line removed.")
		end
		tremove(chatLines, 1)
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
		ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", self.UpdateChatFilter)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", self.UpdateChatFilter)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", self.UpdateChatFilter)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_EMOTE", self.UpdateChatFilter)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_TEXT_EMOTE", self.UpdateChatFilter)
	end
end
