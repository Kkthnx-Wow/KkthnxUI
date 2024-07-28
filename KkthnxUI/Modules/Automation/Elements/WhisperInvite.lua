local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Automation")

local IsInGuild = IsInGuild
local GetNumGuildMembers = GetNumGuildMembers
local GetGuildRosterInfo = GetGuildRosterInfo
local Ambiguate = Ambiguate
local C_FriendList_IsFriend = C_FriendList.IsFriend

local autoInviteKeyword

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

local function isPlayerGuildOrFriend(name)
	if not C["Automation"].WhisperInviteRestriction then
		return true -- Allow all players if the option is disabled
	end

	if IsInGuild() and isPlayerInGuild(name) then
		return true -- Allow players who are in the guild
	elseif C_FriendList_IsFriend(name) then
		return true -- Allow players who are on the friends list
	end

	return false -- Reject all other players
end

local function onChatWhisper(event, message, sender, _, _, _, _, _, _, _, _, _, _, presenceID)
	if QueueStatusButton and QueueStatusButton:IsShown() then
		return
	end

	if autoInviteKeyword and message:lower() == autoInviteKeyword:lower() and isPlayerGuildOrFriend(sender) then
		if event == "CHAT_MSG_WHISPER" then
			C_PartyInfo.InviteUnit(sender)
		elseif event == "CHAT_MSG_BN_WHISPER" then
			local accountInfo = C_BattleNet.GetAccountInfoByID(presenceID)
			if accountInfo then
				local gameAccountInfo = accountInfo.gameAccountInfo
				local gameID = gameAccountInfo.gameAccountID
				if gameID and CanCooperateWithGameAccount(accountInfo) then
					BNInviteFriend(gameID)
				end
			end
		end
	end
end

local function onUpdateAutoInviteKeyword()
	autoInviteKeyword = C["Automation"].WhisperInvite
end

function Module:CreateAutoWhisperInvite()
	if not C["Automation"].WhisperInvite then
		return
	end

	onUpdateAutoInviteKeyword()
	K:RegisterEvent("CHAT_MSG_WHISPER", onChatWhisper)
	K:RegisterEvent("CHAT_MSG_BN_WHISPER", onChatWhisper)
end
