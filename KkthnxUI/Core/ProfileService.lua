--[[-----------------------------------------------------------------------------
-- ProfileService
-- Named profiles + profileKeys.
--
-- Layout:
--   KkthnxUIDB.profiles    = { ["Default"] = { …settings delta… }, ["Raid"] = {…} }
--   KkthnxUIDB.profileKeys = { ["Realm-Char"] = "Default" }
--   KkthnxUIDB.Variables[realm][name] — stays character-scoped (movers, junk, …)
--
-- Incident (Profiles, Jul 2026): old model stored Settings[realm][char] and
-- "switch" deep-copied onto the current char. Shared profiles were impossible.
-----------------------------------------------------------------------------]]

local K = KkthnxUI[1]

local ipairs, pairs = ipairs, pairs
local type = type
local time = time
local print = print
local pcall = pcall
local next = next
local wipe = wipe

local UnitClass = UnitClass
local UnitRace = UnitRace
local UnitSex = UnitSex
local UnitFactionGroup = UnitFactionGroup

local PROFILE_VERSION = "2.0.0"
local PROFILE_PREFIX = "KkthnxUI:Profile:"
local PROFILE_NAME_MAX_LENGTH = 32
local DEFAULT_PROFILE_NAME = "Default"

local ProfileService = {}
K.ProfileService = ProfileService

local META_KEYS = {
	LastModified = true,
	CreatedAt = true,
	CreatedBy = true,
	ImportedAt = true,
	ImportedBy = true,
	ImportedFrom = true,
	ResetAt = true,
	ResetBy = true,
	RenamedFrom = true,
	RenamedAt = true,
	LastSwitched = true,
	SwitchedFrom = true,
}

K.ProfileMetaKeys = META_KEYS

local function trim(str)
	if not str then
		return ""
	end
	return str:match("^%s*(.-)%s*$") or ""
end

local function CopyProfileData(data)
	return (type(data) == "table") and K.CopyTable(data) or {}
end

local function MarkInstallComplete(variables)
	variables.InstallComplete = true
	return variables
end

-- Character identity key (not the profile name).
function ProfileService:GetCharacterKey()
	return K.Realm .. "-" .. K.Name
end

-- Active profile name for this character.
function ProfileService:GetActiveProfileName()
	self:EnsureNamedProfileStorage()
	local keys = KkthnxUIDB.profileKeys
	local name = keys and keys[self:GetCharacterKey()]
	if name and KkthnxUIDB.profiles[name] then
		return name
	end
	return DEFAULT_PROFILE_NAME
end

-- GUI / callers historically used GetCurrentProfileKey as "active identity".
-- Now it returns the active *profile name* so list isCurrent checks stay simple.
function ProfileService:GetCurrentProfileKey()
	return self:GetActiveProfileName()
end

function ProfileService:EnsureNamedProfileStorage()
	KkthnxUIDB = KkthnxUIDB or {}
	if type(KkthnxUIDB.profiles) ~= "table" then
		KkthnxUIDB.profiles = {}
	end
	if type(KkthnxUIDB.profileKeys) ~= "table" then
		KkthnxUIDB.profileKeys = {}
	end
	if type(KkthnxUIDB.Variables) ~= "table" then
		KkthnxUIDB.Variables = {}
	end
	if type(KkthnxUIDB.Variables[K.Realm]) ~= "table" then
		KkthnxUIDB.Variables[K.Realm] = {}
	end
	if type(KkthnxUIDB.Variables[K.Realm][K.Name]) ~= "table" then
		KkthnxUIDB.Variables[K.Realm][K.Name] = {}
	end
	if not KkthnxUIDB.profiles[DEFAULT_PROFILE_NAME] then
		KkthnxUIDB.profiles[DEFAULT_PROFILE_NAME] = {}
	end
	return KkthnxUIDB.profiles, KkthnxUIDB.profileKeys
end

-- Migrate Settings[realm][name] → profiles / profileKeys (schema v2).
function ProfileService:MigrateFromCharacterSettings()
	self:EnsureNamedProfileStorage()
	local settingsRoot = KkthnxUIDB.Settings
	if type(settingsRoot) ~= "table" then
		return
	end

	local profiles = KkthnxUIDB.profiles
	local profileKeys = KkthnxUIDB.profileKeys

	for realm, realmData in pairs(settingsRoot) do
		if type(realmData) == "table" then
			for name, data in pairs(realmData) do
				if type(data) == "table" then
					local charKey = realm .. "-" .. name
					local profileName = charKey
					if not profiles[profileName] then
						profiles[profileName] = data
					end
					if not profileKeys[charKey] then
						profileKeys[charKey] = profileName
					end
				end
			end
		end
	end

	-- Keep Settings as read-only fallback for one version; new writes go to profiles.
	KkthnxUIDB._settingsMigratedToProfiles = true
end

function ProfileService:GetActiveSettings()
	self:EnsureNamedProfileStorage()
	local name = self:GetActiveProfileName()
	local profiles = KkthnxUIDB.profiles
	if type(profiles[name]) ~= "table" then
		profiles[name] = {}
	end
	return profiles[name], name
end

function ProfileService:GetAllProfiles()
	local list = {}
	self:EnsureNamedProfileStorage()
	local active = self:GetActiveProfileName()

	for name, profileData in pairs(KkthnxUIDB.profiles) do
		if type(profileData) == "table" then
			list[name] = {
				key = name,
				name = name,
				realm = K.Realm, -- display fallback; named profiles are account-scoped
				displayName = name,
				data = profileData,
				isCurrent = (name == active),
				lastModified = profileData.LastModified or 0,
			}
		end
	end

	return list
end

-- Compatibility: EnsureProfileStorage(realm, name) for Variables only.
function ProfileService:EnsureProfileStorage(realm, name)
	self:EnsureNamedProfileStorage()
	realm = realm or K.Realm
	if type(KkthnxUIDB.Variables[realm]) ~= "table" then
		KkthnxUIDB.Variables[realm] = {}
	end
	if name and type(KkthnxUIDB.Variables[realm][name]) ~= "table" then
		KkthnxUIDB.Variables[realm][name] = {}
	end
	-- Return active settings + variables realm for callers that still unpack two values.
	return self:GetActiveSettings(), KkthnxUIDB.Variables[realm]
end

function ProfileService:GetProfileSettings(_, profileName)
	self:EnsureNamedProfileStorage()
	profileName = profileName or self:GetActiveProfileName()
	local settings = KkthnxUIDB.profiles[profileName]
	return (type(settings) == "table") and settings or nil
end

function ProfileService:GetProfileVariables(realm, name)
	realm = realm or K.Realm
	name = name or K.Name
	local realmData = KkthnxUIDB and KkthnxUIDB.Variables and KkthnxUIDB.Variables[realm]
	local variables = realmData and realmData[name]
	return (type(variables) == "table") and variables or nil
end

function ProfileService:ValidateProfileName(name)
	if not name or type(name) ~= "string" then
		return false, "Profile name must be a string"
	end
	name = trim(name)
	if #name == 0 then
		return false, "Profile name cannot be empty"
	end
	if #name > PROFILE_NAME_MAX_LENGTH then
		return false, "Profile name too long (max " .. PROFILE_NAME_MAX_LENGTH .. " characters)"
	end
	if name:match('[%\\/:*?"<>|]') then
		return false, "Profile name contains invalid characters"
	end
	return true
end

function ProfileService:ValidateProfileData(data)
	if not data or type(data) ~= "table" then
		return false, "Invalid profile data structure"
	end
	if not data.Version then
		return false, "Profile missing version information"
	end
	if not data.Settings then
		return false, "Profile contains no configuration data"
	end
	return true
end

function ProfileService:PruneSettingsByDefaults(currentTable, defaultTable)
	local function prune(curr, defs, depth)
		depth = depth or 0
		if depth > 20 or type(curr) ~= "table" then
			return curr
		end

		local out = {}
		for k, v in pairs(curr) do
			if not META_KEYS[k] then
				local dv = (type(defs) == "table") and defs[k] or nil
				if type(v) == "table" then
					local pruned = prune(v, dv, depth + 1)
					if type(pruned) == "table" then
						if next(pruned) then
							out[k] = pruned
						end
					else
						out[k] = pruned
					end
				elseif v ~= dv then
					out[k] = v
				end
			end
		end
		return out
	end

	return prune(currentTable, defaultTable, 0)
end

-- Remount runtime C from active profile (CopyDefaults-style apply).
-- Used after SetProfile when a live remount is needed; switch UI still ReloadUI.
function ProfileService:RemountRuntimeConfig()
	local C = KkthnxUI[2]
	if not C or not K.Defaults then
		return
	end

	-- Reset C to defaults first, then apply profile deltas.
	for group, options in pairs(K.Defaults) do
		if type(options) == "table" and type(C[group]) == "table" then
			for option, value in pairs(options) do
				if type(value) == "table" then
					C[group][option] = K.CopyTable(value)
				else
					C[group][option] = value
				end
			end
		end
	end

	local settings = self:GetActiveSettings()
	local metaKeys = META_KEYS
	for group, options in pairs(settings) do
		if not metaKeys[group] and type(options) == "table" and type(C[group]) == "table" then
			for option, value in pairs(options) do
				if C[group][option] ~= nil then
					if type(value) == "table" then
						C[group][option] = K.CopyTable(value)
					else
						C[group][option] = value
					end
				end
			end
		end
	end
end

function ProfileService:SetProfile(profileName)
	self:EnsureNamedProfileStorage()
	if type(profileName) ~= "string" or profileName == "" then
		return false, "Invalid profile name"
	end

	local profiles, profileKeys = KkthnxUIDB.profiles, KkthnxUIDB.profileKeys
	profiles[profileName] = profiles[profileName] or {}
	profileKeys[self:GetCharacterKey()] = profileName

	if K.OnProfileChanged then
		K:OnProfileChanged(profileName)
	end
	return true
end

function ProfileService:ExportProfile(profileKey)
	local profiles = self:GetAllProfiles()
	local profile = profiles[profileKey or self:GetActiveProfileName()]
	if not profile then
		return nil, "Profile not found"
	end
	if not K.LibSerialize or not K.LibDeflate then
		return nil, "Required libraries not available for export"
	end

	local settingsSnapshot = CopyProfileData(self:GetProfileSettings(nil, profile.name))
	if K.Defaults and type(K.Defaults) == "table" then
		settingsSnapshot = self:PruneSettingsByDefaults(settingsSnapshot, K.Defaults)
	end

	-- Named profiles export settings only — Variables stay per-character.
	local exportData = {
		Version = PROFILE_VERSION,
		ProfileName = profile.name,
		ExportedAt = time(),
		ExportedBy = K.Name .. "@" .. K.Realm,
		Settings = settingsSnapshot,
	}

	local serialized = K.LibSerialize:Serialize(exportData)
	if type(serialized) ~= "string" or #serialized == 0 then
		return nil, "Failed to serialize profile data"
	end

	local compressed = K.LibDeflate:CompressDeflate(serialized)
	if not compressed then
		return nil, "Failed to compress profile data"
	end

	local encoded = K.LibDeflate:EncodeForPrint(compressed)
	if not encoded then
		return nil, "Failed to encode profile data"
	end

	return PROFILE_PREFIX .. encoded, nil
end

function ProfileService:ImportProfile(profileString, applyToCurrent)
	if not profileString or type(profileString) ~= "string" then
		return false, "Invalid profile string"
	end

	profileString = trim(profileString)
	if not K.LibSerialize or not K.LibDeflate then
		return false, "Required libraries not available for import"
	end

	if not profileString:find(PROFILE_PREFIX, 1, true) then
		return false, "Invalid profile format (missing KkthnxUI prefix)"
	end

	local dataString = profileString:sub(#PROFILE_PREFIX + 1)
	local decoded = K.LibDeflate:DecodeForPrint(dataString)
	if not decoded then
		return false, "Failed to decode profile data"
	end

	local decompressed = K.LibDeflate:DecompressDeflate(decoded)
	if not decompressed then
		return false, "Failed to decompress profile data - invalid compression"
	end

	local success, data = K.LibSerialize:Deserialize(decompressed)
	if not success or not data then
		return false, "Failed to parse profile data"
	end

	if not data.Settings or type(data.Settings) ~= "table" then
		return false, "Invalid profile data - missing or invalid settings"
	end
	if data.Version and data.Version ~= PROFILE_VERSION then
		print("|cff669DFFKkthnxUI:|r Warning: Profile version mismatch. Some settings may not work correctly.")
	end

	self:EnsureNamedProfileStorage()

	if applyToCurrent then
		local active = self:GetActiveProfileName()
		KkthnxUIDB.profiles[active] = CopyProfileData(data.Settings)
		KkthnxUIDB.profiles[active].ImportedAt = time()
		KkthnxUIDB.profiles[active].ImportedBy = K.Name
		KkthnxUIDB.profiles[active].ImportedFrom = data.ProfileName or "Unknown"
		KkthnxUIDB.profiles[active].LastModified = time()
		-- Optional legacy Variables in old exports: apply to this character only.
		if type(data.Variables) == "table" then
			KkthnxUIDB.Variables[K.Realm][K.Name] = MarkInstallComplete(CopyProfileData(data.Variables))
		end
		return true, "Profile applied to '" .. active .. "' successfully"
	end

	local profileName = data.ProfileName or "Imported Profile"
	local valid, err = self:ValidateProfileName(profileName)
	if not valid then
		return false, err
	end

	if KkthnxUIDB.profiles[profileName] then
		return false, "Profile '" .. profileName .. "' already exists"
	end

	KkthnxUIDB.profiles[profileName] = CopyProfileData(data.Settings)
	KkthnxUIDB.profiles[profileName].ImportedAt = time()
	KkthnxUIDB.profiles[profileName].ImportedBy = K.Name
	KkthnxUIDB.profiles[profileName].ImportedFrom = data.ProfileName or "Unknown"
	KkthnxUIDB.profiles[profileName].LastModified = time()
	return true, "Profile created as '" .. profileName .. "' successfully"
end

function ProfileService:CreateProfile(profileName, sourceProfile)
	local valid, err = self:ValidateProfileName(profileName)
	if not valid then
		return false, err
	end

	self:EnsureNamedProfileStorage()
	if KkthnxUIDB.profiles[profileName] then
		return false, "Profile '" .. profileName .. "' already exists"
	end

	local sourceName = sourceProfile or self:GetActiveProfileName()
	local source = KkthnxUIDB.profiles[sourceName]
	if not source then
		return false, "Source profile not found"
	end

	KkthnxUIDB.profiles[profileName] = CopyProfileData(source)
	KkthnxUIDB.profiles[profileName].CreatedAt = time()
	KkthnxUIDB.profiles[profileName].CreatedBy = K.Name
	KkthnxUIDB.profiles[profileName].LastModified = time()
	return true, "Profile created successfully"
end

function ProfileService:RenameProfile(profileKey, newName)
	local valid, err = self:ValidateProfileName(newName)
	if not valid then
		return false, err
	end

	self:EnsureNamedProfileStorage()
	local oldName = profileKey
	if not KkthnxUIDB.profiles[oldName] then
		return false, "Profile not found"
	end
	if oldName == self:GetActiveProfileName() then
		return false, "Cannot rename the currently active profile"
	end
	if KkthnxUIDB.profiles[newName] then
		return false, "Profile '" .. newName .. "' already exists"
	end

	KkthnxUIDB.profiles[newName] = CopyProfileData(KkthnxUIDB.profiles[oldName])
	KkthnxUIDB.profiles[newName].LastModified = time()
	KkthnxUIDB.profiles[newName].RenamedFrom = oldName
	KkthnxUIDB.profiles[newName].RenamedAt = time()
	KkthnxUIDB.profiles[oldName] = nil

	for charKey, used in pairs(KkthnxUIDB.profileKeys) do
		if used == oldName then
			KkthnxUIDB.profileKeys[charKey] = newName
		end
	end

	return true, "Profile renamed successfully", newName
end

function ProfileService:DeleteProfile(profileKey)
	self:EnsureNamedProfileStorage()
	if profileKey == self:GetActiveProfileName() then
		return false, "Cannot delete the currently active profile"
	end
	if not KkthnxUIDB.profiles[profileKey] then
		return false, "Profile not found"
	end
	if profileKey == DEFAULT_PROFILE_NAME then
		return false, "Cannot delete the Default profile"
	end

	KkthnxUIDB.profiles[profileKey] = nil
	for charKey, used in pairs(KkthnxUIDB.profileKeys) do
		if used == profileKey then
			KkthnxUIDB.profileKeys[charKey] = nil
		end
	end
	return true, "Profile deleted successfully"
end

-- Pointer switch — does not copy settings onto the character.
function ProfileService:SwitchProfile(profileKey)
	self:EnsureNamedProfileStorage()
	if profileKey == self:GetActiveProfileName() then
		return false, "Already using this profile"
	end
	if not KkthnxUIDB.profiles[profileKey] then
		return false, "Profile not found"
	end

	local ok = self:SetProfile(profileKey)
	if not ok then
		return false, "Failed to set profile"
	end

	local settings = KkthnxUIDB.profiles[profileKey]
	settings.LastSwitched = time()
	settings.SwitchedFrom = self:GetCharacterKey()
	settings.LastModified = time()

	-- Ensure this character still has Variables (never shared via profile).
	MarkInstallComplete(KkthnxUIDB.Variables[K.Realm][K.Name])

	return true, "Profile switch initiated"
end

function ProfileService:ResetProfile(profileKey)
	self:EnsureNamedProfileStorage()
	local name = profileKey or self:GetActiveProfileName()
	if not KkthnxUIDB.profiles[name] then
		KkthnxUIDB.profiles[name] = {}
	else
		wipe(KkthnxUIDB.profiles[name])
	end
	KkthnxUIDB.profiles[name].ResetAt = time()
	KkthnxUIDB.profiles[name].ResetBy = K.Name
	KkthnxUIDB.profiles[name].LastModified = time()
	return true, "Profile reset successfully"
end

function ProfileService:GetClassFromGoldInfo(name, realm)
	if KkthnxUIDB.Gold and KkthnxUIDB.Gold[realm] and KkthnxUIDB.Gold[realm][name] then
		local classFromGold = KkthnxUIDB.Gold[realm][name][2]
		if classFromGold then
			return classFromGold
		end
	end
	if KkthnxUIDB.ProfilePortraits and KkthnxUIDB.ProfilePortraits[realm] and KkthnxUIDB.ProfilePortraits[realm][name] then
		return KkthnxUIDB.ProfilePortraits[realm][name].class
	end
	return nil
end

function ProfileService:GetFactionFromGoldInfo(name, realm)
	if KkthnxUIDB.Gold and KkthnxUIDB.Gold[realm] and KkthnxUIDB.Gold[realm][name] then
		local factionFromGold = KkthnxUIDB.Gold[realm][name][3]
		if factionFromGold then
			return factionFromGold
		end
	end
	if KkthnxUIDB.ProfilePortraits and KkthnxUIDB.ProfilePortraits[realm] and KkthnxUIDB.ProfilePortraits[realm][name] then
		return KkthnxUIDB.ProfilePortraits[realm][name].faction
	end
	return "Unknown"
end

function ProfileService:StoreCharacterMetadata(name, realm)
	if not KkthnxUIDB.ProfilePortraits then
		KkthnxUIDB.ProfilePortraits = {}
	end
	if not KkthnxUIDB.ProfilePortraits[realm] then
		KkthnxUIDB.ProfilePortraits[realm] = {}
	end

	local _, class = UnitClass("player")
	local race = UnitRace("player")
	local gender = UnitSex("player")
	local faction = UnitFactionGroup("player")

	KkthnxUIDB.ProfilePortraits[realm][name] = {
		class = class,
		race = race,
		gender = gender,
		faction = faction,
		lastUpdated = time(),
	}
end

function ProfileService:GetRaceFromPortraitData(name, realm)
	local data = KkthnxUIDB.ProfilePortraits and KkthnxUIDB.ProfilePortraits[realm] and KkthnxUIDB.ProfilePortraits[realm][name]
	return data and data.race
end

function ProfileService:GetGenderFromPortraitData(name, realm)
	local data = KkthnxUIDB.ProfilePortraits and KkthnxUIDB.ProfilePortraits[realm] and KkthnxUIDB.ProfilePortraits[realm][name]
	return data and data.gender
end

function ProfileService:GetProfileDataSize(profileData)
	if type(profileData) ~= "table" then
		return 0, 0
	end

	local function valuesEqual(a, b)
		if type(a) ~= type(b) then
			return false
		end
		if type(a) ~= "table" then
			return a == b
		end
		for k, v in pairs(a) do
			if not valuesEqual(v, b[k]) then
				return false
			end
		end
		for k in pairs(b) do
			if a[k] == nil then
				return false
			end
		end
		return true
	end

	local defaults = (type(K.Defaults) == "table") and K.Defaults or nil
	local total, changed = 0, 0
	for group, options in pairs(profileData) do
		if not META_KEYS[group] and type(options) == "table" then
			local groupDefaults = defaults and defaults[group]
			if type(groupDefaults) ~= "table" then
				groupDefaults = nil
			end
			for option, value in pairs(options) do
				if not META_KEYS[option] then
					total = total + 1
					if not defaults or not valuesEqual(value, groupDefaults and groupDefaults[option]) then
						changed = changed + 1
					end
				end
			end
		end
	end
	return changed, total
end

function ProfileService:GetBooleanStats(profileData)
	if type(profileData) ~= "table" then
		return 0, 0
	end

	local enabled, disabled = 0, 0
	local function scan(t, depth)
		depth = depth or 0
		if depth > 20 or type(t) ~= "table" then
			return
		end
		for k, v in pairs(t) do
			if not META_KEYS[k] then
				if type(v) == "boolean" then
					if v then
						enabled = enabled + 1
					else
						disabled = disabled + 1
					end
				elseif type(v) == "table" then
					scan(v, depth + 1)
				end
			end
		end
	end

	scan(profileData, 0)
	return enabled, disabled
end

function ProfileService:EnsureDatabaseIntegrity()
	self:EnsureNamedProfileStorage()
	return KkthnxUIDB ~= nil and type(KkthnxUIDB.profiles) == "table" and type(KkthnxUIDB.Variables) == "table"
end

function ProfileService:UpdateCurrentProfileTimestamp()
	local settings = self:GetActiveSettings()
	if settings then
		settings.LastModified = time()
	end
end

function ProfileService:MigrateProfileTimestamps()
	self:EnsureNamedProfileStorage()
	for _, profileData in pairs(KkthnxUIDB.profiles) do
		if type(profileData) == "table" and not profileData.LastModified then
			profileData.LastModified = time()
		end
	end
end

--- Strip default-equal keys from the active profile before logout.
function ProfileService:CompactActiveProfile()
	if not (K.Defaults and type(K.Defaults) == "table") then
		return
	end
	local settings, name = self:GetActiveSettings()
	if not settings then
		return
	end
	local pruned = self:PruneSettingsByDefaults(settings, K.Defaults)
	-- Preserve meta keys.
	for k in pairs(META_KEYS) do
		if settings[k] ~= nil then
			pruned[k] = settings[k]
		end
	end
	KkthnxUIDB.profiles[name] = pruned
end
