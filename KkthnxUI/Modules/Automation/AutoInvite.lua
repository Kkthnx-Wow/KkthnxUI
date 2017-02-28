local K, C, L = unpack(select(2, ...))
if C.Automation.AutoInvite ~= true then return end

-- WoW Lua
local _G = _G
local string_gsub = string.gsub
local string_lower = string.lower
local string_match = string.match

-- Wow API
local AcceptGroup = _G.AcceptGroup
local BNGetFriendInfo = _G.BNGetFriendInfo
local BNGetNumFriends = _G.BNGetNumFriends
local BNInviteFriend = _G.BNInviteFriend
local BNSendWhisper = _G.BNSendWhisper
local GetBattlefieldEstimatedWaitTime = _G.GetBattlefieldEstimatedWaitTime
local GetFriendInfo = _G.GetFriendInfo
local GetGuildRosterInfo = _G.GetGuildRosterInfo
local GetLFGMode = _G.GetLFGMode
local GetNumFriends = _G.GetNumFriends
local GetNumGuildMembers = _G.GetNumGuildMembers
local GuildRoster = _G.GuildRoster
local InCombatLockdown = _G.InCombatLockdown
local InviteUnit = _G.InviteUnit
local IsInGroup = _G.IsInGroup
local IsInGuild = _G.IsInGuild
local LE_LFG_CATEGORY_FLEXRAID = _G.LE_LFG_CATEGORY_FLEXRAID
local LE_LFG_CATEGORY_LFD = _G.LE_LFG_CATEGORY_LFD
local LE_LFG_CATEGORY_LFR = _G.LE_LFG_CATEGORY_LFR
local LE_LFG_CATEGORY_RF = _G.LE_LFG_CATEGORY_RF
local LE_LFG_CATEGORY_SCENARIO = _G.LE_LFG_CATEGORY_SCENARIO
local LFGInvitePopup = _G.LFGInvitePopup
local SendChatMessage = _G.SendChatMessage
local ShowFriends = _G.ShowFriends
local StaticPopup_Hide = _G.StaticPopup_Hide
local StaticPopupSpecial_Hide = _G.StaticPopupSpecial_Hide
local UnitExists = _G.UnitExists
local UnitIsGroupAssistant = _G.UnitIsGroupAssistant
local UnitIsGroupLeader = _G.UnitIsGroupLeader

-- Global variables that we don"t cache, list them here for mikk"s FindGlobals script
-- GLOBALS:

local LFG_CATEGORY = {
	LE_LFG_CATEGORY_LFD,
	LE_LFG_CATEGORY_LFR,
	LE_LFG_CATEGORY_RF,
	LE_LFG_CATEGORY_SCENARIO,
	LE_LFG_CATEGORY_FLEXRAID,
}

local function GetQueueStatus()
	-- Battlegrounds / PvP
	local WaitTime = GetBattlefieldEstimatedWaitTime(1)
	if WaitTime ~= 0 then
		return true
	end

	-- LFG / LFR
	for _, instance in pairs(LFG_CATEGORY) do
		local Queued = GetLFGMode(instance)
		if Queued ~= nil then
			return true
		end
	end

	return false
end

local AutoAccept = CreateFrame("Frame")
AutoAccept:RegisterEvent("PARTY_INVITE_REQUEST")
AutoAccept:RegisterEvent("GROUP_ROSTER_UPDATE")
AutoAccept:SetScript("OnEvent", function(self, event, ...)
	if event == "PARTY_INVITE_REQUEST" then
		-- InCombatLockdown is to prevent losing a Rare Mob while getting an invite. They have to accept the invite manually.
		if GetQueueStatus() or IsInGroup() or InCombatLockdown() then return end
		local LeaderName = ...

		if IsInGuild() then GuildRoster() end

		for guildIndex = 1, GetNumGuildMembers(true) do
			local guildMemberName = string_gsub(GetGuildRosterInfo(guildIndex), "-.*", "")
			if guildMemberName == LeaderName then
				AcceptGroup()
				self.HideStaticPopup = true
				return
			end
		end

		for bnIndex = 1, BNGetNumFriends() do
			local _, _, _, _, name = BNGetFriendInfo(bnIndex)
			LeaderName = LeaderName:match("(.+)%-.+") or LeaderName
			if name == LeaderName then
				AcceptGroup()
				self.HideStaticPopup = true
				return
			end
		end

		if GetNumFriends() > 0 then ShowFriends() end

		for friendIndex = 1, GetNumFriends() do
			local friendName = string_gsub(GetFriendInfo(friendIndex), "-.*", "")
			if friendName == LeaderName then
				AcceptGroup()
				self.HideStaticPopup = true
				return
			end
		end
	elseif event == "GROUP_ROSTER_UPDATE" and self.HideStaticPopup == true then
		StaticPopupSpecial_Hide(LFGInvitePopup)
		StaticPopup_Hide("PARTY_INVITE")
		StaticPopup_Hide("PARTY_INVITE_XREALM")
		self.HideStaticPopup = false
	end
end)

local AutoInvite = CreateFrame("Frame")
AutoInvite:RegisterEvent("CHAT_MSG_WHISPER")
AutoInvite:RegisterEvent("CHAT_MSG_BN_WHISPER")
AutoInvite:SetScript("OnEvent", function(self, event, ...)
	local message, sender = ...
	if (not UnitExists("party1") or UnitIsGroupLeader("player") or UnitIsGroupAssistant("player")) and string_match(string_lower(message), '^inv') then
		if event == "CHAT_MSG_WHISPER" then
			if GetQueueStatus() then
				SendChatMessage("I'm currently in Queue!", "WHISPER", nil, sender)
			else
				InviteUnit(sender)
			end
		else
			local presenceID = select(13, ...)
			if GetQueueStatus() then
				BNSendWhisper(presenceID, "I'm currently in Queue!")
			else
				BNInviteFriend(presenceID)
			end
		end
	end
end)