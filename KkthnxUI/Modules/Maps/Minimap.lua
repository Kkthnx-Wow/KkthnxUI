local K, C = unpack(select(2, ...))
local Module = K:NewModule("Minimap", "AceEvent-3.0", "AceHook-3.0", "AceTimer-3.0")

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
local MiniMapChallengeMode = _G.MiniMapChallengeMode
local MiniMapInstanceDifficulty = _G.MiniMapInstanceDifficulty
local MiniMapMailFrame = _G.MiniMapMailFrame
local QueueStatusMinimapButton = _G.QueueStatusMinimapButton
local UIParent = _G.UIParent

function Module:GetLocationTextColors()
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

function Module:OnMouseWheelScroll(d)
	if d > 0 then
		_G.MinimapZoomIn:Click()
	elseif d < 0 then
		_G.MinimapZoomOut:Click()
	end
end

function Module.ZoneTextUpdate()
	if not C["Minimap"].Enable then
		return
	end

	Minimap.Location:SetText(string.utf8sub(GetMinimapZoneText(), 1, 46))
	Minimap.Location:SetTextColor(Module:GetLocationTextColors())
	Minimap.Location:FontTemplate(nil, 13)
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
		return self:RegisterEvent("PLAYER_REGEN_ENABLED", "OnEvent")
	end

	K.MinimapSize = C["Minimap"].Enable and C["Minimap"].Size or Minimap:GetWidth() + 10
	K.MinimapWidth, K.MinimapHeight = K.MinimapSize, K.MinimapSize

	if C["Minimap"].Enable then
		Minimap:SetSize(K.MinimapSize, K.MinimapSize)
	end

	local MinimapFrameHolder = _G.MinimapFrameHolder
	if MinimapFrameHolder then
		MinimapFrameHolder:SetWidth(Minimap:GetWidth())
	end

	if Minimap.Location then
		Minimap.Location:SetWidth(K.MinimapSize)
		Minimap.Location:Hide()
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
			GameTimeFrame:SetParent(Minimap)
			GameTimeFrame:SetScale(0.6)
			GameTimeFrame:ClearAllPoints()
			GameTimeFrame:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", -3, -3)
			GameTimeFrame:SetHitRectInsets(0, 0, 0, 0)
			GameTimeFrame:GetNormalTexture():SetTexCoord(0, 1, 0, 1)
			GameTimeFrame:SetNormalTexture("Interface\\Addons\\KkthnxUI\\Media\\Textures\\Calendar.blp")
			GameTimeFrame:SetPushedTexture(nil)
			GameTimeFrame:SetHighlightTexture(nil)

			local GameTimeFont = GameTimeFrame:GetFontString()
			GameTimeFont:ClearAllPoints()
			GameTimeFont:SetPoint("CENTER", 0, -6)
			GameTimeFont:SetFontObject("KkthnxUIFont")
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

	-- QueueStatus Button
	if QueueStatusMinimapButton then
		QueueStatusMinimapButton:ClearAllPoints()
		QueueStatusMinimapButton:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMRIGHT", 2, -2)

		local queueIcon = Minimap:CreateTexture(nil, "ARTWORK")
		queueIcon:SetPoint("CENTER", QueueStatusMinimapButton)
		queueIcon:SetSize(50, 50)
		queueIcon:SetTexture("Interface\\Minimap\\Dungeon_Icon")
		local anim = queueIcon:CreateAnimationGroup()
		anim:SetLooping("REPEAT")
		anim.rota = anim:CreateAnimation("Rotation")
		anim.rota:SetDuration(2)
		anim.rota:SetDegrees(360)
		hooksecurefunc("QueueStatusFrame_Update", function()
			queueIcon:SetShown(QueueStatusMinimapButton:IsShown())
		end)
		hooksecurefunc("EyeTemplate_StartAnimating", function() anim:Play() end)
		hooksecurefunc("EyeTemplate_StopAnimating", function() anim:Stop() end)
	end

	if MiniMapInstanceDifficulty and GuildInstanceDifficulty then
		MiniMapInstanceDifficulty:ClearAllPoints()
		MiniMapInstanceDifficulty:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 0, 0)
		MiniMapInstanceDifficulty:SetScale(0.9)
		GuildInstanceDifficulty:ClearAllPoints()
		GuildInstanceDifficulty:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 0, 0)
		GuildInstanceDifficulty:SetScale(0.9)
	end

	if MiniMapChallengeMode then
		MiniMapChallengeMode:ClearAllPoints()
		MiniMapChallengeMode:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 8, -8)
	end

	if StreamingIcon then
		StreamingIcon:ClearAllPoints()
		StreamingIcon:SetPoint("TOP", UIParent, "TOP", 0, -6)
	end
end

function Module.ADDON_LOADED(_, addon)
	if addon == "Blizzard_TimeManager" then
		TimeManagerClockButton:Kill()
	elseif addon == "Blizzard_FeedbackUI" then
		FeedbackUIButton:Kill()
	end
end

function Module.OnEvent(event)
	if event == "PLAYER_ENTERING_WORLD" then
		Module:ZoneTextUpdate()
	elseif event == "PLAYER_REGEN_ENABLED" then
		Module:UpdateSettings()
	end
end

function Module:WhoPingedMyMap()
	local MinimapPing = CreateFrame("Frame", nil, Minimap)
	MinimapPing:SetAllPoints()

	MinimapPing.Text = MinimapPing:CreateFontString(nil, "OVERLAY")
	MinimapPing.Text:FontTemplate(nil, 14)
	MinimapPing.Text:SetPoint("TOP", MinimapPing, "TOP", 0, -20)

	local AnimationPing = MinimapPing:CreateAnimationGroup()
	AnimationPing:SetScript("OnPlay", function()
		MinimapPing:SetAlpha(1)
	end)

	AnimationPing:SetScript("OnFinished", function()
		MinimapPing:SetAlpha(0)
	end)

	AnimationPing.Fader = AnimationPing:CreateAnimation("Alpha")
	AnimationPing.Fader:SetFromAlpha(1)
	AnimationPing.Fader:SetToAlpha(0)
	AnimationPing.Fader:SetDuration(3)
	AnimationPing.Fader:SetSmoothing("OUT")
	AnimationPing.Fader:SetStartDelay(3)

	function Module.MINIMAP_PING(_, unit)
		local class = select(2, UnitClass(unit))
		if not class then
			return
		end

		local r, g, b = K.ColorClass(class)
		local name = GetUnitName(unit)
		if not name then
			return
		end

		AnimationPing:Stop()
		MinimapPing.Text:SetText(name)
		MinimapPing.Text:SetTextColor(r, g, b)
		AnimationPing:Play()
	end

	K:RegisterEvent("MINIMAP_PING", self.MINIMAP_PING)
end

function Module:OnEnable()
	self:UpdateSettings()

	if not C["Minimap"].Enable then
		Minimap:SetMaskTexture(186178)
		Minimap:SetBlipTexture("Interface\\MiniMap\\ObjectIconsAtlas")
		return
	end

	local UIHider = K.UIFrameHider

	-- Support for other mods
	function GetMinimapShape()
		return "SQUARE"
	end

	local MinimapFrameHolder = CreateFrame("Frame", "MinimapFrameHolder", Minimap)
	MinimapFrameHolder:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -4, -4)
	MinimapFrameHolder:SetWidth(Minimap:GetWidth())
	MinimapFrameHolder:SetHeight(Minimap:GetHeight())

	Minimap:ClearAllPoints()
	Minimap:SetPoint("CENTER", MinimapFrameHolder, "CENTER", 0, 0)
	Minimap:SetMaskTexture(C["Media"].Blank)
	Minimap:SetQuestBlobRingAlpha(0)
	Minimap:SetArchBlobRingAlpha(0)
	Minimap:CreateBorder()
	Minimap:CreateInnerShadow(nil, 0.4)
	Minimap:SetScale(1.0)
	Minimap:SetBlipTexture("Interface\\AddOns\\KkthnxUI\\Media\\MiniMap\\Blip-Nandini-New")

	Minimap:HookScript("OnEnter", function()
		if K.PerformanceFrame:IsShown() then
			K.PerformanceFrame:Hide()
		end

		Minimap.Location:Show()
	end)

	Minimap:HookScript("OnLeave", function()
		if not K.PerformanceFrame:IsShown() then
			K.PerformanceFrame:Show()
		end

		Minimap.Location:Hide()
	end)

	Minimap.Location = Minimap:CreateFontString(nil, "OVERLAY")
	Minimap.Location:FontTemplate(nil, 13)
	Minimap.Location:SetPoint("TOP", Minimap, "TOP", 0, -4)
	Minimap.Location:SetJustifyH("CENTER")
	Minimap.Location:SetJustifyV("MIDDLE")
	Minimap.Location:Hide()

	-- New dungeon finder eye in MoP
	QueueStatusMinimapButton:SetHighlightTexture("")
	if QueueStatusMinimapButton.Highlight then -- bugged out in MoP
		QueueStatusMinimapButton.Highlight:SetTexture(nil)
		QueueStatusMinimapButton.Highlight:SetAlpha(0)
	end

	_G.MinimapBorder:SetParent(UIHider)
	_G.MinimapBorderTop:SetParent(UIHider)
	_G.MiniMapMailBorder:SetParent(UIHider)
	_G.MinimapNorthTag:SetParent(UIHider)
	_G.MiniMapTracking:SetParent(UIHider)
	_G.MiniMapTrackingButton:SetParent(UIHider)
	_G.MinimapZoneTextButton:SetParent(UIHider)
	_G.MinimapZoomIn:SetParent(UIHider)
	_G.MinimapZoomOut:SetParent(UIHider)
	_G.MiniMapMailIcon:SetTexture("Interface\\Addons\\KkthnxUI\\Media\\Textures\\Mail")

	-- Hide the BlopRing on Minimap
	MinimapCluster:EnableMouse(false)
	Minimap:SetArchBlobRingScalar(0)
	Minimap:SetQuestBlobRingScalar(0)

	if QueueStatusMinimapButtonBorder then
		QueueStatusMinimapButtonBorder:SetAlpha(0)
		QueueStatusMinimapButtonBorder:SetTexture(nil)
		QueueStatusMinimapButtonIconTexture:SetTexture(nil)
	end

	_G.MiniMapWorldMapButton:SetParent(K.UIFrameHider)

	MiniMapInstanceDifficulty:SetParent(Minimap)
	GuildInstanceDifficulty:SetParent(Minimap)
	MiniMapChallengeMode:SetParent(Minimap)

	if TimeManagerClockButton then
		TimeManagerClockButton:Kill()
	end

	if FeedbackUIButton then
		FeedbackUIButton:Kill()
	end

	K.Mover(MinimapFrameHolder, "Minimap", "Minimap", {"TOPRIGHT", UIParent, "TOPRIGHT", -4, -4}, Minimap:GetWidth(), Minimap:GetHeight())

	Minimap:EnableMouseWheel(true)
	Minimap:SetScript("OnMouseWheel", Module.OnMouseWheelScroll)

	K:RegisterEvent("PLAYER_ENTERING_WORLD", self.OnEvent)
	K:RegisterEvent("ZONE_CHANGED_NEW_AREA", self.ZoneTextUpdate)
	K:RegisterEvent("ZONE_CHANGED", self.ZoneTextUpdate)
	K:RegisterEvent("ZONE_CHANGED_INDOORS", self.ZoneTextUpdate)
	K:RegisterEvent("ADDON_LOADED", self.ADDON_LOADED)

	self:UpdateSettings()

	self:WhoPingedMyMap()
	self:CreateRecycleBin()
end