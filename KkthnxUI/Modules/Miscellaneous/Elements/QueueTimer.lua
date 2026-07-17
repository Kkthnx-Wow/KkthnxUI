--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Notes:
-- - Purpose: Larger colour-coded LFG/PvP ready countdown + optional expire warning.
-- - Design: Colour-coded LFG/PvP ready countdown + optional expire warning.
--   Blizzard shows the ready popup but no LFG expiration API — ~40s is measured
--   client-side and persisted per-character so a /reload mid-pop keeps the countdown honest.
-- - Events: LFG_PROPOSAL_*, UPDATE_BATTLEFIELD_STATUS; hooks LFGDungeonReadyPopup_Update
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Miscellaneous")

local _G = _G
local ipairs = ipairs
local type = type
local format = string.format
local max = math.max

local CreateFrame = CreateFrame
local GetTime = GetTime
local PlaySoundFile = PlaySoundFile
local SecondsToTime = SecondsToTime
local C_Timer_After = C_Timer.After
local GetBattlefieldPortExpiration = GetBattlefieldPortExpiration
local GetBattlefieldStatus = GetBattlefieldStatus
local GetLFGProposal = GetLFGProposal
local GetMaxBattlefieldID = GetMaxBattlefieldID
local hooksecurefunc = hooksecurefunc

local WARNING_SOUND_ID = 567458
local WARNING_THRESHOLD = 6
local PVE_EXPIRE_BASE = 40
local UPDATE_INTERVAL = 0.2

local remainingPvETime = 0
local activePvPIndex
local updateFrame
local hasWarned = false
local sinceLastUpdate = 0
local lastOpenSoundAt = 0
local queueTimersActive = false
local hooksInstalled = false

-- ---------------------------------------------------------------------------
-- Settings / char persistence
-- ---------------------------------------------------------------------------

local function IsEnabled()
	return C["Misc"].QueueTimers
end

local function SavePvEPopTime()
	local charData = K.GetCharVars()
	charData.QueueTimer = charData.QueueTimer or {}
	charData.QueueTimer.PVEPopTime = GetTime()
end

local function LoadPvEPopTime()
	local data = K.GetCharVars().QueueTimer
	return data and data.PVEPopTime or nil
end

local function ClearPvEPopTime()
	local data = K.GetCharVars().QueueTimer
	if data then
		data.PVEPopTime = nil
	end
end

local function RecalculateRemainingPvE()
	local popTime = LoadPvEPopTime()
	if type(popTime) ~= "number" or popTime <= 0 then
		remainingPvETime = PVE_EXPIRE_BASE
		return
	end

	local remain = PVE_EXPIRE_BASE - (GetTime() - popTime)
	if remain < 0 or remain > PVE_EXPIRE_BASE then
		remainingPvETime = PVE_EXPIRE_BASE
	else
		remainingPvETime = remain
	end
end

-- ---------------------------------------------------------------------------
-- Custom labels on the ready dialog
-- ---------------------------------------------------------------------------

local function HideDefaultQueueTimers()
	if not C["Misc"].QueueTimerHideOtherTimers then
		return
	end

	-- Legacy StatusBar children only; 12.0.7 FrameXML has no default LFG countdown bar.
	local popup = _G.LFGDungeonReadyPopup
	if not popup then
		return
	end

	for _, child in ipairs({ popup:GetChildren() }) do
		if child.GetObjectType and child:GetObjectType() == "StatusBar" then
			child:Hide()
		end
	end
end

local function CreateLabels(dialog)
	if not dialog or not dialog.label or dialog.kkuiQueueLabels then
		return
	end

	local width = dialog:GetWidth()

	dialog.kkuiHeader = K.CreatePlainFS(dialog, 15, L["Queue expires in"], "OVERLAY")
	dialog.kkuiHeader:SetPoint("TOP", dialog.label, "TOP", 0, 0)
	dialog.kkuiHeader:SetWidth(width)

	dialog.kkuiTimer = K.CreatePlainFS(dialog, 24, nil, "OVERLAY")
	dialog.kkuiTimer:SetPoint("TOP", dialog.kkuiHeader, "BOTTOM", 0, -5)
	dialog.kkuiTimer:SetWidth(width)

	dialog.kkuiName = K.CreatePlainFS(dialog, 15, nil, "OVERLAY")
	dialog.kkuiName:SetPoint("TOP", dialog.kkuiTimer, "BOTTOM", 0, -4)
	dialog.kkuiName:SetWidth(width)

	dialog.kkuiStatus = K.CreatePlainFS(dialog, 11, nil, "OVERLAY")
	dialog.kkuiStatus:SetPoint("TOP", dialog.kkuiName, "BOTTOM", 0, -3)
	dialog.kkuiStatus:SetWidth(width)

	dialog.kkuiQueueLabels = true
end

local function ExpiresText(seconds)
	local remain = (seconds and seconds > 0) and seconds or 1
	local hex = (remain > 20) and "20ff20" or (remain > 10) and "ffff00" or "ff0000"
	return format("|cff%s%s|r", hex, SecondsToTime(remain))
end

function Module:UpdateQueueTimerDisplay(timeRemaining, dialog, isPvP)
	if not dialog then
		return
	end
	CreateLabels(dialog)

	local remain = timeRemaining or 0
	if dialog.label then
		dialog.label:SetText("")
	end
	if dialog.instanceInfo and dialog.instanceInfo.SetAlpha then
		dialog.instanceInfo:SetAlpha(0)
	end

	K.SetPlainText(dialog.kkuiTimer, ExpiresText(remain))

	local info = dialog.instanceInfo
	if dialog.kkuiName and dialog.kkuiStatus and info and info.name and (info:IsShown() or isPvP) then
		K.SetPlainText(dialog.kkuiName, info.name:GetText() or "")
		K.SetPlainText(dialog.kkuiStatus, info.statusText and info.statusText:GetText() or "")
	else
		K.SetPlainText(dialog.kkuiName, "")
		K.SetPlainText(dialog.kkuiStatus, "")
	end
end

local function RefreshPvEDisplay()
	if not remainingPvETime or remainingPvETime <= 0 then
		return
	end
	local dialog = _G.LFGDungeonReadyDialog
	if dialog and dialog:IsShown() then
		Module:UpdateQueueTimerDisplay(remainingPvETime, dialog)
		HideDefaultQueueTimers()
	end
end

-- ---------------------------------------------------------------------------
-- Sounds
-- ---------------------------------------------------------------------------

local function WarnOnExpiration(seconds)
	if not C["Misc"].QueueTimerWarning then
		return
	end
	if seconds <= WARNING_THRESHOLD and not hasWarned then
		PlaySoundFile(WARNING_SOUND_ID, "master")
		C_Timer_After(0.1, function()
			PlaySoundFile(WARNING_SOUND_ID, "master")
		end)
		C_Timer_After(0.2, function()
			PlaySoundFile(WARNING_SOUND_ID, "master")
		end)
		hasWarned = true
	end
end

local function PlayQueueOpenSound()
	if not C["Misc"].QueueTimerAudio then
		return
	end
	local now = GetTime()
	if (now - lastOpenSoundAt) > 1 then
		PlaySoundFile(WARNING_SOUND_ID, "master")
		lastOpenSoundAt = now
	end
end

-- ---------------------------------------------------------------------------
-- Ticker
-- ---------------------------------------------------------------------------

local function OnUpdate(_, elapsed)
	sinceLastUpdate = sinceLastUpdate + elapsed
	if sinceLastUpdate < UPDATE_INTERVAL then
		return
	end
	sinceLastUpdate = 0

	if remainingPvETime and remainingPvETime > 0 then
		remainingPvETime = remainingPvETime - UPDATE_INTERVAL
		local dialog = _G.LFGDungeonReadyDialog
		if dialog and dialog:IsShown() then
			local seconds = max(remainingPvETime, 0)
			WarnOnExpiration(seconds)
			Module:UpdateQueueTimerDisplay(seconds, dialog)
		end
	end

	local dialog = _G.PVPReadyDialog
	if activePvPIndex and dialog and _G.PVPReadyDialog_Showing and _G.PVPReadyDialog_Showing(activePvPIndex) then
		local seconds = GetBattlefieldPortExpiration(activePvPIndex)
		if seconds and seconds > 0 then
			WarnOnExpiration(seconds)
			Module:UpdateQueueTimerDisplay(seconds, dialog, true)
		else
			activePvPIndex = nil
			hasWarned = false
		end
	end
end

local function StartTicker()
	if not updateFrame then
		updateFrame = CreateFrame("Frame")
	end
	updateFrame:SetScript("OnUpdate", OnUpdate)
	updateFrame:Show()
end

local function StopTicker()
	if updateFrame then
		updateFrame:SetScript("OnUpdate", nil)
		updateFrame:Hide()
	end
	hasWarned = false
end

local function SyncActivePvE()
	local proposalExists = GetLFGProposal()
	local popup = _G.LFGDungeonReadyPopup

	if not proposalExists or not popup or not popup:IsShown() then
		if remainingPvETime > 0 then
			remainingPvETime = 0
			StopTicker()
			ClearPvEPopTime()
		end
		return
	end

	RecalculateRemainingPvE()
	if remainingPvETime > 0 then
		RefreshPvEDisplay()
		StartTicker()
	end
end

local function SyncActivePvP()
	for i = 1, GetMaxBattlefieldID() do
		if GetBattlefieldStatus(i) == "confirm" then
			activePvPIndex = i
			Module:UpdateQueueTimerDisplay(GetBattlefieldPortExpiration(i) or 0, _G.PVPReadyDialog, true)
			hasWarned = false
			StartTicker()
			return
		end
	end
	activePvPIndex = nil
	if remainingPvETime <= 0 then
		StopTicker()
	end
end

local function BootstrapActiveQueues()
	if not IsEnabled() or not queueTimersActive then
		return
	end
	SyncActivePvE()
	SyncActivePvP()
end

-- ---------------------------------------------------------------------------
-- Events — K:RegisterEvent passes (event, ...payload)
-- ---------------------------------------------------------------------------

local function OnLFGProposalShow()
	if not IsEnabled() then
		return
	end

	remainingPvETime = PVE_EXPIRE_BASE
	RecalculateRemainingPvE()
	SavePvEPopTime()
	hasWarned = false
	PlayQueueOpenSound()
	StartTicker()
	-- Dialog content fills in LFGDungeonReadyPopup_Update (OnShow / PROPOSAL_UPDATE).
	C_Timer_After(0, RefreshPvEDisplay)
end

local function OnLFGProposalUpdate()
	if not IsEnabled() then
		return
	end
	if not GetLFGProposal() then
		remainingPvETime = 0
		StopTicker()
		ClearPvEPopTime()
		return
	end
	RefreshPvEDisplay()
end

local function OnLFGProposalEnded()
	remainingPvETime = 0
	StopTicker()
	ClearPvEPopTime()
end

local function OnBattlefieldStatus(_, index)
	if not IsEnabled() then
		return
	end

	local status = GetBattlefieldStatus(index)
	if status == "confirm" then
		activePvPIndex = index
		Module:UpdateQueueTimerDisplay(GetBattlefieldPortExpiration(index) or 0, _G.PVPReadyDialog, true)
		hasWarned = false
		PlayQueueOpenSound()
		StartTicker()
	elseif activePvPIndex == index then
		activePvPIndex = nil
		hasWarned = false
		if remainingPvETime <= 0 then
			StopTicker()
		end
	end
end

local function InstallHooks()
	if hooksInstalled then
		return
	end
	hooksInstalled = true

	if _G.LFGDungeonReadyPopup_Update then
		hooksecurefunc("LFGDungeonReadyPopup_Update", function()
			if IsEnabled() and queueTimersActive and remainingPvETime > 0 then
				RefreshPvEDisplay()
			end
		end)
	end

	if _G.PVPReadyDialog_Display then
		hooksecurefunc("PVPReadyDialog_Display", function(_, index)
			if not IsEnabled() or not queueTimersActive then
				return
			end
			activePvPIndex = index
			Module:UpdateQueueTimerDisplay(GetBattlefieldPortExpiration(index) or 0, _G.PVPReadyDialog, true)
			hasWarned = false
			PlayQueueOpenSound()
			StartTicker()
		end)
	end
end

-- ---------------------------------------------------------------------------
-- Enable / disable
-- ---------------------------------------------------------------------------

function Module:DisableQueueTimers()
	if not queueTimersActive then
		return
	end

	queueTimersActive = false
	K:UnregisterEvent("LFG_PROPOSAL_SHOW", OnLFGProposalShow)
	K:UnregisterEvent("LFG_PROPOSAL_UPDATE", OnLFGProposalUpdate)
	K:UnregisterEvent("LFG_PROPOSAL_SUCCEEDED", OnLFGProposalEnded)
	K:UnregisterEvent("LFG_PROPOSAL_DONE", OnLFGProposalEnded)
	K:UnregisterEvent("LFG_PROPOSAL_FAILED", OnLFGProposalEnded)
	K:UnregisterEvent("UPDATE_BATTLEFIELD_STATUS", OnBattlefieldStatus)

	remainingPvETime = 0
	activePvPIndex = nil
	StopTicker()
end

function Module:CreateQueueTimers()
	if not IsEnabled() then
		Module:DisableQueueTimers()
		return
	end

	if queueTimersActive then
		return
	end

	queueTimersActive = true
	InstallHooks()

	K:RegisterEvent("LFG_PROPOSAL_SHOW", OnLFGProposalShow)
	K:RegisterEvent("LFG_PROPOSAL_UPDATE", OnLFGProposalUpdate)
	K:RegisterEvent("LFG_PROPOSAL_SUCCEEDED", OnLFGProposalEnded)
	K:RegisterEvent("LFG_PROPOSAL_DONE", OnLFGProposalEnded)
	K:RegisterEvent("LFG_PROPOSAL_FAILED", OnLFGProposalEnded)
	K:RegisterEvent("UPDATE_BATTLEFIELD_STATUS", OnBattlefieldStatus)

	C_Timer_After(0, BootstrapActiveQueues)
end

Module:RegisterMisc("QueueTimer", Module.CreateQueueTimers)
