local K, C = unpack(select(2, ...))
local Module = K:GetModule("Chat")

local _G = _G
local math_max = _G.math.max
local math_min = _G.math.min
local string_find = _G.string.find
local string_gsub = _G.string.gsub
local table_remove = _G.table.remove

local Ambiguate = _G.Ambiguate
local BNGetGameAccountInfoByGUID = _G.BNGetGameAccountInfoByGUID
local C_FriendList_IsFriend = _G.IsCharacterFriend
local C_Timer_After = _G.C_Timer_After
local ChatFrame_AddMessageEventFilter = _G.ChatFrame_AddMessageEventFilter
local GetCVarBool = _G.GetCVarBool
local GetTime = _G.GetTime
local IsGUIDInGroup = _G.IsGUIDInGroup
local IsGuildMember = _G.IsGuildMember
local IsInInstance = _G.IsInInstance
local SetCVar = _G.SetCVar
local UnitIsUnit = _G.UnitIsUnit

local last = {}
local this = {}
local BadBoysList = {}
local FilterList = {}
local chatLines = {}
local prevLineID  = 0
local filterResult = false

local FilterMatches = 1
local ChatFilterList = "%* %-(.*)%||T(.*)||t(.*)||c(.*)%||r %[(.*)Announce by(.*)%] %[(.*)ARENA ANNOUNCER(.*)%] %[(.*)Autobroadcast(.*)%] %[(.*)BG Queue Announcer(.*)%] ERR_NOT_IN_INSTANCE_GROUP ERR_NOT_IN_RAID ERR_QUEST_ALREADY_ON ERR_LEARN_ABILITY_S ERR_LEARN_SPELL_S ERR_SPELL_UNLEARNED_S ERR_LEARN_PASSIVE_S ERR_PET_SPELL_UNLEARNED_S ERR_PET_LEARN_ABILITY_S ERR_PET_LEARN_SPELL_S"
local msgSymbols = {"`", "～", "＠", "＃", "^", "＊", "！", "？", "。", "|", " ", "—", "——", "￥", "’", "‘", "“", "”", "【", "】", "『", "』", "《", "》", "〈", "〉", "（", "）", "〔", "〕", "、", "，", "：", ",", "_", "/", "~", "%-", "%."}

function Module:UpdateFilterList()
	K.SplitList(FilterList, ChatFilterList, true)
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
	elseif guid and (IsGuildMember(guid) or BNGetGameAccountInfoByGUID(guid) or C_FriendList_IsFriend(guid) or (IsInInstance() and IsGUIDInGroup(guid))) then
		return
	end

	if BadBoysList[name] and BadBoysList[name] >= 5 then
		return true
	end

	local filterMsg = string_gsub(msg, "|H.-|h(.-)|h", "%1")
	filterMsg = string_gsub(filterMsg, "|c%x%x%x%x%x%x%x%x", "")
	filterMsg = string_gsub(filterMsg, "|r", "")

	-- Trash Filter
	for _, symbol in ipairs(msgSymbols) do
		filterMsg = string_gsub(filterMsg, symbol, "")
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

	if matches >= FilterMatches then
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
		if line[1] == msgTable[1] and ((msgTable[3] - line[3] < 0.6) or Module:CompareStrDiff(line[2], msgTable[2]) <= 0.1) then
			table_remove(chatLines, i)
			return true
		end
	end

	if chatLinesSize >= 30 then
		table_remove(chatLines, 1)
	end
end

function Module:UpdateChatFilter(event, msg, author, _, _, _, flag, _, _, _, _, lineID, guid)
	if lineID == 0 or lineID ~= prevLineID then
		prevLineID = lineID

		local name = Ambiguate(author, "none")
		filterResult = Module:GetFilterResult(event, msg, name, flag, guid)
		if filterResult then
			BadBoysList[name] = (BadBoysList[name] or 0) + 1
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
	SetCVar(cvar, value)
end

function Module:ToggleChatBubble(party)
	cvar = "chatBubbles"..(party and "Party" or "")
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
			end
			return true
		end
	end
end

-- Show itemlevel on chat hyperlinks
local function isItemHasLevel(link)
	local name, _, rarity, level, _, _, _, _, _, _, _, classID = GetItemInfo(link)
	if name and level and rarity > 1 and (classID == LE_ITEM_CLASS_WEAPON or classID == LE_ITEM_CLASS_ARMOR) then
		local itemLevel = K.GetItemLevel(link)
		return name, itemLevel
	end
end

local function isItemHasGem(link)
	local stats = GetItemStats(link)
	for index in pairs(stats) do
		if string.find(index, "EMPTY_SOCKET_") then
			return "|TInterface\\ItemSocketingFrame\\UI-EmptySocket-Prismatic:0|t"
		end
	end
	return ""
end

local itemCache = {}
local function convertItemLevel(link)
	if itemCache[link] then return itemCache[link] end

	local itemLink = string.match(link, "|Hitem:.-|h")
	if itemLink then
		local name, itemLevel = isItemHasLevel(itemLink)
		if name and itemLevel then
			link = gsub(link, "|h%[(.-)%]|h", "|h["..name.."("..itemLevel..isItemHasGem(itemLink)..")]|h")
			itemCache[link] = link
		end
	end
	return link
end

function Module:UpdateChatItemLevel(_, msg, ...)
	msg = gsub(msg, "(|Hitem:%d+:.-|h.-|h)", convertItemLevel)
	return false, msg, ...
end

function Module:CreateChatFilter()
	if C["Chat"].EnableFilter then
		self:UpdateFilterList()
		ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", self.UpdateChatFilter)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", self.UpdateChatFilter)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", self.UpdateChatFilter)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", self.UpdateChatFilter)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_EMOTE", self.UpdateChatFilter)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_TEXT_EMOTE", self.UpdateChatFilter)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID", self.UpdateChatFilter)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_LEADER", self.UpdateChatFilter)
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

	if C["Chat"].ChatItemLevel then
		ChatFrame_AddMessageEventFilter("CHAT_MSG_LOOT", self.UpdateChatItemLevel)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", self.UpdateChatItemLevel)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", self.UpdateChatItemLevel)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", self.UpdateChatItemLevel)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", self.UpdateChatItemLevel)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", self.UpdateChatItemLevel)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER", self.UpdateChatItemLevel)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID", self.UpdateChatItemLevel)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_LEADER", self.UpdateChatItemLevel)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY", self.UpdateChatItemLevel)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY_LEADER", self.UpdateChatItemLevel)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_GUILD", self.UpdateChatItemLevel)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_BATTLEGROUND", self.UpdateChatItemLevel)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_INSTANCE_CHAT", self.UpdateChatItemLevel)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_INSTANCE_CHAT_LEADER", self.UpdateChatItemLevel)
	end
end