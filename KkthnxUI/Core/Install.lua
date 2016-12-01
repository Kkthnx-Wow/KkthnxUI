local K, C, L = select(2, ...):unpack()

-- LUA API
local _G = _G
local format = format
local min, max = math.min, math.max
local match = string.match
local unpack, select = unpack, select
local print = print

-- WOW API
local CreateFrame = CreateFrame
local SetCVar = SetCVar
local ReloadUI = ReloadUI
local ChatFrame_AddMessageGroup = ChatFrame_AddMessageGroup
local ChatFrame_RemoveAllMessageGroups = ChatFrame_RemoveAllMessageGroups
local ChatFrame_AddChannel = ChatFrame_AddChannel
local ChatFrame_RemoveChannel = ChatFrame_RemoveChannel
local ChangeChatColor = ChangeChatColor
local ToggleChatColorNamesByClassGroup = ToggleChatColorNamesByClassGroup
local FCF_ResetChatWindows = FCF_ResetChatWindows
local FCF_SetLocked = FCF_SetLocked
local FCF_DockFrame, FCF_UnDockFrame = FCF_DockFrame, FCF_UnDockFrame
local FCF_OpenNewWindow = FCF_OpenNewWindow
local FCF_SavePositionAndDimensions = FCF_SavePositionAndDimensions
local FCF_GetChatWindowInfo = FCF_GetChatWindowInfo
local FCF_SetWindowName = FCF_SetWindowName
local FCF_StopDragging = FCF_StopDragging
local FCF_SetChatWindowFontSize = FCF_SetChatWindowFontSize
local NUM_CHAT_WINDOWS = NUM_CHAT_WINDOWS
local LOOT, GENERAL, TRADE = LOOT, GENERAL, TRADE

-- Simple Install
local function InstallUI()
	local ActionBars = C.ActionBar.Enable

	-- CVars
	SetCVar("NamePlateHorizontalScale", 1)
	SetCVar("NamePlateVerticalScale", 1)
	SetCVar("ShowClassColorInNameplate", 1)
	SetCVar("UberTooltips", 1)
	SetCVar("WhisperMode", "inline")
	SetCVar("WholeChatWindowClickable", 0)
	SetCVar("alwaysShowActionBars", 1)
	SetCVar("autoOpenLootHistory", 0)
	SetCVar("autoQuestProgress", 1)
	SetCVar("autoQuestWatch", 1)
	SetCVar("buffDurations", 1)
	SetCVar("cameraDistanceMaxZoomFactor", 2.6)
	SetCVar("chatMouseScroll", 1)
	SetCVar("chatStyle", "im")
	SetCVar("countdownForCooldowns", 0)
	SetCVar("nameplateShowSelf", 0)
	SetCVar("removeChatDelay", 1)
	SetCVar("screenshotQuality", 8)
	SetCVar("scriptErrors", 1)
	SetCVar("showArenaEnemyFrames", 0)
	SetCVar("showTutorials", 0)
	SetCVar("showVKeyCastbar", 1)
	SetCVar("spamFilter", 0)
	SetCVar("violenceLevel", 5)

	if (ActionBars) then
		SetActionBarToggles(1, 1, 1, 1)
	end

	InterfaceOptionsActionBarsPanelPickupActionKeyDropDown:SetValue("SHIFT")
	InterfaceOptionsActionBarsPanelPickupActionKeyDropDown:RefreshValue()

	-- Create our custom chatframes
	FCF_ResetChatWindows()
	FCF_SetLocked(ChatFrame1, 1)
	FCF_DockFrame(ChatFrame2)
	FCF_SetLocked(ChatFrame2, 1)
	FCF_OpenNewWindow(GENERAL)
	FCF_SetLocked(ChatFrame3, 1)
	FCF_DockFrame(ChatFrame3)
	FCF_OpenNewWindow(LOOT)
	FCF_SetLocked(ChatFrame4, 1)
	FCF_DockFrame(ChatFrame4)

	-- Setting chat frames
	if C.Chat.Enable == true and not IsAddOnLoaded("Prat-3.0") or IsAddOnLoaded("Chatter") then
		for i = 1, NUM_CHAT_WINDOWS do
			local Frame = _G["ChatFrame"..i]
			local ID = Frame:GetID()

			Frame:SetSize(C.Chat.Width, C.Chat.Height)

			-- Default width and height of chats
			SetChatWindowSavedDimensions(ID, K.Scale(C.Chat.Width), K.Scale(C.Chat.Height))

			-- Move general chat to bottom left
			if (ID == 1) then
				Frame:ClearAllPoints()
				Frame:SetPoint(unpack(C.Position.Chat))
			end

			-- Save new default position and dimension
			FCF_SavePositionAndDimensions(Frame)

			-- Set default font size
			FCF_SetChatWindowFontSize(nil, Frame, 12)

			if (ID == 1) then
				FCF_SetWindowName(Frame, "G, S & W")
			end

			if (ID == 2) then
				FCF_SetWindowName(Frame, "Log")
			end

			if (not Frame.isLocked) then
				FCF_SetLocked(Frame, 1)
			end
		end

		-- Set more chat groups
		ChatFrame_RemoveAllMessageGroups(ChatFrame1)
		ChatFrame_RemoveChannel(ChatFrame1, TRADE)
		ChatFrame_RemoveChannel(ChatFrame1, GENERAL)
		ChatFrame_RemoveChannel(ChatFrame1, L_CHAT_LOCALDEFENSE)
		ChatFrame_RemoveChannel(ChatFrame1, L_CHAT_GUILDRECRUITMENT)
		ChatFrame_RemoveChannel(ChatFrame1, L_CHAT_LOOKINGFORGROUP)
		ChatFrame_AddMessageGroup(ChatFrame1, "SAY")
		ChatFrame_AddMessageGroup(ChatFrame1, "EMOTE")
		ChatFrame_AddMessageGroup(ChatFrame1, "YELL")
		ChatFrame_AddMessageGroup(ChatFrame1, "GUILD")
		ChatFrame_AddMessageGroup(ChatFrame1, "OFFICER")
		ChatFrame_AddMessageGroup(ChatFrame1, "GUILD_ACHIEVEMENT")
		ChatFrame_AddMessageGroup(ChatFrame1, "WHISPER")
		ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_SAY")
		ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_EMOTE")
		ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_YELL")
		ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_WHISPER")
		ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_BOSS_EMOTE")
		ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_BOSS_WHISPER")
		ChatFrame_AddMessageGroup(ChatFrame1, "PARTY")
		ChatFrame_AddMessageGroup(ChatFrame1, "PARTY_LEADER")
		ChatFrame_AddMessageGroup(ChatFrame1, "RAID")
		ChatFrame_AddMessageGroup(ChatFrame1, "RAID_LEADER")
		ChatFrame_AddMessageGroup(ChatFrame1, "RAID_WARNING")
		ChatFrame_AddMessageGroup(ChatFrame1, "INSTANCE_CHAT")
		ChatFrame_AddMessageGroup(ChatFrame1, "INSTANCE_CHAT_LEADER")
		ChatFrame_AddMessageGroup(ChatFrame1, "BG_HORDE")
		ChatFrame_AddMessageGroup(ChatFrame1, "BG_ALLIANCE")
		ChatFrame_AddMessageGroup(ChatFrame1, "BG_NEUTRAL")
		ChatFrame_AddMessageGroup(ChatFrame1, "SYSTEM")
		ChatFrame_AddMessageGroup(ChatFrame1, "ERRORS")
		ChatFrame_AddMessageGroup(ChatFrame1, "AFK")
		ChatFrame_AddMessageGroup(ChatFrame1, "DND")
		ChatFrame_AddMessageGroup(ChatFrame1, "IGNORED")
		ChatFrame_AddMessageGroup(ChatFrame1, "ACHIEVEMENT")
		ChatFrame_AddMessageGroup(ChatFrame1, "BN_WHISPER")
		ChatFrame_AddMessageGroup(ChatFrame1, "BN_CONVERSATION")

		-- Setup the spam chat frame
		ChatFrame_RemoveAllMessageGroups(ChatFrame3)
		ChatFrame_AddChannel(ChatFrame3, TRADE)
		ChatFrame_AddChannel(ChatFrame3, GENERAL)
		ChatFrame_AddChannel(ChatFrame3, L_CHAT_LOCALDEFENSE)
		ChatFrame_AddChannel(ChatFrame3, L_CHAT_GUILDRECRUITMENT)
		ChatFrame_AddChannel(ChatFrame3, L_CHAT_LOOKINGFORGROUP)

		-- Setup the loot chat
		ChatFrame_RemoveAllMessageGroups(ChatFrame4)
		ChatFrame_AddMessageGroup(ChatFrame4, "COMBAT_XP_GAIN")
		ChatFrame_AddMessageGroup(ChatFrame4, "COMBAT_HONOR_GAIN")
		ChatFrame_AddMessageGroup(ChatFrame4, "COMBAT_FACTION_CHANGE")
		ChatFrame_AddMessageGroup(ChatFrame4, "LOOT")
		ChatFrame_AddMessageGroup(ChatFrame4, "MONEY")

		if (K.Name == "Pervie" or K.Name == "Aceer" or K.Name == "Kkthnxx" or K.Name == "Tatterdots") and (K.Realm == "Stormreaver") then
			SetCVar("scriptErrors", 1)
		end

		-- Enable class color automatically on login and each character without doing /configure each time.
		ToggleChatColorNamesByClassGroup(true, "SAY")
		ToggleChatColorNamesByClassGroup(true, "EMOTE")
		ToggleChatColorNamesByClassGroup(true, "YELL")
		ToggleChatColorNamesByClassGroup(true, "GUILD")
		ToggleChatColorNamesByClassGroup(true, "OFFICER")
		ToggleChatColorNamesByClassGroup(true, "GUILD_ACHIEVEMENT")
		ToggleChatColorNamesByClassGroup(true, "ACHIEVEMENT")
		ToggleChatColorNamesByClassGroup(true, "WHISPER")
		ToggleChatColorNamesByClassGroup(true, "PARTY")
		ToggleChatColorNamesByClassGroup(true, "PARTY_LEADER")
		ToggleChatColorNamesByClassGroup(true, "RAID")
		ToggleChatColorNamesByClassGroup(true, "RAID_LEADER")
		ToggleChatColorNamesByClassGroup(true, "RAID_WARNING")
		ToggleChatColorNamesByClassGroup(true, "BATTLEGROUND")
		ToggleChatColorNamesByClassGroup(true, "BATTLEGROUND_LEADER")
		ToggleChatColorNamesByClassGroup(true, "CHANNEL1")
		ToggleChatColorNamesByClassGroup(true, "CHANNEL2")
		ToggleChatColorNamesByClassGroup(true, "CHANNEL3")
		ToggleChatColorNamesByClassGroup(true, "CHANNEL4")
		ToggleChatColorNamesByClassGroup(true, "CHANNEL5")
		ToggleChatColorNamesByClassGroup(true, "INSTANCE_CHAT")
		ToggleChatColorNamesByClassGroup(true, "INSTANCE_CHAT_LEADER")
	end

	-- Reset saved variables.
	KkthnxUIData = {}
	KkthnxUIPositions = {}
	KkthnxUIDataPerChar = {}

	KkthnxUIDataPerChar.Install = true
	KkthnxUIDataPerChar.FogOfWar = false
	KkthnxUIDataPerChar.AutoInvite = false
	KkthnxUIDataPerChar.BarsLocked = false
	KkthnxUIDataPerChar.SplitBars = true
	KkthnxUIDataPerChar.RightBars = C.ActionBar.RightBars
	KkthnxUIDataPerChar.BottomBars = C.ActionBar.BottomBars

	InstallStepComplete.message = L_INSTALL_COMPLETE
	InstallStepComplete:Show()

	StaticPopup_Show("RELOAD_UI")
end

local function DisableUI()
	DisableAddOn("KkthnxUI")
	ReloadUI()
end

-- Install popups
StaticPopupDialogs["INSTALL_UI"] = {
	text = L_POPUP_INSTALLUI,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = InstallUI,
	OnCancel = function() KkthnxUIDataPerChar.Install = false end,
	timeout = 0,
	showAlert = 1,
	whileDead = 1,
	hideOnEscape = false,
	preferredIndex = 3
}

StaticPopupDialogs["RELOAD_UI"] = {
	text = L_POPUP_RELOADUI,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function() ReloadUI() end,
	OnCancel = function() KkthnxUIDataPerChar.Install = false end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = false,
	preferredIndex = 3
}

StaticPopupDialogs["DISABLE_UI"] = {
	text = L_POPUP_DISABLEUI,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = DisableUI,
	showAlert = true,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = true,
	preferredIndex = 3
}

StaticPopupDialogs["RESET_UI"] = {
	text = L_POPUP_RESETUI,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = InstallUI,
	OnCancel = function() KKkthnxUIDataPerChar.Install = true end,
	showAlert = true,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = true,
	preferredIndex = 3
}

SLASH_INSTALLUI1 = "/installui"
SlashCmdList.INSTALLUI = function() StaticPopup_Show("INSTALL_UI") end

SLASH_CONFIGURE1 = "/resetui"
SlashCmdList.CONFIGURE = function() StaticPopup_Show("RESET_UI") end

SLASH_CONFIGURE1 = "/resetchat"
SlashCmdList.CONFIGURE = function() StaticPopup_Show("RESET_UI") end

-- On login function
local Install = CreateFrame("Frame")
Install:RegisterEvent("ADDON_LOADED")
Install:SetScript("OnEvent", function(self, event, addon)
	if (addon ~= "KkthnxUI") then
		return
	end

	-- Create empty CVar if they doesn't exist
	if KkthnxUIData == nil then KkthnxUIData = {} end
	if KkthnxUIPositions == nil then KkthnxUIPositions = {} end
	if KkthnxUIDataPerChar == nil then KkthnxUIDataPerChar = {} end
	if KkthnxUIDataPerChar.Move then KkthnxUIDataPerChar.Move = {} end

	if KkthnxUIDataPerChar.FogOfWar == nil then KkthnxUIDataPerChar.FogOfWar = false end
	if KkthnxUIDataPerChar.AutoInvite == nil then KkthnxUIDataPerChar.AutoInvite = false end
	if KkthnxUIDataPerChar.BarsLocked == nil then KkthnxUIDataPerChar.BarsLocked = false end
	if KkthnxUIDataPerChar.SplitBars == nil then KkthnxUIDataPerChar.SplitBars = true end
	if KkthnxUIDataPerChar.RightBars == nil then KkthnxUIDataPerChar.RightBars = C.ActionBar.RightBars end
	if KkthnxUIDataPerChar.BottomBars == nil then KkthnxUIDataPerChar.BottomBars = C.ActionBar.BottomBars end

	if K.ScreenWidth < 1024 then
		SetCVar("useUiScale", 0)
		StaticPopup_Show("DISABLE_UI")
	else

		-- Install default if we never ran kkthnxui on this character
		if not KkthnxUIDataPerChar.Install then
			StaticPopup_Show("INSTALL_UI")
		end
	end

	-- Welcome message
	if C.General.WelcomeMessage == true then
		print("|cffffff00"..L_WELCOME_LINE_1..K.Version.." "..K.Client..", "..format("|cff%02x%02x%02x%s|r", K.Color.r * 255, K.Color.g * 255, K.Color.b * 255, K.Name)..".|r")
		print("|cffffff00"..L_WELCOME_LINE_2_1.."|cffffff00"..L_WELCOME_LINE_2_2.."|r")
		print("|cffffff00"..L_WELCOME_LINE_2_3.."|cffffff00"..L_WELCOME_LINE_2_4.."|r")
	end

	self:UnregisterEvent("ADDON_LOADED")
end)

if not InstallStepComplete then
	local imsg = CreateFrame("Frame", "InstallStepComplete", K.UIParent)
	imsg:SetSize(418, 72)
	imsg:SetPoint("TOP", 0, -120)
	imsg:Hide()
	imsg:SetScript("OnShow", function(self)
		if self.message then
			PlaySoundFile([[Sound\Interface\LevelUp.wav]])
			self.text:SetText(self.message)
			UIFrameFadeOut(self, 3.5, 1, 0)
			K.Delay(4, function() self:Hide() end)
			self.message = nil
		else
			self:Hide()
		end
	end)

	imsg.firstShow = false

	imsg.bg = imsg:CreateTexture(nil, "BACKGROUND")
	imsg.bg:SetTexture([[Interface\LevelUp\LevelUpTex]])
	imsg.bg:SetPoint("BOTTOM")
	imsg.bg:SetSize(326, 103)
	imsg.bg:SetTexCoord(0.00195313, 0.63867188, 0.03710938, 0.23828125)
	imsg.bg:SetVertexColor(1, 1, 1, 0.6)

	imsg.lineTop = imsg:CreateTexture(nil, "BACKGROUND")
	imsg.lineTop:SetDrawLayer("BACKGROUND", 2)
	imsg.lineTop:SetTexture([[Interface\LevelUp\LevelUpTex]])
	imsg.lineTop:SetPoint("TOP")
	imsg.lineTop:SetSize(418, 7)
	imsg.lineTop:SetTexCoord(0.00195313, 0.81835938, 0.01953125, 0.03320313)

	imsg.lineBottom = imsg:CreateTexture(nil, "BACKGROUND")
	imsg.lineBottom:SetDrawLayer("BACKGROUND", 2)
	imsg.lineBottom:SetTexture([[Interface\LevelUp\LevelUpTex]])
	imsg.lineBottom:SetPoint("BOTTOM")
	imsg.lineBottom:SetSize(418, 7)
	imsg.lineBottom:SetTexCoord(0.00195313, 0.81835938, 0.01953125, 0.03320313)

	imsg.text = imsg:CreateFontString(nil, "ARTWORK", "GameFont_Gigantic")
	imsg.text:SetPoint("BOTTOM", 0, 12)
	imsg.text:SetTextColor(1, 0.82, 0)
	imsg.text:SetJustifyH("CENTER")
end

-- Help translate
if C.General.TranslateMessage == true then
	if GetLocale() == "esES" or GetLocale() == "koKR" or GetLocale() == "esMX" or GetLocale() == "frFR" or GetLocale() == "koKR" or GetLocale() == "zhCN" or GetLocale() == "zhTW" then
		print("|cffffff00Please help us translate the text settings for |cff3c9bedKkthnxUI|r. |cffffff00You can post a commit to|r |cff3c9bedgithub.com/Kkthnx/KkthnxUI_Legion|r")
	end
end