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
local LE_ITEM_QUALITY_COMMON = _G.LE_ITEM_QUALITY_COMMON
local LE_ITEM_QUALITY_POOR = _G.LE_ITEM_QUALITY_POOR
local LOCALIZED_CLASS_NAMES_MALE = _G.LOCALIZED_CLASS_NAMES_MALE
local LibStub = _G.LibStub
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

local K, C, L = unpack(Engine)

-- Deprecated
LE_ITEM_QUALITY_POOR = Enum.ItemQuality.Poor
LE_ITEM_QUALITY_COMMON = Enum.ItemQuality.Common
LE_ITEM_QUALITY_UNCOMMON = Enum.ItemQuality.Uncommon
LE_ITEM_QUALITY_RARE = Enum.ItemQuality.Rare
LE_ITEM_QUALITY_EPIC = Enum.ItemQuality.Epic
LE_ITEM_QUALITY_LEGENDARY = Enum.ItemQuality.Legendary
LE_ITEM_QUALITY_ARTIFACT = Enum.ItemQuality.Artifact
LE_ITEM_QUALITY_HEIRLOOM = Enum.ItemQuality.Heirloom

K.oUF = Engine.oUF
K.cargBags = Engine.cargBags
K.Unfit = LibStub("Unfit-1.0")
K.libButtonGlow = LibStub("LibButtonGlow-1.0", true)

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
K.Race = UnitRace("player")
K.Faction = UnitFactionGroup("player")
K.Level = UnitLevel("player")
K.Client = GetLocale()
K.Realm = GetRealmName()
K.Media = "Interface\\AddOns\\KkthnxUI\\Media\\"
K.LSM = LibStub and LibStub:GetLibrary("LibSharedMedia-3.0", true)
K.ScreenWidth, K.ScreenHeight = GetPhysicalScreenSize()
K.Resolution = string_format("%dx%d", K.ScreenWidth, K.ScreenHeight)
K.TexCoords = {0.08, 0.92, 0.08, 0.92}
K.Welcome = "|cff669DFFKkthnxUI "..K.Version.." "..K.Client.."|r - /helpui"
K.ScanTooltip = CreateFrame("GameTooltip", "KKUI_ScanTooltip", nil, "GameTooltipTemplate")
K.WowPatch, K.WowBuild, K.WowRelease, K.TocVersion = GetBuildInfo()
K.WowBuild = tonumber(K.WowBuild)
K.GreyColor = "|CFF7b8489"
K.InfoColor = "|CFF669DFF"
K.InfoColorTint = "|CFFA3D3FF"
K.SystemColor = "|CFFFFCC66"

K.CodeDebug = false

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
		K.Print("Module ["..name.."] has already been registered.")
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
	local scale = math_max(0.4, math_min(1.15, 768 / K.ScreenHeight))
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
	elseif not InCombatLockdown() then
		UIParent:SetScale(scale)
	end
end

local isScaling = false
local function UpdatePixelScale(event)
	if isScaling then
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

K:RegisterEvent("PLAYER_LOGIN", function()
	K:SetupUIScale()
	K:RegisterEvent("UI_SCALE_CHANGED", UpdatePixelScale)

	for _, module in next, initQueue do
		if module.OnEnable then
			module:OnEnable()
		else
			K.Print("Module ["..module.name.."] failed to load!")
		end
	end

	K.Modules = modules
end)

function K.CheckSavedVariables()
	if not KkthnxUIData then
		KkthnxUIData = {}
	end

	if not KkthnxUIData[K.Realm] then
		KkthnxUIData[K.Realm] = {}
	end

	if not KkthnxUIData[K.Realm][K.Name] then
		KkthnxUIData[K.Realm][K.Name] = {}
	end

	if not KkthnxUIData[K.Realm][K.Name].AutoQuest then
		KkthnxUIData[K.Realm][K.Name].AutoQuest = false
	end

	if not KkthnxUIData[K.Realm][K.Name].BindType then
		KkthnxUIData[K.Realm][K.Name].BindType = 1
	end

	if not KkthnxUIData[K.Realm][K.Name].ChangeLog then
		KkthnxUIData[K.Realm][K.Name].ChangeLog = {}
	end

	if not KkthnxUIData[K.Realm][K.Name].CustomJunkList then
		KkthnxUIData[K.Realm][K.Name].CustomJunkList = {}
	end

	if not KkthnxUIData[K.Realm][K.Name].DetectVersion then
		KkthnxUIData[K.Realm][K.Name].DetectVersion = K.Version
	end

	if not KkthnxUIData[K.Realm][K.Name].FavouriteItems then
		KkthnxUIData[K.Realm][K.Name].FavouriteItems = {}
	end

	if not KkthnxUIData[K.Realm][K.Name].Mover then
		KkthnxUIData[K.Realm][K.Name].Mover = {}
	end

	if not KkthnxUIData[K.Realm][K.Name].RevealWorldMap then
		KkthnxUIData[K.Realm][K.Name].RevealWorldMap = false
	end

	if not KkthnxUIData[K.Realm][K.Name].SplitCount then
		KkthnxUIData[K.Realm][K.Name].SplitCount = 1
	end

	if not KkthnxUIData[K.Realm][K.Name].TempAnchor then
		KkthnxUIData[K.Realm][K.Name].TempAnchor = {}
	end

	if not KkthnxUIData[K.Realm][K.Name].Chat then
		KkthnxUIData[K.Realm][K.Name].Chat = {
			["Frame1"] = {
				"BOTTOMLEFT",
				"BOTTOMLEFT",
				8,
				8,
				370,
				108,
			},
			["Frame2"] = {
				"TOPLEFT",
				"TOPLEFT",
				0,
				0,
				370,
				108,
			},
			["Frame3"] = {
				"TOPLEFT",
				"TOPLEFT",
				0,
				0,
				370,
				108,
			},
			["Frame4"] = {
				"BOTTOMRIGHT",
				"BOTTOMRIGHT",
				0,
				0,
				370,
				108,
			},
		}
	end
end

function K.StoreDefaults()
	K.Defaults = {}

	for group, options in pairs(C) do
		if (not K.Defaults[group]) then
			K.Defaults[group] = {}
		end

		for option, value in pairs(options) do
			K.Defaults[group][option] = value

			if (type(C[group][option]) == "table") then
				if C[group][option].Options then
					K.Defaults[group][option] = value.Value
				else
					K.Defaults[group][option] = value
				end
			else
				K.Defaults[group][option] = value
			end
		end
	end
end

function K.LoadCustomSettings()
	local Settings

	if (not KkthnxUISettingsPerCharacter) then
		KkthnxUISettingsPerCharacter = {}
	end

	if (not KkthnxUISettingsPerCharacter[K.Realm]) then
		KkthnxUISettingsPerCharacter[K.Realm] = {}
	end

	if (not KkthnxUISettingsPerCharacter[K.Realm][K.Name]) then
		if KkthnxUISettingsPerChar ~= nil then
			-- old table for gui settings, KkthnxUISettingsPerChar is now deprecated and will be removed in a future build
			KkthnxUISettingsPerCharacter[K.Realm][K.Name] = KkthnxUISettingsPerChar
		else
			KkthnxUISettingsPerCharacter[K.Realm][K.Name] = {}
		end
	end

	if not KkthnxUISettings then
		KkthnxUISettings = {}
	end

	if KkthnxUISettingsPerCharacter[K.Realm][K.Name].General and KkthnxUISettingsPerCharacter[K.Realm][K.Name].General.UseGlobal == true then
		Settings = KkthnxUISettings
	else
		Settings = KkthnxUISettingsPerCharacter[K.Realm][K.Name]
	end

	for group, options in pairs(Settings) do
		if C[group] then
			local Count = 0

			for option, value in pairs(options) do
				if (C[group][option] ~= nil) then
					if (C[group][option] == value) then
						Settings[group][option] = nil
					else
						Count = Count + 1

						if (type(C[group][option]) == "table") then
							if C[group][option].Options then
								C[group][option].Value = value
							else
								C[group][option] = value
							end
						else
							C[group][option] = value
						end
					end
				end
			end

			-- Keeps settings clean and small
			if (Count == 0) then
				Settings[group] = nil
			end
		else
			Settings[group] = nil
		end
	end
end

K:RegisterEvent("VARIABLES_LOADED", function(event)
	-- Add SavedVariables
	K.CheckSavedVariables()
	K.StoreDefaults()
	K.LoadCustomSettings()
	-- Setup UI Scale
	K:SetupUIScale(true)
	-- Create Create Static Popups
	K.CreateStaticPopups()
	-- Some GUID Stuff
	K.GUID = UnitGUID("player")
	-- Enable GUI
	K["GUI"]:Enable()

	K:UnregisterEvent(event)
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

_G[AddOnName] = Engine