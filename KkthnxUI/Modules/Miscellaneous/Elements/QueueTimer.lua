local K, C = unpack(KkthnxUI)
local Module = K:GetModule("Miscellaneous")

-- Sourced: syndenbock (JustInTime)
-- Edited: Kkthnx (KkthnxUI)

local RESETS_IN = RESETS_IN
local LFGDungeonReadyDialog = LFGDungeonReadyDialog

local function ColorQueueTimer(value)
	local r, g, b

	if value < 10 then
		r, g, b = 1, 0, 0
	elseif value < 15 then
		r, g, b = 1, 0.65, 0
	elseif value < 25 then
		r, g, b = 1, 0.96, 0
	elseif value < 35 then
		r, g, b = 0.17, 0.73, 0
	else
		r, g, b = 0.17, 0.73, 0
	end

	return K.RGBToHex(r, g, b) .. SecondsToTime(value)
end

-- PvE
function Module:SetupPvEQueueTimer()
	local pveUpdateFrame = CreateFrame("Frame", "KKUI_PvEUpdateFrame")
	local pveUpdateInterval = 0.2
	local pveRemaining = 0
	local pveUpdateTimeStamp

	-- The text of the LFG dialog label randomly changes back, so we override the function to prevent that
	local pveUpdateLFGDialogLabel = LFGDungeonReadyDialog.label.SetText
	LFGDungeonReadyDialog.label.SetText = K.Noop

	LFGDungeonReadyDialog.label:SetPoint("TOP", 0, -22)
	LFGDungeonReadyDialog.label:SetFontObject(K.UIFont)
	LFGDungeonReadyDialog.label:SetFont(select(1, LFGDungeonReadyDialog.label:GetFont()), 13, select(3, LFGDungeonReadyDialog.label:GetFont()))

	local function OnShowPvETimer()
		-- I didn't find a function to check if the dialog is still displayed, so we stop updating after the time is over
		if pveRemaining > 0 then
			pveUpdateLFGDialogLabel(LFGDungeonReadyDialog.label, RESETS_IN .. ": " .. ColorQueueTimer(pveRemaining))
		else
			pveUpdateFrame:SetScript("OnUpdate", nil)
			pveUpdateTimeStamp = nil
		end
	end

	local function OnUpdatePvETimer(_, elapsed)
		pveUpdateTimeStamp = pveUpdateTimeStamp + elapsed

		if pveUpdateTimeStamp < pveUpdateInterval then
			return
		end

		pveRemaining = pveRemaining - pveUpdateTimeStamp
		pveUpdateTimeStamp = 0
		OnShowPvETimer()
	end

	K:RegisterEvent("LFG_PROPOSAL_SHOW", function()
		pveRemaining = 40
		pveUpdateTimeStamp = 0
		pveUpdateFrame:SetScript("OnUpdate", OnUpdatePvETimer)
	end)
end

-- PvP
function Module:SetupPvPQueueTimer()
	local pvpUpdateFrame = CreateFrame("Frame", "KKUI_PvPUpdateFrame")
	local pvpUpdateInterval = 0.2
	local pvpupdateTimeStamp
	local pvpQueue

	PVPReadyDialog.label:SetPoint("TOP", 0, -22)
	PVPReadyDialog.label:SetFontObject(K.UIFont)
	PVPReadyDialog.label:SetFont(select(1, PVPReadyDialog.label:GetFont()), 13, select(3, PVPReadyDialog.label:GetFont()))

	local function OnShowPVPTimer()
		if PVPReadyDialog_Showing(pvpQueue) then
			local seconds = GetBattlefieldPortExpiration(pvpQueue)

			if seconds and seconds > 0 then
				PVPReadyDialog.label:SetText(RESETS_IN .. ": " .. ColorQueueTimer(seconds))
			end
		else
			pvpQueue = nil
			pvpupdateTimeStamp = nil
			pvpUpdateFrame:SetScript("OnUpdate", nil)
		end
	end

	local function OnUpdatePvPTimer(_, elapsed)
		pvpupdateTimeStamp = pvpupdateTimeStamp + elapsed

		if pvpupdateTimeStamp < pvpUpdateInterval then
			return
		end

		pvpupdateTimeStamp = 0
		OnShowPVPTimer()
	end

	local function HandlePVPQueuePop(index)
		pvpQueue = index

		OnShowPVPTimer()
		pvpupdateTimeStamp = 0
		pvpUpdateFrame:SetScript("OnUpdate", OnUpdatePvPTimer)
	end

	K:RegisterEvent("UPDATE_BATTLEFIELD_STATUS", function(_, index)
		if GetBattlefieldStatus(index) == "confirm" then
			HandlePVPQueuePop(index)
		end
	end)
end

function Module:CreateQueueTimers()
	if not C["Misc"].QueueTimers then
		return
	end

	Module:SetupPvEQueueTimer() -- PvE
	Module:SetupPvPQueueTimer() -- PvP
end

Module:RegisterMisc("QueueTimer", Module.CreateQueueTimers)
