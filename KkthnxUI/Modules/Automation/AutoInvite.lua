local K, C, L = select(2, ...):unpack()
if C.Automation.AutoInvite ~= true then return end

local _G = _G
local format = string.format
local select = select
local strmatch = strmatch
local strlower = strlower
local CreateFrame = CreateFrame
local GetNumPartyMembers = GetNumPartyMembers
local GetNumFriends = GetNumFriends
local GetFriendInfo = GetFriendInfo
local GetNumGuildMembers = GetNumGuildMembers
local GetGuildRosterInfo = GetGuildRosterInfo
local UnitIsRaidOfficer = UnitIsRaidOfficer
local UnitIsPartyLeader = UnitIsPartyLeader
local Keyword = C.Misc.InviteKeyword
local AutoInvite = CreateFrame("Frame")
local InviteWhisper = CreateFrame("Frame")

-- Accept invites from guild members or friend list(by ALZA)
if C.Automation.AutoInvite == true then
	local CheckFriend = function(name)
		for i = 1, GetNumFriends() do
			if GetFriendInfo(i) == name then
				return true
			end
		end
		for i = 1, select(2, BNGetNumFriends()) do
			local presenceID, _, _, _, _, toonID, client, isOnline = BNGetFriendInfo(i)
			if client == BNET_CLIENT_WOW and isOnline then
				local _, toonName, _, realmName = BNGetGameAccountInfo(toonID or presenceID)
				if name == toonName or name == toonName.."-"..realmName then
					return true
				end
			end
		end
		if IsInGuild() then
			for i = 1, GetNumGuildMembers() do
				if Ambiguate(GetGuildRosterInfo(i), "none") == name then
					return true
				end
			end
		end
	end

	AutoInvite:RegisterEvent("PARTY_INVITE_REQUEST")
	AutoInvite:SetScript("OnEvent", function(self, event, name)
		if QueueStatusMinimapButton:IsShown() or GetNumGroupMembers() > 0 then return end
		if CheckFriend(name) then
			RaidNotice_AddMessage(RaidWarningFrame, L_INFO_INVITE..name, {r = 0.41, g = 0.8, b = 0.94}, 3)
			K.Print(format("|cffffff00"..L_INFO_INVITE..name..".|r"))
			AcceptGroup()
			for i = 1, STATICPOPUP_NUMDIALOGS do
				local frame = _G["StaticPopup"..i]
				if frame:IsVisible() and frame.which == "PARTY_INVITE" then
					frame.inviteAccepted = 1
					StaticPopup_Hide("PARTY_INVITE")
					return
				elseif frame:IsVisible() and frame.which == "PARTY_INVITE_XREALM" then
					frame.inviteAccepted = 1
					StaticPopup_Hide("PARTY_INVITE_XREALM")
					return
				end
			end
		else
			SendWho(name)
		end
	end)
end

-- Auto invite by whisper(by Tukz)
InviteWhisper:RegisterEvent("CHAT_MSG_WHISPER")
InviteWhisper:RegisterEvent("CHAT_MSG_BN_WHISPER")
InviteWhisper:SetScript("OnEvent", function(self, event, arg1, arg2, ...)
	if ((not UnitExists("party1") or UnitIsGroupLeader("player") or UnitIsGroupAssistant("player")) and arg1:lower():match(Keyword)) and KkthnxUIDataPerChar.AutoInvite == true and not QueueStatusMinimapButton:IsShown() then
		if event == "CHAT_MSG_WHISPER" then
			InviteUnit(arg2)
		elseif event == "CHAT_MSG_BN_WHISPER" then
			local bnetIDAccount = select(11, ...)
			local bnetIDGameAccount = select(6, BNGetFriendInfoByID(bnetIDAccount))
			BNInviteFriend(bnetIDGameAccount)
		end
	end
end)

SlashCmdList["AUTOINVITE"] = function(msg)
	if msg == "off" then
		KkthnxUIDataPerChar.AutoInvite = false
		K.Print("|cffffff00"..L_INVITE_DISABLE..".|r")
	elseif msg == "" then
		KkthnxUIDataPerChar.AutoInvite = true
		K.Print("|cffffff00"..L_INVITE_ENABLE..Keyword..".|r")
		Keyword = Keyword
	else
		KkthnxUIDataPerChar.AutoInvite = true
		K.Print("|cffffff00"..L_INVITE_ENABLE..msg..".|r")
		Keyword = msg
	end
end
SLASH_AUTOINVITE1 = "/ainv"
