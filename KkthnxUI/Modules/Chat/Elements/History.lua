local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Chat")

local ChatFrame_MessageEventHandler = ChatFrame_MessageEventHandler
local ChatFrame1 = ChatFrame1

-- Index of the event type in the chat log entry table
local entryEvent = 30

-- Index of the time the chat log entry was saved in the chat log entry table
local entryTime = 31

-- Maximum number of chat log entries to keep
local MAX_LOG_ENTRIES

-- Table to store chat log history
local chatHistory

-- Flag to track if chat log history has been printed to chat frame
local hasPrinted = false

-- Flag to track if chat log history is currently being printed to chat frame
local isPrinting = false

-- List of events to log
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

-- Prints chat log history to chat frame
local function printChatHistory()
	if not isPrinting then
		isPrinting = true
	else
		return
	end

	-- Print message indicating start of saved chat history
	print("|cffbbbbbb    [Saved Chat History]|r")

	for i = #chatHistory, 1, -1 do
		Temp = chatHistory[i]

		pcall(ChatFrame_MessageEventHandler, ChatFrame1, Temp[entryEvent], unpack(Temp))
	end

	-- Print message indicating end of saved chat history
	print("|cffbbbbbb    [End of Saved Chat History]|r")

	isPrinting = false
	hasPrinted = true
end

-- Saves chat message to chat log history
local function saveChatHistory(event, ...)
	local temp = { ... }

	if temp[1] then
		temp[entryEvent] = event
		temp[entryTime] = time()

		table.insert(chatHistory, 1, temp)

		for i = MAX_LOG_ENTRIES, #chatHistory do
			table.remove(chatHistory, MAX_LOG_ENTRIES)
		end
	end
end

-- Sets up chat history for logging
local function setupChatHistory(event, ...)
	if event == "PLAYER_LOGIN" then
		K:UnregisterEvent(event)
		printChatHistory()
	elseif hasPrinted then
		saveChatHistory(event, ...)
	end
end

-- Creates and initializes chat log history
function Module:CreateChatHistory()
	if C["Chat"].LogMax == 0 then
		return
	end

	chatHistory = type(KkthnxUIDB.ChatHistory) == "table" and KkthnxUIDB.ChatHistory or {}

	-- Maximum number of chat log entries to keep
	MAX_LOG_ENTRIES = C["Chat"].LogMax

	-- Register events for chat logging
	for _, event in ipairs(EVENTS_TO_LOG) do
		K:RegisterEvent(event, setupChatHistory)
	end

	-- Print chat log history to chat frame
	printChatHistory()
end
