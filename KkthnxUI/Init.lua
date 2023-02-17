local AddOnName, Engine = ...

local bit_band = bit.band
local bit_bor = bit.bor
local math_max = math.max
local math_min = math.min
local next = next
local pairs = pairs
local select = select
local string_format = string.format
local string_lower = string.lower
local table_insert = table.insert
local tonumber = tonumber
local unpack = unpack

local BAG_ITEM_QUALITY_COLORS = BAG_ITEM_QUALITY_COLORS
local COMBATLOG_OBJECT_AFFILIATION_MINE = COMBATLOG_OBJECT_AFFILIATION_MINE
local COMBATLOG_OBJECT_AFFILIATION_PARTY = COMBATLOG_OBJECT_AFFILIATION_PARTY
local COMBATLOG_OBJECT_AFFILIATION_RAID = COMBATLOG_OBJECT_AFFILIATION_RAID
local COMBATLOG_OBJECT_CONTROL_PLAYER = COMBATLOG_OBJECT_CONTROL_PLAYER
local COMBATLOG_OBJECT_REACTION_FRIENDLY = COMBATLOG_OBJECT_REACTION_FRIENDLY
local COMBATLOG_OBJECT_TYPE_PET = COMBATLOG_OBJECT_TYPE_PET
local CUSTOM_CLASS_COLORS = CUSTOM_CLASS_COLORS
local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo
local CreateFrame = CreateFrame
local Enum = Enum
local GetAddOnEnableState = GetAddOnEnableState
local GetAddOnInfo = GetAddOnInfo
local GetAddOnMetadata = GetAddOnMetadata
local GetBuildInfo = GetBuildInfo
local GetLocale = GetLocale
local GetNumAddOns = GetNumAddOns
local GetPhysicalScreenSize = GetPhysicalScreenSize
local GetRealmName = GetRealmName
local LOCALIZED_CLASS_NAMES_FEMALE = LOCALIZED_CLASS_NAMES_FEMALE
local LOCALIZED_CLASS_NAMES_MALE = LOCALIZED_CLASS_NAMES_MALE
local LibStub = LibStub
local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local UnitClass = UnitClass
local UnitFactionGroup = UnitFactionGroup
local UnitGUID = UnitGUID
local UnitLevel = UnitLevel
local UnitName = UnitName
local UnitRace = UnitRace
local UnitSex = UnitSex

-- Engine
Engine[1] = {} -- K, Main
Engine[2] = {} -- C, Config
Engine[3] = {} -- L, Locale

local K, C, L = unpack(Engine)

-- Track memory usage for each sub-table
local memoryUsage = {
	K = 0,
	C = 0,
	L = 0,
}

-- Function to update the memory usage for a sub-table
local function updateMemoryUsage(tableName, usage)
	memoryUsage[tableName] = usage
	print(string.format("Memory usage for %s: %d KB", tableName, usage))
end

-- Periodically check memory usage for each sub-table
local function checkMemoryUsage()
	collectgarbage()
	local Kusage = collectgarbage("count")
	collectgarbage()
	local Cusage = collectgarbage("count")
	collectgarbage()
	local Lusage = collectgarbage("count")

	updateMemoryUsage("K", Kusage)
	updateMemoryUsage("C", Cusage)
	updateMemoryUsage("L", Lusage)
end

-- Call the checkMemoryUsage function every 5 minutes
C_Timer.NewTicker(5 * 60, checkMemoryUsage)

-- Lib Info
K.LibBase64 = LibStub("LibBase64-1.0-KkthnxUI")
K.LibActionButton = LibStub("LibActionButton-1.0")
K.LibChangeLog = LibStub("LibChangelog-KkthnxUI")
K.LibDeflate = LibStub("LibDeflate-KkthnxUI")
K.LibSharedMedia = LibStub("LibSharedMedia-3.0", true)
K.LibRangeCheck = LibStub("LibRangeCheck-2.0-KkthnxUI")
K.LibSerialize = LibStub("LibSerialize-KkthnxUI")
K.LibCustomGlow = LibStub("LibCustomGlow-1.0-KkthnxUI", true)
K.LibUnfit = LibStub("Unfit-1.0-KkthnxUI")
K.cargBags = Engine.cargBags
K.oUF = Engine.oUF

-- AddOn Info
K.Title = GetAddOnMetadata(AddOnName, "Title")
K.Version = GetAddOnMetadata(AddOnName, "Version")

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

-- WoW Info
K.WowPatch, K.WowBuild, K.WowRelease, K.TocVersion = GetBuildInfo()
K.WowBuild = tonumber(K.WowBuild)
K.IsNewPatch = K.TocVersion >= 100007 -- 10.0.7

-- Color Info
K.GreyColor = "|CFFC0C0C0"
K.InfoColor = "|CFF669DFF"
K.InfoColorTint = "|CFF3ba1c5" -- 30% Tint
K.SystemColor = "|CFFFFCC66"

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
K.PartyPetFlags = bit_bor(COMBATLOG_OBJECT_AFFILIATION_PARTY, COMBATLOG_OBJECT_REACTION_FRIENDLY, COMBATLOG_OBJECT_CONTROL_PLAYER, COMBATLOG_OBJECT_TYPE_PET)
K.RaidPetFlags = bit_bor(COMBATLOG_OBJECT_AFFILIATION_RAID, COMBATLOG_OBJECT_REACTION_FRIENDLY, COMBATLOG_OBJECT_CONTROL_PLAYER, COMBATLOG_OBJECT_TYPE_PET)

local eventsFrame = CreateFrame("Frame")
local events = {}
local modules = {}
local modulesQueue = {}
local isScaling = false

function K.IsMyPet(flags)
	return bit_band(flags, COMBATLOG_OBJECT_AFFILIATION_MINE) > 0
end

for k, v in pairs(LOCALIZED_CLASS_NAMES_MALE) do
	K.ClassList[v] = k
end

for k, v in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do
	K.ClassList[v] = k
end

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

local qualityColors = BAG_ITEM_QUALITY_COLORS
for index, value in pairs(qualityColors) do
	K.QualityColors[index] = { r = value.r, g = value.g, b = value.b }
end
K.QualityColors[-1] = { r = 1, g = 1, b = 1 }
K.QualityColors[Enum.ItemQuality.Poor] = { r = 0.61, g = 0.61, b = 0.61 }
K.QualityColors[Enum.ItemQuality.Common] = { r = 1, g = 1, b = 1 }

eventsFrame:SetScript("OnEvent", function(_, event, ...)
	for func in pairs(events[event]) do
		if event == "COMBAT_LOG_EVENT_UNFILTERED" then
			func(event, CombatLogGetCurrentEventInfo())
		else
			func(event, ...)
		end
	end
end)

-- Keep track of registered events and their listeners
local registeredEvents = {}

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
		-- Log that a new event has been registered and by which function
		--print(string.format("K:RegisterEvent - Registered event '%s' with function '%s'", event, tostring(func)))
	end

	events[event][func] = true
	-- Log that a new listener has been added to the event
	--print(string.format("K:RegisterEvent - Added listener to event '%s' with function '%s'", event, tostring(func)))

	-- Keep track of the registered event and its listener
	if not registeredEvents[event] then
		registeredEvents[event] = {}
	end
	table.insert(registeredEvents[event], func)
end

function K:UnregisterEvent(event, func)
	if event == "CLEU" then
		event = "COMBAT_LOG_EVENT_UNFILTERED"
	end

	local funcs = events[event]
	if funcs and funcs[func] then
		funcs[func] = nil
		-- Log that a listener has been removed from the event
		--print(string.format("K:UnregisterEvent - Removed listener from event '%s' with function '%s'", event, tostring(func)))

		if not next(funcs) then
			events[event] = nil
			eventsFrame:UnregisterEvent(event)
			-- Log that the event has been unregistered
			--print(string.format("K:UnregisterEvent - Unregistered event '%s'", event))
		end
	end

	-- Remove the listener from the registered events list
	if registeredEvents[event] then
		for i, f in ipairs(registeredEvents[event]) do
			if f == func then
				table.remove(registeredEvents[event], i)
				break
			end
		end
	end
end

-- Modules
function K:NewModule(name)
	if modules[name] then
		error(("Usage: K:NewModule(" .. name .. "): Module '%s' already exists."):format(name), 2)
		return
	end

	local module = {}
	module.name = name
	modules[name] = module

	table_insert(modulesQueue, module)

	return module
end

function K:GetModule(name)
	if not modules[name] then
		error(("Usage: K:GetModule(" .. name .. ") Cannot find Module '%s'."):format(tostring(name)), 2)
		return
	end

	return modules[name]
end

local function GetBestScale()
	return K.Round(math.max(0.4, math.min(1.15, 768 / K.ScreenHeight)), 2)
end

function K.SetupUIScale(init)
	if C["General"].AutoScale then
		C["General"].UIScale = GetBestScale()
	end

	local scale = C["General"].UIScale
	if not InCombatLockdown() then
		UIParent:SetScale(scale)
	end

	if init then
		local ratio = 768 / K.ScreenHeight
		K.Mult = (1 / scale) - ((1 - ratio) / scale)
	end
end

local function UpdatePixelScale(event)
	if isScaling then
		return
	end
	isScaling = true

	if event == "UI_SCALE_CHANGED" then
		K.ScreenWidth, K.ScreenHeight = GetPhysicalScreenSize()
	end

	K.SetupUIScale(true)
	K.SetupUIScale()

	isScaling = false
end

K:RegisterEvent("PLAYER_LOGIN", function()
	SetCVar("ActionButtonUseKeyDown", 1)
	K.SetupUIScale()
	K:RegisterEvent("UI_SCALE_CHANGED", UpdatePixelScale)
	K:SetSmoothingAmount(C["General"].SmoothAmount)

	for _, module in next, modulesQueue do
		if module.OnEnable and not module.Enabled then
			module:OnEnable()
			module.Enabled = true
		else
			error(("Module ('%s') has failed to load."):format(tostring(module.name)), 2)
		end
	end

	K.Modules = modules

	if K.InitCallback then
		K:InitCallback()
	end
end)

-- Event return values were wrong: https://wow.gamepedia.com/PLAYER_LEVEL_UP
K:RegisterEvent("PLAYER_LEVEL_UP", function(_, level)
	if not K.Level then
		return
	end

	K.Level = level
end)

-- Save original ChatFrame_DisplayTimePlayed function
local originalChatFrame_DisplayTimePlayed = ChatFrame_DisplayTimePlayed
-- Override ChatFrame_DisplayTimePlayed function
ChatFrame_DisplayTimePlayed = function(_, totalTime, levelTime)
	-- Get player's class color
	local classColor = K.ClassColors[K.Class].colorStr
	-- Get player's name with class color
	local name = string.format("|c%s%s|r", classColor, K.Name)
	-- Get player's money as string
	local money = GetMoneyString(GetMoney())
	-- Get player's current specialization or NONE if no specialization is selected
	local spec = select(2, GetSpecializationInfo(GetSpecialization())) or NONE

	-- Create total time played message
	local totalTimeMessage = string.format(K.InfoColor .. "Total time played: %s", K.GreyColor .. SecondsToTime(totalTime))
	-- Create level time played message
	local levelTimeMessage = string.format(K.InfoColor .. "Time played this level: %s", K.GreyColor .. SecondsToTime(levelTime))
	-- Create money message
	local moneyMessage = string.format(K.InfoColor .. "Money: %s", K.GreyColor .. money)

	-- Create player info message
	local playerInfo = string.format("%s - %s - %s - %s", name, K.Race, K.Faction, spec)
	-- Print player info
	print(playerInfo)
	-- Print total time played message
	print(totalTimeMessage)
	-- Print level time played message
	print(levelTimeMessage)
	-- Print money message
	print(moneyMessage)
end

for i = 1, GetNumAddOns() do
	local Name, _, _, _, Reason = GetAddOnInfo(i)
	K.AddOns[string_lower(Name)] = GetAddOnEnableState(K.Name, Name) == 2 and (not Reason or Reason ~= "DEMAND_LOADED")
	K.AddOnVersion[string_lower(Name)] = GetAddOnMetadata(Name, "Version")
end

_G.KkthnxUI = Engine
