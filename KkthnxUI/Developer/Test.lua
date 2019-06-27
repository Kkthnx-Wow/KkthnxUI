local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("AutoWhisperInvite", "AceEvent-3.0")

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

function Module:CreateWhisperInvite(event, ...)
	local message, sender = ...
	if (not UnitExists("party1") or UnitIsGroupLeader("player") or UnitIsGroupAssistant("player")) and strmatch(strlower(message), "^"..C["Automation"].WhisperInvite) then
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

function Module:OnEnable()
	self:RegisterEvent("CHAT_MSG_WHISPER", "CreateWhisperInvite")
	self:RegisterEvent("CHAT_MSG_BN_WHISPER", "CreateWhisperInvite")
end

function Module:OnDisable()
	self:UnregisterAllEvents()
end