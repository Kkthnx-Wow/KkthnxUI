local K, C, L = unpack(KkthnxUI)
local Module = K:NewModule("Minimap")

local _G = _G
local math_floor = _G.math.floor
local mod = _G.mod
local pairs = _G.pairs
local select = _G.select
local table_insert = _G.table.insert
local table_sort = _G.table.sort

local C_Calendar_GetNumPendingInvites = _G.C_Calendar.GetNumPendingInvites
local GetUnitName = _G.GetUnitName
local InCombatLockdown = _G.InCombatLockdown
local Minimap = _G.Minimap
local UnitClass = _G.UnitClass
local hooksecurefunc = _G.hooksecurefunc

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
				K.Print("|cffffff00" .. ERR_NOT_IN_COMBAT .. "|r")
				return
			end
			ToggleFrame(SpellBookFrame)
		end,
	},
	{
		text = TALENTS_BUTTON,
		notCheckable = 1,
		func = function()
			if not PlayerTalentFrame then
				TalentFrame_LoadUI()
			end
			if K.Level >= 10 then
				ShowUIPanel(PlayerTalentFrame)
			else
				UIErrorsFrame:AddMessage(format(FEATURE_BECOMES_AVAILABLE_AT_LEVEL, 10), 1, 0.1, 0.1)
				K.Print("|cffffff00" .. format(FEATURE_BECOMES_AVAILABLE_AT_LEVEL, 10) .. "|r")
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
				K.Print("|cffffff00" .. format(FEATURE_BECOMES_AVAILABLE_AT_LEVEL, 10) .. "|r")
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
				K.Print("|cffffff00" .. format(FEATURE_BECOMES_AVAILABLE_AT_LEVEL, 10) .. "|r")
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
				K.Print("|cffffff00" .. FEATURE_NOT_YET_AVAILABLE .. "|r")
			end
		end,
	},
	{
		text = COLLECTIONS,
		notCheckable = 1,
		func = function()
			if InCombatLockdown() then
				K.Print("|cffffff00" .. ERR_NOT_IN_COMBAT .. "|r")
				return
			end
			ToggleCollectionsJournal()
		end,
	},
	{
		text = "Calendar",
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
		if InterfaceOptionsFrame:IsShown() or VideoOptionsFrame:IsShown() or ChatConfigFrame:IsShown() then
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
	text = _G.MAINMENU_BUTTON,
	notCheckable = 1,
	func = function()
		if not _G.GameMenuFrame:IsShown() then
			if _G.VideoOptionsFrame:IsShown() then
				_G.VideoOptionsFrameCancel:Click()
			elseif _G.AudioOptionsFrame:IsShown() then
				_G.AudioOptionsFrameCancel:Click()
			elseif _G.InterfaceOptionsFrame:IsShown() then
				_G.InterfaceOptionsFrameCancel:Click()
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

table_insert(menuList, { text = _G.HELP_BUTTON, notCheckable = 1, func = ToggleHelpFrame })

function Module:CreateStyle()
	local minimapBorder = CreateFrame("Frame", "KKUI_MinimapBorder", Minimap)
	minimapBorder:SetAllPoints(Minimap)
	minimapBorder:SetFrameLevel(Minimap:GetFrameLevel())
	minimapBorder:SetFrameStrata("LOW")
	minimapBorder:CreateBorder(nil, nil, nil, nil, nil, nil, nil, nil, nil, "", nil, nil, nil, nil, nil, nil, nil)

	local minimapBackground = CreateFrame("Frame", "KKUI_MinimapBackground", Minimap)
	minimapBackground:SetAllPoints(Minimap)
	minimapBackground:SetFrameLevel(Minimap:GetFrameLevel())
	minimapBackground:SetFrameStrata("BACKGROUND")
	minimapBackground:CreateBorder(nil, nil, nil, "", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil)

	if not C["Minimap"].MailPulse then
		return
	end

	local minimapMailPulse = CreateFrame("Frame", nil, Minimap, "BackdropTemplate")
	minimapMailPulse:SetBackdrop({ edgeFile = "Interface\\AddOns\\KkthnxUI\\Media\\Border\\Border_Glow_Overlay", edgeSize = 12 })
	minimapMailPulse:SetPoint("TOPLEFT", minimapBorder, -5, 5)
	minimapMailPulse:SetPoint("BOTTOMRIGHT", minimapBorder, 5, -5)
	minimapMailPulse:SetBackdropBorderColor(1, 1, 0, 0.8)
	minimapMailPulse:Hide()

	local anim = minimapMailPulse:CreateAnimationGroup()
	anim:SetLooping("BOUNCE")
	anim.fader = anim:CreateAnimation("Alpha")
	anim.fader:SetFromAlpha(0.8)
	anim.fader:SetToAlpha(0.2)
	anim.fader:SetDuration(1)
	anim.fader:SetSmoothing("OUT")

	local function updateMinimapBorderAnimation()
		if not InCombatLockdown() then
			if C_Calendar_GetNumPendingInvites() > 0 or MiniMapMailFrame:IsShown() and not IsInInstance() then
				if not anim:IsPlaying() then
					minimapMailPulse:Show()
					anim:Play()
				end
			else
				if anim and anim:IsPlaying() then
					anim:Stop()
					minimapMailPulse:Hide()
				end
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

		if anim and anim:IsPlaying() then
			anim:Stop()
			minimapMailPulse:Hide()
		end
	end)
end

-- This is just weird to do this but I hate the default icons for covs
local function UpdateCovenantTexture(texture)
	local CovenantID = C_Covenants.GetActiveCovenantID()
	local CovenantType = Enum.CovenantType
	local TexturePath = "Interface\\AddOns\\KkthnxUI\\Media\\Minimap\\"

	if CovenantID ~= CovenantType.None then
		if CovenantID == CovenantType.Kyrian then
			texture = TexturePath .. "Kyrian"
		elseif CovenantID == CovenantType.Venthyr then
			texture = TexturePath .. "Venthyr"
		elseif CovenantID == CovenantType.NightFae then
			texture = TexturePath .. "NightFae"
		elseif CovenantID == CovenantType.Necrolord then
			texture = TexturePath .. "Necrolords"
		end
	else
		if CovenantID == CovenantType.None then -- No cov so default to differnt icons?
			if K.Faction == "Alliance" then
				texture = TexturePath .. "Alliance"
			else
				texture = TexturePath .. "Horde"
			end
		end
	end

	return texture
end

function Module:ReskinRegions()
	GarrisonLandingPageMinimapButton:SetSize(22, 22)
	hooksecurefunc("GarrisonLandingPageMinimapButton_UpdateIcon", function(self)
		self:ClearAllPoints()
		self:SetPoint("BOTTOMLEFT", Minimap, "BOTTOMLEFT", 4, 4)
		self:SetSize(22, 22)
		self.LoopingGlow:SetSize(24, 24)

		self:GetNormalTexture():SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
		self:GetPushedTexture():SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
		self:GetHighlightTexture():SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
		self.LoopingGlow:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])

		self:SetNormalTexture(UpdateCovenantTexture(self))
		self:SetPushedTexture(UpdateCovenantTexture(self))
		self:SetHighlightTexture(UpdateCovenantTexture(self))
		self.LoopingGlow:SetTexture(UpdateCovenantTexture(self))

		self:GetPushedTexture():SetVertexColor(1, 1, 0, 0.5)

		self:SetHitRectInsets(0, 0, 0, 0)
	end)
	GarrisonLandingPageMinimapButton:SetScript("OnEnter", K.LandingButton_OnEnter)
	GarrisonLandingPageMinimapButton:SetFrameLevel(999)

	-- QueueStatus Button
	if QueueStatusMinimapButton then
		QueueStatusMinimapButton:ClearAllPoints()
		QueueStatusMinimapButton:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMRIGHT", 2, -2)
		QueueStatusMinimapButtonBorder:Hide()
		QueueStatusMinimapButtonIconTexture:SetTexture(nil)
		QueueStatusMinimapButton:SetFrameLevel(999)

		local queueIcon = Minimap:CreateTexture(nil, "OVERLAY")
		queueIcon:SetPoint("CENTER", QueueStatusMinimapButton)
		queueIcon:SetSize(50, 50)
		queueIcon:SetTexture("Interface\\Minimap\\Dungeon_Icon")

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

		local queueStatusDisplay = Module.QueueStatusDisplay
		if queueStatusDisplay then
			queueStatusDisplay.text:ClearAllPoints()
			queueStatusDisplay.text:SetPoint("CENTER", queueIcon, 0, -5)
			queueStatusDisplay.text:SetFontObject(K.UIFont)

			if queueStatusDisplay.title then
				Module:ClearQueueStatus()
			end
		end
	end

	-- Difficulty Flags
	local difficultyFlags = {
		"MiniMapInstanceDifficulty",
		"GuildInstanceDifficulty",
		"MiniMapChallengeMode",
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
			MiniMapMailFrame:SetPoint("BOTTOM", Minimap, "BOTTOM", 0, -4)
		else
			MiniMapMailFrame:SetPoint("BOTTOM", Minimap, "BOTTOM", 0, -12)
		end
		MiniMapMailIcon:SetTexture("Interface\\HELPFRAME\\ReportLagIcon-Mail")
		MiniMapMailFrame:SetScale(1.8)
		MiniMapMailIcon:SetRotation(rad(-27.5))
		MiniMapMailFrame:SetHitRectInsets(11, 11, 11, 15)
	end

	-- Invites Icon
	if GameTimeCalendarInvitesTexture then
		GameTimeCalendarInvitesTexture:ClearAllPoints()
		GameTimeCalendarInvitesTexture:SetParent("Minimap")
		GameTimeCalendarInvitesTexture:SetPoint("TOPRIGHT")
	end

	-- Streaming icon
	if StreamingIcon then
		StreamingIcon:ClearAllPoints()
		StreamingIcon:SetParent("Minimap")
		StreamingIcon:SetPoint("LEFT", -6, 0)
		StreamingIcon:SetAlpha(0.5)
		StreamingIcon:SetScale(0.8)
		StreamingIcon:SetFrameStrata("LOW")
	end

	local inviteNotification = CreateFrame("Button", nil, UIParent, "BackdropTemplate")
	inviteNotification:SetBackdrop({ edgeFile = "Interface\\AddOns\\KkthnxUI\\Media\\Border\\Border_Glow_Overlay", edgeSize = 12 })
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

function Module:ShowCalendar()
	if C["Minimap"].Calendar then
		if not GameTimeFrame.styled then
			GameTimeFrame:SetParent(Minimap)
			GameTimeFrame:SetFrameLevel(16)
			GameTimeFrame:SetScale(0.54)
			GameTimeFrame:ClearAllPoints()
			GameTimeFrame:SetPoint("TOPRIGHT", Minimap, -4, -4)
			GameTimeFrame:SetHitRectInsets(0, 0, 0, 0)
			GameTimeFrame:GetNormalTexture():SetTexCoord(0, 1, 0, 1)
			GameTimeFrame:SetNormalTexture("Interface\\AddOns\\KkthnxUI\\Media\\Minimap\\Calendar.blp")
			GameTimeFrame:SetPushedTexture(nil)
			GameTimeFrame:SetHighlightTexture(nil)

			local fs = GameTimeFrame:GetFontString()
			fs:ClearAllPoints()
			fs:SetPoint("CENTER", 0, -5)
			fs:SetFontObject(K.UIFont)
			fs:SetFont(select(1, fs:GetFont()), 20, select(3, fs:GetFont()))
			fs:SetAlpha(0.9)
			fs:SetShadowOffset(0, 0)

			GameTimeFrame.styled = true
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
		_G.Minimap_OnClick(self)
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
	local display = CreateFrame("Frame", "KKUI_QueueStatusDisplay", _G.QueueStatusMinimapButton)
	display.text = display:CreateFontString(nil, "OVERLAY")

	Module.QueueStatusDisplay = display

	_G.QueueStatusMinimapButton:HookScript("OnHide", Module.ClearQueueStatus)
	hooksecurefunc("QueueStatusEntry_SetMinimalDisplay", Module.SetMinimalQueueStatus)
	hooksecurefunc("QueueStatusEntry_SetFullDisplay", Module.SetFullQueueStatus)
end

function Module:OnEnable()
	if not C["Minimap"].Enable then
		return
	end

	-- Shape and Position
	Minimap:SetFrameLevel(10)
	Minimap:SetMaskTexture(C["Media"].Textures.BlankTexture)
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
	if _G.QueueStatusMinimapButton then
		Module:CreateQueueStatusText()
	end

	Minimap:EnableMouseWheel(true)
	Minimap:SetScript("OnMouseWheel", Module.Minimap_OnMouseWheel)
	Minimap:SetScript("OnMouseUp", Module.Minimap_OnMouseUp)

	-- Hide Blizz
	local frames = {
		"MinimapBorderTop",
		"MinimapNorthTag",
		"MinimapBorder",
		"MinimapZoneTextButton",
		"MinimapZoomOut",
		"MinimapZoomIn",
		"MiniMapWorldMapButton",
		"MiniMapMailBorder",
		"MiniMapTracking",
	}

	for _, v in pairs(frames) do
		K.HideInterfaceOption(_G[v])
	end

	MinimapCluster:EnableMouse(false)
	Minimap:SetArchBlobRingScalar(0)
	Minimap:SetQuestBlobRingScalar(0)

	-- Add Elements
	self:CreatePing()
	self:CreateRecycleBin()
	self:CreateSoundVolume()
	self:CreateStyle()
	self:ReskinRegions()

	-- HybridMinimap
	K:RegisterEvent("ADDON_LOADED", Module.HybridMinimapOnLoad)
end
