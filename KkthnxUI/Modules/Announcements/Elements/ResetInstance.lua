local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Announcements")

local string_match = string.match
local string_gsub = string.gsub
local string_format = string.format

-- Table that contains mapping between system messages and friendly messages
local resetMessageList = {
	INSTANCE_RESET_FAILED = "Cannot reset %s (There are players still inside the instance.)",
	INSTANCE_RESET_FAILED_OFFLINE = "Cannot reset %s (There are players offline in your party.)",
	INSTANCE_RESET_FAILED_ZONING = "Cannot reset %s (There are players in your party attempting to zone into an instance.)",
	INSTANCE_RESET_SUCCESS = "%s has been reset",
}

-- Function that sets up instance reset messages
local function SetupResetInstance(_, text)
	-- Iterate through each system message and friendly message in resetMessageList table
	for systemMessage, friendlyMessage in pairs(resetMessageList) do
		-- Get the system message from global variable
		systemMessage = _G[systemMessage]
		-- Check if the input text matches the system message
		if string_match(text, string_gsub(systemMessage, "%%s", ".+")) then
			-- Extract the instance name from the text
			local instance = string_match(text, string_gsub(systemMessage, "%%s", "(.+)"))
			-- Send the friendly message to the appropriate chat channel
			SendChatMessage(string_format(friendlyMessage, instance), K.CheckChat())
			-- Exit the function once the message has been sent
			return
		end
	end
end

function Module:CreateResetInstance()
	if not C["Announcements"].ResetInstance then
		return
	end

	K:RegisterEvent("CHAT_MSG_SYSTEM", SetupResetInstance)
end
