local K, C = unpack(select(2, ...))
local Module = K:NewModule("ChatFilters", "AceEvent-3.0")

local _G = _G
local strfind, gsub = string.find, string.gsub
local pairs, ipairs, tonumber = pairs, ipairs, tonumber
local min, max, tremove = math.min, math.max, table.remove

local IsGuildMember, C_FriendList_IsFriend, IsGUIDInGroup, C_Timer_After = _G.IsGuildMember, _G.IsCharacterFriend, _G.IsGUIDInGroup, _G.C_Timer.After
local Ambiguate, UnitIsUnit, BNGetGameAccountInfoByGUID, GetTime, SetCVar = _G.Ambiguate, _G.UnitIsUnit, _G.BNGetGameAccountInfoByGUID, _G.GetTime, _G.SetCVar
local ChatFrame_AddMessageEventFilter = _G.ChatFrame_AddMessageEventFilter

function K.SplitList(list, variable, cleanup)
	if cleanup then
		wipe(list)
	end

	for word in gmatch(variable, "%S+") do
		list[word] = true
	end
end

local ChatFilterList = "%* %anal %nigger %[Autobroadcast] %[Autobroadcast]: %Autobroadcast"
local ChatMatches = 1

-- Filter Chat symbols
local msgSymbols = {
	"`","～","＠","＃","^","＊","！","？",
	"。","|"," ","—","——","￥","’","‘",
	"“","”","【","】","『","』","《","》","〈",
	"〉","（","）","〔","〕","、","，","：",",",
	"_","/","~","%-","%.",
}

local FilterList = {}
function Module:UpdateFilterList()
	K.SplitList(FilterList, ChatFilterList, true)
end

-- Ecf Strings Compare
local last, this = {}, {}
function Module:CompareStrDiff(sA, sB) -- Arrays Of Bytes
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

	return this[len_b+1] / max(len_a, len_b)
end

K.BadBoys = {} -- Debug
local chatLines, prevLineID, filterResult = {}, 0, false
function Module:GetFilterResult(event, msg, name, flag, guid)
	if name == K.Name or (event == "CHAT_MSG_WHISPER" and flag == "GM") or flag == "DEV" then
		return
	elseif guid and (IsGuildMember(guid) or BNGetGameAccountInfoByGUID(guid) or C_FriendList_IsFriend(guid) or (IsInInstance() and IsGUIDInGroup(guid))) then
		return
	end

	if K.BadBoys[name] and K.BadBoys[name] >= 5 then
		return true
	end

	local filterMsg = gsub(msg, "|H.-|h(.-)|h", "%1")
	filterMsg = gsub(filterMsg, "|c%x%x%x%x%x%x%x%x", "")
	filterMsg = gsub(filterMsg, "|r", "")

	-- Trash Filter
	for _, symbol in ipairs(msgSymbols) do
		filterMsg = gsub(filterMsg, symbol, "")
	end

	local matches = 0
	for keyword in pairs(FilterList) do
		if keyword ~= "" then
			local _, count = gsub(filterMsg, keyword, "")
			if count > 0 then
				matches = matches + 1
			end
		end
	end

	if matches >= ChatMatches then
		return true
	end

	-- ECF Repeat Filter
	local msgTable = {name, {}, GetTime()}
	if filterMsg == "" then
		filterMsg = msg
	end

	for i = 1, #filterMsg do
		msgTable[2][i] = filterMsg:byte(i)
	end

	local chatLinesSize = #chatLines
	chatLines[chatLinesSize+1] = msgTable
	for i = 1, chatLinesSize do
		local line = chatLines[i]
		if line[1] == msgTable[1] and ((msgTable[3] - line[3] < .6) or Module:CompareStrDiff(line[2], msgTable[2]) <= .1) then
			tremove(chatLines, i)
			return true
		end
	end

	if chatLinesSize >= 30 then
		tremove(chatLines, 1)
	end
end

function Module:UpdateChatFilter(event, msg, author, _, _, _, flag, _, _, _, _, lineID, guid)
	if lineID == 0 or lineID ~= prevLineID then
		prevLineID = lineID

		local name = Ambiguate(author, "none")
		filterResult = Module:GetFilterResult(event, msg, name, flag, guid)
		if filterResult then
			K.BadBoys[name] = (K.BadBoys[name] or 0) + 1
		end
	end

	return filterResult
end

-- Block addon msg
local addonBlockList = {
	"任务进度提示", "%[接受任务%]", "%(任务完成%)", "<大脚", "【爱不易】", "EUI[:_]", "打断:.+|Hspell", "PS 死亡: .+>", "%*%*.+%*%*", "<iLvl>", ("%-"):rep(20),
	"<小队物品等级:.+>", "<LFG>", "进度:", "属性通报", "汐寒", "wow.+兑换码", "wow.+验证码", "【有爱插件】", "：.+>"
}

local cvar
local function toggleCVar(value)
	value = tonumber(value) or 1

	if not _G.InCombatLockdown() then
		SetCVar(cvar, value)
	end
end

function Module:ToggleChatBubble(party)
	cvar = "chatBubbles"..(party and "Party" or "")
	if not _G.GetCVarBool(cvar) then
		return
	end

	toggleCVar(0)
	C_Timer_After(.01, toggleCVar)
end

function Module:UpdateAddOnBlocker(event, msg, author)
	local name = Ambiguate(author, "none")
	if UnitIsUnit(name, "player") then return end

	for _, word in ipairs(addonBlockList) do
		if strfind(msg, word) then
			if event == "CHAT_MSG_SAY" or event == "CHAT_MSG_YELL" then
				Module:ToggleChatBubble()
			elseif event == "CHAT_MSG_PARTY" or event == "CHAT_MSG_PARTY_LEADER" then
				Module:ToggleChatBubble(true)
			end
			return true
		end
	end
end

function Module:OnEnable()
	if C["Chat"].Filter ~= true then
		return
	end

	self:UpdateFilterList()
	ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", self.UpdateChatFilter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", self.UpdateChatFilter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", self.UpdateChatFilter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", self.UpdateChatFilter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_EMOTE", self.UpdateChatFilter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_TEXT_EMOTE", self.UpdateChatFilter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID", self.UpdateChatFilter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_LEADER", self.UpdateChatFilter)

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