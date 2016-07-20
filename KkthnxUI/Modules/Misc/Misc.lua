local K, C, L, _ = select(2, ...):unpack()

local _G = _G
local unpack = unpack
local PlaySound, PlaySoundFile = PlaySound, PlaySoundFile
local hooksecurefunc = hooksecurefunc
local CreateFrame = CreateFrame
local MAX_BATTLEFIELD_QUEUES = MAX_BATTLEFIELD_QUEUES
local GetBattlefieldStatus = GetBattlefieldStatus
local UnitIsAFK = UnitIsAFK
local GetZoneText = GetZoneText
local GetLFGDungeonRewards = GetLFGDungeonRewards
local GetLFGDungeonInfo = GetLFGDungeonInfo
local GetLFGRandomDungeonInfo = GetLFGRandomDungeonInfo
local GetNumRandomDungeons = GetNumRandomDungeons

DurabilityFrame:SetFrameStrata("HIGH")

local function SetPosition(self, _, parent)
	if (parent == "MinimapCluster") or (parent == _G["MinimapCluster"]) then
		DurabilityFrame:ClearAllPoints()
		DurabilityFrame:SetPoint("RIGHT", Minimap, "RIGHT")
		DurabilityFrame:SetScale(0.6)
	end
end
hooksecurefunc(DurabilityFrame,"SetPoint", SetPosition)

-- Move some frames (Shestak)
TicketStatusFrame:ClearAllPoints()
TicketStatusFrame:SetPoint(unpack(C.Position.Ticket))

MirrorTimer1:ClearAllPoints()
MirrorTimer1:SetPoint("TOP", UIParent, 0, -96)

UIErrorsFrame:ClearAllPoints()
UIErrorsFrame:SetPoint(unpack(C.Position.UIError))
UIErrorsFrame:SetFrameLevel(0)

RaidWarningFrame:ClearAllPoints()
RaidWarningFrame:SetPoint("TOP", UIParent, 0, -130)

WorldStateAlwaysUpFrame:ClearAllPoints()
WorldStateAlwaysUpFrame:SetPoint("TOP", UIParent, 0, -10)

hooksecurefunc("WorldStateAlwaysUpFrame_Update", function()
	for i = 1, NUM_ALWAYS_UP_UI_FRAMES do
		local frame = _G["AlwaysUpFrame"..i]

		if frame == AlwaysUpFrame1 then
			local _, _, _, _, y = frame:GetPoint()
			frame:SetPoint("TOP", WorldStateAlwaysUpFrame, "TOP", 0, 0)
		end

		local text = _G["AlwaysUpFrame"..i.."Text"]
		text:ClearAllPoints()
		text:SetPoint("CENTER", frame, "CENTER", 0, 0)
		text:SetJustifyH("CENTER")
		text:SetFont(C.Media.Font, C.Media.Font_Size)
		text:SetShadowOffset((K.Mult or 1), -(K.Mult or 1))

		local icon = _G["AlwaysUpFrame"..i.."Icon"]
		icon:ClearAllPoints()
		icon:SetPoint("RIGHT", text, "LEFT", 12, -8)

		local dynamicIcon = _G["AlwaysUpFrame"..i.."DynamicIconButton"]
		dynamicIcon:ClearAllPoints()
		dynamicIcon:SetPoint("LEFT", text, "RIGHT", 0, 0)
	end
end)

-- Vehicle Indicator
local VehicleAnchor = CreateFrame("Frame", "VehicleAnchor", UIParent)
VehicleAnchor:SetPoint(unpack(C.Position.Vehicle))
VehicleAnchor:SetSize(VehicleSeatIndicator:GetWidth(), VehicleSeatIndicator:GetHeight())

hooksecurefunc(VehicleSeatIndicator, "SetPoint", function(_, _, parent)
	if parent == "MinimapCluster" or parent == _G["MinimapCluster"] then
		VehicleSeatIndicator:ClearAllPoints()
		VehicleSeatIndicator:SetPoint("BOTTOM", VehicleAnchor, "BOTTOM", 0, 24)
		VehicleSeatIndicator:SetFrameStrata("LOW")
	end
end)

local AchFilter = CreateFrame("Frame")
AchFilter:RegisterEvent("ADDON_LOADED")
AchFilter:SetScript("OnEvent", function(self, event, addon)
	if addon == "Blizzard_AchievementUI" then
		AchievementFrame_SetFilter(3)
	end
end)

-- Force readycheck warning
local ShowReadyCheckHook = function(self, initiator)
	if initiator ~= "player" then
		PlaySound("ReadyCheck", "Master")
	end
end
hooksecurefunc("ShowReadyCheck", ShowReadyCheckHook)

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

-- Enforce CVars.
local ForceCVar = CreateFrame("Frame")
ForceCVar:RegisterEvent("PLAYER_ENTERING_WORLD")
ForceCVar:SetScript("OnEvent", function(self, event)
	if event == "PLAYER_ENTERING_WORLD" then
		if not GetCVarBool("lockActionBars") and C.ActionBar.Enable then
			SetCVar("lockActionBars", 1)
		end
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

-- Remove Boss Emote spam during BG(ArathiBasin SpamFix by Partha)
if C.Misc.BGSpam == true then
	local Fixer = CreateFrame("Frame")
	local RaidBossEmoteFrame, spamDisabled = RaidBossEmoteFrame

	local function DisableSpam()
		if GetZoneText() == L_ZONE_ARATHIBASIN then
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