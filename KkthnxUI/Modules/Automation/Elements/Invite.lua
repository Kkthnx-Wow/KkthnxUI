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

local function AutoInvite(event, _, _, _, _, _, _, inviterGUID)
	local previousInviterGUID
	-- Handle incoming party invites
	if event == "PARTY_INVITE_REQUEST" then
		-- Ignore invites if already in a group or queueing for something, or if it's a duplicate invite
		if IsInGroup() or QueueStatusButton:IsShown() or inviterGUID == previousInviterGUID then
			return
		end

		-- Accept the invite if it's from a Battle.net friend, guild member, or someone on the same realm
		local accountInfo = C_BattleNet.GetAccountInfoByGUID(inviterGUID)
		if accountInfo or C_FriendList.IsFriend(inviterGUID) or IsGuildMember(inviterGUID) then
			AcceptGroup()
			previousInviterGUID = inviterGUID
		end
	-- Handle changes to the group roster (e.g. someone leaves or joins)
	elseif event == "GROUP_ROSTER_UPDATE" then
		-- Hide any lingering invite popups
		StaticPopupSpecial_Hide(LFGInvitePopup)
		StaticPopup_Hide("PARTY_INVITE")
		previousInviterGUID = nil
	end
end

function Module:CreateAutoInvite()
	if C["Automation"].AutoInvite then
		-- Register the event handlers if auto-invite is enabled
		K:RegisterEvent("PARTY_INVITE_REQUEST", AutoInvite)
		K:RegisterEvent("GROUP_ROSTER_UPDATE", AutoInvite)
	else
		-- Unregister the event handlers if auto-invite is disabled
		K:UnregisterEvent("PARTY_INVITE_REQUEST", AutoInvite)
		K:UnregisterEvent("GROUP_ROSTER_UPDATE", AutoInvite)
	end
end
