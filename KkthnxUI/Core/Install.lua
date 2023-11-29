local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:NewModule("Installer")

-- Sourced: NDui (siweia)
-- Edited: KkthnxUI (Kkthnx)

local APPLY = APPLY
local CHAT = CHAT
local ChangeChatColor = ChangeChatColor
local ChatConfig_UpdateChatSettings = ChatConfig_UpdateChatSettings
local ChatFrame_AddChannel = ChatFrame_AddChannel
local ChatFrame_AddMessageGroup = ChatFrame_AddMessageGroup
local ChatFrame_RemoveAllMessageGroups = ChatFrame_RemoveAllMessageGroups
local ChatFrame_RemoveChannel = ChatFrame_RemoveChannel
local CreateFrame = CreateFrame
local DEFAULT = DEFAULT
local FCF_DockFrame = FCF_DockFrame
local FCF_OpenNewWindow = FCF_OpenNewWindow
local FCF_ResetChatWindows = FCF_ResetChatWindows
local FCF_SetChatWindowFontSize = FCF_SetChatWindowFontSize
local FCF_SetLocked = FCF_SetLocked
local FCF_SetWindowName = FCF_SetWindowName
local GENERAL = GENERAL
local InCombatLockdown = InCombatLockdown
local PlaySound = PlaySound
local SETTINGS = SETTINGS
local SetCVar = SetCVar
local TRADE = TRADE
local ToggleChatColorNamesByClassGroup = ToggleChatColorNamesByClassGroup
local UIErrorsFrame = UIErrorsFrame
local UIParent = UIParent
local UI_SCALE = UI_SCALE

function Module:ResetSettings()
	KkthnxUIDB.Settings[K.Realm][K.Name] = {}
end

function Module:ResetData()
	KkthnxUIDB.Variables[K.Realm][K.Name] = {}

	FCF_ResetChatWindows()

	if _G.ChatConfigFrame:IsShown() then
		ChatConfig_UpdateChatSettings()
	end

	Module:ForceDefaultCVars()

	ReloadUI()
end

-- Tuitorial
function Module:ForceDefaultCVars()
	SetCVar("RotateMinimap", 0)
	SetCVar("ShowClassColorInNameplate", 1)
	SetCVar("UberTooltips", 1)
	SetCVar("WholeChatWindowClickable", 0)
	SetCVar("alwaysCompareItems", 1)
	SetCVar("alwaysShowActionBars", 1)
	SetCVar("autoLootDefault", 1)
	SetCVar("autoOpenLootHistory", 0)
	SetCVar("autoQuestProgress", 1)
	SetCVar("autoQuestWatch", 1)
	SetCVar("autoSelfCast", 1)
	SetCVar("buffDurations", 1)
	SetCVar("cameraDistanceMaxZoomFactor", 2.6)
	SetCVar("cameraSmoothStyle", 0)
	SetCVar("colorblindMode", 0)
	SetCVar("floatingCombatTextCombatDamage", 1)
	SetCVar("floatingCombatTextCombatDamageDirectionalOffset", 10)
	SetCVar("floatingCombatTextCombatDamageDirectionalScale", 0)
	SetCVar("floatingCombatTextCombatHealing", 1)
	SetCVar("floatingCombatTextFloatMode", 1)
	SetCVar("gameTip", 0)
	SetCVar("instantQuestText", 1)
	SetCVar("lockActionBars", 1)
	SetCVar("lootUnderMouse", 1)
	SetCVar("lossOfControl", 0)
	SetCVar("overrideArchive", 0)
	SetCVar("profanityFilter", 0)
	SetCVar("removeChatDelay", 1)
	SetCVar("screenshotQuality", 10)
	SetCVar("scriptErrors", 1)
	SetCVar("showArenaEnemyFrames", 0)
	SetCVar("showLootSpam", 1)
	SetCVar("showTutorials", 0)
	SetCVar("showVKeyCastbar", 1)
	SetCVar("spamFilter", 0)
	SetCVar("taintLog", 0)
	SetCVar("violenceLevel", 5)
	SetCVar("whisperMode", "inline")
	SetCVar("ActionButtonUseKeyDown", 1)
	SetCVar("UberTooltips", 1)
	SetCVar("alwaysShowActionBars", 1)
	SetCVar("fstack_preferParentKeys", 0) -- Add back the frame names via fstack!
	SetCVar("lockActionBars", 1)
	SetCVar("screenshotQuality", 10)
	SetCVar("showNPETutorials", 0)
	SetCVar("showTutorials", 0)
	SetCVar("statusTextDisplay", "BOTH")
	SetCVar("threatWarning", 3)

	if not InCombatLockdown() then
		SetCVar("nameplateShowEnemyMinions", 1)
		SetCVar("nameplateShowEnemyMinus", 1)
		SetCVar("nameplateShowFriendlyMinions", 0)
		SetCVar("nameplateShowFriends", 0)
		SetCVar("nameplateMotion", 1)
		SetCVar("nameplateShowAll", 1)
		SetCVar("nameplateShowEnemies", 1)
		SetCVar("alwaysShowActionBars", 1)
	end

	if K.isDeveloper then
		SetCVar("ffxGlow", 0)
		SetCVar("WorldTextScale", 1)
		SetCVar("SpellQueueWindow", 25)
	end
end

local function ForceRaidFrame()
	if InCombatLockdown() then
		return
	end

	if not _G.CompactUnitFrameProfiles then
		return
	end

	SetCVar("useCompactPartyFrames", 1)

	_G.SetRaidProfileOption(_G.CompactUnitFrameProfiles.selectedProfile, "useClassColors", true)
	_G.SetRaidProfileOption(_G.CompactUnitFrameProfiles.selectedProfile, "displayPowerBar", true)
	_G.SetRaidProfileOption(_G.CompactUnitFrameProfiles.selectedProfile, "displayBorder", false)
	_G.CompactUnitFrameProfiles_ApplyCurrentSettings()
	_G.CompactUnitFrameProfiles_UpdateCurrentPanel()
end

function Module:ForceChatSettings()
	FCF_ResetChatWindows()

	for _, name in ipairs(_G.CHAT_FRAMES) do
		local frame = _G[name]
		local id = frame:GetID()

		if id == 1 then
			frame:ClearAllPoints()
			frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 7, 11)
			frame:SetWidth(C["Chat"].Width)
			frame:SetHeight(C["Chat"].Height)
		elseif id == 3 then
			VoiceTranscriptionFrame_UpdateVisibility(frame)
			VoiceTranscriptionFrame_UpdateVoiceTab(frame)
			VoiceTranscriptionFrame_UpdateEditBox(frame)
		end

		FCF_SetChatWindowFontSize(nil, frame, 12)
		-- FCF_SavePositionAndDimensions(frame)
		FCF_StopDragging(frame)
	end

	-- General
	FCF_SetLocked(ChatFrame1, 1)
	FCF_SetWindowName(ChatFrame1, L["General"])
	ChatFrame1:Show()

	-- Combat Log
	FCF_DockFrame(ChatFrame2)
	FCF_SetLocked(ChatFrame2, 1)
	FCF_SetWindowName(ChatFrame2, L["CombatLog"])
	ChatFrame2:Show()

	-- Whispers
	FCF_OpenNewWindow(L["Whisper"])
	FCF_SetLocked(ChatFrame4, 1)
	FCF_DockFrame(ChatFrame4)
	ChatFrame4:Show()

	-- Trade
	FCF_OpenNewWindow(L["Trade"])
	FCF_SetLocked(ChatFrame5, 1)
	FCF_DockFrame(ChatFrame5)
	ChatFrame5:Show()

	-- Loot
	FCF_OpenNewWindow(L["Loot"])
	FCF_SetLocked(ChatFrame6, 1)
	FCF_DockFrame(ChatFrame6)
	ChatFrame6:Show()

	-- ChatFrame 1
	ChatFrame_RemoveChannel(ChatFrame1, TRADE)
	ChatFrame_RemoveChannel(ChatFrame1, L["Services"]) -- New channel 9.2.7
	ChatFrame_RemoveChannel(ChatFrame1, GENERAL)
	ChatFrame_RemoveChannel(ChatFrame1, "GuildRecruitment")
	ChatFrame_RemoveChannel(ChatFrame1, "LookingForGroup")

	-- We do not add -> MONSTER_SAY, MONSTER_YELL, MONSTER_EMOTE, MONSTER_WHISPER, MONSTER_BOSS_EMOTE, MONSTER_BOSS_WHISPER
	local chatGroup = {
		"SYSTEM",
		"CHANNEL",
		"SAY",
		"EMOTE",
		"YELL",
		"PARTY",
		"PARTY_LEADER",
		"RAID",
		"RAID_LEADER",
		"RAID_WARNING",
		"INSTANCE_CHAT",
		"INSTANCE_CHAT_LEADER",
		"GUILD",
		"OFFICER",
		"ERRORS",
		"AFK",
		"DND",
		"IGNORED",
		"BG_HORDE",
		"BG_ALLIANCE",
		"BG_NEUTRAL",
		"ACHIEVEMENT",
		"GUILD_ACHIEVEMENT",
		"BN_INLINE_TOAST_ALERT",
	}
	ChatFrame_RemoveAllMessageGroups(ChatFrame1)
	for _, v in ipairs(chatGroup) do
		ChatFrame_AddMessageGroup(_G.ChatFrame1, v)
	end

	-- ChatFrame 4
	chatGroup = { "WHISPER", "BN_WHISPER", "BN_CONVERSATION" }
	ChatFrame_RemoveAllMessageGroups(ChatFrame4)
	for _, v in ipairs(chatGroup) do
		ChatFrame_AddMessageGroup(_G.ChatFrame4, v)
	end

	-- ChatFrame 5
	ChatFrame_RemoveAllMessageGroups(ChatFrame5)
	ChatFrame_AddChannel(ChatFrame5, TRADE)
	ChatFrame_AddChannel(ChatFrame5, GENERAL)
	ChatFrame_AddChannel(ChatFrame5, "LookingForGroup")

	chatGroup = { "COMBAT_XP_GAIN", "COMBAT_HONOR_GAIN", "COMBAT_FACTION_CHANGE", "SKILL", "LOOT", "CURRENCY", "MONEY" }
	ChatFrame_RemoveAllMessageGroups(ChatFrame6)
	for _, v in ipairs(chatGroup) do
		ChatFrame_AddMessageGroup(_G.ChatFrame6, v)
	end

	-- set the chat groups names in class color to enabled for all chat groups which players names appear
	chatGroup = {
		"SAY",
		"EMOTE",
		"YELL",
		"WHISPER",
		"PARTY",
		"PARTY_LEADER",
		"RAID",
		"RAID_LEADER",
		"RAID_WARNING",
		"INSTANCE_CHAT",
		"INSTANCE_CHAT_LEADER",
		"GUILD",
		"OFFICER",
		"ACHIEVEMENT",
		"GUILD_ACHIEVEMENT",
		"COMMUNITIES_CHANNEL",
	}
	for i = 1, _G.MAX_WOW_CHAT_CHANNELS do
		table.insert(chatGroup, "CHANNEL" .. i)
	end

	for _, v in ipairs(chatGroup) do
		ToggleChatColorNamesByClassGroup(true, v)
	end

	-- Adjust Chat Colors
	ChangeChatColor("CHANNEL1", 195 / 255, 230 / 255, 232 / 255) -- General
	ChangeChatColor("CHANNEL2", 232 / 255, 158 / 255, 121 / 255) -- Trade
	ChangeChatColor("CHANNEL3", 232 / 255, 228 / 255, 121 / 255) -- Local Defense
end

-- Tutorial
local tutor
local function YesTutor()
	if tutor then
		tutor:Show()
		return
	end

	tutor = CreateFrame("Frame", nil, UIParent)
	tutor:SetPoint("CENTER")
	tutor:SetSize(480, 240)
	tutor:SetFrameStrata("HIGH")
	K.CreateMoverFrame(tutor)
	tutor:CreateBorder()

	local tutorLogo = tutor:CreateTexture(nil, "OVERLAY")
	tutorLogo:SetSize(512 / 1.4, 256 / 1.4)
	tutorLogo:SetBlendMode("ADD")
	tutorLogo:SetAlpha(0.07)
	tutorLogo:SetTexture(C["Media"].Textures.LogoTexture)
	tutorLogo:SetPoint("CENTER", tutor, "CENTER", 0, 0)

	local ll = CreateFrame("Frame", nil, tutor)
	ll:SetPoint("TOP", -40, -32)
	K.CreateGF(ll, 80, 1, "Horizontal", 0.7, 0.7, 0.7, 0, 0.7)
	ll:SetFrameStrata("HIGH")
	local lr = CreateFrame("Frame", nil, tutor)
	lr:SetPoint("TOP", 40, -32)
	K.CreateGF(lr, 80, 1, "Horizontal", 0.7, 0.7, 0.7, 0.7, 0)
	lr:SetFrameStrata("HIGH")

	local title = K.CreateFontString(tutor, 13, "", "", true, "TOP", 0, -10)
	local body = K.CreateFontString(tutor, 13, "", "", false, "TOPLEFT", 20, -50)

	body:SetPoint("BOTTOMRIGHT", -20, 50)
	body:SetJustifyV("TOP")
	body:SetJustifyH("LEFT")
	body:SetWordWrap(true)

	local progressBar = CreateFrame("StatusBar", nil, tutor)
	progressBar:SetMinMaxValues(0, 500)
	progressBar:SetValue(0)
	progressBar:CreateBorder()
	progressBar:SetPoint("TOP", tutor, "BOTTOM", 0, -6)
	progressBar:SetSize(480, 22)
	progressBar:SetStatusBarTexture(K.GetTexture(C["General"].Texture))
	K:SmoothBar(progressBar)

	progressBar.text = K.CreateFontString(progressBar, 13, "", "", false, "CENTER", 0, -1)

	progressBar.spark = progressBar:CreateTexture(nil, "OVERLAY")
	progressBar.spark:SetWidth(64)
	progressBar.spark:SetHeight(progressBar:GetHeight())
	progressBar.spark:SetTexture(C["Media"].Textures.Spark128Texture)
	progressBar.spark:SetBlendMode("ADD")
	progressBar.spark:SetPoint("CENTER", progressBar:GetStatusBarTexture(), "RIGHT", 0, 0)
	progressBar.spark:SetAlpha(0.6)

	local pass = CreateFrame("Button", nil, tutor)
	pass:SetPoint("BOTTOMLEFT", 10, 10)
	pass:SetSize(90, 24)
	pass:SkinButton()

	pass.text = pass:CreateFontString(nil, "OVERLAY")
	pass.text:SetFontObject(K.UIFont)
	pass.text:SetPoint("CENTER")
	pass.text:SetText(DECLINE)
	pass.text:SetTextColor(1, 0, 0)

	local apply = CreateFrame("Button", nil, tutor)
	apply:SetPoint("BOTTOMRIGHT", -10, 10)
	apply:SetSize(90, 24)
	apply:SkinButton()

	apply.text = apply:CreateFontString(nil, "OVERLAY")
	apply.text:SetFontObject(K.UIFont)
	apply.text:SetPoint("CENTER")
	apply.text:SetText(APPLY)
	apply.text:SetTextColor(0, 1, 0)

	local titles = {
		DEFAULT .. " " .. SETTINGS,
		CHAT,
		UI_SCALE,
		"Skins",
		"Tips",
	}

	local function RefreshText(page)
		title:SetText(titles[page])
		body:SetText(L["Tutorial Page" .. page])

		if progressBar then
			progressBar:SetValue(page .. "00")
			progressBar:SetStatusBarColor(K.r, K.g, K.b)
			progressBar.text:SetText(page .. "/5")
		end
	end
	RefreshText(1)

	local currentPage = 1
	pass:SetScript("OnClick", function()
		if currentPage > 3 then
			pass:Hide()
		end

		currentPage = currentPage + 1
		RefreshText(currentPage)
		StopSound(21968)
		StopSound(140268)
		PlaySound(140268)
	end)

	apply:SetScript("OnClick", function()
		pass:Show()
		if currentPage == 1 then
			Module:ForceDefaultCVars()
			ForceRaidFrame()
			UIErrorsFrame:AddMessage(K.InfoColor .. "Default CVars Loaded.")
			PlaySound(21968)
		elseif currentPage == 2 then
			StopSound(21968)
			Module:ForceChatSettings()
			UIErrorsFrame:AddMessage(K.InfoColor .. "Chat Frame Settings Loaded")
			PlaySound(21968)
		elseif currentPage == 3 then
			StopSound(21968)
			K.SetupUIScale(true)
			UIErrorsFrame:AddMessage(K.InfoColor .. "UI Scale Loaded")
			PlaySound(21968)
		elseif currentPage == 4 then
			StopSound(21968)
			KkthnxUIDB.Variables[K.Realm][K.Name].DBMRequest = true
			KkthnxUIDB.Variables[K.Realm][K.Name].MaxDpsRequest = true
			KkthnxUIDB.Variables[K.Realm][K.Name].CursorTrailRequest = true
			KkthnxUIDB.Variables[K.Realm][K.Name].HekiliRequest = true
			Module.ForceAddonSkins()
			UIErrorsFrame:AddMessage(K.InfoColor .. "Relevant AddOns Settings Loaded, You need to ReloadUI.")
			pass:Hide()
			PlaySound(21968)
		elseif currentPage == 5 then
			Module:ForceDefaultCVars() -- Set these one more time
			StopSound(21968)
			StopSound(140268)
			KkthnxUIDB.Variables[K.Realm][K.Name].InstallComplete = true
			tutor:Hide()
			progressBar:Hide()
			currentPage = 0
			PlaySound(166318)
			StaticPopup_Show("KKUI_CHANGES_RELOAD")
		end

		currentPage = currentPage + 1
		RefreshText(currentPage)
	end)
end

local welcome
local function HelloWorld()
	if welcome then
		welcome:Show()
		return
	end

	welcome = CreateFrame("Frame", "KKUI_Tutorial", UIParent)
	welcome:SetPoint("CENTER")
	welcome:SetSize(420, 500)
	welcome:SetFrameStrata("HIGH")
	K.CreateMoverFrame(welcome)
	welcome:CreateBorder()
	K.CreateFontString(welcome, 30, K.Title, "", false, "TOPLEFT", 10, 28)
	K.CreateFontString(welcome, 14, K.Version, "", true, "TOPLEFT", 154, 16)
	K.CreateFontString(welcome, 16, "Help Info", "", true, "TOP", 0, -10)

	local welcomeLogo = welcome:CreateTexture(nil, "OVERLAY")
	welcomeLogo:SetSize(512, 256)
	welcomeLogo:SetBlendMode("ADD")
	welcomeLogo:SetAlpha(0.04)
	welcomeLogo:SetTexture(C["Media"].Textures.LogoTexture)
	welcomeLogo:SetPoint("CENTER", welcome, "CENTER", 0, 0)

	local welcomeBoss = welcome:CreateTexture(nil, "OVERLAY")
	welcomeBoss:SetSize(128, 64)
	welcomeBoss:SetTexture("Interface\\ENCOUNTERJOURNAL\\UI-EJ-BOSS-SennarthTheColdBreath")
	welcomeBoss:SetPoint("TOPRIGHT", welcome, "TOPRIGHT", 10, 64)

	local ll = CreateFrame("Frame", nil, welcome)
	ll:SetPoint("TOP", -50, -35)
	K.CreateGF(ll, 100, 1, "Horizontal", 0.7, 0.7, 0.7, 0, 0.7)
	ll:SetFrameStrata("HIGH")

	local lr = CreateFrame("Frame", nil, welcome)
	lr:SetPoint("TOP", 50, -35)
	K.CreateGF(lr, 100, 1, "Horizontal", 0.7, 0.7, 0.7, 0.7, 0)
	lr:SetFrameStrata("HIGH")
	-- stylua: ignore start
	K.CreateFontString(welcome, 14, "Thank you for choosing |cff669dffKkthnxUI|r, v" .. K.SystemColor .. K.Version .. "|r!", "", false, "TOP", 0, -50)
	K.CreateFontString(welcome, 13, "|cff669dffKkthnxUI|r is a simplistic user interface that holds", "", false, "TOP", 0, -86)
	K.CreateFontString(welcome, 13, "onto the information and functionality, while still keeping", "", false, "TOP", 0, -106)
	K.CreateFontString(welcome, 13, "most of the good looks. It can be used for any class or role.", "", false, "TOP", 0, -126)
	-- stylua: ignore end

	K.CreateFontString(welcome, 16, "|cff669dffJoin The Community!|r", "", false, "TOP", 0, -160)
	K.CreateFontString(welcome, 13, "There are thousands of users, but most are content", "", false, "TOP", 0, -180)
	-- stylua: ignore
	K.CreateFontString(welcome, 13, "to simply download and use the interface without further", "", false, "TOP", 0, -200)
	K.CreateFontString(welcome, 13, "ado. If you wish to get more involved though,", "", false, "TOP", 0, -220)
	K.CreateFontString(welcome, 13, "have some questions you can't find answers to", "", false, "TOP", 0, -240)
	K.CreateFontString(welcome, 13, "anywhere else or simply just wish to stop by,", "", false, "TOP", 0, -260)
	K.CreateFontString(welcome, 13, "we have both a discord server and a facebook page.", "", false, "TOP", 0, -280)

	local ll = CreateFrame("Frame", nil, welcome)
	ll:SetPoint("TOP", welcome, -90, -326)
	K.CreateGF(ll, 180, 1, "Horizontal", 0.7, 0.7, 0.7, 0, 0.7)
	ll:SetFrameStrata("HIGH")
	local lr = CreateFrame("Frame", nil, welcome)
	lr:SetPoint("TOP", welcome, 90, -326)
	K.CreateGF(lr, 180, 1, "Horizontal", 0.7, 0.7, 0.7, 0.7, 0)
	lr:SetFrameStrata("HIGH")

	-- stylua: ignore
	K.CreateFontString(welcome, 13, "If this is your first time using |cff669dffKkthnxUI|r,", "", false, "BOTTOM", 0, 130)
	K.CreateFontString(welcome, 13, "please take a minute to go through the turtoral!", "", false, "BOTTOM", 0, 110)
	K.CreateFontString(welcome, 13, "if you need help for commands type /khelp", "", false, "BOTTOM", 0, 90)

	if KkthnxUIDB.Variables[K.Realm][K.Name].InstallComplete then
		local close = CreateFrame("Button", nil, welcome)
		close:SetPoint("TOPRIGHT", 4, 4)
		close:SetSize(32, 32)
		close:SkinCloseButton()
		close:SetScript("OnClick", function()
			welcome:Hide()
		end)
	end

	local goTutor = CreateFrame("Button", nil, welcome)
	goTutor:SetPoint("BOTTOM", 0, 10)
	goTutor:SetSize(110, 20)
	goTutor:SkinButton()

	if welcome:IsShown() then
		K.ShowOverlayGlow(goTutor, "AutoCastGlow")
	end

	goTutor.text = goTutor:CreateFontString(nil, "OVERLAY")
	goTutor.text:SetFontObject(K.UIFont)
	goTutor.text:SetPoint("CENTER")
	goTutor.text:SetText("Install")

	goTutor:SetScript("OnClick", function()
		K.HideOverlayGlow(goTutor, "AutoCastGlow")
		welcome:Hide()
		YesTutor()
	end)

	-- local goTwitch = CreateFrame("Button", nil, welcome)
	-- goTwitch:SetPoint("BOTTOM", 0, 50)
	-- goTwitch:SetSize(110, 20)
	-- goTwitch:SkinButton()

	-- goTwitch.text = goTwitch:CreateFontString(nil, "OVERLAY")
	-- goTwitch.text:SetFontObject(K.UIFont)
	-- goTwitch.text:SetPoint("CENTER")
	-- goTwitch.text:SetText("|CFF8F76BDTwitch|r")

	-- goTwitch:SetScript("OnClick", function()
	-- 	StaticPopup_Show("KKUI_POPUP_LINK", nil, nil, "https://www.twitch.tv/kkthnxtv")
	-- end)

	-- local goKick = CreateFrame("Button", nil, welcome)
	-- goKick:SetPoint("BOTTOM", 0, 50)
	-- goKick:SetSize(110, 20)
	-- goKick:SkinButton()

	-- goKick.text = goTwitch:CreateFontString(nil, "OVERLAY")
	-- goKick.text:SetFontObject(K.UIFont)
	-- goKick.text:SetPoint("CENTER")
	-- goKick.text:SetText("|CFF8F76BDTwitch|r")

	-- goKick:SetScript("OnClick", function()
	-- 	StaticPopup_Show("KKUI_POPUP_LINK", nil, nil, "https://www.kick.tv/kkthnx")
	-- end)

	local goDiscord = CreateFrame("Button", nil, welcome)
	goDiscord:SetPoint("BOTTOM", 0, 50)
	goDiscord:SetSize(110, 22)
	goDiscord:SkinButton()

	goDiscord.text = goDiscord:CreateFontString(nil, "OVERLAY")
	goDiscord.text:SetFontObject(K.UIFont)
	goDiscord.text:SetPoint("CENTER")
	goDiscord.text:SetText("|CFF7289daDiscord|r")

	goDiscord:SetScript("OnClick", function()
		StaticPopup_Show("KKUI_POPUP_LINK", nil, nil, "https://discord.gg/Rc9wcK9cAB")
	end)

	local goPaypal = CreateFrame("Button", nil, welcome)
	goPaypal:SetPoint("BOTTOM", -120, 50)
	goPaypal:SetSize(110, 22)
	goPaypal:SkinButton()
	-- goPaypal.KKUI_Border:SetVertexColor(0 / 255, 121 / 255, 193 / 255)

	goPaypal.text = goPaypal:CreateFontString(nil, "OVERLAY")
	goPaypal.text:SetFontObject(K.UIFont)
	goPaypal.text:SetPoint("CENTER")
	goPaypal.text:SetText("|CFF0079C1Paypal|r")

	goPaypal:SetScript("OnClick", function()
		StaticPopup_Show("KKUI_POPUP_LINK", nil, nil, "https://www.paypal.com/paypalme/KkthnxTV")
	end)

	local goPatreon = CreateFrame("Button", nil, welcome)
	goPatreon:SetPoint("BOTTOM", 120, 50)
	goPatreon:SetSize(110, 22)
	goPatreon:SkinButton()

	goPatreon.text = goPatreon:CreateFontString(nil, "OVERLAY")
	goPatreon.text:SetFontObject(K.UIFont)
	goPatreon.text:SetPoint("CENTER")
	goPatreon.text:SetText("|CFFf96854Patreon|r")

	goPatreon:SetScript("OnClick", function()
		StaticPopup_Show("KKUI_POPUP_LINK", nil, nil, "https://www.patreon.com/kkthnx")
	end)
end
_G.SlashCmdList["KKUI_INSTALLER"] = HelloWorld
_G.SLASH_KKUI_INSTALLER1 = "/install"

function Module:OnEnable()
	print(K.Title .. " " .. K.GreyColor .. K.Version .. "|r " .. K.SystemColor .. K.Client .. "|r")

	-- Tutorial and settings
	Module.ForceAddonSkins()
	if not KkthnxUIDB.Variables[K.Realm][K.Name].InstallComplete then
		HelloWorld()
	else
		K.LibChangeLog:Register(K.Title, K.Changelog, KkthnxUIDB.ChangeLog, "lastReadVersion", "onlyShowWhenNewVersion")
		K.LibChangeLog:ShowChangelog(K.Title)
	end
end
