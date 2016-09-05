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
	SetCVar("RotateMinimap", 0)
	SetCVar("ShowClassColorInNameplate", 1)
	SetCVar("SpamFilter", 0)
	SetCVar("UberTooltips", 1)
	SetCVar("WhisperMode", "inline")
	SetCVar("WholeChatWindowClickable", 0)
	SetCVar("alwaysShowActionBars", 1)
	SetCVar("autoDismount", 1)
	SetCVar("autoOpenLootHistory", 0)
	SetCVar("autoQuestProgress", 1)
	SetCVar("autoQuestWatch", 1)
	SetCVar("buffDurations", 1)
	SetCVar("cameraDistanceMaxFactor", 2.6)
	SetCVar("chatMouseScroll", 1)
	SetCVar("chatStyle", "classic", "chatStyle")
	SetCVar("colorblindMode", 0)
	SetCVar("countdownForCooldowns", 0)
	SetCVar("gameTip", 0)
	SetCVar("lockActionBars", 1)
	SetCVar("lootUnderMouse", 0)
	SetCVar("maxfpsbk", 0)
	SetCVar("nameplateShowSelf", 0)
	SetCVar("removeChatDelay", 1)
	SetCVar("screenshotQuality", 10)
	SetCVar("scriptErrors", 0)
	SetCVar("showTutorials", 0)
	SetCVar("statusTextDisplay", "NONE")
	SetCVar("taintLog", 0)
	SetCVar("threatWarning", 3)
	SetCVar("violenceLevel", 5)

	InterfaceOptionsActionBarsPanelPickupActionKeyDropDown:SetValue("SHIFT")
	InterfaceOptionsActionBarsPanelPickupActionKeyDropDown:RefreshValue()

	FCF_ResetChatWindows()
	FCF_SetLocked(ChatFrame1, 1)
	FCF_DockFrame(ChatFrame2)
	FCF_SetLocked(ChatFrame2, 1)

	FCF_OpenNewWindow(LOOT)
	FCF_DockFrame(ChatFrame3)
	FCF_SetLocked(ChatFrame3, 1)
	ChatFrame3:Show()

	-- SETTING CHAT FRAMES
	if C.Chat.Enable == true and not (select(4, GetAddOnInfo("Prat-3.0"))) or (select(4, GetAddOnInfo("Chatter"))) then
		for i = 1, NUM_CHAT_WINDOWS do
			local frame = _G[format("ChatFrame%s", i)]
			local chatFrameId = frame:GetID()
			local chatName = FCF_GetChatWindowInfo(chatFrameId)

			frame:SetSize(C.Chat.Width, C.Chat.Height)

			-- DEFAULT WIDTH AND HEIGHT OF CHATS
			SetChatWindowSavedDimensions(chatFrameId, K.Scale(C.Chat.Width), K.Scale(C.Chat.Height))

			-- MOVE GENERAL CHAT TO BOTTOM LEFT
			if i == 1 then
				frame:ClearAllPoints()
				frame:SetPoint(unpack(C.Position.Chat))
			end

			-- SAVE NEW DEFAULT POSITION AND DIMENSION
			FCF_SavePositionAndDimensions(frame)
			FCF_StopDragging(frame)

			-- SET DEFAULT FONT SIZE
			FCF_SetChatWindowFontSize(nil, frame, 12)

			-- RENAME CHAT TABS.
			if i == 1 then
				FCF_SetWindowName(frame, GENERAL)
			elseif i == 2 then
				FCF_SetWindowName(frame, GUILD_EVENT_LOG)
			elseif i == 3 then
				FCF_SetWindowName(frame, LOOT.." / "..TRADE)
			end
		end

		ChatFrame_RemoveAllMessageGroups(ChatFrame1)
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
		ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_BOSS_EMOTE")
		ChatFrame_AddMessageGroup(ChatFrame1, "PARTY")
		ChatFrame_AddMessageGroup(ChatFrame1, "PARTY_LEADER")
		ChatFrame_AddMessageGroup(ChatFrame1, "RAID")
		ChatFrame_AddMessageGroup(ChatFrame1, "RAID_LEADER")
		ChatFrame_AddMessageGroup(ChatFrame1, "RAID_WARNING")
		ChatFrame_AddMessageGroup(ChatFrame1, "INSTANCE_CHAT")
		ChatFrame_AddMessageGroup(ChatFrame1, "INSTANCE_CHAT_LEADER")
		ChatFrame_AddMessageGroup(ChatFrame1, "BATTLEGROUND")
		ChatFrame_AddMessageGroup(ChatFrame1, "BATTLEGROUND_LEADER")
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
		ChatFrame_AddMessageGroup(ChatFrame1, "BN_INLINE_TOAST_ALERT")

		ChatFrame_RemoveAllMessageGroups(ChatFrame3)
		ChatFrame_AddMessageGroup(ChatFrame3, "COMBAT_FACTION_CHANGE")
		ChatFrame_AddMessageGroup(ChatFrame3, "SKILL")
		ChatFrame_AddMessageGroup(ChatFrame3, "LOOT")
		ChatFrame_AddMessageGroup(ChatFrame3, "MONEY")
		ChatFrame_AddMessageGroup(ChatFrame3, "COMBAT_XP_GAIN")
		ChatFrame_AddMessageGroup(ChatFrame3, "COMBAT_HONOR_GAIN")
		ChatFrame_AddMessageGroup(ChatFrame3, "COMBAT_GUILD_XP_GAIN")
		ChatFrame_AddMessageGroup(ChatFrame3, "CURRENCY")
		ChatFrame_AddChannel(ChatFrame1, GENERAL)
		ChatFrame_RemoveChannel(ChatFrame1, L_CHAT_TRADE)
		ChatFrame_AddChannel(ChatFrame3, L_CHAT_TRADE)

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
		ToggleChatColorNamesByClassGroup(true, "INSTANCE_CHAT")
		ToggleChatColorNamesByClassGroup(true, "INSTANCE_CHAT_LEADER")
		ToggleChatColorNamesByClassGroup(true, "CHANNEL1")
		ToggleChatColorNamesByClassGroup(true, "CHANNEL2")
		ToggleChatColorNamesByClassGroup(true, "CHANNEL3")
		ToggleChatColorNamesByClassGroup(true, "CHANNEL4")
		ToggleChatColorNamesByClassGroup(true, "CHANNEL5")
		ToggleChatColorNamesByClassGroup(true, "CHANNEL6")
		ToggleChatColorNamesByClassGroup(true, "CHANNEL7")
		ToggleChatColorNamesByClassGroup(true, "CHANNEL8")
		ToggleChatColorNamesByClassGroup(true, "CHANNEL9")
		ToggleChatColorNamesByClassGroup(true, "CHANNEL10")
		ToggleChatColorNamesByClassGroup(true, "CHANNEL11")

		-- ADJUST CHAT COLORS
		ChangeChatColor("CHANNEL1", 195/255, 230/255, 232/255) -- GENERAL
		ChangeChatColor("CHANNEL2", 232/255, 158/255, 121/255) -- TRADE
		ChangeChatColor("CHANNEL3", 232/255, 228/255, 121/255) -- LOCAL DEFENSE
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

	K.ShowPopup("RELOAD_UI")
end

local function DisableUI()
	DisableAddOn("KkthnxUI")
	ReloadUI()
end

K.CreatePopup["INSTALL_UI"] = {
	Question = L_POPUP_INSTALLUI,
	Answer1 = ACCEPT,
	Answer2 = CANCEL,
	Function1 = InstallUI,
	Function2 = function() SavedOptionsPerChar.Install = false end,
}

K.CreatePopup["RELOAD_UI"] = {
	Question = L_POPUP_RELOADUI,
	Answer1 = ACCEPT,
	Answer2 = CANCEL,
	Function1 = function() ReloadUI() end,
	Function2 = function() SavedOptionsPerChar.Install = false end,
}

K.CreatePopup["DISABLE_UI"] = {
	Question = L_POPUP_DISABLEUI,
	Answer1 = ACCEPT,
	Answer2 = CANCEL,
	Function1 = DisableUI,
}

K.CreatePopup["RESET_UI"] = {
	Question = L_POPUP_RESETUI,
	Answer1 = ACCEPT,
	Answer2 = CANCEL,
	Function1 = InstallUI,
	Function2 = function() SavedOptionsPerChar.Install = true end,
}

SLASH_INSTALLUI1 = "/installui"
SlashCmdList.INSTALLUI = function() K.ShowPopup("INSTALL_UI") end

SLASH_CONFIGURE1 = "/resetui"
SlashCmdList.CONFIGURE = function() K.ShowPopup("RESET_UI") end

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
		K.ShowPopup("DISABLE_UI")
	else
		--[[
		SetCVar("useUiScale", 1)
		if C.General.UIScale > 1.28 then C.General.UIScale = 1.28 end
		if C.General.UIScale < 0.64 then C.General.UIScale = 0.64 end

		-- SET OUR UISCALE
		SetCVar("uiScale", C.General.UIScale)

		-- HACK FOR 4K AND WQHD RESOLUTION
		local CustomScale = min(2, max(0.32, 768 / string.match(T.resolution, "%d+x(%d+)")))
		if C.General.AutoScale == true and CustomScale < 0.64 then
			UIParent:SetScale(CustomScale)
		elseif CustomScale < 0.64 then
			UIParent:SetScale(C.General.UIScale)
		end
		]]--

		-- INSTALL DEFAULT IF WE NEVER RAN KKTHNXUI ON THIS CHARACTER
		if not SavedOptionsPerChar.Install then
			K.ShowPopup("INSTALL_UI")
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
	if GetLocale() == "esES" or GetLocale() == "koKR" or GetLocale() == "esMX" or GetLocale() == "deDE" or GetLocale() == "frFR" or GetLocale() == "koKR" or GetLocale() == "zhCN" or GetLocale() == "zhTW" then
		print("|cffffe02ePlease help us translate the text settings for |cff2eb6ffKkthnxUI|r. |cffffe02eYou can post a commit to|r |cff2eb6ffgithub.com/Kkthnx/KkthnxUI_Legion|r")
	end
end