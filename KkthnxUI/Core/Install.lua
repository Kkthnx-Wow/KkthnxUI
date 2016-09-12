local K, C, L, _ = select(2, ...):unpack()

-- LUA API
local _G = _G
local format = format
local min, max = math.min, math.max
local match = string.match
local unpack, select = unpack, select
local print = print

-- WOW API
local CreateFrame = CreateFrame
local IsAddOnLoaded = IsAddOnLoaded
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
	SetCVar("countdownForCooldowns", 1)
	SetCVar("buffDurations", 1)
	SetCVar("scriptErrors", 1)
	SetCVar("ShowClassColorInNameplate", 1)
	SetCVar("screenshotQuality", 8)
	SetCVar("chatMouseScroll", 1)
	SetCVar("chatStyle", "im")
	SetCVar("WholeChatWindowClickable", 0)
	SetCVar("WhisperMode", "inline")
	SetCVar("showTutorials", 0)
	SetCVar("autoQuestWatch", 1)
	SetCVar("autoQuestProgress", 1)
	SetCVar("UberTooltips", 1)
	SetCVar("removeChatDelay", 1)
	SetCVar("showVKeyCastbar", 1)
	SetCVar("showArenaEnemyFrames", 0)
	SetCVar("alwaysShowActionBars", 1)
	SetCVar("autoOpenLootHistory", 0)
	SetCVar("spamFilter", 0)
	SetCVar("violenceLevel", 5)
	SetCVar("ShowClassColorInNameplate", 1)
	SetCVar("nameplateShowSelf", 0)
	SetCVar("NamePlateVerticalScale", 1)
	SetCVar("NamePlateHorizontalScale", 1)

	if (ActionBars) then
		SetActionBarToggles(1, 1, 1, 1)
	end

	InterfaceOptionsActionBarsPanelPickupActionKeyDropDown:SetValue("SHIFT")
	InterfaceOptionsActionBarsPanelPickupActionKeyDropDown:RefreshValue()

	-- CREATE OUR CUSTOM CHATFRAMES
	FCF_ResetChatWindows()
	FCF_SetLocked(ChatFrame1, 1)
	FCF_DockFrame(ChatFrame2)
	FCF_SetLocked(ChatFrame2, 1)
	FCF_OpenNewWindow(GENERAL)
	FCF_SetLocked(ChatFrame3, 1)
	FCF_DockFrame(ChatFrame3)

	if C.Chat.LootFrame then
		FCF_OpenNewWindow(LOOT)
		FCF_DockFrame(ChatFrame4)
		ChatFrame4:Show()
	end

	-- SETTING CHAT FRAMES
	if C.Chat.Enable == true and not (select(4, GetAddOnInfo("Prat-3.0"))) or (select(4, GetAddOnInfo("Chatter"))) then
		for i = 1, NUM_CHAT_WINDOWS do
			local Frame = _G["ChatFrame"..i]
			local ID = Frame:GetID()

			Frame:SetSize(C.Chat.Width, C.Chat.Height)

			-- DEFAULT WIDTH AND HEIGHT OF CHATS
			SetChatWindowSavedDimensions(ID, K.Scale(C.Chat.Width), K.Scale(C.Chat.Height))

			-- MOVE GENERAL CHAT TO BOTTOM LEFT
			if (ID == 1) then
				Frame:ClearAllPoints()
				Frame:SetPoint(unpack(C.Position.Chat))
			end

			-- SAVE NEW DEFAULT POSITION AND DIMENSION
			FCF_SavePositionAndDimensions(Frame)

			-- SET DEFAULT FONT SIZE
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

		-- SET MORE CHAT GROUPS
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

		-- SETUP THE SPAM CHAT FRAME
		ChatFrame_RemoveAllMessageGroups(ChatFrame3)
		ChatFrame_AddChannel(ChatFrame3, TRADE)
		ChatFrame_AddChannel(ChatFrame3, GENERAL)
		ChatFrame_AddChannel(ChatFrame3, L_CHAT_LOCALDEFENSE)
		ChatFrame_AddChannel(ChatFrame3, L_CHAT_GUILDRECRUITMENT)
		ChatFrame_AddChannel(ChatFrame3, L_CHAT_LOOKINGFORGROUP)

		-- SETUP THE LOOT CHAT
		if C.Chat.LootFrame then
			ChatFrame_RemoveAllMessageGroups(ChatFrame4)
			ChatFrame_AddMessageGroup(ChatFrame4, "COMBAT_XP_GAIN")
			ChatFrame_AddMessageGroup(ChatFrame4, "COMBAT_HONOR_GAIN")
			ChatFrame_AddMessageGroup(ChatFrame4, "COMBAT_FACTION_CHANGE")
			ChatFrame_AddMessageGroup(ChatFrame4, "LOOT")
			ChatFrame_AddMessageGroup(ChatFrame4, "MONEY")
		end

		if (K.Name == "Pervie" or K.Name == "Aceer" or K.Name == "Kkthnxx" or K.Name == "Tatterdots") and (K.Realm == "Stormreaver") then
			SetCVar("scriptErrors", 1)
		end

		-- ENABLE CLASS COLOR AUTOMATICALLY ON LOGIN AND EACH CHARACTER WITHOUT DOING /CONFIGURE EACH TIME.
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

	-- RESET SAVED VARIABLES ON CHAR
	SavedPositions = {}
	SavedOptionsPerChar = {}

	SavedOptionsPerChar.Install = true
	SavedOptionsPerChar.AutoInvite = false
	SavedOptionsPerChar.BarsLocked = false
	SavedOptionsPerChar.SplitBars = true
	SavedOptionsPerChar.RightBars = C.ActionBar.RightBars
	SavedOptionsPerChar.BottomBars = C.ActionBar.BottomBars

	StaticPopup_Show("RELOAD_UI")
end

local function DisableUI()
	DisableAddOn("KkthnxUI")
	ReloadUI()
end

-- Install Popups
StaticPopupDialogs["INSTALL_UI"] = {
	text = L_POPUP_INSTALLUI,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = InstallUI,
	OnCancel = function() SavedOptionsPerChar.Install = false end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = false,
	preferredIndex = 3
}

StaticPopupDialogs["RELOAD_UI"] = {
	text = L_POPUP_RELOADUI,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function() ReloadUI() end,
	OnCancel = function() SavedOptionsPerChar.Install = false end,
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
	OnCancel = function() SavedOptionsPerChar.Install = true end,
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

-- ON LOGIN FUNCTION
local Install = CreateFrame("Frame")
Install:RegisterEvent("ADDON_LOADED")
Install:SetScript("OnEvent", function(self, event, addon)
	if (addon ~= "KkthnxUI") then
		return
	end

	-- CREATE AN EMPTY CVAR IF THEY DON'T EXIST
	if not SavedPositions then SavedPositions = {} end
	if not SavedOptionsPerChar then SavedOptionsPerChar = {} end
	if SavedOptionsPerChar.AutoInvite == nil then SavedOptionsPerChar.AutoInvite = false end
	if SavedOptionsPerChar.BarsLocked == nil then SavedOptionsPerChar.BarsLocked = false end
	if SavedOptionsPerChar.SplitBars == nil then SavedOptionsPerChar.SplitBars = true end
	if SavedOptionsPerChar.RightBars == nil then SavedOptionsPerChar.RightBars = C.ActionBar.RightBars end
	if SavedOptionsPerChar.BottomBars == nil then SavedOptionsPerChar.BottomBars = C.ActionBar.BottomBars end

	if K.ScreenWidth < 1024 then
		SetCVar("useUiScale", 0)
		StaticPopup_Show("DISABLE_UI")
	else

		-- INSTALL DEFAULT IF WE NEVER RAN KKTHNXUI ON THIS CHARACTER
		if not SavedOptionsPerChar.Install then
			StaticPopup_Show("INSTALL_UI")
		end

		self:UnregisterEvent("ADDON_LOADED")
	end

	-- WELCOME MESSAGE
	if C.General.WelcomeMessage == true then
		print("|cffffe02e"..L_WELCOME_LINE_1..K.Version.." "..K.Client..", "..format("|cff%02x%02x%02x%s|r", K.Color.r * 255, K.Color.g * 255, K.Color.b * 255, K.Name)..".|r")
		print("|cffffe02e"..L_WELCOME_LINE_2_1.."|cffffe02e"..L_WELCOME_LINE_2_2.."|r")
		print("|cffffe02e"..L_WELCOME_LINE_2_3.."|cffffe02e"..L_WELCOME_LINE_2_4.."|r")
	end
end)

-- HELP TRANSLATE
if C.General.TranslateMessage == true then
	if GetLocale() == "esES" or GetLocale() == "koKR" or GetLocale() == "ruRU" or GetLocale() == "esMX" or GetLocale() == "deDE" or GetLocale() == "frFR" or GetLocale() == "koKR" or GetLocale() == "zhCN" or GetLocale() == "zhTW" then
		print("|cffffe02ePlease help us translate the text settings for |cff2eb6ffKkthnxUI|r. |cffffe02eYou can post a commit to|r |cff2eb6ffgithub.com/Kkthnx/KkthnxUI_Legion|r")
	end
end