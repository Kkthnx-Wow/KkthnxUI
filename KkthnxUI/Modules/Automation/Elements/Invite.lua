local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Automation")

local C_BattleNet = C_BattleNet
local C_FriendList = C_FriendList
local IsGuildMember = IsGuildMember
local IsInGroup = IsInGroup
local QueueStatusButton = QueueStatusButton
local StaticPopupSpecial_Hide = StaticPopupSpecial_Hide
local StaticPopup_Hide = StaticPopup_Hide
local LFGInvitePopup = LFGInvitePopup
local debugprofilestop = debugprofilestop
local string_format = string.format

local previousInviterGUID

-- Lightweight profiling
local InviteProfile = { enabled = false, runs = 0, totalMs = 0 }

function Module:AutoInviteProfileSetEnabled(enabled)
	InviteProfile.enabled = not not enabled
	InviteProfile.runs = 0
	InviteProfile.totalMs = 0
end

function Module:AutoInviteProfileDump()
	if InviteProfile.enabled then
		K.Print(string_format("[AutoInvite] runs=%d time=%.2fms", InviteProfile.runs, InviteProfile.totalMs))
	else
		K.Print("[AutoInvite] profiling disabled")
	end
end

local function HandlePartyInvite(inviterGUID)
	if IsInGroup() or QueueStatusButton:IsShown() or inviterGUID == previousInviterGUID then
		return
	end

	local t0
	if InviteProfile.enabled then
		t0 = debugprofilestop()
	end

	local accountInfo = C_BattleNet.GetAccountInfoByGUID(inviterGUID)
	if accountInfo or C_FriendList.IsFriend(inviterGUID) or IsGuildMember(inviterGUID) then
		AcceptGroup()
		previousInviterGUID = inviterGUID
	end

	if InviteProfile.enabled and t0 then
		InviteProfile.runs = InviteProfile.runs + 1
		InviteProfile.totalMs = InviteProfile.totalMs + (debugprofilestop() - t0)
	end
end

local function AutoInvite(event, _, _, _, _, _, _, inviterGUID)
	if event == "PARTY_INVITE_REQUEST" then
		HandlePartyInvite(inviterGUID)
	elseif event == "GROUP_ROSTER_UPDATE" then
		StaticPopupSpecial_Hide(LFGInvitePopup)
		StaticPopup_Hide("PARTY_INVITE")
		previousInviterGUID = nil
	end
end

function Module:CreateAutoInvite()
	if C["Automation"].AutoInvite then
		K:RegisterEvent("PARTY_INVITE_REQUEST", AutoInvite)
		K:RegisterEvent("GROUP_ROSTER_UPDATE", AutoInvite)
	else
		K:UnregisterEvent("PARTY_INVITE_REQUEST", AutoInvite)
		K:UnregisterEvent("GROUP_ROSTER_UPDATE", AutoInvite)
	end
end
