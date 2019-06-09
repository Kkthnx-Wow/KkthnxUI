local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("Miscellaneous", "AceEvent-3.0", "AceHook-3.0")

local _G = _G
local select = select

local CreateFrame = _G.CreateFrame
local GetBattlefieldStatus = _G.GetBattlefieldStatus
local GetCVarBool = _G.GetCVarBool
local GetLFGDungeonInfo = _G.GetLFGDungeonInfo
local GetLFGDungeonRewards = _G.GetLFGDungeonRewards
local GetLFGRandomDungeonInfo = _G.GetLFGRandomDungeonInfo
local GetMaxBattlefieldID = _G.GetMaxBattlefieldID
local GetNetStats = _G.GetNetStats
local GetNumRandomDungeons = _G.GetNumRandomDungeons
local GetZoneText = _G.GetZoneText
local hooksecurefunc = _G.hooksecurefunc
local PlaySound = _G.PlaySound
local SOUNDKIT = _G.SOUNDKIT

local LatencyInterval
local MinLatency, MaxLatency
local OldLatency = -9999
local UpdatedCount = 0

local LagToleranceDefaults = {
	Offset = 0,
	Interval = 30,
	Threshold = 5,
	Min = nil,
	Max = nil,
}

local BATTLEGROUNDS = {
	["Wintergrasp"] = true,
	["Tol Barad"] = true,
	["Isle of Conquest"] = true,
	["Strand of the Ancients"] = true,
	["Alterac Valley"] = true,
	["Warsong Gulch"] = true,
	["Twin Peaks"] = true,
	["Arathi Basin"] = true,
	["Eye of the Storm"] = true,
	["Battle for Gilneas"] = true,
	["Deepwind Gorge"] = true,
	["Silvershard Mines"] = true,
	["The Battle for Gilneas"] = true,
	["Temple of Kotmogu"] = true
}

local LagToleranceTimer = CreateFrame("Frame")
LagToleranceTimer:Hide()

local LagToleranceEvents = CreateFrame("Frame")
LagToleranceEvents:RegisterEvent("VARIABLES_LOADED")

if C["General"].AutoScale then
	local scaleBtn = CreateFrame("Button", "KkthnxUIScaleBtn", Advanced_, "UIPanelButtonTemplate")
	scaleBtn:SetSize(200, 24)
	scaleBtn:SetText(L["Miscellaneous"].KkthnxUI_Scale_Button)
	scaleBtn:SetPoint("LEFT", Advanced_UseUIScale, "LEFT", 4, -70)
	scaleBtn:SetScript("OnClick", function()
		if (not KkthnxUIConfig) then
			K.Print(L["Miscellaneous"].Config_Not_Found)
			return
		end

		if (not KkthnxUIConfigFrame) then
			KkthnxUIConfig:CreateConfigWindow()
		end

		if KkthnxUIConfigFrame:IsVisible() then
			KkthnxUIConfigFrame:Hide()
		else
			HideUIPanel(VideoOptionsFrame)
			HideUIPanel(GameMenuFrame)
			KkthnxUIConfigFrame:Show()
		end
	end)
end

LagToleranceEvents:SetScript("OnEvent", function(self)
	if C["General"].LagTolerance ~= true then
		return
	end

	-- Get Min/Max latency values
	MinLatency = 0
	MaxLatency = 400

	-- Start timer
	LatencyInterval = 1
	LagToleranceTimer:Show()
end)

LagToleranceTimer:SetScript("OnUpdate", function(_, elapsed)
	if C["General"].LagTolerance ~= true then
		return
	end

	LatencyInterval = LatencyInterval - elapsed
	if LatencyInterval <= 0 then
		-- Get Latency
		local _, _, _, Latency = GetNetStats()
		if Latency ~= OldLatency then

			if not Latency then Latency = 0 end
			Latency = Latency + LagToleranceDefaults.Offset

			-- Set Latency to be within Min/Max boundaries
			if LagToleranceDefaults.Min then
				Latency = max(Latency, LagToleranceDefaults.Min)
			end

			if LagToleranceDefaults.Max then
				Latency = min(Latency, LagToleranceDefaults.Max)
			end

			if Latency < MinLatency then
				Latency = MinLatency
			end

			if Latency > MaxLatency then
				Latency = MaxLatency
			end

			-- If Latency changed and greater than the change threshold, then update
			if ((Latency < OldLatency) and ((Latency + LagToleranceDefaults.Threshold) <= OldLatency)) or ((Latency > OldLatency) and ((Latency - LagToleranceDefaults.Threshold) >= OldLatency)) then
				SetCVar("SpellQueueWindow", Latency)

				OldLatency = Latency
			end

			-- Search for first real Latency update, so we can find the beginning of GetNetStats()'s 30sec update cycle
			if UpdatedCount < 2 then
				UpdatedCount = UpdatedCount + 1
			end
		end

		-- Reset timer
		if UpdatedCount < 2 then
			-- Still looking for first real Latency update
			LatencyInterval = 1
		elseif UpdatedCount < 5 then
			-- Run 3 more passes at 1sec each, so we can get 3sec ahead of the GetNetStats() update cycle
			LatencyInterval = 1
			UpdatedCount = UpdatedCount + 1
		else
			-- Update cycle determined, set to normal updates from now on
			LatencyInterval = LagToleranceDefaults.Interval
		end
	end
end)

-- Force readycheck warning
local function ShowReadyCheckHook(_, initiator)
	if initiator ~= "player" then
		PlaySound(SOUNDKIT.READY_CHECK, "Master")
	end
end
hooksecurefunc("ShowReadyCheck", ShowReadyCheckHook)

-- Force lockActionBars CVar
local ForceActionBarCVar = CreateFrame("Frame")
ForceActionBarCVar:RegisterEvent("PLAYER_ENTERING_WORLD")
ForceActionBarCVar:RegisterEvent("CVAR_UPDATE")
ForceActionBarCVar:SetScript("OnEvent", function()
	if not GetCVarBool("lockActionBars") and C["ActionBar"].Enable then
		K.LockCVar("lockActionBars", 1)
	end
end)

-- Force other warnings
local ForceWarning = CreateFrame("Frame")
ForceWarning:RegisterEvent("UPDATE_BATTLEFIELD_STATUS")
ForceWarning:RegisterEvent("PET_BATTLE_QUEUE_PROPOSE_MATCH")
ForceWarning:RegisterEvent("LFG_PROPOSAL_SHOW")
ForceWarning:RegisterEvent("RESURRECT_REQUEST")
ForceWarning:SetScript("OnEvent", function(_, event)
	if event == "UPDATE_BATTLEFIELD_STATUS" then
		for i = 1, GetMaxBattlefieldID() do
			local status = GetBattlefieldStatus(i)
			if status == "confirm" then
				PlaySound(SOUNDKIT.UI_PET_BATTLES_PVP_THROUGH_QUEUE, "Master")
				break
			end
		end
	elseif event == "PET_BATTLE_QUEUE_PROPOSE_MATCH" then
		PlaySound(SOUNDKIT.UI_PET_BATTLES_PVP_THROUGH_QUEUE)
	elseif event == "LFG_PROPOSAL_SHOW" then
		PlaySound(SOUNDKIT.READY_CHECK, "Master")
	elseif event == "RESURRECT_REQUEST" then
		PlaySound(37, "Master")
	end
end)

-- Auto select current event boss from LFD tool(EventBossAutoSelect by Nathanyel)
local firstLFD
LFDParentFrame:HookScript("OnShow", function()
	if not firstLFD then
		firstLFD = 1
		for i = 1, GetNumRandomDungeons() do
			local id = GetLFGRandomDungeonInfo(i)
			local isHoliday = select(15, GetLFGDungeonInfo(id))
			if isHoliday and not GetLFGDungeonRewards(id) then
				LFDQueueFrame_SetType(id)
			end
		end
	end
end)

-- Remove boss emote spam during battlegrounds (ArathiBasin SpamFix by Partha)
local RaidBossEmoteFrame, spamDisabled = RaidBossEmoteFrame
function Module:ToggleBossEmotes()
	if BATTLEGROUNDS[GetZoneText()] then
		RaidBossEmoteFrame:UnregisterEvent("RAID_BOSS_EMOTE")
		spamDisabled = true
	elseif spamDisabled then
		RaidBossEmoteFrame:RegisterEvent("RAID_BOSS_EMOTE")
		spamDisabled = false
	end
end

function Module:OnEnable()
	if C["Misc"].BattlegroundSpam == true then
		self:RegisterEvent("PLAYER_ENTERING_WORLD", "ToggleBossEmotes")
		self:RegisterEvent("ZONE_CHANGED_NEW_AREA", "ToggleBossEmotes")
	end
end