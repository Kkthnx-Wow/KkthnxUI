local _G = _G
local K, C, L = _G.unpack(_G.select(2, ...))
local Module = K:NewModule("Miscellaneous", "AceEvent-3.0")

-- WoW Lua
local select = select
local unpack = unpack
local string_find = string.find

-- GLOBALS: GhostFrame, LevelUpDisplay, BossBanner, statusBar, UIErrorsFrame, RaidNotice_AddMessage
-- GLOBALS: RaidBossEmoteFrame, ChatTypeInfo, DurabilityFrame, SaveBindings, KkthnxUIConfig, KkthnxUIConfigFrame
-- GLOBALS: SideDressUpModel, SideDressUpModelResetButton, DressUpModel, DressUpFrameResetButton
-- GLOBALS: TalkingHeadFrame, LFDQueueFrame_SetType, L_ZONE_ARATHIBASIN, L_ZONE_GILNEAS, AuctionFrame
-- GLOBALS: TicketStatusFrame, HelpOpenTicketButton, HelpOpenWebTicketButton, Minimap, GMMover, UIParent

local Movers = K.Movers

-- Fix UIErrorsFrame framelevel
UIErrorsFrame:SetFrameLevel(0)

do
	local bug = nil
	local FixTooltip = CreateFrame("Frame")
	FixTooltip:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
	FixTooltip:RegisterEvent("ACTIONBAR_PAGE_CHANGED")
	FixTooltip:SetScript("OnEvent", function()
		if GameTooltip:IsShown() then
			bug = true
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

	function Module:OnEnable(...)
		self:RegisterEvent("ADDON_LOADED")
		self:RegisterEvent("DELETE_ITEM_CONFIRM")
	end
end

do
	local scaleBtn = _G.CreateFrame("Button", "KkthnxUIScaleBtn", _G.Advanced_, "UIPanelButtonTemplate")
	scaleBtn:SetSize(200, 24)
	scaleBtn:SetText(L.Miscellaneous.KkthnxUI_Scale_Button)
	scaleBtn:SetPoint("TOPLEFT", _G.Advanced_UIScaleSlider, 20, 0)
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

do -- Make InterfaceOptionsFrame moveable.
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
end

do
	GhostFrame:SkinButton(true)
	GhostFrame:ClearAllPoints()
	GhostFrame:SetPoint("TOP", _G.UIParent, "TOP", 0, -270)
	GhostFrameContentsFrameIcon:SetTexture(nil)
	local x = _G.CreateFrame("Frame", nil, GhostFrame)
	x:SetFrameStrata("MEDIUM")
	x:SetTemplate("Transparent")
	x:SetOutside(GhostFrameContentsFrameIcon)
	local tex = x:CreateTexture(nil, "OVERLAY")
	tex:SetTexture("Interface\\Icons\\spell_holy_guardianspirit")
	tex:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	tex:SetAllPoints()
end

do -- Move some frames (Elvui)
	local TicketStatusMover = _G.CreateFrame("Frame", "TicketStatusMoverAnchor", _G.UIParent)
	TicketStatusMover:SetPoint(C.Position.Ticket[1], C.Position.Ticket[2], C.Position.Ticket[3], C.Position.Ticket[4])
	TicketStatusMover:SetSize(200, 40)
	Movers:RegisterFrame(TicketStatusMover)

	local TicketFrame = CreateFrame("Frame")
	TicketFrame:RegisterEvent("PLAYER_LOGIN")
	TicketFrame:SetScript("OnEvent", function(self, event)
		TicketStatusFrame:ClearAllPoints()
		TicketStatusFrame:SetPoint(unpack(C.Position.Ticket))
		-- Blizzard repositions this frame now in UIParent_UpdateTopFramePositions
		_G.hooksecurefunc(TicketStatusFrame, "SetPoint", function(self, _, anchor)
			if anchor == _G.UIParent then
				TicketStatusFrame:ClearAllPoints()
				TicketStatusFrame:SetPoint("TOPLEFT", TicketStatusMover, 0, 0)
			end
		end)
	end)
end

do -- LevelUp + BossBanner Mover
	local LBBMover = _G.CreateFrame("Frame", "LevelUpBossBannerHolder", _G.UIParent)
	LBBMover:SetSize(200, 20)
	LBBMover:SetPoint("TOP", _G.UIParent, "TOP", 0, -120)

	local LevelUpBossBanner = _G.CreateFrame("Frame")
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
		_G.hooksecurefunc(LevelUpDisplay, "SetPoint", Reanchor)

		-- Boss Banner
		BossBanner:ClearAllPoints()
		BossBanner:SetPoint("TOP", LBBMover)
		_G.hooksecurefunc(BossBanner, "SetPoint", Reanchor)
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
			PlaySound("ReadyCheck", "Master")
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
					_G.PlaySound("PVPTHROUGHQUEUE", "Master")
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

-- Filter out some Felsong stuff I don"t want
if (K.WoWBuild == 23420) and (K.Realm == "Felsong") then
	do
		local serverSpam = {"Autobroadcast", "ARENA ANNOUNCER", "BG Queue Announcer"}

		ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", function(self, event, msg)
			if (not msg) then
				return
			end

			for _, spam in ipairs(serverSpam) do
				if string_find(msg, spam) then
					return true
				end
			end
		end)
	end
end