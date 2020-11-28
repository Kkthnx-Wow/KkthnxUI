local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("Minimap")

local _G = _G
local pairs = _G.pairs
local select = _G.select
local string_format = _G.string.format

local C_Calendar_GetNumPendingInvites = _G.C_Calendar.GetNumPendingInvites
local ERR_NOT_IN_COMBAT = _G.ERR_NOT_IN_COMBAT
local GetUnitName = _G.GetUnitName
local HideUIPanel = _G.HideUIPanel
local InCombatLockdown = _G.InCombatLockdown
local IsInGuild = _G.IsInGuild
local LE_GARRISON_TYPE_6_0 = _G.Enum.GarrisonType.Type_6_0
local LE_GARRISON_TYPE_7_0 = _G.Enum.GarrisonType.Type_7_0
local LE_GARRISON_TYPE_8_0 = _G.Enum.GarrisonType.Type_8_0
local LE_GARRISON_TYPE_9_0 = _G.Enum.GarrisonType.Type_9_0
local Minimap = _G.Minimap
local UnitClass = _G.UnitClass
local table_insert = _G.table.insert

-- Create the new minimap tracking dropdown frame and initialize it
local KKUI_MiniMapTrackingDropDown = CreateFrame("Frame", "KKUI_MiniMapTrackingDropDown", _G.UIParent, "UIDropDownMenuTemplate")
KKUI_MiniMapTrackingDropDown:SetID(1)
KKUI_MiniMapTrackingDropDown:SetClampedToScreen(true)
KKUI_MiniMapTrackingDropDown:Hide()
_G.UIDropDownMenu_Initialize(KKUI_MiniMapTrackingDropDown, _G.MiniMapTrackingDropDown_Initialize, "MENU")
KKUI_MiniMapTrackingDropDown.noResize = true

local checkMinLevel = 10 -- Previous Constants were removed but all these are unlocked at 10.

-- Create the minimap micro menu
local menuFrame = CreateFrame("Frame", "MinimapRightClickMenu", UIParent, "UIDropDownMenuTemplate")
local guildText = IsInGuild() and ACHIEVEMENTS_GUILD_TAB or LOOKINGFORGUILD
local micromenu = {
	{text = K.SystemColor.."Micro Menu", notClickable = true, notCheckable = true},
	{text = "", notClickable = true, notCheckable = true},

	{text = CHARACTER_BUTTON, notCheckable = 1, func = function()
			ToggleCharacter("PaperDollFrame")
	end},

	{text = SPELLBOOK_ABILITIES_BUTTON, notCheckable = 1, func = function()
			ToggleFrame(SpellBookFrame)
	end},

	{text = TALENTS_BUTTON, notCheckable = 1, func = function()
			if not PlayerTalentFrame then
				TalentFrame_LoadUI()
			end
			if K.Level >= 10 then
				ShowUIPanel(PlayerTalentFrame)
			else
				K.Print(K.InfoColor..string_format(FEATURE_BECOMES_AVAILABLE_AT_LEVEL, checkMinLevel).."|r")
			end
	end},

	{text = ACHIEVEMENT_BUTTON, notCheckable = 1, func = function()
			ToggleAchievementFrame()
	end},

	{text = QUESTLOG_BUTTON, notCheckable = 1, func = function()
			ToggleQuestLog()
	end},

	{text = guildText, notCheckable = 1, func = function()
			ToggleGuildFrame()
	end},

	{text = SOCIAL_BUTTON, notCheckable = 1, func = function()
			ToggleFriendsFrame(1)
	end},

	{text = RAID, notCheckable = 1, func = function()
			ToggleFriendsFrame(3)
	end},

	{text = CHAT_CHANNELS, notCheckable = 1, func = function()
			ToggleChannelFrame()
	end},

	{text = PLAYER_V_PLAYER, notCheckable = 1, func = function()
			if K.Level >= checkMinLevel then
				TogglePVPUI()
			else
				K.Print(K.InfoColor..string_format(FEATURE_BECOMES_AVAILABLE_AT_LEVEL, checkMinLevel).."|r")
			end
	end},

	{text = DUNGEONS_BUTTON, notCheckable = 1, func = function()
			if K.Level >= checkMinLevel then
				PVEFrame_ToggleFrame("GroupFinderFrame", nil)
			else
				K.Print(K.InfoColor..string_format(FEATURE_BECOMES_AVAILABLE_AT_LEVEL, checkMinLevel).."|r")
			end
	end},

	{text = ADVENTURE_JOURNAL, notCheckable = 1, func = function()
			if C_AdventureJournal.CanBeShown() then
				ToggleEncounterJournal()
			else
				K.Print(K.InfoColor..FEATURE_NOT_YET_AVAILABLE.."|r")
			end
	end},

	{text = QUESTLOG_BUTTON, notCheckable = 1, func = function()
			OpenQuestLog()
	end},

	{text = MOUNTS, notCheckable = 1, func = function()
			ToggleCollectionsJournal(1)
	end},

	{text = PETS, notCheckable = 1, func = function()
			ToggleCollectionsJournal(2)
	end},

	{text = TOY_BOX, notCheckable = 1, func = function()
			ToggleCollectionsJournal(3)
	end},

	{text = HEIRLOOMS, notCheckable = 1, func = function()
			ToggleCollectionsJournal(4)
	end},

	{text = WARDROBE, notCheckable = 1, func = function()
			if InCombatLockdown() then
				K.Print(K.InfoColor..ERR_NOT_IN_COMBAT.."|r") return
			end
			ToggleCollectionsJournal(5)
	end},

	{text = HELP_BUTTON, notCheckable = 1, func = function()
			ToggleHelpFrame()
	end},

	{text = EVENTS_LABEL, notCheckable = 1, func = function()
			ToggleCalendar()
	end},

	{text = BATTLEFIELD_MINIMAP, notCheckable = 1, func = function()
			ToggleBattlefieldMap()
	end},

	{text = LOOT_ROLLS, notCheckable = 1, func = function()
			ToggleFrame(LootHistoryFrame)
	end},
}

if not IsTrialAccount() and not C_StorePublic.IsDisabledByParentalControls() then
	table_insert(micromenu, {text = BLIZZARD_STORE, notCheckable = 1, func = function()
			StoreMicroButton:Click()
	end})
end

if K.Level > 99 then
	table_insert(micromenu, {text = ORDER_HALL_LANDING_PAGE_TITLE, notCheckable = 1, func = function()
			GarrisonLandingPage_Toggle()
	end})
elseif K.Level > 89 then
	table_insert(micromenu, {text = GARRISON_LANDING_PAGE_TITLE, notCheckable = 1, func = function()
			GarrisonLandingPage_Toggle()
	end})
end

function Module:CreateStyle()
	local minimapBorder = CreateFrame("Frame", nil, Minimap)
	minimapBorder:SetAllPoints(Minimap)
	minimapBorder:SetFrameLevel(Minimap:GetFrameLevel())
	minimapBorder:CreateBorder()

	local minimapMailPulse = CreateFrame("Frame", nil, Minimap, "BackdropTemplate")
	minimapMailPulse:SetBackdrop({edgeFile = "Interface\\AddOns\\KkthnxUI\\Media\\Border\\Border_Glow_Overlay", edgeSize = 12})
	minimapMailPulse:SetPoint("TOPLEFT", minimapBorder, -6, 6)
	minimapMailPulse:SetPoint("BOTTOMRIGHT", minimapBorder, 6, -6)
	minimapMailPulse:SetBackdropBorderColor(1, 1, 0, 0.6)
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
				minimapMailPulse:Show()
				anim:Play()
			else
				anim:Stop()
				minimapMailPulse:Hide()
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

		anim:Stop()
		minimapMailPulse:Hide()
	end)
end

function Module:ReskinRegions()
	-- Garrison
	if C["Minimap"].ShowGarrison then
		hooksecurefunc("GarrisonLandingPageMinimapButton_UpdateIcon", function(self)
			self:ClearAllPoints()
			self:SetPoint("BOTTOMLEFT", Minimap, "BOTTOMLEFT", 0, 0)
			self:GetNormalTexture():SetTexture("Interface\\HelpFrame\\HelpIcon-ReportLag")
			self:GetPushedTexture():SetTexture("Interface\\HelpFrame\\HelpIcon-ReportLag")
			self:GetHighlightTexture():SetTexture("Interface\\HelpFrame\\HelpIcon-ReportLag")
			self:SetSize(30, 30)
		end)

		local menuList = {
			{text =	GARRISON_TYPE_9_0_LANDING_PAGE_TITLE, func = ToggleLandingPage, arg1 = LE_GARRISON_TYPE_9_0, notCheckable = true},
			{text =	WAR_CAMPAIGN, func = ToggleLandingPage, arg1 = LE_GARRISON_TYPE_8_0, notCheckable = true},
			{text =	ORDER_HALL_LANDING_PAGE_TITLE, func = ToggleLandingPage, arg1 = LE_GARRISON_TYPE_7_0, notCheckable = true},
			{text =	GARRISON_LANDING_PAGE_TITLE, func = ToggleLandingPage, arg1 = LE_GARRISON_TYPE_6_0, notCheckable = true},
		}
		GarrisonLandingPageMinimapButton:HookScript("OnMouseDown", function(self, btn)
			if btn == "RightButton" then
				HideUIPanel(GarrisonLandingPage)
				EasyMenu(menuList, K.EasyMenu, self, -80, 0, "MENU", 1)
			end
		end)

		GarrisonLandingPageMinimapButton:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_LEFT")
			GameTooltip:SetText(self.title, 1, 1, 1)
			GameTooltip:AddLine(self.description, nil, nil, nil, true)
			GameTooltip:AddLine("Right click to switch garrisons", nil, nil, nil, true)
			GameTooltip:Show();
		end)
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

	local inviteNotification = CreateFrame("Button", nil, UIParent, "BackdropTemplate")
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
	pingFrame.text = K.CreateFontString(pingFrame, 18, "", "OUTLINE", false, "CENTER")

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

function Module:HideMinimapClock()
	if TimeManagerClockButton then
		TimeManagerClockButton:Hide()
	end
end

function Module:ShowCalendar()
	if C["Minimap"].Calendar then
		if not GameTimeFrame.styled then
			GameTimeFrame:SetParent(Minimap)
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
			fs:FontTemplate(nil, 20)
			fs:SetShadowOffset(0, 0)

			GameTimeFrame.styled = true
		end
		GameTimeFrame:Show()
	else
		GameTimeFrame:Hide()
	end
end

function Module:Minimap_OnMouseWheel(zoom)
	if zoom > 0 then
		Minimap_ZoomIn()
	else
		Minimap_ZoomOut()
	end
end

function Module:Minimap_OnMouseUp(btn)
	_G.HideDropDownMenu(1, nil, KKUI_MiniMapTrackingDropDown)
	menuFrame:Hide()

	local position = Minimap.mover:GetPoint()
	if btn == "MiddleButton" or (btn == "RightButton" and IsShiftKeyDown()) then
		if InCombatLockdown() then
			_G.UIErrorsFrame:AddMessage(K.InfoColor.._G.ERR_NOT_IN_COMBAT)
			return
		end

		if position:match("LEFT") then
			EasyMenu(micromenu, menuFrame, "cursor", 0, 0, "MENU")
		else
			EasyMenu(micromenu, menuFrame, "cursor", -160, 0, "MENU")
		end
	elseif btn == "RightButton" then
		if position:match("LEFT") then
			ToggleDropDownMenu(1, nil, KKUI_MiniMapTrackingDropDown, "cursor", 0, 0, "MENU", 2)
		else
			ToggleDropDownMenu(1, nil, KKUI_MiniMapTrackingDropDown, "cursor", -160, 0, "MENU", 2)
		end
	else
		_G.Minimap_OnClick(self)
	end
end

function Module:SetupHybridMinimap()
	local mapCanvas = HybridMinimap.MapCanvas
	mapCanvas:SetMaskTexture(C["Media"].Blank)
	mapCanvas:SetScript("OnMouseWheel", Module.Minimap_OnMouseWheel)
	mapCanvas:SetScript("OnMouseUp", Module.Minimap_OnMouseUp)
	mapCanvas:SetScript('OnMouseUp', K.Noop)

	HybridMinimap.CircleMask:StripTextures()
end

function Module:HybridMinimapOnLoad(addon)
	if addon == "Blizzard_HybridMinimap" then
		Module:SetupHybridMinimap()
		K:UnregisterEvent(self, Module.HybridMinimapOnLoad)
	end
end

local minimapInfo = {
	text = L["MinimapHelpTip"],
	buttonStyle = HelpTip.ButtonStyle.GotIt,
	targetPoint = HelpTip.Point.LeftEdgeBottom,
	onAcknowledgeCallback = K.HelpInfoAcknowledge,
	callbackArg = "MinimapInfo",
	alignment = 3,
}

function Module:ShowMinimapHelpInfo()
	Minimap:HookScript("OnEnter", function()
		if not KkthnxUIData[K.Realm][K.Name].Help["MinimapInfo"] then
			HelpTip:Show(MinimapCluster, minimapInfo)
		end
	end)
end

function Module:OnEnable()
	if not C["Minimap"].Enable then
		return
	end

	-- Shape and Position
	Minimap:SetFrameLevel(10)
	Minimap:SetMaskTexture(C["Media"].Blank)
	DropDownList1:SetClampedToScreen(true)

	local minimapMover = K.Mover(Minimap, "Minimap", "Minimap", {"TOPRIGHT", UIParent, "TOPRIGHT", -4, -4})
	Minimap:ClearAllPoints()
	Minimap:SetPoint("TOPRIGHT", minimapMover)
	Minimap.mover = minimapMover

	self:UpdateMinimapScale()
	self:HideMinimapClock()
	self:ShowCalendar()

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
	self:CreateStyle()
	self:CreateRecycleBin()
	self:ReskinRegions()
	self:ShowMinimapHelpInfo()

	-- HybridMinimap
	K:RegisterEvent("ADDON_LOADED", Module.HybridMinimapOnLoad)
end