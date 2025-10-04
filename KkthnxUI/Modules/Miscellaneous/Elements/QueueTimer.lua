local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Miscellaneous")

-- Enhanced Queue Timer (PvE/PvP) with config toggles
-- - Audio cue on pop and warning near expiration
-- - Optional hiding of other timer status bars on the dialog
-- - Persists PvE queue pop time across reloads to keep timer accurate

local SecondsToTime = SecondsToTime
local CreateFrame = CreateFrame
local PlaySoundFile = PlaySoundFile
local GetTime = GetTime
local hooksecurefunc = hooksecurefunc

local LFGDungeonReadyDialog = LFGDungeonReadyDialog
local PVPReadyDialog = PVPReadyDialog

local SOUND_ID = 567458 -- UI_Button_Click_01 (placeholder from example)
local WARNING_THRESHOLD = 6
local PVE_BASE_EXPIRE = 40

local pveRemaining = 0
local pvpQueueIndex
local updateFrame
local soundPlayed
local updateInterval = 0.2
local elapsedStamp = 0

-- Chat prints intentionally omitted; audio handled in BeepWarningIfNeeded

local function HideOtherTimers()
	if not C["Misc"].QueueTimerHideOtherTimers then
		return
	end
	local popup = _G and rawget(_G, "LFGDungeonReadyPopup")
	if not popup then
		return
	end
	local children = { popup:GetChildren() }
	for _, child in ipairs(children) do
		if child.GetObjectType and child:GetObjectType() == "StatusBar" then
			child:Hide()
		end
	end
end

-- Create large, center-aligned timer presentation similar to BetterBlizzQueue
local function EnsureCustomLabels(dialog)
	if not dialog or not dialog.label then
		return
	end

	if dialog.queueTimerLabels then
		return
	end

	local maxWidth = dialog:GetWidth()

	-- Title: "Queue expires in"
	dialog.customLabel = dialog:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	dialog.customLabel:SetPoint("TOP", dialog.label, "TOP", 0, 0)
	dialog.customLabel:SetText("Queue expires in")
	local fontFile = select(1, dialog.customLabel:GetFont())
	dialog.customLabel:SetFont(fontFile, 15, "")
	dialog.customLabel:SetShadowOffset(1, -1)
	dialog.customLabel:SetWidth(maxWidth)

	-- Big timer
	dialog.timerLabel = dialog:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	dialog.timerLabel:SetPoint("TOP", dialog.customLabel, "BOTTOM", 0, -5)
	fontFile = select(1, dialog.timerLabel:GetFont())
	dialog.timerLabel:SetFont(fontFile, 24, "")
	dialog.timerLabel:SetShadowOffset(1, -1)
	dialog.timerLabel:SetWidth(maxWidth)

	-- Instance name
	dialog.bgLabel = dialog:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	dialog.bgLabel:SetPoint("TOP", dialog.timerLabel, "BOTTOM", 0, -4)
	fontFile = select(1, dialog.bgLabel:GetFont())
	dialog.bgLabel:SetFont(fontFile, 15, "")
	dialog.bgLabel:SetShadowOffset(1, -1)
	dialog.bgLabel:SetWidth(maxWidth)

	-- Status text
	dialog.statusTextLabel = dialog:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	dialog.statusTextLabel:SetPoint("TOP", dialog.bgLabel, "BOTTOM", 0, -3)
	fontFile = select(1, dialog.statusTextLabel:GetFont())
	dialog.statusTextLabel:SetFont(fontFile, 11, "")
	dialog.statusTextLabel:SetShadowOffset(1, -1)
	dialog.statusTextLabel:SetWidth(maxWidth)

	dialog.queueTimerLabels = true
end

-- Format timer color like BetterBlizzQueue: >20 green, >10 yellow, else red
local function FormatExpiresText(seconds)
	local secs = seconds and seconds > 0 and seconds or 1
	local colorHex = (secs > 20) and "20ff20" or (secs > 10) and "ffff00" or "ff0000"
	return string.format("|cff%s%s|r", colorHex, SecondsToTime(secs))
end

local function SetExpiresText(timeRemaining, dialog, isPvP)
	if not dialog then
		return
	end

	EnsureCustomLabels(dialog)

	local secs = timeRemaining or 0
	if dialog.label then
		dialog.label:SetText("")
	end
	if dialog.instanceInfo and dialog.instanceInfo.SetAlpha then
		dialog.instanceInfo:SetAlpha(0)
	end

	if dialog.timerLabel then
		dialog.timerLabel:SetText(FormatExpiresText(secs))
	end

	if dialog.bgLabel and dialog.statusTextLabel and dialog.instanceInfo and dialog.instanceInfo.name and (dialog.instanceInfo:IsShown() or isPvP) then
		dialog.bgLabel:SetText(dialog.instanceInfo.name:GetText() or "")
		dialog.statusTextLabel:SetText(dialog.instanceInfo.statusText and dialog.instanceInfo.statusText:GetText() or "")
	else
		if dialog.bgLabel then
			dialog.bgLabel:SetText("")
		end
		if dialog.statusTextLabel then
			dialog.statusTextLabel:SetText("")
		end
	end
end

-- Persist PvE pop time to survive reloads
local function SavePVEPopTime()
	KkthnxUIDB.Variables[K.Realm][K.Name].QueueTimer = KkthnxUIDB.Variables[K.Realm][K.Name].QueueTimer or {}
	KkthnxUIDB.Variables[K.Realm][K.Name].QueueTimer.PVEPopTime = GetTime()
end

local function LoadPVEPopTime()
	local t = KkthnxUIDB.Variables[K.Realm][K.Name].QueueTimer
	return t and t.PVEPopTime or nil
end

local function ClearPVEPopTime()
	local t = KkthnxUIDB.Variables[K.Realm][K.Name].QueueTimer
	if t then
		t.PVEPopTime = nil
	end
end

local function RecalcPVERemaining()
	local pop = LoadPVEPopTime()
	if not pop then
		pveRemaining = PVE_BASE_EXPIRE
		return
	end
	local delta = GetTime() - pop
	local remain = PVE_BASE_EXPIRE - delta
	if remain < 0 or remain > PVE_BASE_EXPIRE then
		pveRemaining = PVE_BASE_EXPIRE
	else
		pveRemaining = remain
	end
end

local function BeepWarningIfNeeded(seconds)
	if not C["Misc"].QueueTimerWarning then
		return
	end
	if seconds <= WARNING_THRESHOLD and not soundPlayed then
		PlaySoundFile(SOUND_ID, "master")
		C_Timer.After(0.1, function()
			PlaySoundFile(SOUND_ID, "master")
		end)
		C_Timer.After(0.2, function()
			PlaySoundFile(SOUND_ID, "master")
		end)
		soundPlayed = true
	end
end

local function UpdatePvE()
	if LFGDungeonReadyDialog and LFGDungeonReadyDialog:IsShown() then
		local secs = math.max(pveRemaining or 0, 0)
		BeepWarningIfNeeded(secs)
		SetExpiresText(secs, LFGDungeonReadyDialog)
	end
end

local function UpdatePvP()
	if pvpQueueIndex and PVPReadyDialog and PVPReadyDialog_Showing(pvpQueueIndex) then
		local seconds = GetBattlefieldPortExpiration(pvpQueueIndex)
		if seconds and seconds > 0 then
			BeepWarningIfNeeded(seconds)
			SetExpiresText(seconds, PVPReadyDialog, true)
		else
			pvpQueueIndex = nil
			soundPlayed = false
		end
	end
end

local function OnUpdate(_, elapsed)
	elapsedStamp = elapsedStamp + elapsed
	if elapsedStamp < updateInterval then
		return
	end
	elapsedStamp = 0

	if pveRemaining and pveRemaining > 0 then
		pveRemaining = pveRemaining - updateInterval
		UpdatePvE()
	end
	UpdatePvP()
end

local function StartUpdater()
	if not updateFrame then
		updateFrame = CreateFrame("Frame")
		updateFrame:SetScript("OnUpdate", OnUpdate)
	end
	updateFrame:Show()
end

local function StopUpdater()
	if updateFrame then
		updateFrame:Hide()
		soundPlayed = false
	end
end

local function CaptureQueueWaitTimes()
	-- Optional enhancement: measure LFD queued time
end

function Module:CreateQueueTimers()
	if not C["Misc"].QueueTimers then
		return
	end

	-- PvE proposal
	K:RegisterEvent("LFG_PROPOSAL_SHOW", function()
		pveRemaining = PVE_BASE_EXPIRE
		RecalcPVERemaining()
		SetExpiresText(pveRemaining, LFGDungeonReadyDialog)
		SavePVEPopTime()
		soundPlayed = false
		StartUpdater()
		HideOtherTimers()
	end)

	K:RegisterEvent("LFG_PROPOSAL_SUCCEEDED", function()
		StopUpdater()
		ClearPVEPopTime()
		soundPlayed = false
	end)

	K:RegisterEvent("LFG_PROPOSAL_DONE", function()
		StopUpdater()
		ClearPVEPopTime()
		soundPlayed = false
	end)

	K:RegisterEvent("LFG_PROPOSAL_FAILED", function()
		StopUpdater()
		ClearPVEPopTime()
		soundPlayed = false
	end)

	K:RegisterEvent("LFG_QUEUE_STATUS_UPDATE", function()
		CaptureQueueWaitTimes()
	end)

	-- PvP confirm
	if PVPReadyDialog_Display then
		hooksecurefunc("PVPReadyDialog_Display", function(_, index)
			pvpQueueIndex = index
			SetExpiresText(GetBattlefieldPortExpiration(index) or 0, PVPReadyDialog, true)
			soundPlayed = false
			StartUpdater()
		end)
	end

	K:RegisterEvent("UPDATE_BATTLEFIELD_STATUS", function(_, index)
		if GetBattlefieldStatus(index) == "confirm" then
			pvpQueueIndex = index
			SetExpiresText(GetBattlefieldPortExpiration(index) or 0, PVPReadyDialog, true)
			soundPlayed = false
			StartUpdater()
		else
			if not pveRemaining or pveRemaining <= 0 then
				pvpQueueIndex = nil
				StopUpdater()
			end
		end
	end)
end

Module:RegisterMisc("QueueTimer", Module.CreateQueueTimers)
