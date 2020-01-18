local K, C = unpack(select(2, ...))
local Module = K:NewModule("Minimap", "AceEvent-3.0", "AceHook-3.0", "AceTimer-3.0")

local _G = _G

local C_Timer_After = _G.C_Timer.After
local CreateFrame = _G.CreateFrame
local GetMinimapZoneText = _G.GetMinimapZoneText
local GetUnitName = _G.GetUnitName
local GetZonePVPInfo = _G.GetZonePVPInfo
local InCombatLockdown = _G.InCombatLockdown
local MiniMapMailFrame = _G.MiniMapMailFrame
local Minimap = _G.Minimap
local UIParent = _G.UIParent
local UnitClass = _G.UnitClass
local hooksecurefunc = _G.hooksecurefunc

function Module:GetLocTextColor()
	local pvpType = GetZonePVPInfo()
	if pvpType == "friendly" then
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

function Module:UpdateZoneText()
	if C["Minimap"].LocationText.Value == "HIDE" or not C["Minimap"].Enable then
		return
	end

	Minimap.Location:SetText(GetMinimapZoneText())
	Minimap.Location:SetTextColor(Module:GetLocTextColor())
	Minimap.Location:SetFontObject(K.GetFont(C["UIFonts"].DataTextFonts))
	Minimap.Location:SetFont(select(1, Minimap.Location:GetFont()), 13, select(3, Minimap.Location:GetFont()))
end

function Module:UpdateSettings()
	if InCombatLockdown() then
		K:RegisterEvent("PLAYER_REGEN_ENABLED", self.PLAYER_REGEN_ENABLED)
		return
	end

	K.MinimapSize = C["Minimap"].Enable and C["Minimap"].Size or Minimap:GetWidth() + 10
	K.MinimapWidth, K.MinimapHeight = K.MinimapSize, K.MinimapSize

	Minimap:SetSize(K.MinimapSize, K.MinimapSize)

	local MinimapFrameHolder = _G.MinimapFrameHolder
	if MinimapFrameHolder then
		MinimapFrameHolder:SetWidth(Minimap:GetWidth())
	end

	-- Stop here if KkthnxUI Minimap is disabled.
	if not C["Minimap"].Enable then
		return
	end

	Minimap.Location:SetWidth(K.MinimapSize)

	if C["Minimap"].LocationText.Value ~= "SHOW" or not C["Minimap"].Enable then
		Minimap.Location:Hide()
	else
		Minimap.Location:Show()
	end

	if GarrisonLandingPageMinimapButton then
		if not C["Minimap"].ShowGarrison then
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
		if C["DataText"].Time then
			MiniMapMailFrame:SetPoint("BOTTOM", Minimap, "BOTTOM", 0, 4)
		else
			MiniMapMailFrame:SetPoint("BOTTOM", Minimap, "BOTTOM", 0, -6)
		end
		MiniMapMailFrame:SetScale(1.2)
		MiniMapMailFrame:SetHitRectInsets(8, 8, 12, 11)
	end

	-- QueueStatus Button
	if QueueStatusMinimapButton then
		QueueStatusMinimapButton:ClearAllPoints()
		QueueStatusMinimapButton:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMRIGHT", 2, -2)

		local queueIcon = Minimap:CreateTexture(nil, "ARTWORK")
		queueIcon:SetPoint("CENTER", QueueStatusMinimapButton)
		queueIcon:SetSize(50, 50)
		queueIcon:SetTexture("Interface\\Minimap\\Raid_Icon")

		local anim = queueIcon:CreateAnimationGroup()
		anim:SetLooping("REPEAT")
		anim.rota = anim:CreateAnimation("Rotation")
		anim.rota:SetDuration(3)
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

function Module.PLAYER_REGEN_ENABLED()
	K:UnregisterEvent("PLAYER_REGEN_ENABLED")
	Module:UpdateSettings()
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

local function GetMinimapShape()
	return "SQUARE"
end

function Module:SetGetMinimapShape()
	-- This is just to support for other mods
	_G.GetMinimapShape = GetMinimapShape
	Minimap:SetSize(C["Minimap"].Size, C["Minimap"].Size)
end

function Module:OnEnable()
	if not C["Minimap"].Enable then
		Minimap:SetMaskTexture([[Interface\CharacterFrame\TempPortraitAlphaMask]])
		Minimap:SetBlipTexture("Interface\\MiniMap\\ObjectIconsAtlas")
		return
	end

	local pos
	local MinimapFrameHolder = CreateFrame("Frame", "MinimapFrameHolder", Minimap)
	if K.CheckAddOnState("TitanClassic") then
		pos = {"TOPRIGHT", UIParent, "TOPRIGHT", -4, -30}
	else
		MinimapFrameHolder:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -4, -4)
		pos = {"TOPRIGHT", UIParent, "TOPRIGHT", -4, -4}
	end
	MinimapFrameHolder:SetSize(C["Minimap"].Size, C["Minimap"].Size)

	Minimap:ClearAllPoints()
	Minimap:SetPoint("CENTER", MinimapFrameHolder, "CENTER", 0, 0)
	Minimap:SetMaskTexture(C["Media"].Blank)
	Minimap:CreateBorder()
	Minimap:CreateInnerShadow(nil, 0.4)
	Minimap:SetScale(1.0)
	-- Minimap:SetBlipTexture(C["Minimap"].BlipTexture.Value) -- Broken for now until we fix our Media file for this.

	Minimap:HookScript("OnEnter", function(mm)
		if C["Minimap"].LocationText.Value ~= "MOUSEOVER" or not C["Minimap"].Enable then
			return
		end

		mm.Location:Show()
	end)

	Minimap:HookScript("OnLeave", function(mm)
		if C["Minimap"].LocationText.Value ~= "MOUSEOVER" or not C["Minimap"].Enable then
			return
		end

		mm.Location:Hide()
	end)

	Minimap.Location = Minimap:CreateFontString(nil, "OVERLAY")
	Minimap.Location:SetFontObject(K.GetFont(C["UIFonts"].DataTextFonts))
	Minimap.Location:SetFont(select(1, Minimap.Location:GetFont()), 13, select(3, Minimap.Location:GetFont()))
	Minimap.Location:SetPoint("TOP", Minimap, "TOP", 0, -4)
	Minimap.Location:SetJustifyH("CENTER")
	Minimap.Location:SetJustifyV("MIDDLE")
	if C["Minimap"].LocationText.Value ~= "SHOW" or not C["Minimap"].Enable then
		Minimap.Location:Hide()
	end

	_G.GameTimeFrame:Hide()
	_G.MiniMapMailBorder:Hide()
	_G.MiniMapMailIcon:SetTexture("Interface\\Addons\\KkthnxUI\\Media\\Textures\\Mail")
	_G.MinimapBorder:Hide()
	_G.MiniMapTracking:Kill()
	_G.MinimapNorthTag:Kill()
	_G.MinimapBorderTop:Hide()
	_G.MinimapZoneTextButton:Hide()
	_G.MinimapZoomIn:Hide()
	_G.MinimapZoomOut:Hide()

	if QueueStatusMinimapButtonBorder then
		QueueStatusMinimapButtonBorder:SetAlpha(0)
		QueueStatusMinimapButtonBorder:SetTexture(nil)
		QueueStatusMinimapButtonIconTexture:SetTexture(nil)
	end

	_G.MiniMapWorldMapButton:Hide()

	if _G.TimeManagerClockButton then
		_G.TimeManagerClockButton:Kill()
	end

	if _G.FeedbackUIButton then
		_G.FeedbackUIButton:Kill()
	end

	_G.Minimap:SetArchBlobRingScalar(0)
	_G.Minimap:SetQuestBlobRingScalar(0)
	_G.MinimapCluster:EnableMouse(false)

	K.Mover(MinimapFrameHolder, "Minimap", "Minimap", pos)

	Minimap:EnableMouseWheel(true)
	Minimap:SetScript("OnMouseWheel", Module.OnMouseWheelScroll)

	K:RegisterEvent("PLAYER_ENTERING_WORLD", self.UpdateZoneText)
	K:RegisterEvent("ZONE_CHANGED_NEW_AREA", self.UpdateZoneText)
	K:RegisterEvent("ZONE_CHANGED", self.UpdateZoneText)
	K:RegisterEvent("ZONE_CHANGED_INDOORS", self.UpdateZoneText)
	K:RegisterEvent("ADDON_LOADED", self.ADDON_LOADED)

	self:UpdateSettings()
	self:SetGetMinimapShape()
	self:WhoPingedMyMap()
	self:CreateRecycleBin()
end