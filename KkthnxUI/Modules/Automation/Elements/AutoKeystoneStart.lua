--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Adds a moveable countdown button for Mythic+ dungeon starts, with optional ready-check display and announcement chat messages.
-- - Design: Uses a single button for dual countdown actions and a small status text for group readiness.
-- - Events: GROUP_ROSTER_UPDATE, READY_CHECK, READY_CHECK_CONFIRM, READY_CHECK_FINISHED
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Automation")

-- PERF: Localize frequently used globals.
local _G = _G
local CreateFrame = _G.CreateFrame
local C_Timer_NewTicker = _G.C_Timer.NewTicker
local DoReadyCheck = _G.DoReadyCheck
local GetNumGroupMembers = _G.GetNumGroupMembers
local GetReadyCheckStatus = _G.GetReadyCheckStatus
local IsInGroup = _G.IsInGroup
local IsInRaid = _G.IsInRaid
local IsLFGComplete = _G.IsLFGComplete
local IsPartyLFG = _G.IsPartyLFG
local SendChatMessage = _G.SendChatMessage
local UnitExists = _G.UnitExists
local UnitIsGroupAssistant = _G.UnitIsGroupAssistant
local UnitIsGroupLeader = _G.UnitIsGroupLeader
local C_ChallengeMode_StartChallengeMode = _G.C_ChallengeMode and _G.C_ChallengeMode.StartChallengeMode
local format = string.format

local countdownTicker
local isReadyCheckActive = false
local readyCount = 0
local totalCount = 0
local startButton

local function getAnnouncementChannel()
	if IsInRaid() then
		return "RAID"
	end

	if IsPartyLFG() and IsLFGComplete() then
		return "INSTANCE_CHAT"
	end

	return "PARTY"
end

local function scanReadyCheckStatus()
	readyCount, totalCount = 0, 0

	if not IsInGroup() then
		return
	end

	if IsInRaid() then
		for i = 1, GetNumGroupMembers() do
			local unit = "raid" .. i
			if UnitExists(unit) then
				local status = GetReadyCheckStatus(unit)
				if status then
					totalCount = totalCount + 1
					if status == "ready" then
						readyCount = readyCount + 1
					end
				end
			end
		end
	else
		local playerStatus = GetReadyCheckStatus("player")
		totalCount = 1
		if playerStatus == "ready" then
			readyCount = 1
		end

		for i = 1, GetNumGroupMembers() - 1 do
			local unit = "party" .. i
			if UnitExists(unit) then
				local status = GetReadyCheckStatus(unit)
				if status then
					totalCount = totalCount + 1
					if status == "ready" then
						readyCount = readyCount + 1
					end
				end
			end
		end
	end
end

local function updateReadyStatusText()
	if not startButton then
		return
	end

	if not IsInGroup() then
		startButton.readyText:SetText(L["Solo"] or "Solo")
		return
	end

	if isReadyCheckActive then
		startButton.readyText:SetText(format("%s: %d/%d", L["Ready Check"], readyCount, totalCount))
	else
		startButton.readyText:SetText(format("%s: %d", L["Group"], GetNumGroupMembers()))
	end
end

local function stopCountdown()
	if countdownTicker then
		countdownTicker:Cancel()
		countdownTicker = nil
	end
	if startButton then
		startButton.timerText:SetText("")
	end
end

local function sendCountdownAnnouncement(value)
	if not C["Automation"].AutoKeystoneStartAnnouncements or not IsInGroup() then
		return
	end

	local channel = getAnnouncementChannel()
	if value > 0 then
		SendChatMessage(tostring(value), channel)
	else
		SendChatMessage(L["LetsGo"] or "Let's go!", channel)
	end
end

local function startCountdown(duration)
	stopCountdown()

	if not startButton then
		return
	end

	local remaining = duration
	startButton.timerText:SetText(tostring(remaining))
	if remaining <= 5 then
		sendCountdownAnnouncement(remaining)
	end

	countdownTicker = C_Timer_NewTicker(1, function()
		remaining = remaining - 1
		if remaining <= 0 then
			startButton.timerText:SetText(L["Go"] or "Go!")
			sendCountdownAnnouncement(0)
			stopCountdown()
			if C["Automation"].AutoKeystoneStart and C_ChallengeMode_StartChallengeMode then
				C_ChallengeMode_StartChallengeMode()
			end
			return
		end

		startButton.timerText:SetText(tostring(remaining))
		if remaining <= 5 then
			sendCountdownAnnouncement(remaining)
		end
	end)
end

local function canInitiateReadyCheck()
	return IsInGroup() and (UnitIsGroupLeader("player") or UnitIsGroupAssistant("player"))
end

local function onReadyCheckEvent(event)
	if event == "READY_CHECK" then
		isReadyCheckActive = true
	end

	scanReadyCheckStatus()
	updateReadyStatusText()

	if event == "READY_CHECK_FINISHED" then
		K.Delay(5, function()
			isReadyCheckActive = false
			updateReadyStatusText()
		end)
	end
end

local function onGroupUpdate()
	scanReadyCheckStatus()
	updateReadyStatusText()
end

function Module:CreateAutoKeystoneStart()
	if not C["Automation"].AutoKeystoneStart then
		return
	end

	if not C_ChallengeMode_StartChallengeMode then
		return
	end

	local frame = CreateFrame("Button", "KkthnxUI_AutoKeystoneStart", _G.UIParent, "UIPanelButtonTemplate")
	frame:SetSize(160, 50)
	frame:SetPoint("TOP", _G.UIParent, "TOP", 0, -150)
	frame:SkinButton()
	K.Mover(frame, "AutoKeystoneStart", "AutoKeystoneStart", { "TOP", _G.UIParent, "TOP", 0, -150 })

	frame.title = K.CreateFontString(frame, 14, L["Auto Keystone Start"] or "Auto Keystone Start", "", true, "TOP", 0, -8)
	frame.timerText = K.CreateFontString(frame, 18, "", "", true, "CENTER", 0, -3)
	frame.readyText = K.CreateFontString(frame, 12, "", "", false, "BOTTOM", 0, 6)
	frame:SetScript("OnClick", function(_, button)
		if button == "LeftButton" then
			if canInitiateReadyCheck() then
				DoReadyCheck()
			end
			startCountdown(10)
		elseif button == "RightButton" then
			if canInitiateReadyCheck() then
				DoReadyCheck()
			end
			startCountdown(5)
		end
	end)

	frame:SetScript("OnEnter", function(self)
		_G.GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
		_G.GameTooltip:ClearLines()
		_G.GameTooltip:AddLine(L["Auto Keystone Start"] or "Auto Keystone Start", 1, 1, 1)
		_G.GameTooltip:AddLine(" ")
		_G.GameTooltip:AddLine(L["Left click starts a 10 second countdown."] or "Left click starts a 10 second countdown.", 1, 1, 1)
		_G.GameTooltip:AddLine(L["Right click starts a 5 second countdown."] or "Right click starts a 5 second countdown.", 1, 1, 1)
		_G.GameTooltip:AddLine(L["Announces the countdown when enabled."] or "Announces the countdown when enabled.", 1, 1, 1)
		_G.GameTooltip:Show()
	end)
	frame:SetScript("OnLeave", function()
		_G.GameTooltip:Hide()
	end)

	startButton = frame
	scanReadyCheckStatus()
	updateReadyStatusText()

	K:RegisterEvent("GROUP_ROSTER_UPDATE", onGroupUpdate)
	K:RegisterEvent("READY_CHECK", onReadyCheckEvent)
	K:RegisterEvent("READY_CHECK_CONFIRM", onReadyCheckEvent)
	K:RegisterEvent("READY_CHECK_FINISHED", onReadyCheckEvent)
end
