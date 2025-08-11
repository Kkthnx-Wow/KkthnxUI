local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:NewModule("Installer")

-- Sourced: NDui (siweia)
-- Edited: KkthnxUI (Kkthnx)

-- Frame and UI Elements
local CreateFrame = CreateFrame
local UIParent = UIParent

-- Chat Functions and Variables
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
	end

	-- Apply combat-related CVars if not in combat
	if not InCombatLockdown() then
		for _, cvar in pairs(combatCVars) do
			SetCVar(cvar[1], cvar[2])
		end
	else
		print("Skipped setting combat CVars due to combat lockdown.")
	end

	-- Apply developer-specific CVars if K.isDeveloper is true
	if K.isDeveloper then
		for _, cvar in pairs(developerCVars) do
			SetCVar(cvar[1], cvar[2])
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
	-- General
	FCF_ResetChatWindows()

	-- Set positions and fonts for all chat frames
	for _, name in ipairs(_G.CHAT_FRAMES) do
		local frame = _G[name]
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

	-- Lock and configure ChatFrame1 (General)
	FCF_SetLocked(ChatFrame1, true)
	FCF_SetWindowName(ChatFrame1, L["General"])
	ChatFrame1:Show()

	-- Remove channels and message groups from ChatFrame1
	ChatFrame_RemoveAllMessageGroups(ChatFrame1)
	ChatFrame_RemoveChannel(ChatFrame1, TRADE)
	ChatFrame_RemoveChannel(ChatFrame1, GENERAL)
	ChatFrame_RemoveChannel(ChatFrame1, "LocalDefense")
	ChatFrame_RemoveChannel(ChatFrame1, "GuildRecruitment")
	ChatFrame_RemoveChannel(ChatFrame1, "LookingForGroup")
	ChatFrame_RemoveChannel(ChatFrame1, "Services")

	-- Add message groups to ChatFrame1
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
	for _, group in ipairs(generalMessageGroups) do
		ChatFrame_AddMessageGroup(ChatFrame1, group)
	end

	-- Configure ChatFrame2 (Combat Log)
	FCF_DockFrame(ChatFrame2)
	FCF_SetLocked(ChatFrame2, true)
	FCF_SetWindowName(ChatFrame2, L["Combat"])
	ChatFrame2:Show()

	-- Configure Whispers Window
	local Whispers = FCF_OpenNewWindow("Whispers")
	FCF_SetLocked(Whispers, true)
	FCF_DockFrame(Whispers)
	ChatFrame_RemoveAllMessageGroups(Whispers)
	ChatFrame_AddMessageGroup(Whispers, "WHISPER")
	ChatFrame_AddMessageGroup(Whispers, "BN_WHISPER")
	ChatFrame_AddMessageGroup(Whispers, "BN_CONVERSATION")

	-- Configure Trade Window
	local Trade = FCF_OpenNewWindow(L["Trade"])
	FCF_SetLocked(Trade, true)
	FCF_DockFrame(Trade)
	ChatFrame_RemoveAllMessageGroups(Trade)
	ChatFrame_AddChannel(Trade, TRADE)
	ChatFrame_AddChannel(Trade, GENERAL)
	ChatFrame_AddChannel(Trade, L["Services"])

	-- Configure Loot Window
	local Loot = FCF_OpenNewWindow(L["Loot"])
	FCF_SetLocked(Loot, true)
	FCF_DockFrame(Loot)
	ChatFrame_RemoveAllMessageGroups(Loot)
	ChatFrame_AddMessageGroup(Loot, "COMBAT_XP_GAIN")
	ChatFrame_AddMessageGroup(Loot, "COMBAT_HONOR_GAIN")
	ChatFrame_AddMessageGroup(Loot, "COMBAT_FACTION_CHANGE")
	ChatFrame_AddMessageGroup(Loot, "LOOT")
	ChatFrame_AddMessageGroup(Loot, "MONEY")
	ChatFrame_AddMessageGroup(Loot, "SKILL")

	-- Finalize
	FCF_SelectDockFrame(ChatFrame1)

	-- Enable class color for chat types
	local classColorChatTypes = {
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
	for i = 1, 20 do
		table.insert(classColorChatTypes, "CHANNEL" .. i)
	end

	for _, chatType in ipairs(classColorChatTypes) do
		ChatTypeInfo[chatType].colorNameByClass = true
	end
end

local function CreateFakeAchievementPopup()
	local popup = CreateFrame("Frame", "KKUI_FakeAchievement", UIParent)
	popup:SetSize(310, 70) -- Size similar to the achievement frame
	popup:SetPoint("TOP", UIParent, "TOP", 0, -150)
	popup:SetFrameStrata("DIALOG")
	popup:CreateBorder()
	popup:Hide() -- Hide the frame initially

	-- Achievement icon
	popup.icon = popup:CreateTexture(nil, "OVERLAY", nil, 6)
	popup.icon:SetSize(50, 50)
	popup.icon:SetPoint("LEFT", 10, 0)
	popup.icon:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\KkthnxUI_Spell_Icon") -- Placeholder texture
	popup.icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])

	popup.iconFrame = CreateFrame("Frame", nil, popup)
	popup.iconFrame:SetAllPoints(popup.icon)
	popup.iconFrame:CreateBorder(nil, nil, nil, nil, nil, nil, "")

	-- Title
	popup.title = popup:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	popup.title:SetPoint("TOP", popup, "TOP", 0, 18)

	-- Description
	popup.description = popup:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	popup.description:SetPoint("LEFT", popup.icon, "RIGHT", 14, 0) -- 8 is the padding from the icon, adjust as needed
	popup.description:SetPoint("RIGHT", popup, "RIGHT", -8, 0) -- -8 is the padding from the right edge, adjust as needed
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

	local titles = { DEFAULT .. " " .. SETTINGS, CHAT, UI_SCALE, "Skins", "Tips" }

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
					apply:SetPoint("BOTTOMRIGHT", -10, 10) -- Reset position for Apply button
					pass:Show() -- Ensure pass button is shown for pages < 5
				else
					apply:SetPoint("BOTTOM", 0, 10)
					apply.text:SetText(COMPLETE)
					pass:Hide() -- Hide pass button on final page
				end
				apply.text:SetTextColor(0, 1, 0) -- Set text color back to green
				apply:Enable()
				ticker:Cancel()
			end
		end, countdownTime)

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
			K:SetupUIScale()
			ShowFakeAchievement("Achievement Earned", "You have successfully applied the UIScale Settings.")
			PlaySound(21968)
		elseif currentPage == 4 then
			StopSound(21968)
			KkthnxUIDB.Variables[K.Realm][K.Name].DBMRequest = KkthnxUIDB.Variables[K.Realm][K.Name].DBMRequest or true
			KkthnxUIDB.Variables[K.Realm][K.Name].MaxDpsRequest = KkthnxUIDB.Variables[K.Realm][K.Name].MaxDpsRequest or true
			KkthnxUIDB.Variables[K.Realm][K.Name].CursorTrailRequest = KkthnxUIDB.Variables[K.Realm][K.Name].CursorTrailRequest or true
			KkthnxUIDB.Variables[K.Realm][K.Name].HekiliRequest = KkthnxUIDB.Variables[K.Realm][K.Name].HekiliRequest or true
			Module.ForceAddonSkins()
			ShowFakeAchievement("Achievement Earned", "You have successfully applied the relevant AddOn Settings.")
			PlaySound(21968)
		elseif currentPage == 5 then
			Module:ForceDefaultCVars() -- Set these one more time
			StopSound(21968)
			StopSound(140268)
			KkthnxUIDB.Variables[K.Realm][K.Name].InstallComplete = KkthnxUIDB.Variables[K.Realm][K.Name].InstallComplete or true
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

	K.CreateFontString(welcome, 16, "Welcome " .. K.Name .. "|r", "", true, "TOP", 0, -10)

	local ll = CreateFrame("Frame", nil, welcome)
	ll:SetPoint("TOP", -50, -35)
	K.CreateGF(ll, 100, 1, "Horizontal", 0.7, 0.7, 0.7, 0, 0.7)
	ll:SetFrameStrata("HIGH")

	local lr = CreateFrame("Frame", nil, welcome)
	lr:SetPoint("TOP", 50, -35)
	K.CreateGF(lr, 100, 1, "Horizontal", 0.7, 0.7, 0.7, 0.7, 0)
	lr:SetFrameStrata("HIGH")

	K.CreateFontString(welcome, 14, "Thank you for choosing |cff5C8BCFKkthnxUI|r, v" .. K.SystemColor .. K.Version .. "|r!", "", false, "TOP", 0, -50)
	K.CreateFontString(welcome, 13, "|cff5C8BCFKkthnxUI|r is a simplistic user interface that holds", "", false, "TOP", 0, -86)
	K.CreateFontString(welcome, 13, "onto the information and functionality, while still keeping", "", false, "TOP", 0, -106)
	K.CreateFontString(welcome, 13, "most of the good looks. It can be used for any class or role.", "", false, "TOP", 0, -126)

	K.CreateFontString(welcome, 16, "|cff5C8BCFJoin The Community!|r", "", false, "TOP", 0, -160)
	K.CreateFontString(welcome, 13, "There are thousands of users, but most are content", "", false, "TOP", 0, -180)

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

	K.CreateFontString(welcome, 13, "If this is your first time using |cff5C8BCFKkthnxUI|r,", "", false, "BOTTOM", 0, 130)
	K.CreateFontString(welcome, 13, "please take a minute to go through the tutorial!", "", false, "BOTTOM", 0, 110)
	K.CreateFontString(welcome, 13, "if you need help for commands type /khelp", "", false, "BOTTOM", 0, 90)

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
		KkthnxUIDB.Variables[K.Realm][K.Name].DBMRequest = KkthnxUIDB.Variables[K.Realm][K.Name].DBMRequest or true
		KkthnxUIDB.Variables[K.Realm][K.Name].MaxDpsRequest = KkthnxUIDB.Variables[K.Realm][K.Name].MaxDpsRequest or true
		KkthnxUIDB.Variables[K.Realm][K.Name].CursorTrailRequest = KkthnxUIDB.Variables[K.Realm][K.Name].CursorTrailRequest or true
		KkthnxUIDB.Variables[K.Realm][K.Name].HekiliRequest = KkthnxUIDB.Variables[K.Realm][K.Name].HekiliRequest or true
		Module.ForceAddonSkins()
		KkthnxUIDB.Variables[K.Realm][K.Name].InstallComplete = KkthnxUIDB.Variables[K.Realm][K.Name].InstallComplete or true
		StaticPopup_Show("SKIP_INSTALLER_CONFIRM")
	end)

	goSkip:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText("Skip Installer", 1, 0.82, 0) -- Gold color for title
		GameTooltip:AddLine("This will skip the installer and quickly apply the default settings for this character.", 1, 1, 1, true) -- White text with line break
		GameTooltip:Show()
	end)

	goSkip:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
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
