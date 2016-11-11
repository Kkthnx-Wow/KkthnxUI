local K, C, L = select(2, ...):unpack()

-- I NEED TO CLEAN THIS FILE UP.
local _G = _G
local unpack = unpack
local PlaySound, PlaySoundFile = PlaySound, PlaySoundFile
local hooksecurefunc = hooksecurefunc
local CreateFrame = CreateFrame
local GetBattlefieldStatus = GetBattlefieldStatus
local GetZoneText = GetZoneText
local GetLFGDungeonRewards = GetLFGDungeonRewards
local GetLFGDungeonInfo = GetLFGDungeonInfo
local GetLFGRandomDungeonInfo = GetLFGRandomDungeonInfo
local GetNumRandomDungeons = GetNumRandomDungeons
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

TicketStatusFrame:ClearAllPoints()
TicketStatusFrame:SetPoint(unpack(C.Position.Ticket))
-- Blizzard repositions this frame now in UIParent_UpdateTopFramePositions
hooksecurefunc(TicketStatusFrame, "SetPoint", function(self, _, anchor)
	if anchor == UIParent then
		TicketStatusFrame:ClearAllPoints()
		TicketStatusFrame:SetPoint(unpack(C.Position.Ticket))
	end
end)

UIErrorsFrame:ClearAllPoints()
UIErrorsFrame:SetPoint(unpack(C.Position.UIError))
UIErrorsFrame:SetFrameLevel(0)

RaidBossEmoteFrame:ClearAllPoints()
RaidBossEmoteFrame:SetPoint("TOP", UIParent, "TOP", 0, -200)
RaidBossEmoteFrame:SetScale(0.9)

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
ForceCVar:RegisterEvent("PLAYER_ENTERING_WORLD")
ForceCVar:RegisterEvent("CVAR_UPDATE")
ForceCVar:SetScript("OnEvent", function(self, event)
	if not GetCVarBool("lockActionBars") and C.ActionBar.Enable then
		SetCVar("lockActionBars", 1)
	end

	ForceCVar:UnregisterEvent("PLAYER_ENTERING_WORLD")
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

-- Custom lag tolerance(By Elv22)
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

-- Undress button in auction dress-up frame(by Nefarion)
local strip = CreateFrame("Button", "DressUpFrameUndressButton", DressUpFrame, "UIPanelButtonTemplate")
strip:SetText(L_MISC_UNDRESS)
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