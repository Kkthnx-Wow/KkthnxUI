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

-- The profile this character loads next. It differs from the active one between
-- picking a profile and reloading.
function K:GetPendingProfileName()
	return KkthnxUIDB.profileKeys[GetCharKey()] or activeProfileName
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
	-- Mover positions are stored beside the profile, so they go with it.
	local movers = KkthnxUIDB.movers and KkthnxUIDB.movers[activeProfileName]
	if movers then
		wipe(movers)
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
	if KkthnxUIDB.movers then
		KkthnxUIDB.movers[name] = nil
	end
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

	-- Positions follow the profile they were saved under.
	KkthnxUIDB.movers = KkthnxUIDB.movers or {}
	local target = KkthnxUIDB.movers[activeProfileName]
	if not target then
		target = {}
		KkthnxUIDB.movers[activeProfileName] = target
	end
	wipe(target)
	for k, v in pairs(DeepCopy(KkthnxUIDB.movers[fromName] or {})) do
		target[k] = v
	end

	K.Print("Copied profile '%s'. Reload the UI to apply.", fromName)
	return true
end

-- ---------------------------------------------------------------------------
-- Export and import
-- ---------------------------------------------------------------------------
-- A profile travels as one pasteable line: a short tag, then the settings and
-- mover positions serialized, deflated and base64 encoded. Import never trusts
-- the text. Every value is checked against the defaults, so an edited or foreign
-- string can only ever set options that exist, to values of the right type.

local EXPORT_TAG = "KKUI1:"
local EXPORT_LIMIT = 262144

local ANCHORS = {
	CENTER = true, TOP = true, BOTTOM = true, LEFT = true, RIGHT = true,
	TOPLEFT = true, TOPRIGHT = true, BOTTOMLEFT = true, BOTTOMRIGHT = true,
}

-- Free form tables (favorites, item assignments, custom colours) default to an
-- empty table, so their content has no template to check against. Plain strings,
-- numbers and booleans are kept and anything else is dropped.
local function CleanLoose(value, depth)
	local kind = type(value)
	if kind == "string" or kind == "boolean" then
		return value
	elseif kind == "number" then
		if value == value and value ~= math.huge and value ~= -math.huge then
			return value
		end
	elseif kind == "table" and depth < 4 then
		local copy = {}
		for k, v in pairs(value) do
			local keyKind = type(k)
			if keyKind == "string" or keyKind == "number" then
				local clean = CleanLoose(v, depth + 1)
				if clean ~= nil then
					copy[k] = clean
				end
			end
		end
		return copy
	end
end

-- Build a table holding only the entries of data that the defaults describe.
local function Sanitize(data, defaults)
	local out = {}
	if type(data) ~= "table" then
		return out
	end
	for key, template in pairs(defaults) do
		local value = data[key]
		if value ~= nil then
			if type(template) == "table" then
				if type(value) == "table" then
					if next(template) == nil or template[1] ~= nil then
						out[key] = CleanLoose(value, 0)
					else
						out[key] = Sanitize(value, template)
					end
				end
			elseif type(value) == type(template) then
				out[key] = CleanLoose(value, 0)
			end
		end
	end
	return out
end

local function SanitizeMovers(data)
	local out = {}
	if type(data) ~= "table" then
		return out
	end
	for key, entry in pairs(data) do
		if type(key) == "string" and type(entry) == "table" then
			if type(entry.point) == "string" and ANCHORS[entry.point] and type(entry.x) == "number" and type(entry.y) == "number" then
				out[key] = { point = entry.point, x = entry.x, y = entry.y }
			elseif type(entry[1]) == "number" and type(entry[2]) == "number" then
				out[key] = { entry[1], entry[2] }
			end
		end
	end
	return out
end
K.SanitizeProfileData = Sanitize

-- Returns the export line for a profile, or nil and a reason.
function K:ExportProfile(name)
	name = name or activeProfileName
	local source = KkthnxUIDB.profiles[name]
	if type(source) ~= "table" then
		return nil, "That profile does not exist."
	end
	local encoding = _G.C_EncodingUtil
	if not (encoding and encoding.SerializeCBOR and encoding.CompressString and encoding.EncodeBase64) then
		return nil, "This game client cannot export profiles."
	end

	-- The loaded profile can still hold values equal to the defaults until logout.
	local settings = DeepCopy(source)
	StripDefaults(settings, K.ConfigDefaults)

	local payload = {
		v = 1,
		settings = settings,
		movers = DeepCopy((KkthnxUIDB.movers and KkthnxUIDB.movers[name]) or {}),
	}
	local ok, serialized = pcall(encoding.SerializeCBOR, payload)
	if not ok or not serialized then
		return nil, "The profile could not be serialized."
	end
	local compressed = encoding.CompressString(serialized, _G.Enum.CompressionMethod.Deflate)
	return EXPORT_TAG .. encoding.EncodeBase64(compressed)
end

-- Make a new profile from an export line. Returns the profile name, or nil and a
-- reason. The new profile is not activated, so nothing changes until it is used.
function K:ImportProfile(text, name)
	if type(text) ~= "string" then
		return nil, "Nothing to import."
	end
	text = text:gsub("%s+", "")
	if #text > EXPORT_LIMIT or text:sub(1, #EXPORT_TAG) ~= EXPORT_TAG then
		return nil, "That is not a KkthnxUI profile string."
	end
	if not name or name == "" or KkthnxUIDB.profiles[name] then
		return nil, "Pick a profile name that is not already used."
	end
	local encoding = _G.C_EncodingUtil
	if not (encoding and encoding.DeserializeCBOR and encoding.DecompressString and encoding.DecodeBase64) then
		return nil, "This game client cannot import profiles."
	end

	local ok, payload = pcall(function()
		local decoded = encoding.DecodeBase64(text:sub(#EXPORT_TAG + 1))
		local inflated = encoding.DecompressString(decoded, _G.Enum.CompressionMethod.Deflate)
		return encoding.DeserializeCBOR(inflated)
	end)
	if not ok or type(payload) ~= "table" or payload.v ~= 1 then
		return nil, "That profile string is damaged or from a newer version."
	end

	KkthnxUIDB.profiles[name] = Sanitize(payload.settings, K.ConfigDefaults)
	KkthnxUIDB.movers = KkthnxUIDB.movers or {}
	KkthnxUIDB.movers[name] = SanitizeMovers(payload.movers)
	return name
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
