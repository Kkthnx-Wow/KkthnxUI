local K, C, L = unpack(select(2, ...))
local M = K:NewModule("Minimap", "AceHook-3.0", "AceEvent-3.0", "AceTimer-3.0")

local _G = _G
local tinsert = table.insert
local strsub = strsub

local C_Timer_After = C_Timer.After

function M:GetLocTextColor()
	local pvpType = GetZonePVPInfo()
	if pvpType == "arena" then
		return 0.84, 0.03, 0.03
	elseif pvpType == "friendly" then
		return 0.05, 0.85, 0.03
	elseif pvpType == "contested" then
		return 0.9, 0.85, 0.05
	elseif pvpType == "hostile" then
		return 0.84, 0.03, 0.03
	elseif pvpType == "sanctuary" then
		return 0.035, 0.58, 0.84
	elseif pvpType == "combat" then
		return 0.84, 0.03, 0.03
	else
		return 0.9, 0.85, 0.05
	end
end

function M:ADDON_LOADED(event, addon)
	if addon == "Blizzard_TimeManager" then
		TimeManagerClockButton:Kill()
	elseif addon == "Blizzard_FeedbackUI" then
		FeedbackUIButton:Kill()
	end
end

function M:Minimap_OnMouseWheel(d)
	if d > 0 then
		_G.MinimapZoomIn:Click()
	elseif d < 0 then
		_G.MinimapZoomOut:Click()
	end
end

function M:Update_ZoneText()
	if not C["Minimap"].Enable then return end
	Minimap.location:SetText(strsub(GetMinimapZoneText(), 1, 46))
	Minimap.location:SetTextColor(M:GetLocTextColor())
	Minimap.location:FontTemplate()
end

function M:PLAYER_REGEN_ENABLED()
	self:UnregisterEvent("PLAYER_REGEN_ENABLED")
	self:UpdateSettings()
end

local function PositionTicketButtons()
	HelpOpenTicketButton:ClearAllPoints()
	HelpOpenTicketButton:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", 0, 0)
	HelpOpenWebTicketButton:ClearAllPoints()
	HelpOpenWebTicketButton:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", 0, 0)
end

local isResetting
local function ResetZoom()
	Minimap:SetZoom(0)
	MinimapZoomIn:Enable() -- Reset enabled state of buttons
	MinimapZoomOut:Disable()
	isResetting = false
end

local function SetupZoomReset()
	if C["Minimap"].ResetZoom and not isResetting then
		isResetting = true
		C_Timer_After(C["Minimap"].ResetZoomTime, ResetZoom)
	end
end
hooksecurefunc(Minimap, "SetZoom", SetupZoomReset)

function M:UpdateSettings()
	if InCombatLockdown() then
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
	end
	K.MinimapSize = C["Minimap"].Enable and C["Minimap"].Size or Minimap:GetWidth() + 10
	K.MinimapWidth = K.MinimapSize
	K.MinimapHeight = K.MinimapSize

	if C["Minimap"].Enable then
		Minimap:SetSize(K.MinimapSize, K.MinimapSize)
	end

	if MMHolder then
		MMHolder:SetWidth((Minimap:GetWidth() + 1 + 1 * 3))
	end

	if Minimap.location then
		Minimap.location:SetWidth(K.MinimapSize)
		Minimap.location:Hide()
	end

	-- Stop here if KkthnxUI Minimap is disabled.
	if not C["Minimap"].Enable then
		return
	end

	if GarrisonLandingPageMinimapButton then
		-- GarrisonLandingPageMinimapButton:ClearAllPoints()
		-- GarrisonLandingPageMinimapButton:SetParent(Minimap)
		-- GarrisonLandingPageMinimapButton:SetPoint("TOPLEFT", Minimap, "TOPLEFT", -4, 4)
		-- GarrisonLandingPageMinimapButton:SetSize(36, 36)
		-- hooksecurefunc("GarrisonLandingPageMinimapButton_UpdateIcon", function(self)
		-- 	self:SetNormalTexture("")
		-- 	self:SetPushedTexture("")
		-- 	self:SetHighlightTexture("")

		-- 	local GarrisonIcon = self:CreateTexture(nil, "OVERLAY", nil, 7)
		-- 	GarrisonIcon:SetSize(30, 30)
		-- 	GarrisonIcon:SetPoint("CENTER")
		-- 	GarrisonIcon:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\Textures\\GarrisonUp")
		-- 	GarrisonIcon:SetVertexColor(1, 1, 1)
		-- 	self.GarrisonIcon = GarrisonIcon

		-- 	if (C_Garrison.GetLandingPageGarrisonType() == LE_GARRISON_TYPE_6_0) then
		-- 		self.title = GARRISON_LANDING_PAGE_TITLE
		-- 		self.description = MINIMAP_GARRISON_LANDING_PAGE_TOOLTIP
		-- 	else
		-- 		self.title = ORDER_HALL_LANDING_PAGE_TITLE
		-- 		self.description = MINIMAP_ORDER_HALL_LANDING_PAGE_TOOLTIP
		-- 	end
		-- end)

		-- GarrisonLandingPageMinimapButton:SetScript("OnEnter", function(self)
		-- 	self.GarrisonIcon:SetVertexColor(1, .8, 0)
		-- end)

		-- GarrisonLandingPageMinimapButton:SetScript("OnLeave", function(self)
		-- 	self.GarrisonIcon:SetVertexColor(1, 1, 1)
		-- end)
		-- GarrisonMinimapBuilding_ShowPulse = function() end

		-- if GarrisonLandingPageTutorialBox then
		-- 	GarrisonLandingPageTutorialBox:SetScale(1 / 0.8)
		-- 	GarrisonLandingPageTutorialBox:SetClampedToScreen(true)
		-- end

		local GarrisonLandingPageMinimapButton = _G.GarrisonLandingPageMinimapButton
		GarrisonLandingPageMinimapButton:SetParent(K.UIFrameHider)
		GarrisonLandingPageMinimapButton:UnregisterAllEvents()
		GarrisonLandingPageMinimapButton:Show()
		GarrisonLandingPageMinimapButton.Hide = GarrisonLandingPageMinimapButton.Show
	end

	if GameTimeFrame then
		if C["Minimap"].hideCalendar then
			GameTimeFrame:Hide()
		else
			GameTimeFrame:SetParent(Minimap)
			GameTimeFrame:SetScale(0.6)
			GameTimeFrame:ClearAllPoints()
			GameTimeFrame:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", -2, -3)
			GameTimeFrame:SetHitRectInsets(0, 0, 0, 0)
			GameTimeFrame:GetNormalTexture():SetTexCoord(0, 1, 0, 1)
			GameTimeFrame:SetNormalTexture("Interface\\Addons\\KkthnxUI\\Media\\Textures\\Calendar.blp")
			GameTimeFrame:SetPushedTexture(nil)
			GameTimeFrame:SetHighlightTexture (nil)

			local GameTimeFont = GameTimeFrame:GetFontString()
			GameTimeFont:ClearAllPoints()
			GameTimeFont:SetPoint("CENTER", 0, -7)
			GameTimeFont:SetFont(C["Media"].Font, 20)
			GameTimeFont:SetTextColor(0.2, 0.2, 0.1, 1)

			GameTimeFrame:SetAlpha(0)
			K.UIFrameFadeIn(GameTimeFrame, 0.4, GameTimeFrame:GetAlpha(), 1)
		end
	end

	if MiniMapMailFrame then
		MiniMapMailFrame:ClearAllPoints()
		MiniMapMailFrame:SetPoint("BOTTOM", Minimap, "BOTTOM", 0, 4)
		MiniMapMailFrame:SetScale(1.2)
		MiniMapMailIcon:SetTexture("Interface\\Addons\\KkthnxUI\\Media\\Textures\\Mail")
	end

	if QueueStatusMinimapButton then
		QueueStatusMinimapButton:ClearAllPoints()
		QueueStatusMinimapButton:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMRIGHT", 2, -2)
		QueueStatusMinimapButton:SetScale(1.0)
	end

	if MiniMapInstanceDifficulty and GuildInstanceDifficulty then
		MiniMapInstanceDifficulty:ClearAllPoints()
		MiniMapInstanceDifficulty:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 0, 0)
		GuildInstanceDifficulty:ClearAllPoints()
		GuildInstanceDifficulty:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 0, 0)
	end

	if HelpOpenTicketButton and HelpOpenWebTicketButton then
		HelpOpenTicketButton:SetScale(1)
		HelpOpenWebTicketButton:SetScale(1)
		PositionTicketButtons()
	end
end

function M:OnInitialize()
	self:UpdateSettings()
	if not C["Minimap"].Enable then
		Minimap:SetMaskTexture("Textures\\MinimapMask")
		return
	end

	-- Support for other mods
	function GetMinimapShape()
		return "SQUARE"
	end

	local mmholder = CreateFrame("Frame", "MMHolder", Minimap)
	mmholder:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -4, -4)
	mmholder:SetWidth(Minimap:GetWidth())
	mmholder:SetHeight(Minimap:GetHeight())

	Minimap:ClearAllPoints()
	Minimap:SetPoint("TOPRIGHT", mmholder, "TOPRIGHT", -1, -1)
	Minimap:SetMaskTexture(C["Media"].Blank)
	Minimap:SetQuestBlobRingAlpha(0)
	Minimap:SetArchBlobRingAlpha(0)
	Minimap:SetTemplate()
	Minimap:SetFrameLevel(Minimap:GetFrameLevel() + 2)
	Minimap:HookScript("OnEnter", function(self)
		self.location:Show()
	end)

	Minimap:HookScript("OnLeave", function(self)
		self.location:Hide()
	end)

	--Fix spellbook taint
	ShowUIPanel(SpellBookFrame)
	HideUIPanel(SpellBookFrame)

	Minimap.location = Minimap:CreateFontString(nil, "OVERLAY")
	Minimap.location:FontTemplate(nil, 13, "OUTLINE")
	Minimap.location:SetPoint("TOP", Minimap, "TOP", 0, -4)
	Minimap.location:SetJustifyH("CENTER")
	Minimap.location:SetJustifyV("MIDDLE")
	Minimap.location:Hide()

	MinimapBorder:Hide()
	MinimapBorderTop:Hide()

	MinimapZoomIn:Hide()
	MinimapZoomOut:Hide()
	MiniMapVoiceChatFrame:Hide()
	MinimapNorthTag:Kill()
	MinimapZoneTextButton:Hide()
	MiniMapTracking:Hide()
	MiniMapMailBorder:Hide()
	MiniMapMailIcon:SetTexture("")

	--Hide the BlopRing on Minimap
	Minimap:SetArchBlobRingScalar(0)
	Minimap:SetQuestBlobRingScalar(0)

	if C["Minimap"].hideClassHallReport then
		GarrisonLandingPageMinimapButton:Kill()
		GarrisonLandingPageMinimapButton.IsShown = function() return true end
	end

	QueueStatusMinimapButtonBorder:Hide()
	QueueStatusFrame:SetClampedToScreen(true)

	MiniMapWorldMapButton:Hide()

	MiniMapInstanceDifficulty:Hide()
	GuildInstanceDifficulty:Hide()
	MiniMapInstanceDifficulty.Show = K.Noop
	GuildInstanceDifficulty.Show = K.Noop
	MiniMapChallengeMode:GetRegions():SetTexture("")

	if TimeManagerClockButton then
		TimeManagerClockButton:Kill()
	end

	if FeedbackUIButton then
		FeedbackUIButton:Kill()
	end

	K["Movers"]:RegisterFrame(MMHolder)

	Minimap:EnableMouseWheel(true)
	Minimap:SetScript("OnMouseWheel", M.Minimap_OnMouseWheel)

	-- Make sure these invisible frames follow the minimap.
	MinimapCluster:ClearAllPoints()
	MinimapCluster:SetAllPoints(Minimap)
	MinimapCluster:EnableMouse(false)
	MinimapBackdrop:ClearAllPoints()
	MinimapBackdrop:SetAllPoints(Minimap)

	self:RegisterEvent("PLAYER_ENTERING_WORLD", "Update_ZoneText")
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA", "Update_ZoneText")
	self:RegisterEvent("ZONE_CHANGED", "Update_ZoneText")
	self:RegisterEvent("ZONE_CHANGED_INDOORS", "Update_ZoneText")
	self:RegisterEvent("ADDON_LOADED")
	self:UpdateSettings()
end