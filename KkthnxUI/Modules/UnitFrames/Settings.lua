--[[-----------------------------------------------------------------------------
-- Live GUI refresh for unit, party, and raid frame settings.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Unitframes")

local PLAYER_SIZE = {
	PlayerHealthWidth = true,
	PlayerHealthHeight = true,
	PlayerPowerHeight = true,
}

local TARGET_SIZE = {
	TargetHealthWidth = true,
	TargetHealthHeight = true,
	TargetPowerHeight = true,
}

local FOCUS_SIZE = {
	FocusHealthWidth = true,
	FocusHealthHeight = true,
	FocusPowerHeight = true,
}

local PARTY_REBUILD = {
	Enable = true,
	ShowPet = true,
	ShowBuffs = true,
	Castbars = true,
	CastbarIcon = true,
	ShowHealPrediction = true,
	ShowPlayer = true,
	ShowPartySolo = true,
	TargetHighlight = true,
	DispelIcon = true,
	DispelIconAll = true,
}

local PARTY_SIZE = {
	HealthWidth = true,
	HealthHeight = true,
	PowerHeight = true,
}

local RAID_LAYOUT = {
	UseRaidForParty = true,
}

local RAID_LAYOUT_REBUILD = {
	HorizonRaid = true,
	ReverseRaid = true,
}

local RAID_AURA_TRACK = {
	AuraTrackIcons = true,
	AuraTrackSpellTextures = true,
	AuraTrackThickness = true,
}

local SIMPLE_PARTY_REBUILD = {
	Enable = true,
	RaidBuffsStyle = true,
	RaidBuffs = true,
	ShowHealPrediction = true,
	TargetHighlight = true,
	DebuffWatch = true,
	DebuffWatchDefault = true,
	DispelIcon = true,
	DispelIconAll = true,
}

local SIMPLE_PARTY_AURA = {
	AuraTrackIcons = true,
	AuraTrackSpellTextures = true,
	AuraTrackThickness = true,
}

local ARENA_REBUILD = {
	Castbars = true,
	CastbarIcon = true,
}

local ARENA_SIZE = {
	HealthWidth = true,
	HealthHeight = true,
	PowerHeight = true,
}

local BOSS_REBUILD = {
	Castbars = true,
	CastbarIcon = true,
}

local BOSS_SIZE = {
	HealthWidth = true,
	HealthHeight = true,
	PowerHeight = true,
}

local RAID_DEBUFF = {
	DebuffWatch = true,
	DebuffWatchDefault = true,
}

local RAID_AURA_REFRESH = {
	DesaturateBuffs = true,
}

local RAID_REBUILD = {
	Enable = true,
	RaidBuffsStyle = true,
	RaidBuffs = true,
	MainTankFrames = true,
	NumGroups = true,
	ShowTeamIndex = true,
	ShowHealPrediction = true,
	AbsorbStrips = true,
	DispelIcon = true,
	PowerBarShow = true,
	ManabarShow = true,
	TargetHighlight = true,
	ShowNotHereTimer = true,
	AuraTrack = true,
	-- BUGFIX: DispelIconAll was listed here too, which made the `key == "DispelIconAll"`
	-- branch below dead code (RAID_REBUILD[key] is checked first in the elseif chain).
	-- That forced a full RebuildRaidFrames() for a setting that only changes an existing
	-- icon's filter criteria — RefreshRaidDispelIcons() already exists for exactly this
	-- and is far cheaper. DispelIcon stays here since toggling it on/off actually needs
	-- to create/destroy the icon frame, which only a rebuild does.
}

-- Portrait-only rebuilds (empty for now; PortraitStyle handled explicitly).
local UNITFRAME_REBUILD = {}

-- Structural toggles that need a full core-unit spawn (castbars, auras, pets, companions).
local UNITFRAME_SPAWN = {
	PlayerCastbar = true,
	PlayerCastbarIcon = true,
	PlayerCastbarHeight = true,
	PlayerCastbarWidth = true,
	PlayerBuffs = true,
	PlayerDebuffs = true,
	TargetCastbar = true,
	TargetCastbarIcon = true,
	TargetCastbarHeight = true,
	TargetCastbarWidth = true,
	TargetBuffs = true,
	TargetDebuffs = true,
	FocusCastbar = true,
	FocusCastbarIcon = true,
	FocusCastbarHeight = true,
	FocusCastbarWidth = true,
	FocusBuffs = true,
	FocusDebuffs = true,
	HidePet = true,
	HidePetName = true,
	HideTargetofTarget = true,
	HideTargetOfTargetName = true,
	HideFocusTarget = true,
	HideFocusTargetName = true,
	ClassResources = true,
	CastClassColor = true,
	CastReactionColor = true,
	ShowHealPrediction = true,
	DebuffHighlight = true,
	PvPIndicator = true,
	AdditionalPower = true,
	ShowPlayerLevel = true,
	GlobalCooldown = true,
	Stagger = true,
	CombatFade = true,
	PetHealthHeight = true,
	PetHealthWidth = true,
	PetPowerHeight = true,
	TargetTargetHealthHeight = true,
	TargetTargetHealthWidth = true,
	TargetTargetPowerHeight = true,
	FocusTargetHealthHeight = true,
	FocusTargetHealthWidth = true,
	FocusTargetPowerHeight = true,
}

local function OnUnitframeSetting(configPath)
	local key = configPath:match("^Unitframe%.(.+)$")
	if not key then
		return
	end

	if key == "AllTextScale" then
		Module:UpdateTextScale()
	elseif key == "Enable" then
		Module:SetUnitframesEnabled(C["Unitframe"].Enable)
	elseif key == "HideMaxPlayerLevel" then
		Module:UpdatePlayerLevelVisibility()
	elseif key == "CastbarLatency" then
		Module:ToggleCastBarLatency()
	elseif key == "OnlyShowPlayerDebuff" then
		Module:UpdateOnlyShowPlayerDebuffs()
	elseif key == "HealthbarColor" then
		Module:UpdateUnitframeHealthbarColor()
	elseif key == "Smooth" then
		Module:UpdateUnitframeSmooth()
	elseif key == "Range" then
		Module:RefreshRangeFading()
	elseif key == "PortraitStyle" or UNITFRAME_REBUILD[key] then
		Module:RebuildPortraitUnits()
	elseif key == "PrivateAuras" then
		-- Private auras sit on player + party/raid — spawn cores and rebuild headers.
		Module:SpawnCoreUnitFrames()
		Module:RebuildPartyFrames()
		Module:RebuildRaidFrames()
	elseif UNITFRAME_SPAWN[key] then
		Module:SpawnCoreUnitFrames()
	elseif key == "HidePetLevel" or key == "HideFocusTargetLevel" or key == "HideTargetOfTargetLevel" then
		Module:UpdateOptionalUnitLevels()
	elseif key == "PlayerBuffsPerRow" then
		Module:UpdatePlayerBuffs()
	elseif key == "PlayerDebuffsPerRow" then
		Module:UpdatePlayerDebuffs()
	elseif key == "TargetBuffsPerRow" then
		Module:UpdateTargetBuffs()
	elseif key == "TargetDebuffsPerRow" then
		Module:UpdateTargetDebuffs()
	elseif PLAYER_SIZE[key] then
		Module:UpdatePlayerSize()
	elseif TARGET_SIZE[key] then
		Module:UpdateTargetSize()
	elseif FOCUS_SIZE[key] then
		Module:UpdateFocusSize()
	end
end

local function OnPartySetting(configPath)
	local key = configPath:match("^Party%.(.+)$")
	if not key then
		return
	end

	if PARTY_REBUILD[key] then
		Module:RebuildPartyFrames()
	elseif key == "HealthbarColor" then
		Module:UpdatePartyHealthbarColors()
	elseif key == "Smooth" then
		Module:UpdatePartySmooth()
	elseif PARTY_SIZE[key] then
		Module:UpdatePartySize()
	end
end

local function OnSimplePartySetting(configPath)
	local key = configPath:match("^SimpleParty%.(.+)$")
	if not key then
		return
	end

	if SIMPLE_PARTY_REBUILD[key] then
		Module:RebuildPartyFrames()
	elseif key == "HealthbarColor" then
		Module:UpdateSimplePartyHealthbarColors()
	elseif key == "Smooth" then
		Module:UpdateSimplePartySmooth()
	elseif key == "HealthWidth" or key == "HealthHeight" then
		Module:UpdateSimplePartySize()
	elseif key == "HorizonParty" then
		Module:UpdateSimplePartyOrientation()
	elseif key == "PowerBarHeight" then
		Module:UpdateSimplePartyPowerHeight()
	elseif key == "PowerBarShow" or key == "ManabarShow" then
		Module:UpdateSimplePartyPowerBars()
	elseif SIMPLE_PARTY_AURA[key] then
		Module:UpdateSimplePartyAuraTrack()
	end
end

local function OnRaidSetting(configPath)
	local key = configPath:match("^Raid%.(.+)$")
	if not key then
		return
	end

	if key == "Width" or key == "Height" then
		Module:UpdateRaidSize()
	elseif key == "HealthFormat" then
		Module:UpdateRaidHealthTags()
	elseif RAID_AURA_REFRESH[key] then
		Module:UpdateRaidBuffAuras()
	elseif RAID_REBUILD[key] then
		Module:RebuildRaidFrames()
	elseif key == "DispelIconAll" then
		Module:RefreshRaidDispelIcons()
	elseif key == "HealthbarColor" then
		Module:UpdateRaidHealthbarColors()
	elseif key == "Smooth" then
		Module:UpdateRaidSmooth()
	elseif RAID_LAYOUT_REBUILD[key] then
		Module:UpdateRaidLayout()
	elseif RAID_LAYOUT[key] then
		Module:UpdateAllHeaders()
	elseif RAID_DEBUFF[key] then
		Module:UpdateRaidDebuffIndicator()
		Module:RebuildRaidFrames()
	elseif RAID_AURA_TRACK[key] then
		Module:UpdateRaidAuraTrack()
	end
end

local function OnArenaSetting(configPath)
	local key = configPath:match("^Arena%.(.+)$")
	if not key then
		return
	end

	if ARENA_REBUILD[key] then
		Module:SafeSpawnArenaFrames()
	elseif key == "HealthbarColor" then
		Module:UpdateArenaHealthbarColor()
	elseif key == "Smooth" then
		Module:UpdateArenaSmooth()
	elseif ARENA_SIZE[key] then
		Module:UpdateArenaSize()
	end
end

local function OnBossSetting(configPath)
	local key = configPath:match("^Boss%.(.+)$")
	if not key then
		return
	end

	if BOSS_REBUILD[key] then
		Module:SafeSpawnBossFrames()
	elseif key == "HealthbarColor" then
		Module:UpdateBossHealthbarColor()
	elseif key == "Smooth" then
		Module:UpdateBossSmooth()
	elseif BOSS_SIZE[key] then
		Module:UpdateBossSize()
	end
end

K:RegisterSettingPrefixCallback("Unitframe.", OnUnitframeSetting)
K:RegisterSettingPrefixCallback("Party.", OnPartySetting)
K:RegisterSettingPrefixCallback("SimpleParty.", OnSimplePartySetting)
K:RegisterSettingPrefixCallback("Raid.", OnRaidSetting)
K:RegisterSettingPrefixCallback("Arena.", OnArenaSetting)
K:RegisterSettingPrefixCallback("Boss.", OnBossSetting)
