local K, C = unpack(KkthnxUI)
local Module = K:GetModule("Chat")

local _G = _G
local ipairs = _G.ipairs
local math_max = _G.math.max
local math_min = _G.math.min
local pairs = _G.pairs
local string_find = _G.string.find
local string_gsub = _G.string.gsub
local table_remove = _G.table.remove
local tonumber = _G.tonumber

local Ambiguate = _G.Ambiguate
local BN_TOAST_TYPE_CLUB_INVITATION = _G.BN_TOAST_TYPE_CLUB_INVITATION or 6
local C_BattleNet_GetGameAccountInfoByGUID = _G.C_BattleNet.GetGameAccountInfoByGUID
local C_FriendList_IsFriend = _G.C_FriendList.IsFriend
local C_Timer_After = _G.C_Timer.After
local ChatFrame_AddMessageEventFilter = _G.ChatFrame_AddMessageEventFilter
local GetCVarBool = _G.GetCVarBool
local GetTime = _G.GetTime
local IsGUIDInGroup = _G.IsGUIDInGroup
local IsGuildMember = _G.IsGuildMember
local SetCVar = _G.SetCVar
local UnitIsUnit = _G.UnitIsUnit
local hooksecurefunc = _G.hooksecurefunc

local msgSymbols = {
	"`",
	"～",
	"＠",
	"＃",
	"^",
	"＊",
	"！",
	"？",
	"。",
	"|",
	" ",
	"—",
	"——",
	"￥",
	"’",
	"‘",
	"“",
	"”",
	"【",
	"】",
	"『",
	"』",
	"《",
	"》",
	"〈",
	"〉",
	"（",
	"）",
	"〔",
	"〕",
	"、",
	"，",
	"：",
	",",
	"_",
	"/",
	"~",
}
local addonBlockList = {
	"%(Task completed%)",
	"%*%*.+%*%*",
	"%[Accept task%]",
	":.+>",
	"<Bigfoot",
	"<iLvl>",
	"<LFG>",
	"<Team Item Level:.+>",
	"Attribute Notification",
	"EUI[:_]",
	"Interrupt:. +|Hspell",
	"Progress:",
	"PS death: .+>",
	"Task progress prompt",
	"wow.+Redemption Code",
	"wow.+Verification Code",
	"Xihan",
	"|Hspell.+=>",
	"【Love is not easy】",
	"【Love Plugin]",
	("%-"):rep(20),
}
local trashClubs = { "Let's Play Games Together", "Salute Us", "Small Uplift", "Stand up", "Tribe Chowder" }
local autoBroadcasts = {
	"%-(.*)%|T(.*)|t(.*)|c(.*)%|r",
	"%[(.*)ARENA ANNOUNCER(.*)%]",
	"%[(.*)Announce by(.*)%]",
	"%[(.*)Autobroadcast(.*)%]",
	"%[(.*)BG Queue Announcer(.*)%]",
	"You are not mounted so you can't dismount.",
}

C.BadBoys = {} -- debug
local FilterList = {}
local WhiteFilterList = {}
local chatLines = {}
local cvar
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
		Module.MuteThisTime = true
		return true
	end

	if C["Chat"].BlockSpammer and C.BadBoys[name] and C.BadBoys[name] >= 5 then
		return true
	end

	local filterMsg = string_gsub(msg, "|H.-|h(.-)|h", "%1")
	filterMsg = string_gsub(filterMsg, "|c%x%x%x%x%x%x%x%x", "")
	filterMsg = string_gsub(filterMsg, "|r", "")

	-- Trash Filter
	for _, symbol in ipairs(msgSymbols) do
		filterMsg = string_gsub(filterMsg, symbol, "")
	end

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
		if
			line[1] == msgTable[1]
			and ((event == "CHAT_MSG_CHANNEL" or event == "CHAT_MSG_MONSTER_SAY" and msgTable[3] - line[3] < 0.6) or Module:CompareStrDiff(line[2], msgTable[2]) <= 0.1)
		then
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

local function toggleCVar(value)
	value = tonumber(value) or 1
	SetCVar(cvar, value)
end

function Module:ToggleChatBubble(party)
	cvar = "chatBubbles" .. (party and "Party" or "")
	if not GetCVarBool(cvar) then
		return
	end

	toggleCVar(0)
	C_Timer_After(0.01, toggleCVar)
end

function Module:UpdateAddOnBlocker(event, msg, author)
	local name = Ambiguate(author, "none")
	if UnitIsUnit(name, "player") then
		return
	end

	for _, word in ipairs(addonBlockList) do
		if string_find(msg, word) then
			if event == "CHAT_MSG_SAY" or event == "CHAT_MSG_YELL" then
				Module:ToggleChatBubble()
			elseif event == "CHAT_MSG_PARTY" or event == "CHAT_MSG_PARTY_LEADER" then
				Module:ToggleChatBubble(true)
			elseif event == "CHAT_MSG_WHISPER" then
				Module.MuteThisTime = true
			end
			return true
		end
	end
end

function Module:BlockTrashClub()
	if self.toastType == BN_TOAST_TYPE_CLUB_INVITATION then
		local text = self.DoubleLine:GetText() or ""
		for _, name in pairs(trashClubs) do
			if string_find(text, name) then
				self:Hide()
				return
			end
		end
	end
end

function Module:AutoBroadcasts(_, msg, ...)
	for _, filter in ipairs(autoBroadcasts) do
		if string.match(msg, filter) then
			return true
		end
	end

	return false, msg, ...
end

function Module:CreateChatFilter()
	hooksecurefunc(BNToastFrame, "ShowToast", self.BlockTrashClub)

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

	if C["Chat"].BlockAddonAlert then
		ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", self.UpdateAddOnBlocker)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", self.UpdateAddOnBlocker)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_EMOTE", self.UpdateAddOnBlocker)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY", self.UpdateAddOnBlocker)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY_LEADER", self.UpdateAddOnBlocker)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID", self.UpdateAddOnBlocker)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_LEADER", self.UpdateAddOnBlocker)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_INSTANCE_CHAT", self.UpdateAddOnBlocker)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_INSTANCE_CHAT_LEADER", self.UpdateAddOnBlocker)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", self.UpdateAddOnBlocker)
	end

	ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", self.AutoBroadcasts)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_BOSS_EMOTE", self.AutoBroadcasts)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", self.AutoBroadcasts)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", self.AutoBroadcasts)
end
