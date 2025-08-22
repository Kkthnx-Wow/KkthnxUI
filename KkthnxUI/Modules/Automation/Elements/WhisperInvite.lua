local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Automation")

-- Cache WoW API functions
local IsInGuild = IsInGuild
local GetNumGuildMembers = GetNumGuildMembers
local GetGuildRosterInfo = GetGuildRosterInfo
local Ambiguate = Ambiguate
local C_FriendList_IsFriend = C_FriendList.IsFriend
local C_BattleNet_GetAccountInfoByID = C_BattleNet.GetAccountInfoByID
local CanCooperateWithGameAccount = CanCooperateWithGameAccount
local C_PartyInfo_InviteUnit = C_PartyInfo.InviteUnit
local BNInviteFriend = BNInviteFriend

local autoInviteKeyword

-- Check if a player is in the same guild
local function isPlayerInGuild(unitName)
	if not unitName or not IsInGuild() then
		return false
	end
	unitName = Ambiguate(unitName, "none")
	for i = 1, GetNumGuildMembers() do
		if Ambiguate(GetGuildRosterInfo(i), "none") == unitName then
			return true
		end
	end
	return false
end

-- Check if the player is either a guild member or a friend
local function isPlayerGuildOrFriend(name)
	if not C["Automation"].WhisperInviteRestriction then
		return true -- Allow everyone if restriction is disabled
	end
	return isPlayerInGuild(name) or C_FriendList_IsFriend(name)
end

-- Handle whispers and send invites if keyword matches
local function onChatWhisper(event, message, sender, _, _, _, _, _, _, _, _, _, _, presenceID)
	if QueueStatusButton:IsShown() then
		return
	end -- Ignore if the player is in a queue

	if autoInviteKeyword and message:lower() == autoInviteKeyword:lower() and isPlayerGuildOrFriend(sender) then
		if event == "CHAT_MSG_WHISPER" then
			C_PartyInfo_InviteUnit(sender)
		elseif event == "CHAT_MSG_BN_WHISPER" then
			local accountInfo = C_BattleNet_GetAccountInfoByID(presenceID)
			if accountInfo and CanCooperateWithGameAccount(accountInfo) then
				local gameID = accountInfo.gameAccountInfo.gameAccountID
				if gameID then
					BNInviteFriend(gameID)
				end
			end
		end
	end
end

-- Update the keyword for auto invite
local function onUpdateInviteKeyword()
	autoInviteKeyword = C["Automation"].WhisperInvite
end

-- Initialize the auto whisper invite feature
function Module:CreateAutoWhisperInvite()
	if C["Automation"].WhisperInvite then
		onUpdateInviteKeyword()
		K:RegisterEvent("CHAT_MSG_WHISPER", onChatWhisper)
		K:RegisterEvent("CHAT_MSG_BN_WHISPER", onChatWhisper)
	else
		K:UnregisterEvent("CHAT_MSG_WHISPER", onChatWhisper)
		K:UnregisterEvent("CHAT_MSG_BN_WHISPER", onChatWhisper)
	end
end
