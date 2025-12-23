local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:NewModule("Installer")

-- Sourced: NDui (siweia)
-- Edited: KkthnxUI (Kkthnx)

-- ====================================================
-- Local Variable Caching - Performance Optimization
-- ====================================================

-- Basic Lua functions
local _G = _G

-- Table functions
local tinsert = table.insert
local wipe = wipe

-- String functions
local format = format or string.format

-- Frame and UI Elements
local CreateFrame = CreateFrame
local UIParent = UIParent

-- Chat Functions and Variables
local ChatConfig_UpdateChatSettings = ChatConfig_UpdateChatSettings
local ChatFrame1_AddChannel = ChatFrame1.AddChannel
local ChatFrame1_AddMessageGroup = ChatFrame1.AddMessageGroup
local ChatFrame1_RemoveAllMessageGroups = ChatFrame1.RemoveAllMessageGroups
local ChatFrame1_RemoveChannel = ChatFrame1.RemoveChannel
local ChatTypeInfo = ChatTypeInfo
local FCF_DockFrame = FCF_DockFrame
local FCF_OpenNewWindow = FCF_OpenNewWindow
local FCF_ResetChatWindows = FCF_ResetChatWindows
local FCF_SavePositionAndDimensions = FCF_SavePositionAndDimensions
local FCF_SelectDockFrame = FCF_SelectDockFrame
local FCF_SetChatWindowFontSize = FCF_SetChatWindowFontSize
local FCF_SetLocked = FCF_SetLocked
local FCF_SetWindowName = FCF_SetWindowName
local FCF_StopDragging = FCF_StopDragging
local CHAT_FRAMES = CHAT_FRAMES

-- Game and System Settings
local C_Timer = C_Timer
local InCombatLockdown = InCombatLockdown
local PlaySound = PlaySound
local ReloadUI = ReloadUI
local SetCVar = SetCVar
local StaticPopup_Show = StaticPopup_Show
local StopSound = StopSound

-- Tooltips
local GameTooltip = GameTooltip

-- Constants and Miscellaneous
local APPLY = APPLY
local CHAT = CHAT
local COMPLETE = COMPLETE
local DECLINE = DECLINE
local DEFAULT = DEFAULT
local GENERAL = GENERAL
local RENOWN_LEVEL_UP_SKIP_BUTTON = RENOWN_LEVEL_UP_SKIP_BUTTON
local SETTINGS = SETTINGS
local START = START
local TRADE = TRADE
local UI_SCALE = UI_SCALE

-- Sound IDs
local SOUNDKIT_ACHIEVEMENT = 21968
local SOUNDKIT_UI_BNET_TOAST = 140268
local SOUNDKIT_READY_CHECK = 166318

-- ====================================================
-- Reusable Tables - Memory Management
-- ====================================================

local chatColorTypes = {}
local defaultCVarsCache = {}
local combatCVarsCache = {}
local developerCVarsCache = {}

-- ====================================================
-- Helper Functions
-- ====================================================

-- Apply CVars from a cached table
local function ApplyCVars(cvarTable)
	if not cvarTable or #cvarTable == 0 then
		return
	end

	for i = 1, #cvarTable do
		local cvar = cvarTable[i]
		SetCVar(cvar[1], cvar[2])
	end
end

-- Initialize CVar caches (called once)
local function InitializeCVarCaches()
	-- Only initialize once
	if #defaultCVarsCache > 0 then
		return
	end

	-- Default CVars
	defaultCVarsCache = {
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

	-- Combat CVars
	combatCVarsCache = {
		{ "nameplateShowEnemyMinions", 1 },
		{ "nameplateShowEnemyMinus", 1 },
		{ "nameplateShowFriendlyMinions", 0 },
		{ "nameplateShowFriends", 0 },
		{ "nameplateMotion", 1 },
		{ "nameplateShowAll", 1 },
		{ "nameplateShowEnemies", 1 },
		{ "alwaysShowActionBars", 1 },
	}

	-- Developer CVars
	developerCVarsCache = {
		{ "ffxGlow", 0 },
		{ "WorldTextScale", 1 },
		{ "SpellQueueWindow", 25 },
	}
end

-- ====================================================
-- Module Functions
-- ====================================================

function Module:ResetSettings()
	KkthnxUIDB.Settings[K.Realm][K.Name] = {}
end

function Module:ResetData()
	KkthnxUIDB.Variables[K.Realm][K.Name] = {}

	FCF_ResetChatWindows()

	if _G.ChatConfigFrame and _G.ChatConfigFrame:IsShown() then
		ChatConfig_UpdateChatSettings()
	end

	Module:ForceDefaultCVars()

	ReloadUI()
end

function Module:ForceDefaultCVars()
	-- Initialize caches if needed
	InitializeCVarCaches()

	-- Apply default CVars
	ApplyCVars(defaultCVarsCache)

	-- Apply combat-related CVars if not in combat
	if not InCombatLockdown() then
		ApplyCVars(combatCVarsCache)
	end

	-- Apply developer-specific CVars if K.isDeveloper is true
	if K.isDeveloper then
		ApplyCVars(developerCVarsCache)
	end
end

-- Reusable raid frame configuration
local function ForceRaidFrame()
	if InCombatLockdown() then
		return
	end

	if not _G.CompactUnitFrameProfiles then
		return
	end

	SetCVar("useCompactPartyFrames", 1)

	local profile = _G.CompactUnitFrameProfiles.selectedProfile
	_G.SetRaidProfileOption(profile, "useClassColors", true)
	_G.SetRaidProfileOption(profile, "displayPowerBar", true)
	_G.SetRaidProfileOption(profile, "displayBorder", false)
	_G.CompactUnitFrameProfiles_ApplyCurrentSettings()
	_G.CompactUnitFrameProfiles_UpdateCurrentPanel()
end

-- General message groups (cached)
local generalMessageGroups = {
	"SAY",
	"EMOTE",
	"YELL",
	"GUILD",
	"OFFICER",
	"GUILD_ACHIEVEMENT",
	"MONSTER_SAY",
	"MONSTER_EMOTE",
	"MONSTER_YELL",
	"MONSTER_WHISPER",
	"MONSTER_BOSS_EMOTE",
	"MONSTER_BOSS_WHISPER",
	"PARTY",
	"PARTY_LEADER",
	"RAID",
	"PING",
	"RAID_LEADER",
	"RAID_WARNING",
	"INSTANCE_CHAT",
	"INSTANCE_CHAT_LEADER",
	"BG_HORDE",
	"BG_ALLIANCE",
	"BG_NEUTRAL",
	"SYSTEM",
	"ERRORS",
	"AFK",
	"DND",
	"IGNORED",
	"ACHIEVEMENT",
}

function Module:ForceChatSettings()
	-- Reset chat windows
	FCF_ResetChatWindows()

	-- Set positions and fonts for all chat frames
	for i = 1, #CHAT_FRAMES do
		local frameName = CHAT_FRAMES[i]
		local frame = _G[frameName]
		if frame then
			local id = frame:GetID()

			-- Set the position for ChatFrame1 (General)
			if id == 1 then
				frame:ClearAllPoints()
				frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 7, 11)
			end

			-- Common configurations for all frames
			FCF_SetChatWindowFontSize(nil, frame, 12)
			FCF_SavePositionAndDimensions(frame)
			FCF_StopDragging(frame)
		end
	end

	-- Configure ChatFrame1 (General)
	local ChatFrame1 = _G.ChatFrame1
	FCF_SetLocked(ChatFrame1, true)
	FCF_SetWindowName(ChatFrame1, L["General"])
	ChatFrame1:Show()

	-- Remove channels and message groups from ChatFrame1
	ChatFrame1_RemoveAllMessageGroups(ChatFrame1)
	ChatFrame1_RemoveChannel(ChatFrame1, TRADE)
	ChatFrame1_RemoveChannel(ChatFrame1, GENERAL)
	ChatFrame1_RemoveChannel(ChatFrame1, "LocalDefense")
	ChatFrame1_RemoveChannel(ChatFrame1, "GuildRecruitment")
	ChatFrame1_RemoveChannel(ChatFrame1, "LookingForGroup")
	ChatFrame1_RemoveChannel(ChatFrame1, "Services")

	-- Add message groups to ChatFrame1
	for i = 1, #generalMessageGroups do
		ChatFrame1_AddMessageGroup(ChatFrame1, generalMessageGroups[i])
	end

	-- Configure ChatFrame2 (Combat Log)
	local ChatFrame2 = _G.ChatFrame2
	FCF_DockFrame(ChatFrame2)
	FCF_SetLocked(ChatFrame2, true)
	FCF_SetWindowName(ChatFrame2, L["Combat"])
	ChatFrame2:Show()

	-- Configure Whispers Window
	local Whispers = FCF_OpenNewWindow("Whispers")
	FCF_SetLocked(Whispers, true)
	FCF_DockFrame(Whispers)
	ChatFrame1_RemoveAllMessageGroups(Whispers)
	ChatFrame1_AddMessageGroup(Whispers, "WHISPER")
	ChatFrame1_AddMessageGroup(Whispers, "BN_WHISPER")
	ChatFrame1_AddMessageGroup(Whispers, "BN_CONVERSATION")

	-- Configure Trade Window
	local Trade = FCF_OpenNewWindow(L["Trade"])
	FCF_SetLocked(Trade, true)
	FCF_DockFrame(Trade)
	ChatFrame1_RemoveAllMessageGroups(Trade)
	ChatFrame1_AddChannel(Trade, TRADE)
	ChatFrame1_AddChannel(Trade, GENERAL)
	ChatFrame1_AddChannel(Trade, L["Services"])

	-- Configure Loot Window
	local Loot = FCF_OpenNewWindow(L["Loot"])
	FCF_SetLocked(Loot, true)
	FCF_DockFrame(Loot)
	ChatFrame1_RemoveAllMessageGroups(Loot)
	ChatFrame1_AddMessageGroup(Loot, "COMBAT_XP_GAIN")
	ChatFrame1_AddMessageGroup(Loot, "COMBAT_HONOR_GAIN")
	ChatFrame1_AddMessageGroup(Loot, "COMBAT_FACTION_CHANGE")
	ChatFrame1_AddMessageGroup(Loot, "LOOT")
	ChatFrame1_AddMessageGroup(Loot, "MONEY")
	ChatFrame1_AddMessageGroup(Loot, "SKILL")

	-- Finalize
	FCF_SelectDockFrame(ChatFrame1)

	-- Build class color chat types table (cached)
	if #chatColorTypes == 0 then
		wipe(chatColorTypes)
		local baseTypes = {
			"SAY",
			"YELL",
			"GUILD",
			"OFFICER",
			"WHISPER",
			"WHISPER_INFORM",
			"BN_WHISPER",
			"BN_WHISPER_INFORM",
			"PARTY",
			"PARTY_LEADER",
			"RAID",
			"RAID_LEADER",
			"RAID_WARNING",
			"INSTANCE_CHAT",
			"INSTANCE_CHAT_LEADER",
			"EMOTE",
			"CHANNEL",
			"GUILD_ACHIEVEMENT",
		}

		-- Add base types
		for i = 1, #baseTypes do
			tinsert(chatColorTypes, baseTypes[i])
		end

		-- Add channel types
		for i = 1, 20 do
			tinsert(chatColorTypes, "CHANNEL" .. i)
		end
	end

	-- Enable class color for chat types
	for i = 1, #chatColorTypes do
		local chatType = chatColorTypes[i]
		if ChatTypeInfo[chatType] then
			ChatTypeInfo[chatType].colorNameByClass = true
		end
	end
end

-- ====================================================
-- Fake Achievement Popup (Optimized)
-- ====================================================

local fakeAchievementPopup
local achievementAnimationGroup

local function CreateFakeAchievementPopup()
	if fakeAchievementPopup then
		return fakeAchievementPopup
	end

	local popup = CreateFrame("Frame", "KKUI_FakeAchievement", UIParent)
	popup:SetSize(310, 70)
	popup:SetPoint("TOP", UIParent, "TOP", 0, -150)
	popup:SetFrameStrata("DIALOG")
	popup:CreateBorder()
	popup:Hide()

	-- Achievement icon
	popup.icon = popup:CreateTexture(nil, "OVERLAY", nil, 6)
	popup.icon:SetSize(50, 50)
	popup.icon:SetPoint("LEFT", 10, 0)
	popup.icon:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\KkthnxUI_Spell_Icon")
	popup.icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])

	popup.iconFrame = CreateFrame("Frame", nil, popup)
	popup.iconFrame:SetAllPoints(popup.icon)
	popup.iconFrame:CreateBorder(nil, nil, nil, nil, nil, nil, "")

	-- Title
	popup.title = popup:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	popup.title:SetPoint("TOP", popup, "TOP", 0, 18)

	-- Description
	popup.description = popup:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	popup.description:SetPoint("LEFT", popup.icon, "RIGHT", 14, 0)
	popup.description:SetPoint("RIGHT", popup, "RIGHT", -8, 0)
	popup.description:SetJustifyH("LEFT")
	popup.description:SetWordWrap(true)

	-- Create animation group once and reuse
	achievementAnimationGroup = popup:CreateAnimationGroup()

	-- Move animation
	local move = achievementAnimationGroup:CreateAnimation("Translation")
	move:SetOffset(0, -50)
	move:SetDuration(0.5)
	move:SetSmoothing("OUT")

	-- Fade animation
	local fade = achievementAnimationGroup:CreateAnimation("Alpha")
	fade:SetFromAlpha(1)
	fade:SetToAlpha(0)
	fade:SetStartDelay(1.0)
	fade:SetDuration(1.5)
	fade:SetSmoothing("IN")

	achievementAnimationGroup:SetScript("OnFinished", function()
		popup:Hide()
	end)

	fakeAchievementPopup = popup
	return popup
end

local function ShowFakeAchievement(title, description)
	local popup = CreateFakeAchievementPopup()

	-- Stop any running animation
	if achievementAnimationGroup:IsPlaying() then
		achievementAnimationGroup:Stop()
	end

	popup.title:SetText(title)
	popup.description:SetText(description)
	popup:Show()

	-- Play animation
	achievementAnimationGroup:Play()
end

-- ====================================================
-- Tutorial Frame (Optimized)
-- ====================================================

local tutor
local tutorProgressBar
local tutorTicker
local currentPage = 0

-- Tutorial page titles (cached)
local tutorialTitles = {
	DEFAULT .. " " .. SETTINGS,
	CHAT,
	UI_SCALE,
	"Skins",
	"Tips",
}

-- Fallback tutorial text in case localization fails (color-coded, concise)
local tutorialFallbackText = {
	"|cff5C8BCFOptimize Game Settings|r\n\nApplies |cff4CAF50recommended settings|r:\n\n|cffFFD700• Nameplates, Camera, Combat Text, Raid Frames|r\n\n|cffFF6B6BNote:|r QoL improvements.\n\nClick |cff4CAF50'Apply'|r or |cffFF6B6B'Decline'|r.",
	"|cff5C8BCFOrganize Chat|r\n\nCreates |cff4CAF50five windows|r:\n\n|cffFFD700General, Combat, Whispers, Trade, Loot|r\n\n|cff4CAF50Bonus:|r Class colors!\n\nClick |cff4CAF50'Apply'|r or |cffFF6B6B'Decline'|r.",
	"|cff5C8BCFPerfect UI Scale|r\n\nCalculates |cff4CAF50optimal scale|r:\n\n• Perfect text size\n• Fits your screen\n• Comfortable play\n\nClick |cff4CAF50'Apply'|r or |cffFF6B6B'Decline'|r.",
	"|cff5C8BCFAddOn Integration|r\n\nOptimizes addons:\n\n|cffFFD700DBM, MaxDps, Hekili, CursorTrail|r\n\n|cff9E9E9EOptional feature|r\n\nClick |cff4CAF50'Apply'|r or |cffFF6B6B'Decline'|r.",
	"|cff4CAF50Complete!|r\n\n|cffFFD700Congrats!|r UI ready.\n\nType |cffFFD700/gui|r or |cffFFD700/khelp|r\n\nClick |cff4CAF50'Apply'|r to reload!",
}

local function RefreshTutorText(page)
	if not tutor or not tutor.title or not tutor.body then
		return
	end

	tutor.title:SetText(tutorialTitles[page])

	-- Use localization with fallback
	local bodyText = L["Tutorial Page" .. page] or tutorialFallbackText[page] or "No description available."
	tutor.body:SetText(bodyText)

	if tutorProgressBar then
		tutorProgressBar:SetValue(page * 100)
		tutorProgressBar:SetStatusBarColor(K.r, K.g, K.b)
		tutorProgressBar.text:SetText(page .. "/5")
	end
end

local function ApplyTutorialStep(page)
	if page == 1 then
		Module:ForceDefaultCVars()
		ForceRaidFrame()
		ShowFakeAchievement("Achievement Earned", "You have successfully applied the Default CVars.")
		PlaySound(SOUNDKIT_ACHIEVEMENT)
	elseif page == 2 then
		StopSound(SOUNDKIT_ACHIEVEMENT)
		Module:ForceChatSettings()
		ShowFakeAchievement("Achievement Earned", "You have successfully applied the Chat Frame Settings.")
		PlaySound(SOUNDKIT_ACHIEVEMENT)
	elseif page == 3 then
		StopSound(SOUNDKIT_ACHIEVEMENT)
		K:SetupUIScale()
		ShowFakeAchievement("Achievement Earned", "You have successfully applied the UIScale Settings.")
		PlaySound(SOUNDKIT_ACHIEVEMENT)
	elseif page == 4 then
		StopSound(SOUNDKIT_ACHIEVEMENT)
		local vars = KkthnxUIDB.Variables[K.Realm][K.Name]
		vars.DBMRequest = vars.DBMRequest or true
		vars.HekiliRequest = vars.HekiliRequest or true
		local getAddOnProfiles = K:GetModule("AddOns")
		if getAddOnProfiles then
			print("getAddOnProfiles found")
			K:GetModule("AddOns"):CreateAddOnProfiles()
		end
		ShowFakeAchievement("Achievement Earned", "You have successfully applied the relevant AddOn Settings.")
		PlaySound(SOUNDKIT_ACHIEVEMENT)
	elseif page == 5 then
		Module:ForceDefaultCVars() -- Set these one more time
		StopSound(SOUNDKIT_ACHIEVEMENT)
		StopSound(SOUNDKIT_UI_BNET_TOAST)
		KkthnxUIDB.Variables[K.Realm][K.Name].InstallComplete = true
		tutor:Hide()
		if tutorProgressBar then
			tutorProgressBar:Hide()
		end
		currentPage = 0
		PlaySound(SOUNDKIT_READY_CHECK)
		StaticPopup_Show("KKUI_CHANGES_RELOAD")
	end
end

local function StartCountdown(button, callback)
	if not button then
		return
	end

	-- Cancel any existing ticker
	if tutorTicker then
		tutorTicker:Cancel()
		tutorTicker = nil
	end

	button:Disable()
	local countdownTime = 3
	button.text:SetText(countdownTime)
	button.text:SetTextColor(1, 0, 0)

	tutorTicker = C_Timer.NewTicker(1, function()
		countdownTime = countdownTime - 1
		if countdownTime > 0 then
			button.text:SetText(countdownTime)
		else
			if callback then
				callback()
			end
			button:Enable()
			tutorTicker:Cancel()
			tutorTicker = nil
		end
	end, 3)
end

local function YesTutor()
	if tutor then
		tutor:Show()
		return
	end

	tutor = CreateFrame("Frame", nil, UIParent)
	tutor:SetPoint("CENTER")
	tutor:SetSize(480, 280)
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

	tutor.title = K.CreateFontString(tutor, 14, "", "", true, "TOP", 0, -10)
	tutor.body = K.CreateFontString(tutor, 12, "", "", false, "TOPLEFT", 20, -40)
	tutor.body:SetPoint("BOTTOMRIGHT", -20, 45)
	tutor.body:SetJustifyV("TOP")
	tutor.body:SetJustifyH("LEFT")
	tutor.body:SetWordWrap(true)
	tutor.body:SetSpacing(2)

	tutorProgressBar = CreateFrame("StatusBar", nil, tutor)
	tutorProgressBar:SetMinMaxValues(0, 500)
	tutorProgressBar:SetValue(0)
	tutorProgressBar:CreateBorder()
	tutorProgressBar:SetPoint("TOP", tutor, "BOTTOM", 0, -6)
	tutorProgressBar:SetSize(480, 22)
	tutorProgressBar:SetStatusBarTexture(K.GetTexture(C["General"].Texture))
	K:SmoothBar(tutorProgressBar)

	tutorProgressBar.text = K.CreateFontString(tutorProgressBar, 13, "", "", false, "CENTER", 0, -1)

	tutorProgressBar.spark = tutorProgressBar:CreateTexture(nil, "OVERLAY")
	tutorProgressBar.spark:SetWidth(64)
	tutorProgressBar.spark:SetHeight(tutorProgressBar:GetHeight())
	tutorProgressBar.spark:SetTexture(C["Media"].Textures.Spark128Texture)
	tutorProgressBar.spark:SetBlendMode("ADD")
	tutorProgressBar.spark:SetPoint("CENTER", tutorProgressBar:GetStatusBarTexture(), "RIGHT", 0, 0)
	tutorProgressBar.spark:SetAlpha(0.6)

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

	currentPage = 1
	RefreshTutorText(currentPage)

	pass:SetScript("OnClick", function()
		if currentPage > 3 then
			pass:Hide()
		end

		currentPage = currentPage + 1
		RefreshTutorText(currentPage)
		StopSound(SOUNDKIT_ACHIEVEMENT)
		StopSound(SOUNDKIT_UI_BNET_TOAST)
		PlaySound(SOUNDKIT_UI_BNET_TOAST)
	end)

	apply:SetScript("OnClick", function()
		StartCountdown(apply, function()
			apply:ClearAllPoints()
			if currentPage < 5 then
				apply.text:SetText(APPLY)
				apply:SetPoint("BOTTOMRIGHT", -10, 10)
				pass:Show()
			else
				apply:SetPoint("BOTTOM", 0, 10)
				apply.text:SetText(COMPLETE)
				pass:Hide()
			end
			apply.text:SetTextColor(0, 1, 0)
		end)

		ApplyTutorialStep(currentPage)

		currentPage = currentPage + 1
		RefreshTutorText(currentPage)
	end)
end

-- ====================================================
-- Welcome Frame (Optimized)
-- ====================================================

local welcome

local function CreateSocialButton(parent, point, relativePoint, xOffset, yOffset, text, color, link)
	local button = CreateFrame("Button", nil, parent)
	button:SetPoint(point, relativePoint, xOffset, yOffset)
	button:SetSize(90, 22)
	button:SkinButton()

	button.text = button:CreateFontString(nil, "OVERLAY")
	button.text:SetFontObject(K.UIFont)
	button.text:SetPoint("CENTER")
	button.text:SetText(color .. text .. "|r")

	button:SetScript("OnClick", function()
		StaticPopup_Show("KKUI_POPUP_LINK", nil, nil, link)
	end)

	return button
end

local function HelloWorld()
	if welcome then
		welcome:Show()
		return
	end

	welcome = CreateFrame("Frame", "KKUI_Tutorial", UIParent)
	welcome:SetPoint("CENTER")
	welcome:SetSize(470, 430)
	welcome:SetFrameStrata("HIGH")
	K.CreateMoverFrame(welcome)
	welcome:CreateBorder()

	-- Welcome title with player name
	K.CreateFontString(welcome, 16, format(L["Installer Welcome"], K.Name .. "|r"), "", true, "TOP", 0, -10)

	local ll = CreateFrame("Frame", nil, welcome)
	ll:SetPoint("TOP", -50, -38)
	K.CreateGF(ll, 100, 1, "Horizontal", 0.7, 0.7, 0.7, 0, 0.7)
	ll:SetFrameStrata("HIGH")

	local lr = CreateFrame("Frame", nil, welcome)
	lr:SetPoint("TOP", 50, -38)
	K.CreateGF(lr, 100, 1, "Horizontal", 0.7, 0.7, 0.7, 0.7, 0)
	lr:SetFrameStrata("HIGH")

	-- Thank you message with version
	K.CreateFontString(welcome, 14, format(L["Installer Thank You"], K.SystemColor .. K.Version .. "|r"), "", false, "TOP", 0, -50)

	-- Description lines
	K.CreateFontString(welcome, 13, L["Installer Description Line 1"], "", false, "TOP", 0, -86)
	K.CreateFontString(welcome, 13, L["Installer Description Line 2"], "", false, "TOP", 0, -106)
	K.CreateFontString(welcome, 13, L["Installer Description Line 3"], "", false, "TOP", 0, -126)

	-- Community section
	K.CreateFontString(welcome, 16, L["Installer Join Community"], "", false, "TOP", 0, -155)
	K.CreateFontString(welcome, 12, L["Installer Community Line 1"], "", false, "TOP", 0, -178)
	K.CreateFontString(welcome, 12, L["Installer Community Line 2"], "", false, "TOP", 0, -196)
	K.CreateFontString(welcome, 12, L["Installer Community Line 3"], "", false, "TOP", 0, -214)
	K.CreateFontString(welcome, 12, L["Installer Community Line 4"], "", false, "TOP", 0, -232)
	K.CreateFontString(welcome, 12, L["Installer Community Line 5"], "", false, "TOP", 0, -250)
	K.CreateFontString(welcome, 12, L["Installer Community Line 6"], "", false, "TOP", 0, -268)

	local ll2 = CreateFrame("Frame", nil, welcome)
	ll2:SetPoint("TOP", welcome, -90, -292)
	K.CreateGF(ll2, 180, 1, "Horizontal", 0.7, 0.7, 0.7, 0, 0.7)
	ll2:SetFrameStrata("HIGH")

	local lr2 = CreateFrame("Frame", nil, welcome)
	lr2:SetPoint("TOP", welcome, 90, -292)
	K.CreateGF(lr2, 180, 1, "Horizontal", 0.7, 0.7, 0.7, 0.7, 0)
	lr2:SetFrameStrata("HIGH")

	-- First time user instructions
	K.CreateFontString(welcome, 12, L["Installer First Time Line 1"], "", false, "BOTTOM", 0, 112)
	K.CreateFontString(welcome, 12, L["Installer First Time Line 2"], "", false, "BOTTOM", 0, 94)

	if KkthnxUIDB.Variables[K.Realm][K.Name].InstallComplete or K.isDeveloper then
		local close = CreateFrame("Button", nil, welcome)
		close:SetPoint("TOPRIGHT", 4, 4)
		close:SetSize(32, 32)
		close:SkinCloseButton()
		close:SetScript("OnClick", function()
			welcome:Hide()
		end)
	end

	local goTutor = CreateFrame("Button", nil, welcome)
	goTutor:SetPoint("BOTTOM", -58, 10)
	goTutor:SetSize(110, 22)
	goTutor:SkinButton()

	goTutor.text = goTutor:CreateFontString(nil, "OVERLAY")
	goTutor.text:SetFontObject(K.UIFont)
	goTutor.text:SetPoint("CENTER", 0, -1)
	goTutor.text:SetText(K.MyClassColor .. START .. "|r")

	goTutor:SetScript("OnClick", function()
		welcome:Hide()
		YesTutor()
	end)

	local goSkip = CreateFrame("Button", nil, welcome)
	goSkip:SetPoint("BOTTOM", 58, 10)
	goSkip:SetSize(110, 22)
	goSkip:SkinButton()

	goSkip.text = goSkip:CreateFontString(nil, "OVERLAY")
	goSkip.text:SetFontObject(K.UIFont)
	goSkip.text:SetPoint("CENTER", 0, -1)
	goSkip.text:SetText(K.MyClassColor .. RENOWN_LEVEL_UP_SKIP_BUTTON .. "|r")

	goSkip:SetScript("OnClick", function()
		Module:ForceDefaultCVars()
		ForceRaidFrame()
		Module:ForceChatSettings()
		K:SetupUIScale()
		local vars = KkthnxUIDB.Variables[K.Realm][K.Name]
		vars.DBMRequest = vars.DBMRequest or true
		vars.HekiliRequest = vars.HekiliRequest or true
		local getAddOnProfiles = K:GetModule("AddOns")
		if getAddOnProfiles then
			print("getAddOnProfiles found")
			K:GetModule("AddOns"):CreateAddOnProfiles()
		end
		vars.InstallComplete = true
		StaticPopup_Show("SKIP_INSTALLER_CONFIRM")
	end)

	goSkip:HookScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(L["Installer Skip Tooltip Title"], 1, 0.82, 0)
		GameTooltip:AddLine(L["Installer Skip Tooltip Desc"], 1, 1, 1, true)
		GameTooltip:Show()
	end)

	goSkip:HookScript("OnLeave", function()
		GameTooltip:Hide()
	end)

	-- Social buttons using helper function
	local goDiscord = CreateSocialButton(welcome, "TOPLEFT", goTutor, -30, 40, "Discord", "|CFF7289da", "https://discord.gg/Rc9wcK9cAB")
	local goPaypal = CreateSocialButton(welcome, "LEFT", goDiscord, 96, 0, "Paypal", "|CFF0079C1", "https://www.paypal.com/paypalme/KkthnxTV")
	local goPatreon = CreateSocialButton(welcome, "LEFT", goPaypal, 96, 0, "Patreon", "|CFFf96854", "https://www.patreon.com/kkthnx")
end

-- ====================================================
-- Slash Command and OnEnable
-- ====================================================

_G.SlashCmdList["KKUI_INSTALLER"] = HelloWorld
_G.SLASH_KKUI_INSTALLER1 = "/install"

function Module:OnEnable()
	if not KkthnxUIDB.Variables[K.Realm][K.Name].InstallComplete then
		print(K.Title .. " " .. K.GreyColor .. K.Version .. "|r " .. K.SystemColor .. K.Client .. "|r")
		HelloWorld()
	end
end
