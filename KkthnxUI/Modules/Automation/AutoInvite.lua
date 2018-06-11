local K, C = unpack(select(2, ...))
local Module = K:NewModule("AutoInvite", "AceEvent-3.0")

-- Wow Lua
local _G = _G
local string_format = string.format
local string_gsub = string.gsub

-- Wow API
local AcceptGroup = _G.AcceptGroup
local BNET_CLIENT_WOW = _G.BNET_CLIENT_WOW
local BNGetFriendGameAccountInfo = _G.BNGetFriendGameAccountInfo
local BNGetFriendInfo = _G.BNGetFriendInfo
local BNGetNumFriendGameAccounts = _G.BNGetNumFriendGameAccounts
local BNGetNumFriends = _G.BNGetNumFriends
local GetFriendInfo = _G.GetFriendInfo
local GetGuildRosterInfo = _G.GetGuildRosterInfo
local GetNumGuildMembers = _G.GetNumGuildMembers
local GuildRoster = _G.GuildRoster
local IsInGroup = _G.IsInGroup
local IsInGuild = _G.IsInGuild
local ShowFriends = _G.ShowFriends
local StaticPopup_Hide = _G.StaticPopup_Hide
local StaticPopupSpecial_Hide = _G.StaticPopupSpecial_Hide
local GetNumFriends = _G.GetNumFriends

local hideStatic = false
local PLAYER_REALM = string_gsub(K.Realm, "[%s%-]", "")
function Module:AutoInvite(event, leaderName)
	if C["Automation"].AutoInvite ~= true then return end

	if event == "PARTY_INVITE_REQUEST" then
		if QueueStatusMinimapButton:IsShown() then
			return
		end

		if IsInGroup() then
			return
		end

		hideStatic = true

		if GetNumFriends() > 0 then
			ShowFriends()
		end

		if IsInGuild() then
			GuildRoster()
		end

		local friendName, guildMemberName, memberName, numGameAccounts, isOnline, accountName, bnToonName, bnClient, bnRealm, bnAcceptedInvite, _
		local inGroup = false

		for friendIndex = 1, GetNumFriends() do
			friendName = GetFriendInfo(friendIndex)
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
				_, accountName, _, _, _, _, _, isOnline = BNGetFriendInfo(bnIndex)
				if isOnline then
					if accountName and (accountName == leaderName) then
						AcceptGroup()
						bnAcceptedInvite = true
					end
					if not bnAcceptedInvite then
						numGameAccounts = BNGetNumFriendGameAccounts(bnIndex)
						if numGameAccounts > 0 then
							for toonIndex = 1, numGameAccounts do
								_, bnToonName, bnClient, bnRealm = BNGetFriendGameAccountInfo(bnIndex, toonIndex)
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
						end
					end
					if bnAcceptedInvite then
						break
					end
				end
			end
		end
	elseif event == "GROUP_ROSTER_UPDATE" and hideStatic == true then
		StaticPopupSpecial_Hide(LFGInvitePopup)
		StaticPopup_Hide("PARTY_INVITE")
		hideStatic = false
	end
end

function Module:OnEnable()
	self:RegisterEvent("PARTY_INVITE_REQUEST", "AutoInvite")
	self:RegisterEvent("GROUP_ROSTER_UPDATE", "AutoInvite")
end