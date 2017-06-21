local K, C, L = unpack(select(2, ...))

-- Lua API
local _G = _G
local select = select
local string_lower = string.lower
local tonumber = tonumber

-- Wow API
local DisableAddOn = _G.DisableAddOn
local GetAddOnEnableState = _G.GetAddOnEnableState
local GetAddOnInfo = _G.GetAddOnInfo
local GetBuildInfo = _G.GetBuildInfo
local GetSpecialization = _G.GetSpecialization
local ReloadUI = _G.ReloadUI
local UnitClass = _G.UnitClass
local UnitName = _G.UnitName

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: SLASH_RELOADUI2, SLASH_RELOADUI1, newVersion, Spec

-- Check role to return what role the player is.
local function UnitRole()
	local GetSpec = GetSpecialization()
	local GetClass = select(2, UnitClass("player"))

	if not GetSpec or not GetClass then return end

	local Roles = {
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

	return Roles[GetClass][GetSpec]
end

K.UIName = "KkthnxUI"
K.Noop = function() return end
K.Unit = UnitGUID("player")
K.Name = UnitName("player")
K.GUID = UnitGUID("player")
K.Class = select(2, UnitClass("player"))
K.Role = UnitRole("player")
K.Spec = GetSpecialization()
K.Race = select(2, UnitRace("player"))
K.Level = UnitLevel("player")
K.Client = GetLocale()
K.Realm = GetRealmName()
K.OmniCC = select(4, GetAddOnInfo("OmniCC"))
-- Currently in Legion logging in while in Windowed mode will cause the game to use "Custom" resolution and GetCurrentResolution() returns 0. We use GetCVar("gxWindowedResolution") as fail safe
K.Resolution = ({GetScreenResolutions()})[GetCurrentResolution()] or GetCVar("gxWindowedResolution")
K.ScreenWidth, K.ScreenHeight = DecodeResolution(K.Resolution)
K.PriestColors = {r = 0.86, g = 0.92, b = 0.98, colorStr = "dbebfa"}
K.Color = K.Class == "PRIEST" and K.PriestColors or (CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[K.Class] or RAID_CLASS_COLORS[K.Class])
K.Version = GetAddOnMetadata(K.UIName, "Version")
K.TexCoords = {0.08, 0.92, 0.08, 0.92}
K.VersionNumber = tonumber(K.Version)
K.WoWPatch, K.WoWBuild, K.WoWPatchReleaseDate, K.TocVersion = GetBuildInfo()
K.WoWBuild = select(2, GetBuildInfo()) K.WoWBuild = tonumber(K.WoWBuild)

K.AddOns = {}
for i = 1, GetNumAddOns() do
	local AddOnName = GetAddOnInfo(i)
	K.AddOns[string_lower(AddOnName)] = GetAddOnEnableState(K.Name, AddOnName) > 0
end

-- Register events for CheckRole function.
local Loading = CreateFrame("Frame")
Loading:RegisterEvent("PLAYER_LOGIN")
Loading:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
Loading:RegisterEvent("PLAYER_TALENT_UPDATE")
Loading:RegisterEvent("CHARACTER_POINTS_CHANGED")
Loading:RegisterEvent("UNIT_INVENTORY_CHANGED")
Loading:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
Loading:SetScript("OnEvent", UnitRole)