local K, C, L = unpack(select(2, ...))

-- Lua API
local select = select
local string_lower = string.lower
local string_match = string.match

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

local function CheckRole(self, event)
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
		PRIEST = {Healer, Healer, Caster},
		ROGUE = {Melee, Melee, Melee},
		SHAMAN = {Caster, Melee, Healer},
		WARLOCK = {Caster, Caster, Caster},
		WARRIOR = {Melee, Melee, Tank}
	}

	local Specialization = GetSpecialization() or 0
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
K.Spec = GetSpecialization() or 0
K.Race = select(2, UnitRace("player"))
K.Level = UnitLevel("player")
K.Client = GetLocale()
K.Realm = GetRealmName()
K.Resolution = Resolution or (Windowed and GetCVar("gxWindowedResolution")) or GetCVar("gxFullscreenResolution")
K.Color = K.Class == "PRIEST" and K.PriestColors or (CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[K.Class] or RAID_CLASS_COLORS[K.Class])
K.Version = GetAddOnMetadata(K.UIName, "Version")
K.ScreenHeight = tonumber(string_match(K.Resolution, "%d+x(%d+)"))
K.ScreenWidth = tonumber(string_match(K.Resolution, "(%d+)x+%d"))
K.VersionNumber = tonumber(K.Version)
K.WoWPatch, K.WoWBuild, K.WoWPatchReleaseDate, K.TocVersion = GetBuildInfo()
K.WoWBuild = select(2, GetBuildInfo()) K.WoWBuild = tonumber(K.WoWBuild)

K.AddOns = {}
for i = 1, GetNumAddOns() do
	local Name = GetAddOnInfo(i)
	K.AddOns[string_lower(Name)] = GetAddOnEnableState(K.Name, Name) > 0
end

RoleUpdater:RegisterEvent("PLAYER_ENTERING_WORLD")
RoleUpdater:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
RoleUpdater:RegisterEvent("PLAYER_TALENT_UPDATE")
RoleUpdater:RegisterEvent("CHARACTER_POINTS_CHANGED")
RoleUpdater:RegisterEvent("UNIT_INVENTORY_CHANGED")
RoleUpdater:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
RoleUpdater:SetScript("OnEvent", CheckRole)

SLASH_RELOADUI1, SLASH_RELOADUI2 = "/rl", "/reloadui"
SlashCmdList["RELOADUI"] = ReloadUI