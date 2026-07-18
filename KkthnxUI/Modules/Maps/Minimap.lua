--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Handles minimap adjustments, custom micro menu, and element skinning.
-- - Design: Hooks into Minimap events and clusters to provide a streamlined experience.
-- - Events: CALENDAR_UPDATE_PENDING_INVITES, PLAYER_REGEN_DISABLED, PLAYER_REGEN_ENABLED, UPDATE_PENDING_MAIL, MINIMAP_PING, ADDON_LOADED
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:NewModule("Minimap")

-- PERF: Localize global functions and environment for faster lookups in high-frequency events.
local math_floor = _G.math.floor
local string_find = _G.string.find

local _G = _G
local C_AddOns_IsAddOnLoaded = _G.C_AddOns and _G.C_AddOns.IsAddOnLoaded
local C_Calendar_GetNumPendingInvites = _G.C_Calendar and _G.C_Calendar.GetNumPendingInvites
local C_DateAndTime_GetCurrentCalendarTime = _G.C_DateAndTime and _G.C_DateAndTime.GetCurrentCalendarTime
local C_Garrison_HasGarrison = _G.C_Garrison and _G.C_Garrison.HasGarrison
local CreateFrame = _G.CreateFrame
local GameTooltip = _G.GameTooltip
local GetTime = _G.GetTime
local GetUnitName = _G.GetUnitName
local InCombatLockdown = _G.InCombatLockdown
local IsAltKeyDown = _G.IsAltKeyDown
local IsControlKeyDown = _G.IsControlKeyDown
local IsShiftKeyDown = _G.IsShiftKeyDown
local Minimap = _G.Minimap
local MinimapCluster = _G.MinimapCluster
local SOUNDKIT = _G.SOUNDKIT
local ToggleCalendar = _G.ToggleCalendar
local UIParent = _G.UIParent
local UnitClass = _G.UnitClass
local UnitIsUnit = _G.UnitIsUnit
local hooksecurefunc = _G.hooksecurefunc
local ipairs = _G.ipairs
local pcall = _G.pcall
local select = _G.select
local tostring = _G.tostring
local type = _G.type
local unpack = _G.unpack

-- REASON: Blizzard helpers (may not exist on all clients).
local Minimap_OnClick = _G.Minimap_OnClick
local Minimap_OnMouseUp = _G.Minimap_OnMouseUp

function Module:CreateStyle()
	local minimapBorder = CreateFrame("Frame", "KKUI_MinimapBorder", Minimap)
	minimapBorder:SetAllPoints(Minimap)
	minimapBorder:SetFrameLevel(Minimap:GetFrameLevel())
	minimapBorder:SetFrameStrata("LOW")
	minimapBorder:CreateBorder()

	if not C["Minimap"].MailPulse then
		return
	end

	local indicatorFrame = MinimapCluster and MinimapCluster.IndicatorFrame
	local minimapMailFrame = indicatorFrame and indicatorFrame.MailFrame

	local minimapMailPulse = CreateFrame("Frame", nil, Minimap, "BackdropTemplate")
	minimapMailPulse:SetBackdrop({
		edgeFile = "Interface\\AddOns\\KkthnxUI\\Media\\Border\\Border_Glow_Overlay",
		edgeSize = 12,
	})
	minimapMailPulse:SetPoint("TOPLEFT", minimapBorder, -5, 5)
	minimapMailPulse:SetPoint("BOTTOMRIGHT", minimapBorder, 5, -5)
	minimapMailPulse:Hide()

	local anim = minimapMailPulse:CreateAnimationGroup()
	anim:SetLooping("BOUNCE")
	anim.fader = anim:CreateAnimation("Alpha")
	anim.fader:SetFromAlpha(0.8)
	anim.fader:SetToAlpha(0.2)
	anim.fader:SetDuration(1)
	anim.fader:SetSmoothing("OUT")

	Module.minimapMailPulse = minimapMailPulse
	Module.minimapMailAnim = anim

	-- REASON: Updates the border pulse animation based on combat status or pending invites/mail.
	local function updateMinimapBorderAnimation()
		local borderColor

		if InCombatLockdown() then
			borderColor = { 1, 0, 0, 0.8 }
		else
			local invites = C_Calendar_GetNumPendingInvites and C_Calendar_GetNumPendingInvites() or 0
			if invites > 0 or (minimapMailFrame and minimapMailFrame:IsShown()) then
				borderColor = { 1, 1, 0, 0.8 }
			end
		end

		if borderColor then
			minimapMailPulse:Show()
			minimapMailPulse:SetBackdropBorderColor(unpack(borderColor))
			if not anim:IsPlaying() then
				anim:Play()
			end
		else
			if anim:IsPlaying() then
				anim:Stop()
			end
			minimapMailPulse:Hide()
			minimapMailPulse:SetBackdropBorderColor(1, 1, 0, 0.8)
		end
	end

	K:RegisterEvent("CALENDAR_UPDATE_PENDING_INVITES", updateMinimapBorderAnimation)
	K:RegisterEvent("PLAYER_REGEN_DISABLED", updateMinimapBorderAnimation)
	K:RegisterEvent("PLAYER_REGEN_ENABLED", updateMinimapBorderAnimation)
	K:RegisterEvent("UPDATE_PENDING_MAIL", updateMinimapBorderAnimation)
	Module._mailPulseBorderUpdate = updateMinimapBorderAnimation

	if minimapMailFrame then
		minimapMailFrame:HookScript("OnHide", function()
			if InCombatLockdown() then
				return
			end

			if anim:IsPlaying() then
				anim:Stop()
				minimapMailPulse:Hide()
			end
		end)
	end
end

local function toggleLandingPage(_, ...)
	if not (C_Garrison_HasGarrison and C_Garrison_HasGarrison(...)) then
		_G.UIErrorsFrame:AddMessage(K.InfoColor .. _G.CONTRIBUTION_TOOLTIP_UNLOCKED_WHEN_ACTIVE)
		return
	end
	_G.ShowGarrisonLandingPage(...)
end

function Module:ReskinRegions()
	-- REASON: Garrison / Expansion Landing Page Minimap Button (mirror Blizzard behavior).
	local garrMinimapButton = _G.ExpansionLandingPageMinimapButton
	if garrMinimapButton then
		local buttonTextureIcon = "ShipMissionIcon-Combat-Mission"

		local function skinLandingPageButton(self)
			local normal = self:GetNormalTexture()
			local pushed = self:GetPushedTexture()
			local highlight = self:GetHighlightTexture()

			if normal and normal.SetAtlas then
				normal:SetAtlas(buttonTextureIcon)
				normal:SetVertexColor(1, 1, 1, 1)
			end
			if pushed and pushed.SetAtlas then
				pushed:SetAtlas(buttonTextureIcon)
				pushed:SetVertexColor(1, 1, 1, 1)
			end
			if highlight and highlight.SetAtlas then
				highlight:SetAtlas(buttonTextureIcon)
				highlight:SetVertexColor(1, 1, 1, 1)
			end
			if self.LoopingGlow and self.LoopingGlow.SetAtlas then
				self.LoopingGlow:SetAtlas(buttonTextureIcon)
				self.LoopingGlow:SetSize(26, 26)
			end

			self:SetSize(26, 26)
		end

		local function positionLandingPageButton(self)
			self:ClearAllPoints()
			self:SetPoint("BOTTOMLEFT", Minimap, "BOTTOMLEFT", 4, 4)
			self:SetHitRectInsets(0, 0, 0, 0)
		end

		local function refreshLandingPageButton(self)
			positionLandingPageButton(self)
			skinLandingPageButton(self)
		end

		refreshLandingPageButton(garrMinimapButton)
		garrMinimapButton:HookScript("OnShow", refreshLandingPageButton)
		hooksecurefunc(garrMinimapButton, "UpdateIcon", refreshLandingPageButton)

		local landingMenuList = {
			{ text = _G.GARRISON_TYPE_9_0_LANDING_PAGE_TITLE, func = toggleLandingPage, arg1 = _G.Enum.GarrisonType.Type_9_0_Garrison, notCheckable = true },
			{ text = _G.GARRISON_TYPE_8_0_LANDING_PAGE_TITLE, func = toggleLandingPage, arg1 = _G.Enum.GarrisonType.Type_8_0_Garrison, notCheckable = true },
			{ text = _G.ORDER_HALL_LANDING_PAGE_TITLE, func = toggleLandingPage, arg1 = _G.Enum.GarrisonType.Type_7_0_Garrison, notCheckable = true },
			{ text = _G.GARRISON_LANDING_PAGE_TITLE, func = toggleLandingPage, arg1 = _G.Enum.GarrisonType.Type_6_0_Garrison, notCheckable = true },
		}

		garrMinimapButton:HookScript("OnMouseDown", function(self, btn)
			if btn == "RightButton" then
				if _G.GarrisonLandingPage and _G.GarrisonLandingPage:IsShown() then
					_G.HideUIPanel(_G.GarrisonLandingPage)
				end
				if _G.ExpansionLandingPage and _G.ExpansionLandingPage:IsShown() then
					_G.HideUIPanel(_G.ExpansionLandingPage)
				end
				K.LibEasyMenu.Create(landingMenuList, K.EasyMenu, self, -80, 0, "MENU", 1)
			end
		end)

		garrMinimapButton:HookScript("OnEnter", function(self)
			if GameTooltip and GameTooltip:IsOwned(self) then
				GameTooltip:AddLine("\n" .. (L and (L["Right Click to switch Summaries"] or "Right Click to switch Summaries") or "Right Click to switch Summaries"), 1, 1, 1, true)
				GameTooltip:Show()
			end
		end)
	end

	-- REASON: QueueStatus Button. Re-parents and skins the queue/LFG eye indicator.
	local queueStatusButton = _G.QueueStatusButton
	if queueStatusButton then
		local queueStatusButtonIcon = _G.QueueStatusButtonIcon
		local queueStatusFrame = _G.QueueStatusFrame

		queueStatusButton:SetParent(MinimapCluster)
		queueStatusButton:SetSize(24, 24)
		queueStatusButton:SetFrameLevel(20)
		queueStatusButton:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMRIGHT", -4, 4)

		if queueStatusButtonIcon then
			queueStatusButtonIcon:SetAlpha(0)
		end
		if queueStatusFrame then
			queueStatusFrame:SetPoint("TOPRIGHT", queueStatusButton, "TOPLEFT")
		end

		hooksecurefunc(queueStatusButton, "SetPoint", function(button, _, _, _, x, y)
			if not (x == -4 and y == 4) then
				button:ClearAllPoints()
				button:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMRIGHT", -4, 4)
			end
		end)

		local queueIcon = Minimap:CreateTexture(nil, "ARTWORK")
		queueIcon:SetPoint("CENTER", queueStatusButton)
		queueIcon:SetSize(56, 56)
		queueIcon:SetTexture("Interface\\Minimap\\Dungeon_Icon")

		local anim = queueIcon:CreateAnimationGroup()
		anim:SetLooping("REPEAT")
		anim.rota = anim:CreateAnimation("Rotation")
		anim.rota:SetDuration(2)
		anim.rota:SetDegrees(360)

		if queueStatusFrame then
			hooksecurefunc(queueStatusFrame, "Update", function()
				queueIcon:SetShown(queueStatusButton:IsShown())
			end)
		end

		if queueStatusButton.Eye then
			hooksecurefunc(queueStatusButton.Eye, "PlayAnim", function()
				anim:Play()
			end)
			hooksecurefunc(queueStatusButton.Eye, "StopAnimating", function()
				anim:Pause()
			end)
		end

		local queueStatusDisplay = Module.QueueStatusDisplay
		if queueStatusDisplay then
			queueStatusDisplay.text:ClearAllPoints()
			queueStatusDisplay.text:SetPoint("CENTER", queueStatusButton, 0, -5)
			queueStatusDisplay.text:SetFontObject(K.UIFont)
			queueStatusDisplay.text:SetFont(select(1, queueStatusDisplay.text:GetFont()), 13, select(3, queueStatusDisplay.text:GetFont()))

			if queueStatusDisplay.title then
				Module:ClearQueueStatus()
			end
		end
	end

	-- REASON: Difficulty Flags. Anchors and skins the instance difficulty indicators.
	local instDifficulty = MinimapCluster and MinimapCluster.InstanceDifficulty
	if instDifficulty then
		instDifficulty:SetParent(Minimap)
		instDifficulty:SetScale(0.9)

		local function updateFlagAnchor(frame)
			local p, rel, rp, x, y = frame:GetPoint()
			if p == "TOPLEFT" and rel == Minimap and rp == "TOPLEFT" and x == 2 and y == -2 then
				return
			end
			frame:ClearAllPoints()
			frame:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 2, -2)
		end

		updateFlagAnchor(instDifficulty)
		hooksecurefunc(instDifficulty, "SetPoint", updateFlagAnchor)

		local function replaceFlagTexture(texture)
			texture:SetTexture(K.MediaFolder .. "Minimap\\Flag")
		end

		local function reskinDifficultyFrame(frame)
			if not frame then
				return
			end
			if frame.Border then
				frame.Border:Hide()
			end
			replaceFlagTexture(frame.Background)
			hooksecurefunc(frame.Background, "SetAtlas", replaceFlagTexture)
		end

		reskinDifficultyFrame(instDifficulty.Instance)
		reskinDifficultyFrame(instDifficulty.Guild)
		reskinDifficultyFrame(instDifficulty.ChallengeMode)
	end

	-- REASON: Indicator Frame (mail/calendar, etc.). Managed via a helper to ensure consistent positioning.
	local function updateIndicatorAnchor(frame)
		if not frame then
			return
		end

		local wantY = (C["DataText"].Time and 20) or 4
		local p, rel, rp, x, y = frame:GetPoint()
		if not (p == "BOTTOM" and rel == Minimap and rp == "BOTTOM" and x == 0 and y == wantY) then
			frame:ClearAllPoints()
			frame:SetPoint("BOTTOM", Minimap, "BOTTOM", 0, wantY)
		end
	end

	local indicatorFrame = MinimapCluster and MinimapCluster.IndicatorFrame
	if indicatorFrame then
		updateIndicatorAnchor(indicatorFrame)
		hooksecurefunc(indicatorFrame, "SetPoint", updateIndicatorAnchor)
		indicatorFrame:SetFrameLevel(11)
	end

	-- REASON: Invites Icon. Re-parents and reposition the guest/calendar invite notification.
	local gameTimeCalendarInvitesTexture = _G.GameTimeCalendarInvitesTexture
	if gameTimeCalendarInvitesTexture then
		gameTimeCalendarInvitesTexture:ClearAllPoints()
		gameTimeCalendarInvitesTexture:SetParent(Minimap)
		gameTimeCalendarInvitesTexture:SetPoint("TOPLEFT")
	end

	-- REASON: Streaming icon. Adjusts the position/visibility of the background downloader icon.
	local streamingIcon = _G.StreamingIcon
	if streamingIcon then
		streamingIcon:ClearAllPoints()
		streamingIcon:SetParent(Minimap)
		streamingIcon:SetPoint("LEFT", -6, 0)
		streamingIcon:SetAlpha(0.5)
		streamingIcon:SetScale(0.8)
		streamingIcon:SetFrameStrata("LOW")
	end

	-- REASON: Calendar invite notification border. Provides a visual glow when an invite is pending.
	local inviteNotification = CreateFrame("Button", nil, Minimap, "BackdropTemplate")
	inviteNotification:SetBackdrop({
		edgeFile = "Interface\\AddOns\\KkthnxUI\\Media\\Border\\Border_Glow_Overlay",
		edgeSize = 12,
	})
	inviteNotification:SetPoint("TOPLEFT", Minimap, -5, 5)
	inviteNotification:SetPoint("BOTTOMRIGHT", Minimap, 5, -5)
	inviteNotification:SetBackdropBorderColor(1, 1, 0, 0.8)
	inviteNotification:Hide()

	K.CreateFontString(inviteNotification, 12, K.InfoColor .. ((L and L["Pending Calendar Invite(s)!"]) or "Pending Calendar Invite(s)!"), "")

	local function updateInviteVisibility()
		local invites = C_Calendar_GetNumPendingInvites and C_Calendar_GetNumPendingInvites() or 0
		inviteNotification:SetShown(invites > 0)
	end
	K:RegisterEvent("CALENDAR_UPDATE_PENDING_INVITES", updateInviteVisibility)
	K:RegisterEvent("PLAYER_ENTERING_WORLD", updateInviteVisibility)

	inviteNotification:SetScript("OnClick", function(_, btn)
		inviteNotification:Hide()

		if btn == "LeftButton" and ToggleCalendar then
			ToggleCalendar()
		end

		K:UnregisterEvent("CALENDAR_UPDATE_PENDING_INVITES", updateInviteVisibility)
		K:UnregisterEvent("PLAYER_ENTERING_WORLD", updateInviteVisibility)
	end)
end

function Module:CreatePing()
	-- MIDNIGHT (12.0): Blizzard removed the legacy minimap ping info event.
	-- Disabled on 12.x for the same reason.
	if K.TocVersion and K.TocVersion >= 120000 then
		return
	end

	local pingFrame = CreateFrame("Frame", nil, Minimap)
	pingFrame:SetSize(Minimap:GetWidth(), 13)
	pingFrame:SetPoint("BOTTOM", Minimap, "BOTTOM", 0, 30)
	pingFrame.text = K.CreateFontString(pingFrame, 13, "", "OUTLINE", false, "CENTER")

	local pingAnimation = pingFrame:CreateAnimationGroup()
	pingAnimation:SetScript("OnPlay", function()
		pingFrame:SetAlpha(0.8)
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

	-- REASON: Displays the name and class color of the player who pinged the minimap.
	local ok = pcall(K.RegisterEvent, K, "MINIMAP_PING", function(_, unit)
		if UnitIsUnit(unit, "player") then
			return
		end

		local class = select(2, UnitClass(unit))
		local name = GetUnitName(unit)
		if not class or not name then
			return
		end

		local r, g, b = K.ColorClass(class)

		pingAnimation:Stop()
		pingFrame.text:SetText(name)
		pingFrame.text:SetTextColor(r, g, b)
		pingAnimation:Play()
	end)
	if not ok then
		pingFrame:Hide()
	end
end

function Module:UpdateMinimapScale()
	local minimapSize = C["Minimap"].Size
	Minimap:SetSize(minimapSize, minimapSize)
	if Minimap.mover then
		Minimap.mover:SetSize(minimapSize, minimapSize)
	end
end

Module.UpdateSize = Module.UpdateMinimapScale

function Module:UpdateEasyVolume()
	if C["Minimap"].EasyVolume then
		if not self.VolumeText then
			self:CreateSoundVolume()
		end
	elseif self.VolumeText then
		local parent = self.VolumeText:GetParent()
		if parent then
			parent:Hide()
		end
	end
end

function Module:UpdateMailPulse()
	if self.minimapMailPulse then
		if C["Minimap"].MailPulse then
			self.minimapMailPulse:Show()
		else
			if self.minimapMailAnim and self.minimapMailAnim:IsPlaying() then
				self.minimapMailAnim:Stop()
			end
			self.minimapMailPulse:Hide()
		end
	end
end

function Module:UpdateRecycleBin()
	self:CreateRecycleBin()
end

function Module:UpdateCalendar()
	Module:ShowCalendar()
end

function Module:UpdateQueueStatusText()
	if not C["Minimap"].QueueStatusText then
		Module:ClearQueueStatus()
	end
end

-- REASON: Required by LibDBIcon-1.0 and similar libraries to determine circular vs square button placement.
-- FIX: The previous version lazily initialized UpdateMinimapScale() here on first call, hiding a side-effect
-- inside a utility stub. Scale is now initialized explicitly in OnEnable; this function is pure.
function _G.GetMinimapShape()
	return "SQUARE"
end

function Module:HideMinimapClock()
	local timeManagerClockButton = _G.TimeManagerClockButton
	if timeManagerClockButton then
		timeManagerClockButton:Hide()
	end
end

local isGameTimeFrameStyled = false
function Module:ShowCalendar()
	local gameTimeFrame = _G.GameTimeFrame
	if not gameTimeFrame then
		return
	end

	if C["Minimap"].Calendar then
		if not isGameTimeFrameStyled then
			local calendarText = K.CreatePlainFS(gameTimeFrame, 12, nil, "OVERLAY")

			gameTimeFrame:SetParent(Minimap)
			gameTimeFrame:SetFrameLevel(16)
			gameTimeFrame:ClearAllPoints()
			gameTimeFrame:SetPoint("TOPRIGHT", Minimap, -4, -4)
			gameTimeFrame:SetHitRectInsets(0, 0, 0, 0)
			gameTimeFrame:SetSize(22, 22)

			calendarText:ClearAllPoints()
			calendarText:SetPoint("CENTER", 0, -4)
			calendarText:SetTextColor(0, 0, 0)
			calendarText:SetAlpha(0.9)

			-- REASON: Skins the calendar icon and updates the date text whenever it changes.
			hooksecurefunc("GameTimeFrame_SetDate", function()
				gameTimeFrame:SetNormalTexture("Interface\\AddOns\\KkthnxUI\\Media\\Minimap\\Calendar.blp")
				gameTimeFrame:SetPushedTexture("Interface\\AddOns\\KkthnxUI\\Media\\Minimap\\Calendar.blp")
				gameTimeFrame:SetHighlightTexture(0)
				gameTimeFrame:GetNormalTexture():SetTexCoord(0, 1, 0, 1)
				gameTimeFrame:GetPushedTexture():SetTexCoord(0, 1, 0, 1)

				if C_DateAndTime_GetCurrentCalendarTime then
					K.SetPlainText(calendarText, C_DateAndTime_GetCurrentCalendarTime().monthDay)
				end
			end)

			isGameTimeFrameStyled = true
		end

		gameTimeFrame:Show()
	else
		gameTimeFrame:Hide()
	end
end

local function getVolumeColor(current)
	local r, g, b = K.oUF:RGBColorGradient(current, 100, 1, 1, 1, 1, 0.8, 0, 1, 0, 0)
	return r, g, b
end

local function getCurrentVolume()
	return K.Round(_G.GetCVar("Sound_MasterVolume") * 100)
end

function Module:CreateSoundVolume()
	if not C["Minimap"].EasyVolume then
		return
	end

	local volumeFrame = CreateFrame("Frame", nil, Minimap)
	volumeFrame:SetAllPoints()

	local volumeText = K.CreateFontString(volumeFrame, 30)
	local volumeAnim = volumeFrame:CreateAnimationGroup()
	volumeAnim:SetScript("OnPlay", function()
		volumeFrame:SetAlpha(1)
	end)
	volumeAnim:SetScript("OnFinished", function()
		volumeFrame:SetAlpha(0)
	end)

	volumeAnim.fader = volumeAnim:CreateAnimation("Alpha")
	volumeAnim.fader:SetFromAlpha(1)
	volumeAnim.fader:SetToAlpha(0)
	volumeAnim.fader:SetDuration(3)
	volumeAnim.fader:SetSmoothing("OUT")
	volumeAnim.fader:SetStartDelay(1)

	Module.VolumeText = volumeText
	Module.VolumeAnim = volumeAnim
end

-- REASON: Allows adjusting the master volume via Ctrl + MouseWheel on the minimap.
function Module.Minimap_OnMouseWheel(_, zoom)
	if IsControlKeyDown() and Module.VolumeText then
		local volumeMult = IsAltKeyDown() and 100 or 2
		local volumeValue = getCurrentVolume() + zoom * volumeMult

		if volumeValue > 100 then
			volumeValue = 100
		elseif volumeValue < 0 then
			volumeValue = 0
		end

		_G.SetCVar("Sound_MasterVolume", tostring(volumeValue / 100))
		Module.VolumeText:SetText(volumeValue .. "%")
		Module.VolumeText:SetTextColor(getVolumeColor(volumeValue))
		Module.VolumeAnim:Stop()
		Module.VolumeAnim:Play()
	else
		if zoom > 0 then
			_G.Minimap_ZoomIn()
		else
			_G.Minimap_ZoomOut()
		end
	end
end

function Module.Minimap_OnMouseUp(_, btn)
	K.EasyMenu:Hide()

	local anchorPoint = Minimap.mover and Minimap.mover:GetPoint()
	if btn == "MiddleButton" or (btn == "RightButton" and IsShiftKeyDown()) then
		if InCombatLockdown() then
			_G.UIErrorsFrame:AddMessage(K.InfoColor .. _G.ERR_NOT_IN_COMBAT)
			return
		end

		if anchorPoint and string_find(anchorPoint, "LEFT") then
			K.LibEasyMenu.Create(Module:GetMicroMenuList(), K.EasyMenu, "cursor", 0, 0)
		else
			K.LibEasyMenu.Create(Module:GetMicroMenuList(), K.EasyMenu, "cursor", -160, 0)
		end
	elseif btn == "RightButton" then
		local trackingButton = MinimapCluster and MinimapCluster.Tracking and MinimapCluster.Tracking.Button
		if trackingButton and trackingButton.OpenMenu then
			trackingButton:OpenMenu()
			if trackingButton.menu then
				local isRightPosition = anchorPoint and string_find(anchorPoint, "RIGHT")
				trackingButton.menu:ClearAllPoints()
				trackingButton.menu:SetPoint(isRightPosition and "TOPRIGHT" or "TOPLEFT", Minimap, isRightPosition and "LEFT" or "RIGHT", isRightPosition and -4 or 4, 0)
			end
		end
	else
		-- REASON: Preserves Blizzard's default minimap click behavior for pinging and clicking.
		if Minimap and Minimap.OnClick then
			Minimap:OnClick(btn)
		elseif Minimap_OnClick then
			Minimap_OnClick(Minimap, btn)
		elseif Minimap_OnMouseUp then
			Minimap_OnMouseUp(Minimap, btn)
		else
			Minimap:Click()
		end
	end
end

function Module:SetupHybridMinimap()
	local hybridMinimap = _G.HybridMinimap
	if hybridMinimap and hybridMinimap.CircleMask then
		hybridMinimap.CircleMask:SetTexture("Interface\\BUTTONS\\WHITE8X8")
	end
end

function Module.HybridMinimapOnLoad(event, addon)
	if addon == "Blizzard_HybridMinimap" then
		Module:SetupHybridMinimap()
		K:UnregisterEvent("ADDON_LOADED", Module.HybridMinimapOnLoad)
	end
end

function Module:QueueStatusTimeFormat(seconds)
	local statusDisplay = Module.QueueStatusDisplay
	if not (statusDisplay and statusDisplay.text) then
		return
	end

	local hours = math_floor((seconds % 86400) / 3600)
	if hours > 0 then
		statusDisplay.text:SetFormattedText("%d" .. K.MyClassColor .. "h", hours)
		return
	end

	local minutes = math_floor((seconds % 3600) / 60)
	if minutes > 0 then
		statusDisplay.text:SetFormattedText("%d" .. K.MyClassColor .. "m", minutes)
		return
	end

	local remainingSeconds = math_floor(seconds % 60)
	if remainingSeconds > 0 then
		statusDisplay.text:SetFormattedText("%d" .. K.MyClassColor .. "s", remainingSeconds)
	end
end

function Module:QueueStatusSetTime(seconds)
	local statusDisplay = Module.QueueStatusDisplay
	if not statusDisplay then
		return
	end

	local timeInQueue = GetTime() - seconds
	Module:QueueStatusTimeFormat(timeInQueue)
	statusDisplay.text:SetTextColor(1, 1, 1)
end

function Module:QueueStatusOnUpdate(elapsed)
	self.updateThrottle = self.updateThrottle - elapsed
	if self.updateThrottle <= 0 then
		Module:QueueStatusSetTime(self.queuedTime)
		self.updateThrottle = 0.1
	end
end

function Module:SetFullQueueStatus(title, queuedTime, averageWait)
	if not C["Minimap"].QueueStatusText then
		return
	end

	local statusDisplay = Module.QueueStatusDisplay
	if not statusDisplay then
		return
	end

	-- SECRET: never compare or store opaque queue titles.
	if title and not K.NotSecret(title) then
		return
	end

	if not statusDisplay.title or statusDisplay.title == title then
		if queuedTime then
			statusDisplay.title = title
			statusDisplay.updateThrottle = 0
			statusDisplay.queuedTime = queuedTime
			statusDisplay.averageWait = averageWait
			statusDisplay:SetScript("OnUpdate", Module.QueueStatusOnUpdate)
		else
			Module:ClearQueueStatus()
		end
	end
end

function Module:SetMinimalQueueStatus(title)
	local statusDisplay = Module.QueueStatusDisplay
	if not statusDisplay then
		return
	end
	if title and not K.NotSecret(title) then
		return
	end
	if statusDisplay.title == title then
		Module:ClearQueueStatus()
	end
end

function Module:ClearQueueStatus()
	local statusDisplay = Module.QueueStatusDisplay
	if not statusDisplay then
		return
	end

	statusDisplay.text:SetText("")
	statusDisplay.title = nil
	statusDisplay.queuedTime = nil
	statusDisplay.averageWait = nil
	statusDisplay:SetScript("OnUpdate", nil)
end

function Module:CreateQueueStatusText()
	local queueStatusButton = _G.QueueStatusButton
	if not queueStatusButton then
		return
	end

	local statusDisplay = CreateFrame("Frame", "KKUI_QueueStatusDisplay", queueStatusButton)
	statusDisplay.text = statusDisplay:CreateFontString(nil, "OVERLAY")

	Module.QueueStatusDisplay = statusDisplay

	queueStatusButton:HookScript("OnHide", Module.ClearQueueStatus)
	hooksecurefunc("QueueStatusEntry_SetMinimalDisplay", Module.SetMinimalQueueStatus)
	hooksecurefunc("QueueStatusEntry_SetFullDisplay", Module.SetFullQueueStatus)
end

function Module:BlizzardACF()
	local addonCompartmentFrame = _G.AddonCompartmentFrame
	if not addonCompartmentFrame then
		return
	end

	if C["Minimap"].ShowRecycleBin then
		K.HideInterfaceOption(addonCompartmentFrame)
	else
		addonCompartmentFrame:ClearAllPoints()
		addonCompartmentFrame:SetPoint("BOTTOMRIGHT", Minimap, -26, 2)
		addonCompartmentFrame:SetFrameLevel(999)
		addonCompartmentFrame:StripTextures()
		addonCompartmentFrame:CreateBorder()
	end
end

function Module:OnEnable()
	if C["Minimap"].Enable then
		self:InitMinimap()
	end
end

function Module:ApplyMinimapCustomization()
	Minimap:SetFrameLevel(10)
	Minimap:SetMaskTexture(C["Media"].Textures.White8x8Texture)

	if Minimap.mover then
		Minimap:ClearAllPoints()
		Minimap:SetPoint("TOPRIGHT", Minimap.mover)
	end

	self:UpdateMinimapScale()

	if MinimapCluster then
		MinimapCluster:EnableMouse(false)
		if MinimapCluster.Tracking then
			MinimapCluster.Tracking:SetAlpha(0)
			MinimapCluster.Tracking:SetScale(0.0001)
		end
		if MinimapCluster.BorderTop then
			MinimapCluster.BorderTop:Hide()
		end
		if MinimapCluster.ZoneTextButton then
			MinimapCluster.ZoneTextButton:Hide()
		end
	end

	Minimap:SetArchBlobRingScalar(0)
	Minimap:SetQuestBlobRingScalar(0)

	if Minimap.ZoomIn then
		K.HideInterfaceOption(Minimap.ZoomIn)
	end
	if Minimap.ZoomOut then
		K.HideInterfaceOption(Minimap.ZoomOut)
	end
	if _G.MinimapCompassTexture then
		K.HideInterfaceOption(_G.MinimapCompassTexture)
	end

	if _G.KKUI_MinimapBorder then
		_G.KKUI_MinimapBorder:Show()
	end

	self:HideMinimapClock()
end

function Module:RestoreDefaultMinimapLayout()
	if MinimapCluster then
		Minimap:SetParent(MinimapCluster)
		Minimap:ClearAllPoints()
		Minimap:SetPoint("CENTER", MinimapCluster, "CENTER", 0, 0)

		MinimapCluster:EnableMouse(true)
		if MinimapCluster.Tracking then
			K.ShowInterfaceOption(MinimapCluster.Tracking)
		end
		if MinimapCluster.BorderTop then
			MinimapCluster.BorderTop:Show()
		end
		if MinimapCluster.ZoneTextButton then
			MinimapCluster.ZoneTextButton:Show()
		end
	end

	Minimap:SetMaskTexture("Interface\\BUTTONS\\UI-Minimap-Button")
	Minimap:SetArchBlobRingScalar(1)
	Minimap:SetQuestBlobRingScalar(1)

	if Minimap.ZoomIn then
		K.ShowInterfaceOption(Minimap.ZoomIn)
	end
	if Minimap.ZoomOut then
		K.ShowInterfaceOption(Minimap.ZoomOut)
	end
	if _G.MinimapCompassTexture then
		K.ShowInterfaceOption(_G.MinimapCompassTexture)
	end

	if _G.KKUI_MinimapBorder then
		_G.KKUI_MinimapBorder:Hide()
	end

	if _G.TimeManagerClockButton then
		_G.TimeManagerClockButton:Show()
	end

	if self.minimapMailPulse then
		if self.minimapMailAnim and self.minimapMailAnim:IsPlaying() then
			self.minimapMailAnim:Stop()
		end
		self.minimapMailPulse:Hide()
	end

	self:UpdateEasyVolume()
	self:UpdateCalendar()
	self:UpdateQueueStatusText()
end

function Module:InitMinimap()
	if self._minimapInitialized then
		return
	end
	self._minimapInitialized = true

	if _G.DropDownList1 then
		_G.DropDownList1:SetClampedToScreen(true)
	end

	local minimapMover = K.Mover(Minimap, "Minimap", "Minimap", { "TOPRIGHT", UIParent, "TOPRIGHT", -4, -4 })
	Minimap.mover = minimapMover

	self:ApplyMinimapCustomization()

	self:ShowCalendar()

	if _G.QueueStatusButton then
		Module:CreateQueueStatusText()
	end

	Minimap:EnableMouseWheel(true)
	Minimap:SetScript("OnMouseWheel", Module.Minimap_OnMouseWheel)
	Minimap:SetScript("OnMouseUp", Module.Minimap_OnMouseUp)

	if MinimapCluster and MinimapCluster.KillEditMode then
		MinimapCluster:KillEditMode()
	end

	-- REASON: Load various minimap sub-modules dynamically with error protection.
	local loadMinimapModules = {
		"BlizzardACF",
		"CreatePing",
		"CreateRecycleBin",
		"CreateSoundVolume",
		"CreateStyle",
		"ReskinRegions",
	}

	for _, funcName in ipairs(loadMinimapModules) do
		local func = self[funcName]
		if type(func) == "function" then
			local success, err = pcall(func, self)
			if not success then
				_G.error("Error in function " .. funcName .. ": " .. tostring(err), 2)
			end
		end
	end

	-- REASON: HybridMinimap. Skins the hybrid minimap (e.g., inside raids/dungeons) when loaded.
	K:RegisterEvent("ADDON_LOADED", Module.HybridMinimapOnLoad)
end

function Module:StopMailPulseEvents()
	local fn = self._mailPulseBorderUpdate
	if not fn then
		return
	end

	K:UnregisterEvent("CALENDAR_UPDATE_PENDING_INVITES", fn)
	K:UnregisterEvent("PLAYER_REGEN_DISABLED", fn)
	K:UnregisterEvent("PLAYER_REGEN_ENABLED", fn)
	K:UnregisterEvent("UPDATE_PENDING_MAIL", fn)
end

function Module:SetMinimapEnabled(enabled)
	if enabled then
		self:InitMinimap()
		Minimap:Show()
		if Minimap.mover then
			Minimap.mover:Show()
		end
		self:ApplyMinimapCustomization()
		if C["Minimap"].MailPulse and self._mailPulseBorderUpdate then
			K:RegisterEvent("CALENDAR_UPDATE_PENDING_INVITES", self._mailPulseBorderUpdate)
			K:RegisterEvent("PLAYER_REGEN_DISABLED", self._mailPulseBorderUpdate)
			K:RegisterEvent("PLAYER_REGEN_ENABLED", self._mailPulseBorderUpdate)
			K:RegisterEvent("UPDATE_PENDING_MAIL", self._mailPulseBorderUpdate)
		end
		self:UpdateCalendar()
		self:UpdateRecycleBin()
		self:UpdateQueueStatusText()
		self:UpdateMailPulse()
	else
		if Minimap.mover then
			Minimap.mover:Hide()
		end
		self:StopMailPulseEvents()
		self:RestoreDefaultMinimapLayout()
	end

	local dataText = K:GetModule("DataText")
	if dataText and dataText.UpdateLocationTextVisibility then
		dataText:UpdateLocationTextVisibility()
	end
end
