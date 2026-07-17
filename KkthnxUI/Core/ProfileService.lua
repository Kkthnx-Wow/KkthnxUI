local K = KkthnxUI[1]

--[[-----------------------------------------------------------------------------
-- ProfileService
--
-- Pure profile data/service layer for ProfileGUI.
--
-- REASON: ProfileGUI.lua had storage validation, profile CRUD, import/export
-- serialization, metadata pruning, and visual rendering all in one file. That's
-- how UI bugs and DB bugs start sharing a kitchen. Keep the data plumbing here;
-- keep frames/buttons/dialog layout in ProfileGUI.lua.
-----------------------------------------------------------------------------]]

local ipairs, pairs = ipairs, pairs
local type = type
local time = time
local print = print
local pcall = pcall

local UnitClass = UnitClass
local UnitRace = UnitRace
local UnitSex = UnitSex
local UnitFactionGroup = UnitFactionGroup

local PROFILE_VERSION = "2.0.0"
local PROFILE_PREFIX = "KkthnxUI:Profile:"
local PROFILE_NAME_MAX_LENGTH = 32

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

function ProfileService:GetCurrentProfileKey()
	return K.Realm .. "-" .. K.Name
end

function ProfileService:GetAllProfiles()
	local profiles = {}

	if not KkthnxUIDB or type(KkthnxUIDB.Settings) ~= "table" then
		return profiles
	end

	for realm, realmData in pairs(KkthnxUIDB.Settings) do
		if type(realmData) == "table" then
			for name, profileData in pairs(realmData) do
				if type(profileData) == "table" then
					local profileKey = realm .. "-" .. name
					profiles[profileKey] = {
						key = profileKey,
						name = name,
						realm = realm,
						displayName = name .. " (" .. realm .. ")",
						data = profileData,
						isCurrent = (profileKey == self:GetCurrentProfileKey()),
						lastModified = profileData.LastModified or 0,
					}
				end
			end
		end
	end

	return profiles
end

function ProfileService:EnsureProfileStorage(realm, name)
	KkthnxUIDB = KkthnxUIDB or {}
	if type(KkthnxUIDB.Settings) ~= "table" then
		KkthnxUIDB.Settings = {}
	end
	if type(KkthnxUIDB.Settings[realm]) ~= "table" then
		KkthnxUIDB.Settings[realm] = {}
	end
	if type(KkthnxUIDB.Variables) ~= "table" then
		KkthnxUIDB.Variables = {}
	end
	if type(KkthnxUIDB.Variables[realm]) ~= "table" then
		KkthnxUIDB.Variables[realm] = {}
	end

	if name then
		if type(KkthnxUIDB.Settings[realm][name]) ~= "table" then
			KkthnxUIDB.Settings[realm][name] = {}
		end
		if type(KkthnxUIDB.Variables[realm][name]) ~= "table" then
			KkthnxUIDB.Variables[realm][name] = {}
		end
	end

	return KkthnxUIDB.Settings[realm], KkthnxUIDB.Variables[realm]
end

function ProfileService:GetProfileSettings(realm, name)
	local realmData = KkthnxUIDB and KkthnxUIDB.Settings and KkthnxUIDB.Settings[realm]
	local settings = realmData and realmData[name]
	return (type(settings) == "table") and settings or nil
end

function ProfileService:GetProfileVariables(realm, name)
	local realmData = KkthnxUIDB and KkthnxUIDB.Variables and KkthnxUIDB.Variables[realm]
	local variables = realmData and realmData[name]
	return (type(variables) == "table") and variables or nil
end

function ProfileService:ValidateProfileName(name)
	if not name or type(name) ~= "string" then
		return false, "Profile name must be a string"
	end
	if #name == 0 then
		return false, "Profile name cannot be empty"
	end
	if #name > PROFILE_NAME_MAX_LENGTH then
		return false, "Profile name too long (max " .. PROFILE_NAME_MAX_LENGTH .. " characters)"
	end
	if name:match('[%\\/:*?"<>|]') then
		return false, "Profile name contains invalid characters"
	end

	local reservedNames = { "Default", "Backup", "Temp", "Cache", "Config", "Settings", "Variables" }
	for _, reserved in ipairs(reservedNames) do
		if name:lower() == reserved:lower() then
			return false, "Profile name '" .. name .. "' is reserved"
		end
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
	if not data.Settings and not data.Variables then
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

function ProfileService:ExportProfile(profileKey)
	local profiles = self:GetAllProfiles()
	local profile = profiles[profileKey or self:GetCurrentProfileKey()]
	if not profile then
		return nil, "Profile not found"
	end
	if not K.LibSerialize or not K.LibDeflate then
		return nil, "Required libraries not available for export"
	end

	local settingsSnapshot = CopyProfileData(self:GetProfileSettings(profile.realm, profile.name))
	if K.Defaults and type(K.Defaults) == "table" then
		settingsSnapshot = self:PruneSettingsByDefaults(settingsSnapshot, K.Defaults)
	end

	local exportData = {
		Version = PROFILE_VERSION,
		ExportedAt = time(),
		ExportedBy = K.Name .. "@" .. K.Realm,
		Settings = settingsSnapshot,
		Variables = CopyProfileData(self:GetProfileVariables(profile.realm, profile.name)),
	}

	if not exportData.Settings or type(exportData.Settings) ~= "table" then
		return nil, "Export failed: Invalid settings data"
	end

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

	local currentExport = (function()
		local ok, out = pcall(function()
			return self:ExportProfile(self:GetCurrentProfileKey())
		end)
		return ok and out or nil
	end)()
	if applyToCurrent and type(currentExport) == "string" and trim(profileString) == currentExport then
		return false, "You are currently using this profile"
	end

	if not data.Settings or type(data.Settings) ~= "table" then
		return false, "Invalid profile data - missing or invalid settings"
	end
	if data.Version and data.Version ~= PROFILE_VERSION then
		print("|cff669DFFKkthnxUI:|r Warning: Profile version mismatch. Some settings may not work correctly.")
	end

	if applyToCurrent then
		local settingsByRealm, variablesByRealm = self:EnsureProfileStorage(K.Realm)
		settingsByRealm[K.Name] = CopyProfileData(data.Settings)
		variablesByRealm[K.Name] = MarkInstallComplete(CopyProfileData(data.Variables))
		settingsByRealm[K.Name].ImportedAt = time()
		settingsByRealm[K.Name].ImportedBy = K.Name
		settingsByRealm[K.Name].ImportedFrom = data.ProfileName or "Unknown"
		settingsByRealm[K.Name].LastModified = time()
		return true, "Profile applied to " .. K.Name .. " successfully"
	end

	local profileName = data.ProfileName or "Imported Profile"
	local valid, error = self:ValidateProfileName(profileName)
	if not valid then
		return false, error
	end

	local profileKey = K.Realm .. "-" .. profileName
	if self:GetAllProfiles()[profileKey] then
		return false, "Profile '" .. profileName .. "' already exists"
	end

	local settingsByRealm, variablesByRealm = self:EnsureProfileStorage(K.Realm)
	settingsByRealm[profileName] = CopyProfileData(data.Settings)
	variablesByRealm[profileName] = MarkInstallComplete(CopyProfileData(data.Variables))
	settingsByRealm[profileName].ImportedAt = time()
	settingsByRealm[profileName].ImportedBy = K.Name
	settingsByRealm[profileName].ImportedFrom = data.ProfileName or "Unknown"
	settingsByRealm[profileName].LastModified = time()
	return true, "Profile created as '" .. profileName .. "' successfully"
end

function ProfileService:CreateProfile(profileName, sourceProfile)
	local valid, error = self:ValidateProfileName(profileName)
	if not valid then
		return false, error
	end

	local profileKey = K.Realm .. "-" .. profileName
	if self:GetAllProfiles()[profileKey] then
		return false, "Profile '" .. profileName .. "' already exists"
	end

	local settingsByRealm, variablesByRealm = self:EnsureProfileStorage(K.Realm)
	if sourceProfile then
		local source = self:GetAllProfiles()[sourceProfile]
		if not source then
			return false, "Source profile not found"
		end
		settingsByRealm[profileName] = CopyProfileData(self:GetProfileSettings(source.realm, source.name))
		variablesByRealm[profileName] = CopyProfileData(self:GetProfileVariables(source.realm, source.name))
	else
		settingsByRealm[profileName] = CopyProfileData(self:GetProfileSettings(K.Realm, K.Name))
		variablesByRealm[profileName] = CopyProfileData(self:GetProfileVariables(K.Realm, K.Name))
	end

	settingsByRealm[profileName].CreatedAt = time()
	settingsByRealm[profileName].CreatedBy = K.Name
	settingsByRealm[profileName].LastModified = time()
	return true, "Profile created successfully"
end

function ProfileService:RenameProfile(profileKey, newName)
	local valid, error = self:ValidateProfileName(newName)
	if not valid then
		return false, error
	end

	local profiles = self:GetAllProfiles()
	local profile = profiles[profileKey]
	if not profile then
		return false, "Profile not found"
	end
	if profile.isCurrent then
		return false, "Cannot rename the currently active profile"
	end

	local newProfileKey = profile.realm .. "-" .. newName
	if profiles[newProfileKey] then
		return false, "Profile '" .. newName .. "' already exists"
	end

	local oldSettings = self:GetProfileSettings(profile.realm, profile.name)
	local oldVariables = self:GetProfileVariables(profile.realm, profile.name)
	if not oldSettings then
		return false, "Profile data not found"
	end

	local settingsByRealm, variablesByRealm = self:EnsureProfileStorage(profile.realm)
	settingsByRealm[newName] = CopyProfileData(oldSettings)
	if oldVariables then
		variablesByRealm[newName] = CopyProfileData(oldVariables)
	end
	settingsByRealm[newName].LastModified = time()
	settingsByRealm[newName].RenamedFrom = profile.name
	settingsByRealm[newName].RenamedAt = time()
	settingsByRealm[profile.name] = nil
	variablesByRealm[profile.name] = nil

	return true, "Profile renamed successfully", newProfileKey
end

function ProfileService:DeleteProfile(profileKey)
	if profileKey == self:GetCurrentProfileKey() then
		return false, "Cannot delete the currently active profile"
	end

	local profile = self:GetAllProfiles()[profileKey]
	if not profile then
		return false, "Profile not found"
	end

	local settingsByRealm, variablesByRealm = self:EnsureProfileStorage(profile.realm)
	settingsByRealm[profile.name] = nil
	variablesByRealm[profile.name] = nil
	return true, "Profile deleted successfully"
end

function ProfileService:SwitchProfile(profileKey)
	if profileKey == self:GetCurrentProfileKey() then
		return false, "Already using this profile"
	end

	local profile = self:GetAllProfiles()[profileKey]
	if not profile then
		return false, "Profile not found"
	end

	local sourceSettings = self:GetProfileSettings(profile.realm, profile.name)
	if not sourceSettings then
		return false, "Profile data not found"
	end

	local settingsByRealm, variablesByRealm = self:EnsureProfileStorage(K.Realm)
	settingsByRealm[K.Name] = CopyProfileData(sourceSettings)
	variablesByRealm[K.Name] = MarkInstallComplete(CopyProfileData(self:GetProfileVariables(profile.realm, profile.name)))
	settingsByRealm[K.Name].LastSwitched = time()
	settingsByRealm[K.Name].SwitchedFrom = profileKey
	settingsByRealm[K.Name].LastModified = time()
	return true, "Profile switch initiated"
end

function ProfileService:ResetProfile(profileKey)
	local profile = profileKey and self:GetAllProfiles()[profileKey] or nil

	if not profile then
		local settingsByRealm, variablesByRealm = self:EnsureProfileStorage(K.Realm)
		settingsByRealm[K.Name] = {}
		variablesByRealm[K.Name] = MarkInstallComplete({})
		settingsByRealm[K.Name].ResetAt = time()
		settingsByRealm[K.Name].ResetBy = K.Name
		settingsByRealm[K.Name].LastModified = time()
	else
		local settingsByRealm, variablesByRealm = self:EnsureProfileStorage(profile.realm)
		settingsByRealm[profile.name] = {}
		variablesByRealm[profile.name] = MarkInstallComplete({})
		settingsByRealm[profile.name].ResetAt = time()
		settingsByRealm[profile.name].ResetBy = K.Name
		settingsByRealm[profile.name].LastModified = time()
	end

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
	return KkthnxUIDB and KkthnxUIDB.Settings and KkthnxUIDB.Variables
end

function ProfileService:UpdateCurrentProfileTimestamp()
	local settings = self:GetProfileSettings(K.Realm, K.Name)
	if settings then
		settings.LastModified = time()
	end
end

function ProfileService:MigrateProfileTimestamps()
	if not KkthnxUIDB or type(KkthnxUIDB.Settings) ~= "table" then
		return
	end

	for _, realmData in pairs(KkthnxUIDB.Settings) do
		if type(realmData) == "table" then
			for _, profileData in pairs(realmData) do
				if type(profileData) == "table" and not profileData.LastModified then
					profileData.LastModified = time()
				end
			end
		end
	end
end
