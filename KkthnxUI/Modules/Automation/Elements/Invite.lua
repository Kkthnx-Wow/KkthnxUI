local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Automation")

--Cache global variables
local C_BattleNet = C_BattleNet
local C_FriendList = C_FriendList
local IsGuildMember = IsGuildMember
local IsInGroup = IsInGroup
local QueueStatusButton = QueueStatusButton
local StaticPopupSpecial_Hide = StaticPopupSpecial_Hide
local StaticPopup_Hide = StaticPopup_Hide
local LFGInvitePopup = LFGInvitePopup
local previousInviterGUID

--Main function
function Module.AutoInvite(event, _, _, _, _, _, _, inviterGUID)
	if event == "PARTY_INVITE_REQUEST" then
		--Check if player is already in group or queued for group or already accepted an invite from the same inviter
		if IsInGroup() or QueueStatusButton:IsShown() or inviterGUID == previousInviterGUID then
			return
		end

		-- Check if the inviter is a friend or guild member
		local accountInfo = C_BattleNet.GetAccountInfoByGUID(inviterGUID)
		if accountInfo or C_FriendList.IsFriend(inviterGUID) then
			AcceptGroup()
			previousInviterGUID = inviterGUID
		elseif IsGuildMember(inviterGUID) then
			AcceptGroup()
			previousInviterGUID = inviterGUID
		end
	elseif event == "GROUP_ROSTER_UPDATE" then
		-- Hide invite popups when player joins a group
		StaticPopupSpecial_Hide(LFGInvitePopup)
		StaticPopup_Hide("PARTY_INVITE")
		previousInviterGUID = nil
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
