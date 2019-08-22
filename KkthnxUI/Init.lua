local AddOnName, Engine = ...

local _G = _G
local math_max = _G.math.max
local math_min = _G.math.min
local string_format = _G.string.format
local string_lower = _G.string.lower
local string_match = _G.string.match
local table_insert = _G.table.insert
local tonumber = _G.tonumber
local unpack = _G.unpack

local CUSTOM_CLASS_COLORS = _G.CUSTOM_CLASS_COLORS
local CombatLogGetCurrentEventInfo = _G.CombatLogGetCurrentEventInfo
local CreateFrame = _G.CreateFrame
local GetAddOnEnableState = _G.GetAddOnEnableState
local GetAddOnInfo = _G.GetAddOnInfo
local GetAddOnMetadata = _G.GetAddOnMetadata
local GetBuildInfo = _G.GetBuildInfo
local GetCVar = _G.GetCVar
local GetCurrentResolution = _G.GetCurrentResolution
local GetLocale = _G.GetLocale
local GetNumAddOns = _G.GetNumAddOns
local GetRealmName = _G.GetRealmName
local GetScreenResolutions = _G.GetScreenResolutions
local GetSpecialization = _G.GetSpecialization
local LOCALIZED_CLASS_NAMES_MALE = _G.LOCALIZED_CLASS_NAMES_MALE
local LibStub = _G.LibStub
local RAID_CLASS_COLORS = _G.RAID_CLASS_COLORS
local UnitClass = _G.UnitClass
local UnitFactionGroup = _G.UnitFactionGroup
local UnitLevel = _G.UnitLevel
local UnitName = _G.UnitName
local UnitRace = _G.UnitRace

-- Engine
Engine[1] = {} -- K, Main
Engine[2] = {} -- C, Config
Engine[3] = {} -- L, Locales

local K = unpack(Engine)

K.Title = GetAddOnMetadata(AddOnName, "Title")
K.Version = GetAddOnMetadata(AddOnName, "Version")
K.Credits = GetAddOnMetadata(AddOnName, "X-Credits")

K.Noop = function()
	return
end

K.Name = UnitName("player")
K.LocalizedClass, K.Class, K.ClassID = UnitClass("player")
K.LocalizedRace, K.Race = UnitRace("player")
K.Faction, K.LocalizedFaction = UnitFactionGroup("player")
K.Spec = GetSpecialization() or 0
K.Level = UnitLevel("player")
K.Client = GetLocale()
K.Realm = GetRealmName()
K.oUF = Engine.oUF
K.Media = "Interface\\AddOns\\KkthnxUI\\Media\\"
K.LSM = LibStub and LibStub:GetLibrary("LibSharedMedia-3.0", true)
K.Resolution = ({GetScreenResolutions()})[GetCurrentResolution()] or GetCVar("gxWindowedResolution")
K.ScreenHeight = tonumber(string_match(K.Resolution, "%d+x(%d+)"))
K.ScreenWidth = tonumber(string_match(K.Resolution, "(%d+)x+%d"))
K.UIScale = math_min(2, math_max(0.01, 768 / string_match(K.Resolution, "%d+x(%d+)")))
K.PriestColors = {r = 0.86, g = 0.92, b = 0.98, colorStr = "dbebfa"}
K.Color = K.Class == "PRIEST" and K.PriestColors or (CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[K.Class] or RAID_CLASS_COLORS[K.Class])
K.MyClassColor = string_format("|cff%02x%02x%02x", K.Color.r * 255, K.Color.g * 255, K.Color.b * 255)
K.TexCoords = {0.08, 0.92, 0.08, 0.92}
K.Welcome = "|cff4488ffKkthnxUI "..K.Version.." "..K.Client.."|r - /helpui"
K.ScanTooltip = CreateFrame("GameTooltip", "KkthnxUI_ScanTooltip", _G.UIParent, "GameTooltipTemplate")
K.WowPatch, K.WowBuild, K.WowRelease, K.TocVersion = GetBuildInfo()
K.WowBuild = tonumber(K.WowBuild)
K.IsPTR = GetBuildInfo and K.WowBuild >= 29634
K.InfoColor = "|cff4488ff"
K.CodeDebug = false -- Don't touch this, unless you know what you are doing?

K.ClassList = {}
for k, v in pairs(LOCALIZED_CLASS_NAMES_MALE) do
	K.ClassList[v] = k
end
K.ClassColors = {}
local colors = CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS
for class in pairs(colors) do
	K.ClassColors[class] = {}
	K.ClassColors[class].r = colors[class].r
	K.ClassColors[class].g = colors[class].g
	K.ClassColors[class].b = colors[class].b
	K.ClassColors[class].colorStr = colors[class].colorStr
end
K.r, K.g, K.b = K.ClassColors[K.Class].r, K.ClassColors[K.Class].g, K.ClassColors[K.Class].b

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
		print("Module <"..name.."> has been registered.")
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
		print("Module <"..name.."> does not exist.")
		return
	end

	return modules[name]
end

K:RegisterEvent("PLAYER_LOGIN", function()
	for _, module in next, initQueue do
		if module.OnEnable then
			module:OnEnable()
		else
			print("Module <"..module.name.."> does not loaded.")
		end
	end

	K.Modules = modules
end)

local function PositionGameMenuButton()
	GameMenuFrame:SetHeight(GameMenuFrame:GetHeight() + GameMenuButtonLogout:GetHeight())
	local _, relTo, _, _, offY = GameMenuButtonLogout:GetPoint()
	if relTo ~= GameMenuFrame[AddOnName] then
		GameMenuFrame[AddOnName]:ClearAllPoints()
		GameMenuFrame[AddOnName]:SetPoint("TOPLEFT", relTo, "BOTTOMLEFT", 0, -1)
		GameMenuButtonLogout:ClearAllPoints()
		GameMenuButtonLogout:SetPoint("TOPLEFT", GameMenuFrame[AddOnName], "BOTTOMLEFT", 0, offY)
	end
end

-- Got to check for addon name, or this will fire for ALL addons, creating a ton of buttons!
local function CreateGameMenuButton(event, addon)
	if (addon ~= AddOnName) then 
		return 
	end 

	K.GUID = UnitGUID("player")
	K.CreateStaticPopups()

	-- KkthnxUI GameMenu Button.
	local GameMenuButton = CreateFrame("Button", nil, GameMenuFrame, "GameMenuButtonTemplate")
	GameMenuButton:SetText(string_format("|cff4488ff%s|r", AddOnName))
	GameMenuButton:SetScript("OnClick", function()
		if (not KkthnxUIConfigFrame) then
			KkthnxUIConfig:CreateConfigWindow()
		end

		if KkthnxUIConfigFrame:IsVisible() then
			KkthnxUIConfigFrame:Hide()
		else
			KkthnxUIConfigFrame:Show()
		end

		HideUIPanel(GameMenuFrame)
	end)
	GameMenuFrame[AddOnName] = GameMenuButton

	if not IsAddOnLoaded("ConsolePortUI_Menu") then
		GameMenuButton:SetSize(GameMenuButtonLogout:GetWidth(), GameMenuButtonLogout:GetHeight())
		GameMenuButton:SetPoint("TOPLEFT", GameMenuButtonAddons, "BOTTOMLEFT", 0, -1)
		hooksecurefunc("GameMenuFrame_UpdateVisibleButtons", PositionGameMenuButton)
	end
	K:UnregisterEvent("ADDON_LOADED", CreateGameMenuButton)
end
K:RegisterEvent("ADDON_LOADED", CreateGameMenuButton)

-- Event return values were wrong: https://wow.gamepedia.com/PLAYER_LEVEL_UP 
K:RegisterEvent("PLAYER_LEVEL_UP", function(_, level)
	if not K.Level then
		return
	end

	K.Level = level
end)

K.AddOns = {}
K.AddOnVersion = {}
for i = 1, GetNumAddOns() do
	local Name = GetAddOnInfo(i)
	K.AddOns[string_lower(Name)] = GetAddOnEnableState(K.Name, Name) == 2
	K.AddOnVersion[string_lower(Name)] = GetAddOnMetadata(Name, "Version")
end

do
	K.AboutPanel = CreateFrame("Frame", nil, _G.InterfaceOptionsFramePanelContainer)
	K.AboutPanel:Hide()
	K.AboutPanel.name = K.Title
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

		-- Social Buttion, because why not?
		local titleButtons = self:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
		titleButtons:SetPoint("TOPLEFT", subLocalizations, "BOTTOMLEFT", 0, -16)
		titleButtons:SetText("Keep Calm I'm Adding Buttons:")

		local buttonGitHub = CreateFrame("Button", nil, self, "UIPanelButtonTemplate")
		buttonGitHub:SetSize(100, 22)
		buttonGitHub:SetPoint("TOPLEFT", titleButtons, "BOTTOMLEFT", 0, -8)
		buttonGitHub:SkinButton()
		buttonGitHub:SetScript("OnClick", function()
			K.StaticPopup_Show("GITHUB_EDITBOX", nil, nil, "https://github.com/kkthnx-wow/KkthnxUI_8.0.1")
		end)
		buttonGitHub.Text = buttonGitHub:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		buttonGitHub.Text:SetPoint("CENTER", buttonGitHub)
		buttonGitHub.Text:SetText("|cffffd100".."GitHub".."|r")

		local buttonBugReport = CreateFrame("Button", nil, self, "UIPanelButtonTemplate")
		buttonBugReport:SetSize(100, 22)
		buttonBugReport:SetPoint("LEFT", buttonGitHub, "RIGHT", 6, 0)
		buttonBugReport:SkinButton()
		buttonBugReport:SetScript("OnClick", function()
			K.StaticPopup_Show("GITHUB_EDITBOX", nil, nil, "https://github.com/kkthnx-wow/KkthnxUI_8.0.1/issues/new")
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
		buttonDiscord.Text:SetText("|cffffd100".."Discord".."|r")

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