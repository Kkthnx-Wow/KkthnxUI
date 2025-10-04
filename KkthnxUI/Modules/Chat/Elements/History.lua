local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Chat")

local ChatFrame_MessageEventHandler = ChatFrame_MessageEventHandler
local ChatFrame1 = ChatFrame1

local entryEvent = 30
local entryTime = 31
local chatHistory = {}
local hasRestored = false
local isPrinting = false
local eventsRegistered = false

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

local function getMaxLogEntries()
	local value = C and C["Chat"] and C["Chat"].LogMax
	if type(value) == "number" then
		if value < 0 then
			return 0
		end
		return value
	end
	return 250
end

local function printChatHistory()
	if isPrinting or hasRestored then
		return
	end

	isPrinting = true

	if #chatHistory > 0 then
		local addonName = K.Title or "KkthnxUI"
		print(string.format("|cff99ccff[%s]|r |cffbbbbbbRestoring saved chat history|r |cff66ff66(%d)|r", addonName, #chatHistory))
		for i = #chatHistory, 1, -1 do
			local temp = chatHistory[i]
			pcall(ChatFrame_MessageEventHandler, ChatFrame1, temp[entryEvent], unpack(temp))
		end
		print(string.format("|cff99ccff[%s]|r |cffbbbbbbEnd of saved chat history|r", addonName))
	end

	isPrinting = false
	hasRestored = true
end

local function saveChatHistory(event, ...)
	if getMaxLogEntries() == 0 then
		return
	end

	if isPrinting then
		return
	end

	local temp = { ... }
	if not temp[1] then
		return
	end

	temp[entryEvent] = event
	temp[entryTime] = time()

	table.insert(chatHistory, 1, temp)

	local maxEntries = getMaxLogEntries()
	while #chatHistory > maxEntries do
		table.remove(chatHistory, #chatHistory)
	end

	KkthnxUIDB.ChatHistory = chatHistory
end

local function registerChatEvents()
	if eventsRegistered then
		return
	end
	for _, e in ipairs(EVENTS_TO_LOG) do
		K:RegisterEvent(e, saveChatHistory)
	end
	eventsRegistered = true
end

local function unregisterChatEvents()
	if not eventsRegistered then
		return
	end
	for _, e in ipairs(EVENTS_TO_LOG) do
		K:UnregisterEvent(e, saveChatHistory)
	end
	eventsRegistered = false
end

-- Clear saved chat history (DB + in-memory)
function Module:ClearChatHistory()
	if wipe then
		wipe(chatHistory)
	else
		chatHistory = {}
	end
	KkthnxUIDB.ChatHistory = nil
	hasRestored = false
	print("|cff99ccff[KkthnxUI]|r Cleared saved chat history.")
end

-- Live update handler for GUI changes
function Module:onLogMaxChanged(newValue)
	local maxEntries = tonumber(newValue) or getMaxLogEntries()
	if maxEntries <= 0 then
		unregisterChatEvents()
		if wipe then
			wipe(chatHistory)
		else
			chatHistory = {}
		end
		KkthnxUIDB.ChatHistory = nil
		return
	end

	registerChatEvents()

	-- Trim history immediately if decreased
	while #chatHistory > maxEntries do
		table.remove(chatHistory, #chatHistory)
	end
	KkthnxUIDB.ChatHistory = chatHistory
end

function Module:CreateChatHistory()
	local maxEntries = getMaxLogEntries()

	if maxEntries ~= 0 then
		chatHistory = KkthnxUIDB.ChatHistory or {}
		registerChatEvents()
		printChatHistory()
	else
		unregisterChatEvents()
		if wipe then
			wipe(chatHistory)
		else
			chatHistory = {}
		end
		KkthnxUIDB.ChatHistory = nil
	end
end
