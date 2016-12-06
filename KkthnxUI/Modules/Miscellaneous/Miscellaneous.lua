local K, C, L = select(2, ...):unpack()

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

-- GLOBALS: TicketStatusFrame, HelpOpenTicketButton, HelpOpenWebTicketButton, Minimap, GMMover, UIParent
-- GLOBALS: TalkingHeadFrame, LFDQueueFrame_SetType, L_ZONE_ARATHIBASIN, L_ZONE_GILNEAS, AuctionFrame
-- GLOBALS: SideDressUpModel, SideDressUpModelResetButton, DressUpModel, DressUpFrameResetButton

local Movers = K.Movers

-- Move some frames (Shestak)
local HeadFrame = CreateFrame("Frame")
HeadFrame:RegisterEvent("ADDON_LOADED")
HeadFrame:SetScript("OnEvent", function(self, event, addon)
	if (addon == "Blizzard_TalkingHeadUI") then
		TalkingHeadFrame.ignoreFramePositionManager = true
		TalkingHeadFrame:ClearAllPoints()
		TalkingHeadFrame:SetPoint(unpack(C.Position.TalkingHead))
		TalkingHeadFrame:SetScale(.80)
	end
end)

-- Move some frames (Elvui)
local TicketStatusMover = CreateFrame("Frame", "TicketStatusMoverAnchor", UIParent)
TicketStatusMover:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 250, -6)
TicketStatusMover:SetSize(TicketStatusFrame:GetWidth(), TicketStatusFrame:GetHeight())
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
			TicketStatusFrame:SetPoint("TOPLEFT", GMMover, 0, 0)
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

local PVPMessageEnhancement = CreateFrame("Frame")
PVPMessageEnhancement:RegisterEvent("CHAT_MSG_BG_SYSTEM_HORDE")
PVPMessageEnhancement:RegisterEvent("CHAT_MSG_BG_SYSTEM_ALLIANCE")
PVPMessageEnhancement:RegisterEvent("CHAT_MSG_BG_SYSTEM_NEUTRAL")
PVPMessageEnhancement:SetScript("OnEvent", function(self, event)
	-- if C.Misc.EnhancedPvPMessages ~= true then return end
	local _, instanceType = IsInInstance()
	if instanceType == "pvp" or instanceType == "arena" then
		RaidNotice_AddMessage(RaidBossEmoteFrame, msg, ChatTypeInfo["RAID_BOSS_EMOTE"])
	end
end)

-- Move and scale UIErrorsFrame
UIErrorsFrame:ClearAllPoints()
UIErrorsFrame:SetPoint(unpack(C.Position.UIError))
UIErrorsFrame:SetFrameLevel(0)

-- Move and scale RaidBossEmoteFrame
RaidBossEmoteFrame:ClearAllPoints()
RaidBossEmoteFrame:SetPoint("TOP", UIParent, "TOP", 0, -200)
RaidBossEmoteFrame:SetScale(0.9)

-- Move and scale RaidWarningFrame
RaidWarningFrame:ClearAllPoints()
RaidWarningFrame:SetPoint("TOP", UIParent, "TOP", 0, -260)
RaidWarningFrame:SetScale(0.8)

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
ForceWarning:RegisterEvent("BATTLEFIELD_MGR_ENTRY_INVITE")
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
			i = i + 1
		end
	elseif event == "BATTLEFIELD_MGR_ENTRY_INVITE" then
		PlaySound("PVPTHROUGHQUEUE", "Master")
	elseif event == "PET_BATTLE_QUEUE_PROPOSE_MATCH" then
		PlaySound("PVPTHROUGHQUEUE", "Master")
	elseif event == "LFG_PROPOSAL_SHOW" then
		PlaySound("ReadyCheck", "Master")
	elseif event == "RESURRECT_REQUEST" then
		PlaySoundFile("Sound\\Spells\\Resurrection.wav", "Master")
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
	local CustomLagTolerance = CreateFrame("Frame")
	CustomLagTolerance:SetScript("OnEvent", function(self, event)
		local down, up, lagHome, lagWorld = GetNetStats()
		SetCVar("ReducedLagTolerance", 1)
		SetCVar("MaxSpellStartRecoveryOffset", lagWorld)
	end)
	CustomLagTolerance:RegisterEvent("ZONE_CHANGED")
	CustomLagTolerance:RegisterEvent("ADDON_LOADED")
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
if C.Automation.NoBanner == true then
	BossBanner.PlayBanner = function() end
end

-- Undress button in auction dress-up frame(by Nefarion)
local strip = CreateFrame("Button", "DressUpFrameUndressButton", DressUpFrame, "UIPanelButtonTemplate")
strip:SetText(L.Misc.Undress)
strip:SetHeight(22)
strip:SetWidth(strip:GetTextWidth() + 40)
strip:SetPoint("RIGHT", DressUpFrameResetButton, "LEFT", -2, 0)
strip:RegisterForClicks("AnyUp")
strip:SetScript("OnClick", function(self, button)
	if button == "RightButton" then
		self.model:UndressSlot(19)
	else
		self.model:Undress()
	end
	PlaySound("gsTitleOptionOK")
end)
strip.model = DressUpModel

strip:RegisterEvent("AUCTION_HOUSE_SHOW")
strip:RegisterEvent("AUCTION_HOUSE_CLOSED")
strip:SetScript("OnEvent", function(self)
	if AuctionFrame:IsVisible() and self.model ~= SideDressUpModel then
		self:SetParent(SideDressUpModel)
		self:ClearAllPoints()
		self:SetPoint("TOP", SideDressUpModelResetButton, "BOTTOM", 0, -3)
		self.model = SideDressUpModel
	elseif self.model ~= DressUpModel then
		self:SetParent(DressUpModel)
		self:ClearAllPoints()
		self:SetPoint("RIGHT", DressUpFrameResetButton, "LEFT", -2, 0)
		self.model = DressUpModel
	end
end)