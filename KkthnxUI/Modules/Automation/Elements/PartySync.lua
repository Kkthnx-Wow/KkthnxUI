--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Automatically accepts Party Sync invitations from friends and BNet contacts.
-- - Design: Hooks QuestSessionManager.StartDialog:Show to check the requester against the friends list.
-- - Events: Hooked QuestSessionManager.StartDialog:Show
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Automation")

-- PERF: Localize globals and API functions to minimize lookup overhead.
local BNGetNumFriends = BNGetNumFriends
local C_BattleNet_GetFriendGameAccountInfo = C_BattleNet.GetFriendGameAccountInfo
local C_BattleNet_GetFriendNumGameAccounts = C_BattleNet.GetFriendNumGameAccounts
local C_FriendList_IsFriend = C_FriendList.IsFriend
local C_QuestSession_GetSessionBeginDetails = C_QuestSession.GetSessionBeginDetails
local UnitGUID = UnitGUID
local UnitName = UnitName
local hooksecurefunc = hooksecurefunc
local string_split = string.split

-- ---------------------------------------------------------------------------
-- Internal Logic
-- ---------------------------------------------------------------------------
local function isFriend(name)
	-- REASON: Verifies if a character name belongs to a friend on either the WoW or BNet friends lists.
	if not name then
		return
	end

	name = string_split("-", name) -- Remove realm identifier

	if C_FriendList_IsFriend(name) then
		return true
	end

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

local function setupAutoPartySyncAccept(self)
	-- REASON: Automatic acceptance logic invoked when the Party Sync dialog is displayed.
	local sessionBeginDetails = C_QuestSession_GetSessionBeginDetails()
	if not sessionBeginDetails then
		return
	end

	for i = 1, 4 do
		local unit = "party" .. i
		if UnitGUID(unit) == sessionBeginDetails.guid then
			local requesterName = UnitName(unit)
			if requesterName and isFriend(requesterName) then
				if self.ButtonContainer and self.ButtonContainer.Confirm then
					self.ButtonContainer.Confirm:Click()
					K.Print("Auto-accepted a Party Sync from " .. requesterName)
					-- WARNING: Inform the user so they aren't confused by self-clicking UI elements.
					K.Print("To disable auto-accept, adjust the setting in KkthnxUI Config.")
				end
			end
			return
		end
	end
end

-- ---------------------------------------------------------------------------
-- Module Registration
-- ---------------------------------------------------------------------------
function Module:CreateAutoPartySyncAccept()
	-- REASON: Feature entry point; hooks the Blizzard QuestSessionManager dialog.
	if C["Automation"].AutoPartySync then
		local questSessionManager = _G.QuestSessionManager
		if questSessionManager and questSessionManager.StartDialog then
			hooksecurefunc(questSessionManager.StartDialog, "Show", setupAutoPartySyncAccept)
		end
	end
end
