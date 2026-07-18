--[[-----------------------------------------------------------------------------
Addon: KkthnxUI
Author: Josh "Kkthnx" Russell
Notes:
- Purpose: Core initialization, engine setup, and module management.
- Combat: Runs during combat to handle events and scale updates.
-----------------------------------------------------------------------------]]

local AddOnName, Engine = ...

-- ---------------------------------------------------------------------------
-- Locals & Global Caching
-- ---------------------------------------------------------------------------

-- PERF: Lua 5.1 local caching for better performance in hotspots.
local _G = _G

local pairs = pairs
local select = select
local tonumber = tonumber
local type = type

local max = max
local min = min
local math_abs = math.abs
local math_floor = math.floor

local print = print

local bit_band = bit.band
local bit_bor = bit.bor

local string_format = string.format
local string_lower = string.lower

local table_insert = table.insert

local next = next

-- ---------------------------------------------------------------------------
-- WoW Globals & API Caching
-- ---------------------------------------------------------------------------

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

-- PERF: Cache additional high-traffic APIs.
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

-- ---------------------------------------------------------------------------
-- Engine & Tables
-- ---------------------------------------------------------------------------

Engine[1] = {} -- K: Utilities/Core
Engine[2] = {} -- C: Configuration
Engine[3] = {} -- L: Locales

local K, C = Engine[1], Engine[2]

-- ---------------------------------------------------------------------------
-- Library Support
-- ---------------------------------------------------------------------------

K.LibEasyMenu = LibStub("LibEasyMenu-1.0-KkthnxUI", true)
K.LibBase64 = LibStub("LibBase64-1.0-KkthnxUI", true)
K.LibActionButton = LibStub("LibActionButton-1.0-KkthnxUI", true)
K.LibDeflate = LibStub("LibDeflate-KkthnxUI", true)
K.LibSharedMedia = LibStub("LibSharedMedia-3.0", true)
K.LibSerialize = LibStub("LibSerialize-KkthnxUI", true)
K.LibCustomGlow = LibStub("LibCustomGlow-1.0-KkthnxUI", true)
K.LibUnfit = LibStub("LibUnfit-1.0-KkthnxUI", true)
K.cargBags = Engine and Engine.cargBags
K.oUF = Engine and Engine.oUF

-- ---------------------------------------------------------------------------
-- AddOn Metadata
-- ---------------------------------------------------------------------------

K.Title = C_AddOns_GetAddOnMetadata(AddOnName, "Title")
K.Version = C_AddOns_GetAddOnMetadata(AddOnName, "Version")

-- ---------------------------------------------------------------------------
-- Global Functions
-- ---------------------------------------------------------------------------

K.Noop = function() end

-- ---------------------------------------------------------------------------
-- Character Data
-- ---------------------------------------------------------------------------

K.Name = UnitName("player")
K.Class = select(2, UnitClass("player"))
K.Race = UnitRace("player")
K.Faction = UnitFactionGroup("player")
K.Level = UnitLevel("player")
K.Client = GetLocale() -- NOTE: This is the user's game client locale (enUS, deDE, etc.)
K.Realm = GetRealmName()
K.Sex = UnitSex("player")
K.GUID = UnitGUID("player")

-- ---------------------------------------------------------------------------
-- Display Details
-- ---------------------------------------------------------------------------

K.ScreenWidth, K.ScreenHeight = GetPhysicalScreenSize()
K.Resolution = string_format("%dx%d", K.ScreenWidth, K.ScreenHeight)

-- ---------------------------------------------------------------------------
-- Game & UI Components
-- ---------------------------------------------------------------------------

K.TexCoords = { 0.08, 0.92, 0.08, 0.92 }
K.EasyMenu = CreateFrame("Frame", "KKUI_EasyMenu", UIParent, "UIDropDownMenuTemplate")
K.ScanTooltip = CreateFrame("GameTooltip", "KKUI_ScanTooltip", UIParent, "GameTooltipTemplate")
K.ScanTooltip:SetOwner(UIParent, "ANCHOR_NONE")

-- ---------------------------------------------------------------------------
-- Expansion & Patch Info
-- ---------------------------------------------------------------------------

K.WowPatch, K.WowBuild, K.WowRelease, K.TocVersion = GetBuildInfo()
K.WowBuild = tonumber(K.WowBuild)
K.IsNewPatch = K.WowBuild >= 110200 -- COMPAT: Handle breaking API changes in Patch 11.2.0+

-- ---------------------------------------------------------------------------
-- Color Definitions
-- ---------------------------------------------------------------------------

K.GreyColor = "|CFFC0C0C0"
K.InfoColor = "|CFF5C8BCF"
K.InfoColorTint = "|CFF93BAFF"
K.SystemColor = "|CFFFFCC66"

-- ---------------------------------------------------------------------------
-- Media & Fonts
-- ---------------------------------------------------------------------------

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

-- ---------------------------------------------------------------------------
-- Tracking Lists
-- ---------------------------------------------------------------------------

K.ClassList = {}
K.ClassColors = {}
K.QualityColors = {}
K.AddOns = {}
K.AddOnVersion = {}

-- ---------------------------------------------------------------------------
-- Constants & Flags
-- ---------------------------------------------------------------------------

K.PartyPetFlags = bit_bor(COMBATLOG_OBJECT_AFFILIATION_PARTY, COMBATLOG_OBJECT_REACTION_FRIENDLY, COMBATLOG_OBJECT_CONTROL_PLAYER, COMBATLOG_OBJECT_TYPE_PET)
K.RaidPetFlags = bit_bor(COMBATLOG_OBJECT_AFFILIATION_RAID, COMBATLOG_OBJECT_REACTION_FRIENDLY, COMBATLOG_OBJECT_CONTROL_PLAYER, COMBATLOG_OBJECT_TYPE_PET)

-- ---------------------------------------------------------------------------
-- Internal State
-- ---------------------------------------------------------------------------

local eventsFrame = CreateFrame("Frame")
local events = {} -- events[event] = { func1 = true, func2 = true }
local unitEvents = {} -- events subscribed via RegisterUnitEvent
local modules = {}
local modulesQueue = {}

-- REASON: eventsFrame:RegisterEvent is protected during combat lockdown. When a
-- module subscribes to a new event mid-fight (e.g. lazy CLEU from a nameplate
-- enabling), queue the frame registration until regen instead of erroring.
local pendingEventRegistration = {}

local function FlushPendingEventRegistration()
	events["PLAYER_REGEN_ENABLED"][FlushPendingEventRegistration] = nil

	for event, info in pairs(pendingEventRegistration) do
		if events[event] then
			if info.unit1 then
				eventsFrame:RegisterUnitEvent(event, info.unit1, info.unit2)
			else
				eventsFrame:RegisterEvent(event)
			end
		end
	end
	pendingEventRegistration = {}
end

local function RegisterEventsFrame(event, unit1, unit2)
	if InCombatLockdown() then
		pendingEventRegistration[event] = { unit1 = unit1, unit2 = unit2 }
		local regenHandlers = events["PLAYER_REGEN_ENABLED"]
		if not regenHandlers then
			regenHandlers = {}
			events["PLAYER_REGEN_ENABLED"] = regenHandlers
		end
		regenHandlers[FlushPendingEventRegistration] = true
		return
	end

	if unit1 then
		eventsFrame:RegisterUnitEvent(event, unit1, unit2)
	else
		eventsFrame:RegisterEvent(event)
	end
end

local isScaling = false
local pendingScaleApply = false

-- REASON: Protected frames cannot be scaled in combat; defer until regen enabled.
local function ApplyScaleAfterCombat()
	K:UnregisterEvent("PLAYER_REGEN_ENABLED", ApplyScaleAfterCombat)
	pendingScaleApply = false
	K:SetupUIScale()
end

-- ---------------------------------------------------------------------------
-- Utility Helpers
-- ---------------------------------------------------------------------------

function K.IsMyPet(flags)
	return bit_band(flags, COMBATLOG_OBJECT_AFFILIATION_MINE) > 0
end

-- NOTE: Use localized class names for lookup tables where tokens aren't available.
for classToken, localizedName in pairs(LOCALIZED_CLASS_NAMES_MALE) do
	K.ClassList[localizedName] = classToken
end
for classToken, localizedName in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do
	K.ClassList[localizedName] = classToken
end

-- REASON: Prefer CUSTOM_CLASS_COLORS if a color-modifying addon is present.
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

-- ---------------------------------------------------------------------------
-- Quality Colors
-- ---------------------------------------------------------------------------

for index, value in pairs(BAG_ITEM_QUALITY_COLORS) do
	K.QualityColors[index] = { r = value.r, g = value.g, b = value.b }
end
K.QualityColors[-1] = { r = 1, g = 1, b = 1 }
K.QualityColors[Enum.ItemQuality.Poor] = { r = 0.61, g = 0.61, b = 0.61 }
K.QualityColors[Enum.ItemQuality.Common] = { r = 1, g = 1, b = 1 }

-- ---------------------------------------------------------------------------
-- Event System
-- ---------------------------------------------------------------------------

-- REASON: Pre-register regen so combat-deferred event subscriptions can queue
-- FlushPendingEventRegistration without calling RegisterEvent again in combat.
eventsFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
events["PLAYER_REGEN_ENABLED"] = {}

-- NOTE: Centralized dispatcher to minimize the number of OnEvent handlers.
eventsFrame:SetScript("OnEvent", function(_, event, ...)
	local funcs = events[event]
	if not funcs then
		return
	end

	if event == "COMBAT_LOG_EVENT_UNFILTERED" then
		-- PERF: Fetch the CLEU payload once per event, then fan it out to all listeners.
		local timestamp, eventType, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName
		local destFlags, destRaidFlags, arg12, arg13, arg14, arg15, arg16, arg17
		local arg18, arg19, arg20, arg21, arg22, arg23, arg24, arg25

		timestamp, eventType, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, arg12, arg13, arg14, arg15, arg16, arg17, arg18, arg19, arg20, arg21, arg22, arg23, arg24, arg25 = CombatLogGetCurrentEventInfo()

		for func, context in pairs(funcs) do
			if context == true then
				func(event, timestamp, eventType, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, arg12, arg13, arg14, arg15, arg16, arg17, arg18, arg19, arg20, arg21, arg22, arg23, arg24, arg25)
			else
				func(context, event, timestamp, eventType, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, arg12, arg13, arg14, arg15, arg16, arg17, arg18, arg19, arg20, arg21, arg22, arg23, arg24, arg25)
			end
		end
	else
		for func, context in pairs(funcs) do
			if context == true then
				func(event, ...)
			else
				func(context, event, ...)
			end
		end
	end
end)

-- MIDNIGHT (12.0): do NOT register COMBAT_LOG_EVENT_UNFILTERED here. Registering it
-- from the addon-load bootstrap chunk runs during the restricted load phase and gets
-- blocked (ADDON_ACTION_BLOCKED at Frame:RegisterEvent), which then taints the rest of
-- KkthnxUI's init and floods taint.log. Register CLEU lazily from a real consumer
-- after login instead: K:RegisterEvent below performs the actual
-- eventsFrame:RegisterEvent the first time a module subscribes (post-PLAYER_LOGIN).

function K:RegisterEvent(event, func)
	if event == "CLEU" then
		event = "COMBAT_LOG_EVENT_UNFILTERED"
	end

	if not func or (type(func) ~= "function" and type(func) ~= "string") then
		K.Print(string_format("RegisterEvent error: invalid function for '%s'", event))
		return
	end

	if not events[event] then
		events[event] = {}
		RegisterEventsFrame(event)
	end

	events[event][func] = true
end

function K:RegisterUnitEvent(event, func, unit1, unit2)
	if not func or type(func) ~= "function" then
		K.Print(string_format("RegisterUnitEvent error: invalid function for '%s'", event))
		return
	end

	if not unit1 then
		K.Print(string_format("RegisterUnitEvent error: missing unit token for '%s'", event))
		return
	end

	if not events[event] then
		events[event] = {}
		unitEvents[event] = true
		RegisterEventsFrame(event, unit1, unit2)
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
			if event == "PLAYER_REGEN_ENABLED" then
				return
			end

			events[event] = nil
			unitEvents[event] = nil
			pendingEventRegistration[event] = nil
			if not InCombatLockdown() then
				eventsFrame:UnregisterEvent(event)
			end
		end
	end
end

-- ---------------------------------------------------------------------------
-- Module Framework
-- ---------------------------------------------------------------------------

function K:NewModule(name, noReport)
	if modules[name] then
		K.Print(string_format("Module <%s> has already been registered.", name))
		return modules[name]
	end

	local internal = { name = name, IsEnabled = false, noReport = noReport }
	if noReport then
		internal.OnEnable = K.Noop
	end
	local module = setmetatable({}, {
		__index = internal,
		__newindex = function(_, k, v)
			if k == "OnEnable" or k == "OnDisable" or k == "OnInitialize" then
				if internal[k] ~= nil and internal[k] ~= K.Noop then
					K.Print(string_format("|cffff0000KkthnxUI Error:|r Module [%s] already has an [%s] function. This choice will overwrite the previous one! Please check your module code.", name, k))
				end
			end
			internal[k] = v
		end,
	})

	module.Toggle = function(_, state)
		if state then
			K:EnableModule(name)
		else
			K:DisableModule(name)
		end
	end

	modules[name] = module
	table_insert(modulesQueue, module)

	return module
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
		K:EnableModule(module.name)
	end
end

function K:EnableModule(name)
	local module = modules[name]
	if not module or module.IsEnabled then
		return
	end

	if module.OnEnable then
		module:OnEnable()
		module.IsEnabled = true
	else
		K.Print(string_format("Module <%s> failed to initialize: Missing OnEnable function.", name))
	end
end

function K:DisableModule(name)
	local module = modules[name]
	if not module or not module.IsEnabled then
		return
	end

	if module.OnDisable then
		module:OnDisable()
	end
	module.IsEnabled = false
end

-- ---------------------------------------------------------------------------
-- Secure Action Helpers
-- ---------------------------------------------------------------------------

-- WARNING: These functions deal with protected states and must remain taint-safe.
function K:RegisterStateDriver(frame, state, value)
	if not frame or not state or not value then
		print(string_format("|cffff0000KkthnxUI:RegisterStateDriver error:|r invalid arguments"))
		return
	end
	RegisterStateDriver(frame, state, value)
end

K.HookSecureFunc = hooksecurefunc

-- ---------------------------------------------------------------------------
-- UI Scaling (exact perfect scale — no 2-decimal rounding)
-- ---------------------------------------------------------------------------

-- Incident (UIScale, Jul 2026): K.Round(scale, 2) turned 768/1440≈0.5333 into 0.53
-- and soft 1px borders. Keep full precision; Mult = perfect / uiScale.
local function GetPerfectScale()
	return max(0.4, min(1.15, 768 / K.ScreenHeight))
end

local function GetBestScale()
	return GetPerfectScale()
end

-- Truncated AutoScale leftovers (0.53, 0.71, …) → exact perfect when AutoScale is on.
local function MigrateTruncatedAutoScale()
	if not C["General"].AutoScale then
		return
	end
	local perfect = GetPerfectScale()
	local stored = C["General"].UIScale
	if type(stored) ~= "number" then
		return
	end
	-- Old AutoScale wrote Round(perfect, 2); swap back to the exact value.
	local truncated = math_floor(perfect * 100 + 0.5) / 100
	if math_abs(stored - truncated) < 0.0001 and math_abs(stored - perfect) > 0.0001 then
		C["General"].UIScale = perfect
	end
end

function K:SetupUIScale(init)
	MigrateTruncatedAutoScale()

	if C["General"].AutoScale then
		C["General"].UIScale = GetBestScale()
	end

	local scale = C["General"].UIScale
	if init then
		if K.UpdatePixelMult then
			K.UpdatePixelMult()
		else
			-- Core/Functions may not be loaded yet on very early calls.
			local perfect = 768 / K.ScreenHeight
			C.Mult = perfect / (scale ~= 0 and scale or 1)
		end
		return
	end

	if InCombatLockdown() then
		-- WARNING: Protected frames cannot be scaled in combat; defer.
		if not pendingScaleApply then
			pendingScaleApply = true
			K:RegisterEvent("PLAYER_REGEN_ENABLED", ApplyScaleAfterCombat)
		end
		return
	end

	UIParent:SetScale(scale)
	if K.UpdatePixelMult then
		K.UpdatePixelMult()
	end
end

local function UpdatePixelScale(event)
	if isScaling then
		return
	end

	-- REASON: Always refresh screen dimensions and recalculate C.Mult immediately, even
	-- during combat. Only UIParent:SetScale is protected by combat lockdown and must be
	-- deferred. Recalc Mult immediately; only SetScale waits for regen.
	if event == "UI_SCALE_CHANGED" then
		K.ScreenWidth, K.ScreenHeight = GetPhysicalScreenSize()
	end
	K:SetupUIScale(true)

	-- WARNING: UIParent:SetScale is a protected call; defer past combat lockdown.
	if InCombatLockdown() then
		if not pendingScaleApply then
			pendingScaleApply = true
			K:RegisterEvent("PLAYER_REGEN_ENABLED", ApplyScaleAfterCombat)
		end
		return
	end

	isScaling = true
	K:SetupUIScale()
	isScaling = false
end

-- ---------------------------------------------------------------------------
-- Final Initialization
-- ---------------------------------------------------------------------------

K:RegisterEvent("PLAYER_LOGIN", function()
	-- NOTE: Use KeyDown for better responsiveness.
	SetCVar("ActionButtonUseKeyDown", 1)

	K:SetupUIScale()

	K:RegisterEvent("UI_SCALE_CHANGED", UpdatePixelScale)
	K:RegisterEvent("PLAYER_ENTERING_WORLD", UpdatePixelScale)

	K:SetSmoothingAmount(C["General"].SmoothAmount)

	if K.LibCustomGlow then
		K.ShowOverlayGlow = K.LibCustomGlow.ShowOverlayGlow
		K.HideOverlayGlow = K.LibCustomGlow.HideOverlayGlow
	end

	-- Initialize all registered modules.
	K:InitializeModules()

	K.Modules = modules

	if K.InitCallback then
		K:InitCallback()
	end
end)

K:RegisterEvent("PLAYER_LEVEL_UP", function(_, level)
	K.Level = level
end)

-- ---------------------------------------------------------------------------
-- AddOn Cache
-- ---------------------------------------------------------------------------

-- NOTE: Pre-cache addon statuses to avoid repetitive C_AddOns calls.
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

-- ---------------------------------------------------------------------------
-- Global Exposure
-- ---------------------------------------------------------------------------

-- WARNING: Exposing the engine globally for other modules and external support.
_G.KkthnxUI = Engine
