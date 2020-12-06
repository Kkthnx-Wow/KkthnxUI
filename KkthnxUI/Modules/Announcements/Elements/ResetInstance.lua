local K, C = unpack(select(2, ...))
local Module = K:GetModule("Announcements")

local _G = _G
local string_match = _G.string.match
local string_gsub = _G.string.gsub
local string_format = _G.string.format

local msgList = {
	INSTANCE_RESET_FAILED = "Cannot reset %s (There are players still inside the instance.)",
	INSTANCE_RESET_FAILED_OFFLINE = "Cannot reset %s (There are players offline in your party.)",
	INSTANCE_RESET_FAILED_ZONING = "Cannot reset %s (There are players in your party attempting to zone into an instance.)",
	INSTANCE_RESET_SUCCESS = "%s has been reset",
}

function Module:SetupResetInstance(text)
	for systemMessage, friendlyMessage in pairs(msgList) do
		systemMessage = _G[systemMessage]
		if (string_match(text, string_gsub(systemMessage, "%%s", ".+"))) then
			local instance = string_match(text, string_gsub(systemMessage, "%%s", "(.+)"))
			SendChatMessage(string_format("KkthnxUI: " .. friendlyMessage, instance), K.CheckChat())
			return
		end
	end
end

function Module:CreateResetInstance()
	if C["Announcements"].ResetInstance then
		K:RegisterEvent("CHAT_MSG_SYSTEM", Module.SetupResetInstance)
	else
		K:UnregisterEvent("CHAT_MSG_SYSTEM", Module.SetupResetInstance)
	end
end