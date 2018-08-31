local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("Minimap", "AceHook-3.0", "AceEvent-3.0", "AceTimer-3.0")

local _G = _G
local string_sub = string.sub

local C_Timer_After = _G.C_Timer.After
local CreateFrame = _G.CreateFrame
local GameTimeFrame = _G.GameTimeFrame
local GarrisonLandingPageMinimapButton = _G.GarrisonLandingPageMinimapButton
local GetMinimapZoneText = _G.GetMinimapZoneText
local GetZonePVPInfo = _G.GetZonePVPInfo
local GuildInstanceDifficulty = _G.GuildInstanceDifficulty
local hooksecurefunc = _G.hooksecurefunc
local InCombatLockdown = _G.InCombatLockdown
local Minimap = _G.Minimap
local UIParent = _G.UIParent

function Module:GetLocTextColor()
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

function Module:ADDON_LOADED(_, addon)
	if addon == "Blizzard_TimeManager" then
		TimeManagerClockButton:Kill()
	elseif addon == "Blizzard_FeedbackUI" then
		FeedbackUIButton:Kill()
	end
end

function Module:Minimap_OnMouseWheel(d)
	if d > 0 then
		_G.MinimapZoomIn:Click()
	elseif d < 0 then
		_G.MinimapZoomOut:Click()
	end
end

function Module:Update_ZoneText()
	if not C["Minimap"].Enable then
		return
	end

	Minimap.location:SetText(string_sub(GetMinimapZoneText(), 1, 46))
	Minimap.location:SetTextColor(Module:GetLocTextColor())
	Minimap.location:FontTemplate(nil, 13)
end

function Module:PLAYER_REGEN_ENABLED()
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

function Module:UpdateSettings()
	if InCombatLockdown() then
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
	end
	K.MinimapSize = C["Minimap"].Enable and C["Minimap"].Size or 170
	K.MinimapWidth = K.MinimapSize
	K.MinimapHeight = K.MinimapSize

	if C["Minimap"].Enable then
		Minimap:SetSize(K.MinimapSize, K.MinimapSize)
	end

	if MMHolder then
		MMHolder:SetWidth(Minimap:GetWidth())
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
		if not C["Minimap"].GarrisonLandingPage then
			-- ugly hack to keep the keybind functioning
			GarrisonLandingPageMinimapButton:SetParent(K.UIFrameHider)
			GarrisonLandingPageMinimapButton:UnregisterAllEvents()
			GarrisonLandingPageMinimapButton:Show()
			GarrisonLandingPageMinimapButton.Hide = GarrisonLandingPageMinimapButton.Show
		else
			GarrisonLandingPageMinimapButton:ClearAllPoints()
			GarrisonLandingPageMinimapButton:SetPoint("BOTTOMLEFT", Minimap, "BOTTOMLEFT", 0, 0)
			GarrisonLandingPageMinimapButton:SetScale(0.8)
			if GarrisonLandingPageTutorialBox then
				GarrisonLandingPageTutorialBox:SetScale(0.8)
				GarrisonLandingPageTutorialBox:SetClampedToScreen(true)
			end
		end
	end

	if GameTimeFrame then
		if not C["Minimap"].Calendar then
			GameTimeFrame:Hide()
		else
			local GameTimeFrameFont = K.GetFont(C["General"].Font)
			GameTimeFrame:SetParent(Minimap)
			GameTimeFrame:SetScale(0.6)
			GameTimeFrame:ClearAllPoints()
			GameTimeFrame:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", -3, -3)
			GameTimeFrame:SetHitRectInsets(0, 0, 0, 0)
			GameTimeFrame:GetNormalTexture():SetTexCoord(0, 1, 0, 1)
			GameTimeFrame:SetNormalTexture("Interface\\Addons\\KkthnxUI\\Media\\Textures\\Calendar.blp")
			GameTimeFrame:SetPushedTexture(nil)
			GameTimeFrame:SetHighlightTexture (nil)

			local GameTimeFont = GameTimeFrame:GetFontString()
			GameTimeFont:ClearAllPoints()
			GameTimeFont:SetPoint("CENTER", 0, -6)
			GameTimeFont:SetFontObject(GameTimeFrameFont)
			GameTimeFont:SetFont(select(1, GameTimeFont:GetFont()), 20, select(3, GameTimeFont:GetFont()))
			GameTimeFont:SetShadowOffset(0, 0)
		end
	end

	if MiniMapMailFrame then
		MiniMapMailFrame:ClearAllPoints()
		MiniMapMailFrame:SetPoint("BOTTOM", Minimap, "BOTTOM", 0, 4)
		MiniMapMailFrame:SetScale(1.2)
	end

	if QueueStatusMinimapButton then
		QueueStatusMinimapButton:ClearAllPoints()
		QueueStatusMinimapButton:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMRIGHT", 2, -2)
	end

	if MiniMapInstanceDifficulty and GuildInstanceDifficulty then
		MiniMapInstanceDifficulty:ClearAllPoints()
		MiniMapInstanceDifficulty:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 0, 0)
		GuildInstanceDifficulty:ClearAllPoints()
		GuildInstanceDifficulty:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 0, 0)
	end

	if MiniMapChallengeMode then
		MiniMapChallengeMode:ClearAllPoints()
		MiniMapChallengeMode:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 8, -8)
	end

	if HelpOpenTicketButton and HelpOpenWebTicketButton then
		PositionTicketButtons()
	end
end

function Module:OnInitialize()
	self:UpdateSettings()
	if not C["Minimap"].Enable then
		Minimap:SetMaskTexture("Textures\\MinimapMask")
		return
	end

	-- Support for other mods
	function GetMinimapShape()
		return "SQUARE"
	end

	local MMHolder = CreateFrame("Frame", "MMHolder", Minimap)
	MMHolder:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -4, -4)
	MMHolder:SetWidth(Minimap:GetWidth())
	MMHolder:SetHeight(Minimap:GetHeight())

	Minimap:ClearAllPoints()
	Minimap:SetPoint("CENTER", MMHolder, "CENTER", 0, 0)
	Minimap:SetMaskTexture(C["Media"].Blank)
	Minimap:SetQuestBlobRingAlpha(0)
	Minimap:SetArchBlobRingAlpha(0)
	Minimap:CreateBorder()
	Minimap:CreateInnerShadow(nil, 0.4)

	Minimap:HookScript("OnEnter", function(self)
		if K.PerformanceFrame then
			K.PerformanceFrame:Hide()
		end

		self.location:Show()
	end)

	Minimap:HookScript("OnLeave", function(self)
		if K.PerformanceFrame then
			K.PerformanceFrame:Show()
		end

		self.location:Hide()
	end)

	Minimap.location = Minimap:CreateFontString(nil, "OVERLAY")
	Minimap.location:SetWidth(C["Minimap"].Size)
	Minimap.location:FontTemplate(nil, 13)
	Minimap.location:SetPoint("TOP", 0, -4)
	Minimap.location:SetJustifyH("CENTER")
	Minimap.location:SetJustifyV("MIDDLE")
	Minimap.location:Hide()

	MinimapBorder:Hide()
	MinimapBorderTop:Hide()
	MinimapZoomIn:Hide()
	MinimapZoomOut:Hide()
	MinimapNorthTag:Kill()
	MinimapZoneTextButton:Hide()
	MiniMapTracking:Hide()
	MiniMapMailBorder:Hide()
	MiniMapMailIcon:SetTexture("Interface\\Addons\\KkthnxUI\\Media\\Textures\\Mail")

	-- Hide the BlopRing on Minimap
	Minimap:SetArchBlobRingScalar(0)
	Minimap:SetQuestBlobRingScalar(0)

	QueueStatusMinimapButtonBorder:Hide()
	QueueStatusFrame:SetClampedToScreen(true)

	MiniMapWorldMapButton:Hide()

	MiniMapInstanceDifficulty:SetParent(Minimap)
	GuildInstanceDifficulty:SetParent(Minimap)
	MiniMapChallengeMode:SetParent(Minimap)

	if TimeManagerClockButton then
		TimeManagerClockButton:Kill()
	end

	if FeedbackUIButton then
		FeedbackUIButton:Kill()
	end

	K["Movers"]:RegisterFrame(MMHolder)
	MinimapBackdrop:SetMovable(true)
	MinimapBackdrop:SetUserPlaced(true)
	MinimapBackdrop:SetParent(Minimap)
	MinimapBackdrop:ClearAllPoints()
	MinimapBackdrop:SetPoint("CENTER")

	MinimapCluster:SetMovable(true)
	MinimapCluster:SetUserPlaced(true)
	MinimapCluster:ClearAllPoints()
	MinimapCluster:SetAllPoints(Minimap)
	MinimapCluster:EnableMouse(false)

	Minimap:EnableMouseWheel(true)
	Minimap:SetScript("OnMouseWheel", Module.Minimap_OnMouseWheel)

	self:RegisterEvent("PLAYER_ENTERING_WORLD", "Update_ZoneText")
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA", "Update_ZoneText")
	self:RegisterEvent("ZONE_CHANGED", "Update_ZoneText")
	self:RegisterEvent("ZONE_CHANGED_INDOORS", "Update_ZoneText")
	self:RegisterEvent("ADDON_LOADED")
	self:UpdateSettings()
end