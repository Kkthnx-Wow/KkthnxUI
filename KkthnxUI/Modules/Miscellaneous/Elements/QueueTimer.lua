--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Replaces standard queue timers with enhanced, more visible versions and warning sounds.
-- - Design: Hooks LFG and PVP ready dialogs, injects custom font strings, and tracks PvE pop times for persistent countdowns.
-- - Events: LFG_PROPOSAL_SHOW, LFG_PROPOSAL_SUCCEEDED, UPDATE_BATTLEFIELD_STATUS
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Miscellaneous")

-- PERF: Localize global functions and environment for faster lookups.
local ipairs = _G.ipairs
local math_max = _G.math.max
local select = _G.select
local string_format = _G.string_format
local type = _G.type

local _G = _G
local CreateFrame = _G.CreateFrame
local GetBattlefieldPortExpiration = _G.GetBattlefieldPortExpiration
local GetBattlefieldStatus = _G.GetBattlefieldStatus
local GetTime = _G.GetTime
local HookSecureFunc = _G.hooksecurefunc
local PlaySoundFile = _G.PlaySoundFile
local SecondsToTime = _G.SecondsToTime

-- SG: Constants
local QUEUE_WARNING_SOUND_ID = 567458
local QUEUE_WARNING_THRESHOLD = 6
local PVE_QUEUE_EXPIRE_BASE = 40
local QUEUE_UPDATE_INTERVAL = 0.2

-- SG: State Variables
local remainingPvETime = 0
local activePvPQueueIndex
local queueUpdateFrame
local hasPlayedWarningSound = false
local elapsedSinceLastUpdate = 0

-- REASON: Hides default Blizzard queue timer status bars to prevent UI clutter when custom timers are active.
local function hideDefaultQueueTimers()
	if not C["Misc"].QueueTimerHideOtherTimers then
		return
	end
	local queuePopup = _G.LFGDungeonReadyPopup
	if not queuePopup then
		return
	end
	local childFrameList = { queuePopup:GetChildren() }
	for _, childFrame in ipairs(childFrameList) do
		if childFrame.GetObjectType and childFrame:GetObjectType() == "StatusBar" then
			childFrame:Hide()
		end
	end
end

-- REASON: Injects custom font strings into a ready dialog frame for displaying remaining time and instance information.
local function createCustomQueueLabels(dialogFrame)
	if not dialogFrame or not dialogFrame.label or dialogFrame.queueTimerLabels then
		return
	end

	local frameWidth = dialogFrame:GetWidth()

	dialogFrame.customLabel = dialogFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	dialogFrame.customLabel:SetPoint("TOP", dialogFrame.label, "TOP", 0, 0)
	dialogFrame.customLabel:SetText("Queue expires in")
	local fontPath = select(1, dialogFrame.customLabel:GetFont())
	dialogFrame.customLabel:SetFont(fontPath, 15, "")
	dialogFrame.customLabel:SetShadowOffset(1, -1)
	dialogFrame.customLabel:SetWidth(frameWidth)

	dialogFrame.timerLabel = dialogFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	dialogFrame.timerLabel:SetPoint("TOP", dialogFrame.customLabel, "BOTTOM", 0, -5)
	fontPath = select(1, dialogFrame.timerLabel:GetFont())
	dialogFrame.timerLabel:SetFont(fontPath, 24, "")
	dialogFrame.timerLabel:SetShadowOffset(1, -1)
	dialogFrame.timerLabel:SetWidth(frameWidth)

	dialogFrame.bgLabel = dialogFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	dialogFrame.bgLabel:SetPoint("TOP", dialogFrame.timerLabel, "BOTTOM", 0, -4)
	fontPath = select(1, dialogFrame.bgLabel:GetFont())
	dialogFrame.bgLabel:SetFont(fontPath, 15, "")
	dialogFrame.bgLabel:SetShadowOffset(1, -1)
	dialogFrame.bgLabel:SetWidth(frameWidth)

	dialogFrame.statusTextLabel = dialogFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	dialogFrame.statusTextLabel:SetPoint("TOP", dialogFrame.bgLabel, "BOTTOM", 0, -3)
	fontPath = select(1, dialogFrame.statusTextLabel:GetFont())
	dialogFrame.statusTextLabel:SetFont(fontPath, 11, "")
	dialogFrame.statusTextLabel:SetShadowOffset(1, -1)
	dialogFrame.statusTextLabel:SetWidth(frameWidth)

	dialogFrame.queueTimerLabels = true
end

local function getQueueExpiresText(secondsUntilExpiration)
	local secondsRemaining = (secondsUntilExpiration and secondsUntilExpiration > 0) and secondsUntilExpiration or 1
	local expirationColorHex = (secondsRemaining > 20) and "20ff20" or (secondsRemaining > 10) and "ffff00" or "ff0000"
	return string_format("|cff%s%s|r", expirationColorHex, SecondsToTime(secondsRemaining))
end

function Module:updateQueueExpiresDisplay(timeRemaining, dialogFrame, isPvPQueue)
	if not dialogFrame then
		return
	end
	createCustomQueueLabels(dialogFrame)

	local secondsRemaining = timeRemaining or 0
	if dialogFrame.label then
		dialogFrame.label:SetText("")
	end
	if dialogFrame.instanceInfo and dialogFrame.instanceInfo.SetAlpha then
		dialogFrame.instanceInfo:SetAlpha(0)
	end

	if dialogFrame.timerLabel then
		dialogFrame.timerLabel:SetText(getQueueExpiresText(secondsRemaining))
	end

	if dialogFrame.bgLabel and dialogFrame.statusTextLabel and dialogFrame.instanceInfo and dialogFrame.instanceInfo.name and (dialogFrame.instanceInfo:IsShown() or isPvPQueue) then
		dialogFrame.bgLabel:SetText(dialogFrame.instanceInfo.name:GetText() or "")
		dialogFrame.statusTextLabel:SetText(dialogFrame.instanceInfo.statusText and dialogFrame.instanceInfo.statusText:GetText() or "")
	else
		if dialogFrame.bgLabel then
			dialogFrame.bgLabel:SetText("")
		end
		if dialogFrame.statusTextLabel then
			dialogFrame.statusTextLabel:SetText("")
		end
	end
end

-- REASON: Persists the PvE queue pop timestamp to the character database to allow for accurate countdowns across UI refreshes.
local function savePvEQueuePopTime()
	local charData = K.GetCharVars()
	charData.QueueTimer = charData.QueueTimer or {}
	charData.QueueTimer.PVEPopTime = GetTime()
end

local function loadPvEQueuePopTime()
	local queueData = K.GetCharVars().QueueTimer
	return queueData and queueData.PVEPopTime or nil
end

local function clearPvEQueuePopTime()
	local queueData = K.GetCharVars().QueueTimer
	if queueData then
		queueData.PVEPopTime = nil
	end
end

-- REASON: Recalculates the remaining PvE queue time based on the persisted pop timestamp to maintain countdown accuracy.
local function recalculateRemainingPvETime()
	local popTimeValue = loadPvEQueuePopTime()

	if type(popTimeValue) == "table" then
		popTimeValue = popTimeValue.timeAdded or popTimeValue.value or popTimeValue[1]
	end

	if not popTimeValue or type(popTimeValue) ~= "number" then
		remainingPvETime = PVE_QUEUE_EXPIRE_BASE
		return
	end

	local timeDelta = GetTime() - popTimeValue
	local timeRemain = PVE_QUEUE_EXPIRE_BASE - timeDelta
	if timeRemain < 0 or timeRemain > PVE_QUEUE_EXPIRE_BASE then
		remainingPvETime = PVE_QUEUE_EXPIRE_BASE
	else
		remainingPvETime = timeRemain
	end
end

-- REASON: Plays a triple-beep warning sound when the queue is close to expiration to alert the player.
local function warnOnQueueExpiration(secondsUntilExpiration)
	if not C["Misc"].QueueTimerWarning then
		return
	end
	if secondsUntilExpiration <= QUEUE_WARNING_THRESHOLD and not hasPlayedWarningSound then
		PlaySoundFile(QUEUE_WARNING_SOUND_ID, "master")
		_G.C_Timer.After(0.1, function()
			PlaySoundFile(QUEUE_WARNING_SOUND_ID, "master")
		end)
		_G.C_Timer.After(0.2, function()
			PlaySoundFile(QUEUE_WARNING_SOUND_ID, "master")
		end)
		hasPlayedWarningSound = true
	end
end

local function updatePvEQueueUI()
	local lfgDialog = _G.LFGDungeonReadyDialog
	if lfgDialog and lfgDialog:IsShown() then
		local displaySeconds = math_max(remainingPvETime or 0, 0)
		warnOnQueueExpiration(displaySeconds)
		Module:updateQueueExpiresDisplay(displaySeconds, lfgDialog)
	end
end

local function updatePvPQueueUI()
	local pvpDialog = _G.PVPReadyDialog
	if activePvPQueueIndex and pvpDialog and _G.PVPReadyDialog_Showing(activePvPQueueIndex) then
		local secondsValue = GetBattlefieldPortExpiration(activePvPQueueIndex)
		if secondsValue and secondsValue > 0 then
			warnOnQueueExpiration(secondsValue)
			Module:updateQueueExpiresDisplay(secondsValue, pvpDialog, true)
		else
			activePvPQueueIndex = nil
			hasPlayedWarningSound = false
		end
	end
end

local function onUpdateTick(_, elapsed)
	elapsedSinceLastUpdate = elapsedSinceLastUpdate + elapsed
	if elapsedSinceLastUpdate < QUEUE_UPDATE_INTERVAL then
		return
	end
	elapsedSinceLastUpdate = 0

	if remainingPvETime and remainingPvETime > 0 then
		remainingPvETime = remainingPvETime - QUEUE_UPDATE_INTERVAL
		updatePvEQueueUI()
	end
	updatePvPQueueUI()
end

local function startQueueUpdateFrame()
	if not queueUpdateFrame then
		queueUpdateFrame = CreateFrame("Frame")
		queueUpdateFrame:SetScript("OnUpdate", onUpdateTick)
	end
	queueUpdateFrame:Show()
end

local function stopQueueUpdateFrame()
	if queueUpdateFrame then
		queueUpdateFrame:Hide()
	end
	hasPlayedWarningSound = false
end

function Module:CreateQueueTimers()
	if not C["Misc"].QueueTimers then
		return
	end

	K:RegisterEvent("LFG_PROPOSAL_SHOW", function()
		remainingPvETime = PVE_QUEUE_EXPIRE_BASE
		recalculateRemainingPvETime()
		Module:updateQueueExpiresDisplay(remainingPvETime, _G.LFGDungeonReadyDialog)
		savePvEQueuePopTime()
		hasPlayedWarningSound = false
		startQueueUpdateFrame()
		hideDefaultQueueTimers()
	end)

	local function onLfgQueueDone()
		stopQueueUpdateFrame()
		clearPvEQueuePopTime()
	end

	K:RegisterEvent("LFG_PROPOSAL_SUCCEEDED", onLfgQueueDone)
	K:RegisterEvent("LFG_PROPOSAL_DONE", onLfgQueueDone)
	K:RegisterEvent("LFG_PROPOSAL_FAILED", onLfgQueueDone)

	if _G.PVPReadyDialog_Display then
		HookSecureFunc("PVPReadyDialog_Display", function(_, pvpIndex)
			activePvPQueueIndex = pvpIndex
			Module:updateQueueExpiresDisplay(GetBattlefieldPortExpiration(pvpIndex) or 0, _G.PVPReadyDialog, true)
			hasPlayedWarningSound = false
			startQueueUpdateFrame()
		end)
	end

	K:RegisterEvent("UPDATE_BATTLEFIELD_STATUS", function(_, pvpIndex)
		if _G.GetBattlefieldStatus(pvpIndex) == "confirm" then
			activePvPQueueIndex = pvpIndex
			Module:updateQueueExpiresDisplay(GetBattlefieldPortExpiration(pvpIndex) or 0, _G.PVPReadyDialog, true)
			hasPlayedWarningSound = false
			startQueueUpdateFrame()
		else
			if not remainingPvETime or remainingPvETime <= 0 then
				activePvPQueueIndex = nil
				stopQueueUpdateFrame()
			end
		end
	end)
end

Module:RegisterMisc("QueueTimer", Module.CreateQueueTimers)
