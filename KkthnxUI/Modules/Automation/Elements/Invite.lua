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

local previousInviterGUID

local function HandlePartyInvite(inviterGUID)
	if IsInGroup() or QueueStatusButton:IsShown() or inviterGUID == previousInviterGUID then
		return
	end

	local accountInfo = C_BattleNet.GetAccountInfoByGUID(inviterGUID)
	if accountInfo or C_FriendList.IsFriend(inviterGUID) or IsGuildMember(inviterGUID) then
		AcceptGroup()
		previousInviterGUID = inviterGUID
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
