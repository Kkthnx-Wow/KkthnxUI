local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Announcements")

local string_match = string.match
local string_format = string.format
local GetTime = GetTime
local ipairs = ipairs

-- Precompute anchored match/capture patterns from Blizzard strings
local function _Gv(key, fallback)
	local g = _G
	if type(g) == "table" then
		local v = rawget(g, key)
		if v ~= nil then
			return v
		end
	end
	return fallback
end

local L_FAILED = _Gv("INSTANCE_RESET_FAILED", "Instance reset failed: %s")
local L_FAILED_OFFLINE = _Gv("INSTANCE_RESET_FAILED_OFFLINE", "Instance reset failed (offline): %s")
local L_FAILED_ZONING = _Gv("INSTANCE_RESET_FAILED_ZONING", "Instance reset failed (zoning): %s")
local L_SUCCESS = _Gv("INSTANCE_RESET_SUCCESS", "%s has been reset")

local resetMessageList = {
	{ match = "^" .. L_FAILED:gsub("%%s", ".+") .. "$", capture = "^" .. L_FAILED:gsub("%%s", "(.+)") .. "$", friendlyMessage = L["Cannot reset %s (There are players still inside the instance.)"] or "Cannot reset %s (There are players still inside the instance.)" },
	{ match = "^" .. L_FAILED_OFFLINE:gsub("%%s", ".+") .. "$", capture = "^" .. L_FAILED_OFFLINE:gsub("%%s", "(.+)") .. "$", friendlyMessage = L["Cannot reset %s (There are players offline in your party.)"] or "Cannot reset %s (There are players offline in your party.)" },
	{ match = "^" .. L_FAILED_ZONING:gsub("%%s", ".+") .. "$", capture = "^" .. L_FAILED_ZONING:gsub("%%s", "(.+)") .. "$", friendlyMessage = L["Cannot reset %s (There are players in your party attempting to zone into an instance.)"] or "Cannot reset %s (There are players in your party attempting to zone into an instance.)" },
	{ match = "^" .. L_SUCCESS:gsub("%%s", ".+") .. "$", capture = "^" .. L_SUCCESS:gsub("%%s", "(.+)") .. "$", friendlyMessage = L["%s has been reset"] or "%s has been reset" },
}

-- Dedupe guard for identical system messages in a short window
Module._lastResetText = nil
Module._lastResetTime = 0

local function SetupResetInstance(_, text)
	-- Ignore duplicates within 1 second
	local now = GetTime()
	if text == Module._lastResetText and (now - (Module._lastResetTime or 0)) < 1 then
		return
	end

	for _, info in ipairs(resetMessageList) do
		if string_match(text, info.match) then
			local instance = string_match(text, info.capture) or ""
			Module._lastResetText = text
			Module._lastResetTime = now
			SendChatMessage(string_format(info.friendlyMessage, instance), K.CheckChat())
			return
		end
	end
end

function Module:CreateResetInstance()
	if C["Announcements"].ResetInstance then
		K:RegisterEvent("CHAT_MSG_SYSTEM", SetupResetInstance)
	else
		K:UnregisterEvent("CHAT_MSG_SYSTEM", SetupResetInstance)
	end
end
