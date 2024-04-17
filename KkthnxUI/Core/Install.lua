local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:NewModule("Installer")

-- Sourced: NDui (siweia)
-- Edited: KkthnxUI (Kkthnx)

-- Frame and UI Elements
local CreateFrame = CreateFrame
local UIParent = UIParent
local UIErrorsFrame = UIErrorsFrame

-- Chat Functions and Variables
local ChangeChatColor = ChangeChatColor
local ChatConfig_UpdateChatSettings = ChatConfig_UpdateChatSettings
local ChatFrame_AddMessageGroup = ChatFrame_AddMessageGroup
local ChatFrame_RemoveAllMessageGroups = ChatFrame_RemoveAllMessageGroups
local ChatFrame_RemoveChannel = ChatFrame_RemoveChannel
local FCF_DockFrame = FCF_DockFrame
local FCF_OpenNewWindow = FCF_OpenNewWindow
local FCF_ResetChatWindows = FCF_ResetChatWindows
local FCF_SetChatWindowFontSize = FCF_SetChatWindowFontSize
local FCF_SetLocked = FCF_SetLocked
local FCF_SetWindowName = FCF_SetWindowName
local ToggleChatColorNamesByClassGroup = ToggleChatColorNamesByClassGroup

-- Game and System Settings
local InCombatLockdown = InCombatLockdown
local PlaySound = PlaySound
local SetCVar = SetCVar

-- Constants and Miscellaneous
local APPLY = APPLY
local CHAT = CHAT
local DEFAULT = DEFAULT
local GENERAL = GENERAL
local SETTINGS = SETTINGS
local TRADE = TRADE
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
	local defaultCVars = {
		{ "RotateMinimap", 0 },
		{ "ShowClassColorInNameplate", 1 },
		{ "UberTooltips", 1 },
		{ "WholeChatWindowClickable", 0 },
		{ "alwaysCompareItems", 1 },
		{ "autoLootDefault", 1 },
		{ "autoOpenLootHistory", 0 },
		{ "autoQuestProgress", 1 },
		{ "autoQuestWatch", 1 },
		{ "autoSelfCast", 1 },
		{ "buffDurations", 1 },
		{ "cameraDistanceMaxZoomFactor", 2.6 },
		{ "cameraSmoothStyle", 0 },
		{ "colorblindMode", 0 },
		{ "floatingCombatTextCombatDamage", 1 },
		{ "floatingCombatTextCombatDamageDirectionalOffset", 10 },
		{ "floatingCombatTextCombatDamageDirectionalScale", 0 },
		{ "floatingCombatTextCombatHealing", 1 },
		{ "floatingCombatTextFloatMode", 1 },
		{ "gameTip", 0 },
		{ "instantQuestText", 1 },
		{ "lockActionBars", 1 },
		{ "lootUnderMouse", 1 },
		{ "lossOfControl", 0 },
		{ "overrideArchive", 0 },
		{ "profanityFilter", 0 },
		{ "removeChatDelay", 1 },
		{ "screenshotQuality", 10 },
		{ "scriptErrors", 1 },
		{ "showArenaEnemyFrames", 0 },
		{ "showLootSpam", 1 },
		{ "showTutorials", 0 },
		{ "showVKeyCastbar", 1 },
		{ "spamFilter", 0 },
		{ "taintLog", 0 },
		{ "violenceLevel", 5 },
		{ "whisperMode", "inline" },
		{ "ActionButtonUseKeyDown", 1 },
		{ "fstack_preferParentKeys", 0 },
		{ "showNPETutorials", 0 },
		{ "statusTextDisplay", "BOTH" },
		{ "threatWarning", 3 },
	}

	local combatCVars = {
		{ "nameplateShowEnemyMinions", 1 },
		{ "nameplateShowEnemyMinus", 1 },
		{ "nameplateShowFriendlyMinions", 0 },
		{ "nameplateShowFriends", 0 },
		{ "nameplateMotion", 1 },
		{ "nameplateShowAll", 1 },
		{ "nameplateShowEnemies", 1 },
		{ "alwaysShowActionBars", 1 },
	}

	local developerCVars = {
		{ "ffxGlow", 0 },
		{ "WorldTextScale", 1 },
		{ "SpellQueueWindow", 25 },
	}

	-- Apply default CVars
	for _, cvar in pairs(defaultCVars) do
		SetCVar(cvar[1], cvar[2])
		-- print("SetCVar - Default: " .. cvar[1] .. " to " .. tostring(cvar[2]))
	end

	-- Apply combat-related CVars if not in combat
	if not InCombatLockdown() then
		for _, cvar in pairs(combatCVars) do
			SetCVar(cvar[1], cvar[2])
			-- print("SetCVar - Combat: " .. cvar[1] .. " to " .. tostring(cvar[2]))
		end
	else
		print("Skipped setting combat CVars due to combat lockdown.")
	end

	-- Apply developer-specific CVars if K.isDeveloper is true
	if K.isDeveloper then
		for _, cvar in pairs(developerCVars) do
			SetCVar(cvar[1], cvar[2])
			-- print("SetCVar - Developer: " .. cvar[1] .. " to " .. tostring(cvar[2]))
		end
	else
		print("Skipped setting developer CVars as K.isDeveloper is not true.")
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
	local function resetAndConfigureChatFrames()
		FCF_ResetChatWindows()

		for _, name in ipairs(_G.CHAT_FRAMES) do
			local frame = _G[name]
			local id = frame:GetID()

			-- Configure specific frames based on their IDs
			if id == 1 then
				frame:ClearAllPoints()
				frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 7, 11)
			elseif id == 2 then
				FCF_SetWindowName(frame, L["CombatLog"])
			elseif id == 3 then
				-- Voice transcription specific settings
				VoiceTranscriptionFrame_UpdateVisibility(frame)
				VoiceTranscriptionFrame_UpdateVoiceTab(frame)
				VoiceTranscriptionFrame_UpdateEditBox(frame)
			end

			-- Common configuration for all frames
			FCF_SetChatWindowFontSize(nil, frame, 12)
			FCF_SavePositionAndDimensions(frame)
			FCF_StopDragging(frame)
		end
	end

	local function configureChatFrame(chatFrame, windowName, removeChannels, messageGroups, isDocked)
		-- Configuration for individual chat frames
		if isDocked then
			FCF_DockFrame(chatFrame)
		else
			FCF_OpenNewWindow(windowName)
		end

		FCF_SetLocked(chatFrame, 1)
		FCF_SetWindowName(chatFrame, windowName)
		chatFrame:Show()

		-- Remove specified channels and add message groups
		for _, channel in ipairs(removeChannels or {}) do
			ChatFrame_RemoveChannel(chatFrame, channel)
		end

		ChatFrame_RemoveAllMessageGroups(chatFrame)
		for _, group in ipairs(messageGroups) do
			ChatFrame_AddMessageGroup(chatFrame, group)
		end
	end

	local function configureChatColors()
		-- Set specific colors for chat channels
		ChangeChatColor("CHANNEL1", 195 / 255, 230 / 255, 232 / 255) -- General
		ChangeChatColor("CHANNEL2", 232 / 255, 158 / 255, 121 / 255) -- Trade
		ChangeChatColor("CHANNEL3", 232 / 255, 228 / 255, 121 / 255) -- Local Defense
	end

	local function enableClassColors(chatGroups)
		-- Enable class colors for specified chat groups
		for _, group in ipairs(chatGroups) do
			ToggleChatColorNamesByClassGroup(true, group)
		end
	end

	-- Apply configurations
	resetAndConfigureChatFrames()

	-- Configure specific chat frames
	configureChatFrame(
		ChatFrame1,
		L["General"],
		{ TRADE, L["Services"], GENERAL, "GuildRecruitment", "LookingForGroup" },
		{
			"ACHIEVEMENT",
			"AFK",
			"BG_ALLIANCE",
			"BG_HORDE",
			"BG_NEUTRAL",
			"BN_INLINE_TOAST_ALERT",
			"CHANNEL",
			"DND",
			"EMOTE",
			"ERRORS",
			"GUILD",
			"GUILD_ACHIEVEMENT",
			"IGNORED",
			"INSTANCE_CHAT",
			"INSTANCE_CHAT_LEADER",
			"MONSTER_BOSS_EMOTE",
			"MONSTER_BOSS_WHISPER",
			"MONSTER_EMOTE",
			"MONSTER_SAY",
			"MONSTER_WHISPER",
			"MONSTER_YELL",
			"OFFICER",
			"PARTY",
			"PARTY_LEADER",
			"RAID",
			"RAID_LEADER",
			"RAID_WARNING",
			"SAY",
			"SYSTEM",
			"YELL",
		}
	)
	configureChatFrame(ChatFrame2, L["CombatLog"], nil, {}, true)
	configureChatFrame(ChatFrame4, L["Whisper"], nil, { "WHISPER", "BN_WHISPER", "BN_CONVERSATION" }, true)
	configureChatFrame(ChatFrame5, L["Trade"], nil, {}, true)
	configureChatFrame(
		ChatFrame6,
		L["Loot"],
		nil,
		{ "COMBAT_XP_GAIN", "COMBAT_HONOR_GAIN", "COMBAT_FACTION_CHANGE", "SKILL", "LOOT", "CURRENCY", "MONEY" },
		true
	)

	configureChatColors()

	local classColorGroups = {
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
	local maxChatChannels = _G.MAX_WOW_CHAT_CHANNELS or 10 -- Fallback in case the global isn't set
	for i = 1, maxChatChannels do
		table.insert(classColorGroups, "CHANNEL" .. i)
	end
	enableClassColors(classColorGroups)
end

local function CreateFakeAchievementPopup()
	local popup = CreateFrame("Frame", "KkthnxUIFakeAchievement", UIParent, "GlowBoxTemplate")
	popup:SetSize(300, 70) -- Size similar to the achievement frame
	popup:SetPoint("TOP", UIParent, "TOP", 0, -150)
	popup:SetFrameStrata("DIALOG")
	popup:Hide() -- Hide the frame initially

	-- Background texture
	popup.bg = popup:CreateTexture(nil, "BACKGROUND")
	popup.bg:SetTexture("Interface\\AchievementFrame\\UI-Achievement-AchievementBackground")
	popup.bg:SetPoint("CENTER")
	popup.bg:SetSize(296, 66)
	popup.bg:SetTexCoord(0, 1, 0, 0.28125)

	-- Achievement icon
	popup.icon = popup:CreateTexture(nil, "OVERLAY")
	popup.icon:SetSize(44, 44)
	popup.icon:SetPoint("LEFT", 8, 0)
	popup.icon:SetTexture("Interface\\Icons\\Achievement_General") -- Placeholder texture

	-- Assuming you have already created 'popup.icon' before this
	popup.iconFrame = popup:CreateTexture(nil, "OVERLAY", nil, 6)
	popup.iconFrame:SetSize(56, 56) -- Adjust the size as needed to fit around the icon
	popup.iconFrame:SetPoint("CENTER", popup.icon, "CENTER", 0, 0)
	popup.iconFrame:SetTexture("Interface\\AchievementFrame\\UI-Achievement-IconFrame")
	popup.iconFrame:SetTexCoord(0, 0.5625, 0, 0.5625) -- Adjust if needed to get the correct part of the texture

	-- Title
	popup.title = popup:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	popup.title:SetPoint("TOP", popup.bg, "TOP", 0, 18)

	-- Description
	popup.description = popup:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	popup.description:SetPoint("LEFT", popup.icon, "RIGHT", 8, 0) -- 8 is the padding from the icon, adjust as needed
	popup.description:SetPoint("RIGHT", popup.bg, "RIGHT", -8, 0) -- -8 is the padding from the right edge, adjust as needed
	popup.description:SetJustifyH("LEFT") -- Align text to the left
	popup.description:SetWordWrap(true) -- Enable word wrapping

	-- Animation code
	popup:SetScript("OnShow", function(self)
		local anim = self:CreateAnimationGroup()

		-- Move animation
		local move = anim:CreateAnimation("Translation")
		move:SetOffset(0, -50)
		move:SetDuration(0.5)
		move:SetSmoothing("OUT")

		-- Fade animation
		local fade = anim:CreateAnimation("Alpha")
		fade:SetFromAlpha(1)
		fade:SetToAlpha(0)
		fade:SetStartDelay(1.0) -- Reduced start delay by 1.5 seconds
		fade:SetDuration(1.5)
		fade:SetSmoothing("IN")

		anim:SetScript("OnFinished", function()
			self:Hide()
		end)
		anim:Play()
	end)

	return popup
end
local fakeAchievementPopup = CreateFakeAchievementPopup()

local function ShowFakeAchievement(title, description)
	fakeAchievementPopup.title:SetText(title)
	fakeAchievementPopup.description:SetText(description)
	fakeAchievementPopup:Show()
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
		-- Disable the apply button and start the countdown
		apply:Disable()
		local countdownTime = 3 -- Give it 1 second so the player can not spam the installer! :D
		apply.text:SetText(countdownTime)
		apply.text:SetTextColor(1, 0, 0) -- Set text color to red

		local ticker
		ticker = C_Timer.NewTicker(1, function()
			countdownTime = countdownTime - 1
			if countdownTime > 0 then
				apply.text:SetText(countdownTime)
			else
				apply:ClearAllPoints()
				if currentPage < 5 then
					apply.text:SetText(APPLY)
				else
					apply:SetPoint("BOTTOM", 0, 10)
					apply.text:SetText(COMPLETE)
				end
				apply.text:SetTextColor(0, 1, 0) -- Set text color back to green
				apply:Enable()
				ticker:Cancel()
			end
		end, countdownTime)

		pass:Show()
		if currentPage == 1 then
			Module:ForceDefaultCVars()
			ForceRaidFrame()
			ShowFakeAchievement("Achievement Earned", "You have successfully applied the Default CVars.")
			PlaySound(21968)
		elseif currentPage == 2 then
			StopSound(21968)
			Module:ForceChatSettings()
			ShowFakeAchievement("Achievement Earned", "You have successfully applied the Chat Frame Settings.")
			PlaySound(21968)
		elseif currentPage == 3 then
			StopSound(21968)
			K.SetupUIScale(true)
			ShowFakeAchievement("Achievement Earned", "You have successfully applied the UIScale Settings.")
			PlaySound(21968)
		elseif currentPage == 4 then
			StopSound(21968)
			KkthnxUIDB.Variables[K.Realm][K.Name].DBMRequest = KkthnxUIDB.Variables[K.Realm][K.Name].DBMRequest or true
			KkthnxUIDB.Variables[K.Realm][K.Name].MaxDpsRequest = KkthnxUIDB.Variables[K.Realm][K.Name].MaxDpsRequest
				or true
			KkthnxUIDB.Variables[K.Realm][K.Name].CursorTrailRequest = KkthnxUIDB.Variables[K.Realm][K.Name].CursorTrailRequest
				or true
			KkthnxUIDB.Variables[K.Realm][K.Name].HekiliRequest = KkthnxUIDB.Variables[K.Realm][K.Name].HekiliRequest
				or true
			Module.ForceAddonSkins()
			ShowFakeAchievement("Achievement Earned", "You have successfully applied the relevant AddOn Settings.")
			pass:Hide()
			PlaySound(21968)
		elseif currentPage == 5 then
			Module:ForceDefaultCVars() -- Set these one more time
			StopSound(21968)
			StopSound(140268)
			KkthnxUIDB.Variables[K.Realm][K.Name].InstallComplete = KkthnxUIDB.Variables[K.Realm][K.Name].InstallComplete
				or true
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
	welcomeBoss:SetTexture("Interface\\ENCOUNTERJOURNAL\\UI-EJ-BOSS-Fyrakk the Burning")
	welcomeBoss:SetPoint("TOPRIGHT", welcome, "TOPRIGHT", 10, 64)

	local ll = CreateFrame("Frame", nil, welcome)
	ll:SetPoint("TOP", -50, -35)
	K.CreateGF(ll, 100, 1, "Horizontal", 0.7, 0.7, 0.7, 0, 0.7)
	ll:SetFrameStrata("HIGH")

	local lr = CreateFrame("Frame", nil, welcome)
	lr:SetPoint("TOP", 50, -35)
	K.CreateGF(lr, 100, 1, "Horizontal", 0.7, 0.7, 0.7, 0.7, 0)
	lr:SetFrameStrata("HIGH")

	K.CreateFontString(
		welcome,
		14,
		"Thank you for choosing |cff669dffKkthnxUI|r, v" .. K.SystemColor .. K.Version .. "|r!",
		"",
		false,
		"TOP",
		0,
		-50
	)
	K.CreateFontString(
		welcome,
		13,
		"|cff669dffKkthnxUI|r is a simplistic user interface that holds",
		"",
		false,
		"TOP",
		0,
		-86
	)
	K.CreateFontString(
		welcome,
		13,
		"onto the information and functionality, while still keeping",
		"",
		false,
		"TOP",
		0,
		-106
	)
	K.CreateFontString(
		welcome,
		13,
		"most of the good looks. It can be used for any class or role.",
		"",
		false,
		"TOP",
		0,
		-126
	)

	K.CreateFontString(welcome, 16, "|cff669dffJoin The Community!|r", "", false, "TOP", 0, -160)
	K.CreateFontString(welcome, 13, "There are thousands of users, but most are content", "", false, "TOP", 0, -180)

	K.CreateFontString(
		welcome,
		13,
		"to simply download and use the interface without further",
		"",
		false,
		"TOP",
		0,
		-200
	)
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

	K.CreateFontString(
		welcome,
		13,
		"If this is your first time using |cff669dffKkthnxUI|r,",
		"",
		false,
		"BOTTOM",
		0,
		130
	)
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
	goTutor:SetSize(110, 22)
	goTutor:SkinButton()

	if welcome:IsShown() then
		K.ShowOverlayGlow(goTutor, "AutoCastGlow")
	end

	goTutor.text = goTutor:CreateFontString(nil, "OVERLAY")
	goTutor.text:SetFontObject(K.UIFont)
	goTutor.text:SetPoint("CENTER", 0, -1)
	goTutor.text:SetText(K.MyClassColor .. START .. "|r")

	goTutor:SetScript("OnClick", function()
		K.HideOverlayGlow(goTutor, "AutoCastGlow")
		welcome:Hide()
		YesTutor()
	end)

	local goTwitch = CreateFrame("Button", nil, welcome)
	goTwitch:SetPoint("BOTTOMLEFT", 21, 50)
	goTwitch:SetSize(90, 20)
	goTwitch:SkinButton()

	goTwitch.text = goTwitch:CreateFontString(nil, "OVERLAY")
	goTwitch.text:SetFontObject(K.UIFont)
	goTwitch.text:SetPoint("CENTER")
	goTwitch.text:SetText("|CFF8F76BDTwitch|r")

	goTwitch:SetScript("OnClick", function()
		StaticPopup_Show("KKUI_POPUP_LINK", nil, nil, "https://www.twitch.tv/kkthnxtv")
	end)

	local goDiscord = CreateFrame("Button", nil, welcome)
	goDiscord:SetPoint("LEFT", goTwitch, "RIGHT", 6, 0)
	goDiscord:SetSize(90, 22)
	goDiscord:SkinButton()

	goDiscord.text = goDiscord:CreateFontString(nil, "OVERLAY")
	goDiscord.text:SetFontObject(K.UIFont)
	goDiscord.text:SetPoint("CENTER")
	goDiscord.text:SetText("|CFF7289daDiscord|r")

	goDiscord:SetScript("OnClick", function()
		StaticPopup_Show("KKUI_POPUP_LINK", nil, nil, "https://discord.gg/Rc9wcK9cAB")
	end)

	local goPaypal = CreateFrame("Button", nil, welcome)
	goPaypal:SetPoint("LEFT", goDiscord, "RIGHT", 6, 0)
	goPaypal:SetSize(90, 22)
	goPaypal:SkinButton()

	goPaypal.text = goPaypal:CreateFontString(nil, "OVERLAY")
	goPaypal.text:SetFontObject(K.UIFont)
	goPaypal.text:SetPoint("CENTER")
	goPaypal.text:SetText("|CFF0079C1Paypal|r")

	goPaypal:SetScript("OnClick", function()
		StaticPopup_Show("KKUI_POPUP_LINK", nil, nil, "https://www.paypal.com/paypalme/KkthnxTV")
	end)

	local goPatreon = CreateFrame("Button", nil, welcome)
	goPatreon:SetPoint("LEFT", goPaypal, "RIGHT", 6, 0)
	goPatreon:SetSize(90, 22)
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
