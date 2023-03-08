local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Automation")

-- Sourced: Leatrix Plus (Leatrix)
-- Edited: KkthnxUI (Kkthnx)

local string_split = string.split

local BNET_CLIENT_WOW = BNET_CLIENT_WOW
local BNGetNumFriends = BNGetNumFriends
local C_BattleNet_GetFriendGameAccountInfo = C_BattleNet.GetFriendGameAccountInfo
local C_BattleNet_GetFriendNumGameAccounts = C_BattleNet.GetFriendNumGameAccounts
local C_FriendList_GetFriendInfoByIndex = C_FriendList.GetFriendInfoByIndex
local C_FriendList_GetNumFriends = C_FriendList.GetNumFriends
local C_FriendList_ShowFriends = C_FriendList.ShowFriends
local C_QuestSession_GetSessionBeginDetails = C_QuestSession.GetSessionBeginDetails
local GetGuildRosterInfo = GetGuildRosterInfo
local GetNumGuildMembers = GetNumGuildMembers
local QuestSessionManager = QuestSessionManager
local UnitGUID = UnitGUID
local UnitName = UnitName
local hooksecurefunc = hooksecurefunc

-- Cache frequently accessed global functions
local string_split = string.split
local C_QuestSession_GetSessionBeginDetails = C_QuestSession.GetSessionBeginDetails
local C_FriendList_IsFriend = C_FriendList.IsFriend

local partyUnitsList = { "player", "party1", "party2", "party3", "party4" }

-- Check if a name is in your friends list
local function IsFriendCheck(friendName)
	-- Do nothing if name is empty (such as whispering from the Battle.net app)
	if not friendName then
		return
	end

	-- Remove realm
	friendName = string_split("-", friendName, 2)

	-- Check character friends
	if C_FriendList_IsFriend(friendName) then
		return true
	end

	-- Check Battle.net friends
	local numBNet = BNGetNumFriends()
	for i = 1, numBNet do
		local numGameAccounts = C_BattleNet_GetFriendNumGameAccounts(i)
		if numGameAccounts > 0 then
			for j = 1, numGameAccounts do
				local gameAccountInfo = C_BattleNet_GetFriendGameAccountInfo(i, j)
				local charName = gameAccountInfo.characterName
				local client = gameAccountInfo.clientProgram
				if client == BNET_CLIENT_WOW and charName == friendName then
					return true
				end
			end
		end
	end
end

local function SetupAutoPartySyncAccept(self)
	if C_QuestSession_GetSessionBeginDetails() then
		for _, unit in ipairs(partyUnitsList) do
			if UnitGUID(unit) == C_QuestSession_GetSessionBeginDetails().guid then
				local requesterName = UnitName(unit)
				if requesterName and IsFriendCheck(requesterName) then
					self.ButtonContainer.Confirm:Click()
					K.Print("You have auto accepted a Party Sync from " .. requesterName)
					K.Print("If you do not want to auto accept these. You can turn it off in KkthnxUI Config")
				end
				return
			end
		end
	end
end

function Module:CreateAutoPartySyncAccept()
	if not C["Automation"].AutoPartySync then
		return
	end

	hooksecurefunc(QuestSessionManager.StartDialog, "Show", SetupAutoPartySyncAccept)
end
