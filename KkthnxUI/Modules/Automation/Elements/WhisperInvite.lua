local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Automation")

local acceptedKeyword

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
	if C["Automation"].WhisperInviteGuildFriends then -- Implement this later
		if IsInGuild() and isPlayerInGuild(name) then
			--print("Player", name, "is in the guild.")
			return true
		elseif C_FriendList.IsFriend(name) then
			--print("Player", name, "is in the friends list.")
			return true
		end
	else
		--print("WhisperInviteGuildFriends is disabled. Accepting all players.")
		return true
	end
	return false
end

-- Handle auto-invites on chat whisper
local function onChatWhisper(event, message, sender, _, _, _, _, _, _, _, _, _, _, presenceID)
	--print("Received whisper:", message)
	--print("Sender:", sender)

	if QueueStatusButton and QueueStatusButton:IsShown() then
		--print("You are currently in a queue. Ignoring whisper.")
		return
	end

	if acceptedKeyword and message:lower() == acceptedKeyword:lower() and isPlayerGuildOrFriend(sender) then
		--print("Whisper matched accepted keyword and sender is in guild or friends list.")

		if event == "CHAT_MSG_WHISPER" then
			--print("Inviting sender to party...")
			C_PartyInfo.InviteUnit(sender)
		elseif event == "CHAT_MSG_BN_WHISPER" then
			local accountInfo = C_BattleNet.GetAccountInfoByID(presenceID)
			if accountInfo then
				local gameAccountInfo = accountInfo.gameAccountInfo
				local gameID = gameAccountInfo.gameAccountID
				if gameID then
					if CanCooperateWithGameAccount(accountInfo) then
						--print("Inviting sender to party via Battle.net...")
						BNInviteFriend(gameID)
					end
				end
			end
		end
	else
		--print("Whisper did not match accepted keyword or sender is not in guild or friends list.")
	end
end

-- Update the list of accepted keywords
local function onUpdateAcceptedKeyword()
	acceptedKeyword = C["Automation"].WhisperInvite
end

-- Create auto whisper invite
function Module:CreateAutoWhisperInvite()
	if C["Chat"].WhisperInvite == "" then
		return
	end

	onUpdateAcceptedKeyword()
	K:RegisterEvent("CHAT_MSG_WHISPER", onChatWhisper)
	K:RegisterEvent("CHAT_MSG_BN_WHISPER", onChatWhisper)
end
