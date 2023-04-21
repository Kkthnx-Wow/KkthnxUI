local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Chat")

local ChatFrame_MessageEventHandler = ChatFrame_MessageEventHandler
local ChatFrame1 = ChatFrame1

-- Maximum number of chat log entries to keep
local MAX_LOG_ENTRIES = 0

-- Table to store chat log history
local chatHistory = {}

-- Flag to track if chat log history has been printed to chat frame
local hasPrinted = false

-- Flag to track if chat log history is currently being printed to chat frame
local isPrinting = false

-- Prints chat log history to chat frame
local function printChatHistory()
	isPrinting = true

	for i = #chatHistory, 1, -1 do
		local temp = chatHistory[i]
		ChatFrame_MessageEventHandler(ChatFrame1, temp[1], unpack(temp))
	end

	isPrinting = false
	hasPrinted = true
end

-- Saves chat message to chat log history
local function saveChatHistory(event, ...)
	local temp = { ... }

	if temp[1] then
		temp[1] = event
		temp[#temp + 1] = time()

		table.insert(chatHistory, 1, temp)

		for i = #chatHistory, MAX_LOG_ENTRIES + 1, -1 do
			table.remove(chatHistory, i)
		end
	end
end

-- Sets up chat history for logging
local function setupChatHistory(event, ...)
	if hasPrinted then
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

	-- Register events for chat logging
	for _, event in ipairs(EVENTS_TO_LOG) do
		K:RegisterEvent(event, setupChatHistory)
	end

	-- Print chat log history to chat frame
	printChatHistory()
end
