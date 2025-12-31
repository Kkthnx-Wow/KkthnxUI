-- Cache globals / tables locally for performance
local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Automation")

-- Lua / WoW API locals
local math_random = math.random
local GetInstanceInfo = GetInstanceInfo
local GetTime = GetTime
local IsInGroup = IsInGroup
local IsInRaid = IsInRaid
local IsPartyLFG = IsPartyLFG
local C_PartyInfo_IsPartyWalkIn = C_PartyInfo.IsPartyWalkIn
local C_Timer_After = C_Timer.After
local SendChatMessage = SendChatMessage

-- Pre-resolve locale goodbye list once
local AutoGoodbyeList = L["AutoGoodbyeMessages"]

-- Anti-spam timestamp + "are we already waiting to send?"
local lastGoodbyeAt = 0
local pendingGoodbye = false

-- Choose correct channel at send-time
local function GetGroupChannel()
	local _, instanceType = GetInstanceInfo()
	if not instanceType or instanceType == "none" then
		return nil
	end

	if not IsInGroup() then
		return nil
	end

	-- Prefer instance chat for queued groups (LFD/LFR), otherwise party/raid.
	if IsPartyLFG() and not C_PartyInfo_IsPartyWalkIn() then
		return "INSTANCE_CHAT"
	end

	if IsInRaid() then
		return "RAID"
	end

	return "PARTY"
end

local function SendAutoGoodbyeMessage()
	pendingGoodbye = false

	local now = GetTime()
	if now > 0 and (now - lastGoodbyeAt) < 8 then
		return
	end

	local list = AutoGoodbyeList
	if not list or #list == 0 then
		return
	end

	local channel = GetGroupChannel()
	if not channel then
		return
	end

	local msg = list[math_random(#list)]
	if not msg or msg == "" then
		return
	end

	SendChatMessage(msg, channel)
	lastGoodbyeAt = now
end

local function SetupAutoGoodbye()
	if pendingGoodbye then
		return
	end

	pendingGoodbye = true

	-- Random delay 2-5s
	C_Timer_After(math_random(2, 5), SendAutoGoodbyeMessage)
end

function Module:CreateAutoGoodbye()
	if C["Automation"].AutoGoodbye then
		K:RegisterEvent("LFG_COMPLETION_REWARD", SetupAutoGoodbye)
		K:RegisterEvent("CHALLENGE_MODE_COMPLETED", SetupAutoGoodbye)
	else
		K:UnregisterEvent("LFG_COMPLETION_REWARD", SetupAutoGoodbye)
		K:UnregisterEvent("CHALLENGE_MODE_COMPLETED", SetupAutoGoodbye)
	end
end
