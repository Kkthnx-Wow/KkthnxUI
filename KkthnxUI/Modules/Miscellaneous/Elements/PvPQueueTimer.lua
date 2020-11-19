local K, C = unpack(select(2, ...))
local Module = K:GetModule("Miscellaneous")

local _G = _G

local CreateFrame = _G.CreateFrame
local GetTime = _G.GetTime
local IsAddOnLoaded = _G.IsAddOnLoaded

-- Queue timer on LFGDungeonReadyDialog

local PvPReadyDialogTimer = CreateFrame("Frame", nil, _G.PVPReadyDialog)
PvPReadyDialogTimer:SetPoint("TOP", _G.PVPReadyDialog, "BOTTOM", 0, -4)
PvPReadyDialogTimer:SetSize(240, 14)
PvPReadyDialogTimer:CreateBorder()

PvPReadyDialogTimer.StatusBar = CreateFrame("StatusBar", nil, PvPReadyDialogTimer)
PvPReadyDialogTimer.StatusBar:SetStatusBarTexture(K.GetTexture(C["UITextures"].GeneralTextures))
PvPReadyDialogTimer.StatusBar:SetAllPoints()
PvPReadyDialogTimer.StatusBar:SetFrameLevel(_G.PVPReadyDialog:GetFrameLevel() + 1)
PvPReadyDialogTimer.StatusBar:SetStatusBarColor(1, 0.7, 0)

PvPReadyDialogTimer.StatusBar.Spark = PvPReadyDialogTimer.StatusBar:CreateTexture(nil, "OVERLAY")
PvPReadyDialogTimer.StatusBar.Spark:SetTexture(C["Media"].Spark_128)
PvPReadyDialogTimer.StatusBar.Spark:SetSize(64, PvPReadyDialogTimer:GetHeight())
PvPReadyDialogTimer.StatusBar.Spark:SetBlendMode("ADD")

_G.PVPReadyDialog.nextUpdate = 0
local function Update_PvPQueueTimer()
	local object = _G.PVPReadyDialog
	local oldTime = GetTime()
	local flag = 0
	local duration = 90
	local interval = 0.1

	object:SetScript("OnUpdate", function(_, elapsed)
		object.nextUpdate = object.nextUpdate + elapsed
		if object.nextUpdate > interval then
			local newTime = GetTime()
			if (newTime - oldTime) < duration then
				local width = PvPReadyDialogTimer:GetWidth() * (newTime - oldTime) / duration
				PvPReadyDialogTimer.StatusBar:SetPoint("BOTTOMRIGHT", PvPReadyDialogTimer, 0 - width, 0)
				PvPReadyDialogTimer.StatusBar.Spark:SetPoint("CENTER", PvPReadyDialogTimer.StatusBar:GetStatusBarTexture(), "RIGHT", 0, 0)
				flag = flag + 1
				if flag >= 10 then
					flag = 0
				end
			else
				object:SetScript("OnUpdate", nil)
			end
			object.nextUpdate = 0
		end
	end)
end

local function Setup_PvPQueueTimer()
	if PVPReadyDialog:IsShown() then
		Update_PvPQueueTimer()
	end
end

-- This is an important QoL addition.
function Module:CreatePvPQueueTimer()
	K:RegisterEvent("UPDATE_BATTLEFIELD_STATUS", Setup_PvPQueueTimer)
end