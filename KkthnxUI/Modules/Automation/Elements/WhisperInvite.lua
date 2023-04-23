local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Automation")

-- Store the list of accepted keywords in a table
local acceptedKeywords = {}

-- Update the list of accepted keywords
local function updateAcceptedKeywords()
	for word in string.gmatch(C["Automation"].WhisperInvite, "[^,]+") do
		table.insert(acceptedKeywords, word)
	end
	-- print("Accepted keywords: ", table.concat(acceptedKeywords, ", "))
end

-- Check if a player is in guild
local function isPlayerInGuild(unitName)
	if not unitName or not IsInGuild() then
		return false
	end
	for i = 1, GetNumGuildMembers() do
		local name = GetGuildRosterInfo(i)
		if name and Ambiguate(name, "none") == Ambiguate(unitName, "none") then
			return true
		end
	end
	return false
end

-- Check if a player is in the player's guild or friends list
local function isPlayerGuildOrFriend(name)
	if C["Automation"].WhisperInviteGuildFriends then
		if IsInGuild() and isPlayerInGuild(name) then
			return true
		elseif C_FriendList.IsFriend(name) then
			return true
		end
	else
		return true
	end
	return false
end

-- Handle auto-invites on chat whisper
local function onChatWhisper(event, message, sender, _, _, _, _, _, _, _, _, _, _, presenceID)
	if not acceptedKeywords then
		return
	end
	local lowerMessage = message:lower()
	for word in pairs(acceptedKeywords) do
		if lowerMessage:match(word) and isPlayerGuildOrFriend(sender) then
			-- K.Print("Auto-invite triggered for keyword:", word)
			if event == "CHAT_MSG_WHISPER" then
				C_PartyInfo.InviteUnit(sender)
			elseif event == "CHAT_MSG_BN_WHISPER" then
				BNInviteFriend(presenceID)
			end
		end
	end
end

-- Update the list of accepted keywords
local function onUpdateAcceptedKeywords()
	wipe(acceptedKeywords)
	updateAcceptedKeywords()
end

-- Create auto whisper invite
function Module:CreateAutoWhisperInvite()
	if C["Chat"].WhisperInvite == "" then
		return
	end
	-- Update the list of keywords to trigger auto-invites
	onUpdateAcceptedKeywords()
	-- Register the onChatWhisper function to handle incoming whispers
	K:RegisterEvent("CHAT_MSG_WHISPER", onChatWhisper)
	-- Register the onChatWhisper function to handle incoming Battle.net whispers
	K:RegisterEvent("CHAT_MSG_BN_WHISPER", onChatWhisper)
end
