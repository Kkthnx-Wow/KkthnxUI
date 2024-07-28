local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Automation")

-- Sourced: Leatrix Plus (Leatrix)
-- Edited: KkthnxUI (Kkthnx)

-- Import necessary functions and modules
local BNGetNumFriends = BNGetNumFriends
local C_BattleNet_GetFriendGameAccountInfo = C_BattleNet.GetFriendGameAccountInfo
local C_BattleNet_GetFriendNumGameAccounts = C_BattleNet.GetFriendNumGameAccounts
local C_FriendList_IsFriend = C_FriendList.IsFriend
local C_QuestSession_GetSessionBeginDetails = C_QuestSession.GetSessionBeginDetails
local hooksecurefunc = hooksecurefunc
local string_split = string.split
local UnitGUID = UnitGUID
local UnitName = UnitName

-- Check if a given name is in your friends list
local function isFriend(name)
	-- Do nothing if name is empty (such as whispering from the Battle.net app)
	if not name then
		return
	end

	-- Remove realm
	name = string_split("-", name, 2)

	-- Check character friends
	if C_FriendList_IsFriend(name) then
		return true
	end

	-- Check Battle.net friends
	local numBNetFriends = BNGetNumFriends()
	for i = 1, numBNetFriends do
		local numGameAccounts = C_BattleNet_GetFriendNumGameAccounts(i)
		if numGameAccounts > 0 then
			for j = 1, numGameAccounts do
				local gameAccountInfo = C_BattleNet_GetFriendGameAccountInfo(i, j)
				local charName = gameAccountInfo.characterName
				local client = gameAccountInfo.clientProgram
				if client == "WoW" and charName == name then
					return true
				end
			end
		end
	end
end

-- Accept a Party Sync invitation if it's from a friend and auto-accept is enabled
local function setupAutoPartySyncAccept(self)
	local sessionBeginDetails = C_QuestSession_GetSessionBeginDetails()
	if sessionBeginDetails then
		for _, unit in ("player|party[1-4]"):gmatch("[^|]+") do
			print("setupAutoPartySyncAccept", unit)
			if UnitGUID(unit) == sessionBeginDetails.guid then
				local requesterName = UnitName(unit)
				if requesterName and isFriend(requesterName) then
					self.ButtonContainer.Confirm:Click()
					K.Print("You have auto accepted a Party Sync from " .. requesterName)
					K.Print("If you do not want to auto accept these, you can turn it off in KkthnxUI Config")
				end
				return
			end
		end
	end
end

-- Create a hook to automatically accept Party Sync invitations
function Module:CreateAutoPartySyncAccept()
	if not C["Automation"].AutoPartySync then
		return
	end

	hooksecurefunc(QuestSessionManager.StartDialog, "Show", setupAutoPartySyncAccept)
end
