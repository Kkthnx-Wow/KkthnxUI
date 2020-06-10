local AddOnName, Engine = ...

local _G = _G
local math_max = _G.math.max
local math_min = _G.math.min
local next = _G.next
local pairs = _G.pairs
local select = _G.select
local string_format = _G.string.format
local string_lower = _G.string.lower
local table_insert = _G.table.insert
local tonumber = _G.tonumber
local unpack = _G.unpack

local BAG_ITEM_QUALITY_COLORS = _G.BAG_ITEM_QUALITY_COLORS
local CUSTOM_CLASS_COLORS = _G.CUSTOM_CLASS_COLORS
local C_Timer_After = _G.C_Timer.After
local CombatLogGetCurrentEventInfo = _G.CombatLogGetCurrentEventInfo
local CreateFrame = _G.CreateFrame
local GetAddOnEnableState = _G.GetAddOnEnableState
local GetAddOnInfo = _G.GetAddOnInfo
local GetAddOnMetadata = _G.GetAddOnMetadata
local GetBuildInfo = _G.GetBuildInfo
local GetLocale = _G.GetLocale
local GetNumAddOns = _G.GetNumAddOns
local GetPhysicalScreenSize = _G.GetPhysicalScreenSize
local GetRealmName = _G.GetRealmName
local GetTime = _G.GetTime
local InCombatLockdown = _G.InCombatLockdown
local LE_ITEM_QUALITY_COMMON = _G.LE_ITEM_QUALITY_COMMON
local LE_ITEM_QUALITY_POOR = _G.LE_ITEM_QUALITY_POOR
local LOCALIZED_CLASS_NAMES_MALE = _G.LOCALIZED_CLASS_NAMES_MALE
local LibStub = _G.LibStub
local PlaySound = _G.PlaySound
local RAID_CLASS_COLORS = _G.RAID_CLASS_COLORS
local UnitClass = _G.UnitClass
local UnitFactionGroup = _G.UnitFactionGroup
local UnitGUID = _G.UnitGUID
local UnitLevel = _G.UnitLevel
local UnitName = _G.UnitName
local UnitRace = _G.UnitRace

-- Engine
Engine[1] = {} -- K, Main
Engine[2] = {} -- C, Config
Engine[3] = {} -- L, Locales

local K, C = unpack(Engine)

K.oUF = Engine.oUF
K.cargBags = Engine.cargBags
K.libButtonGlow = LibStub("LibButtonGlow-1.0", true)
K.libCustomGlow = LibStub("LibCustomGlow-1.0", true)

K.AddOns = {}
K.AddOnVersion = {}

K.Title = GetAddOnMetadata(AddOnName, "Title")
K.Version = GetAddOnMetadata(AddOnName, "Version")
K.Credits = GetAddOnMetadata(AddOnName, "X-Credits")

K.Noop = function()
	return
end

K.Name = UnitName("player")
K.Class = select(2, UnitClass("player"))
K.Race = select(2, UnitRace("player"))
K.Faction = select(2, UnitFactionGroup("player"))
K.Level = UnitLevel("player")
K.Client = GetLocale()
K.Realm = GetRealmName()
K.Media = "Interface\\AddOns\\KkthnxUI\\Media\\"
K.LSM = LibStub and LibStub:GetLibrary("LibSharedMedia-3.0", true)
K.ScreenWidth, K.ScreenHeight = GetPhysicalScreenSize()
K.Resolution = string_format("%dx%d", K.ScreenWidth, K.ScreenHeight)
K.PriestColors = {r = 0.86, g = 0.92, b = 0.98, colorStr = "ffdbebfa"} -- Keep this until I convert the rest.
K.TexCoords = {0.08, 0.92, 0.08, 0.92}
K.Welcome = "|cff669DFFKkthnxUI "..K.Version.." "..K.Client.."|r - /helpui"
K.ScanTooltip = CreateFrame("GameTooltip", "KkthnxUI_ScanTooltip", _G.UIParent, "GameTooltipTemplate")
K.WowPatch, K.WowBuild, K.WowRelease, K.TocVersion = GetBuildInfo()
K.WowBuild = tonumber(K.WowBuild)
K.GreyColor = "|CFF7b8489"
K.InfoColor = "|CFF669DFF"
K.SystemColor = "|CFFFFCC66"

K.CodeDebug = false -- Don't touch this, unless you know what you are doing?

K.QualityColors = {}
local qualityColors = BAG_ITEM_QUALITY_COLORS
for index, value in pairs(qualityColors) do
	K.QualityColors[index] = {r = value.r, g = value.g, b = value.b}
end
K.QualityColors[-1] = {r = 1, g = 1, b = 1}
K.QualityColors[LE_ITEM_QUALITY_POOR] = {r = 0.61, g = 0.61, b = 0.61}
K.QualityColors[LE_ITEM_QUALITY_COMMON] = {r = 1, g = 1, b = 1}

K.ClassList = {}
for k, v in pairs(LOCALIZED_CLASS_NAMES_MALE) do
	K.ClassList[v] = k
end

K.ClassColors = {}
local colors = CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS
for class, value in pairs(colors) do
	K.ClassColors[class] = {}
	K.ClassColors[class].r = value.r
	K.ClassColors[class].g = value.g
	K.ClassColors[class].b = value.b
	K.ClassColors[class].colorStr = value.colorStr
end
K.r, K.g, K.b = K.ClassColors[K.Class].r, K.ClassColors[K.Class].g, K.ClassColors[K.Class].b
K.MyClassColor = string_format("|cff%02x%02x%02x", K.r * 255, K.g * 255, K.b * 255)

local events = {}
local host = CreateFrame("Frame")
local modules, initQueue = {}, {}

host:SetScript("OnEvent", function(_, event, ...)
	for func in pairs(events[event]) do
		if event == "COMBAT_LOG_EVENT_UNFILTERED" then
			func(event, CombatLogGetCurrentEventInfo())
		else
			func(event, ...)
		end
	end
end)

function K:RegisterEvent(event, func, unit1, unit2)
	if not events[event] then
		events[event] = {}
		if unit1 then
			host:RegisterUnitEvent(event, unit1, unit2)
		else
			host:RegisterEvent(event)
		end
	end

	events[event][func] = true
end

function K:UnregisterEvent(event, func)
	local funcs = events[event]
	if funcs and funcs[func] then
		funcs[func] = nil
		if not next(funcs) then
			events[event] = nil
			host:UnregisterEvent(event)
		end
	end
end

-- Modules
function K:NewModule(name)
	if modules[name] then
		K.Print("Module <"..name.."> has been registered.")
		return
	end

	local module = {}
	module.name = name
	modules[name] = module

	table_insert(initQueue, module)
	return module
end

function K:GetModule(name)
	if not modules[name] then
		K.Print("Module <"..name.."> does not exist.")
		return
	end

	return modules[name]
end

local function GetBestScale()
	return math_max(0.4, math_min(1.15, 768 / K.ScreenHeight))
end

function K:SetupUIScale(init)
	if C["General"].AutoScale then
		C["General"].UIScale = GetBestScale()
	end

	local scale = C["General"].UIScale
	if init == true then
		local pixel, ratio = 1, 768 / K.ScreenHeight
		K.Mult = (pixel / scale) - ((pixel - ratio) / scale)
	elseif not InCombatLockdown() then
		UIParent:SetScale(scale)
	end
end

local isScaling = false
function K:UpdatePixelScale(event)
	if isScaling then
		return
	end
	isScaling = true

	if event == "UI_SCALE_CHANGED" then
		K.ScreenWidth, K.ScreenHeight = GetPhysicalScreenSize()
		K.Resolution = string_format("%dx%d", K.ScreenWidth, K.ScreenHeight)
	end

	K:SetupUIScale(true)
	K:SetupUIScale()

	isScaling = false
end

function K:Scale(x)
	local mult = K.Mult
	return mult * math.floor(x / mult + 0.5)
end

K:RegisterEvent("PLAYER_LOGIN", function()
	local configSettings
	local configName = UnitName("player")
	local configRealm = GetRealmName()

	-- Config Clean and Small Here xD
	if (KkthnxUIConfigPerAccount) then
		configSettings = KkthnxUIConfigShared.Account
	else
		configSettings = KkthnxUIConfigShared[configRealm][configName]
	end

	for group, options in pairs(configSettings) do
		if C[group] then
			local Count = 0

			for option, value in pairs(options) do
				if (C[group][option] ~= nil) then
					if (C[group][option] == value) then
						configSettings[group][option] = nil
					else
						Count = Count + 1

						C[group][option] = value
					end
				end
			end

			-- Keeps KkthnxUIConfig clean and small
			if (Count == 0) then
				configSettings[group] = nil
			end
		else
			configSettings[group] = nil
		end
	end

	-- Update UIScale
	K:SetupUIScale()
	K:RegisterEvent("UI_SCALE_CHANGED", K.UpdatePixelScale)

	for _, module in next, initQueue do
		if module.OnEnable then
			module:OnEnable()
		else
			K.Print("Module <"..module.name.."> does not loaded.")
		end
	end

	local KKGUIButton = CreateFrame("Button", "GameMenuFrame_KKUI", GameMenuFrame, "GameMenuButtonTemplate")
	KKGUIButton:SetText((string_format("|cff669DFF%s|r", AddOnName)))
	KKGUIButton:SetPoint("TOP", GameMenuButtonAddons, "BOTTOM", 0, -21)
	GameMenuFrame:HookScript("OnShow", function(self)
		GameMenuButtonLogout:SetPoint("TOP", KKGUIButton, "BOTTOM", 0, -21)
		self:SetHeight(self:GetHeight() + KKGUIButton:GetHeight() + 26)
	end)

	KKGUIButton:SetScript("OnClick", function()
		if InCombatLockdown() then
			UIErrorsFrame:AddMessage(K.InfoColor..ERR_NOT_IN_COMBAT)
			return
		end

		if (not KkthnxUIConfigFrame) then
			KkthnxUIConfig:CreateConfigWindow()
			PlaySound(603)
		end

		if KkthnxUIConfigFrame:IsVisible() then
			KkthnxUIConfigFrame:Hide()
			PlaySound(604)
		else
			KkthnxUIConfigFrame:Show()
			PlaySound(603)
		end

		HideUIPanel(GameMenuFrame)
	end)

	K.Modules = modules
end)

-- Got to check for addon name, or this will fire for ALL addons, creating a ton of buttons!
K:RegisterEvent("ADDON_LOADED", function(_, addon)
	if (addon ~= AddOnName) then
		return
	end

	local playerName = UnitName("player")
	local playerRealm = GetRealmName()

	if (not KkthnxUIData) then
		KkthnxUIData = {}
	end

	-- Create missing entries in the saved vars if they don"t exist.
	if (not KkthnxUIData[playerRealm]) then
		KkthnxUIData[playerRealm] = {}
	end

	if (not KkthnxUIData[playerRealm][playerName]) then
		KkthnxUIData[playerRealm][playerName] = {}
	end

	if (KkthnxUIDataPerChar) then
		KkthnxUIData[playerRealm][playerName] = KkthnxUIDataPerChar
		KkthnxUIDataPerChar = nil
	end

	if (not KkthnxUIData.ChangelogVersion) then
		KkthnxUIData.ChangelogVersion = {}
	end

	-- Blizzard have too many issues with per character saved variables, we now move them (if they exists) to account saved variables.
	if (not KkthnxUIConfigShared) then
		KkthnxUIConfigShared = {}
	end

	if (not KkthnxUIConfigShared.Account) then
		KkthnxUIConfigShared.Account = {}
	end

	if (not KkthnxUIConfigShared[playerRealm]) then
		KkthnxUIConfigShared[playerRealm] = {}
	end

	if (not KkthnxUIConfigShared[playerRealm][playerName]) then
		KkthnxUIConfigShared[playerRealm][playerName] = {}
	end

	if (KkthnxUIConfigNotShared) then
		KkthnxUIConfigShared[playerRealm][playerName] = KkthnxUIConfigNotShared
		KkthnxUIConfigNotShared = nil
	end

	if (not KkthnxUIData[playerRealm][playerName].RevealWorldMap) then
		KkthnxUIData[playerRealm][playerName].RevealWorldMap = false
	end

	if (not KkthnxUIData[playerRealm][playerName].AutoQuest) then
		KkthnxUIData[playerRealm][playerName].AutoQuest = false
	end

	if (not KkthnxUIData[playerRealm][playerName].BindType) then
		KkthnxUIData[playerRealm][playerName].BindType = 1
	end

	if (not KkthnxUIData[playerRealm][playerName].FavouriteItems) then
		KkthnxUIData[playerRealm][playerName].FavouriteItems = {}
	end

	if (not KkthnxUIData[playerRealm][playerName].SplitCount) then
		KkthnxUIData[playerRealm][playerName].SplitCount = 1
	end

	if (not KkthnxUIData[playerRealm][playerName].CustomJunkList) then
		KkthnxUIData[playerRealm][playerName].CustomJunkList = {}
	end

	if (not KkthnxUIData[playerRealm][playerName].Mover) then
		KkthnxUIData[playerRealm][playerName].Mover = {}
	end

	if (not KkthnxUIData[playerRealm][playerName].LuaErrorDisabledAddOns) then
		KkthnxUIData[playerRealm][playerName].LuaErrorDisabledAddOns = {}
	end

	if (not KkthnxUIData[playerRealm][playerName].MoviesSeen) then
		KkthnxUIData[playerRealm][playerName].MoviesSeen = {}
	end

	if (not KkthnxUIData[playerRealm][playerName].TempAnchor) then
		KkthnxUIData[playerRealm][playerName].TempAnchor = {}
	end

	if (not KkthnxUIData[playerRealm][playerName].DetectVersion) then
		KkthnxUIData[playerRealm][playerName].DetectVersion = K.Version
	end

	if (not KkthnxUIData[playerRealm][playerName].ContactList) then
		KkthnxUIData[playerRealm][playerName].ContactList = {}
	end

	if (not KkthnxUIData[playerRealm][playerName].KeystoneInfo) then
		KkthnxUIData[playerRealm][playerName].KeystoneInfo = {}
	end

	K.GUID = UnitGUID("player")
	K.CreateStaticPopups()

	K:UnregisterEvent("ADDON_LOADED")
end)

-- Event return values were wrong: https://wow.gamepedia.com/PLAYER_LEVEL_UP
K:RegisterEvent("PLAYER_LEVEL_UP", function(_, level)
	if not K.Level then
		return
	end

	K.Level = level
end)

for i = 1, GetNumAddOns() do
	local Name = GetAddOnInfo(i)
	K.AddOns[string_lower(Name)] = GetAddOnEnableState(K.Name, Name) == 2
	K.AddOnVersion[string_lower(Name)] = GetAddOnMetadata(Name, "Version")
end

do
	K.AboutPanel = CreateFrame("Frame", nil, _G.InterfaceOptionsFramePanelContainer)
	K.AboutPanel:Hide()
	K.AboutPanel.name = K.Title or "KkthnxUI"
	K.AboutPanel:SetScript("OnShow", function(self)
		if self.show then
			return
		end

		local titleInfo = self:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
		titleInfo:SetPoint("TOPLEFT", 16, -16)
		titleInfo:SetText("Info:")

		local subInfo = self:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
		subInfo:SetWidth(580)
		subInfo:SetPoint("TOPLEFT", titleInfo, "BOTTOMLEFT", 0, -8)
		subInfo:SetJustifyH("LEFT")
		subInfo:SetText(GetAddOnMetadata("KkthnxUI", "Notes"))

		local titleCredits = self:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
		titleCredits:SetPoint("TOPLEFT", subInfo, "BOTTOMLEFT", 0, -8)
		titleCredits:SetText("Credits:")

		local subCredits = self:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
		subCredits:SetWidth(580)
		subCredits:SetPoint("TOPLEFT", titleCredits, "BOTTOMLEFT", 0, -8)
		subCredits:SetJustifyH("LEFT")
		subCredits:SetText(GetAddOnMetadata("KkthnxUI", "X-Credits"))

		local titleThanks = self:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
		titleThanks:SetPoint("TOPLEFT", subCredits, "BOTTOMLEFT", 0, -16)
		titleThanks:SetText("Special Thanks:")

		local subThanks = self:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
		subThanks:SetWidth(580)
		subThanks:SetPoint("TOPLEFT", titleThanks, "BOTTOMLEFT", 0, -8)
		subThanks:SetJustifyH("LEFT")
		subThanks:SetText(GetAddOnMetadata("KkthnxUI", "X-Thanks"))

		local titleLocalizations = self:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
		titleLocalizations:SetPoint("TOPLEFT", subThanks, "BOTTOMLEFT", 0, -16)
		titleLocalizations:SetText("Translation:")

		local subLocalizations = self:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
		subLocalizations:SetWidth(580)
		subLocalizations:SetPoint("TOPLEFT", titleLocalizations, "BOTTOMLEFT", 0, -8)
		subLocalizations:SetJustifyH("LEFT")
		subLocalizations:SetText(GetAddOnMetadata("KkthnxUI", "X-Localizations"))

		local titleTranslators = self:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
		titleTranslators:SetPoint("TOPLEFT", subLocalizations, "BOTTOMLEFT", 0, -16)
		titleTranslators:SetText("Translators:")

		local subTranslators = self:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
		subTranslators:SetWidth(580)
		subTranslators:SetPoint("TOPLEFT", titleTranslators, "BOTTOMLEFT", 0, -8)
		subTranslators:SetJustifyH("LEFT")
		subTranslators:SetText(GetAddOnMetadata("KkthnxUI", "X-Translation"))

		-- Social Buttion, because why not?
		local titleButtons = self:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
		titleButtons:SetPoint("TOPLEFT", subTranslators, "BOTTOMLEFT", 0, -16)
		titleButtons:SetText("Keep Calm I'm Adding Buttons:")

		local buttonGitHub = CreateFrame("Button", nil, self, "UIPanelButtonTemplate")
		buttonGitHub:SetSize(100, 22)
		buttonGitHub:SetPoint("TOPLEFT", titleButtons, "BOTTOMLEFT", 0, -8)
		buttonGitHub:SkinButton()
		buttonGitHub:SetScript("OnClick", function()
			K.StaticPopup_Show("GITHUB_EDITBOX", nil, nil, "https://github.com/Kkthnx-Wow/KkthnxUI_8.2.0")
		end)
		buttonGitHub.Text = buttonGitHub:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		buttonGitHub.Text:SetPoint("CENTER", buttonGitHub)
		buttonGitHub.Text:SetText("|cffffd100".."GitHub".."|r")

		local buttonBugReport = CreateFrame("Button", nil, self, "UIPanelButtonTemplate")
		buttonBugReport:SetSize(100, 22)
		buttonBugReport:SetPoint("LEFT", buttonGitHub, "RIGHT", 6, 0)
		buttonBugReport:SkinButton()
		buttonBugReport:SetScript("OnClick", function()
			K.StaticPopup_Show("GITHUB_EDITBOX", nil, nil, "https://github.com/Kkthnx-Wow/KkthnxUI_8.2.0/issues/new")
		end)
		buttonBugReport.Text = buttonBugReport:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		buttonBugReport.Text:SetPoint("CENTER", buttonBugReport)
		buttonBugReport.Text:SetText("|cffffd100".."Bug Report".."|r")

		local buttonDiscord = CreateFrame("Button", nil, self, "UIPanelButtonTemplate")
		buttonDiscord:SetSize(100, 22)
		buttonDiscord:SetPoint("LEFT", buttonBugReport, "RIGHT", 6, 0)
		buttonDiscord:SkinButton()
		buttonDiscord:SetScript("OnClick", function()
			K.StaticPopup_Show("GITHUB_EDITBOX", nil, nil, "https://discordapp.com/invite/mKKySTY")
		end)
		buttonDiscord.Text = buttonDiscord:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		buttonDiscord.Text:SetPoint("CENTER", buttonDiscord)
		buttonDiscord.Text:SetText("|cff7289DA".."Discord".."|r")

		local buttonFacebook = CreateFrame("Button", nil, self, "UIPanelButtonTemplate")
		buttonFacebook:SetSize(100, 22)
		buttonFacebook:SetPoint("LEFT", buttonDiscord, "RIGHT", 6, 0)
		buttonFacebook:SkinButton()
		buttonFacebook:SetScript("OnClick", function()
			K.StaticPopup_Show("GITHUB_EDITBOX", nil, nil, "https://www.facebook.com/kkthnxui")
		end)
		buttonFacebook.Text = buttonFacebook:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		buttonFacebook.Text:SetPoint("CENTER", buttonFacebook)
		buttonFacebook.Text:SetText("|cff3C5A99".."Facebook".."|r")

		local buttonTwitter = CreateFrame("Button", nil, self, "UIPanelButtonTemplate")
		buttonTwitter:SetSize(100, 22)
		buttonTwitter:SetPoint("LEFT", buttonFacebook, "RIGHT", 6, 0)
		buttonTwitter:SkinButton()
		buttonTwitter:SetScript("OnClick", function()
			K.StaticPopup_Show("GITHUB_EDITBOX", nil, nil, "https://twitter.com/KkthnxUI")
		end)
		buttonTwitter.Text = buttonTwitter:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		buttonTwitter.Text:SetPoint("CENTER", buttonTwitter)
		buttonTwitter.Text:SetText("|cff38A1F3".."Twitter".."|r")

		local interfaceVersion = self:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		interfaceVersion:SetPoint("BOTTOMRIGHT", -16, 16)
		interfaceVersion:SetText("Version: "..K.Version)

		self.show = true
	end)

	K.AboutPanel.Commands = CreateFrame( "Frame", nil, K.AboutPanel)
	K.AboutPanel.Commands.name = "Commands"
	K.AboutPanel.Commands:Hide()
	K.AboutPanel.Commands.parent = K.AboutPanel.name

	K.AboutPanel.Questions = CreateFrame( "Frame", nil, K.AboutPanel)
	K.AboutPanel.Questions.name = "Questions"
	K.AboutPanel.Questions:Hide()
	K.AboutPanel.Questions.parent = K.AboutPanel.name

	_G.InterfaceOptions_AddCategory(K.AboutPanel)
	_G.InterfaceOptions_AddCategory(K.AboutPanel.Commands)
	_G.InterfaceOptions_AddCategory(K.AboutPanel.Questions)
end

_G[AddOnName] = Engine