local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Automation")

local BNGetNumFriends = BNGetNumFriends
local C_BattleNet_GetFriendGameAccountInfo = C_BattleNet.GetFriendGameAccountInfo
local C_BattleNet_GetFriendNumGameAccounts = C_BattleNet.GetFriendNumGameAccounts
local C_FriendList_IsFriend = C_FriendList.IsFriend
local C_QuestSession_GetSessionBeginDetails = C_QuestSession.GetSessionBeginDetails
local hooksecurefunc = hooksecurefunc
local string_split = string.split
local UnitGUID = UnitGUID
local UnitName = UnitName

-- Function to check if a given name is in the player's friends list
local function isFriend(name)
	if not name then
		return
	end

	name = string_split("-", name) -- Remove realm from name

	-- Check if the name exists in the friend list
	if C_FriendList_IsFriend(name) then
		return true
	end

	-- Check if the name exists in the Battle.net friends list
	local numBNetFriends = BNGetNumFriends()
	for i = 1, numBNetFriends do
		local numGameAccounts = C_BattleNet_GetFriendNumGameAccounts(i)
		for j = 1, numGameAccounts do
			local gameAccountInfo = C_BattleNet_GetFriendGameAccountInfo(i, j)
			if gameAccountInfo and gameAccountInfo.clientProgram == "WoW" and gameAccountInfo.characterName == name then
				return true
			end
		end
	end
end

-- Function to auto-accept Party Sync invitations from friends
local function setupAutoPartySyncAccept(self)
	local sessionBeginDetails = C_QuestSession_GetSessionBeginDetails()
	if not sessionBeginDetails then
		return
	end

	for i = 1, 4 do
		local unit = "party" .. i
		if UnitGUID(unit) == sessionBeginDetails.guid then
			local requesterName = UnitName(unit)
			if requesterName and isFriend(requesterName) then
				self.ButtonContainer.Confirm:Click()
				K.Print("Auto accepted a Party Sync from " .. requesterName)
				K.Print("To disable auto-accept, adjust the setting in KkthnxUI Config.")
			end
			return
		end
	end
end

-- Hook to automatically accept Party Sync invitations from friends
function Module:CreateAutoPartySyncAccept()
	if C["Automation"].AutoPartySync then
		hooksecurefunc(QuestSessionManager.StartDialog, "Show", setupAutoPartySyncAccept)
	end
end
