local AddOnName, Engine = ...

--[[
-- NOTE: KkthnxUI uses "#4488ff color RGB value is (68, 136, 255)" for its primary color
-- NOTE: KkthnxUI uses "#ffbb44 color RGB value is (255, 187, 68)" for its secondary color

-- NOTE: Uncomment this to see the primary color
print("|cff4488ff#4488ff color|r")
-- NOTE: Uncomment this to see the secondary color
print("|cffffbb44#ffbb44 color|r")
]]--

-- Lua API
local _G = _G
local string_lower = string.lower
local select = select

-- Wow API
local GetAddOnEnableState = _G.GetAddOnEnableState
local GetAddOnInfo = _G.GetAddOnInfo
local GetBuildInfo = _G.GetBuildInfo
local GetSpecialization = _G.GetSpecialization
local UnitClass = _G.UnitClass
local UnitName = _G.UnitName
local UnitLevel = _G.UnitLevel

local AddOn = LibStub("AceAddon-3.0"):NewAddon(AddOnName, "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0", "AceHook-3.0")
-- local Locale = LibStub("AceLocale-3.0"):GetLocale(AddOnName, false)

Engine[1] = AddOn
Engine[2] = {}
Engine[3] = {}

_G[AddOnName] = Engine -- Allow other addons to use our Engine

-- Check role to return what role the player is.
function AddOn:UnitRole()
	local playerSpec = GetSpecialization()
	local playerClass = select(2, UnitClass("player"))
	local playerLevel = UnitLevel("player")

	if (not playerSpec or playerLevel > 10) then return end

	local playerRoles = {
		["DEATHKNIGHT"] = {"Tank", "Melee", "Melee"},
		["DEMONHUNTER"] = {"Melee", "Tank"},
		["DRUID"] = {"Caster", "Melee", "Tank", "Healer"},
		["HUNTER"] = {"Melee", "Melee", "Melee"},
		["MAGE"] = {"Caster", "Caster", "Caster"},
		["MONK"] = {"Tank", "Healer", "Melee"},
		["PALADIN"] = {"Healer", "Tank", "Melee"},
		["PRIEST"] = {"Healer", "Healer", "Caster"},
		["ROGUE"] = {"Melee", "Melee", "Melee"},
		["SHAMAN"] = {"Caster", "Melee", "Healer"},
		["WARLOCK"] = {"Caster", "Caster", "Caster"},
		["WARRIOR"] = {"Melee", "Melee", "Tank"}
	}

	return playerRoles[playerClass][playerSpec]
end

AddOn.Title = GetAddOnMetadata(AddOnName, "Title")
AddOn.Version = GetAddOnMetadata(AddOnName, "Version")
AddOn.Noop = function() return end
AddOn.Name = UnitName("player")
AddOn.GUID = UnitGUID("player")
AddOn.Class = select(2, UnitClass("player"))
AddOn.Role = AddOn.UnitRole("player")
AddOn.Spec = GetSpecialization() or 0
AddOn.Race = select(2, UnitRace("player"))
AddOn.Level = UnitLevel("player")
AddOn.Client = GetLocale()
AddOn.Realm = GetRealmName()
AddOn.LSM = LibStub and LibStub:GetLibrary("LibSharedMedia-3.0", true)
AddOn.OmniCC = select(4, GetAddOnInfo("OmniCC"))
AddOn.Resolution = ({GetScreenResolutions()})[GetCurrentResolution()] or GetCVar("gxWindowedResolution")
AddOn.ScreenWidth, AddOn.ScreenHeight = DecodeResolution(AddOn.Resolution)
AddOn.PriestColors = {r = 0.86, g = 0.92, b = 0.98, colorStr = "dbebfa"}
AddOn.Color = AddOn.Class == "PRIEST" and AddOn.PriestColors or (CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[AddOn.Class] or RAID_CLASS_COLORS[AddOn.Class])
AddOn.TexCoords = {0.08, 0.92, 0.08, 0.92}
AddOn.WoWPatch, AddOn.WoWBuild, AddOn.WoWPatchReleaseDate, AddOn.TocVersion = GetBuildInfo()
AddOn.WoWBuild = select(2, GetBuildInfo()) AddOn.WoWBuild = tonumber(AddOn.WoWBuild)

AddOn.AddOns = {}
for i = 1, GetNumAddOns() do
	local AddOnName = GetAddOnInfo(i)
	AddOn.AddOns[string_lower(AddOnName)] = GetAddOnEnableState(AddOn.Name, AddOnName) > 0
end

-- Register events for CheckRole function.
local Loading = CreateFrame("Frame")
Loading:RegisterEvent("PLAYER_LOGIN")
Loading:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
Loading:RegisterEvent("PLAYER_TALENT_UPDATE")
Loading:RegisterEvent("CHARACTER_POINTS_CHANGED")
Loading:RegisterEvent("UNIT_INVENTORY_CHANGED")
Loading:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
Loading:SetScript("OnEvent", function()
	AddOn:UnitRole()
end)