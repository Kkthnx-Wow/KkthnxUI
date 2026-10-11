--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/QoL/BlockInvites.lua
	Purpose:
		Turn away group invites from people who are not on your friends list, your
		Battle.net friends or your guild, and say who was turned away. Requests to
		join your group, which arrive as a confirmation, can be turned away too.

		Both checks go by the sender's GUID, which cannot be faked by a name that
		looks like a friend's. An invite whose sender cannot be read is left for you
		to decide. Nothing is turned away while you have a group finder application
		or listing, since those invites come from strangers on purpose.
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]

if not (K.Client and K.Client.IsRetail) then
	return
end

local Module = K:GetModule("QoL")

local IsSecret = K.IsSecret
local C_FriendList = C_FriendList
local C_BattleNet = C_BattleNet
local IsGuildMember = IsGuildMember
local format = string.format

-- A group finder invite comes from a stranger by design, so while you have an
-- application out or a listing of your own, nothing is turned away.
local function UsingGroupFinder()
	local C_LFGList = C_LFGList
	return C_LFGList.HasActiveEntryInfo() or #C_LFGList.GetApplications() > 0
end

local function KnowsPlayer(guid)
	return C_FriendList.IsFriend(guid) or C_BattleNet.GetAccountInfoByGUID(guid) ~= nil or IsGuildMember(guid)
end

-- Someone invites you.
local function OnInvite(_, _, name, _, _, _, _, _, guid)
	if not guid or IsSecret(guid) or UsingGroupFinder() or KnowsPlayer(guid) then
		return
	end
	DeclineGroup()
	StaticPopup_Hide("PARTY_INVITE")
	K.Print(format(L["Declined a group invite from %s."], IsSecret(name) and UNKNOWN or name or UNKNOWN))
end

-- Someone asks to join you.
local function OnRequest()
	if not C.QoL.BlockRequests then
		return
	end
	-- The pending item is an invite token, not a player. The player's GUID is the
	-- third value Blizzard's own dialog reads from GetInviteConfirmationInfo.
	local invite = GetNextPendingInviteConfirmation()
	if not invite then
		return
	end
	local _, _, guid = GetInviteConfirmationInfo(invite)
	if not guid or IsSecret(guid) or UsingGroupFinder() or KnowsPlayer(guid) then
		return
	end
	RespondToInviteConfirmation(invite, false)
	StaticPopup_Hide("GROUP_INVITE_CONFIRMATION")
	K.Print(L["Declined a request to join your group."])
end

function Module:SetupBlockInvites()
	self:RegisterEvent("PARTY_INVITE_REQUEST", OnInvite)
	self:RegisterEvent("GROUP_INVITE_CONFIRMATION", OnRequest)
end
