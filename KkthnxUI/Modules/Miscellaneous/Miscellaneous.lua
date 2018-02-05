local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("Miscellaneous", "AceEvent-3.0")

-- Global variables that we don"t cache
-- GLOBALS: GameMenuFrame GhostFrameContentsFrame GhostFrameContentsFrameIcon GhostFrameContentsFrameText GhostFrameLeft GhostFrameMiddle GhostFrameRight
-- GLOBALS: GhostFrame LevelUpDisplay BossBanner statusBar UIErrorsFrame RaidNotice_AddMessage
-- GLOBALS: InterfaceOptionsFrame LFDParentFrame PlaySoundKitID SOUNDKIT StaticPopup1 StaticPopup1Button1 StaticPopup1EditBox VideoOptionsFrame
-- GLOBALS: RaidBossEmoteFrame ChatTypeInfo DurabilityFrame SaveBindings KkthnxUIConfig KkthnxUIConfigFrame
-- GLOBALS: SideDressUpModel SideDressUpModelResetButton DressUpModel DressUpFrameResetButton
-- GLOBALS: TalkingHeadFrame LFDQueueFrame_SetType L_ZONE_ARATHIBASIN L_ZONE_GILNEAS AuctionFrame
-- GLOBALS: TicketStatusFrame HelpOpenTicketButton HelpOpenWebTicketButton Minimap GMMover UIParent

local _G = _G

local select = select
local unpack = unpack
local string_find = string.find

local CreateFrame = _G.CreateFrame
local GetBattlefieldInstanceExpiration = _G.GetBattlefieldInstanceExpiration
local GetBattlefieldStatus = _G.GetBattlefieldStatus
local GetCursorInfo = _G.GetCursorInfo
local GetCVarBool = _G.GetCVarBool
local GetMaxBattlefieldID = _G.GetMaxBattlefieldID
local InCombatLockdown = _G.InCombatLockdown
local IsInInstance = _G.IsInInstance
local PlaySound = _G.PlaySound
local PlaySoundFile = _G.PlaySoundFile
local PVPTimerFrame = _G.PVPTimerFrame
local SetCVar = _G.SetCVar

local RESURRECTION_REQUEST_SOUND = "Sound\\Spells\\Resurrection.wav"
local Movers = K["Movers"]

-- Fix UIErrorsFrame framelevel
UIErrorsFrame:SetFrameLevel(0)

do
	function Module:DELETE_ITEM_CONFIRM(...)
		if StaticPopup1EditBox:IsShown() then
			StaticPopup1EditBox:Hide()
			StaticPopup1Button1:Enable()

			local link = select(3, GetCursorInfo())

			Module.link:SetText(link)
			Module.link:Show()
		end
	end

	function Module:ADDON_LOADED()
		Module.link = StaticPopup1:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
		Module.link:SetPoint("CENTER", StaticPopup1EditBox)
		Module.link:Hide()

		StaticPopup1:HookScript("OnHide", function(self)
			Module.link:Hide()
		end)
	end

	function Module:OnInitialize(...)
		self:RegisterEvent("ADDON_LOADED")
		self:RegisterEvent("DELETE_ITEM_CONFIRM")
	end
end

do
	if C["General"].AutoScale then
		local scaleBtn = _G.CreateFrame("Button", "KkthnxUIScaleBtn", _G.Advanced_, "UIPanelButtonTemplate")
		scaleBtn:SetSize(200, 24)
		scaleBtn:SetText(L.Miscellaneous.KkthnxUI_Scale_Button)
		scaleBtn:SetPoint("LEFT", Advanced_UseUIScale, "LEFT",4, -70)
		scaleBtn:SetScript("OnClick", function()
			if (not KkthnxUIConfig) then
				_G.print(L.Miscellaneous.Config_Not_Found)
				return
			end
			if (not KkthnxUIConfigFrame) then
				KkthnxUIConfig:CreateConfigWindow()
			end
			if KkthnxUIConfigFrame:IsVisible() then
				KkthnxUIConfigFrame:Hide()
			else
				_G.HideUIPanel(VideoOptionsFrame)
				_G.HideUIPanel(GameMenuFrame)
				KkthnxUIConfigFrame:Show()
			end
		end)
	end
end

do
	-- Fix blank tooltip
	local bug = nil
	local FixTooltip = CreateFrame("Frame")
	FixTooltip:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
	FixTooltip:RegisterEvent("ACTIONBAR_PAGE_CHANGED")
	FixTooltip:SetScript("OnEvent", function()
		if GameTooltip:IsShown() then
			bug = true
		end
	end)

	local FixTooltipBags = CreateFrame("Frame")
	FixTooltipBags:RegisterEvent("BAG_UPDATE_DELAYED")
	FixTooltipBags:SetScript("OnEvent", function()
		if StuffingFrameBags and StuffingFrameBags:IsShown() then
			if GameTooltip:IsShown() then
				bug = true
			end
		end
	end)

	GameTooltip:HookScript("OnTooltipCleared", function(self)
		if self:IsForbidden() then return end
		if bug and self:NumLines() == 0 then
			self:Hide()
			bug = false
		end
	end)
end

--[[do -- Make InterfaceOptionsFrame moveable.
	InterfaceOptionsFrame:SetClampedToScreen(true)
	InterfaceOptionsFrame:SetMovable(true)
	InterfaceOptionsFrame:EnableMouse(true)
	InterfaceOptionsFrame:RegisterForDrag("LeftButton", "RightButton")
	InterfaceOptionsFrame:SetScript("OnDragStart", function(self)
		if InCombatLockdown() then return end
		self:StartMoving()
		self.isMoving = true
	end)

	InterfaceOptionsFrame:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
		self.isMoving = false
	end)
end--]]

do -- Move some frames (Elvui)
	local TicketStatusMover = _G.CreateFrame("Frame", "TicketStatusMoverAnchor", _G.UIParent)
	TicketStatusMover:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 250, -6)
	TicketStatusMover:SetSize(200, 40)
	Movers:RegisterFrame(TicketStatusMover)

	local TicketFrame = CreateFrame("Frame")
	TicketFrame:RegisterEvent("PLAYER_LOGIN")
	TicketFrame:SetScript("OnEvent", function(self, event)
		TicketStatusFrame:ClearAllPoints()
		TicketStatusFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 250, -6)
		-- Blizzard repositions this frame now in UIParent_UpdateTopFramePositions
		_G.hooksecurefunc(TicketStatusFrame, "SetPoint", function(self, _, anchor)
			if anchor == _G.UIParent then
				TicketStatusFrame:ClearAllPoints()
				TicketStatusFrame:SetPoint("CENTER", TicketStatusMover, 0, 0)
			end
		end)
	end)
end

do -- Display battleground messages in the middle of the screen.
	local PVPMessageEnhancement = _G.CreateFrame("Frame")
	PVPMessageEnhancement:RegisterEvent("CHAT_MSG_BG_SYSTEM_HORDE")
	PVPMessageEnhancement:RegisterEvent("CHAT_MSG_BG_SYSTEM_ALLIANCE")
	PVPMessageEnhancement:RegisterEvent("CHAT_MSG_BG_SYSTEM_NEUTRAL")
	PVPMessageEnhancement:SetScript("OnEvent", function(self, _, msg)
		if not C["Misc"].EnhancedPvpMessages then return end
		local _, instanceType = _G.IsInInstance()
		if instanceType == "pvp" or instanceType == "arena" then
			RaidNotice_AddMessage(RaidBossEmoteFrame, msg, ChatTypeInfo["RAID_BOSS_EMOTE"])
		end
	end)
end

do -- Force readycheck warning
	local ShowReadyCheckHook = function(self, initiator)
		if initiator ~= "player" then
			PlaySound(PlaySoundKitID and "ReadyCheck" or SOUNDKIT.READY_CHECK, "Master")
		end
	end
	_G.hooksecurefunc("ShowReadyCheck", ShowReadyCheckHook)
end

do -- Force lockActionBars CVar
	local ForceCVar = _G.CreateFrame("Frame")
	ForceCVar:RegisterEvent("PLAYER_ENTERING_WORLD")
	ForceCVar:RegisterEvent("CVAR_UPDATE")
	ForceCVar:SetScript("OnEvent", function(self, event)
		if not GetCVarBool("lockActionBars") and C["ActionBar"].Enable then
			SetCVar("lockActionBars", 1)
		end
	end)
end

do -- Force other warnings
	local ForceWarning = _G.CreateFrame("Frame")
	ForceWarning:RegisterEvent("UPDATE_BATTLEFIELD_STATUS")
	ForceWarning:RegisterEvent("PET_BATTLE_QUEUE_PROPOSE_MATCH")
	ForceWarning:RegisterEvent("LFG_PROPOSAL_SHOW")
	ForceWarning:RegisterEvent("RESURRECT_REQUEST")
	ForceWarning:SetScript("OnEvent", function(self, event)
		if event == "UPDATE_BATTLEFIELD_STATUS" then
			for i = 1, _G.GetMaxBattlefieldID() do
				local status = _G.GetBattlefieldStatus(i)
				if status == "confirm" then
					_G.PlaySound(8459, "Master")
					break
				end
			end
		elseif event == "PET_BATTLE_QUEUE_PROPOSE_MATCH" then
			PlaySound(PlaySoundKitID and "PVPTHROUGHQUEUE" or SOUNDKIT.UI_PET_BATTLES_PVP_THROUGH_QUEUE)
		elseif event == "LFG_PROPOSAL_SHOW" then
			PlaySound(PlaySoundKitID and "ReadyCheck" or SOUNDKIT.READY_CHECK)
		elseif event == "RESURRECT_REQUEST" then
			PlaySoundFile(RESURRECTION_REQUEST_SOUND, "Master")
		end
	end)
end

do -- Auto select current event boss from LFD tool(EventBossAutoSelect by Nathanyel)
	local firstLFD
	LFDParentFrame:HookScript("OnShow", function()
		if not firstLFD then
			firstLFD = 1
			for i = 1, _G.GetNumRandomDungeons() do
				local id = _G.GetLFGRandomDungeonInfo(i)
				local isHoliday = select(15, _G.GetLFGDungeonInfo(id))
				if isHoliday and not _G.GetLFGDungeonRewards(id) then
					LFDQueueFrame_SetType(id)
				end
			end
		end
	end)
end

do -- Remove boss emote spam during bg(ArathiBasin SpamFix by Partha)
	if C["Misc"].BattlegroundSpam == true then
		local Fixer = _G.CreateFrame("Frame")
		local RaidBossEmoteFrame, spamDisabled = _G.RaidBossEmoteFrame

		local function DisableSpam()
			if _G.GetZoneText() == _G.L_ZONE_ARATHIBASIN or _G.GetZoneText() == _G.L_ZONE_GILNEAS then
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
end

do -- Boss Banner Hider
	if C["Misc"].NoBanner == true then
		BossBanner.PlayBanner = function() end
	end
end