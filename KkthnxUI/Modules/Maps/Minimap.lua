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
local table_insert = _G.table.insert
local table_sort = _G.table.sort

local _G = _G
local C_AddOns_IsAddOnLoaded = _G.C_AddOns and _G.C_AddOns.IsAddOnLoaded
local C_Calendar_GetNumPendingInvites = _G.C_Calendar and _G.C_Calendar.GetNumPendingInvites
local C_DateAndTime_GetCurrentCalendarTime = _G.C_DateAndTime and _G.C_DateAndTime.GetCurrentCalendarTime
local C_Garrison_HasGarrison = _G.C_Garrison and _G.C_Garrison.HasGarrison
local C_StorePublic_IsEnabled = _G.C_StorePublic and _G.C_StorePublic.IsEnabled
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

-- Create the minimap micro menu
-- REASON: Minimap micro menu entries.
local menuList = {
	{
		text = _G.CHARACTER_BUTTON,
		icon = 236415,
		func = function()
			_G.ToggleCharacter("PaperDollFrame")
		end,
		notCheckable = 1,
	},
	{
		text = _G.SPELLBOOK,
		icon = 133741,
		func = function()
			if _G.PlayerSpellsUtil then
				_G.PlayerSpellsUtil.ToggleSpellBookFrame()
			else
				_G.ToggleFrame(_G.SpellBookFrame)
			end
		end,
		notCheckable = 1,
	},
	{
		text = _G.TIMEMANAGER_TITLE,
		icon = 237538,
		func = function()
			_G.ToggleFrame(_G.TimeManagerFrame)
		end,
		notCheckable = 1,
	},
	{
		text = _G.CHAT_CHANNELS,
		icon = 2056011,
		func = function()
			_G.ToggleChannelFrame()
		end,
		notCheckable = 1,
	},
	{
		text = _G.SOCIAL_BUTTON,
		icon = 442272,
		func = function()
			_G.ToggleFriendsFrame()
		end,
		notCheckable = 1,
	},
	{
		text = _G.TALENTS_BUTTON,
		icon = 3717418,
		func = function()
			if _G.PlayerSpellsUtil then
				_G.PlayerSpellsUtil.ToggleClassTalentFrame()
			else
				_G.ToggleTalentFrame()
			end
		end,
		notCheckable = 1,
	},
	{
		text = _G.GUILD,
		icon = 135026,
		func = function()
			_G.ToggleGuildFrame()
		end,
		notCheckable = 1,
	},
	{
		text = _G.COLLECTIONS,
		icon = 5321228,
		func = function()
			_G.ToggleCollectionsJournal()
		end,
		notCheckable = 1,
	},
	{
		text = _G.ACHIEVEMENT_BUTTON,
		icon = 1033987,
		func = function()
			_G.ToggleAchievementFrame()
		end,
		notCheckable = 1,
	},
	{
		text = _G.LFG_TITLE,
		icon = 134149,
		func = function()
			_G.ToggleLFDParentFrame()
		end,
		notCheckable = 1,
	},
	{
		text = L["Calendar"],
		icon = 3007435,
		func = function()
			if _G.GameTimeFrame then
				_G.GameTimeFrame:Click()
			end
		end,
		notCheckable = 1,
	},
	{
		text = _G.ENCOUNTER_JOURNAL,
		icon = 236409,
		func = function()
			if not (C_AddOns_IsAddOnLoaded and C_AddOns_IsAddOnLoaded("Blizzard_EncounterJournal")) then
				_G.UIParentLoadAddOn("Blizzard_EncounterJournal")
			end
			_G.ToggleFrame(_G.EncounterJournal)
		end,
		notCheckable = 1,
	},
	{
		text = _G.PROFESSIONS_BUTTON,
		icon = 236574,
		func = function()
			_G.ToggleProfessionsBook()
		end,
		notCheckable = 1,
	},
	{
		text = _G.GARRISON_TYPE_8_0_LANDING_PAGE_TITLE,
		icon = 1044996,
		func = function()
			if _G.ExpansionLandingPageMinimapButton then
				_G.ExpansionLandingPageMinimapButton:ToggleLandingPage()
			end
		end,
		notCheckable = 1,
	},
	{
		text = _G.QUESTLOG_BUTTON,
		icon = 236669,
		func = function()
			_G.ToggleQuestLog()
		end,
		notCheckable = 1,
	},
}

if K.Level == 80 then
	table_insert(menuList, {
		text = _G.RATED_PVP_WEEKLY_VAULT,
		icon = "greatVault-whole-normal",
		notCheckable = 1,
		func = function()
			if not _G.WeeklyRewardsFrame and _G.WeeklyRewards_LoadUI then
				_G.WeeklyRewards_LoadUI()
			end
			_G.ToggleFrame(_G.WeeklyRewardsFrame)
		end,
	})
end

if C_StorePublic_IsEnabled and C_StorePublic_IsEnabled() then
	table_insert(menuList, {
		text = _G.BLIZZARD_STORE,
		icon = 939375,
		notCheckable = 1,
		func = function()
			if _G.StoreMicroButton then
				_G.StoreMicroButton:Click()
			end
		end,
	})
end

-- REASON: Handled in the initial table creation for efficiency.

-- REASON: Handled in the initial table creation for efficiency.

-- REASON: Sort the menu list alphabetically for easier navigation, keeping specific buttons at the bottom.
table_sort(menuList, function(a, b)
	if a and b and a.text and b.text then
		return a.text < b.text
	end
	return false
end)

table_insert(menuList, {
	text = _G.MAINMENU_BUTTON,
	microOffset = "MainMenuMicroButton",
	func = function()
		if not _G.GameMenuFrame:IsShown() then
			_G.CloseMenus()
			_G.CloseAllWindows()
			_G.PlaySound(SOUNDKIT.IG_MAINMENU_OPEN)
			_G.ShowUIPanel(_G.GameMenuFrame)
		else
			_G.PlaySound(SOUNDKIT.IG_MAINMENU_QUIT)
			_G.HideUIPanel(_G.GameMenuFrame)
			_G.MainMenuMicroButton:SetButtonState("NORMAL")
		end
	end,
	notCheckable = 1,
	icon = 134400,
})

table_insert(menuList, {
	text = _G.HELP_BUTTON,
	microOffset = nil,
	bottom = true,
	func = function()
		_G.ToggleHelpFrame()
	end,
	notCheckable = 1,
	icon = 511544,
})

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

function Module:UpdateMinimapScale()
	local minimapSize = C["Minimap"].Size
	Minimap:SetSize(minimapSize, minimapSize)
	if Minimap.mover then
		Minimap.mover:SetSize(minimapSize, minimapSize)
	end
end

-- REASON: Mandatory for LibDBIcon-1.0 and similar libraries to return the correct shape.
function _G.GetMinimapShape()
	if not Module.Initialized then
		Module:UpdateMinimapScale()
		Module.Initialized = true
	end
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
			local calendarText = gameTimeFrame:CreateFontString(nil, "OVERLAY")

			gameTimeFrame:SetParent(Minimap)
			gameTimeFrame:SetFrameLevel(16)
			gameTimeFrame:ClearAllPoints()
			gameTimeFrame:SetPoint("TOPRIGHT", Minimap, -4, -4)
			gameTimeFrame:SetHitRectInsets(0, 0, 0, 0)
			gameTimeFrame:SetSize(22, 22)

			calendarText:ClearAllPoints()
			calendarText:SetPoint("CENTER", 0, -4)
			calendarText:SetFontObject(K.UIFont)
			calendarText:SetFont(select(1, calendarText:GetFont()), 12, select(3, calendarText:GetFont()))
			calendarText:SetTextColor(0, 0, 0)
			calendarText:SetShadowOffset(0, 0)
			calendarText:SetAlpha(0.9)

			-- REASON: Skins the calendar icon and updates the date text whenever it changes.
			hooksecurefunc("GameTimeFrame_SetDate", function()
				gameTimeFrame:SetNormalTexture("Interface\\AddOns\\KkthnxUI\\Media\\Minimap\\Calendar.blp")
				gameTimeFrame:SetPushedTexture("Interface\\AddOns\\KkthnxUI\\Media\\Minimap\\Calendar.blp")
				gameTimeFrame:SetHighlightTexture(0)
				gameTimeFrame:GetNormalTexture():SetTexCoord(0, 1, 0, 1)
				gameTimeFrame:GetPushedTexture():SetTexCoord(0, 1, 0, 1)

				if C_DateAndTime_GetCurrentCalendarTime then
					calendarText:SetText(C_DateAndTime_GetCurrentCalendarTime().monthDay)
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
			K.LibEasyMenu.Create(menuList, K.EasyMenu, "cursor", 0, 0)
		else
			K.LibEasyMenu.Create(menuList, K.EasyMenu, "cursor", -160, 0)
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

function Module:HybridMinimapOnLoad(addon)
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
	if statusDisplay and statusDisplay.title == title then
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
	if not C["Minimap"].Enable then
		return
	end

	-- REASON: Shape and Position. Sets the minimap as a square and initializes its mover.
	Minimap:SetFrameLevel(10)
	Minimap:SetMaskTexture(C["Media"].Textures.White8x8Texture)

	if _G.DropDownList1 then
		_G.DropDownList1:SetClampedToScreen(true)
	end

	local minimapMover = K.Mover(Minimap, "Minimap", "Minimap", { "TOPRIGHT", UIParent, "TOPRIGHT", -4, -4 })
	Minimap:ClearAllPoints()
	Minimap:SetPoint("TOPRIGHT", minimapMover)
	Minimap.mover = minimapMover

	self:HideMinimapClock()
	self:ShowCalendar()
	self:UpdateMinimapScale()

	if _G.QueueStatusButton then
		Module:CreateQueueStatusText()
	end

	Minimap:EnableMouseWheel(true)
	Minimap:SetScript("OnMouseWheel", Module.Minimap_OnMouseWheel)
	Minimap:SetScript("OnMouseUp", Module.Minimap_OnMouseUp)

	-- REASON: Hides standard Blizzard Minimap elements to prevent clutter.
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

	if MinimapCluster and MinimapCluster.KillEditMode then
		MinimapCluster:KillEditMode()
	end

	-- REASON: Load various minimap sub-modules dynamically with error protection.
	local loadMinimapModules = {
		"BlizzardACF",
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
