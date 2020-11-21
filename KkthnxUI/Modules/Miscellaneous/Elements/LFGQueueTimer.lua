local K, C = unpack(select(2, ...))
local Module = K:GetModule("Miscellaneous")

local _G = _G

local CreateFrame = _G.CreateFrame
local GetTime = _G.GetTime
local IsAddOnLoaded = _G.IsAddOnLoaded

-- Queue timer on LFGDungeonReadyDialog

local LFGReadyDialogTimer = CreateFrame("Frame", nil, _G.LFGDungeonReadyDialog)
LFGReadyDialogTimer:SetPoint("TOP", _G.LFGDungeonReadyDialog, "BOTTOM", 0, -4)
LFGReadyDialogTimer:SetSize(240, 14)
LFGReadyDialogTimer:CreateBorder()

LFGReadyDialogTimer.StatusBar = CreateFrame("StatusBar", nil, LFGReadyDialogTimer)
LFGReadyDialogTimer.StatusBar:SetStatusBarTexture(K.GetTexture(C["UITextures"].GeneralTextures))
LFGReadyDialogTimer.StatusBar:SetAllPoints()
LFGReadyDialogTimer.StatusBar:SetFrameLevel(_G.LFGDungeonReadyDialog:GetFrameLevel() + 1)
LFGReadyDialogTimer.StatusBar:SetStatusBarColor(1, 0.7, 0)

LFGReadyDialogTimer.StatusBar.Spark = LFGReadyDialogTimer.StatusBar:CreateTexture(nil, "OVERLAY")
LFGReadyDialogTimer.StatusBar.Spark:SetTexture(C["Media"].Spark_128)
LFGReadyDialogTimer.StatusBar.Spark:SetSize(64, LFGReadyDialogTimer:GetHeight())
LFGReadyDialogTimer.StatusBar.Spark:SetBlendMode("ADD")

_G.LFGDungeonReadyDialog.nextUpdate = 0
local function Update_LFGQueueTimer()
	local object = _G.LFGDungeonReadyDialog
	local oldTime = GetTime()
	local flag = 0
	local duration = 40
	local interval = 0.1

	object:SetScript("OnUpdate", function(_, elapsed)
		object.nextUpdate = object.nextUpdate + elapsed
		if object.nextUpdate > interval then
			local newTime = GetTime()
			if (newTime - oldTime) < duration then
				local width = LFGReadyDialogTimer:GetWidth() * (newTime - oldTime) / duration
				LFGReadyDialogTimer.StatusBar:SetPoint("BOTTOMRIGHT", LFGReadyDialogTimer, 0 - width, 0)
				LFGReadyDialogTimer.StatusBar.Spark:SetPoint("CENTER", LFGReadyDialogTimer.StatusBar:GetStatusBarTexture(), "RIGHT", 0, 0)
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

local function Setup_LFGQueueTimer()
	if LFGDungeonReadyDialog:IsShown() then
		Update_LFGQueueTimer()
	end
end

-- No config option for this as this will be disabled if replaced by one of the 2 addons that provide this.
-- This is an important QoL addition.
function Module:CreateLFGQueueTimer()
	if not IsAddOnLoaded("DBM-Core") or not IsAddOnLoaded("BigWigs") then
		K:RegisterEvent("LFG_PROPOSAL_SHOW", Setup_LFGQueueTimer)
	else
		K:UnregisterEvent("LFG_PROPOSAL_SHOW", Setup_LFGQueueTimer)
	end
end