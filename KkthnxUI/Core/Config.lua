--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Core/Config.lua
	Purpose:
		SavedVariables backed config with named profiles. The active profile is
		deep merged onto the defaults into the live C table. On logout the values
		that still match defaults are stripped so the saved file stays small.

	Layout of KkthnxUIDB:
		{
			profileKeys = { ["Char - Realm"] = "ProfileName" },
			profiles    = { ["ProfileName"] = { ...user overrides... } },
		}
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

local pairs = pairs
local type = type
local next = next
local wipe = wipe

-- ---------------------------------------------------------------------------
-- Table helpers
-- ---------------------------------------------------------------------------

local function DeepCopy(src)
	if type(src) ~= "table" then
		return src
	end
	local copy = {}
	for k, v in pairs(src) do
		copy[k] = DeepCopy(v)
	end
	return copy
end
K.DeepCopy = DeepCopy

-- Fill missing keys in dest from src without overwriting existing values.
local function MergeDefaults(dest, src)
	for k, v in pairs(src) do
		if type(v) == "table" then
			if type(dest[k]) ~= "table" then
				dest[k] = {}
			end
			MergeDefaults(dest[k], v)
		elseif dest[k] == nil then
			dest[k] = v
		end
	end
	return dest
end
K.MergeDefaults = MergeDefaults

-- Remove values from db that match defaults, so overrides only keep real diffs.
local function StripDefaults(db, defaults)
	for k, v in pairs(defaults) do
		if type(v) == "table" and type(db[k]) == "table" then
			StripDefaults(db[k], v)
			if not next(db[k]) then
				db[k] = nil
			end
		elseif db[k] == v then
			db[k] = nil
		end
	end
end

-- ---------------------------------------------------------------------------
-- Profile resolution
-- ---------------------------------------------------------------------------

local function GetCharKey()
	return K.Name .. " - " .. K.Realm
end

local activeProfileName

function K:GetActiveProfileName()
	return activeProfileName
end

function K:ListProfiles()
	local list = {}
	for name in pairs(KkthnxUIDB.profiles) do
		list[#list + 1] = name
	end
	return list
end

-- Switch profiles and rebuild C. Modules should listen for the reload prompt.
function K:SetProfile(name)
	if not KkthnxUIDB.profiles[name] then
		KkthnxUIDB.profiles[name] = {}
	end
	KkthnxUIDB.profileKeys[GetCharKey()] = name
	K.Print("Profile set to '%s'. Reload the UI to apply.", name)
end

function K:ResetProfile()
	if activeProfileName and KkthnxUIDB.profiles[activeProfileName] then
		wipe(KkthnxUIDB.profiles[activeProfileName])
	end
	K.Print("Active profile reset. Reload the UI to apply.")
end

-- Create an empty profile (no-op if it already exists).
function K:CreateProfile(name)
	if not name or name == "" or KkthnxUIDB.profiles[name] then
		return false
	end
	KkthnxUIDB.profiles[name] = {}
	return true
end

-- Delete a profile. The active profile cannot be deleted.
function K:DeleteProfile(name)
	if not name or name == activeProfileName or not KkthnxUIDB.profiles[name] then
		return false
	end
	KkthnxUIDB.profiles[name] = nil
	-- Drop any character keys that pointed at it.
	for charKey, profileName in pairs(KkthnxUIDB.profileKeys) do
		if profileName == name then
			KkthnxUIDB.profileKeys[charKey] = "Default"
		end
	end
	return true
end

-- Copy another profile's data into the active profile.
function K:CopyProfile(fromName)
	local source = KkthnxUIDB.profiles[fromName]
	if not source or fromName == activeProfileName then
		return false
	end
	wipe(K.ActiveProfile)
	for k, v in pairs(DeepCopy(source)) do
		K.ActiveProfile[k] = v
	end
	K.Print("Copied profile '%s'. Reload the UI to apply.", fromName)
	return true
end

-- ---------------------------------------------------------------------------
-- Setup, called by the engine before any module OnInitialize.
-- ---------------------------------------------------------------------------

function K:SetupConfig()
	KkthnxUIDB = KkthnxUIDB or {}
	KkthnxUIDB.profileKeys = KkthnxUIDB.profileKeys or {}
	KkthnxUIDB.profiles = KkthnxUIDB.profiles or {}

	local charKey = GetCharKey()
	activeProfileName = KkthnxUIDB.profileKeys[charKey]
	if not activeProfileName then
		activeProfileName = "Default"
		KkthnxUIDB.profileKeys[charKey] = activeProfileName
	end

	local profile = KkthnxUIDB.profiles[activeProfileName]
	if type(profile) ~= "table" then
		profile = {}
		KkthnxUIDB.profiles[activeProfileName] = profile
	end

	-- Build the live config: defaults first, then the stored overrides win.
	local defaults = K.ConfigDefaults
	local live = DeepCopy(defaults)
	-- Overlay stored overrides onto the defaults copy.
	local function Overlay(dest, src)
		for k, v in pairs(src) do
			if type(v) == "table" and type(dest[k]) == "table" then
				Overlay(dest[k], v)
			else
				dest[k] = v
			end
		end
	end
	Overlay(live, profile)

	-- Copy the built values into the shared C table in place so existing
	-- references to C stay valid.
	for k in pairs(C) do
		if k ~= "Media" then
			C[k] = nil
		end
	end
	for k, v in pairs(live) do
		C[k] = v
	end

	-- Keep the stored profile table as the write target for live edits.
	K.ActiveProfile = profile
	K.DB = KkthnxUIDB
end

-- Persist a single setting into the active profile right away.
-- path is a list of keys, e.g. K:SetConfig({"ActionBar", "ButtonSize"}, 36)
function K:SetConfig(path, value)
	local node = K.ActiveProfile
	for i = 1, #path - 1 do
		local key = path[i]
		if type(node[key]) ~= "table" then
			node[key] = {}
		end
		node = node[key]
	end
	node[path[#path]] = value

	-- Mirror into the live C table.
	local live = C
	for i = 1, #path - 1 do
		live = live[path[i]]
	end
	live[path[#path]] = value
end

-- ---------------------------------------------------------------------------
-- Logout: strip defaults so the saved file stays clean.
-- ---------------------------------------------------------------------------

local logout = CreateFrame("Frame")
logout:RegisterEvent("PLAYER_LOGOUT")
logout:SetScript("OnEvent", function()
	if K.ActiveProfile then
		StripDefaults(K.ActiveProfile, K.ConfigDefaults)
	end
end)
