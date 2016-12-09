local K, C, L = select(2, ...):unpack()

-- Lua API
local select = select
local strlower = string.lower

-- Wow API
local GetAddOnEnableState = GetAddOnEnableState
local GetBuildInfo = GetBuildInfo
local GetSpecialization = GetSpecialization
local tonumber = tonumber
local UnitClass = UnitClass
local UnitName = UnitName

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: SLASH_RELOADUI2, SLASH_RELOADUI1, newVersion

local Resolution = GetCurrentResolution() > 0 and select(GetCurrentResolution(), GetScreenResolutions()) or nil
local Windowed = Display_DisplayModeDropDown:windowedmode()
local Fullscreen = Display_DisplayModeDropDown:fullscreenmode()
local RoleUpdater = CreateFrame("Frame")

local CheckRole = function(self, event, unit)
	local Tank = "TANK"
	local Melee = "MELEE"
	local Caster = "CASTER"
	local Healer = "HEALER"

	local Roles = {
		DEATHKNIGHT = {Tank, Melee, Melee},
		DEMONHUNTER = {Melee, Tank},
		DRUID = {Caster, Melee, Tank, Healer},
		HUNTER = {Melee, Melee, Melee},
		MAGE = {Caster, Caster, Caster},
		MONK = {Tank, Healer, Melee},
		PALADIN = {Healer, Tank, Melee},
		PRIEST = {Healer, Caster, Healer},
		ROGUE = {Melee, Melee, Melee},
		SHAMAN = {Caster, Melee, Healer},
		WARLOCK = {Caster, Caster, Caster},
		WARRIOR = {Melee, Melee, Tank}
	}

	local Specialization = GetSpecialization()
	local Class = select(2, UnitClass("player"))
	return Roles[Class][Specialization]
end

K.UIName = "KkthnxUI"
K.WindowedMode = Windowed
K.FullscreenMode = Fullscreen
K.Noop = function() return end
K.Unit = UnitGUID("player")
K.Name = UnitName("player")
K.Class = select(2, UnitClass("player"))
K.Role = CheckRole("player")
K.CheckRole = CheckRole
K.Race = select(2, UnitRace("player"))
K.Level = UnitLevel("player")
K.Client = GetLocale()
K.Realm = GetRealmName()
K.Resolution = Resolution or (Windowed and GetCVar("gxWindowedResolution")) or GetCVar("gxFullscreenResolution")
K.Color = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[K.Class]
K.Version = GetAddOnMetadata(K.UIName, "Version")
K.ScreenHeight = tonumber(string.match(K.Resolution, "%d+x(%d+)"))
K.ScreenWidth = tonumber(string.match(K.Resolution, "(%d+)x+%d"))
K.VersionNumber = tonumber(K.Version)
K.WoWPatch, K.WoWBuild, K.WoWPatchReleaseDate, K.TocVersion = GetBuildInfo()
K.WoWBuild = select(2, GetBuildInfo()) K.WoWBuild = tonumber(K.WoWBuild)
K.AddOns = {}

for i = 1, GetNumAddOns() do
	local Name = GetAddOnInfo(i)
	K.AddOns[strlower(Name)] = GetAddOnEnableState(K.Name, Name) > 0
end

RoleUpdater:RegisterEvent("PLAYER_ENTERING_WORLD")
RoleUpdater:RegisterEvent("PLAYER_TALENT_UPDATE")
RoleUpdater:SetScript("OnEvent", K.CheckRole)

SLASH_RELOADUI1, SLASH_RELOADUI2 = "/rl", "/reloadui"
SlashCmdList["RELOADUI"] = ReloadUI