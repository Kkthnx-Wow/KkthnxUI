local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:NewModule("Minimap")

local math_floor = math.floor
local select = select
local table_sort = table.sort
local tinsert = tinsert
local unpack = unpack
local SOUNDKIT = SOUNDKIT
local C_AddOns_IsAddOnLoaded = C_AddOns and C_AddOns.IsAddOnLoaded
local C_Garrison_HasGarrison = C_Garrison and C_Garrison.HasGarrison
local ShowGarrisonLandingPage = ShowGarrisonLandingPage
local UIParentLoadAddOn = UIParentLoadAddOn
local ToggleFrame = ToggleFrame
local CloseMenus = CloseMenus
local CloseAllWindows = CloseAllWindows
local PlaySound = PlaySound
local ShowUIPanel = ShowUIPanel
local HideUIPanel = HideUIPanel
local ipairs = ipairs

local C_Calendar_GetNumPendingInvites = C_Calendar.GetNumPendingInvites
local C_DateAndTime_GetCurrentCalendarTime = C_DateAndTime.GetCurrentCalendarTime
local GetUnitName = GetUnitName
local InCombatLockdown = InCombatLockdown
local Minimap = Minimap
local UnitClass = UnitClass
local hooksecurefunc = hooksecurefunc

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
			if PlayerSpellsUtil then
				PlayerSpellsUtil.ToggleSpellBookFrame()
			else
				ToggleFrame(_G.SpellBookFrame)
			end
		end,
		notCheckable = 1,
		icon = 133741,
	},
	{
		text = _G.TIMEMANAGER_TITLE,
		func = function()
			ToggleFrame(_G.TimeManagerFrame)
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
			if PlayerSpellsUtil then
				PlayerSpellsUtil.ToggleClassTalentFrame()
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
			_G.GameTimeFrame:Click()
		end,
		notCheckable = 1,
		icon = 3007435,
	},
	{
		text = _G.ENCOUNTER_JOURNAL,
		microOffset = "EJMicroButton",
		func = function()
			if not (C_AddOns_IsAddOnLoaded and C_AddOns_IsAddOnLoaded("Blizzard_EncounterJournal")) then
				UIParentLoadAddOn("Blizzard_EncounterJournal")
			end
			ToggleFrame(_G.EncounterJournal)
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
			_G.ExpansionLandingPageMinimapButton:ToggleLandingPage()
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
		text = RATED_PVP_WEEKLY_VAULT,
		func = function()
			if not WeeklyRewardsFrame then
				WeeklyRewards_LoadUI()
			end
			ToggleFrame(WeeklyRewardsFrame)
		end,
		notCheckable = 1,
		icon = "greatVault-whole-normal",
	})
end

if C_StorePublic.IsEnabled and C_StorePublic.IsEnabled() then
	tinsert(menuList, {
		text = _G.BLIZZARD_STORE,
		func = function()
			_G.StoreMicroButton:Click()
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
			CloseMenus()
			CloseAllWindows()
			PlaySound(SOUNDKIT.IG_MAINMENU_OPEN)
			ShowUIPanel(_G.GameMenuFrame)
		else
			PlaySound(SOUNDKIT.IG_MAINMENU_QUIT)
			HideUIPanel(_G.GameMenuFrame)

			MainMenuMicroButton:SetButtonState("NORMAL")
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

	local MinimapMailFrame = MinimapCluster.IndicatorFrame.MailFrame

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

	-- Add comments to describe the purpose of the function
	local function updateMinimapBorderAnimation(event)
		local borderColor = nil

		-- If player enters combat, set border color to red
		if event == "PLAYER_REGEN_DISABLED" then
			borderColor = { 1, 0, 0, 0.8 }
		elseif not InCombatLockdown() then
			if C_Calendar_GetNumPendingInvites() > 0 or MinimapMailFrame:IsShown() then
				-- If there are pending calendar invites or minimap mail frame is shown, set border color to yellow
				borderColor = { 1, 1, 0, 0.8 }
			end
		end

		-- If a border color was set, show the minimap mail pulse frame and play the animation
		if borderColor then
			minimapMailPulse:Show()
			minimapMailPulse:SetBackdropBorderColor(unpack(borderColor))
			anim:Play()
		else
			minimapMailPulse:Hide()
			minimapMailPulse:SetBackdropBorderColor(1, 1, 0, 0.8)
			-- Stop the animation
			anim:Stop()
		end
	end
	K:RegisterEvent("CALENDAR_UPDATE_PENDING_INVITES", updateMinimapBorderAnimation)
	K:RegisterEvent("PLAYER_REGEN_DISABLED", updateMinimapBorderAnimation)
	K:RegisterEvent("PLAYER_REGEN_ENABLED", updateMinimapBorderAnimation)
	K:RegisterEvent("UPDATE_PENDING_MAIL", updateMinimapBorderAnimation)

	MinimapMailFrame:HookScript("OnHide", function()
		if InCombatLockdown() then
			return
		end

		if anim and anim:IsPlaying() then
			anim:Stop()
			minimapMailPulse:Hide()
		end
	end)
end

local function ToggleLandingPage(_, ...)
	if not C_Garrison_HasGarrison(...) then
		UIErrorsFrame:AddMessage(K.InfoColor .. CONTRIBUTION_TOOLTIP_UNLOCKED_WHEN_ACTIVE)
		return
	end
	ShowGarrisonLandingPage(...)
end

function Module:ReskinRegions()
	-- Garrison
	local garrMinimapButton = ExpansionLandingPageMinimapButton
	if garrMinimapButton then
		local buttonTextureIcon = "ShipMissionIcon-Combat-Mission"
		local function updateMinimapButtons(self)
			self:ClearAllPoints()
			self:SetPoint("BOTTOMLEFT", Minimap, "BOTTOMLEFT", 4, 4)
			self:GetNormalTexture():SetAtlas(buttonTextureIcon)
			self:GetPushedTexture():SetAtlas(buttonTextureIcon)
			self:GetHighlightTexture():SetAtlas(buttonTextureIcon)
			self:GetNormalTexture():SetVertexColor(1, 1, 1, 1)
			self:GetPushedTexture():SetVertexColor(1, 1, 1, 1)
			self:GetHighlightTexture():SetVertexColor(1, 1, 1, 1)

			self.LoopingGlow:SetAtlas(buttonTextureIcon)
			self.LoopingGlow:SetSize(26, 26)

			self:SetHitRectInsets(0, 0, 0, 0)
			self:SetSize(26, 26)
		end
		updateMinimapButtons(garrMinimapButton)
		garrMinimapButton:HookScript("OnShow", updateMinimapButtons)
		hooksecurefunc(garrMinimapButton, "UpdateIcon", updateMinimapButtons)

		local menuList = {
			{ text = _G.GARRISON_TYPE_9_0_LANDING_PAGE_TITLE, func = ToggleLandingPage, arg1 = Enum.GarrisonType.Type_9_0_Garrison, notCheckable = true },
			{ text = _G.WAR_CAMPAIGN, func = ToggleLandingPage, arg1 = Enum.GarrisonType.Type_8_0_Garrison, notCheckable = true },
			{ text = _G.ORDER_HALL_LANDING_PAGE_TITLE, func = ToggleLandingPage, arg1 = Enum.GarrisonType.Type_7_0_Garrison, notCheckable = true },
			{ text = _G.GARRISON_LANDING_PAGE_TITLE, func = ToggleLandingPage, arg1 = Enum.GarrisonType.Type_6_0_Garrison, notCheckable = true },
		}
		garrMinimapButton:HookScript("OnMouseDown", function(self, btn)
			if btn == "RightButton" then
				if _G.GarrisonLandingPage and _G.GarrisonLandingPage:IsShown() then
					HideUIPanel(_G.GarrisonLandingPage)
				end
				if _G.ExpansionLandingPage and _G.ExpansionLandingPage:IsShown() then
					HideUIPanel(_G.ExpansionLandingPage)
				end
				K.LibEasyMenu.Create(menuList, K.EasyMenu, self, -80, 0, "MENU", 1)
			end
		end)
		garrMinimapButton:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_LEFT")
			GameTooltip:SetText(self.title, 1, 1, 1)
			GameTooltip:AddLine(self.description, nil, nil, nil, true)
			GameTooltip:AddLine("|nRight Click to switch Summaries", nil, nil, nil, true)
			GameTooltip:Show()
		end)
	end

	-- QueueStatus Button
	if QueueStatusButton then
		QueueStatusButton:SetParent(MinimapCluster)
		QueueStatusButton:SetSize(24, 24)
		QueueStatusButton:SetFrameLevel(20)
		QueueStatusButton:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMRIGHT", -4, 4)

		QueueStatusButtonIcon:SetAlpha(0)

		QueueStatusFrame:SetPoint("TOPRIGHT", QueueStatusButton, "TOPLEFT")

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

		hooksecurefunc(QueueStatusFrame, "Update", function()
			queueIcon:SetShown(QueueStatusButton:IsShown())
		end)

		hooksecurefunc(QueueStatusButton.Eye, "PlayAnim", function()
			anim:Play()
		end)

		hooksecurefunc(QueueStatusButton.Eye, "StopAnimating", function()
			anim:Pause()
		end)

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
	local instDifficulty = MinimapCluster.InstanceDifficulty
	if instDifficulty then
		instDifficulty:SetParent(Minimap)
		instDifficulty:SetScale(0.9)

		local function UpdateFlagAnchor(frame, _, _, _, _, _, force)
			if force then
				return
			end
			frame:ClearAllPoints()
			frame:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 2, -2, true)
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

	local function updateMapAnchor(frame, _, _, newAnchor, _, _, force)
		if force then
			return
		end

		local p, rel, rp, x, y = frame:GetPoint()
		local wantY
		if C["DataText"].Time then
			wantY = 20
		else
			wantY = 4
		end
		if not (p == newAnchor and rel == Minimap and rp == "BOTTOM" and x == 0 and y == wantY) then
			frame:ClearAllPoints()
			frame:SetPoint("BOTTOM", Minimap, "BOTTOM", 0, wantY)
		end
	end

	-- get the indicator frame from the MinimapCluster object
	local indicatorFrame = MinimapCluster.IndicatorFrame
	if indicatorFrame then
		-- set the initial position of the frame
		updateMapAnchor(indicatorFrame)

		-- hook into the SetPoint function to update the frame's position if necessary
		hooksecurefunc(indicatorFrame, "SetPoint", function(frame, ...)
			updateMapAnchor(frame, ..., select(2, frame:GetPoint()))
		end)

		-- set the frame level to 11 to ensure it appears above other elements
		indicatorFrame:SetFrameLevel(11)
	end

	-- Invites Icon
	if GameTimeCalendarInvitesTexture then
		GameTimeCalendarInvitesTexture:ClearAllPoints()
		GameTimeCalendarInvitesTexture:SetParent(Minimap)
		GameTimeCalendarInvitesTexture:SetPoint("TOPLEFT")
	end

	-- Streaming icon
	if StreamingIcon then
		StreamingIcon:ClearAllPoints()
		StreamingIcon:SetParent(Minimap)
		StreamingIcon:SetPoint("LEFT", -6, 0)
		StreamingIcon:SetAlpha(0.5)
		StreamingIcon:SetScale(0.8)
		StreamingIcon:SetFrameStrata("LOW")
	end

	local inviteNotification = CreateFrame("Button", nil, UIParent, "BackdropTemplate")
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
		inviteNotification:SetShown(C_Calendar_GetNumPendingInvites() > 0)
	end
	K:RegisterEvent("CALENDAR_UPDATE_PENDING_INVITES", updateInviteVisibility)
	K:RegisterEvent("PLAYER_ENTERING_WORLD", updateInviteVisibility)

	inviteNotification:SetScript("OnClick", function(_, btn)
		inviteNotification:Hide()

		if btn == "LeftButton" then
			ToggleCalendar()
		end

		K:UnregisterEvent("CALENDAR_UPDATE_PENDING_INVITES", updateInviteVisibility)
		K:UnregisterEvent("PLAYER_ENTERING_WORLD", updateInviteVisibility)
	end)
end

function Module:CreatePing()
	local pingFrame = CreateFrame("Frame", nil, Minimap)
	pingFrame:SetSize(Minimap:GetWidth(), 13)
	pingFrame:SetPoint("BOTTOM", _G.Minimap, "BOTTOM", 0, 30)
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
		if UnitIsUnit(unit, "player") then -- ignore player ping
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
	if TimeManagerClockButton then
		TimeManagerClockButton:Hide()
	end
end

local GameTimeFrameStyled
function Module:ShowCalendar()
	if C["Minimap"].Calendar then
		if not GameTimeFrameStyled then
			local GameTimeFrame = GameTimeFrame
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
				calendarText:SetText(C_DateAndTime_GetCurrentCalendarTime().monthDay)
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
	return K.Round(GetCVar("Sound_MasterVolume") * 100)
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

function Module:Minimap_OnMouseWheel(zoom)
	if IsControlKeyDown() and Module.VolumeText then
		local value = GetCurrentVolume()
		local mult = IsAltKeyDown() and 100 or 2
		value = value + zoom * mult
		if value > 100 then
			value = 100
		end
		if value < 0 then
			value = 0
		end

		SetCVar("Sound_MasterVolume", tostring(value / 100))
		Module.VolumeText:SetText(value .. "%")
		Module.VolumeText:SetTextColor(GetVolumeColor(value))
		Module.VolumeAnim:Stop()
		Module.VolumeAnim:Play()
	else
		if zoom > 0 then
			Minimap_ZoomIn()
		else
			Minimap_ZoomOut()
		end
	end
end

function Module:Minimap_TrackingDropdown()
	local dropdown = CreateFrame("Frame", "KKUI_MiniMapTrackingDropDown", _G.UIParent, "UIDropDownMenuTemplate")
	dropdown:SetID(1)
	dropdown:SetClampedToScreen(true)
	dropdown:Hide()

	_G.UIDropDownMenu_Initialize(dropdown, _G.MiniMapTrackingDropDown_Initialize, "MENU")
	dropdown.noResize = true

	return dropdown
end

function Module:Minimap_OnMouseUp(btn)
	K.EasyMenu:Hide()

	if Module.TrackingDropdown then
		_G.HideDropDownMenu(1, nil, Module.TrackingDropdown)
	end

	local position = Minimap.mover:GetPoint()
	if btn == "MiddleButton" or (btn == "RightButton" and IsShiftKeyDown()) then
		if InCombatLockdown() then
			_G.UIErrorsFrame:AddMessage(K.InfoColor .. _G.ERR_NOT_IN_COMBAT)
			return
		end

		if position:match("LEFT") then
			K.LibEasyMenu.Create(menuList, K.EasyMenu, "cursor", 0, 0)
		else
			K.LibEasyMenu.Create(menuList, K.EasyMenu, "cursor", -160, 0)
		end
	elseif btn == "RightButton" then
		local button = _G.MinimapCluster.Tracking.Button
		if button then
			button:OpenMenu()

			if button.menu then
				local left = position and position:match("RIGHT")
				button.menu:ClearAllPoints()
				button.menu:SetPoint(left and "TOPRIGHT" or "TOPLEFT", Minimap, left and "LEFT" or "RIGHT", left and -4 or 4, 0)
			end
		end
	else
		_G.Minimap:OnClick(self)
	end
end

function Module:SetupHybridMinimap()
	HybridMinimap.CircleMask:SetTexture("Interface\\BUTTONS\\WHITE8X8")
end

function Module:HybridMinimapOnLoad(addon)
	if addon == "Blizzard_HybridMinimap" then
		Module:SetupHybridMinimap()
		K:UnregisterEvent("ADDON_LOADED", Module.HybridMinimapOnLoad)
	end
end

function Module:QueueStatusTimeFormat(seconds)
	local hours = math_floor((seconds % 86400) / 3600)
	if hours > 0 then
		return Module.QueueStatusDisplay.text:SetFormattedText("%d" .. K.MyClassColor .. "h", hours)
	end

	local mins = math_floor((seconds % 3600) / 60)
	if mins > 0 then
		return Module.QueueStatusDisplay.text:SetFormattedText("%d" .. K.MyClassColor .. "m", mins)
	end

	local secs = math_floor(seconds % 60)
	if secs > 0 then
		return Module.QueueStatusDisplay.text:SetFormattedText("%d" .. K.MyClassColor .. "s", secs)
	end
end

function Module:QueueStatusSetTime(seconds)
	local timeInQueue = GetTime() - seconds
	Module:QueueStatusTimeFormat(timeInQueue)
	Module.QueueStatusDisplay.text:SetTextColor(1, 1, 1)
end

function Module:QueueStatusOnUpdate(elapsed)
	-- Replicate QueueStatusEntry_OnUpdate throttle
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
	if Module.QueueStatusDisplay.title == title then
		Module:ClearQueueStatus()
	end
end

function Module:ClearQueueStatus()
	local display = Module.QueueStatusDisplay
	display.text:SetText("")
	display.title = nil
	display.queuedTime = nil
	display.averageWait = nil
	display:SetScript("OnUpdate", nil)
end

function Module:CreateQueueStatusText()
	local display = CreateFrame("Frame", "KKUI_QueueStatusDisplay", _G.QueueStatusButton)
	display.text = display:CreateFontString(nil, "OVERLAY")

	Module.QueueStatusDisplay = display

	_G.QueueStatusButton:HookScript("OnHide", Module.ClearQueueStatus)
	hooksecurefunc("QueueStatusEntry_SetMinimalDisplay", Module.SetMinimalQueueStatus)
	hooksecurefunc("QueueStatusEntry_SetFullDisplay", Module.SetFullQueueStatus)
end

function Module:BlizzardACF()
	local frame = AddonCompartmentFrame
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
	DropDownList1:SetClampedToScreen(true)

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
	MinimapCluster:EnableMouse(false)
	MinimapCluster.Tracking:SetAlpha(0)
	MinimapCluster.Tracking:SetScale(0.0001)
	MinimapCluster.BorderTop:Hide()
	MinimapCluster.ZoneTextButton:Hide()
	Minimap:SetArchBlobRingScalar(0)
	Minimap:SetQuestBlobRingScalar(0)
	K.HideInterfaceOption(Minimap.ZoomIn)
	K.HideInterfaceOption(Minimap.ZoomOut)
	K.HideInterfaceOption(MinimapCompassTexture)
	MinimapCluster:KillEditMode()

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
