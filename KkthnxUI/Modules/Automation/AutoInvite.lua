local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("AutoInvite", "AceEvent-3.0", "AceTimer-3.0")

-- Wow Lua
local _G = _G
local string_gsub = string.gsub
local string_format = string.format

-- Wow API
local AcceptGroup = _G.AcceptGroup
local BNET_CLIENT_WOW = _G.BNET_CLIENT_WOW
local BNGetFriendGameAccountInfo = _G.BNGetFriendGameAccountInfo
local BNGetFriendInfo = _G.BNGetFriendInfo
local BNGetFriendInfoByID = _G.BNGetFriendInfoByID
local BNGetNumFriendGameAccounts = _G.BNGetNumFriendGameAccounts
local BNGetNumFriends = _G.BNGetNumFriends
local BNInviteFriend = _G.BNInviteFriend
local GetFriendInfo = _G.GetFriendInfo
local GetGuildRosterInfo = _G.GetGuildRosterInfo
local GetNumFriends = _G.GetNumFriends
local GetNumFriends = _G.GetNumFriends
local GetNumGuildMembers = _G.GetNumGuildMembers
local GetRealmName = _G.GetRealmName
local GuildRoster = _G.GuildRoster
local InviteUnit = _G.InviteUnit
local IsInGroup = _G.IsInGroup
local IsInGuild = _G.IsInGuild
local ShowFriends = _G.ShowFriends
local SLASH_AUTOWHISPERINVITE1 = _G.SLASH_AUTOWHISPERINVITE1
local StaticPopup_Hide = _G.StaticPopup_Hide
local StaticPopupSpecial_Hide = _G.StaticPopupSpecial_Hide
local UnitExists = _G.UnitExists
local UnitIsGroupAssistant = _G.UnitIsGroupAssistant
local UnitIsGroupLeader = _G.UnitIsGroupLeader
local UnitName = _G.UnitName

-- GLOBALS: QueueStatusMinimapButton, LFGInvitePopup, KkthnxUIDataPerChar, KkthnxUIData

local hideStatic = false
local PLAYER_REALM = string_gsub(K.Realm, "[%s%-]", "")
function Module:AutoInvite(event, leaderName)
	if C["Automation"].AutoInvite ~= true then return end

	if event == "PARTY_INVITE_REQUEST" then
		if QueueStatusMinimapButton:IsShown() then return end -- Prevent losing que inside LFD if someone invites you to group
		if IsInGroup() then return end
		hideStatic = true

		-- Update Guild and Friendlist
		if GetNumFriends() > 0 then ShowFriends() end
		if IsInGuild() then GuildRoster() end

		local friendName, guildMemberName, memberName, numGameAccounts, isOnline, bnToonName, bnClient, bnRealm, bnAcceptedInvite, _
		local inGroup = false

		for friendIndex = 1, GetNumFriends() do
			friendName = GetFriendInfo(friendIndex) -- this is already stripped of your own realm
			if friendName and (friendName == leaderName) then
				AcceptGroup()
				inGroup = true
				break
			end
		end

		if not inGroup then
			for guildIndex = 1, GetNumGuildMembers(true) do
				guildMemberName = GetGuildRosterInfo(guildIndex)
				memberName = guildMemberName and string_gsub(guildMemberName, "%-"..PLAYER_REALM, "")
				if memberName and (memberName == leaderName) then
					AcceptGroup()
					inGroup = true
					break
				end
			end
		end

		if not inGroup then
			for bnIndex = 1, BNGetNumFriends() do
				bnAcceptedInvite = false
				_, _, _, _, _, _, _, isOnline = BNGetFriendInfo(bnIndex)
				if isOnline then
					numGameAccounts = BNGetNumFriendGameAccounts(bnIndex)
					if numGameAccounts > 0 then
						for toonIndex = 1, numGameAccounts do
							_, bnToonName, bnClient, bnRealm = BNGetFriendGameAccountInfo(bnIndex, toonIndex);
							if bnClient == BNET_CLIENT_WOW then
								if bnRealm and bnRealm ~= "" and bnRealm ~= PLAYER_REALM then
									bnToonName = string_format("%s-%s", bnToonName, bnRealm)
								end
								if bnToonName and (bnToonName == leaderName) then
									AcceptGroup()
									bnAcceptedInvite = true
									break
								end
							end
						end
						if bnAcceptedInvite then
							break
						end
					end
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

function Module:AutoWhisperInvite(event, arg1, arg2, ...)
	if ((not UnitExists("party1") or UnitIsGroupLeader("player") or UnitIsGroupAssistant("player")) and arg1:lower():match(C["Automation"].InviteKeyword)) and KkthnxUIData[K.Realm][K.Name].AutoInvite == true and not QueueStatusMinimapButton:IsShown() then
		if event == "CHAT_MSG_WHISPER" then
			InviteUnit(arg2)
		elseif event == "CHAT_MSG_BN_WHISPER" then
			local bnetIDAccount = select(11, ...)
			local bnetIDGameAccount = select(6, BNGetFriendInfoByID(bnetIDAccount))
			BNInviteFriend(bnetIDGameAccount)
		end
	end
end

function Module:OnEnable()
	self:RegisterEvent("PARTY_INVITE_REQUEST", "AutoInvite")
	self:RegisterEvent("GROUP_ROSTER_UPDATE", "AutoInvite")
	self:RegisterEvent("CHAT_MSG_WHISPER", "AutoWhisperInvite")
	self:RegisterEvent("CHAT_MSG_BN_WHISPER", "AutoWhisperInvite")
end

SlashCmdList.AUTOINVITE = function(msg)
	if msg == "off" then
		KkthnxUIData[K.Realm][K.Name].AutoInvite = false
		K.Print("|cffffff00".."Autoinvite OFF"..".|r")
	elseif msg == "" then
		KkthnxUIData[K.Realm][K.Name].AutoInvite = true
		K.Print("|cffffff00".."Autoinvite ON: "..C["Automation"].InviteKeyword..".|r")
		C["Automation"].InviteKeyword = C["Automation"].InviteKeyword
	else
		KkthnxUIData[K.Realm][K.Name].AutoInvite = true
		K.Print("|cffffff00".."Autoinvite ON: "..msg..".|r")
		C["Automation"].InviteKeyword = msg
	end
end
SLASH_AUTOINVITE1 = "/ainv"