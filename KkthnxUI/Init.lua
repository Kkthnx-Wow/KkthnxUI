local AddOnName, Engine = ...

--========================================================
-- Locals / global caching (WoW Lua 5.1 performance)
--========================================================
local _G = _G

local pairs = pairs
local select = select
local tonumber = tonumber
local type = type

local max = max
local min = min

local print = print

local bit_band = bit.band
local bit_bor = bit.bor

local string_format = string.format
local string_lower = string.lower

local table_insert = table.insert
local table_remove = table.remove

local debugstack = debugstack

--========================================================
-- Cached WoW globals / APIs
--========================================================
local BAG_ITEM_QUALITY_COLORS = BAG_ITEM_QUALITY_COLORS

local COMBATLOG_OBJECT_AFFILIATION_MINE = COMBATLOG_OBJECT_AFFILIATION_MINE
local COMBATLOG_OBJECT_AFFILIATION_PARTY = COMBATLOG_OBJECT_AFFILIATION_PARTY
local COMBATLOG_OBJECT_AFFILIATION_RAID = COMBATLOG_OBJECT_AFFILIATION_RAID
local COMBATLOG_OBJECT_CONTROL_PLAYER = COMBATLOG_OBJECT_CONTROL_PLAYER
local COMBATLOG_OBJECT_REACTION_FRIENDLY = COMBATLOG_OBJECT_REACTION_FRIENDLY
local COMBATLOG_OBJECT_TYPE_PET = COMBATLOG_OBJECT_TYPE_PET

local C_AddOns_GetAddOnMetadata = C_AddOns.GetAddOnMetadata
local GetAddOnEnableState = C_AddOns.GetAddOnEnableState
local GetAddOnInfo = C_AddOns.GetAddOnInfo
local GetNumAddOns = C_AddOns.GetNumAddOns

-- Cache additional globals for performance
local hooksecurefunc = hooksecurefunc
local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo
local CreateFrame = CreateFrame
local Enum = Enum
local GetBuildInfo = GetBuildInfo
local GetLocale = GetLocale
local GetPhysicalScreenSize = GetPhysicalScreenSize
local GetRealmName = GetRealmName
local InCombatLockdown = InCombatLockdown
local LOCALIZED_CLASS_NAMES_FEMALE = LOCALIZED_CLASS_NAMES_FEMALE
local LOCALIZED_CLASS_NAMES_MALE = LOCALIZED_CLASS_NAMES_MALE
local LibStub = LibStub
local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local SetCVar = SetCVar
local UIParent = UIParent
local UnitClass = UnitClass
local UnitFactionGroup = UnitFactionGroup
local UnitGUID = UnitGUID
local UnitLevel = UnitLevel
local UnitName = UnitName
local UnitRace = UnitRace
local UnitSex = UnitSex

--========================================================
-- Engine tables
--========================================================
Engine[1] = {} -- K
Engine[2] = {} -- C
Engine[3] = {} -- L

local K, C, L = Engine[1], Engine[2], Engine[3]

--========================================================
-- Lib Info
--========================================================
K.LibEasyMenu = LibStub("LibEasyMenu-1.0-KkthnxUI", true) or nil
K.LibBase64 = LibStub("LibBase64-1.0-KkthnxUI", true) or nil
K.LibActionButton = LibStub("LibActionButton-1.0-KkthnxUI", true) or nil
K.LibDeflate = LibStub("LibDeflate-KkthnxUI", true) or nil
K.LibSharedMedia = LibStub("LibSharedMedia-3.0", true) or nil
K.LibSerialize = LibStub("LibSerialize-KkthnxUI", true) or nil
K.LibCustomGlow = LibStub("LibCustomGlow-1.0-KkthnxUI", true) or nil
K.LibUnfit = LibStub("LibUnfit-1.0-KkthnxUI", true) or nil
K.cargBags = Engine and Engine.cargBags or nil
K.oUF = Engine and Engine.oUF or nil

--========================================================
-- AddOn Info
--========================================================
K.Title = C_AddOns_GetAddOnMetadata(AddOnName, "Title")
K.Version = C_AddOns_GetAddOnMetadata(AddOnName, "Version")

-- Functions
K.Noop = function() end

--========================================================
-- Player Info
--========================================================
K.Name = UnitName("player")
K.Class = select(2, UnitClass("player"))
K.Race = UnitRace("player")
K.Faction = UnitFactionGroup("player")
K.Level = UnitLevel("player")
K.Client = GetLocale()
K.Realm = GetRealmName()
K.Sex = UnitSex("player")
K.GUID = UnitGUID("player")

--========================================================
-- Screen Info
--========================================================
K.ScreenWidth, K.ScreenHeight = GetPhysicalScreenSize()
K.Resolution = string_format("%dx%d", K.ScreenWidth, K.ScreenHeight)

--========================================================
-- UI Info
--========================================================
K.TexCoords = { 0.08, 0.92, 0.08, 0.92 }
K.EasyMenu = CreateFrame("Frame", "KKUI_EasyMenu", UIParent, "UIDropDownMenuTemplate")
K.ScanTooltip = CreateFrame("GameTooltip", "KKUI_ScanTooltip", UIParent, "GameTooltipTemplate")
K.ScanTooltip:SetOwner(UIParent, "ANCHOR_NONE")

--========================================================
-- WoW Info
--========================================================
K.WowPatch, K.WowBuild, K.WowRelease, K.TocVersion = GetBuildInfo()
K.WowBuild = tonumber(K.WowBuild)
K.IsNewPatch = K.WowBuild >= 110200 -- Patch 11.2.0+

--========================================================
-- Color Info
--========================================================
K.GreyColor = "|CFFC0C0C0"
K.InfoColor = "|CFF5C8BCF"
K.InfoColorTint = "|CFF93BAFF"
K.SystemColor = "|CFFFFCC66"

--========================================================
-- Media Info
--========================================================
K.MediaFolder = "Interface\\AddOns\\KkthnxUI\\Media\\"

K.UIFont = "KkthnxUIFont"
K.UIFontSize = select(2, _G.KkthnxUIFont:GetFont())
K.UIFontStyle = select(3, _G.KkthnxUIFont:GetFont())

K.UIFontOutline = "KkthnxUIFontOutline"
K.UIFontOutlineSize = select(2, _G.KkthnxUIFontOutline:GetFont())
K.UIFontOutlineStyle = select(3, _G.KkthnxUIFontOutline:GetFont())

K.LeftButton = " |TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:13:11:0:-1:512:512:12:66:230:307|t "
K.RightButton = " |TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:13:11:0:-1:512:512:12:66:333:410|t "
K.ScrollButton = " |TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:13:11:0:-1:512:512:12:66:127:204|t "

--========================================================
-- Lists
--========================================================
K.ClassList = {}
K.ClassColors = {}
K.QualityColors = {}
K.AddOns = {}
K.AddOnVersion = {}

--========================================================
-- Flags / Constants
--========================================================
K.PartyPetFlags = bit_bor(COMBATLOG_OBJECT_AFFILIATION_PARTY, COMBATLOG_OBJECT_REACTION_FRIENDLY, COMBATLOG_OBJECT_CONTROL_PLAYER, COMBATLOG_OBJECT_TYPE_PET)
K.RaidPetFlags = bit_bor(COMBATLOG_OBJECT_AFFILIATION_RAID, COMBATLOG_OBJECT_REACTION_FRIENDLY, COMBATLOG_OBJECT_CONTROL_PLAYER, COMBATLOG_OBJECT_TYPE_PET)

--========================================================
-- Tables / State
--========================================================
local eventsFrame = CreateFrame("Frame")
local events = {} -- events[event] = { func1 = true, func2 = true }
local modules = {}
local modulesQueue = {}

local isScaling = false
local pendingScaleApply = false

--========================================================
-- Deferred scale application after combat
--========================================================
local function ApplyScaleAfterCombat()
	K:UnregisterEvent("PLAYER_REGEN_ENABLED", ApplyScaleAfterCombat)
	pendingScaleApply = false
	K:SetupUIScale()
end

--========================================================
-- Helpers
--========================================================
function K.IsMyPet(flags)
	return bit_band(flags, COMBATLOG_OBJECT_AFFILIATION_MINE) > 0
end

-- Populate ClassList with localized class names
for classToken, localizedName in pairs(LOCALIZED_CLASS_NAMES_MALE) do
	K.ClassList[localizedName] = classToken
end
for classToken, localizedName in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do
	K.ClassList[localizedName] = classToken
end

-- Class colors (prefer custom if present)
local colors = _G.CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS
for class, value in pairs(colors) do
	local t = K.ClassColors[class]
	if not t then
		t = {}
		K.ClassColors[class] = t
	end
	t.r = value.r
	t.g = value.g
	t.b = value.b
	t.colorStr = value.colorStr
end

K.r, K.g, K.b = K.ClassColors[K.Class].r, K.ClassColors[K.Class].g, K.ClassColors[K.Class].b
K.MyClassColor = string_format("|cff%02x%02x%02x", K.r * 255, K.g * 255, K.b * 255)

-- Quality colors
for index, value in pairs(BAG_ITEM_QUALITY_COLORS) do
	K.QualityColors[index] = { r = value.r, g = value.g, b = value.b }
end
K.QualityColors[-1] = { r = 1, g = 1, b = 1 }
K.QualityColors[Enum.ItemQuality.Poor] = { r = 0.61, g = 0.61, b = 0.61 }
K.QualityColors[Enum.ItemQuality.Common] = { r = 1, g = 1, b = 1 }

--========================================================
-- Event System (Simplified)
--========================================================
eventsFrame:SetScript("OnEvent", function(self, event, ...)
	local funcs = events[event]
	if not funcs then
		return
	end

	if event == "COMBAT_LOG_EVENT_UNFILTERED" then
		for func in pairs(funcs) do
			-- Directly pass the API call return values to avoid table churn and truncation
			func(event, CombatLogGetCurrentEventInfo())
		end
	else
		for func in pairs(funcs) do
			func(event, ...)
		end
	end
end)

function K:RegisterEvent(event, func, unit1, unit2)
	if event == "CLEU" then
		event = "COMBAT_LOG_EVENT_UNFILTERED"
	end

	if not func or type(func) ~= "function" then
		print(string_format("|cffff0000KkthnxUI:RegisterEvent error:|r invalid function for '%s'", event))
		return
	end

	if not events[event] then
		events[event] = {}
		if unit1 then
			eventsFrame:RegisterUnitEvent(event, unit1, unit2)
		else
			eventsFrame:RegisterEvent(event)
		end
	end

	events[event][func] = true
end

function K:UnregisterEvent(event, func)
	if event == "CLEU" then
		event = "COMBAT_LOG_EVENT_UNFILTERED"
	end

	local funcs = events[event]
	if funcs and funcs[func] then
		funcs[func] = nil

		if not next(funcs) then
			events[event] = nil
			eventsFrame:UnregisterEvent(event)
		end
	end
end

--========================================================
-- Modules
--========================================================
function K:NewModule(name)
	if modules[name] then
		print(string_format("|cffff0000KkthnxUI:|r Module <%s> has been registered.", name))
		return modules[name]
	end
	local module = { name = name, IsEnabled = false }
	modules[name] = module

	table_insert(modulesQueue, module)
	return module
end

-- Alias for CreateModule
function K:CreateModule(name)
	return K:NewModule(name)
end

function K:GetModule(name)
	if not modules[name] then
		print(string_format("|cffff0000KkthnxUI:|r Module <%s> does not exist.", name))
		return
	end
	return modules[name]
end

function K:InitializeModules()
	for i = 1, #modulesQueue do
		local module = modulesQueue[i]
		if module.OnEnable and not module.IsEnabled then
			module:OnEnable()
			module.IsEnabled = true
		end
	end
end

--========================================================
-- Secure Frame Helpers (Taint Safety)
--========================================================
function K:RegisterStateDriver(frame, state, value)
	if not frame or not state or not value then
		print(string_format("|cffff0000KkthnxUI:RegisterStateDriver error:|r invalid arguments"))
		return
	end
	RegisterStateDriver(frame, state, value)
end

K.HookSecureFunc = hooksecurefunc

--========================================================
-- Scaling
--========================================================
local function GetBestScale()
	local scale = max(0.4, min(1.15, 768 / K.ScreenHeight))
	return K.Round(scale, 2)
end

function K:SetupUIScale(init)
	if C["General"].AutoScale then
		C["General"].UIScale = GetBestScale()
	end

	local scale = C["General"].UIScale
	if init then
		local pixel = 1
		local ratio = 768 / K.ScreenHeight
		K.Mult = (pixel / scale) - ((pixel - ratio) / scale)
		return
	end

	if InCombatLockdown() then
		if not pendingScaleApply then
			pendingScaleApply = true
			K:RegisterEvent("PLAYER_REGEN_ENABLED", ApplyScaleAfterCombat)
		end
		return
	end

	UIParent:SetScale(scale)
end

local function UpdatePixelScale(event)
	if isScaling then
		return
	end

	if InCombatLockdown() then
		if not pendingScaleApply then
			pendingScaleApply = true
			K:RegisterEvent("PLAYER_REGEN_ENABLED", ApplyScaleAfterCombat)
		end
		return
	end

	isScaling = true

	if event == "UI_SCALE_CHANGED" then
		K.ScreenWidth, K.ScreenHeight = GetPhysicalScreenSize()
	end

	K:SetupUIScale(true)
	K:SetupUIScale()

	isScaling = false
end

--========================================================
-- Initialization
--========================================================
K:RegisterEvent("PLAYER_LOGIN", function()
	SetCVar("ActionButtonUseKeyDown", 1)

	K:SetupUIScale()

	K:RegisterEvent("UI_SCALE_CHANGED", UpdatePixelScale)
	K:RegisterEvent("PLAYER_ENTERING_WORLD", UpdatePixelScale)

	K:SetSmoothingAmount(C["General"].SmoothAmount)

	if K.LibCustomGlow then
		K.ShowOverlayGlow = K.LibCustomGlow.ShowOverlayGlow
		K.HideOverlayGlow = K.LibCustomGlow.HideOverlayGlow
	end

	-- Initialize all modules
	K:InitializeModules()

	K.Modules = modules

	if K.InitCallback then
		K:InitCallback()
	end
end)

K:RegisterEvent("PLAYER_LEVEL_UP", function(_, level)
	K.Level = level
end)

--========================================================
-- AddOn list cache
--========================================================
do
	local playerName = K.Name
	for i = 1, GetNumAddOns() do
		local name, _, _, _, reason = GetAddOnInfo(i)
		if name then
			local lowerName = string_lower(name)
			K.AddOns[lowerName] = (GetAddOnEnableState(playerName, name) == 2) and (not reason or reason ~= "DEMAND_LOADED")
			K.AddOnVersion[lowerName] = C_AddOns_GetAddOnMetadata(name, "Version")
		end
	end
end

--========================================================
-- Expose Engine globally
--========================================================
_G.KkthnxUI = Engine
