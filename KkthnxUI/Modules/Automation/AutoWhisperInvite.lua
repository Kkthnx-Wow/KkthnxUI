local K, C = unpack(select(2, ...))
local Module = K:GetModule("Automation")

local _G = _G
local string_lower = string.lower
local select = select

local BNGetFriendIndex = _G.BNGetFriendIndex
local BNGetFriendInfo = _G.BNGetFriendInfo
local BNInviteFriend = _G.BNInviteFriend
local BNIsFriend = _G.BNIsFriend
local InviteUnit = _G.InviteUnit
local UnitExists = _G.UnitExists
local UnitIsGroupLeader = _G.UnitIsGroupLeader

function Module.WhisperInvite(event, arg1, arg2, ...)
	if (not UnitExists("party1") or UnitIsGroupLeader("player")) and string_lower(arg1) == string_lower(C["Automation"].WhisperInvite) then
		if event == "CHAT_MSG_WHISPER" then
			InviteUnit(arg2)
		elseif event == "CHAT_MSG_BN_WHISPER" then
			local presenceID = select(11, ...)
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