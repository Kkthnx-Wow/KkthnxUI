--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/Misc/PullCountdown.lua
	Purpose:
		A group pull timer driven from chat: /pull [seconds] (alias /pc) counts
		down in party, raid, or instance chat so everyone engages together. A
		second /pull while one is running aborts it.

		Chat only, no combat APIs, so nothing here can taint a secure path. It needs
		a group and an out-of-combat player. The target name is optional and guarded
		against Midnight secret values inside instanced content.
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]

local Module = K:NewModule("PullCountdown")

local tonumber = tonumber
local tostring = tostring
local format = string.format
local floor = math.floor

local IsSecret = K.IsSecret
local IsInGroup = IsInGroup
local IsInRaid = IsInRaid
local IsPartyLFG = IsPartyLFG
local UnitAffectingCombat = UnitAffectingCombat
local UnitName = UnitName
local C_ChatInfo = C_ChatInfo
local C_Timer = C_Timer

local ticker
local remaining

-- Route to whichever group channel is live, or nil when solo.
local function GroupChannel()
	if IsPartyLFG and IsPartyLFG() then
		return "INSTANCE_CHAT"
	elseif IsInRaid() then
		return "RAID"
	elseif IsInGroup() then
		return "PARTY"
	end
end

local function SendGroup(msg)
	local channel = GroupChannel()
	if channel then
		C_ChatInfo.SendChatMessage(msg, channel)
	end
end

local function ResetTicker()
	if ticker then
		ticker:Cancel()
		ticker = nil
	end
	remaining = nil
end

-- The target's name for the pull call, blank when there is no target or the name
-- reads secret (another unit inside an instance).
local function SafeTargetName()
	local name = UnitName("target")
	if not name or IsSecret(name) then
		return ""
	end
	return name
end

function Module:Start(input)
	if not C.PullCountdown.Enable then
		return
	end
	if not IsInGroup() then
		K.Print(L["You must be in a group to start a pull countdown."])
		return
	end
	if UnitAffectingCombat("player") then
		K.Print(L["You can't start a pull countdown in combat."])
		return
	end

	-- Toggle: a second /pull aborts the running timer.
	if ticker then
		ResetTicker()
		SendGroup(L["Pull ABORTED!"])
		return
	end

	local delay = tonumber(input)
	if not delay or delay < 1 then
		delay = C.PullCountdown.Seconds or 10
	end
	-- Cap so a typo cannot spam chat for minutes.
	if delay > 60 then
		delay = 60
	end
	delay = floor(delay)

	remaining = delay
	local target = SafeTargetName()
	if target ~= "" then
		SendGroup(format(L["Pulling %s in %d.."], target, delay))
	else
		SendGroup(format(L["Pulling in %d.."], delay))
	end

	-- One-second ticks, so "10" is roughly ten seconds of wall time.
	ticker = C_Timer.NewTicker(1, function()
		if not remaining then
			ResetTicker()
			return
		end
		remaining = remaining - 1
		if remaining > 0 then
			SendGroup(tostring(remaining) .. "..")
		else
			SendGroup(L["Pull!"])
			ResetTicker()
		end
	end)
end

-- Registered at file load so /pull always answers, even before the module's
-- OnEnable runs, mirroring how the addon's own slash command is set up.
SLASH_KKUI_PULL1 = "/pull"
SLASH_KKUI_PULL2 = "/pc"
SlashCmdList.KKUI_PULL = function(msg)
	Module:Start(msg)
end

function Module:OnDisable()
	ResetTicker()
end
