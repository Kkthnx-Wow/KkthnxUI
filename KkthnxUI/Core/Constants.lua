local K, C, L = select(2, ...):unpack()

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

-- Matching the pre-MoP return arguments of the Blizzard API call (Credits to Goldpaw)
K.GetAddOnInfo = function(index)
	local name, title, notes, enabled, loadable, reason, security
	if tonumber((select(2, GetBuildInfo()))) >= 19034 then
		name, title, notes, loadable, reason, security, newVersion = GetAddOnInfo(index)
		enabled = not(GetAddOnEnableState(UnitName("player"), index) == 0) -- not a boolean, messed that one up! o.O
	else
		name, title, notes, enabled, loadable, reason, security = GetAddOnInfo(index)
	end
	return name, title, notes, enabled, loadable, reason, security
end

-- Check if an addon is enabled	in the addon listing
K.IsAddOnEnabled = function(addon_name)
	local addon_name = strlower(addon_name)
	for i = 1,GetNumAddOns() do
		local name, title, notes, enabled, loadable, reason, security = K.GetAddOnInfo(i)
		if strlower(name) == addon_name then
			if enabled then
				return true
			end
		end
	end
end

RoleUpdater:RegisterEvent("PLAYER_ENTERING_WORLD")
RoleUpdater:RegisterEvent("PLAYER_TALENT_UPDATE")
RoleUpdater:SetScript("OnEvent", K.CheckRole)

SLASH_RELOADUI1, SLASH_RELOADUI2 = "/rl", "/reloadui"
SlashCmdList["RELOADUI"] = ReloadUI