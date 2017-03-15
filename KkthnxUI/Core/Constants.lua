local K, C, L = unpack(select(2, ...))

-- Lua API
local _G = _G
local select = select
local string_lower = string.lower
local tonumber = tonumber

-- Wow API
local GetAddOnEnableState = _G.GetAddOnEnableState
local GetBuildInfo = _G.GetBuildInfo
local GetSpecialization = _G.GetSpecialization
local UnitClass = _G.UnitClass
local UnitName = _G.UnitName
local DisableAddOn = _G.DisableAddOn
local ReloadUI = _G.ReloadUI

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: SLASH_RELOADUI2, SLASH_RELOADUI1, newVersion, Spec

local function CheckRole(self, event, unit)
	local Tank = "TANK" or "Tank"
	local Melee = "MELEE" or "Melee"
	local Caster = "CASTER" or "Caster"
	local Healer = "HEALER" or "Healer"

	local Roles = {
		["DEATHKNIGHT"] = {Tank, Melee, Melee},
		["DEMONHUNTER"] = {Melee, Tank},
		["DRUID"] = {Caster, Melee, Tank, Healer},
		["HUNTER"] = {Melee, Melee, Melee},
		["MAGE"] = {Caster, Caster, Caster},
		["MONK"] = {Tank, Healer, Melee},
		["PALADIN"] = {Healer, Tank, Melee},
		["PRIEST"] = {Healer, Healer, Caster},
		["ROGUE"] = {Melee, Melee, Melee},
		["SHAMAN"] = {Caster, Melee, Healer},
		["WARLOCK"] = {Caster, Caster, Caster},
		["WARRIOR"] = {Melee, Melee, Tank}
	}

	local Spec = GetSpecialization(Spec) or nil
	local Class = select(2, UnitClass("player"))
	return Roles[Class][Spec] or nil
end

K.UIName = "KkthnxUI"
K.Noop = function() return end
K.Unit = UnitGUID("player")
K.Name = UnitName("player")
K.Class = select(2, UnitClass("player"))
K.Role = CheckRole("player")
K.Spec = GetSpecialization(K.Spec) or nil
K.Race = select(2, UnitRace("player"))
K.Level = UnitLevel("player")
K.Client = GetLocale()
K.Realm = GetRealmName()
-- Currently in Legion logging in while in Windowed mode will cause the game to use "Custom" resolution and GetCurrentResolution() returns 0. We use GetCVar("gxWindowedResolution") as fail safe
K.Resolution = ({GetScreenResolutions()})[GetCurrentResolution()] or GetCVar("gxWindowedResolution")
K.Color = K.Class == "PRIEST" and K.PriestColors or (CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[K.Class] or RAID_CLASS_COLORS[K.Class])
K.Version = GetAddOnMetadata(K.UIName, "Version")
K.ScreenWidth, K.ScreenHeight = DecodeResolution(K.Resolution)
K.VersionNumber = tonumber(K.Version)
K.WoWPatch, K.WoWBuild, K.WoWPatchReleaseDate, K.TocVersion = GetBuildInfo()
K.WoWBuild = select(2, GetBuildInfo()) K.WoWBuild = tonumber(K.WoWBuild)

K.AddOns = {}
for i = 1, GetNumAddOns() do
	local AddOnName = GetAddOnInfo(i)
	K.AddOns[string_lower(AddOnName)] = GetAddOnEnableState(K.Name, AddOnName) > 0
end

StaticPopupDialogs["KKTHNXUI_INCOMPATIBLE"] = {
	text = "Oh no, you have |cff3c9bedKkthnxUI|r and |cff8a0707Diabolic|r|cffffffffUI|r both enabled at the same time. Select an addon to disable to prevent conflicts!",
	button1 = "|cff3c9bedKkthnxUI|r",
	button2 = "|cff8a0707Diabolic|r|cffffffffUI|r",
	OnAccept = function() DisableAddOn("KkthnxUI") ReloadUI() end,
	OnCancel = function() DisableAddOn("DiabolicUI") ReloadUI() end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = false,
	preferredIndex = 3,
	showAlert = 1
}

if IsAddOnLoaded("DiabolicUI") then
	StaticPopup_Show("KKTHNXUI_INCOMPATIBLE")
end

local Loading = CreateFrame("Frame")
Loading:RegisterEvent("PLAYER_ENTERING_WORLD")
Loading:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
Loading:RegisterEvent("PLAYER_TALENT_UPDATE")
Loading:RegisterEvent("CHARACTER_POINTS_CHANGED")
Loading:RegisterEvent("UNIT_INVENTORY_CHANGED")
Loading:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
Loading:SetScript("OnEvent", CheckRole)