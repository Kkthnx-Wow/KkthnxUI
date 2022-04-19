local K, C = unpack(KkthnxUI)
local Module = K:GetModule("Automation")

-- Sourced: Leatrix Plus (Leatrix)
-- Edited: KkthnxUI (Kkthnx)

local _G = _G
local string_split = _G.string.split

local BNET_CLIENT_WOW = _G.BNET_CLIENT_WOW
local BNGetNumFriends = _G.BNGetNumFriends
local C_BattleNet_GetFriendGameAccountInfo = _G.C_BattleNet.GetFriendGameAccountInfo
local C_BattleNet_GetFriendNumGameAccounts = _G.C_BattleNet.GetFriendNumGameAccounts
local C_FriendList_GetFriendInfoByIndex = _G.C_FriendList.GetFriendInfoByIndex
local C_FriendList_GetNumFriends = _G.C_FriendList.GetNumFriends
local C_FriendList_ShowFriends = _G.C_FriendList.ShowFriends
local C_QuestSession_GetSessionBeginDetails = _G.C_QuestSession.GetSessionBeginDetails
local GetGuildRosterInfo = _G.GetGuildRosterInfo
local GetNumGuildMembers = _G.GetNumGuildMembers
local UnitGUID = _G.UnitGUID
local UnitName = _G.UnitName
local hooksecurefunc = _G.hooksecurefunc

local partyUnitsList = { "player", "party1", "party2", "party3", "party4" }

-- Check if a name is in your friends list or guild (does not check realm as realm is unknown for some checks)
local function IsFriendCheck(friendName)
	-- Do nothing if name is empty (such as whispering from the Battle.net app)
	if not friendName then
		return
	end

	-- Update friends list
	C_FriendList_ShowFriends()

	-- Remove realm
	friendName = string_split("-", friendName, 2)

	-- Check character friends
	for i = 1, C_FriendList_GetNumFriends() do
		-- Return true if name matches with or without realm
		local charFriendName = C_FriendList_GetFriendInfoByIndex(i).name
		charFriendName = string_split("-", charFriendName, 2)
		if friendName == charFriendName then
			return true
		end
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

	-- Check guild roster (new members may need to press J to refresh roster)
	local total = GetNumGuildMembers()
	for i = 1, total do
		local name, _, _, _, _, _, _, _, connected, _, _, _, _, mobile = GetGuildRosterInfo(i)
		if connected and not mobile then
			name = string_split("-", name, 2)
			if name == friendName then
				return true
			end
		end
	end
end

local function SetupAutoPartySyncAccept(self)
	local details = C_QuestSession_GetSessionBeginDetails()
	if details then
		for _, unit in ipairs(partyUnitsList) do
			if UnitGUID(unit) == details.guid then
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
