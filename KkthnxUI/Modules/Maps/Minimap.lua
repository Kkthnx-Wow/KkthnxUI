local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:NewModule("Minimap")

local math_floor = math.floor
local mod = mod
local pairs = pairs
local select = select
local table_insert = table.insert
local table_sort = table.sort

local C_Calendar_GetNumPendingInvites = C_Calendar.GetNumPendingInvites
local GetUnitName = GetUnitName
local InCombatLockdown = InCombatLockdown
local Minimap = Minimap
local UnitClass = UnitClass
local hooksecurefunc = hooksecurefunc

-- Create the minimap micro menu
local menuFrame = CreateFrame("Frame", "MinimapRightClickMenu", UIParent)
local guildText = IsInGuild() and ACHIEVEMENTS_GUILD_TAB or LOOKINGFORGUILD
local journalText = K.Client == "ruRU" and ENCOUNTER_JOURNAL or ADVENTURE_JOURNAL
local menuList = {
	{
		text = CHARACTER_BUTTON,
		notCheckable = 1,
		func = function()
			ToggleCharacter("PaperDollFrame")
		end,
	},
	{
		text = SPELLBOOK_ABILITIES_BUTTON,
		notCheckable = 1,
		func = function()
			if InCombatLockdown() then
				print("|cffffff00" .. ERR_NOT_IN_COMBAT .. "|r")
				return
			end
			ToggleFrame(SpellBookFrame)
		end,
	},
	{
		text = TALENTS_BUTTON,
		notCheckable = 1,
		func = function()
			if K.Level >= 10 then
				ToggleTalentFrame()
			else
				UIErrorsFrame:AddMessage(format(FEATURE_BECOMES_AVAILABLE_AT_LEVEL, 10), 1, 0.1, 0.1)
			end
		end,
	},
	{
		text = ACHIEVEMENT_BUTTON,
		notCheckable = 1,
		func = function()
			ToggleAchievementFrame()
		end,
	},
	{
		text = QUESTLOG_BUTTON,
		notCheckable = 1,
		func = function()
			ToggleQuestLog()
		end,
	},
	{
		text = guildText,
		notCheckable = 1,
		func = function()
			ToggleGuildFrame()
		end,
	},
	{
		text = SOCIAL_BUTTON,
		notCheckable = 1,
		func = function()
			ToggleFriendsFrame()
		end,
	},
	{
		text = CHAT_CHANNELS,
		notCheckable = 1,
		func = function()
			ToggleChannelFrame()
		end,
	},
	{
		text = PLAYER_V_PLAYER,
		notCheckable = 1,
		func = function()
			if K.Level >= 10 then
				TogglePVPUI()
			else
				UIErrorsFrame:AddMessage(format(FEATURE_BECOMES_AVAILABLE_AT_LEVEL, 10), 1, 0.1, 0.1)
			end
		end,
	},
	{
		text = GROUP_FINDER,
		notCheckable = 1,
		func = function()
			if K.Level >= 10 then
				PVEFrame_ToggleFrame("GroupFinderFrame", nil)
			else
				UIErrorsFrame:AddMessage(format(FEATURE_BECOMES_AVAILABLE_AT_LEVEL, 10), 1, 0.1, 0.1)
			end
		end,
	},
	{
		text = journalText,
		notCheckable = 1,
		func = function()
			if C_AdventureJournal.CanBeShown() then
				ToggleEncounterJournal()
			else
				UIErrorsFrame:AddMessage(FEATURE_NOT_YET_AVAILABLE, 1, 0.1, 0.1)
			end
		end,
	},
	{
		text = COLLECTIONS,
		notCheckable = 1,
		func = function()
			if InCombatLockdown() then
				print("|cffffff00" .. ERR_NOT_IN_COMBAT .. "|r")
				return
			end
			ToggleCollectionsJournal()
		end,
	},
	{
		text = L_MINIMAP_CALENDAR,
		notCheckable = 1,
		func = function()
			ToggleCalendar()
		end,
	},
	{
		text = BATTLEFIELD_MINIMAP,
		notCheckable = 1,
		func = function()
			ToggleBattlefieldMap()
		end,
	},
}

if not IsTrialAccount() and not C_StorePublic.IsDisabledByParentalControls() then
	table_insert(menuList, {
		text = BLIZZARD_STORE,
		notCheckable = 1,
		func = function()
			StoreMicroButton:Click()
		end,
	})
end

if K.Level == MAX_PLAYER_LEVEL then
	table_insert(menuList, {
		text = RATED_PVP_WEEKLY_VAULT,
		notCheckable = 1,
		func = function()
			if not WeeklyRewardsFrame then
				WeeklyRewards_LoadUI()
			end
			ToggleFrame(WeeklyRewardsFrame)
		end,
	})
end

table_insert(menuList, {
	text = K.Title,
	notCheckable = 1,
	bottom = true,
	func = function()
		-- Prevent options panel from showing if Blizzard options panel is showing
		if SettingsPanel:IsShown() or ChatConfigFrame:IsShown() then
			return
		end

		-- No modifier key toggles the options panel
		if InCombatLockdown() then
			UIErrorsFrame:AddMessage(K.InfoColor .. ERR_NOT_IN_COMBAT)
			return
		end

		K["GUI"]:Toggle()
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION)
	end,
})

table_sort(menuList, function(a, b)
	if a and b and a.text and b.text then
		return a.text < b.text
	end
end)

-- We want these two on the bottom
table_insert(menuList, {
	text = MAINMENU_BUTTON,
	notCheckable = 1,
	func = function()
		if not _G.GameMenuFrame:IsShown() then
			if _G.SettingsPanel:IsShown() then
				_G.SettingsPanel.CloseButton:Click()
			end

			CloseMenus()
			CloseAllWindows()
			PlaySound(850) -- IG_MAINMENU_OPEN
			ShowUIPanel(_G.GameMenuFrame)
		else
			PlaySound(854) -- IG_MAINMENU_QUIT
			HideUIPanel(_G.GameMenuFrame)
			MainMenuMicroButton_SetNormal()
		end
	end,
})

table_insert(menuList, { text = HELP_BUTTON, notCheckable = 1, func = ToggleHelpFrame })

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
			if C_Calendar.GetNumPendingInvites() > 0 or MinimapMailFrame:IsShown() then
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
	if not C_Garrison.HasGarrison(...) then
		UIErrorsFrame:AddMessage(K.InfoColor .. CONTRIBUTION_TOOLTIP_UNLOCKED_WHEN_ACTIVE)
		return
	end
	ShowGarrisonLandingPage(...)
end

function Module:ReskinRegions()
	-- Garrison
	local garrMinimapButton = ExpansionLandingPageMinimapButton
	if garrMinimapButton then
		local function updateMinimapButtons(self)
			self:ClearAllPoints()
			self:SetPoint("BOTTOMLEFT", Minimap, "BOTTOMLEFT", 4, 2)
			self:GetNormalTexture():SetAtlas("UI-HUD-UnitFrame-Player-CombatIcon-2x")
			self:GetPushedTexture():SetAtlas("UI-HUD-UnitFrame-Player-CombatIcon-2x")
			self:GetHighlightTexture():SetAtlas("UI-HUD-UnitFrame-Player-CombatIcon-2x")
			self:GetNormalTexture():SetVertexColor(1, 1, 1, 0.9)
			self:GetPushedTexture():SetVertexColor(1, 1, 1, 1)
			self:GetHighlightTexture():SetVertexColor(1, 1, 1, 1)

			self.LoopingGlow:SetAtlas("UI-HUD-UnitFrame-Player-CombatIcon-2x")
			self.LoopingGlow:SetSize(24, 24)

			self:SetHitRectInsets(0, 0, 0, 0)
			self:SetSize(24, 24)
		end
		updateMinimapButtons(garrMinimapButton)
		garrMinimapButton:HookScript("OnShow", updateMinimapButtons)
		hooksecurefunc(garrMinimapButton, "UpdateIcon", updateMinimapButtons)

		local menuList = {
			{
				text = GARRISON_TYPE_9_0_LANDING_PAGE_TITLE,
				func = ToggleLandingPage,
				arg1 = Enum.GarrisonType.Type_9_0,
				notCheckable = true,
			},
			{ text = WAR_CAMPAIGN, func = ToggleLandingPage, arg1 = Enum.GarrisonType.Type_8_0, notCheckable = true },
			{
				text = ORDER_HALL_LANDING_PAGE_TITLE,
				func = ToggleLandingPage,
				arg1 = Enum.GarrisonType.Type_7_0,
				notCheckable = true,
			},
			{
				text = GARRISON_LANDING_PAGE_TITLE,
				func = ToggleLandingPage,
				arg1 = Enum.GarrisonType.Type_6_0,
				notCheckable = true,
			},
		}
		garrMinimapButton:HookScript("OnMouseDown", function(self, btn)
			if btn == "RightButton" then
				if _G.GarrisonLandingPage and _G.GarrisonLandingPage:IsShown() then
					HideUIPanel(_G.GarrisonLandingPage)
				end
				if _G.ExpansionLandingPage and _G.ExpansionLandingPage:IsShown() then
					HideUIPanel(_G.ExpansionLandingPage)
				end
				EasyMenu(menuList, K.EasyMenu, self, -80, 0, "MENU", 1)
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
		QueueStatusButton:ClearAllPoints()
		QueueStatusButton:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMRIGHT", 2, -2)
		QueueStatusButton:SetFrameLevel(999)
		QueueStatusButton:SetSize(33, 33)

		QueueStatusButtonIcon:SetAlpha(0)

		QueueStatusFrame:ClearAllPoints()
		QueueStatusFrame:SetPoint("TOPRIGHT", QueueStatusButton, "TOPLEFT")

		local queueIcon = Minimap:CreateTexture(nil, "ARTWORK")
		queueIcon:SetPoint("CENTER", QueueStatusButton)
		queueIcon:SetSize(50, 50)
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

			if queueStatusDisplay.title then
				Module:ClearQueueStatus()
			end
		end
	end

	-- Difficulty Flags
	local instDifficulty = MinimapCluster.InstanceDifficulty
	if instDifficulty then
		local function updateFlagAnchor(frame, _, _, _, _, _, force)
			if force then
				return
			end
			frame:ClearAllPoints()
			frame:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", 2, 2, true)
		end
		instDifficulty:SetParent(Minimap)
		instDifficulty:SetScale(0.7)
		updateFlagAnchor(instDifficulty)
		hooksecurefunc(instDifficulty, "SetPoint", updateFlagAnchor)

		local function replaceFlag(self)
			self:SetTexture(K.MediaFolder .. "Minimap\\Flag")
		end
		local function reskinDifficulty(frame)
			frame.Border:Hide()
			replaceFlag(frame.Background)
			hooksecurefunc(frame.Background, "SetAtlas", replaceFlag)
		end
		reskinDifficulty(instDifficulty.Instance)
		reskinDifficulty(instDifficulty.Guild)
		reskinDifficulty(instDifficulty.ChallengeMode)
	end

	local function updateMapAnchor(frame, _, _, newAnchor, _, _, force)
		-- exit if the 'force' argument is passed in
		if force then
			return
		end

		-- check if the new position is different from the current position
		local currentAnchor = { frame:GetPoint() }
		if not (currentAnchor[1] == newAnchor and currentAnchor[2] == Minimap and currentAnchor[3] == "BOTTOM" and currentAnchor[4] == 0 and (C["DataText"].Time and currentAnchor[5] == 20 or currentAnchor[5] == 4)) then
			-- reset the frame's position
			frame:ClearAllPoints()

			-- set the frame's position based on the value of C["DataText"].Time
			if C["DataText"].Time then
				frame:SetPoint("BOTTOM", Minimap, "BOTTOM", 0, 20)
			else
				frame:SetPoint("BOTTOM", Minimap, "BOTTOM", 0, 4)
			end
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
		GameTimeCalendarInvitesTexture:SetPoint("TOPRIGHT")
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

	K.CreateFontString(inviteNotification, 12, K.InfoColor .. "Pending Calendar Invite(s)!", "")

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

-- Show Calendar Function
function Module:ShowCalendar()
	-- Check if Calendar is enabled in config
	if C["Minimap"].Calendar then
		-- If the Calendar is not styled yet
		if not GameTimeFrame.styled then
			-- Set the parent frame as Minimap
			GameTimeFrame:SetParent(Minimap)
			-- Set the frame level to 16
			GameTimeFrame:SetFrameLevel(16)
			-- Clear any existing points
			GameTimeFrame:ClearAllPoints()
			-- Set the position to top right of the Minimap with a 4 pixel offset
			GameTimeFrame:SetPoint("TOPRIGHT", Minimap, -4, -4)
			-- Set the hit rect insets to 0
			GameTimeFrame:SetHitRectInsets(0, 0, 0, 0)
			-- Set the size to 22x22
			GameTimeFrame:SetSize(22, 22)

			-- Create a font string
			local fs = GameTimeFrame:CreateFontString(nil, "OVERLAY")
			-- Clear any existing points
			fs:ClearAllPoints()
			-- Set the position to the center with a -5 pixel offset
			fs:SetPoint("CENTER", 0, -5)
			-- Set the font object
			fs:SetFontObject(K.UIFont)
			-- Set the font to the selected font, with a size of 12 and the selected font style
			fs:SetFont(select(1, fs:GetFont()), 12, select(3, fs:GetFont()))
			-- Set the text color to black
			fs:SetTextColor(0, 0, 0)
			-- Set the shadow offset to 0, 0
			fs:SetShadowOffset(0, 0)
			-- Set the alpha to 0.9
			fs:SetAlpha(0.9)

			-- Secure hook for "GameTimeFrame_SetDate"
			hooksecurefunc("GameTimeFrame_SetDate", function()
				-- Set the normal texture
				GameTimeFrame:SetNormalTexture("Interface\\AddOns\\KkthnxUI\\Media\\Minimap\\Calendar.blp")
				-- Set the pushed texture
				GameTimeFrame:SetPushedTexture("Interface\\AddOns\\KkthnxUI\\Media\\Minimap\\Calendar.blp")
				-- Set the highlight texture to 0
				GameTimeFrame:SetHighlightTexture(0)
				-- Set the normal texture's TexCoord to 0, 1, 0, 1
				GameTimeFrame:GetNormalTexture():SetTexCoord(0, 1, 0, 1)
				-- Set the pushed texture's TexCoord to 0, 1, 0, 1
				GameTimeFrame:GetPushedTexture():SetTexCoord(0, 1, 0, 1)

				-- Set the text to the current calendar month day
				fs:SetText(C_DateAndTime.GetCurrentCalendarTime().monthDay)
			end)

			-- Set style to true
			GameTimeFrame.styled = true
		end
		-- Show the GameTimeFrame
		GameTimeFrame:Show()
	else
		-- Hide the GameTimeFrame
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
	menuFrame:Hide()

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
			EasyMenu(menuList, menuFrame, "cursor", 0, 0)
		else
			EasyMenu(menuList, menuFrame, "cursor", -160, 0)
		end
	elseif btn == "RightButton" and Module.TrackingDropdown then
		if position:match("LEFT") then
			ToggleDropDownMenu(1, nil, Module.TrackingDropdown, "cursor", 0, 0)
		else
			ToggleDropDownMenu(1, nil, Module.TrackingDropdown, "cursor", -160, 0)
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
		K:UnregisterEvent(self, Module.HybridMinimapOnLoad)
	end
end

function Module:UpdateBlipTexture()
	Minimap:SetBlipTexture(C["Minimap"].BlipTexture.Value)
end

function Module:QueueStatusTimeFormat(seconds)
	local hours = math_floor(mod(seconds, 86400) / 3600)
	if hours > 0 then
		return Module.QueueStatusDisplay.text:SetFormattedText("%d" .. K.MyClassColor .. "h", hours)
	end

	local mins = math_floor(mod(seconds, 3600) / 60)
	if mins > 0 then
		return Module.QueueStatusDisplay.text:SetFormattedText("%d" .. K.MyClassColor .. "m", mins)
	end

	local secs = math_floor(seconds, 60)
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
	self:UpdateBlipTexture()
	self:UpdateMinimapScale()
	if _G.QueueStatusButton then
		Module:CreateQueueStatusText()
	end

	Minimap:EnableMouseWheel(true)
	Minimap:SetScript("OnMouseWheel", Module.Minimap_OnMouseWheel)
	Minimap:SetScript("OnMouseUp", Module.Minimap_OnMouseUp)

	-- Hide Blizz
	MinimapCluster:EnableMouse(false)
	MinimapCluster.Tracking:Hide()
	MinimapCluster.BorderTop:Hide()
	MinimapCluster.ZoneTextButton:Hide()
	Minimap:SetArchBlobRingScalar(0)
	Minimap:SetQuestBlobRingScalar(0)
	K.HideInterfaceOption(Minimap.ZoomIn)
	K.HideInterfaceOption(Minimap.ZoomOut)
	K.HideInterfaceOption(MinimapCompassTexture)

	-- Add Elements
	self:CreatePing()
	self:CreateRecycleBin()
	self:CreateSoundVolume()
	self:CreateStyle()
	self:ReskinRegions()

	-- HybridMinimap
	K:RegisterEvent("ADDON_LOADED", Module.HybridMinimapOnLoad)
end
