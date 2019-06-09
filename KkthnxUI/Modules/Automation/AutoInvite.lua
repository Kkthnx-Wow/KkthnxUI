local K, C = unpack(select(2, ...))
local Module = K:NewModule("AutoInvite", "AceEvent-3.0")

local _G = _G

local AcceptGroup = _G.AcceptGroup
local BNGetGameAccountInfoByGUID = _G.BNGetGameAccountInfoByGUID
local IsCharacterFriend = _G.IsCharacterFriend
local IsGuildMember = _G.IsGuildMember
local IsInGroup = _G.IsInGroup
local StaticPopup_Hide = _G.StaticPopup_Hide
local StaticPopupSpecial_Hide = _G.StaticPopupSpecial_Hide

local hideStatic
function Module:AutoInvite(event, _, _, _, _, _, _, inviterGUID)
	if not C["Automation"].AutoInvite then
		return
	end

	if event == "PARTY_INVITE_REQUEST" then
		-- Prevent Losing Que Inside LFD If Someone Invites You To Group
		if _G.QueueStatusMinimapButton:IsShown() or IsInGroup() or (not inviterGUID or inviterGUID == "") then
			return
		end

		if BNGetGameAccountInfoByGUID(inviterGUID) or IsCharacterFriend(inviterGUID) or IsGuildMember(inviterGUID) then
			hideStatic = true
			AcceptGroup()
		end
	elseif event == "GROUP_ROSTER_UPDATE" and hideStatic then
		StaticPopupSpecial_Hide(_G.LFGInvitePopup) -- New LFD Popup When Invited In Custom Created Group
		StaticPopup_Hide("PARTY_INVITE")
		hideStatic = nil
	end
end

function Module:OnEnable()
	self:RegisterEvent("PARTY_INVITE_REQUEST", "AutoInvite")
	self:RegisterEvent("GROUP_ROSTER_UPDATE", "AutoInvite")
end
