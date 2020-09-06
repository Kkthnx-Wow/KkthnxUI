local K, C = unpack(select(2, ...))
local Module = K:NewModule("Minimap")

local _G = _G
local pairs = _G.pairs
local select = _G.select

local C_Calendar_GetNumPendingInvites = _G.C_Calendar.GetNumPendingInvites
local ERR_NOT_IN_COMBAT = _G.ERR_NOT_IN_COMBAT
local GetUnitName = _G.GetUnitName
local HideUIPanel = _G.HideUIPanel
local InCombatLockdown = _G.InCombatLockdown
local IsAddOnLoaded = _G.IsAddOnLoaded
local UIErrorsFrame = _G.UIErrorsFrame
local UnitClass = _G.UnitClass
local Minimap = _G.Minimap

function Module:CreateStyle()
	local minimapBorder = CreateFrame("Frame", nil, Minimap)
	minimapBorder:SetAllPoints(Minimap)
	minimapBorder:SetFrameLevel(Minimap:GetFrameLevel())
	minimapBorder:CreateBorder(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, true)
	minimapBorder.KKUI_InnerShadow:SetAlpha(0.7)

	local minimapMailPulse = CreateFrame("Frame", nil, Minimap)
	minimapMailPulse:SetBackdrop({edgeFile = "Interface\\AddOns\\KkthnxUI\\Media\\Border\\Border_Glow_Overlay", edgeSize = 12})
	minimapMailPulse:SetPoint("TOPLEFT", minimapBorder, -6, 6)
	minimapMailPulse:SetPoint("BOTTOMRIGHT", minimapBorder, 6, -6)
	minimapMailPulse:SetBackdropBorderColor(1, 1, 0, 0.6)
	minimapMailPulse:Hide()

	local function updateMinimapBorderAnimation()
		if not InCombatLockdown() then
			if C_Calendar_GetNumPendingInvites() > 0 or MiniMapMailFrame:IsShown() and not IsInInstance() then
				minimapMailPulse:Show()
				K.Flash(minimapMailPulse, 1, true)
			else
				minimapMailPulse:Hide()
				K.StopFlash(minimapMailPulse)
			end
		end
	end
	K:RegisterEvent("CALENDAR_UPDATE_PENDING_INVITES", updateMinimapBorderAnimation)
	K:RegisterEvent("PLAYER_REGEN_DISABLED", updateMinimapBorderAnimation)
	K:RegisterEvent("PLAYER_REGEN_ENABLED", updateMinimapBorderAnimation)
	K:RegisterEvent("UPDATE_PENDING_MAIL", updateMinimapBorderAnimation)

	MiniMapMailFrame:HookScript("OnHide", function()
		if InCombatLockdown() then
			return
		end

		minimapMailPulse:Hide()
		K.StopFlash(minimapMailPulse)
	end)
end

function Module:ReskinRegions()
	-- Garrison
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
				GarrisonLandingPageTutorialBox:SetScale(1)
				GarrisonLandingPageTutorialBox:SetClampedToScreen(true)
			end
		end

		if not IsAddOnLoaded("GarrisonMissionManager") then
			GarrisonLandingPageMinimapButton:RegisterForClicks("AnyUp")
			GarrisonLandingPageMinimapButton:HookScript("OnClick", function(_, btn, down)
				if btn == "MiddleButton" and not down then
					HideUIPanel(GarrisonLandingPage)
					ShowGarrisonLandingPage(LE_GARRISON_TYPE_7_0)
				elseif btn == "RightButton" and not down then
					HideUIPanel(GarrisonLandingPage)
					ShowGarrisonLandingPage(LE_GARRISON_TYPE_6_0)
				end
			end)
		end
	end

	-- QueueStatus Button
	if QueueStatusMinimapButton then
		QueueStatusMinimapButton:ClearAllPoints()
		QueueStatusMinimapButton:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMRIGHT", 2, -2)
		QueueStatusMinimapButtonBorder:Hide()
		QueueStatusMinimapButtonIconTexture:SetTexture(nil)

		local queueIcon = Minimap:CreateTexture(nil, "ARTWORK")
		queueIcon:SetPoint("CENTER", QueueStatusMinimapButton)
		queueIcon:SetSize(50, 50)
		queueIcon:SetTexture("Interface\\Minimap\\Raid_Icon")

		local queueIconAnimation = queueIcon:CreateAnimationGroup()
		queueIconAnimation:SetLooping("REPEAT")
		queueIconAnimation.rotation = queueIconAnimation:CreateAnimation("Rotation")
		queueIconAnimation.rotation:SetDuration(2)
		queueIconAnimation.rotation:SetDegrees(360)

		hooksecurefunc("QueueStatusFrame_Update", function()
			queueIcon:SetShown(QueueStatusMinimapButton:IsShown())
		end)

		hooksecurefunc("EyeTemplate_StartAnimating", function()
			queueIconAnimation:Play()
		end)

		hooksecurefunc("EyeTemplate_StopAnimating", function()
			queueIconAnimation:Stop()
		end)
	end

	-- Difficulty Flags
	local difficultyFlags = {
		"MiniMapInstanceDifficulty",
		"GuildInstanceDifficulty",
		"MiniMapChallengeMode"
	}

	for _, v in pairs(difficultyFlags) do
		local difficultyFlag = _G[v]
		difficultyFlag:ClearAllPoints()
		difficultyFlag:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 0, 0)
		difficultyFlag:SetScale(0.9)
	end

	-- Mail icon
	if MiniMapMailFrame then
		MiniMapMailFrame:ClearAllPoints()
		if C["DataText"].Time then
			MiniMapMailFrame:SetPoint("BOTTOM", Minimap, "BOTTOM", 0, 6)
		else
			MiniMapMailFrame:SetPoint("BOTTOM", Minimap, "BOTTOM", 0, -6)
		end
		MiniMapMailIcon:SetTexture("Interface\\Addons\\KkthnxUI\\Media\\Textures\\Mail")
		MiniMapMailFrame:SetScale(1.2)
		MiniMapMailFrame:SetHitRectInsets(8, 8, 12, 11)
	end

	-- Invites Icon
	if GameTimeCalendarInvitesTexture then
		GameTimeCalendarInvitesTexture:ClearAllPoints()
		GameTimeCalendarInvitesTexture:SetParent("Minimap")
		GameTimeCalendarInvitesTexture:SetPoint("TOPRIGHT")
	end

	local inviteNotification = CreateFrame("Button", nil, UIParent)
	inviteNotification:SetBackdrop({edgeFile = "Interface\\AddOns\\KkthnxUI\\Media\\Border\\Border_Glow_Overlay", edgeSize = 13})
	inviteNotification:SetPoint("TOPLEFT", Minimap, -6, 6)
	inviteNotification:SetPoint("BOTTOMRIGHT", Minimap, 6, -6)
	inviteNotification:SetBackdropBorderColor(1, 1, 0)
	inviteNotification:Hide()

	K.CreateFontString(inviteNotification, 12, K.InfoColor.."Pending Calendar Invite(s)!", "")

	local function updateInviteVisibility()
		inviteNotification:SetShown(C_Calendar_GetNumPendingInvites() > 0)
	end
	K:RegisterEvent("CALENDAR_UPDATE_PENDING_INVITES", updateInviteVisibility)
	K:RegisterEvent("PLAYER_ENTERING_WORLD", updateInviteVisibility)

	inviteNotification:SetScript("OnClick", function(_, btn)
		inviteNotification:Hide()

		if btn == "LeftButton" and not InCombatLockdown() then
			ToggleCalendar()
		end

		K:UnregisterEvent("CALENDAR_UPDATE_PENDING_INVITES", updateInviteVisibility)
		K:UnregisterEvent("PLAYER_ENTERING_WORLD", updateInviteVisibility)
	end)
end

function Module:CreatePing()
	local pingFrame = CreateFrame("Frame", nil, Minimap)
	pingFrame:SetAllPoints()
	pingFrame.text = K.CreateFontString(pingFrame, 16, "", "", false, "TOP", 0, C["DataText"].Location and -24 or -6)

	local pingAnimation = pingFrame:CreateAnimationGroup()

	pingAnimation:SetScript("OnPlay", function()
		pingFrame:SetAlpha(1)
	end)

	pingAnimation:SetScript("OnFinished", function()
		pingFrame:SetAlpha(0)
	end)

	pingAnimation.fader = pingAnimation:CreateAnimation("Alpha")
	pingAnimation.fader:SetFromAlpha(1)
	pingAnimation.fader:SetToAlpha(0)
	pingAnimation.fader:SetDuration(3)
	pingAnimation.fader:SetSmoothing("OUT")
	pingAnimation.fader:SetStartDelay(3)

	K:RegisterEvent("MINIMAP_PING", function(_, unit)
		if unit == "player" then -- Do show ourself. -.-
			return
		end

		local class = select(2, UnitClass(unit))
		local r, g, b = K.ColorClass(class)
		local name = GetUnitName(unit)

		pingAnimation:Stop()
		pingFrame.text:SetText(name)
		pingFrame.text:SetTextColor(r, g, b)
		pingAnimation:Play()
	end)
end

function Module:UpdateMinimapScale()
	local size = C["Minimap"].Size
	Minimap:SetSize(size, size)
	Minimap.mover:SetSize(size, size)
end

function Module:OnEnable()
	-- Shape and Position
	Minimap:SetFrameLevel(10)
	Minimap:SetMaskTexture(C["Media"].Blank)
	DropDownList1:SetClampedToScreen(true)

	local minimapMover = K.Mover(Minimap, "Minimap", "Minimap", {"TOPRIGHT", UIParent, "TOPRIGHT", -4, -4})
	Minimap:ClearAllPoints()
	Minimap:SetPoint("TOPRIGHT", minimapMover)
	Minimap.mover = minimapMover

	self:UpdateMinimapScale()

	-- Mousewheel Zoom
	Minimap:EnableMouseWheel(true)
	Minimap:SetScript("OnMouseWheel", function(_, zoom)
		if zoom > 0 then
			Minimap_ZoomIn()
		else
			Minimap_ZoomOut()
		end
	end)

	-- Click Func
	Minimap:SetScript("OnMouseUp", function(self, btn)
		if btn == "MiddleButton" then
			if InCombatLockdown() then
				UIErrorsFrame:AddMessage(K.InfoColor..ERR_NOT_IN_COMBAT)
				return
			end
			ToggleCalendar()
		elseif btn == "RightButton" then
			ToggleDropDownMenu(1, nil, MiniMapTrackingDropDown, self, -(self:GetWidth() * 0.7), (self:GetWidth() * 0.3))
		else
			Minimap_OnClick(self)
		end
	end)

	-- Hide Blizz
	local frames = {
		"GameTimeFrame",
		"MinimapBorder",
		"MinimapBorderTop",
		"MiniMapMailBorder",
		"MinimapNorthTag",
		"MiniMapTracking",
		"MiniMapWorldMapButton",
		"MinimapZoneTextButton",
		"MinimapZoomIn",
		"MinimapZoomOut",
		"TimeManagerClockButton"
	}

	for _, v in pairs(frames) do
		K.HideInterfaceOption(_G[v])
	end

	MinimapCluster:EnableMouse(false)
	Minimap:SetArchBlobRingScalar(0)
	Minimap:SetQuestBlobRingScalar(0)

	-- Add Elements
	self:CreatePing()
	self:CreateStyle()
	self:CreateRecycleBin()
	self:ReskinRegions()
end