--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Automatically accepts group invites from friends, guild members, and BNet contacts.
-- - Design: Hooks PARTY_INVITE_REQUEST and automatically calls AcceptGroup for trusted sources.
-- - Events: PARTY_INVITE_REQUEST, GROUP_ROSTER_UPDATE
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Automation")

-- PERF: Localize globals and API functions to minimize lookup overhead.
local AcceptGroup = AcceptGroup
local C_BattleNet_GetAccountInfoByGUID = C_BattleNet.GetAccountInfoByGUID
local C_FriendList_IsFriend = C_FriendList.IsFriend
local IsGuildMember = IsGuildMember
local IsInGroup = IsInGroup
local LFGInvitePopup = LFGInvitePopup
local QueueStatusButton = QueueStatusButton
local StaticPopupSpecial_Hide = StaticPopupSpecial_Hide
local StaticPopup_Hide = StaticPopup_Hide

-- ---------------------------------------------------------------------------
-- State
-- ---------------------------------------------------------------------------
local previousInviterGUID

-- ---------------------------------------------------------------------------
-- Internal Logic
-- ---------------------------------------------------------------------------
local function handlePartyInvite(inviterGUID)
	-- REASON: Filters invites to only auto-accept from trusted sources (friends, guild, BNet).
	if IsInGroup() or QueueStatusButton:IsShown() or inviterGUID == previousInviterGUID then
		return
	end

	local accountInfo = C_BattleNet_GetAccountInfoByGUID(inviterGUID)
	if accountInfo or C_FriendList_IsFriend(inviterGUID) or IsGuildMember(inviterGUID) then
		AcceptGroup()
		previousInviterGUID = inviterGUID
	end
end

local function autoInvite(event, _, _, _, _, _, _, inviterGUID)
	if event == "PARTY_INVITE_REQUEST" then
		handlePartyInvite(inviterGUID)
	elseif event == "GROUP_ROSTER_UPDATE" then
		-- REASON: Clean up UI artifacts and reset state once the group roster updates.
		StaticPopupSpecial_Hide(LFGInvitePopup)
		StaticPopup_Hide("PARTY_INVITE")
		previousInviterGUID = nil
	end
end

-- ---------------------------------------------------------------------------
-- Module Registration
-- ---------------------------------------------------------------------------
function Module:CreateAutoInvite()
	-- REASON: Registers group invite events based on user configuration.
	if C["Automation"].AutoInvite then
		K:RegisterEvent("PARTY_INVITE_REQUEST", autoInvite)
		K:RegisterEvent("GROUP_ROSTER_UPDATE", autoInvite)
	else
		K:UnregisterEvent("PARTY_INVITE_REQUEST", autoInvite)
		K:UnregisterEvent("GROUP_ROSTER_UPDATE", autoInvite)
	end
end
