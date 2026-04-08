--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Automatically sends a random "goodbye" message when a dungeon or keystone is completed.
-- - Design: Hooks completion events and sends a message after a random delay (2-5 seconds) to the group channel.
-- - Events: LFG_COMPLETION_REWARD, CHALLENGE_MODE_COMPLETED
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Automation")

-- PERF: Localize globals and Lua functions to minimize lookup overhead.
local C_PartyInfo_IsPartyWalkIn = C_PartyInfo.IsPartyWalkIn
local C_Timer_After = C_Timer.After
local GetInstanceInfo = GetInstanceInfo
local GetTime = GetTime
local IsInGroup = IsInGroup
local IsInRaid = IsInRaid
local IsPartyLFG = IsPartyLFG
local SendChatMessage = SendChatMessage
local math_random = math.random

-- ---------------------------------------------------------------------------
-- Constants & State
-- ---------------------------------------------------------------------------
local autoGoodbyeList = L["AutoGoodbyeMessages"]
local lastGoodbyeAt = 0
local pendingGoodbye = false

-- ---------------------------------------------------------------------------
-- Internal Logic
-- ---------------------------------------------------------------------------
local function getGroupChannel()
	-- REASON: Determines the appropriate chat channel for the current group context.
	local _, instanceType = GetInstanceInfo()
	if not instanceType or instanceType == "none" then
		return nil
	end

	if not IsInGroup() then
		return nil
	end

	-- REASON: Prefer INSTANCE_CHAT for LFD/LFR groups to ensure visibility to all queued members.
	if IsPartyLFG() and not C_PartyInfo_IsPartyWalkIn() then
		return "INSTANCE_CHAT"
	end

	if IsInRaid() then
		return "RAID"
	end

	return "PARTY"
end

local function sendAutoGoodbyeMessage()
	pendingGoodbye = false

	local now = GetTime()
	-- REASON: Throttles messages to prevent excessive output if events fire rapidly.
	if now > 0 and (now - lastGoodbyeAt) < 8 then
		return
	end

	local list = autoGoodbyeList
	if not list or #list == 0 then
		return
	end

	local channel = getGroupChannel()
	if not channel then
		return
	end

	-- REASON: Selects a random message from the locale-provided list for variety.
	local msg = list[math_random(#list)]
	if not msg or msg == "" then
		return
	end

	SendChatMessage(msg, channel)
	lastGoodbyeAt = now
end

local function setupAutoGoodbye()
	if pendingGoodbye then
		return
	end

	pendingGoodbye = true

	-- REASON: Introduces a random delay to make the automated message feel more human and less robotic.
	C_Timer_After(math_random(2, 5), sendAutoGoodbyeMessage)
end

-- ---------------------------------------------------------------------------
-- Module Registration
-- ---------------------------------------------------------------------------
function Module:CreateAutoGoodbye()
	-- REASON: Feature entry point; registers for completion events in dungeons and mythic plus.
	if C["Automation"].AutoGoodbye then
		K:RegisterEvent("LFG_COMPLETION_REWARD", setupAutoGoodbye)
		K:RegisterEvent("CHALLENGE_MODE_COMPLETED", setupAutoGoodbye)
	else
		K:UnregisterEvent("LFG_COMPLETION_REWARD", setupAutoGoodbye)
		K:UnregisterEvent("CHALLENGE_MODE_COMPLETED", setupAutoGoodbye)
	end
end
