local K, C, L = unpack(select(2, ...))

-- Lua API
local _G = _G
local format = format
local match = string.match
local min, max = math.min, math.max
local print = print
local unpack, select = unpack, select

-- Wow API
local ChangeChatColor = ChangeChatColor
local ChatFrame_AddChannel = ChatFrame_AddChannel
local ChatFrame_AddMessageGroup = ChatFrame_AddMessageGroup
local ChatFrame_RemoveAllMessageGroups = ChatFrame_RemoveAllMessageGroups
local ChatFrame_RemoveChannel = ChatFrame_RemoveChannel
local CreateFrame = CreateFrame
local FCF_DockFrame, FCF_UnDockFrame = FCF_DockFrame, FCF_UnDockFrame
local FCF_GetChatWindowInfo = FCF_GetChatWindowInfo
local FCF_OpenNewWindow = FCF_OpenNewWindow
local FCF_ResetChatWindows = FCF_ResetChatWindows
local FCF_SavePositionAndDimensions = FCF_SavePositionAndDimensions
local FCF_SetChatWindowFontSize = FCF_SetChatWindowFontSize
local FCF_SetLocked = FCF_SetLocked
local FCF_SetWindowName = FCF_SetWindowName
local FCF_StopDragging = FCF_StopDragging
local GetCVarBool = GetCVarBool
local LOOT, GENERAL, TRADE = LOOT, GENERAL, TRADE
local NUM_CHAT_WINDOWS = NUM_CHAT_WINDOWS
local PlayMusic = PlayMusic
local PlaySoundFile = PlaySoundFile
local ReloadUI = ReloadUI
local SetCVar = SetCVar
local ToggleChatColorNamesByClassGroup = ToggleChatColorNamesByClassGroup
local StaticPopup_Show = StaticPopup_Show
local GetCVar = GetCVar

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: ActionBars, SetActionBarToggles, SLASH_VERSION1, DisableAddOn, KkthnxUIData
-- GLOBALS: ChatFrame4, DEFAULT_CHAT_FRAME, KkthnxUIDataPerChar, InstallationMessageFrame
-- GLOBALS: SLASH_CONFIGURE1, SLASH_RESETUI1, ChatFrame1, ChatFrame2, ChatFrame3, UIParent
-- GLOBALS: SLASH_TUTORIAL2, SLASH_TUTORIAL1, SLASH_TUTORIAL1, SLASH_CONFIGURE2, UIConfig

local KkthnxUIInstall = CreateFrame("Frame", nil, UIParent)

function KkthnxUIInstall:ChatSetup()
	-- Setting chat frames if using KkthnxUI.
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
	ChatFrame_RemoveChannel(ChatFrame1, L.Chat.LocalDefense)
	ChatFrame_RemoveChannel(ChatFrame1, L.Chat.GuildRecruitment)
	ChatFrame_RemoveChannel(ChatFrame1, L.Chat.LookingForGroup)
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
	ChatFrame_AddChannel(ChatFrame3, L.Chat.LocalDefense)
	ChatFrame_AddChannel(ChatFrame3, L.Chat.GuildRecruitment)
	ChatFrame_AddChannel(ChatFrame3, L.Chat.LookingForGroup)

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

	-- Adjust Chat Colors (Thanks ElvUI)
	-- General
	ChangeChatColor("CHANNEL1", 195/255, 230/255, 232/255)
	-- Trade
	ChangeChatColor("CHANNEL2", 232/255, 158/255, 121/255)
	-- Local Defense
	ChangeChatColor("CHANNEL3", 232/255, 228/255, 121/255)

	DEFAULT_CHAT_FRAME:SetUserPlaced(true)

	for index = 1, NUM_CHAT_WINDOWS do
		local ChatFrame = _G[format("ChatFrame%s", index)]
		local ChatFrameID = ChatFrame:GetID()
		local _, FontSize = FCF_GetChatWindowInfo(ChatFrameID)

		FCF_SetChatWindowFontSize(nil, ChatFrame, FontSize)

		ChatFrame:SetSize(C.Chat.Width, C.Chat.Height)

		-- Position. Just to be safe here.
		if C.Chat.Background == true then
			if (index == 1) then
				ChatFrame:ClearAllPoints()
				ChatFrame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 6, 6)

				FCF_SavePositionAndDimensions(ChatFrame)
			end
		elseif C.Chat.Background == false then
			if (index == 1) then
				ChatFrame:ClearAllPoints()
				ChatFrame:SetPoint(unpack(C.Position.Chat))

				FCF_SavePositionAndDimensions(ChatFrame)
			end
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
	SetCVar("alwaysShowActionBars", 1)
	SetCVar("autoLootDefault", 0)
	SetCVar("autoOpenLootHistory", 0)
	SetCVar("autoQuestProgress", 1)
	SetCVar("autoQuestWatch", 1)
	SetCVar("buffDurations", 1)
	SetCVar("cameraDistanceMaxZoomFactor", 2.6)
	SetCVar("chatMouseScroll", 1)
	SetCVar("chatStyle", "im")
	SetCVar("colorblindMode", 0)
	SetCVar("countdownForCooldowns", 0)
	SetCVar("gameTip", 0)
	SetCVar("lootUnderMouse", 0)
	SetCVar("NamePlateHorizontalScale", 1)
	SetCVar("nameplateShowSelf", 0)
	SetCVar("NamePlateVerticalScale", 1)
	SetCVar("removeChatDelay", 1)
	SetCVar("RotateMinimap", 0)
	SetCVar("screenshotQuality", 8)
	SetCVar("showArenaEnemyFrames", 0)
	SetCVar("ShowClassColorInNameplate", 1)
	SetCVar("showTutorials", 0)
	SetCVar("showVKeyCastbar", 1)
	SetCVar("spamFilter", 0)
	SetCVar("taintLog", 0)
	SetCVar("UberTooltips", 1)
	SetCVar("violenceLevel", 5)
	SetCVar("WhisperMode", "inline")
	SetCVar("WholeChatWindowClickable", 0)
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
	if K.DataTexts then K.DataTexts:Reset() end

	-- Reset movable stuff into original positions
	if KkthnxUIDataPerChar.Movers then KkthnxUIDataPerChar.Movers = {} end
end

local KkthnxUIVersionFrame = CreateFrame("Button", "KkthnxUIVersionFrame", UIParent)
KkthnxUIVersionFrame:SetSize(300, 36)
KkthnxUIVersionFrame:SetPoint("CENTER")
KkthnxUIVersionFrame:SetTemplate("Default")
KkthnxUIVersionFrame:SetBackdropBorderColor(K.Color.r, K.Color.g, K.Color.b)
KkthnxUIVersionFrame:FontString("Text", C.Media.Font, 13, C.Media.Font_Style)
KkthnxUIVersionFrame.Text:SetPoint("CENTER")
KkthnxUIVersionFrame.Text:SetText("|cff3c9bed" ..K.UIName.." v".. K.Version .." |cffffffff Coded by: Kkthnx|r")
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
StatusBar:SetWidth(KkthnxUIInstallFrame:GetWidth() -44)
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
Header:SetFont(C.Media.Font, 16, "OUTLINE")
Header:SetPoint("TOP", KkthnxUIInstallFrame, "TOP", 0, -20)

local TextOne = KkthnxUIInstallFrame:CreateFontString(nil, "OVERLAY")
TextOne:SetJustifyH("LEFT")
TextOne:SetFont(C.Media.Font, 12, C.Media.Font_Style)
TextOne:SetWidth(KkthnxUIInstallFrame:GetWidth() -40)
TextOne:SetPoint("TOPLEFT", KkthnxUIInstallFrame, "TOPLEFT", 20, -60)

local TextTwo = KkthnxUIInstallFrame:CreateFontString(nil, "OVERLAY")
TextTwo:SetJustifyH("LEFT")
TextTwo:SetFont(C.Media.Font, 12, C.Media.Font_Style)
TextTwo:SetWidth(KkthnxUIInstallFrame:GetWidth() -40)
TextTwo:SetPoint("TOPLEFT", TextOne, "BOTTOMLEFT", 0, -20)

local TextThree = KkthnxUIInstallFrame:CreateFontString(nil, "OVERLAY")
TextThree:SetJustifyH("LEFT")
TextThree:SetFont(C.Media.Font, 12, C.Media.Font_Style)
TextThree:SetWidth(KkthnxUIInstallFrame:GetWidth() -40)
TextThree:SetPoint("TOPLEFT", TextTwo, "BOTTOMLEFT", 0, -20)

local TextFour = KkthnxUIInstallFrame:CreateFontString(nil, "OVERLAY")
TextFour:SetJustifyH("LEFT")
TextFour:SetFont(C.Media.Font, 12, C.Media.Font_Style)
TextFour:SetWidth(KkthnxUIInstallFrame:GetWidth() -40)
TextFour:SetPoint("TOPLEFT", TextThree, "BOTTOMLEFT", 0, -20)

local StatusBarText = StatusBar:CreateFontString(nil, "OVERLAY")
StatusBarText:SetFont(C.Media.Font, 13, "OUTLINE")
StatusBarText:SetPoint("CENTER", StatusBar)

local OptionOne = CreateFrame("Button", "KkthnxUIInstallOption1", KkthnxUIInstallFrame)
OptionOne:SetPoint("BOTTOMLEFT", KkthnxUIInstallFrame, "BOTTOMLEFT", 22, 28)
OptionOne:SetSize(128, 20)
OptionOne:SkinButton()
OptionOne:FontString("Text", C.Media.Font, 12, C.Media.Font_Style)
OptionOne.Text:SetPoint("CENTER")

local OptionTwo = CreateFrame("Button", "KkthnxUIInstallOption2", KkthnxUIInstallFrame)
OptionTwo:SetPoint("BOTTOMRIGHT", KkthnxUIInstallFrame, "BOTTOMRIGHT", -22, 28)
OptionTwo:SetSize(128, 20)
OptionTwo:SkinButton()
OptionTwo:FontString("Text", C.Media.Font, 12, C.Media.Font_Style)
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
	Header:SetText(L.Install.Header11)
	TextOne:SetText(L.Install.Step4Line1)
	TextTwo:SetText(L.Install.Step4Line2)
	TextThree:SetText(L.Install.Step4Line3)
	TextFour:SetText(L.Install.Step4Line4)
	StatusBarText:SetText("4/4")
	OptionOne:Hide()
	OptionTwo.Text:SetText(L.Install.ButtonFinish)
	OptionTwo:SetScript("OnClick", function()
		ReloadUI()
	end)
end

local StepThree = function()
	if not OptionTwo:IsShown() then OptionTwo:Show() end

	InstallationMessageFrame.Message = "Installation ChatFrames"
	InstallationMessageFrame:Show()

	StatusBar:SetValue(3)
	Header:SetText(L.Install.Header10)
	TextOne:SetText(L.Install.Step3Line1)
	TextTwo:SetText(L.Install.Step3Line2)
	TextThree:SetText(L.Install.Step3Line3)
	TextFour:SetText(L.Install.Step3Line4)
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
	Header:SetText(L.Install.Header9)
	StatusBarText:SetText("2/4")
	if K.CheckAddOn("Prat") or K.CheckAddOn("Chatter") then
		TextOne:SetText(L.Install.Step2Line0)
		TextTwo:SetText("")
		TextThree:SetText("")
		TextFour:SetText("")
		OptionTwo:Hide()
	else
		TextOne:SetText(L.Install.Step2Line1)
		TextTwo:SetText(L.Install.Step2Line2)
		TextThree:SetText(L.Install.Step2Line3)
		TextFour:SetText(L.Install.Step2Line4)
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
	Header:SetText(L.Install.Header8)
	TextOne:SetText(L.Install.Step1Line1)
	TextTwo:SetText(L.Install.Step1Line2)
	TextThree:SetText(L.Install.Step1Line3)
	TextFour:SetText(L.Install.Step1Line4)
	StatusBarText:SetText("1/4")

	OptionOne:Show()

	OptionOne.Text:SetText(L.Install.ButtonSkip)
	OptionTwo.Text:SetText(L.Install.ButtonContinue)

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
	Header:SetText(L.Install.Header7)
	TextOne:SetText(L.Tutorial.Step6Line1)
	TextTwo:SetText(L.Tutorial.Step6Line2)
	TextThree:SetText(L.Tutorial.Step6Line3)
	TextFour:SetText(L.Tutorial.Step6Line4)

	StatusBarText:SetText("6/6")

	OptionOne:Show()

	OptionOne.Text:SetText(L.Install.ButtonClose)
	OptionTwo.Text:SetText(L.Install.ButtonInstall)

	OptionOne:SetScript("OnClick", function()
		KkthnxUIInstallFrame:Hide()
	end)
	OptionTwo:SetScript("OnClick", StepOne)
end

local TutorialFive = function()
	StatusBar:SetValue(5)
	Header:SetText(L.Install.Header6)
	TextOne:SetText(L.Tutorial.Step5Line1)
	TextTwo:SetText(L.Tutorial.Step5Line2)
	TextThree:SetText(L.Tutorial.Step5Line3)
	TextFour:SetText(L.Tutorial.Step5Line4)

	StatusBarText:SetText("5/6")

	OptionTwo:SetScript("OnClick", TutorialSix)
end

local TutorialFour = function()
	StatusBar:SetValue(4)
	Header:SetText(L.Install.Header5)
	TextOne:SetText(L.Tutorial.Step4Line1)
	TextTwo:SetText(L.Tutorial.Step4Line2)
	TextThree:SetText(L.Tutorial.Step4Line3)
	TextFour:SetText(L.Tutorial.Step4Line4)

	StatusBarText:SetText("4/6")

	OptionTwo:SetScript("OnClick", TutorialFive)
end

local TutorialThree = function()
	StatusBar:SetValue(3)
	Header:SetText(L.Install.Header4)
	TextOne:SetText(L.Tutorial.Step3Line1)
	TextTwo:SetText(L.Tutorial.Step3Line2)
	TextThree:SetText(L.Tutorial.Step3Line3)
	TextFour:SetText(L.Tutorial.Step3Line4)

	StatusBarText:SetText("3/6")

	OptionTwo:SetScript("OnClick", TutorialFour)
end

local TutorialTwo = function()
	StatusBar:SetValue(2)
	Header:SetText(L.Install.Header3)
	TextOne:SetText(L.Tutorial.Step2Line1)
	TextTwo:SetText(L.Tutorial.Step2Line2)
	TextThree:SetText(L.Tutorial.Step2Line3)
	TextFour:SetText(L.Tutorial.Step2Line4)

	StatusBarText:SetText("2/6")

	OptionTwo:SetScript("OnClick", TutorialThree)
end

local TutorialOne = function()
	StatusBar:SetMinMaxValues(0, 6)
	StatusBar:Show()
	Close:Show()
	StatusBar:SetValue(1)
	StatusBar:SetStatusBarColor(K.Color.r, K.Color.g, K.Color.b)
	Header:SetText(L.Install.Header2)
	TextOne:SetText(L.Tutorial.Step1Line1)
	TextTwo:SetText(L.Tutorial.Step1Line2)
	TextThree:SetText(L.Tutorial.Step1Line3)
	TextFour:SetText(L.Tutorial.Step1Line4)
	StatusBarText:SetText("1/6")
	OptionOne:Hide()
	OptionTwo.Text:SetText(L.Install.ButtonNext)
	OptionTwo:SetScript("OnClick", TutorialTwo)
end

-- Install KkthnxUI with default settings.
function KkthnxUIInstall:Install()
	KkthnxUIInstallFrame:Show()
	StatusBar:Hide()
	OptionOne:Show()
	OptionTwo:Show()
	Close:Show()
	Header:SetText(L.Install.Header1)
	TextOne:SetText(L.Install.InitLine1)
	TextTwo:SetText(L.Install.InitLine2)
	TextThree:SetText(L.Install.InitLine3)
	TextFour:SetText(L.Install.InitLine4)

	OptionOne.Text:SetText(L.Install.ButtonTutorial)
	OptionTwo.Text:SetText(L.Install.ButtonInstall)

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
			K.FadeOut(self, 1, 0)

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
	if (addon ~= "KkthnxUI") then return end

	-- Create empty saved vars if they doesn't exist.
	if KkthnxUIData == nil then KkthnxUIData = {} end
	if KkthnxUIDataPerChar == nil then KkthnxUIDataPerChar = {} end
	if KkthnxUIDataPerChar.Movers == nil then KkthnxUIDataPerChar.Movers = {} end
	if KkthnxUIDataPerChar.FogOfWar == nil then KkthnxUIDataPerChar.FogOfWar = false end
	if KkthnxUIDataPerChar.AutoInvite == nil then KkthnxUIDataPerChar.AutoInvite = false end
	if KkthnxUIDataPerChar.BarsLocked == nil then KkthnxUIDataPerChar.BarsLocked = false end
	if KkthnxUIDataPerChar.SplitBars == nil then KkthnxUIDataPerChar.SplitBars = true end
	if KkthnxUIDataPerChar.RightBars == nil then KkthnxUIDataPerChar.RightBars = C.ActionBar.RightBars end
	if KkthnxUIDataPerChar.BottomBars == nil then KkthnxUIDataPerChar.BottomBars = C.ActionBar.BottomBars end

	-- Check if we should disable our UI due to too small of ScreenWidth
	if K.ScreenWidth < 1024 and GetCVarBool("gxMonitor") == "0" then
		local UseUIScale = GetCVarBool("useUiScale")
		if not UseUIScale then
			SetCVar("useUiScale", 0)
		end
		StaticPopup_Show("DISABLE_UI")
	end

	-- Install default if we never ran KkthnxUI on this character.
	if not KkthnxUIDataPerChar.Install then
		KkthnxUIInstall.Install()
	end

	-- Welcome message
	if C.General.WelcomeMessage == true then
		print("|cffffff00"..L.Welcome.Line1..K.Version.." "..K.Client..", "..format("|cff%02x%02x%02x%s|r", K.Color.r * 255, K.Color.g * 255, K.Color.b * 255, K.Name)..".|r")
		print("|cffffff00"..L.Welcome.Line2.."|cffffff00"..L.Welcome.Line3.."|r")
		print("|cffffff00"..L.Welcome.Line4.."|cffffff00"..L.Welcome.Line5.."|r")
	end

	if event == "ADDON_LOADED" then
		self:UnregisterEvent("ADDON_LOADED")
	end
end)

SLASH_TUTORIAL1, SLASH_TUTORIAL2 = "/uihelp", "/tutorial"
SlashCmdList.TUTORIAL = function() KkthnxUIInstallFrame:Show() TutorialOne() end

SLASH_VERSION1 = "/version"
SlashCmdList.VERSION = function() if KkthnxUIVersionFrame:IsShown() then KkthnxUIVersionFrame:Hide() else KkthnxUIVersionFrame:Show() end end

SLASH_CONFIGURE1, SLASH_CONFIGURE2 = "/install", "/installui"
SlashCmdList.CONFIGURE = KkthnxUIInstall.Install

SLASH_RESETUI1 = "/resetui"
SlashCmdList.RESETUI = function() KkthnxUIInstallFrame:Show() StepOne() end

StaticPopupDialogs["DISABLE_UI"] = {
	text = L.Popup.DisableUI,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function() DisableAddOn("KkthnxUI") ReloadUI() end,
	showAlert = true,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = true,
	preferredIndex = 3
}

StaticPopupDialogs["RESET_UI"] = {
	text = L.Popup.ResetUI,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function() KkthnxUIInstall.Install() if UIConfig and UIConfig:IsShown() then UIConfigMain:Hide() end end,
	OnCancel = function() KkthnxUIDataPerChar.Install = true end,
	showAlert = true,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = true,
	preferredIndex = 3
}

-- Help translate
if C.General.TranslateMessage == true then
	if GetLocale() == "zhCN" or GetLocale() == "zhTW" then
		print("|cffffff00Please help us translate the text settings for |cff3c9bedKkthnxUI|r. |cffffff00You can post a commit to|r |cff3c9bedgithub.com/Kkthnx/KkthnxUI_Legion|r")
	end
end