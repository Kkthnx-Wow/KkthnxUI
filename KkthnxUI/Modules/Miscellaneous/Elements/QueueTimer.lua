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
-- FIX: _G.string_format does not exist; the correct path is _G.string.format.
local string_format = _G.string.format
local type = _G.type

local _G = _G
local CreateFrame = _G.CreateFrame
local GetBattlefieldPortExpiration = _G.GetBattlefieldPortExpiration
local GetTime = _G.GetTime
local hooksecurefunc = _G.hooksecurefunc
local PlaySoundFile = _G.PlaySoundFile
local PVPReadyDialog_Showing = _G.PVPReadyDialog_Showing
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
local lastOpenSoundAt = 0

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
local function setQueueLabelText(fs, text)
	if not fs then
		return
	end
	if fs.kkShadow then
		K.SetPlainText(fs, text or "")
	else
		fs:SetText(text or "")
	end
end

local function createCustomQueueLabels(dialogFrame)
	if not dialogFrame or not dialogFrame.label or dialogFrame.queueTimerLabels then
		return
	end

	local frameWidth = dialogFrame:GetWidth()

	dialogFrame.customLabel = K.CreatePlainFS(dialogFrame, 15, "Queue expires in", "OVERLAY")
	dialogFrame.customLabel:SetPoint("TOP", dialogFrame.label, "TOP", 0, 0)
	dialogFrame.customLabel:SetWidth(frameWidth)

	dialogFrame.timerLabel = K.CreatePlainFS(dialogFrame, 24, nil, "OVERLAY")
	dialogFrame.timerLabel:SetPoint("TOP", dialogFrame.customLabel, "BOTTOM", 0, -5)
	dialogFrame.timerLabel:SetWidth(frameWidth)

	dialogFrame.bgLabel = K.CreatePlainFS(dialogFrame, 15, nil, "OVERLAY")
	dialogFrame.bgLabel:SetPoint("TOP", dialogFrame.timerLabel, "BOTTOM", 0, -4)
	dialogFrame.bgLabel:SetWidth(frameWidth)

	dialogFrame.statusTextLabel = K.CreatePlainFS(dialogFrame, 11, nil, "OVERLAY")
	dialogFrame.statusTextLabel:SetPoint("TOP", dialogFrame.bgLabel, "BOTTOM", 0, -3)
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
		setQueueLabelText(dialogFrame.timerLabel, getQueueExpiresText(secondsRemaining))
	end

	if dialogFrame.bgLabel and dialogFrame.statusTextLabel and dialogFrame.instanceInfo and dialogFrame.instanceInfo.name and (dialogFrame.instanceInfo:IsShown() or isPvPQueue) then
		setQueueLabelText(dialogFrame.bgLabel, dialogFrame.instanceInfo.name:GetText() or "")
		setQueueLabelText(dialogFrame.statusTextLabel, dialogFrame.instanceInfo.statusText and dialogFrame.instanceInfo.statusText:GetText() or "")
	else
		setQueueLabelText(dialogFrame.bgLabel, "")
		setQueueLabelText(dialogFrame.statusTextLabel, "")
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

local function playQueueOpenSound()
	local now = GetTime()
	if C["Misc"].QueueTimerAudio and (now - lastOpenSoundAt) > 1 then
		PlaySoundFile(QUEUE_WARNING_SOUND_ID, "master")
		lastOpenSoundAt = now
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
	if activePvPQueueIndex and pvpDialog and PVPReadyDialog_Showing(activePvPQueueIndex) then
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

local queueTimersActive = false
local pvpDisplayHooked = false

local function onLfgProposalShow()
	if not C["Misc"].QueueTimers then
		return
	end

	remainingPvETime = PVE_QUEUE_EXPIRE_BASE
	recalculateRemainingPvETime()
	Module:updateQueueExpiresDisplay(remainingPvETime, _G.LFGDungeonReadyDialog)
	savePvEQueuePopTime()
	hasPlayedWarningSound = false
	playQueueOpenSound()
	startQueueUpdateFrame()
	hideDefaultQueueTimers()
end

local function onLfgQueueDone()
	stopQueueUpdateFrame()
	clearPvEQueuePopTime()
end

local function onPvpReadyDialogDisplay(_, pvpIndex)
	if not C["Misc"].QueueTimers then
		return
	end

	activePvPQueueIndex = pvpIndex
	Module:updateQueueExpiresDisplay(GetBattlefieldPortExpiration(pvpIndex) or 0, _G.PVPReadyDialog, true)
	hasPlayedWarningSound = false
	playQueueOpenSound()
	startQueueUpdateFrame()
end

local function onBattlefieldStatus(_, pvpIndex)
	if not C["Misc"].QueueTimers then
		return
	end

	if _G.GetBattlefieldStatus(pvpIndex) == "confirm" then
		activePvPQueueIndex = pvpIndex
		Module:updateQueueExpiresDisplay(GetBattlefieldPortExpiration(pvpIndex) or 0, _G.PVPReadyDialog, true)
		hasPlayedWarningSound = false
		playQueueOpenSound()
		startQueueUpdateFrame()
	else
		if not remainingPvETime or remainingPvETime <= 0 then
			activePvPQueueIndex = nil
			stopQueueUpdateFrame()
		end
	end
end

function Module:DisableQueueTimers()
	if not queueTimersActive then
		return
	end

	queueTimersActive = false
	K:UnregisterEvent("LFG_PROPOSAL_SHOW", onLfgProposalShow)
	K:UnregisterEvent("LFG_PROPOSAL_SUCCEEDED", onLfgQueueDone)
	K:UnregisterEvent("LFG_PROPOSAL_DONE", onLfgQueueDone)
	K:UnregisterEvent("LFG_PROPOSAL_FAILED", onLfgQueueDone)
	K:UnregisterEvent("UPDATE_BATTLEFIELD_STATUS", onBattlefieldStatus)
	stopQueueUpdateFrame()
	clearPvEQueuePopTime()
	activePvPQueueIndex = nil
end

function Module:CreateQueueTimers()
	if not C["Misc"].QueueTimers then
		Module:DisableQueueTimers()
		return
	end

	if queueTimersActive then
		return
	end

	queueTimersActive = true

	K:RegisterEvent("LFG_PROPOSAL_SHOW", onLfgProposalShow)
	K:RegisterEvent("LFG_PROPOSAL_SUCCEEDED", onLfgQueueDone)
	K:RegisterEvent("LFG_PROPOSAL_DONE", onLfgQueueDone)
	K:RegisterEvent("LFG_PROPOSAL_FAILED", onLfgQueueDone)

	if not pvpDisplayHooked and _G.PVPReadyDialog_Display then
		hooksecurefunc("PVPReadyDialog_Display", onPvpReadyDialogDisplay)
		pvpDisplayHooked = true
	end

	K:RegisterEvent("UPDATE_BATTLEFIELD_STATUS", onBattlefieldStatus)
end

Module:RegisterMisc("QueueTimer", Module.CreateQueueTimers)
