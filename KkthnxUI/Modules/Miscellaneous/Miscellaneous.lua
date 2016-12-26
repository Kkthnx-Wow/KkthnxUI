local K, C, L = unpack(select(2, ...))

-- WoW Lua
local select = select
local tostring = tostring
local unpack = unpack

-- Wow API
local GetBattlefieldStatus = GetBattlefieldStatus
local GetCVar = GetCVar
local GetCVarBool = GetCVarBool
local GetLFGDungeonInfo = GetLFGDungeonInfo
local GetLFGDungeonRewards = GetLFGDungeonRewards
local GetLFGRandomDungeonInfo = GetLFGRandomDungeonInfo
local GetMaxBattlefieldID = GetMaxBattlefieldID
local GetNumRandomDungeons = GetNumRandomDungeons
local GetZoneText = GetZoneText
local hooksecurefunc = hooksecurefunc
local PlaySound = PlaySound
local PlaySoundFile = PlaySoundFile
local SetCVar = SetCVar
local IsInRaid = IsInRaid

-- GLOBALS: TicketStatusFrame, HelpOpenTicketButton, HelpOpenWebTicketButton, Minimap, GMMover, UIParent
-- GLOBALS: TalkingHeadFrame, LFDQueueFrame_SetType, L_ZONE_ARATHIBASIN, L_ZONE_GILNEAS, AuctionFrame
-- GLOBALS: SideDressUpModel, SideDressUpModelResetButton, DressUpModel, DressUpFrameResetButton
-- GLOBALS: GhostFrame, LevelUpDisplay, BossBanner, statusBar

local Movers = K.Movers

-- Fix frame level for UIErrorsFrame
UIErrorsFrame:SetFrameLevel(0)

-- Skin return to graveyard button(Elvui)
do
	GhostFrame:StripTextures()
	GhostFrame:SkinButton()
	GhostFrame:SetBackdropColor(0, 0, 0, 0)
	GhostFrame:SetBackdropBorderColor(0, 0, 0, 0)
	local function forceBackdropColor(self, r, g, b, a)
		if r ~= 0 or g ~= 0 or b ~= 0 or a ~= 0 then
			GhostFrame:SetBackdropColor(0, 0, 0, 0)
			GhostFrame:SetBackdropBorderColor(0, 0, 0, 0)
		end
	end
	hooksecurefunc(GhostFrame, "SetBackdropColor", forceBackdropColor)
	hooksecurefunc(GhostFrame, "SetBackdropBorderColor", forceBackdropColor)
	GhostFrame:ClearAllPoints()
	GhostFrame:SetPoint("TOP", UIParent, "TOP", 0, -270)
	GhostFrameContentsFrameIcon:SetTexture(nil)
	local x = CreateFrame("Frame", nil, GhostFrame)
	x:SetFrameStrata("MEDIUM")
	x:CreateBackdrop()
	x:SetOutside(GhostFrameContentsFrameIcon)
	local tex = x:CreateTexture(nil, "OVERLAY")
	tex:SetTexture("Interface\\Icons\\spell_holy_guardianspirit")
	tex:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	tex:SetInside()
end

-- Move some frames (Shestak)
local HeadFrame = CreateFrame("Frame")
HeadFrame:RegisterEvent("ADDON_LOADED")
HeadFrame:SetScript("OnEvent", function(self, event, addon)
	if (addon == "Blizzard_TalkingHeadUI") then
		TalkingHeadFrame.ignoreFramePositionManager = true
		TalkingHeadFrame:ClearAllPoints()
		TalkingHeadFrame:SetPoint(unpack(C.Position.TalkingHead))
	end

	if event == ("ADDON_LOADED") then
		self:UnregisterEvent("ADDON_LOADED")
	end
end)

-- Move some frames (Elvui)
local TicketStatusMover = CreateFrame("Frame", "TicketStatusMoverAnchor", UIParent)
TicketStatusMover:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 250, -6)
TicketStatusMover:SetSize(200, 40)
Movers:RegisterFrame(TicketStatusMover)

local TicketFrame = CreateFrame("Frame")
TicketFrame:RegisterEvent("PLAYER_LOGIN")
TicketFrame:SetScript("OnEvent", function(self, event)
	TicketStatusFrame:ClearAllPoints()
	TicketStatusFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 250, -5)
	-- Blizzard repositions this frame now in UIParent_UpdateTopFramePositions
	hooksecurefunc(TicketStatusFrame, "SetPoint", function(self, _, anchor)
		if anchor == UIParent then
			TicketStatusFrame:ClearAllPoints()
			TicketStatusFrame:SetPoint("TOPLEFT", TicketStatusMover, 0, 0)
		end
	end)
end)

-- LevelUp + BossBanner Mover
local LBBMover = CreateFrame("Frame", "LevelUpBossBannerHolder", UIParent)
LBBMover:SetSize(200, 20)
LBBMover:SetPoint("TOP", UIParent, "TOP", 0, -120)

local LevelUpBossBanner = CreateFrame("Frame")
LevelUpBossBanner:RegisterEvent("PLAYER_LOGIN")
LevelUpBossBanner:SetScript("OnEvent", function(self, event)
	Movers:RegisterFrame(LBBMover)

	local function Reanchor(frame, _, anchor)
		if anchor ~= LBBMover then
			frame:ClearAllPoints()
			frame:SetPoint("TOP", LBBMover)
		end
	end

	-- Level Up Display
	LevelUpDisplay:ClearAllPoints()
	LevelUpDisplay:SetPoint("TOP", LBBMover)
	hooksecurefunc(LevelUpDisplay, "SetPoint", Reanchor)

	-- Boss Banner
	BossBanner:ClearAllPoints()
	BossBanner:SetPoint("TOP", LBBMover)
	hooksecurefunc(BossBanner, "SetPoint", Reanchor)
end)

-- Force readycheck warning
local ShowReadyCheckHook = function(self, initiator)
	if initiator ~= "player" then
		PlaySound("ReadyCheck", "Master")
	end
end
hooksecurefunc("ShowReadyCheck", ShowReadyCheckHook)

-- Force lockActionBars CVar
local ForceCVar = CreateFrame("Frame")
ForceCVar:RegisterEvent("PLAYER_LOGIN")
ForceCVar:RegisterEvent("CVAR_UPDATE")
ForceCVar:SetScript("OnEvent", function(self, event)
	if not GetCVarBool("lockActionBars") and C.ActionBar.Enable then
		SetCVar("lockActionBars", 1)
	end
end)

-- Force other warning
local ForceWarning = CreateFrame("Frame")
ForceWarning:RegisterEvent("UPDATE_BATTLEFIELD_STATUS")
ForceWarning:RegisterEvent("PET_BATTLE_QUEUE_PROPOSE_MATCH")
ForceWarning:RegisterEvent("LFG_PROPOSAL_SHOW")
ForceWarning:RegisterEvent("RESURRECT_REQUEST")
ForceWarning:SetScript("OnEvent", function(self, event)
	if event == "UPDATE_BATTLEFIELD_STATUS" then
		for i = 1, GetMaxBattlefieldID() do
			local status = GetBattlefieldStatus(i)
			if status == "confirm" then
				PlaySound("PVPTHROUGHQUEUE", "Master")
				break
			end
		end
	elseif event == "PET_BATTLE_QUEUE_PROPOSE_MATCH" then
		PlaySound("PVPTHROUGHQUEUE", "Master")
	elseif event == "LFG_PROPOSAL_SHOW" then
		PlaySound("ReadyCheck", "Master")
	elseif event == "RESURRECT_REQUEST" then
		PlaySoundFile([[Sound\Spells\Resurrection.wav]], "Master")
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

-- Custom lag tolerance
if C.General.CustomLagTolerance == true then
	local customlag = CreateFrame("Frame")
	local int = 5
	local _, _, _, lag = GetNetStats()
	local LatencyUpdate = function(self, elapsed)
		int = int - elapsed
		if int < 0 then
			if GetCVar("reducedLagTolerance") ~= tostring(1) then SetCVar("reducedLagTolerance", tostring(1)) end
			if lag ~= 0 and lag <= 400 then
				SetCVar("maxSpellStartRecoveryOffset", tostring(lag))
			end
			int = 5
		end
	end
	customlag:SetScript("OnUpdate", LatencyUpdate)
	LatencyUpdate(customlag, 10)
end

-- Remove boss emote spam during bg(ArathiBasin SpamFix by Partha)
if C.Misc.BGSpam == true then
	local Fixer = CreateFrame("Frame")
	local RaidBossEmoteFrame, spamDisabled = RaidBossEmoteFrame

	local function DisableSpam()
		if GetZoneText() == L_ZONE_ARATHIBASIN or GetZoneText() == L_ZONE_GILNEAS then
			RaidBossEmoteFrame:UnregisterEvent("RAID_BOSS_EMOTE")
			spamDisabled = true
		elseif spamDisabled then
			RaidBossEmoteFrame:RegisterEvent("RAID_BOSS_EMOTE")
			spamDisabled = false
		end
	end

	Fixer:RegisterEvent("PLAYER_ENTERING_WORLD")
	Fixer:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	Fixer:SetScript("OnEvent", DisableSpam)
end

-- Boss Banner Hider
if C.Misc.NoBanner == true then
	BossBanner.PlayBanner = function() end
end

--	Hide TalkingHeadFrame
if C.Misc.HideTalkingHead == true then
	local HideTalkingHead = CreateFrame("Frame")
	HideTalkingHead:RegisterEvent("ADDON_LOADED")
	HideTalkingHead:SetScript("OnEvent", function(self, event, addon)
		if addon == "Blizzard_TalkingHeadUI" then
			hooksecurefunc("TalkingHeadFrame_PlayCurrent", function()
				TalkingHeadFrame:Hide()
			end)

			if event == ("ADDON_LOADED") then
				self:UnregisterEvent("ADDON_LOADED")
			end
		end
	end)
end

-- Disable QuestTrackingTooltips while in raid and in combat
-- This can become a spam fest when you have 20+ people on the same quest!
local QuestTracking = CreateFrame("Frame")
QuestTracking:RegisterEvent("PLAYER_ENTERING_WORLD")
QuestTracking:RegisterEvent("GROUP_ROSTER_UPDATE")
QuestTracking:SetScript("OnEvent", function(self, event)
	if event == ("PLAYER_ENTERING_WORLD") then
		local _, instanceType = IsInInstance()
		if instanceType == "raid" then
			SetCVar("showQuestTrackingTooltips", 0)
		else
			SetCVar("showQuestTrackingTooltips", 1)
		end
	end
end)