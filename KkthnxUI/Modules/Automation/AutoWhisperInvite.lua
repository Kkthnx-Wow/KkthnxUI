local K, C = unpack(select(2, ...))
local Module = K:GetModule("Automation")

local _G = _G
local pairs = pairs
local string_match = string.match
local string_lower = string.lower
local select = select

local BNInviteFriend = _G.BNInviteFriend
local BNSendWhisper = _G.BNSendWhisper
local GetBattlefieldEstimatedWaitTime = _G.GetBattlefieldEstimatedWaitTime
local GetLFGMode = _G.GetLFGMode
local InviteUnit = _G.InviteUnit
local LE_LFG_CATEGORY_FLEXRAID = _G.LE_LFG_CATEGORY_FLEXRAID
local LE_LFG_CATEGORY_LFD = _G.LE_LFG_CATEGORY_LFD
local LE_LFG_CATEGORY_LFR = _G.LE_LFG_CATEGORY_LFR
local LE_LFG_CATEGORY_RF = _G.LE_LFG_CATEGORY_RF
local LE_LFG_CATEGORY_SCENARIO = _G.LE_LFG_CATEGORY_SCENARIO
local SendChatMessage = _G.SendChatMessage
local UnitExists = _G.UnitExists
local UnitIsGroupAssistant = _G.UnitIsGroupAssistant
local UnitIsGroupLeader = _G.UnitIsGroupLeader

function Module:GetQueueStatus()
	-- Battlegrounds / PvP
	local WaitTime = GetBattlefieldEstimatedWaitTime(1)
	if WaitTime ~= 0 then
		return true
	end

	-- LFG / LFR
	for _, instance in pairs({LE_LFG_CATEGORY_LFD, LE_LFG_CATEGORY_LFR, LE_LFG_CATEGORY_RF, LE_LFG_CATEGORY_SCENARIO, LE_LFG_CATEGORY_FLEXRAID}) do
		local Queued = GetLFGMode(instance)
		if Queued ~= nil then
			return true
		end
	end

	return false
end

function Module.WhisperInvite(event, ...)
	local message, sender = ...
	if (not UnitExists("party1") or UnitIsGroupLeader("player") or UnitIsGroupAssistant("player")) and string_match(string_lower(message), "^"..C["Automation"].WhisperInvite) then
		if event == "CHAT_MSG_WHISPER" then
			if Module:GetQueueStatus() then
				SendChatMessage("I'm currently in Queue!", "WHISPER", nil, sender)
			else
				InviteUnit(sender)
			end
		else
			local presenceID = select(13, ...)
			if Module:GetQueueStatus() then
				BNSendWhisper(presenceID, "I'm currently in Queue!")
			else
				BNInviteFriend(presenceID)
			end
		end
	end
end

function Module:CreateAutoWhisperInvite()
	K:RegisterEvent("CHAT_MSG_WHISPER", self.WhisperInvite)
	K:RegisterEvent("CHAT_MSG_BN_WHISPER", self.WhisperInvite)
end