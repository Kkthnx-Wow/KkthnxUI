local K, C = unpack(select(2, ...))
local Module = K:GetModule("Automation")

local _G = _G
local string_lower = string.lower

local BNGetFriendIndex = _G.BNGetFriendIndex
local BNGetFriendInfo = _G.BNGetFriendInfo
local BNInviteFriend = _G.BNInviteFriend
local BNIsFriend = _G.BNIsFriend
local InviteUnit = _G.InviteUnit
local IsInGroup = _G.IsInGroup
local UnitIsGroupAssistant = _G.UnitIsGroupAssistant
local UnitIsGroupLeader = _G.UnitIsGroupLeader

function Module.WhisperInvite(event, ...)
	local msg, author, _, _, _, _, _, _, _, _, _, _, presenceID = ...
	if (not IsInGroup() or UnitIsGroupLeader("player") or UnitIsGroupAssistant("player")) and string_lower(msg) == string_lower(C["Automation"].WhisperInvite) then
		if event == "CHAT_MSG_WHISPER" then
			InviteUnit(author)
		elseif event == "CHAT_MSG_BN_WHISPER" then
			if presenceID and BNIsFriend(presenceID) then
				local index = BNGetFriendIndex(presenceID)
				if index then
					local _, _, _, _, _, toonID = BNGetFriendInfo(index)
					if toonID then
						BNInviteFriend(toonID)
					end
				end
			end
		end
	end
	return
end

function Module:CreateAutoWhisperInvite()
	K:RegisterEvent("CHAT_MSG_WHISPER", self.WhisperInvite)
	K:RegisterEvent("CHAT_MSG_BN_WHISPER", self.WhisperInvite)
end