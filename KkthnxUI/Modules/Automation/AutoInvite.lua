local K, C, L, _ = select(2, ...):unpack()
if C.Automation.AutoInvite ~= true then return end

local _G = _G
local format = string.format
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

		if IsInGuild() then
			for i = 1, GetNumGuildMembers() do
				if GetGuildRosterInfo(i) == name then
					return true
				end
			end
		end
	end

	AutoInvite:RegisterEvent("PARTY_INVITE_REQUEST")
	AutoInvite:SetScript("OnEvent", function(self, event, name)
		if MiniMapLFGFrame:IsShown() then return end -- Prevent losing que inside LFD if someone invites you to group
		if GetNumPartyMembers() > 0 or GetNumRaidMembers() > 0 then return end
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
				end
			end
		else
			SendWho(name)
		end
	end)
end

-- Auto invite by whisper(by Tukz)
InviteWhisper:RegisterEvent("CHAT_MSG_WHISPER")
InviteWhisper:SetScript("OnEvent", function(self, event, msg, sender)
	if (not UnitInParty("player") or UnitIsPartyLeader("player") or UnitIsRaidOfficer("player")) and strmatch(strlower(msg), Keyword) and SavedOptionsPerChar.AutoInvite == true and not MiniMapLFGFrame:IsShown() then
		if event == "CHAT_MSG_WHISPER" then
			InviteUnit(sender)
		end
	end
end)

SlashCmdList["AUTOINVITE"] = function(msg)
	if msg == "off" then
		SavedOptionsPerChar.AutoInvite = false
		K.Print("|cffffff00"..L_INVITE_DISABLE..".|r")
	elseif msg == "" then
		SavedOptionsPerChar.AutoInvite = true
		K.Print("|cffffff00"..L_INVITE_ENABLE..C.Misc.InviteKeyword..".|r")
		C.Misc.InviteKeyword = C.Misc.InviteKeyword
	else
		SavedOptionsPerChar.AutoInvite = true
		K.Print("|cffffff00"..L_INVITE_ENABLE..msg..".|r")
		C.Misc.InviteKeyword = msg
	end
end
SLASH_AUTOINVITE1 = "/ainv"