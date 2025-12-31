local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:NewModule("Minimap")

-- Lua locals
local _G = _G
local error = error
local ipairs = ipairs
local pcall = pcall
local select = select
local tostring = tostring
local type = type
local unpack = unpack

local math_floor = math.floor
local string_find = string.find
local table_sort = table.sort
local tinsert = tinsert

-- WoW API locals
local CreateFrame = CreateFrame
local GameTooltip = GameTooltip
local GetTime = GetTime
local GetUnitName = GetUnitName
local InCombatLockdown = InCombatLockdown
local IsAltKeyDown = IsAltKeyDown
local IsControlKeyDown = IsControlKeyDown
local IsShiftKeyDown = IsShiftKeyDown
local ToggleCalendar = ToggleCalendar
local UnitClass = UnitClass
local UnitIsUnit = UnitIsUnit
local hooksecurefunc = hooksecurefunc
local UIParent = UIParent

-- Globals / frames
local Minimap = Minimap
local MinimapCluster = MinimapCluster
local SOUNDKIT = SOUNDKIT

-- C_ API locals (guarded for private server compatibility)
local C_AddOns_IsAddOnLoaded = C_AddOns and C_AddOns.IsAddOnLoaded
local C_Calendar_GetNumPendingInvites = C_Calendar and C_Calendar.GetNumPendingInvites
local C_DateAndTime_GetCurrentCalendarTime = C_DateAndTime and C_DateAndTime.GetCurrentCalendarTime
local C_Garrison_HasGarrison = C_Garrison and C_Garrison.HasGarrison
local C_StorePublic_IsEnabled = C_StorePublic and C_StorePublic.IsEnabled

-- Blizzard helpers (may not exist on all clients)
local Minimap_OnClick = _G.Minimap_OnClick
local Minimap_OnMouseUp = _G.Minimap_OnMouseUp

-- Create the minimap micro menu
local menuList = {
	{
		text = _G.CHARACTER_BUTTON,
		func = function()
			_G.ToggleCharacter("PaperDollFrame")
		end,
		notCheckable = 1,
		icon = 236415,
	},
	{
		text = _G.SPELLBOOK,
		func = function()
			-- PlayerSpellsUtil can be loaded after login; avoid caching it.
			if _G.PlayerSpellsUtil then
				_G.PlayerSpellsUtil.ToggleSpellBookFrame()
			else
				_G.ToggleFrame(_G.SpellBookFrame)
			end
		end,
		notCheckable = 1,
		icon = 133741,
	},
	{
		text = _G.TIMEMANAGER_TITLE,
		func = function()
			_G.ToggleFrame(_G.TimeManagerFrame)
		end,
		notCheckable = 1,
		icon = 237538,
	},
	{
		text = _G.CHAT_CHANNELS,
		func = function()
			_G.ToggleChannelFrame()
		end,
		notCheckable = 1,
		icon = 2056011,
	},
	{
		text = _G.SOCIAL_BUTTON,
		func = function()
			_G.ToggleFriendsFrame()
		end,
		notCheckable = 1,
		icon = 442272,
	},
	{
		text = _G.TALENTS_BUTTON,
		func = function()
			if _G.PlayerSpellsUtil then
				_G.PlayerSpellsUtil.ToggleClassTalentFrame()
			else
				_G.ToggleTalentFrame()
			end
		end,
		notCheckable = 1,
		icon = 3717418,
	},
	{
		text = _G.GUILD,
		func = function()
			_G.ToggleGuildFrame()
		end,
		notCheckable = 1,
		icon = 135026,
	},
	{
		text = _G.COLLECTIONS,
		func = function()
			_G.ToggleCollectionsJournal()
		end,
		notCheckable = 1,
		icon = 5321228,
	},
	{
		text = _G.ACHIEVEMENT_BUTTON,
		func = function()
			_G.ToggleAchievementFrame()
		end,
		notCheckable = 1,
		icon = 1033987,
	},
	{
		text = _G.LFG_TITLE,
		func = function()
			_G.ToggleLFDParentFrame()
		end,
		notCheckable = 1,
		icon = 134149,
	},
	{
		text = (L and L["Calendar"]) or "Calendar",
		func = function()
			if _G.GameTimeFrame then
				_G.GameTimeFrame:Click()
			end
		end,
		notCheckable = 1,
		icon = 3007435,
	},
	{
		text = _G.ENCOUNTER_JOURNAL,
		microOffset = "EJMicroButton",
		func = function()
			if not (C_AddOns_IsAddOnLoaded and C_AddOns_IsAddOnLoaded("Blizzard_EncounterJournal")) then
				_G.UIParentLoadAddOn("Blizzard_EncounterJournal")
			end
			_G.ToggleFrame(_G.EncounterJournal)
		end,
		notCheckable = 1,
		icon = 236409,
	},
	{
		text = _G.PROFESSIONS_BUTTON,
		func = function()
			_G.ToggleProfessionsBook()
		end,
		notCheckable = 1,
		icon = 236574,
	},
	{
		text = _G.GARRISON_TYPE_8_0_LANDING_PAGE_TITLE,
		func = function()
			if _G.ExpansionLandingPageMinimapButton then
				_G.ExpansionLandingPageMinimapButton:ToggleLandingPage()
			end
		end,
		notCheckable = 1,
		icon = 1044996,
	},
	{
		text = _G.QUESTLOG_BUTTON,
		func = function()
			_G.ToggleQuestLog()
		end,
		notCheckable = 1,
		icon = 236669,
	},
}

if K.Level == 80 then
	tinsert(menuList, {
		text = _G.RATED_PVP_WEEKLY_VAULT,
		func = function()
			if not _G.WeeklyRewardsFrame and _G.WeeklyRewards_LoadUI then
				_G.WeeklyRewards_LoadUI()
			end
			_G.ToggleFrame(_G.WeeklyRewardsFrame)
		end,
		notCheckable = 1,
		icon = "greatVault-whole-normal",
	})
end

if C_StorePublic_IsEnabled and C_StorePublic_IsEnabled() then
	tinsert(menuList, {
		text = _G.BLIZZARD_STORE,
		func = function()
			if _G.StoreMicroButton then
				_G.StoreMicroButton:Click()
			end
		end,
		notCheckable = 1,
		icon = 939375,
	})
end

table_sort(menuList, function(a, b)
	if a and b and a.text and b.text then
		return a.text < b.text
	end
end)

-- want these two on the bottom
tinsert(menuList, {
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

tinsert(menuList, {
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
	local MinimapMailFrame = indicatorFrame and indicatorFrame.MailFrame

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

	local function updateMinimapBorderAnimation(event)
		local borderColor

		if event == "PLAYER_REGEN_DISABLED" then
			borderColor = { 1, 0, 0, 0.8 }
		elseif not InCombatLockdown() then
			local invites = C_Calendar_GetNumPendingInvites and C_Calendar_GetNumPendingInvites() or 0
			if invites > 0 or (MinimapMailFrame and MinimapMailFrame:IsShown()) then
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

	if MinimapMailFrame then
		MinimapMailFrame:HookScript("OnHide", function()
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

local function ToggleLandingPage(_, ...)
	if not (C_Garrison_HasGarrison and C_Garrison_HasGarrison(...)) then
		_G.UIErrorsFrame:AddMessage(K.InfoColor .. _G.CONTRIBUTION_TOOLTIP_UNLOCKED_WHEN_ACTIVE)
		return
	end
	_G.ShowGarrisonLandingPage(...)
end

function Module:ReskinRegions()
	-- Garrison / Expansion Landing Page Minimap Button (mirror Blizzard behavior)
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
			{ text = _G.GARRISON_TYPE_9_0_LANDING_PAGE_TITLE, func = ToggleLandingPage, arg1 = Enum.GarrisonType.Type_9_0_Garrison, notCheckable = true },
			{ text = _G.GARRISON_TYPE_8_0_LANDING_PAGE_TITLE, func = ToggleLandingPage, arg1 = Enum.GarrisonType.Type_8_0_Garrison, notCheckable = true },
			{ text = _G.ORDER_HALL_LANDING_PAGE_TITLE, func = ToggleLandingPage, arg1 = Enum.GarrisonType.Type_7_0_Garrison, notCheckable = true },
			{ text = _G.GARRISON_LANDING_PAGE_TITLE, func = ToggleLandingPage, arg1 = Enum.GarrisonType.Type_6_0_Garrison, notCheckable = true },
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

	-- QueueStatus Button
	local QueueStatusButton = _G.QueueStatusButton
	if QueueStatusButton then
		local QueueStatusButtonIcon = _G.QueueStatusButtonIcon
		local QueueStatusFrame = _G.QueueStatusFrame

		QueueStatusButton:SetParent(MinimapCluster)
		QueueStatusButton:SetSize(24, 24)
		QueueStatusButton:SetFrameLevel(20)
		QueueStatusButton:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMRIGHT", -4, 4)

		if QueueStatusButtonIcon then
			QueueStatusButtonIcon:SetAlpha(0)
		end
		if QueueStatusFrame then
			QueueStatusFrame:SetPoint("TOPRIGHT", QueueStatusButton, "TOPLEFT")
		end

		hooksecurefunc(QueueStatusButton, "SetPoint", function(button, _, _, _, x, y)
			if not (x == -4 and y == 4) then
				button:ClearAllPoints()
				button:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMRIGHT", -4, 4)
			end
		end)

		local queueIcon = Minimap:CreateTexture(nil, "ARTWORK")
		queueIcon:SetPoint("CENTER", QueueStatusButton)
		queueIcon:SetSize(56, 56)
		queueIcon:SetTexture("Interface\\Minimap\\Dungeon_Icon")

		local anim = queueIcon:CreateAnimationGroup()
		anim:SetLooping("REPEAT")
		anim.rota = anim:CreateAnimation("Rotation")
		anim.rota:SetDuration(2)
		anim.rota:SetDegrees(360)

		if QueueStatusFrame then
			hooksecurefunc(QueueStatusFrame, "Update", function()
				queueIcon:SetShown(QueueStatusButton:IsShown())
			end)
		end

		if QueueStatusButton.Eye then
			hooksecurefunc(QueueStatusButton.Eye, "PlayAnim", function()
				anim:Play()
			end)
			hooksecurefunc(QueueStatusButton.Eye, "StopAnimating", function()
				anim:Pause()
			end)
		end

		local queueStatusDisplay = Module.QueueStatusDisplay
		if queueStatusDisplay then
			queueStatusDisplay.text:ClearAllPoints()
			queueStatusDisplay.text:SetPoint("CENTER", QueueStatusButton, 0, -5)
			queueStatusDisplay.text:SetFontObject(K.UIFont)
			queueStatusDisplay.text:SetFont(select(1, queueStatusDisplay.text:GetFont()), 13, select(3, queueStatusDisplay.text:GetFont()))

			if queueStatusDisplay.title then
				Module:ClearQueueStatus()
			end
		end
	end

	-- Difficulty Flags
	local instDifficulty = MinimapCluster and MinimapCluster.InstanceDifficulty
	if instDifficulty then
		instDifficulty:SetParent(Minimap)
		instDifficulty:SetScale(0.9)

		local function UpdateFlagAnchor(frame)
			frame:ClearAllPoints()
			frame:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 2, -2)
		end

		UpdateFlagAnchor(instDifficulty)
		hooksecurefunc(instDifficulty, "SetPoint", UpdateFlagAnchor)

		local function ReplaceFlagTexture(texture)
			texture:SetTexture(K.MediaFolder .. "Minimap\\Flag")
		end

		local function ReskinDifficultyFrame(frame)
			if not frame then
				return
			end
			if frame.Border then
				frame.Border:Hide()
			end
			ReplaceFlagTexture(frame.Background)
			hooksecurefunc(frame.Background, "SetAtlas", ReplaceFlagTexture)
		end

		ReskinDifficultyFrame(instDifficulty.Instance)
		ReskinDifficultyFrame(instDifficulty.Guild)
		ReskinDifficultyFrame(instDifficulty.ChallengeMode)
	end

	-- Indicator Frame (mail/calendar, etc.)
	local function UpdateIndicatorAnchor(frame)
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
		UpdateIndicatorAnchor(indicatorFrame)
		hooksecurefunc(indicatorFrame, "SetPoint", UpdateIndicatorAnchor)
		indicatorFrame:SetFrameLevel(11)
	end

	-- Invites Icon
	local GameTimeCalendarInvitesTexture = _G.GameTimeCalendarInvitesTexture
	if GameTimeCalendarInvitesTexture then
		GameTimeCalendarInvitesTexture:ClearAllPoints()
		GameTimeCalendarInvitesTexture:SetParent(Minimap)
		GameTimeCalendarInvitesTexture:SetPoint("TOPLEFT")
	end

	-- Streaming icon
	local StreamingIcon = _G.StreamingIcon
	if StreamingIcon then
		StreamingIcon:ClearAllPoints()
		StreamingIcon:SetParent(Minimap)
		StreamingIcon:SetPoint("LEFT", -6, 0)
		StreamingIcon:SetAlpha(0.5)
		StreamingIcon:SetScale(0.8)
		StreamingIcon:SetFrameStrata("LOW")
	end

	-- Calendar invite notification border
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

	K:RegisterEvent("MINIMAP_PING", function(_, unit)
		if UnitIsUnit(unit, "player") then
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
	if Minimap.mover then
		Minimap.mover:SetSize(size, size)
	end
end

function GetMinimapShape() -- LibDBIcon
	if not Module.Initialized then
		Module:UpdateMinimapScale()
		Module.Initialized = true
	end
	return "SQUARE"
end

function Module:HideMinimapClock()
	local TimeManagerClockButton = _G.TimeManagerClockButton
	if TimeManagerClockButton then
		TimeManagerClockButton:Hide()
	end
end

local GameTimeFrameStyled
function Module:ShowCalendar()
	local GameTimeFrame = _G.GameTimeFrame
	if not GameTimeFrame then
		return
	end

	if C["Minimap"].Calendar then
		if not GameTimeFrameStyled then
			local calendarText = GameTimeFrame:CreateFontString(nil, "OVERLAY")

			GameTimeFrame:SetParent(Minimap)
			GameTimeFrame:SetFrameLevel(16)
			GameTimeFrame:ClearAllPoints()
			GameTimeFrame:SetPoint("TOPRIGHT", Minimap, -4, -4)
			GameTimeFrame:SetHitRectInsets(0, 0, 0, 0)
			GameTimeFrame:SetSize(22, 22)

			calendarText:ClearAllPoints()
			calendarText:SetPoint("CENTER", 0, -4)
			calendarText:SetFontObject(K.UIFont)
			calendarText:SetFont(select(1, calendarText:GetFont()), 12, select(3, calendarText:GetFont()))
			calendarText:SetTextColor(0, 0, 0)
			calendarText:SetShadowOffset(0, 0)
			calendarText:SetAlpha(0.9)

			hooksecurefunc("GameTimeFrame_SetDate", function()
				GameTimeFrame:SetNormalTexture("Interface\\AddOns\\KkthnxUI\\Media\\Minimap\\Calendar.blp")
				GameTimeFrame:SetPushedTexture("Interface\\AddOns\\KkthnxUI\\Media\\Minimap\\Calendar.blp")
				GameTimeFrame:SetHighlightTexture(0)
				GameTimeFrame:GetNormalTexture():SetTexCoord(0, 1, 0, 1)
				GameTimeFrame:GetPushedTexture():SetTexCoord(0, 1, 0, 1)

				if C_DateAndTime_GetCurrentCalendarTime then
					calendarText:SetText(C_DateAndTime_GetCurrentCalendarTime().monthDay)
				end
			end)

			GameTimeFrameStyled = true
		end

		GameTimeFrame:Show()
	else
		GameTimeFrame:Hide()
	end
end

local function GetVolumeColor(cur)
	local r, g, b = K.oUF:RGBColorGradient(cur, 100, 1, 1, 1, 1, 0.8, 0, 1, 0, 0)
	return r, g, b
end

local function GetCurrentVolume()
	return K.Round(_G.GetCVar("Sound_MasterVolume") * 100)
end

function Module:CreateSoundVolume()
	if not C["Minimap"].EasyVolume then
		return
	end

	local f = CreateFrame("Frame", nil, Minimap)
	f:SetAllPoints()

	local text = K.CreateFontString(f, 30)
	local anim = f:CreateAnimationGroup()
	anim:SetScript("OnPlay", function()
		f:SetAlpha(1)
	end)
	anim:SetScript("OnFinished", function()
		f:SetAlpha(0)
	end)
	anim.fader = anim:CreateAnimation("Alpha")
	anim.fader:SetFromAlpha(1)
	anim.fader:SetToAlpha(0)
	anim.fader:SetDuration(3)
	anim.fader:SetSmoothing("OUT")
	anim.fader:SetStartDelay(1)

	Module.VolumeText = text
	Module.VolumeAnim = anim
end

function Module.Minimap_OnMouseWheel(_, zoom)
	if IsControlKeyDown() and Module.VolumeText then
		local value = GetCurrentVolume()
		local mult = IsAltKeyDown() and 100 or 2

		value = value + zoom * mult
		if value > 100 then
			value = 100
		elseif value < 0 then
			value = 0
		end

		_G.SetCVar("Sound_MasterVolume", tostring(value / 100))
		Module.VolumeText:SetText(value .. "%")
		Module.VolumeText:SetTextColor(GetVolumeColor(value))
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

function Module:Minimap_TrackingDropdown()
	local dropdown = CreateFrame("Frame", "KKUI_MiniMapTrackingDropDown", UIParent, "UIDropDownMenuTemplate")
	dropdown:SetID(1)
	dropdown:SetClampedToScreen(true)
	dropdown:Hide()

	_G.UIDropDownMenu_Initialize(dropdown, _G.MiniMapTrackingDropDown_Initialize, "MENU")
	dropdown.noResize = true

	return dropdown
end

function Module.Minimap_OnMouseUp(_, btn)
	K.EasyMenu:Hide()

	if Module.TrackingDropdown then
		_G.HideDropDownMenu(1, nil, Module.TrackingDropdown)
	end

	local position = Minimap.mover and Minimap.mover:GetPoint()
	if btn == "MiddleButton" or (btn == "RightButton" and IsShiftKeyDown()) then
		if InCombatLockdown() then
			_G.UIErrorsFrame:AddMessage(K.InfoColor .. _G.ERR_NOT_IN_COMBAT)
			return
		end

		if position and string_find(position, "LEFT") then
			K.LibEasyMenu.Create(menuList, K.EasyMenu, "cursor", 0, 0)
		else
			K.LibEasyMenu.Create(menuList, K.EasyMenu, "cursor", -160, 0)
		end
	elseif btn == "RightButton" then
		local trackingButton = MinimapCluster and MinimapCluster.Tracking and MinimapCluster.Tracking.Button
		if trackingButton and trackingButton.OpenMenu then
			trackingButton:OpenMenu()
			if trackingButton.menu then
				local left = position and string_find(position, "RIGHT")
				trackingButton.menu:ClearAllPoints()
				trackingButton.menu:SetPoint(left and "TOPRIGHT" or "TOPLEFT", Minimap, left and "LEFT" or "RIGHT", left and -4 or 4, 0)
			end
		end
	else
		-- Preserve Blizzard minimap click behavior
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
	local HybridMinimap = _G.HybridMinimap
	if HybridMinimap and HybridMinimap.CircleMask then
		HybridMinimap.CircleMask:SetTexture("Interface\\BUTTONS\\WHITE8X8")
	end
end

function Module:HybridMinimapOnLoad(addon)
	if addon == "Blizzard_HybridMinimap" then
		Module:SetupHybridMinimap()
		K:UnregisterEvent("ADDON_LOADED", Module.HybridMinimapOnLoad)
	end
end

function Module:QueueStatusTimeFormat(seconds)
	local display = Module.QueueStatusDisplay
	if not (display and display.text) then
		return
	end

	local hours = math_floor((seconds % 86400) / 3600)
	if hours > 0 then
		display.text:SetFormattedText("%d" .. K.MyClassColor .. "h", hours)
		return
	end

	local mins = math_floor((seconds % 3600) / 60)
	if mins > 0 then
		display.text:SetFormattedText("%d" .. K.MyClassColor .. "m", mins)
		return
	end

	local secs = math_floor(seconds % 60)
	if secs > 0 then
		display.text:SetFormattedText("%d" .. K.MyClassColor .. "s", secs)
	end
end

function Module:QueueStatusSetTime(seconds)
	local display = Module.QueueStatusDisplay
	if not display then
		return
	end

	local timeInQueue = GetTime() - seconds
	Module:QueueStatusTimeFormat(timeInQueue)
	display.text:SetTextColor(1, 1, 1)
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

	local display = Module.QueueStatusDisplay
	if not display then
		return
	end

	if not display.title or display.title == title then
		if queuedTime then
			display.title = title
			display.updateThrottle = 0
			display.queuedTime = queuedTime
			display.averageWait = averageWait
			display:SetScript("OnUpdate", Module.QueueStatusOnUpdate)
		else
			Module:ClearQueueStatus()
		end
	end
end

function Module:SetMinimalQueueStatus(title)
	local display = Module.QueueStatusDisplay
	if display and display.title == title then
		Module:ClearQueueStatus()
	end
end

function Module:ClearQueueStatus()
	local display = Module.QueueStatusDisplay
	if not display then
		return
	end

	display.text:SetText("")
	display.title = nil
	display.queuedTime = nil
	display.averageWait = nil
	display:SetScript("OnUpdate", nil)
end

function Module:CreateQueueStatusText()
	local QueueStatusButton = _G.QueueStatusButton
	if not QueueStatusButton then
		return
	end

	local display = CreateFrame("Frame", "KKUI_QueueStatusDisplay", QueueStatusButton)
	display.text = display:CreateFontString(nil, "OVERLAY")

	Module.QueueStatusDisplay = display

	QueueStatusButton:HookScript("OnHide", Module.ClearQueueStatus)
	hooksecurefunc("QueueStatusEntry_SetMinimalDisplay", Module.SetMinimalQueueStatus)
	hooksecurefunc("QueueStatusEntry_SetFullDisplay", Module.SetFullQueueStatus)
end

function Module:BlizzardACF()
	local frame = _G.AddonCompartmentFrame
	if not frame then
		return
	end

	if C["Minimap"].ShowRecycleBin then
		K.HideInterfaceOption(frame)
	else
		frame:ClearAllPoints()
		frame:SetPoint("BOTTOMRIGHT", Minimap, -26, 2)
		frame:SetFrameLevel(999)
		frame:StripTextures()
		frame:CreateBorder()
	end
end

function Module:OnEnable()
	if not C["Minimap"].Enable then
		return
	end

	-- Shape and Position
	Minimap:SetFrameLevel(10)
	Minimap:SetMaskTexture(C["Media"].Textures.White8x8Texture)

	if _G.DropDownList1 then
		_G.DropDownList1:SetClampedToScreen(true)
	end

	-- Create the new minimap tracking dropdown frame and initialize it
	Module.TrackingDropdown = Module:Minimap_TrackingDropdown()

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

	-- Hide Blizz
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

	-- Add Elements
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
				error("Error in function " .. funcName .. ": " .. tostring(err), 2)
			end
		end
	end

	-- HybridMinimap
	K:RegisterEvent("ADDON_LOADED", Module.HybridMinimapOnLoad)
end
