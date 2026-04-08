--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Automatically invites players to a group when they whisper a specific keyword.
-- - Design: Monitors chat messages and cross-references senders with friends/guild lists.
-- - Events: CHAT_MSG_WHISPER, CHAT_MSG_BN_WHISPER
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Automation")

-- PERF: Localize globals and WoW API functions to minimize lookup overhead.
local _G = _G
local Ambiguate = Ambiguate
local BNInviteFriend = BNInviteFriend
local C_BattleNet_GetAccountInfoByID = C_BattleNet.GetAccountInfoByID
local C_FriendList_IsFriend = C_FriendList.IsFriend
local C_PartyInfo_InviteUnit = C_PartyInfo.InviteUnit
local CanCooperateWithGameAccount = CanCooperateWithGameAccount
local GetGuildRosterInfo = GetGuildRosterInfo
local GetNumGuildMembers = GetNumGuildMembers
local IsInGuild = IsInGuild

-- ---------------------------------------------------------------------------
-- State
-- ---------------------------------------------------------------------------
local autoInviteKeyword

-- ---------------------------------------------------------------------------
-- Internal Checkers
-- ---------------------------------------------------------------------------
local function isPlayerInGuild(unitName)
	-- REASON: Scans the guild roster to verify if the whispering unit is a guild mate.
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

local function isPlayerGuildOrFriend(name)
	-- REASON: Checks if the user has restricted invites to guild/friends only.
	if not C["Automation"].WhisperInviteRestriction then
		return true
	end
	return isPlayerInGuild(name) or C_FriendList_IsFriend(name)
end

-- ---------------------------------------------------------------------------
-- Chat Handling
-- ---------------------------------------------------------------------------
local function onChatWhisper(event, message, sender, _, _, _, _, _, _, _, _, _, _, presenceID)
	-- REASON: Prevents sending invites if the player is currently in a queue to avoid social awkwardness/bugs.
	local queueStatusButton = _G.QueueStatusButton
	if queueStatusButton and queueStatusButton:IsShown() then
		return
	end

	if autoInviteKeyword and message:lower() == autoInviteKeyword:lower() and isPlayerGuildOrFriend(sender) then
		if event == "CHAT_MSG_WHISPER" then
			C_PartyInfo_InviteUnit(sender)
		elseif event == "CHAT_MSG_BN_WHISPER" then
			-- REASON: Handles BNet-specific invites which require account/game ID lookups.
			local accountInfo = C_BattleNet_GetAccountInfoByID(presenceID)
			if accountInfo and CanCooperateWithGameAccount(accountInfo) then
				local gameAccountInfo = accountInfo.gameAccountInfo
				if gameAccountInfo and gameAccountInfo.gameAccountID then
					BNInviteFriend(gameAccountInfo.gameAccountID)
				end
			end
		end
	end
end

local function onUpdateInviteKeyword()
	autoInviteKeyword = C["Automation"].WhisperInvite
end

-- ---------------------------------------------------------------------------
-- Module Registration
-- ---------------------------------------------------------------------------
function Module:CreateAutoWhisperInvite()
	-- REASON: Feature entry point; registers for whisper events based on user configuration.
	if C["Automation"].WhisperInvite then
		onUpdateInviteKeyword()
		K:RegisterEvent("CHAT_MSG_WHISPER", onChatWhisper)
		K:RegisterEvent("CHAT_MSG_BN_WHISPER", onChatWhisper)
	else
		K:UnregisterEvent("CHAT_MSG_WHISPER", onChatWhisper)
		K:UnregisterEvent("CHAT_MSG_BN_WHISPER", onChatWhisper)
	end
end
