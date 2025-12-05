local AddOnName, Engine = ...

local bit_band = bit.band
local bit_bor = bit.bor
local next = next
local pairs = pairs
local select = select
local string_format = string.format
local string_lower = string.lower
local tonumber = tonumber

local BAG_ITEM_QUALITY_COLORS = BAG_ITEM_QUALITY_COLORS
local COMBATLOG_OBJECT_AFFILIATION_MINE = COMBATLOG_OBJECT_AFFILIATION_MINE
local COMBATLOG_OBJECT_AFFILIATION_PARTY = COMBATLOG_OBJECT_AFFILIATION_PARTY
local COMBATLOG_OBJECT_AFFILIATION_RAID = COMBATLOG_OBJECT_AFFILIATION_RAID
local COMBATLOG_OBJECT_CONTROL_PLAYER = COMBATLOG_OBJECT_CONTROL_PLAYER
local COMBATLOG_OBJECT_REACTION_FRIENDLY = COMBATLOG_OBJECT_REACTION_FRIENDLY
local COMBATLOG_OBJECT_TYPE_PET = COMBATLOG_OBJECT_TYPE_PET
local C_AddOns_GetAddOnMetadata = C_AddOns.GetAddOnMetadata
local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo
local CreateFrame = CreateFrame
local Enum = Enum
local GetAddOnEnableState = C_AddOns.GetAddOnEnableState
local GetAddOnInfo = C_AddOns.GetAddOnInfo
local GetBuildInfo = GetBuildInfo
local GetLocale = GetLocale
local GetNumAddOns = C_AddOns.GetNumAddOns
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

-- Create the Engine table and its sub-tables
Engine[1] = {} -- K, Main functionality
Engine[2] = {} -- C, Configuration
Engine[3] = {} -- L, Localization

-- Assign the sub-tables to local variables K, C, and L for easier access
local K, C, L = Engine[1], Engine[2], Engine[3]

-- Lib Info
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

-- AddOn Info
K.Title = C_AddOns_GetAddOnMetadata(AddOnName, "Title")
K.Version = C_AddOns_GetAddOnMetadata(AddOnName, "Version")

-- Functions
K.Noop = function() end

-- Player Info
K.Name = UnitName("player")
K.Class = select(2, UnitClass("player"))
K.Race = UnitRace("player")
K.Faction = UnitFactionGroup("player")
K.Level = UnitLevel("player")
K.Client = GetLocale()
K.Realm = GetRealmName()
K.Sex = UnitSex("player")
K.GUID = UnitGUID("player")

-- Screen Info
K.ScreenWidth, K.ScreenHeight = GetPhysicalScreenSize()
K.Resolution = string_format("%dx%d", K.ScreenWidth, K.ScreenHeight)

-- UI Info
K.TexCoords = { 0.08, 0.92, 0.08, 0.92 }
K.EasyMenu = CreateFrame("Frame", "KKUI_EasyMenu", UIParent, "UIDropDownMenuTemplate")
K.ScanTooltip = CreateFrame("GameTooltip", "KKUI_ScanTooltip", UIParent, "GameTooltipTemplate")
K.ScanTooltip:SetOwner(UIParent, "ANCHOR_NONE")

-- WoW Info
K.WowPatch, K.WowBuild, K.WowRelease, K.TocVersion = GetBuildInfo()
K.WowBuild = tonumber(K.WowBuild)
K.IsNewPatch = K.WowBuild >= 110200 -- Patch 11.2.0 or higher

-- Color Info
K.GreyColor = "|CFFC0C0C0" -- Soft gray
K.InfoColor = "|CFF5C8BCF" -- Soft blue
K.InfoColorTint = "|CFF93BAFF" -- Softened tint
K.SystemColor = "|CFFFFCC66" -- Soft gold

-- Media Info
K.MediaFolder = "Interface\\AddOns\\KkthnxUI\\Media\\"
K.UIFont = "KkthnxUIFont"
K.UIFontSize = select(2, _G.KkthnxUIFont:GetFont())
K.UIFontStyle = select(3, _G.KkthnxUIFont:GetFont())
K.UIFontOutline = "KkthnxUIFontOutline"
K.UIFontSize = select(2, _G.KkthnxUIFontOutline:GetFont())
K.UIFontStyle = select(3, _G.KkthnxUIFontOutline:GetFont())
K.LeftButton = " |TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:13:11:0:-1:512:512:12:66:230:307|t "
K.RightButton = " |TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:13:11:0:-1:512:512:12:66:333:410|t "
K.ScrollButton = " |TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:13:11:0:-1:512:512:12:66:127:204|t "

-- Lists
K.ClassList = {}
K.ClassColors = {}
K.QualityColors = {}
K.AddOns = {}
K.AddOnVersion = {}

-- Flags
-- Constants
K.PartyPetFlags = bit_bor(COMBATLOG_OBJECT_AFFILIATION_PARTY, COMBATLOG_OBJECT_REACTION_FRIENDLY, COMBATLOG_OBJECT_CONTROL_PLAYER, COMBATLOG_OBJECT_TYPE_PET)
K.RaidPetFlags = bit_bor(COMBATLOG_OBJECT_AFFILIATION_RAID, COMBATLOG_OBJECT_REACTION_FRIENDLY, COMBATLOG_OBJECT_CONTROL_PLAYER, COMBATLOG_OBJECT_TYPE_PET)

-- Tables
local eventsFrame = CreateFrame("Frame")
local events = {}
local modules = {}
local modulesQueue = {}

-- Variables
local isScaling = false
local pendingScaleApply = false

-- Deferred scale application after combat
local function ApplyScaleAfterCombat()
	-- Unregister this one-shot handler and apply scale now that we're out of combat
	K:UnregisterEvent("PLAYER_REGEN_ENABLED", ApplyScaleAfterCombat)
	pendingScaleApply = false
	K:SetupUIScale()
end

-- Functions
function K.IsMyPet(flags)
	return bit_band(flags, COMBATLOG_OBJECT_AFFILIATION_MINE) > 0
end

-- Populate the ClassList table with localized class names
for k, v in pairs(LOCALIZED_CLASS_NAMES_MALE) do
	K.ClassList[v] = k
end

for k, v in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do
	K.ClassList[v] = k
end

-- Populate the ClassColors table with the colors of each class
local colors = CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS
for class, value in pairs(colors) do
	K.ClassColors[class] = {}
	K.ClassColors[class].r = value.r
	K.ClassColors[class].g = value.g
	K.ClassColors[class].b = value.b
	K.ClassColors[class].colorStr = value.colorStr
end

-- Get the player's class color
K.r, K.g, K.b = K.ClassColors[K.Class].r, K.ClassColors[K.Class].g, K.ClassColors[K.Class].b
K.MyClassColor = string_format("|cff%02x%02x%02x", K.r * 255, K.g * 255, K.b * 255)

-- Populate the QualityColors table with the colors of each item quality
local qualityColors = BAG_ITEM_QUALITY_COLORS
for index, value in pairs(qualityColors) do
	K.QualityColors[index] = { r = value.r, g = value.g, b = value.b }
end
K.QualityColors[-1] = { r = 1, g = 1, b = 1 }
K.QualityColors[Enum.ItemQuality.Poor] = { r = 0.61, g = 0.61, b = 0.61 }
K.QualityColors[Enum.ItemQuality.Common] = { r = 1, g = 1, b = 1 } -- This is the default color, but it's included here for completeness.

local function SafeDispatch(func, event, ...)
	local ok, err = pcall(func, event, ...)
	if not ok then
		print(string_format("|cffff0000KkthnxUI callback error:|r %s (event: %s)", tostring(err), tostring(event)))
	end
end

eventsFrame:SetScript("OnEvent", function(_, event, ...)
	local funcs = events[event]
	if not funcs then
		return
	end

	for func in pairs(funcs) do
		if type(func) == "function" then
			if event == "COMBAT_LOG_EVENT_UNFILTERED" then
				SafeDispatch(func, event, CombatLogGetCurrentEventInfo())
			else
				SafeDispatch(func, event, ...)
			end
		else
			print(string_format("|cffff9900KkthnxUI:|r skipped non-function handler for '%s' (%s)", tostring(event), tostring(func)))
		end
	end
end)

function K:RegisterEvent(event, func, unit1, unit2)
	if event == "CLEU" then
		event = "COMBAT_LOG_EVENT_UNFILTERED"
	end
	if not events[event] then
		events[event] = {}
		if unit1 then
			eventsFrame:RegisterUnitEvent(event, unit1, unit2)
		else
			eventsFrame:RegisterEvent(event)
		end
	end

	-- Defensive guard: ensure 'func' is a valid key
	if not func then
		-- Add a concise debug to help identify bad registrations without hard erroring
		print(string_format("|cffff0000KkthnxUI:RegisterEvent error:|r nil callback for event '%s'", tostring(event)))
		return
	end

	-- Optional: warn if func is not callable; we store keys and call later, so just hint
	if type(func) ~= "function" then
		-- Allow non-function keys as we iterate keys later, but surface info for debugging
		-- Using tostring on func to avoid indexing nil
		print(string_format("|cffff9900KkthnxUI:RegisterEvent notice:|r non-function key registered for '%s' (%s)", tostring(event), tostring(func)))
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

function K:NewModule(name)
	if modules[name] then
		print("Module <" .. name .. "> has been registered.")
		return
	end
	local module = {}
	module.name = name
	modules[name] = module

	tinsert(modulesQueue, module)
	return module
end

function K:GetModule(name)
	if not modules[name] then
		print("Module <" .. name .. "> does not exist.")
		return
	end

	return modules[name]
end

local function GetBestScale()
	local scale = max(0.4, min(1.15, 768 / K.ScreenHeight))
	return K.Round(scale, 2)
end

-- Function to set up UI scale
function K:SetupUIScale(init)
	if C["General"].AutoScale then
		C["General"].UIScale = GetBestScale()
	end

	local scale = C["General"].UIScale
	if init then
		local pixel = 1
		local ratio = 768 / K.ScreenHeight
		K.Mult = (pixel / scale) - ((pixel - ratio) / scale)
	else
		if InCombatLockdown() then
			-- Defer applying UIParent scale until after combat to avoid taint/mismatch
			if not pendingScaleApply then
				pendingScaleApply = true
				K:RegisterEvent("PLAYER_REGEN_ENABLED", ApplyScaleAfterCombat)
			end
			return
		end

		UIParent:SetScale(scale)
	end
end

-- Function to update pixel scale
local function UpdatePixelScale(event)
	if isScaling then
		return
	end

	-- If this fired during combat, schedule a safe apply when leaving combat
	if InCombatLockdown() then
		if not pendingScaleApply then
			pendingScaleApply = true
			K:RegisterEvent("PLAYER_REGEN_ENABLED", ApplyScaleAfterCombat)
		end
		return
	end

	isScaling = true

	if event == "UI_SCALE_CHANGED" then
		K.ScreenWidth, K.ScreenHeight = GetPhysicalScreenSize() -- Ensure globals are updated
	end

	K:SetupUIScale(true)
	K:SetupUIScale()

	isScaling = false
end

-- Register events for initializing the addon
K:RegisterEvent("PLAYER_LOGIN", function()
	-- Set CVars
	SetCVar("ActionButtonUseKeyDown", 1)

	-- Set up UI scaling
	K:SetupUIScale()

	-- Register event for UI scale change
	K:RegisterEvent("UI_SCALE_CHANGED", UpdatePixelScale)
	K:RegisterEvent("PLAYER_ENTERING_WORLD", UpdatePixelScale)

	-- Set smoothing amount
	K:SetSmoothingAmount(C["General"].SmoothAmount)

	if K.LibCustomGlow then
		K.ShowOverlayGlow = K.LibCustomGlow.ShowOverlayGlow
		K.HideOverlayGlow = K.LibCustomGlow.HideOverlayGlow
	end

	-- Enable modules
	for _, module in ipairs(modulesQueue) do
		assert(module.OnEnable, "Module has no OnEnable function.")
		assert(not module.Enabled, "Module is already enabled.")

		module:OnEnable()
		module.Enabled = true
	end

	-- Set modules
	K.Modules = modules

	-- Call initialization callback if it exists
	if K.InitCallback then
		K:InitCallback()
	end
end)

-- Register event for player level up
K:RegisterEvent("PLAYER_LEVEL_UP", function(_, level)
	K.Level = level
end)

-- Initialize AddOn information
for i = 1, GetNumAddOns() do
	local name, _, _, _, reason = GetAddOnInfo(i)
	local lowerName = string.lower(name)
	K.AddOns[lowerName] = GetAddOnEnableState(K.Name, name) == 2 and (not reason or reason ~= "DEMAND_LOADED")
	K.AddOnVersion[lowerName] = C_AddOns.GetAddOnMetadata(name, "Version")
end

-- Expose the Engine globally
_G.KkthnxUI = Engine
