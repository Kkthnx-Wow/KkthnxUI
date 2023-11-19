local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Chat")

local ChatFrame_MessageEventHandler = ChatFrame_MessageEventHandler
local ChatFrame1 = ChatFrame1

local entryEvent = 30
local entryTime = 31
local MAX_LOG_ENTRIES = C["Chat"].LogMax

local chatHistory = {}
local hasPrinted = false
local isPrinting = false

local EVENTS_TO_LOG = {
	"CHAT_MSG_INSTANCE_CHAT",
	"CHAT_MSG_INSTANCE_CHAT_LEADER",
	"CHAT_MSG_EMOTE",
	"CHAT_MSG_GUILD",
	"CHAT_MSG_OFFICER",
	"CHAT_MSG_PARTY",
	"CHAT_MSG_PARTY_LEADER",
	"CHAT_MSG_RAID",
	"CHAT_MSG_RAID_LEADER",
	"CHAT_MSG_RAID_WARNING",
	"CHAT_MSG_SAY",
	"CHAT_MSG_WHISPER",
	"CHAT_MSG_WHISPER_INFORM",
	"CHAT_MSG_YELL",
}

local function printChatHistory()
	if isPrinting then
		return
	end

	isPrinting = true

	print("|cffbbbbbb    [Saved Chat History]|r")

	for i = #chatHistory, 1, -1 do
		local temp = chatHistory[i]
		pcall(ChatFrame_MessageEventHandler, ChatFrame1, temp[entryEvent], unpack(temp))
	end

	print("|cffbbbbbb    [End of Saved Chat History]|r")

	isPrinting = false
	hasPrinted = true
end

local function saveChatHistory(event, ...)
	local temp = { ... }
	if not temp[1] then
		return
	end

	temp[entryEvent] = event
	temp[entryTime] = time()

	table.insert(chatHistory, 1, temp)

	while #chatHistory > MAX_LOG_ENTRIES do
		table.remove(chatHistory, #chatHistory)
	end
end

local function setupChatHistory(event, ...)
	if event == "PLAYER_LOGIN" then
		K:UnregisterEvent(event)
		printChatHistory()
	elseif hasPrinted then
		saveChatHistory(event, ...)
	end
end

function Module:CreateChatHistory()
	if MAX_LOG_ENTRIES == 0 then
		return
	end

	chatHistory = KkthnxUIDB.ChatHistory or {}

	for _, event in ipairs(EVENTS_TO_LOG) do
		K:RegisterEvent(event, setupChatHistory)
	end

	printChatHistory()
end
