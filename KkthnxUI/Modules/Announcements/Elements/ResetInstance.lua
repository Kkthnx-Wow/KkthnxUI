local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Announcements")

local string_match = string.match
local string_format = string.format

-- Precompute patterns for matching system messages
local resetMessageList = {
	{ pattern = _G.INSTANCE_RESET_FAILED:gsub("%%s", ".+"), friendlyMessage = "Cannot reset %s (There are players still inside the instance.)" },
	{ pattern = _G.INSTANCE_RESET_FAILED_OFFLINE:gsub("%%s", ".+"), friendlyMessage = "Cannot reset %s (There are players offline in your party.)" },
	{ pattern = _G.INSTANCE_RESET_FAILED_ZONING:gsub("%%s", ".+"), friendlyMessage = "Cannot reset %s (There are players in your party attempting to zone into an instance.)" },
	{ pattern = _G.INSTANCE_RESET_SUCCESS:gsub("%%s", ".+"), friendlyMessage = "%s has been reset" },
}

-- Function that sets up instance reset messages
local function SetupResetInstance(_, text)
	for _, resetInfo in ipairs(resetMessageList) do
		if string_match(text, resetInfo.pattern) then
			local instance = string_match(text, resetInfo.pattern:gsub(".+", "(.+)"))
			SendChatMessage(string_format(resetInfo.friendlyMessage, instance), K.CheckChat())
			return
		end
	end
end

-- Function to create or remove instance reset announcements
function Module:CreateResetInstance()
	if C["Announcements"].ResetInstance then
		K:RegisterEvent("CHAT_MSG_SYSTEM", SetupResetInstance)
	else
		K:UnregisterEvent("CHAT_MSG_SYSTEM", SetupResetInstance)
	end
end
