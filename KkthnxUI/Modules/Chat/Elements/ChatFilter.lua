--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Notes:
-- - Purpose: Keyword + near-duplicate spam filter for public chat / whispers.
-- - Design: ChatFrame message filters; FilterList is a space/comma-separated string
--   (K.SplitList). Friends / guild / group / self are never filtered.
-- - Secret: early-out on opaque msg / author (Midnight messaging lockdown).
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Chat")

local pairs = pairs
local gsub = string.gsub
local strfind = string.find
local strlower = string.lower
local min = math.min
local max = math.max
local tremove = table.remove
local wipe = wipe
local GetTime = GetTime
local Ambiguate = Ambiguate
local IsGuildMember = IsGuildMember
local C_PartyInfo_IsGUIDInGroup = C_PartyInfo and C_PartyInfo.IsGUIDInGroup
local C_FriendList_IsFriend = C_FriendList.IsFriend
local C_BattleNet_GetGameAccountInfoByGUID = C_BattleNet.GetGameAccountInfoByGUID
local ChatFrame_AddMessageEventFilter = ChatFrame_AddMessageEventFilter
local ChatFrame_RemoveMessageEventFilter = ChatFrame_RemoveMessageEventFilter

local FILTER_EVENTS = {
	"CHAT_MSG_CHANNEL",
	"CHAT_MSG_SAY",
	"CHAT_MSG_YELL",
	"CHAT_MSG_WHISPER",
	"CHAT_MSG_EMOTE",
	"CHAT_MSG_TEXT_EMOTE",
}

-- Symbols stripped before keyword / repeat matching.
local msgSymbols = {
	"`", "～", "＠", "＃", "^", "＊", "！", "？", "。", "|", " ", "—", "——", "￥",
	"’", "‘", "“", "”", "【", "】", "『", "』", "《", "》", "〈", "〉", "（", "）",
	"〔", "〕", "、", "，", "：", ",", "_", "/", "~",
}

local FilterList = {}
local BadBoys = {}
local chatLines, prevLineID = {}, 0
local filterResult
local last, this = {}, {}
local rowPool = {}
local filtersInstalled = false

-- ---
-- Filter list (C["Chat"].FilterList → set)
-- ---

function Module:UpdateChatFilterList()
	K.SplitList(FilterList, C["Chat"].FilterList, true)
end

-- ---
-- Levenshtein (reused rows — no per-call GC)
-- ---

local function AcquireChatLine(name, timestamp)
	local row = tremove(rowPool)
	if row then
		row[1], row[3] = name, timestamp
		wipe(row[2])
	else
		row = { name, {}, timestamp }
	end
	return row
end

local function ReleaseChatLine(row)
	if not row then
		return
	end
	row[1], row[3] = nil, nil
	wipe(row[2])
	rowPool[#rowPool + 1] = row
end

local function CompareStrDiff(sA, sB)
	local lenA, lenB = #sA, #sB
	if lenA == 0 or lenB == 0 then
		return 1
	end

	for j = 0, lenB do
		last[j + 1] = j
	end
	for i = 1, lenA do
		this[1] = i
		for j = 1, lenB do
			this[j + 1] = (sA[i] == sB[j]) and last[j] or (min(last[j + 1], this[j], last[j]) + 1)
		end
		for j = 0, lenB do
			last[j + 1] = this[j + 1]
		end
	end
	return this[lenB + 1] / max(lenA, lenB)
end

local function IsTrustedGUID(guid)
	if not guid or guid == "" or K.IsSecret(guid) then
		return false
	end
	if IsGuildMember(guid) then
		return true
	end
	if C_BattleNet_GetGameAccountInfoByGUID(guid) then
		return true
	end
	if C_FriendList_IsFriend(guid) then
		return true
	end
	if C_PartyInfo_IsGUIDInGroup and C_PartyInfo_IsGUIDInGroup(guid) then
		return true
	end
	return false
end

local function GetFilterResult(event, msg, name, flag, guid)
	-- Never filter yourself, GMs, or developers.
	if name == K.Name or (event == "CHAT_MSG_WHISPER" and flag == "GM") or flag == "DEV" then
		return
	end

	if IsTrustedGUID(guid) then
		return
	end

	-- Session spammers (tripped keyword/repeat enough times).
	if BadBoys[name] and BadBoys[name] >= 5 then
		return true
	end

	local filterMsg = gsub(msg, "|H.-|h(.-)|h", "%1")
	filterMsg = gsub(filterMsg, "|c%x%x%x%x%x%x%x%x", "")
	filterMsg = gsub(filterMsg, "|C%x%x%x%x%x%x%x%x", "")
	filterMsg = gsub(filterMsg, "|r", "")
	filterMsg = gsub(filterMsg, "|R", "")

	for i = 1, #msgSymbols do
		filterMsg = gsub(filterMsg, msgSymbols[i], "")
	end
	filterMsg = strlower(filterMsg)

	-- Keyword blacklist — need FilterMatches hits (default 1).
	local matches = 0
	local threshold = C["Chat"].FilterMatches or 1
	for keyword in pairs(FilterList) do
		if keyword ~= "" then
			-- Plain substring so Lua magic chars in the list can't throw.
			local needle = type(keyword) == "string" and strlower(keyword) or tostring(keyword)
			if strfind(filterMsg, needle, 1, true) then
				matches = matches + 1
			end
		end
	end
	if matches >= threshold then
		return true
	end

	-- Repeat filter: same sender, near-identical body (or channel flood < 0.6s).
	local msgTable = AcquireChatLine(name, GetTime())
	if filterMsg == "" then
		filterMsg = msg
	end
	for i = 1, #filterMsg do
		msgTable[2][i] = filterMsg:byte(i)
	end

	local size = #chatLines
	chatLines[size + 1] = msgTable
	for i = 1, size do
		local line = chatLines[i]
		if line[1] == msgTable[1] and ((event == "CHAT_MSG_CHANNEL" and msgTable[3] - line[3] < 0.6) or CompareStrDiff(line[2], msgTable[2]) <= 0.1) then
			ReleaseChatLine(tremove(chatLines, i))
			return true
		end
	end
	if size >= 30 then
		ReleaseChatLine(tremove(chatLines, 1))
	end
end

-- Filter callback: (chatFrame, event, msg, author, …). Colon form eats chatFrame as self.
function Module:UpdateChatFilter(event, msg, author, _, _, _, flag, _, _, _, _, lineID, guid)
	if not C["Chat"].ChatFilter then
		return
	end
	if not msg or K.IsSecret(msg) then
		return
	end

	-- One verdict per lineID — shared across every chat frame showing it.
	if lineID ~= prevLineID then
		prevLineID = lineID
		if K.IsSecret(author) then
			filterResult = nil
		else
			local name = Ambiguate(author, "none")
			filterResult = GetFilterResult(event, msg, name, flag, guid)
			if filterResult then
				BadBoys[name] = (BadBoys[name] or 0) + 1
				-- Mute whisper sound for lines we hide this pass.
				if event == "CHAT_MSG_WHISPER" then
					Module.MuteCache[name] = GetTime()
				end
			end
		end
	end

	return filterResult
end

function Module:UpdateChatFilterState()
	Module:UpdateChatFilterList()

	local enable = C["Chat"].ChatFilter
	if enable and not filtersInstalled then
		for i = 1, #FILTER_EVENTS do
			ChatFrame_AddMessageEventFilter(FILTER_EVENTS[i], Module.UpdateChatFilter)
		end
		filtersInstalled = true
	elseif not enable and filtersInstalled then
		for i = 1, #FILTER_EVENTS do
			ChatFrame_RemoveMessageEventFilter(FILTER_EVENTS[i], Module.UpdateChatFilter)
		end
		filtersInstalled = false
	end
end

function Module:CreateChatFilter()
	Module:UpdateChatFilterState()
end
