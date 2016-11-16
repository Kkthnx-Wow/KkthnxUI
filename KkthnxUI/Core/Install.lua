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

local KkthnxUIInstall = CreateFrame("Frame", nil, UIParent)

function KkthnxUIInstall:ChatSetup()
	-- Setting chat frames if using KkthnxUI chats.
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

	DEFAULT_CHAT_FRAME:SetUserPlaced(true)

	for index = 1, NUM_CHAT_WINDOWS do
		local ChatFrame = _G[format("ChatFrame%s", index)]
		local ChatFrameID = ChatFrame:GetID()
		local _, FontSize = FCF_GetChatWindowInfo(ChatFrameID)

		FCF_SetChatWindowFontSize(nil, ChatFrame, FontSize)

		ChatFrame:SetSize(C.Chat.Width, C.Chat.Height)

		if (index == 1) then
			ChatFrame:ClearAllPoints()
			ChatFrame:SetPoint(unpack(C.Position.Chat))

			FCF_SavePositionAndDimensions(ChatFrame)
		end

		FCF_SavePositionAndDimensions(ChatFrame)
		FCF_StopDragging(ChatFrame)

		if (index == 1) then
			FCF_SetWindowName(ChatFrame, "G, S, W")
		end

		if (index == 2) then
			FCF_SetWindowName(ChatFrame, "Log")
		end

		DEFAULT_CHAT_FRAME:SetUserPlaced(true)
	end
end

function KkthnxUIInstall:CVarSetup()
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
end

function KkthnxUIInstall:PositionSetup()
	-- Reset saved variables on char
	KkthnxUIDataPerChar = {}

	KkthnxUIDataPerChar.FogOfWar = false
	KkthnxUIDataPerChar.AutoInvite = false
	KkthnxUIDataPerChar.BarsLocked = false
	KkthnxUIDataPerChar.SplitBars = true
	KkthnxUIDataPerChar.RightBars = C.ActionBar.RightBars
	KkthnxUIDataPerChar.BottomBars = C.ActionBar.BottomBars

	-- Default our DataTexts
	if (K.DataTexts) then K.DataTexts:Reset() end

	-- Reset movable stuff into original positions
	if KkthnxUIDataPerChar.Movers then KkthnxUIDataPerChar.Movers = {} end
end

local KkthnxUIVersionFrame = CreateFrame("Button", "KkthnxUIVersionFrame", UIParent)
KkthnxUIVersionFrame:SetSize(300, 36)
KkthnxUIVersionFrame:SetPoint("CENTER")
KkthnxUIVersionFrame:SetTemplate("Default")
KkthnxUIVersionFrame:FontString("Text", C.Media.Font, 12)
KkthnxUIVersionFrame.Text:SetPoint("CENTER")
KkthnxUIVersionFrame.Text:SetText("KkthnxUI ".. K.Version .." by Kkthnx|r")
KkthnxUIVersionFrame:SetScript("OnClick", function()
	KkthnxUIVersionFrame:Hide()
end)
KkthnxUIVersionFrame:Hide()

local KkthnxUIInstallFrame = CreateFrame("Frame", "KkthnxUIInstallFrame", UIParent)
KkthnxUIInstallFrame:SetSize(400, 400)
KkthnxUIInstallFrame:SetPoint("CENTER")
KkthnxUIInstallFrame:SetTemplate("Default")
KkthnxUIInstallFrame:Hide()

local StatusBar = CreateFrame("StatusBar", nil, KkthnxUIInstallFrame)
StatusBar:SetStatusBarTexture(C.Media.Texture)
StatusBar:SetPoint("BOTTOM", KkthnxUIInstallFrame, "BOTTOM", 0, 60)
StatusBar:SetHeight(20)
StatusBar:SetWidth(KkthnxUIInstallFrame:GetWidth()-44)
StatusBar:SetFrameStrata("HIGH")
StatusBar:SetFrameLevel(6)
StatusBar:Hide()

local StatusBarBorder = CreateFrame("Frame", nil, StatusBar)
StatusBarBorder:SetTemplate("Default")
StatusBarBorder:SetPoint("TOPLEFT", StatusBar, -4, 4)
StatusBarBorder:SetPoint("BOTTOMRIGHT", StatusBar, 4, -4)
StatusBarBorder:SetFrameStrata("HIGH")
StatusBarBorder:SetFrameLevel(5)

local Header = KkthnxUIInstallFrame:CreateFontString(nil, "OVERLAY")
Header:SetFont(C.Media.Font, 16, "THINOUTLINE")
Header:SetPoint("TOP", KkthnxUIInstallFrame, "TOP", 0, -20)

local TextOne = KkthnxUIInstallFrame:CreateFontString(nil, "OVERLAY")
TextOne:SetJustifyH("LEFT")
TextOne:SetFont(C.Media.Font, 12)
TextOne:SetWidth(KkthnxUIInstallFrame:GetWidth()-40)
TextOne:SetPoint("TOPLEFT", KkthnxUIInstallFrame, "TOPLEFT", 20, -60)

local TextTwo = KkthnxUIInstallFrame:CreateFontString(nil, "OVERLAY")
TextTwo:SetJustifyH("LEFT")
TextTwo:SetFont(C.Media.Font, 12)
TextTwo:SetWidth(KkthnxUIInstallFrame:GetWidth()-40)
TextTwo:SetPoint("TOPLEFT", TextOne, "BOTTOMLEFT", 0, -20)

local TextThree = KkthnxUIInstallFrame:CreateFontString(nil, "OVERLAY")
TextThree:SetJustifyH("LEFT")
TextThree:SetFont(C.Media.Font, 12)
TextThree:SetWidth(KkthnxUIInstallFrame:GetWidth()-40)
TextThree:SetPoint("TOPLEFT", TextTwo, "BOTTOMLEFT", 0, -20)

local TextFour = KkthnxUIInstallFrame:CreateFontString(nil, "OVERLAY")
TextFour:SetJustifyH("LEFT")
TextFour:SetFont(C.Media.Font, 12)
TextFour:SetWidth(KkthnxUIInstallFrame:GetWidth()-40)
TextFour:SetPoint("TOPLEFT", TextThree, "BOTTOMLEFT", 0, -20)

local StatusBarText = StatusBar:CreateFontString(nil, "OVERLAY")
StatusBarText:SetFont(C.Media.Font, 13, "THINOUTLINE")
StatusBarText:SetPoint("CENTER", StatusBar)

local OptionOne = CreateFrame("Button", "KkthnxUIInstallOption1", KkthnxUIInstallFrame)
OptionOne:SetPoint("BOTTOMLEFT", KkthnxUIInstallFrame, "BOTTOMLEFT", 22, 28)
OptionOne:SetSize(128, 20)
OptionOne:SkinButton()
OptionOne:FontString("Text", C.Media.Font, 12)
OptionOne.Text:SetPoint("CENTER")

local OptionTwo = CreateFrame("Button", "KkthnxUIInstallOption2", KkthnxUIInstallFrame)
OptionTwo:SetPoint("BOTTOMRIGHT", KkthnxUIInstallFrame, "BOTTOMRIGHT", -22, 28)
OptionTwo:SetSize(128, 20)
OptionTwo:SkinButton()
OptionTwo:FontString("Text", C.Media.Font, 12)
OptionTwo.Text:SetPoint("CENTER")

local Close = CreateFrame("Button", "KkthnxUIInstallCloseButton", KkthnxUIInstallFrame, "UIPanelCloseButton")
Close:SetPoint("TOPRIGHT", KkthnxUIInstallFrame, "TOPRIGHT")
Close:SetScript("OnClick", function()
	KkthnxUIInstallFrame:Hide()
end)

local StepFour = function()
	InstallationMessageFrame.Message = "Installation Complete"
	InstallationMessageFrame:Show()

	KkthnxUIDataPerChar.Install = true
	StatusBar:SetValue(4)
	Header:SetText(L_INSTALL_HEADER_11)
	TextOne:SetText(L_INSTALL_STEP_4_LINE_1)
	TextTwo:SetText(L_INSTALL_STEP_4_LINE_2)
	TextThree:SetText(L_INSTALL_STEP_4_LINE_3)
	TextFour:SetText(L_INSTALL_STEP_4_LINE_4)
	StatusBarText:SetText("4/4")
	OptionOne:Hide()
	OptionTwo.Text:SetText(L_INSTALL_BUTTON_FINISH)
	OptionTwo:SetScript("OnClick", function()
		ReloadUI()
	end)
end

local StepThree = function()
	if not OptionTwo:IsShown() then OptionTwo:Show() end

	InstallationMessageFrame.Message = "Installation ChatFrames"
	InstallationMessageFrame:Show()

	StatusBar:SetValue(3)
	Header:SetText(L_INSTALL_HEADER_10)
	TextOne:SetText(L_INSTALL_STEP_3_LINE_1)
	TextTwo:SetText(L_INSTALL_STEP_3_LINE_2)
	TextThree:SetText(L_INSTALL_STEP_3_LINE_3)
	TextFour:SetText(L_INSTALL_STEP_3_LINE_4)
	StatusBarText:SetText("3/4")
	OptionOne:SetScript("OnClick", StepFour)
	OptionTwo:SetScript("OnClick", function()
		KkthnxUIInstall.PositionSetup()
		StepFour()
	end)
end

local StepTwo = function()
	InstallationMessageFrame.Message = "Installation CVARs"
	InstallationMessageFrame:Show()

	StatusBar:SetValue(2)
	Header:SetText(L_INSTALL_HEADER_9)
	StatusBarText:SetText("2/4")
	if IsAddOnLoaded("Prat") or IsAddOnLoaded("Chatter") then
		TextOne:SetText(L_INSTALL_STEP_2_LINE_0)
		TextTwo:SetText("")
		TextThree:SetText("")
		TextFour:SetText("")
		OptionTwo:Hide()
	else
		TextOne:SetText(L_INSTALL_STEP_2_LINE_1)
		TextTwo:SetText(L_INSTALL_STEP_2_LINE_2)
		TextThree:SetText(L_INSTALL_STEP_2_LINE_3)
		TextFour:SetText(L_INSTALL_STEP_2_LINE_4)
		OptionTwo:SetScript("OnClick", function()
			KkthnxUIInstall.ChatSetup()
			StepThree()
		end)
	end
	OptionOne:SetScript("OnClick", StepThree)
end

local StepOne = function()
	Close:Hide()
	StatusBar:SetMinMaxValues(0, 4)
	StatusBar:Show()
	StatusBar:SetValue(1)
	StatusBar:SetStatusBarColor(K.Color.r, K.Color.g, K.Color.b)
	Header:SetText(L_INSTALL_HEADER_8)
	TextOne:SetText(L_INSTALL_STEP_1_LINE_1)
	TextTwo:SetText(L_INSTALL_STEP_1_LINE_2)
	TextThree:SetText(L_INSTALL_STEP_1_LINE_3)
	TextFour:SetText(L_INSTALL_STEP_1_LINE_4)
	StatusBarText:SetText("1/4")

	OptionOne:Show()

	OptionOne.Text:SetText(L_INSTALL_BUTTON_SKIP)
	OptionTwo.Text:SetText(L_INSTALL_BUTTON_CONTINUE)

	OptionOne:SetScript("OnClick", StepTwo)
	OptionTwo:SetScript("OnClick", function()
		KkthnxUIInstall.CVarSetup()
		StepTwo()
	end)

	-- this is really essential, whatever if skipped or not
	if (ActionBars) then
		SetActionBarToggles(1, 1, 1, 1)
	end

	SetCVar("alwaysShowActionBars", 1)
end

local TutorialSix = function()
	StatusBar:SetValue(6)
	Header:SetText(L_INSTALL_HEADER_7)
	TextOne:SetText(L_TUTORIAL_STEP_6_LINE_1)
	TextTwo:SetText(L_TUTORIAL_STEP_6_LINE_2)
	TextThree:SetText(L_TUTORIAL_STEP_6_LINE_3)
	TextFour:SetText(L_TUTORIAL_STEP_6_LINE_4)

	StatusBarText:SetText("6/6")

	OptionOne:Show()

	OptionOne.Text:SetText(L_INSTALL_BUTTON_CLOSE)
	OptionTwo.Text:SetText(L_INSTALL_BUTTON_INSTALL)

	OptionOne:SetScript("OnClick", function()
		KkthnxUIInstallFrame:Hide()
	end)
	OptionTwo:SetScript("OnClick", StepOne)
end

local TutorialFive = function()
	StatusBar:SetValue(5)
	Header:SetText(L_INSTALL_HEADER_6)
	TextOne:SetText(L_TUTORIAL_STEP_5_LINE_1)
	TextTwo:SetText(L_TUTORIAL_STEP_5_LINE_2)
	TextThree:SetText(L_TUTORIAL_STEP_5_LINE_3)
	TextFour:SetText(L_TUTORIAL_STEP_5_LINE_4)

	StatusBarText:SetText("5/6")

	OptionTwo:SetScript("OnClick", TutorialSix)
end

local TutorialFour = function()
	StatusBar:SetValue(4)
	Header:SetText(L_INSTALL_HEADER_5)
	TextOne:SetText(L_TUTORIAL_STEP_4_LINE_1)
	TextTwo:SetText(L_TUTORIAL_STEP_4_LINE_2)
	TextThree:SetText(L_TUTORIAL_STEP_4_LINE_3)
	TextFour:SetText(L_TUTORIAL_STEP_4_LINE_4)

	StatusBarText:SetText("4/6")

	OptionTwo:SetScript("OnClick", TutorialFive)
end

local TutorialThree = function()
	StatusBar:SetValue(3)
	Header:SetText(L_INSTALL_HEADER_4)
	TextOne:SetText(L_TUTORIAL_STEP_3_LINE_1)
	TextTwo:SetText(L_TUTORIAL_STEP_3_LINE_2)
	TextThree:SetText(L_TUTORIAL_STEP_3_LINE_3)
	TextFour:SetText(L_TUTORIAL_STEP_3_LINE_4)

	StatusBarText:SetText("3/6")

	OptionTwo:SetScript("OnClick", TutorialFour)
end

local TutorialTwo = function()
	StatusBar:SetValue(2)
	Header:SetText(L_INSTALL_HEADER_3)
	TextOne:SetText(L_TUTORIAL_STEP_2_LINE_1)
	TextTwo:SetText(L_TUTORIAL_STEP_2_LINE_2)
	TextThree:SetText(L_TUTORIAL_STEP_2_LINE_3)
	TextFour:SetText(L_TUTORIAL_STEP_2_LINE_4)

	StatusBarText:SetText("2/6")

	OptionTwo:SetScript("OnClick", TutorialThree)
end

local TutorialOne = function()
	StatusBar:SetMinMaxValues(0, 6)
	StatusBar:Show()
	Close:Show()
	StatusBar:SetValue(1)
	StatusBar:SetStatusBarColor(K.Color.r, K.Color.g, K.Color.b)
	Header:SetText(L_INSTALL_HEADER_2)
	TextOne:SetText(L_TUTORIAL_STEP_1_LINE_1)
	TextTwo:SetText(L_TUTORIAL_STEP_1_LINE_2)
	TextThree:SetText(L_TUTORIAL_STEP_1_LINE_3)
	TextFour:SetText(L_TUTORIAL_STEP_1_LINE_4)
	StatusBarText:SetText("1/6")
	OptionOne:Hide()
	OptionTwo.Text:SetText(L_INSTALL_BUTTON_NEXT)
	OptionTwo:SetScript("OnClick", TutorialTwo)
end

-- this install KkthnxUI with default settings.
function KkthnxUIInstall:Install()
	KkthnxUIInstallFrame:Show()
	StatusBar:Hide()
	OptionOne:Show()
	OptionTwo:Show()
	Close:Show()
	Header:SetText(L_INSTALL_HEADER_1)
	TextOne:SetText(L_INSTALL_INIT_LINE_1)
	TextTwo:SetText(L_INSTALL_INIT_LINE_2)
	TextThree:SetText(L_INSTALL_INIT_LINE_3)
	TextFour:SetText(L_INSTALL_INIT_LINE_4)

	OptionOne.Text:SetText(L_INSTALL_BUTTON_TUTORIAL)
	OptionTwo.Text:SetText(L_INSTALL_BUTTON_INSTALL)

	OptionOne:SetScript("OnClick", TutorialOne)
	OptionTwo:SetScript("OnClick", StepOne)
end

if (not InstallationMessageFrame) then
	local InstallationMessageFrame = CreateFrame("Frame", "InstallationMessageFrame", UIParent)
	InstallationMessageFrame:SetPoint("TOP", 0, -100)
	InstallationMessageFrame:SetSize(418, 72)
	InstallationMessageFrame:Hide()

	InstallationMessageFrame:SetScript("OnShow", function(self)
		if (self.Message) then
			PlaySoundFile([[Sound\Interface\LevelUp.ogg]])
			self.Text:SetText(self.Message)
			UIFrameFadeOut(self, 1.5, 1, 0)

			K.Delay(2, function()
				self:Hide()
			end)

			self.Message = nil

			if (InstallationMessageFrame.FirstShow == false) then
				if (GetCVarBool("Sound_EnableMusic")) then
					PlayMusic([[Sound\Music\ZoneMusic\DMF_L70ETC01.mp3]])
				end

				InstallationMessageFrame.FirstShow = true
			end
		else
			self:Hide()
		end
	end)

	InstallationMessageFrame.FirstShow = false

	InstallationMessageFrame.Texture = InstallationMessageFrame:CreateTexture(nil, "BACKGROUND")
	InstallationMessageFrame.Texture:SetPoint("BOTTOM")
	InstallationMessageFrame.Texture:SetSize(326, 103)
	InstallationMessageFrame.Texture:SetTexture([[Interface\LevelUp\LevelUpTex]])
	InstallationMessageFrame.Texture:SetTexCoord(0.00195313, 0.63867188, 0.03710938, 0.23828125)
	InstallationMessageFrame.Texture:SetVertexColor(1, 1, 1, 0.6)

	InstallationMessageFrame.LineTop = InstallationMessageFrame:CreateTexture(nil, "BACKGROUND")
	InstallationMessageFrame.LineTop:SetPoint("TOP")
	InstallationMessageFrame.LineTop:SetSize(418, 7)
	InstallationMessageFrame.LineTop:SetDrawLayer("BACKGROUND", 2)
	InstallationMessageFrame.LineTop:SetTexture([[Interface\LevelUp\LevelUpTex]])
	InstallationMessageFrame.LineTop:SetTexCoord(0.00195313, 0.81835938, 0.01953125, 0.03320313)

	InstallationMessageFrame.LineBottom = InstallationMessageFrame:CreateTexture(nil, "BACKGROUND")
	InstallationMessageFrame.LineBottom:SetPoint("BOTTOM")
	InstallationMessageFrame.LineBottom:SetSize(418, 7)
	InstallationMessageFrame.LineBottom:SetDrawLayer("BACKGROUND", 2)
	InstallationMessageFrame.LineBottom:SetTexture([[Interface\LevelUp\LevelUpTex]])
	InstallationMessageFrame.LineBottom:SetTexCoord(0.00195313, 0.81835938, 0.01953125, 0.03320313)

	InstallationMessageFrame.Text = InstallationMessageFrame:CreateFontString(nil, "ARTWORK", "GameFont_Gigantic")
	InstallationMessageFrame.Text:SetPoint("BOTTOM", 0, 12)
	InstallationMessageFrame.Text:SetTextColor(1, 0.82, 0)
	InstallationMessageFrame.Text:SetJustifyH("CENTER")
end

-- On login function
local Install = CreateFrame("Frame")
Install:RegisterEvent("ADDON_LOADED")
Install:SetScript("OnEvent", function(self, event, addon)
	if (addon ~= "KkthnxUI") then
		return
	end

	-- create empty saved vars if they doesn"t exist.
	if KkthnxUIData == nil then KkthnxUIData = {} end
	if KkthnxUIDataPerChar == nil then KkthnxUIDataPerChar = {} end

	if K.ScreenWidth < 1024 then
		SetCVar("useUiScale", 0)
		StaticPopup_Show("DISABLE_UI")
	else
		-- install default if we never ran KkthnxUI on this character.
		if not KkthnxUIDataPerChar.Install then
			KkthnxUIInstall.Install()
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

SLASH_TUTORIAL1 = "/uihelp"
SLASH_TUTORIAL2 = "/tutorial"
SlashCmdList.TUTORIAL = function() KkthnxUIInstallFrame:Show() TutorialOne() end

SLASH_VERSION1 = "/version"
SlashCmdList.VERSION = function() if KkthnxUIVersionFrame:IsShown() then KkthnxUIVersionFrame:Hide() else KkthnxUIVersionFrame:Show() end end

SLASH_CONFIGURE1 = "/install"
SlashCmdList.CONFIGURE = KkthnxUIInstall.Install

SLASH_RESETUI1 = "/resetui"
SlashCmdList.RESETUI = function() KkthnxUIInstallFrame:Show() StepOne() end

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
	OnAccept = KkthnxUIInstall.Install,
	OnCancel = function() KkthnxUIDataPerChar.Install = true end,
	showAlert = true,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = true,
	preferredIndex = 3
}

-- Help translate
if C.General.TranslateMessage == true then
	if GetLocale() == "esES" or GetLocale() == "koKR" or GetLocale() == "esMX" or GetLocale() == "frFR" or GetLocale() == "koKR" or GetLocale() == "zhCN" or GetLocale() == "zhTW" then
		print("|cffffff00Please help us translate the text settings for |cff3c9bedKkthnxUI|r. |cffffff00You can post a commit to|r |cff3c9bedgithub.com/Kkthnx/KkthnxUI_Legion|r")
	end
end
