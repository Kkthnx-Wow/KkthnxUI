local K, C, L = unpack(select(2, ...))

-- WoW Lua
local _G = _G
local select = select
local tostring = tostring
local unpack = unpack

-- Wow API
local GetBattlefieldStatus = _G.GetBattlefieldStatus
local GetCVar = _G.GetCVar
local GetCVarBool = _G.GetCVarBool
local GetLFGDungeonInfo = _G.GetLFGDungeonInfo
local GetLFGDungeonRewards = _G.GetLFGDungeonRewards
local GetLFGRandomDungeonInfo = _G.GetLFGRandomDungeonInfo
local GetMaxBattlefieldID = _G.GetMaxBattlefieldID
local GetNumRandomDungeons = _G.GetNumRandomDungeons
local GetZoneText = _G.GetZoneText
local hooksecurefunc = _G.hooksecurefunc
local IsInInstance = _G.IsInInstance
local IsInRaid = _G.IsInRaid
local PlaySound = _G.PlaySound
local PlaySoundFile = _G.PlaySoundFile
local SetCVar = _G.SetCVar

-- GLOBALS: TicketStatusFrame, HelpOpenTicketButton, HelpOpenWebTicketButton, Minimap, GMMover, UIParent
-- GLOBALS: TalkingHeadFrame, LFDQueueFrame_SetType, L_ZONE_ARATHIBASIN, L_ZONE_GILNEAS, AuctionFrame
-- GLOBALS: SideDressUpModel, SideDressUpModelResetButton, DressUpModel, DressUpFrameResetButton
-- GLOBALS: GhostFrame, LevelUpDisplay, BossBanner, statusBar, UIErrorsFrame, COMBAT, RaidNotice_AddMessage
-- GLOBALS: RaidBossEmoteFrame, ChatTypeInfo

local Movers = K.Movers

-- Fix UIErrorsFrame framelevel
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

-- Move some frames (Elvui)
local TicketStatusMover = CreateFrame("Frame", "TicketStatusMoverAnchor", UIParent)
TicketStatusMover:SetPoint(unpack(C.Position.Ticket))
TicketStatusMover:SetSize(200, 40)
Movers:RegisterFrame(TicketStatusMover)

local TicketFrame = CreateFrame("Frame")
TicketFrame:RegisterEvent("PLAYER_LOGIN")
TicketFrame:SetScript("OnEvent", function(self, event)
	TicketStatusFrame:ClearAllPoints()
	TicketStatusFrame:SetPoint(unpack(C.Position.Ticket))
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

-- Display combat state changes
local CombatState = CreateFrame("Frame")
CombatState:RegisterEvent("PLAYER_REGEN_ENABLED")
CombatState:RegisterEvent("PLAYER_REGEN_DISABLED")
CombatState:SetScript("OnEvent", function(self, event)
	if not C.Misc.CombatState then return end
	if event == "PLAYER_REGEN_DISABLED" then
		UIErrorsFrame:AddMessage("+ " .. COMBAT, 1, 1, 1)
	elseif event == "PLAYER_REGEN_DISABLED" then
		UIErrorsFrame:AddMessage("- " .. COMBAT, 1, 1, 1)
	end
end)

-- Display battleground messages in the middle of the screen.
local PVPMessageEnhancement = CreateFrame("Frame")
PVPMessageEnhancement:RegisterEvent("CHAT_MSG_BG_SYSTEM_HORDE")
PVPMessageEnhancement:RegisterEvent("CHAT_MSG_BG_SYSTEM_ALLIANCE")
PVPMessageEnhancement:RegisterEvent("CHAT_MSG_BG_SYSTEM_NEUTRAL")
PVPMessageEnhancement:SetScript("OnEvent", function(self, _, msg)
	if not C.Misc.EnhancedPvpMessages then return end
	local _, instanceType = IsInInstance()
	if instanceType == "pvp" or instanceType == "arena" then
		RaidNotice_AddMessage(RaidBossEmoteFrame, msg, ChatTypeInfo["RAID_BOSS_EMOTE"])
	end
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
ForceCVar:RegisterEvent("PLAYER_ENTERING_WORLD")
ForceCVar:RegisterEvent("CVAR_UPDATE")
ForceCVar:SetScript("OnEvent", function(self, event)
	if event == "PLAYER_ENTERING_WORLD" then
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	end

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

-- Remove boss emote spam during bg(ArathiBasin SpamFix by Partha)
if C.Misc.BGSpam == true then
	local Fixer = CreateFrame("Frame")
	local RaidBossEmoteFrame, spamDisabled = RaidBossEmoteFrame

	local function DisableSpam()
		if GetZoneText() == L.Zone.ArathiBasin or GetZoneText() == L.Zone.Gilneas then
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