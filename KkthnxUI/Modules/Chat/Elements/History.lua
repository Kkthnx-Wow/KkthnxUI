local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Chat")

local ChatFrame_MessageEventHandler = ChatFrame_MessageEventHandler
local ChatFrame1 = ChatFrame1

local EntryEvent = 30
local EntryTime = 31
local LogMax
local Events = {
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

-- Function to print the chat history
function Module:PrintChatHistory()
	-- Temporary variable to hold the current chat history entry
	local Temp

	-- Set the flag to indicate that we are currently printing the chat history
	Module.IsPrinting = true

	-- Iterate through the chat history in reverse order
	for i = #KkthnxUIDB.ChatHistory, 1, -1 do
		-- Get the current chat history entry
		Temp = KkthnxUIDB.ChatHistory[i]

		-- Send the current chat history entry to the message event handler
		ChatFrame_MessageEventHandler(ChatFrame1, Temp[EntryEvent], unpack(Temp))
	end

	-- Set the flag to indicate that we have finished printing the chat history
	Module.IsPrinting = false
	Module.HasPrinted = true
end

-- Function to save the current chat message to the chat history
function Module:SaveChatHistory(event, ...)
	-- Create a table to hold the current chat message
	local Temp = { ... }

	-- Check if the current chat message is not empty
	if Temp[1] then
		-- Add the event and timestamp to the current chat message
		Temp[EntryEvent] = event
		Temp[EntryTime] = time()

		-- Insert the current chat message at the beginning of the chat history
		table.insert(KkthnxUIDB.ChatHistory, 1, Temp)

		-- Remove the oldest chat message if the chat history exceeds the maximum number of entries
		for _ = LogMax, #KkthnxUIDB.ChatHistory do
			table.remove(KkthnxUIDB.ChatHistory, LogMax)
		end
	end
end

-- Function to set up the chat history
function Module:SetupChatHistory(event, ...)
	-- Check if we have already printed the chat history
	if Module.HasPrinted then
		-- Save the current chat message to the chat history
		Module:SaveChatHistory(event, ...)
	end
end

-- Function to create the chat history
function Module:CreateChatHistory()
	-- Exit if we don't want to log any lines
	if C["Chat"].LogMax == 0 then
		return
	end

	-- Create the global table to hold the chat history if it doesn't exist
	KkthnxUIDB.ChatHistory = type(KkthnxUIDB.ChatHistory) == "table" and KkthnxUIDB.ChatHistory or {}

	-- Set the maximum number of entries to log
	LogMax = C["Chat"].LogMax

	-- Register the chat events to be logged
	for i = 1, #Events do
		K:RegisterEvent(Events[i], Module.SetupChatHistory)
	end

	-- Print the existing chat history
	Module:PrintChatHistory()
end
