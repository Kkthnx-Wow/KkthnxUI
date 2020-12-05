local K, C = unpack(select(2, ...))
local Module = K:GetModule("Automation")

local _G = _G

local AcceptGroup = _G.AcceptGroup
local C_BattleNet_GetGameAccountInfoByGUID = _G.C_BattleNet.GetGameAccountInfoByGUID
local C_FriendList_IsFriend = _G.C_FriendList.IsFriend
local IsGuildMember = _G.IsGuildMember
local IsInGroup = _G.IsInGroup
local LFGInvitePopup = _G.LFGInvitePopup
local QueueStatusMinimapButton = _G.QueueStatusMinimapButton
local StaticPopupSpecial_Hide = _G.StaticPopupSpecial_Hide
local StaticPopup_Hide = _G.StaticPopup_Hide

local hideStatic
function Module.AutoInvite(event, _, _, _, _, _, _, inviterGUID)
	if event == "PARTY_INVITE_REQUEST" then
		-- Prevent Losing Que Inside LFD If Someone Invites You To Group
		if QueueStatusMinimapButton:IsShown() or IsInGroup() or (not inviterGUID or inviterGUID == "") then
			return
		end

		if C_BattleNet_GetGameAccountInfoByGUID(inviterGUID) or C_FriendList_IsFriend(inviterGUID) or IsGuildMember(inviterGUID) then
			hideStatic = true
			AcceptGroup()
		end
	elseif event == "GROUP_ROSTER_UPDATE" and hideStatic then
		StaticPopupSpecial_Hide(LFGInvitePopup) -- New LFD Popup When Invited In Custom Created Group
		StaticPopup_Hide("PARTY_INVITE")
		hideStatic = nil
	end
end

function Module:CreateAutoInvite()
	if C["Automation"].AutoInvite then
		K:RegisterEvent("PARTY_INVITE_REQUEST", Module.AutoInvite)
		K:RegisterEvent("GROUP_ROSTER_UPDATE", Module.AutoInvite)
	else
		K:UnregisterEvent("PARTY_INVITE_REQUEST", Module.AutoInvite)
		K:UnregisterEvent("GROUP_ROSTER_UPDATE", Module.AutoInvite)
	end
end