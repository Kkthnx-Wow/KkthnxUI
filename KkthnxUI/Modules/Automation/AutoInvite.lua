local K, C, L = unpack(select(2, ...))
if C.Automation.AutoInvite ~= true then return end

-- WoW Lua
local _G = _G
local string_gsub = string.gsub

-- Wow API
local AcceptGroup = _G.AcceptGroup
local BNGetFriendInfo = _G.BNGetFriendInfo
local BNGetNumFriends = _G.BNGetNumFriends
local GetFriendInfo = _G.GetFriendInfo
local GetGuildRosterInfo = _G.GetGuildRosterInfo
local GetNumFriends = _G.GetNumFriends
local GetNumGuildMembers = _G.GetNumGuildMembers
local GuildRoster = _G.GuildRoster
local IsInGroup = _G.IsInGroup
local IsInGuild = _G.IsInGuild
local ShowFriends = _G.ShowFriends
local StaticPopup_Hide = _G.StaticPopup_Hide
local StaticPopupSpecial_Hide = _G.StaticPopupSpecial_Hide

-- Global variables that we don"t cache, list them here for mikk"s FindGlobals script
-- GLOBALS: leaderName, QueueStatusMinimapButton, LFGInvitePopup

-- Accept invites from guild members or friend list
local hideStatic = false

local function AutoInvite(event, leaderName)
	if event == "PARTY_INVITE_REQUEST" then
		if QueueStatusMinimapButton:IsShown() then return end -- Prevent losing que inside LFD if someone invites you to group
		if IsInGroup() then return end
		hideStatic = true

		-- Update Guild and Friendlist
		if GetNumFriends() > 0 then ShowFriends() end
		if IsInGuild() then GuildRoster() end
		local inGroup = false

		for friendIndex = 1, GetNumFriends() do
			local friendName = string_gsub(GetFriendInfo(friendIndex), "-.*", "")
			if friendName == leaderName then
				AcceptGroup()
				inGroup = true
				break
			end
		end

		if not inGroup then
			for guildIndex = 1, GetNumGuildMembers(true) do
				local guildMemberName = string_gsub(GetGuildRosterInfo(guildIndex), "-.*", "")
				if guildMemberName == leaderName then
					AcceptGroup()
					inGroup = true
					break
				end
			end
		end

		if not inGroup then
			for bnIndex = 1, BNGetNumFriends() do
				local _, _, _, _, name = BNGetFriendInfo(bnIndex)
				leaderName = leaderName:match("(.+)%-.+") or leaderName
				if name == leaderName then
					AcceptGroup()
					break
				end
			end
		end
	elseif event == "GROUP_ROSTER_UPDATE" and hideStatic == true then
		StaticPopupSpecial_Hide(LFGInvitePopup) -- New LFD popup when invited in custon created group
		StaticPopup_Hide("PARTY_INVITE")
		StaticPopup_Hide("PARTY_INVITE_XREALM") -- Not sure bout this but whatever, still an invite
		hideStatic = false
	end
end

local Loading = CreateFrame("Frame")
Loading:RegisterEvent("PLAYER_LOGIN")
Loading:RegisterEvent("PARTY_INVITE_REQUEST")
Loading:RegisterEvent("GROUP_ROSTER_UPDATE")
Loading:SetScript("OnEvent", function(self, event)
	AutoInvite(event, leaderName)
end)