local K, C = unpack(select(2, ...))
local Module = K:GetModule("Automation")

local AcceptGroup = _G.AcceptGroup
local BNGetGameAccountInfoByGUID = _G.BNGetGameAccountInfoByGUID
local IsCharacterFriend = _G.IsCharacterFriend
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

		if BNGetGameAccountInfoByGUID(inviterGUID) or IsCharacterFriend(inviterGUID) or IsGuildMember(inviterGUID) then
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
		K:RegisterEvent("PARTY_INVITE_REQUEST", self.AutoInvite)
		K:RegisterEvent("GROUP_ROSTER_UPDATE", self.AutoInvite)
	else
		K:UnregisterEvent("PARTY_INVITE_REQUEST", self.AutoInvite)
		K:UnregisterEvent("GROUP_ROSTER_UPDATE", self.AutoInvite)
	end
end