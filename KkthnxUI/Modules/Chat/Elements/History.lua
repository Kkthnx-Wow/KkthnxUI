--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Saves and restores chat history across sessions.
-- - Design: Stores chat messages in a persistent database and re-plays them into the main chat frame on login.
-- - Events: CHAT_MSG_SAY, CHAT_MSG_WHISPER, etc.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Chat")

-- PERF: Localize globals and API functions to reduce lookup overhead.
local _G = _G
local ChatFrame1 = _G.ChatFrame1
local ChatFrame_MessageEventHandler = _G.ChatFrame_MessageEventHandler
local ipairs = ipairs
local pcall = pcall
local print = print
local string_format = string.format
local table_insert = table.insert
local table_remove = table.remove
local table_unpack = unpack
local table_wipe = table.wipe
local time = time
local tonumber = tonumber
local type = type

-- ---------------------------------------------------------------------------
-- Constants & State
-- ---------------------------------------------------------------------------
local ENTRY_EVENT = 30
local ENTRY_TIME = 31

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

-- ---------------------------------------------------------------------------
-- Internal Logic
-- ---------------------------------------------------------------------------
local function getMaxLogEntries()
	-- REASON: Retrieves the maximum number of history entries from user configuration.
	local value = C["Chat"] and C["Chat"].LogMax
	if type(value) == "number" then
		return (value < 0) and 0 or value
	end
	return 250
end

local function printChatHistory()
	-- REASON: Re-plays the saved chat database into the main chat frame.
	if isPrinting or hasRestored then
		return
	end

	isPrinting = true

	if #chatHistory > 0 then
		local addonName = K.Title or "KkthnxUI"
		print(string_format("|cff99ccff[%s]|r |cffbbbbbbRestoring saved chat history|r |cff66ff66(%d)|r", addonName, #chatHistory))
		for i = #chatHistory, 1, -1 do
			local messageData = chatHistory[i]
			-- WARNING: Use pcall when invoking message handlers as malformed history entries could cause UI errors.
			pcall(ChatFrame_MessageEventHandler, ChatFrame1, messageData[ENTRY_EVENT], table_unpack(messageData))
		end
		print(string_format("|cff99ccff[%s]|r |cffbbbbbbEnd of saved chat history|r", addonName))
	end

	isPrinting = false
	hasRestored = true
end

local function saveChatHistory(event, ...)
	-- REASON: Captures chat messages and stores them in the persistent history table.
	if getMaxLogEntries() == 0 or isPrinting then
		return
	end

	local messageData = { ... }
	if not messageData[1] then
		return
	end

	messageData[ENTRY_EVENT] = event
	messageData[ENTRY_TIME] = time()

	table_insert(chatHistory, 1, messageData)

	-- REASON: Trims the history table to respect the configured maximum entry limit.
	local maxEntries = getMaxLogEntries()
	while #chatHistory > maxEntries do
		table_remove(chatHistory, #chatHistory)
	end

	_G.KkthnxUIDB.ChatHistory = chatHistory
end

local function registerChatEvents()
	if eventsRegistered then
		return
	end
	for _, eventName in ipairs(EVENTS_TO_LOG) do
		K:RegisterEvent(eventName, saveChatHistory)
	end
	eventsRegistered = true
end

local function unregisterChatEvents()
	if not eventsRegistered then
		return
	end
	for _, eventName in ipairs(EVENTS_TO_LOG) do
		K:UnregisterEvent(eventName, saveChatHistory)
	end
	eventsRegistered = false
end

-- ---------------------------------------------------------------------------
-- Module API
-- ---------------------------------------------------------------------------
function Module:ClearChatHistory()
	-- REASON: Manual utility to wipe the history database and current session cache.
	if table_wipe then
		table_wipe(chatHistory)
	else
		chatHistory = {}
	end
	_G.KkthnxUIDB.ChatHistory = nil
	hasRestored = false
	print("|cff99ccff[KkthnxUI]|r Cleared saved chat history.")
end

function Module:onLogMaxChanged(newValue)
	-- REASON: Live update handler for when the user modifies the history limit in the GUI.
	local maxEntries = tonumber(newValue) or getMaxLogEntries()
	if maxEntries <= 0 then
		unregisterChatEvents()
		if table_wipe then
			table_wipe(chatHistory)
		else
			chatHistory = {}
		end
		_G.KkthnxUIDB.ChatHistory = nil
		return
	end

	registerChatEvents()

	while #chatHistory > maxEntries do
		table_remove(chatHistory, #chatHistory)
	end
	_G.KkthnxUIDB.ChatHistory = chatHistory
end

-- ---------------------------------------------------------------------------
-- Initialization
-- ---------------------------------------------------------------------------
function Module:CreateChatHistory()
	-- REASON: Registration entry point; loads the saved context and initiates restoration.
	local maxEntries = getMaxLogEntries()

	if maxEntries ~= 0 then
		chatHistory = _G.KkthnxUIDB.ChatHistory or {}
		registerChatEvents()
		printChatHistory()
	else
		unregisterChatEvents()
		if table_wipe then
			table_wipe(chatHistory)
		else
			chatHistory = {}
		end
		_G.KkthnxUIDB.ChatHistory = nil
	end
end
