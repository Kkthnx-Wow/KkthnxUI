local K, C = KkthnxUI[1], KkthnxUI[2]

-- System Documentation

--[[
Advanced ProfileGUI System for KkthnxUI

Inspired by NDui's ProfileGUI system, this provides comprehensive
profile management including:
- Profile list management with visual interface
- Create, copy, delete, reset profiles
- Data validation and error handling
- Import/export with improved security
- Profile sharing and backup
- Automatic profile switching options
- Modern UI design
]]

-- API Declarations

-- Lua API
local _G = _G
local ipairs, pairs = ipairs, pairs
local type = type
local select = select
local tinsert = table.insert
local time = time
local date = date
local UnitClass = UnitClass
local UnitRace = UnitRace
local UnitSex = UnitSex
local UnitFactionGroup = UnitFactionGroup
local debugprofilestop = debugprofilestop

-- WoW API
local CreateFrame = CreateFrame
local UIParent = UIParent
local ReloadUI = ReloadUI
local PlaySound = PlaySound
local SOUNDKIT = SOUNDKIT
local SetPortraitTexture = SetPortraitTexture

-- Utility Functions

-- String utility functions
local function trim(str)
	if not str then
		return ""
	end
	return str:match("^%s*(.-)%s*$") or ""
end

-- Add trim method to string metatable if not already present
if not string.trim then
	string.trim = trim
end

-- Configuration Constants

-- Profile System Configuration
local PROFILE_VERSION = "2.0.0"
local PROFILE_PREFIX = "KkthnxUI:Profile:"
local PROFILE_NAME_MAX_LENGTH = 32

-- UI Constants

-- Panel Dimensions (match main GUI proportions)
local PANEL_WIDTH = 560
local PANEL_HEIGHT = 640
local LIST_WIDTH = 200
local LIST_HEIGHT = 420
local BUTTON_HEIGHT = 28
local SPACING = 8
local HEADER_HEIGHT = 40

-- Colors (match main GUI design exactly)
local ACCENT_COLOR = { K.r, K.g, K.b }
local TEXT_COLOR = { 0.9, 0.9, 0.9, 1 }
local SUCCESS_COLOR = { 0.3, 0.9, 0.3 }
local ERROR_COLOR = { 0.9, 0.3, 0.3 }
local WARNING_COLOR = { 0.9, 0.7, 0.2 }
local BG_COLOR = C["Media"].Backdrops.ColorBackdrop
local SIDEBAR_COLOR = { 0.05, 0.05, 0.05, 0.95 }
local WIDGET_BG = { 0.12, 0.12, 0.12, 0.8 }
local BUTTON_HOVER = { 0.18, 0.18, 0.18, 1 }
local SELECTED_BG = { 0.15, 0.15, 0.15, 0.9 }

-- ProfileGUI Module Core

-- ProfileGUI Main Object
local ProfileGUI = {
	Frame = nil,
	IsVisible = false,
	CurrentProfile = nil,
	ProfileList = {},
	SelectedProfile = nil,
	LastUpdate = 0,
}

-- Helper Functions

-- Create colored background texture (matching main GUI exactly)
local function CreateColoredBackground(frame, r, g, b, a)
	local bg = frame:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints()
	bg:SetTexture(C["Media"].Textures.White8x8Texture)
	bg:SetVertexColor(r or 0, g or 0, b or 0, a or 0.8)
	return bg
end

-- Create clean, simple button (updated to match main GUI styling exactly)
local function CreateButton(parent, text, width, height, onClick)
	local button = CreateFrame("Button", nil, parent)
	button:SetSize(width or 120, height or BUTTON_HEIGHT)

	-- Clean button background (matching main GUI exactly)
	local buttonBg = button:CreateTexture(nil, "BACKGROUND")
	buttonBg:SetAllPoints()
	buttonBg:SetTexture(C["Media"].Textures.White8x8Texture)
	buttonBg:SetVertexColor(0.15, 0.15, 0.15, 1)
	button.KKUI_Background = buttonBg

	-- Subtle border for depth (matching main GUI exactly)
	local buttonBorder = button:CreateTexture(nil, "BORDER")
	buttonBorder:SetPoint("TOPLEFT", -1, 1)
	buttonBorder:SetPoint("BOTTOMRIGHT", 1, -1)
	buttonBorder:SetTexture(C["Media"].Textures.White8x8Texture)
	buttonBorder:SetVertexColor(0.3, 0.3, 0.3, 0.8)
	button.KKUI_Border = buttonBorder

	-- Hover effects for clean design (matching main GUI exactly)
	button:SetScript("OnEnter", function(self)
		self.KKUI_Background:SetVertexColor(ACCENT_COLOR[1] * 0.8, ACCENT_COLOR[2] * 0.8, ACCENT_COLOR[3] * 0.8, 1)
		self.KKUI_Border:SetVertexColor(ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3], 1)
		if self.Text then
			self.Text:SetTextColor(1, 1, 1, 1)
		end
	end)

	button:SetScript("OnLeave", function(self)
		self.KKUI_Background:SetVertexColor(0.15, 0.15, 0.15, 1)
		self.KKUI_Border:SetVertexColor(0.3, 0.3, 0.3, 0.8)
		if self.Text then
			self.Text:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
		end
	end)

	-- Click effect (matching main GUI exactly)
	button:SetScript("OnMouseDown", function(self)
		self.KKUI_Background:SetVertexColor(ACCENT_COLOR[1] * 0.6, ACCENT_COLOR[2] * 0.6, ACCENT_COLOR[3] * 0.6, 1)
	end)

	button:SetScript("OnMouseUp", function(self)
		if self:IsMouseOver() then
			self.KKUI_Background:SetVertexColor(ACCENT_COLOR[1] * 0.8, ACCENT_COLOR[2] * 0.8, ACCENT_COLOR[3] * 0.8, 1)
		else
			self.KKUI_Background:SetVertexColor(0.15, 0.15, 0.15, 1)
		end
	end)

	-- Button text
	button.Text = button:CreateFontString(nil, "OVERLAY")
	button.Text:SetFontObject(K.UIFont)
	button.Text:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
	button.Text:SetText(text)
	button.Text:SetPoint("CENTER")

	if onClick then
		button:SetScript("OnClick", onClick)
	end

	return button
end

-- Simplified EditBox
local function CreateEditBox(parent, width, height, multiline)
	local editBox = CreateFrame("EditBox", nil, parent)
	editBox:SetSize(width or 200, height or 32)
	editBox:SetFontObject(K.UIFont)
	editBox:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
	editBox:SetAutoFocus(false)
	editBox:SetTextInsets(8, 8, 4, 4)

	if multiline then
		editBox:SetMultiLine(true)
		editBox:SetMaxLetters(0)
	end

	-- Simple background (matching main GUI exactly)
	local inputBg = editBox:CreateTexture(nil, "BACKGROUND")
	inputBg:SetAllPoints()
	inputBg:SetTexture(C["Media"].Textures.White8x8Texture)
	inputBg:SetVertexColor(0.1, 0.1, 0.1, 1)

	-- Simple focus effects (matching main GUI exactly)
	editBox:SetScript("OnEditFocusGained", function(self)
		inputBg:SetVertexColor(0.15, 0.15, 0.15, 1)
	end)

	editBox:SetScript("OnEditFocusLost", function(self)
		inputBg:SetVertexColor(0.1, 0.1, 0.1, 1)
	end)

	editBox:SetScript("OnEscapePressed", function(self)
		self:ClearFocus()
	end)

	return editBox
end

-- Profile Data Management

-- Profile Data Management
function ProfileGUI:GetCurrentProfileKey()
	return K.Realm .. "-" .. K.Name
end

function ProfileGUI:GetAllProfiles()
	local profiles = {}

	if not KkthnxUIDB or not KkthnxUIDB.Settings then
		return profiles
	end

	for realm, realmData in pairs(KkthnxUIDB.Settings) do
		for name, profileData in pairs(realmData) do
			local profileKey = realm .. "-" .. name
			local displayName = name .. " (" .. realm .. ")"

			profiles[profileKey] = {
				key = profileKey,
				name = name,
				realm = realm,
				displayName = displayName,
				data = profileData,
				isCurrent = (profileKey == self:GetCurrentProfileKey()),
				lastModified = profileData.LastModified or 0,
			}
		end
	end

	return profiles
end

-- Profile Validation

function ProfileGUI:ValidateProfileName(name)
	if not name or type(name) ~= "string" then
		return false, "Profile name must be a string"
	end

	if #name == 0 then
		return false, "Profile name cannot be empty"
	end

	if #name > PROFILE_NAME_MAX_LENGTH then
		return false, "Profile name too long (max " .. PROFILE_NAME_MAX_LENGTH .. " characters)"
	end

	-- Check for invalid characters
	if name:match('[%\\/:*?"<>|]') then
		return false, "Profile name contains invalid characters"
	end

	-- Check for reserved names
	local reservedNames = { "Default", "Backup", "Temp", "Cache", "Config", "Settings", "Variables" }
	for _, reserved in ipairs(reservedNames) do
		if name:lower() == reserved:lower() then
			return false, "Profile name '" .. name .. "' is reserved"
		end
	end

	return true
end

function ProfileGUI:ValidateProfileData(data)
	if not data or type(data) ~= "table" then
		return false, "Invalid profile data structure"
	end

	-- Check for required fields
	if not data.Version then
		return false, "Profile missing version information"
	end

	if not data.Settings and not data.Variables then
		return false, "Profile contains no configuration data"
	end

	return true
end

-- Profile Import/Export

-- Prune settings by removing metadata keys and values equal to defaults
local function KKUI_PruneSettingsByDefaults(currentTable, defaultTable)
	local META = {
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

	local function prune(curr, defs, depth)
		depth = depth or 0
		if depth > 20 or type(curr) ~= "table" then
			return curr
		end
		local out = {}
		for k, v in pairs(curr) do
			if not META[k] then
				local dv = (type(defs) == "table") and defs[k] or nil
				if type(v) == "table" then
					local pruned = prune(v, dv, depth + 1)
					if type(pruned) == "table" then
						local hasAny
						for _ in pairs(pruned) do
							hasAny = true
							break
						end
						if hasAny then
							out[k] = pruned
						end
					else
						out[k] = pruned
					end
				else
					if v ~= dv then
						out[k] = v
					end
				end
			end
		end
		return out
	end

	return prune(currentTable, defaultTable, 0)
end

-- Prune Variables by removing ephemeral keys and empty tables
local function KKUI_PruneVariables(varsTable)
	if type(varsTable) ~= "table" then
		return {}
	end
	local DROP = {
		TempAnchor = true,
		InstallComplete = true,
		DBMRequest = true,
		MaxDpsRequest = true,
		CursorTrailRequest = true,
		HekiliRequest = true,
		ResetDetails = true,
	}
	local function clean(t, depth)
		depth = depth or 0
		if depth > 20 or type(t) ~= "table" then
			return t
		end
		local out = {}
		for k, v in pairs(t) do
			if not DROP[k] then
				if type(v) == "table" then
					local child = clean(v, depth + 1)
					local hasAny
					if type(child) == "table" then
						for _ in pairs(child) do
							hasAny = true
							break
						end
					end
					if hasAny then
						out[k] = child
					end
				else
					out[k] = v
				end
			end
		end
		return out
	end
	return clean(varsTable, 0)
end

function ProfileGUI:ExportProfile(profileKey)
	local profiles = self:GetAllProfiles()
	local profile = profiles[profileKey or self:GetCurrentProfileKey()]

	if not profile then
		return nil, "Profile not found"
	end

	-- Check if libraries are available
	if not K.LibSerialize or not K.LibDeflate then
		return nil, "Required libraries not available for export"
	end

	-- Snapshot settings and prune to only differences from defaults
	local settingsSnapshot = K.CopyTable(KkthnxUIDB.Settings[profile.realm][profile.name] or {})
	if K.Defaults and type(K.Defaults) == "table" then
		settingsSnapshot = KKUI_PruneSettingsByDefaults(settingsSnapshot, K.Defaults)
	end

	-- Snapshot Variables
	local variablesSnapshot = K.CopyTable(KkthnxUIDB.Variables[profile.realm] and KkthnxUIDB.Variables[profile.realm][profile.name] or {})

	-- Prepare the export data structure
	local exportData = {
		Version = PROFILE_VERSION,
		ExportedAt = time(),
		ExportedBy = K.Name .. "@" .. K.Realm,
		Settings = settingsSnapshot,
		Variables = variablesSnapshot,
	}

	-- Debug: Validate export data before serialization
	if not exportData.Settings or type(exportData.Settings) ~= "table" then
		return nil, "Export failed: Invalid settings data"
	end

	local serialized = K.LibSerialize:Serialize(exportData)
	if not serialized then
		return nil, "Failed to serialize profile data"
	end

	-- Debug: Check serialized data
	if type(serialized) ~= "string" or #serialized == 0 then
		return nil, "Failed to serialize profile data - invalid output"
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

function ProfileGUI:ImportProfile(profileString, applyToCurrent)
	if not profileString or type(profileString) ~= "string" then
		return false, "Invalid profile string"
	end

	-- Trim the profile string to remove any leading/trailing whitespace
	profileString = profileString:trim()

	-- Check if libraries are available
	if not K.LibSerialize or not K.LibDeflate then
		return false, "Required libraries not available for import"
	end

	-- Support both old and new profile formats
	local isNewFormat = profileString:find(PROFILE_PREFIX, 1, true)
	local isOldFormat = profileString:find("KkthnxUI:Profile:", 1, true)

	if not isNewFormat and not isOldFormat then
		return false, "Invalid profile format (missing KkthnxUI prefix)"
	end

	-- Remove appropriate prefix
	local dataString
	if isNewFormat then
		dataString = profileString:sub(#PROFILE_PREFIX + 1)
	else
		dataString = profileString:sub(#"KkthnxUI:Profile:" + 1)
	end

	-- Decode and decompress with error handling
	local decoded = K.LibDeflate:DecodeForPrint(dataString)
	if not decoded then
		return false, "Failed to decode profile data"
	end

	local decompressed = K.LibDeflate:DecompressDeflate(decoded)
	if not decompressed then
		return false, "Failed to decompress profile data - invalid compression"
	end

	-- Deserialize with error handling
	local success, data = K.LibSerialize:Deserialize(decompressed)
	if not success or not data then
		return false, "Failed to parse profile data"
	end

	-- If code matches current export exactly
	local currentExport = (function()
		local ok, out = pcall(function()
			return self:ExportProfile(self:GetCurrentProfileKey())
		end)
		if ok then
			return out
		end
		return nil
	end)()
	if applyToCurrent and type(currentExport) == "string" then
		local pasted = profileString:trim()
		if pasted == currentExport then
			return false, "You are currently using this profile"
		end
	end

	-- Validate data structure
	if not data.Settings or type(data.Settings) ~= "table" then
		return false, "Invalid profile data - missing or invalid settings"
	end

	-- Check version compatibility
	if data.Version and data.Version ~= PROFILE_VERSION then
		print("|cff669DFFKkthnxUI:|r Warning: Profile version mismatch. Some settings may not work correctly.")
	end

	-- Ensure database integrity
	if not self:EnsureDatabaseIntegrity() then
		return false, "Database not available"
	end

	if applyToCurrent then
		-- Apply to current character's profile
		local currentProfileName = K.Name

		-- Deep copy the imported data to current character
		KkthnxUIDB.Settings[K.Realm][currentProfileName] = K.CopyTable(data.Settings)
		KkthnxUIDB.Variables[K.Realm][currentProfileName] = K.CopyTable(data.Variables or {})

		-- Ensure installer is marked complete for the current character
		KkthnxUIDB.Variables[K.Realm][currentProfileName].InstallComplete = true

		-- Add import metadata
		KkthnxUIDB.Settings[K.Realm][currentProfileName].ImportedAt = time()
		KkthnxUIDB.Settings[K.Realm][currentProfileName].ImportedBy = K.Name
		KkthnxUIDB.Settings[K.Realm][currentProfileName].ImportedFrom = data.ProfileName or "Unknown"
		KkthnxUIDB.Settings[K.Realm][currentProfileName].LastModified = time()

		return true, "Profile applied to " .. currentProfileName .. " successfully"
	else
		-- Create new profile entry
		local profileName = data.ProfileName or "Imported Profile"
		local valid, error = self:ValidateProfileName(profileName)
		if not valid then
			return false, error
		end

		-- Check if profile already exists
		local currentKey = K.Realm .. "-" .. profileName
		local existingProfiles = self:GetAllProfiles()
		if existingProfiles[currentKey] then
			return false, "Profile '" .. profileName .. "' already exists"
		end

		-- Deep copy the imported data
		KkthnxUIDB.Settings[K.Realm][profileName] = K.CopyTable(data.Settings)
		KkthnxUIDB.Variables[K.Realm][profileName] = K.CopyTable(data.Variables or {})

		-- Mark imported profile as installed to skip tutorial on future activation
		if KkthnxUIDB.Variables[K.Realm][profileName] then
			KkthnxUIDB.Variables[K.Realm][profileName].InstallComplete = true
		end

		-- Add import metadata
		KkthnxUIDB.Settings[K.Realm][profileName].ImportedAt = time()
		KkthnxUIDB.Settings[K.Realm][profileName].ImportedBy = K.Name
		KkthnxUIDB.Settings[K.Realm][profileName].ImportedFrom = data.ProfileName or "Unknown"
		KkthnxUIDB.Settings[K.Realm][profileName].LastModified = time()

		return true, "Profile created as '" .. profileName .. "' successfully"
	end
end

function ProfileGUI:CreateProfile(profileName, sourceProfile)
	-- Ensure database integrity
	if not self:EnsureDatabaseIntegrity() then
		return false, "Database not available"
	end

	local valid, error = self:ValidateProfileName(profileName)
	if not valid then
		return false, error
	end

	-- Check if profile already exists
	local profileKey = K.Realm .. "-" .. profileName
	local existingProfiles = self:GetAllProfiles()
	if existingProfiles[profileKey] then
		return false, "Profile '" .. profileName .. "' already exists"
	end

	-- Create profile structure
	if not KkthnxUIDB.Settings[K.Realm] then
		KkthnxUIDB.Settings[K.Realm] = {}
	end
	if not KkthnxUIDB.Variables[K.Realm] then
		KkthnxUIDB.Variables[K.Realm] = {}
	end

	if sourceProfile then
		-- Copy from source profile
		local profiles = self:GetAllProfiles()
		local source = profiles[sourceProfile]

		if source then
			KkthnxUIDB.Settings[K.Realm][profileName] = K.CopyTable(KkthnxUIDB.Settings[source.realm][source.name] or {})
			KkthnxUIDB.Variables[K.Realm][profileName] = K.CopyTable(KkthnxUIDB.Variables[source.realm][source.name] or {})
		else
			return false, "Source profile not found"
		end
	else
		-- Create with current character settings as base
		local currentSettings = KkthnxUIDB.Settings[K.Realm][K.Name] or {}
		local currentVariables = KkthnxUIDB.Variables[K.Realm][K.Name] or {}

		KkthnxUIDB.Settings[K.Realm][profileName] = K.CopyTable(currentSettings)
		KkthnxUIDB.Variables[K.Realm][profileName] = K.CopyTable(currentVariables)
	end

	-- Add metadata
	KkthnxUIDB.Settings[K.Realm][profileName].CreatedAt = time()
	KkthnxUIDB.Settings[K.Realm][profileName].CreatedBy = K.Name
	KkthnxUIDB.Settings[K.Realm][profileName].LastModified = time()

	-- Ensure current character metadata is stored
	self:StoreCharacterMetadata(K.Name, K.Realm)

	return true, "Profile created successfully"
end

function ProfileGUI:RenameProfile(profileKey, newName)
	-- Ensure database integrity
	if not self:EnsureDatabaseIntegrity() then
		return false, "Database not available"
	end

	local valid, error = self:ValidateProfileName(newName)
	if not valid then
		return false, error
	end

	-- Get the profile data
	local profiles = self:GetAllProfiles()
	local profile = profiles[profileKey]
	if not profile then
		return false, "Profile not found"
	end

	-- Check if this is the current profile
	if profile.isCurrent then
		return false, "Cannot rename the currently active profile"
	end

	-- Check if new name already exists
	local newProfileKey = profile.realm .. "-" .. newName
	if profiles[newProfileKey] then
		return false, "Profile '" .. newName .. "' already exists"
	end

	-- Get the actual data from the database
	local oldSettings = KkthnxUIDB.Settings[profile.realm][profile.name]
	local oldVariables = KkthnxUIDB.Variables[profile.realm][profile.name]

	if not oldSettings then
		return false, "Profile data not found"
	end

	-- Create new profile with copied data
	KkthnxUIDB.Settings[profile.realm][newName] = K.CopyTable(oldSettings)
	if oldVariables then
		KkthnxUIDB.Variables[profile.realm][newName] = K.CopyTable(oldVariables)
	end

	-- Update metadata for the renamed profile
	KkthnxUIDB.Settings[profile.realm][newName].LastModified = time()
	KkthnxUIDB.Settings[profile.realm][newName].RenamedFrom = profile.name
	KkthnxUIDB.Settings[profile.realm][newName].RenamedAt = time()

	-- Remove old profile data
	KkthnxUIDB.Settings[profile.realm][profile.name] = nil
	if KkthnxUIDB.Variables[profile.realm] then
		KkthnxUIDB.Variables[profile.realm][profile.name] = nil
	end

	-- Update selected profile if it was the renamed one
	if self.SelectedProfile == profileKey then
		self.SelectedProfile = newProfileKey
	end

	return true, "Profile renamed successfully"
end

function ProfileGUI:DeleteProfile(profileKey)
	if profileKey == self:GetCurrentProfileKey() then
		return false, "Cannot delete the currently active profile"
	end

	local profiles = self:GetAllProfiles()
	local profile = profiles[profileKey]

	if not profile then
		return false, "Profile not found"
	end

	-- Delete from database
	if KkthnxUIDB.Settings[profile.realm] then
		KkthnxUIDB.Settings[profile.realm][profile.name] = nil
	end
	if KkthnxUIDB.Variables[profile.realm] then
		KkthnxUIDB.Variables[profile.realm][profile.name] = nil
	end

	return true, "Profile deleted successfully"
end

function ProfileGUI:SwitchProfile(profileKey)
	-- Ensure database integrity
	if not self:EnsureDatabaseIntegrity() then
		return false, "Database not available"
	end

	if profileKey == self:GetCurrentProfileKey() then
		return false, "Already using this profile"
	end

	local profiles = self:GetAllProfiles()
	local profile = profiles[profileKey]

	if not profile then
		return false, "Profile not found"
	end

	-- Switch the profile by copying the profile data to current character
	local sourceSettings = KkthnxUIDB.Settings[profile.realm][profile.name]
	local sourceVariables = KkthnxUIDB.Variables[profile.realm][profile.name]

	if sourceSettings then
		KkthnxUIDB.Settings[K.Realm][K.Name] = K.CopyTable(sourceSettings)
	end

	if sourceVariables then
		if not KkthnxUIDB.Variables[K.Realm] then
			KkthnxUIDB.Variables[K.Realm] = {}
		end
		KkthnxUIDB.Variables[K.Realm][K.Name] = K.CopyTable(sourceVariables)
		-- Ensure installer is marked complete after switching profiles
		KkthnxUIDB.Variables[K.Realm][K.Name].InstallComplete = true
	end

	-- Add switch metadata
	KkthnxUIDB.Settings[K.Realm][K.Name].LastSwitched = time()
	KkthnxUIDB.Settings[K.Realm][K.Name].SwitchedFrom = profileKey
	KkthnxUIDB.Settings[K.Realm][K.Name].LastModified = time()

	return true, "Profile switch initiated"
end

function ProfileGUI:ResetProfile(profileKey)
	local profile = profileKey and self:GetAllProfiles()[profileKey] or nil

	if not profile then
		-- Reset current profile to defaults
		if KkthnxUIDB.Settings[K.Realm] then
			KkthnxUIDB.Settings[K.Realm][K.Name] = K.CopyTable(K.Defaults or {})
		end
		if KkthnxUIDB.Variables[K.Realm] then
			KkthnxUIDB.Variables[K.Realm][K.Name] = {}
		end

		-- Add reset metadata
		KkthnxUIDB.Settings[K.Realm][K.Name].ResetAt = time()
		KkthnxUIDB.Settings[K.Realm][K.Name].ResetBy = K.Name
		KkthnxUIDB.Settings[K.Realm][K.Name].LastModified = time()
	else
		-- Reset specified profile to defaults
		if KkthnxUIDB.Settings[profile.realm] then
			KkthnxUIDB.Settings[profile.realm][profile.name] = K.CopyTable(K.Defaults or {})
		end
		if KkthnxUIDB.Variables[profile.realm] then
			KkthnxUIDB.Variables[profile.realm][profile.name] = {}
		end

		-- Add reset metadata
		KkthnxUIDB.Settings[profile.realm][profile.name].ResetAt = time()
		KkthnxUIDB.Settings[profile.realm][profile.name].ResetBy = K.Name
		KkthnxUIDB.Settings[profile.realm][profile.name].LastModified = time()
	end

	return true, "Profile reset successfully"
end

-- UI Creation

function ProfileGUI:CreateScrollFrame(parent, width, height)
	local scrollFrame = CreateFrame("ScrollFrame", nil, parent)
	scrollFrame:SetSize(width, height)

	-- Simple background
	CreateColoredBackground(scrollFrame, 0.08, 0.08, 0.08, 0.9)

	-- Scroll child
	local scrollChild = CreateFrame("Frame", nil, scrollFrame)
	scrollChild:SetWidth(width - 20)
	scrollChild:SetHeight(1)
	scrollFrame:SetScrollChild(scrollChild)

	-- Keep child width in sync with frame width for responsive layouts
	scrollFrame:SetScript("OnSizeChanged", function(self, w)
		if self.Child and w then
			self.Child:SetWidth(math.max(1, w - 20))
		end
	end)

	-- Enable mouse wheel scrolling
	scrollFrame:EnableMouseWheel(true)
	scrollFrame:SetScript("OnMouseWheel", function(self, delta)
		local current = self:GetVerticalScroll()
		local maxScroll = self:GetVerticalScrollRange()
		local step = 30

		if delta > 0 then
			self:SetVerticalScroll(math.max(0, current - step))
		else
			self:SetVerticalScroll(math.min(maxScroll, current + step))
		end
	end)

	scrollFrame.Child = scrollChild
	return scrollFrame
end

-- Profile List
function ProfileGUI:RefreshProfileList()
	local startMs
	if K.isDeveloper then
		startMs = debugprofilestop()
	end
	if not self.ProfileScrollFrame or not self.ProfileScrollFrame.Child then
		return
	end

	-- Refresh current character metadata to ensure it's up to date
	self:StoreCharacterMetadata(K.Name, K.Realm)

	-- Clear existing buttons
	for _, child in ipairs({ self.ProfileScrollFrame.Child:GetChildren() }) do
		child:Hide()
		child:SetParent(nil)
	end

	local profiles = self:GetAllProfiles()
	local sortedProfiles = {}

	-- Sort profiles by display name
	for _, profile in pairs(profiles) do
		tinsert(sortedProfiles, profile)
	end

	table.sort(sortedProfiles, function(a, b)
		-- Current profile should appear first
		if a.isCurrent ~= b.isCurrent then
			return a.isCurrent
		end
		return a.displayName < b.displayName
	end)

	local yOffset = -8
	local buttonHeight = 32

	for _, profile in ipairs(sortedProfiles) do
		local button = self:CreateProfileListButton(profile)
		button:SetParent(self.ProfileScrollFrame.Child)
		button:SetPoint("TOPLEFT", 8, yOffset)
		button:SetPoint("TOPRIGHT", -8, yOffset)
		button:SetHeight(buttonHeight)

		yOffset = yOffset - buttonHeight - 4
	end

	-- Update scroll frame content height
	local contentHeight = math.abs(yOffset) + 20
	local frameHeight = self.ProfileScrollFrame:GetHeight() or LIST_HEIGHT
	self.ProfileScrollFrame.Child:SetHeight(math.max(contentHeight, frameHeight))

	-- Auto-select current profile if no selection
	if not self.SelectedProfile and profiles then
		local currentKey = self:GetCurrentProfileKey()
		if profiles[currentKey] then
			self.SelectedProfile = currentKey
		end
		if K.isDeveloper and startMs then
			local elapsedMs = debugprofilestop() - startMs
			K.Print(string.format("[KKUI_DEV] RefreshProfileList %.3f ms", elapsedMs))
		end
	end
end

function ProfileGUI:CreateProfileListButton(profile)
	local button = CreateFrame("Button", nil, self.ProfileScrollFrame.Child)
	button:SetHeight(32)

	-- Simple button background
	local buttonBg = CreateColoredBackground(button, 0.08, 0.08, 0.08, 0.9)
	button.KKUI_Background = buttonBg

	-- Profile selection indicator
	local selected = button:CreateTexture(nil, "OVERLAY")
	selected:SetSize(3, 24)
	selected:SetPoint("LEFT", 2, 0)
	selected:SetTexture(C["Media"].Textures.White8x8Texture)
	selected:SetVertexColor(ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3], 1)
	selected:Hide()
	button.Selected = selected

	-- Portrait with simple styling
	local portraitFrame = CreateFrame("Frame", nil, button)
	portraitFrame:SetSize(24, 24)
	portraitFrame:SetPoint("LEFT", 12, 0)

	-- Portrait background
	local portraitBg = CreateColoredBackground(portraitFrame, 0.12, 0.12, 0.12, 1)

	-- Portrait border
	local portraitBorder = portraitFrame:CreateTexture(nil, "BORDER")
	portraitBorder:SetPoint("TOPLEFT", -1, 1)
	portraitBorder:SetPoint("BOTTOMRIGHT", 1, -1)
	portraitBorder:SetTexture(C["Media"].Textures.White8x8Texture)
	portraitBorder:SetVertexColor(0.3, 0.3, 0.3, 0.8)

	-- Portrait texture
	local portrait = portraitFrame:CreateTexture(nil, "ARTWORK")
	portrait:SetPoint("TOPLEFT", 2, -2)
	portrait:SetPoint("BOTTOMRIGHT", -2, 2)

	self:SetupPortrait(portrait, profile.name, profile.realm)

	button.Portrait = portrait
	button.PortraitFrame = portraitFrame
	button.PortraitBorder = portraitBorder

	-- Profile name text
	local nameText = button:CreateFontString(nil, "OVERLAY")
	nameText:SetFontObject(K.UIFont)
	nameText:SetPoint("LEFT", portraitFrame, "RIGHT", 8, 0)
	nameText:SetPoint("RIGHT", button, "RIGHT", -8, 0)
	nameText:SetJustifyH("LEFT")
	nameText:SetText(profile.name)
	nameText:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
	button.Text = nameText

	-- Simplified tooltip - only essential info
	button:SetScript("OnEnter", function(self)
		if not profile.isCurrent then
			buttonBg:SetVertexColor(BUTTON_HOVER[1], BUTTON_HOVER[2], BUTTON_HOVER[3], 0.6)
		end
		nameText:SetTextColor(1, 1, 1, 1)

		-- Clean, minimal tooltip
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(profile.displayName, 1, 1, 1, 1, true)

		if profile.isCurrent then
			GameTooltip:AddLine("Currently Active Profile", SUCCESS_COLOR[1], SUCCESS_COLOR[2], SUCCESS_COLOR[3])
		else
			GameTooltip:AddLine("Click to select this profile", 0.5, 0.8, 1)
		end

		GameTooltip:Show()
	end)

	button:SetScript("OnLeave", function(buttonSelf)
		local isSelected = (self.SelectedProfile == profile.key)
		local isCurrent = profile.isCurrent

		if isCurrent then
			buttonBg:SetVertexColor(ACCENT_COLOR[1] * 0.2, ACCENT_COLOR[2] * 0.2, ACCENT_COLOR[3] * 0.2, 0.9)
			nameText:SetTextColor(ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3], 1)
		elseif isSelected then
			buttonBg:SetVertexColor(SELECTED_BG[1], SELECTED_BG[2], SELECTED_BG[3], SELECTED_BG[4])
			nameText:SetTextColor(ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3], 1)
		else
			buttonBg:SetVertexColor(0.08, 0.08, 0.08, 0.9)
			nameText:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
		end

		GameTooltip:Hide()
	end)

	-- Click handler
	button:SetScript("OnClick", function(self, mouseButton)
		if mouseButton == "LeftButton" then
			ProfileGUI:SelectProfile(profile.key)
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
		end
	end)

	button:RegisterForClicks("LeftButtonUp")
	button.Profile = profile

	-- Set initial state
	self:UpdateProfileButtonState(button, profile)

	return button
end

function ProfileGUI:ShowRenameProfileDialog()
	if not self.SelectedProfile then
		self:ShowStatusMessage("No profile selected to rename", "error")
		return
	end

	local profiles = self:GetAllProfiles()
	local profile = profiles[self.SelectedProfile]

	if profile.isCurrent then
		self:ShowStatusMessage("Cannot rename the currently active profile", "error")
		return
	end

	local dialog = self:CreateInputDialog("Rename Profile", "Enter a new name for the profile '" .. profile.name .. "':", profile.name, function(newName)
		if not newName or newName == "" then
			self:ShowStatusMessage("Profile name cannot be empty", "error")
			return
		end

		if newName == profile.name then
			self:ShowStatusMessage("New name must be different from current name", "error")
			return
		end

		local success, error = self:RenameProfile(self.SelectedProfile, newName)
		if success then
			self:ShowStatusMessage("Profile renamed successfully", "success")
			self:RefreshProfileList()
			self:UpdateInfoPanel()
		else
			self:ShowStatusMessage(error, "error")
		end
	end)
end

-- Helper function to update profile button state
function ProfileGUI:UpdateProfileButtonState(button, profile)
	local isSelected = (self.SelectedProfile == profile.key)
	local isCurrent = profile.isCurrent

	-- Update background
	if isCurrent then
		button.KKUI_Background:SetVertexColor(ACCENT_COLOR[1] * 0.2, ACCENT_COLOR[2] * 0.2, ACCENT_COLOR[3] * 0.2, 0.9)
		button.Text:SetTextColor(ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3], 1)
	elseif isSelected then
		button.KKUI_Background:SetVertexColor(SELECTED_BG[1], SELECTED_BG[2], SELECTED_BG[3], SELECTED_BG[4])
		button.Text:SetTextColor(ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3], 1)
	else
		button.KKUI_Background:SetVertexColor(0.08, 0.08, 0.08, 0.9)
		button.Text:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
	end

	-- Update selection indicator
	if isSelected or isCurrent then
		button.Selected:Show()
		if isCurrent then
			button.Selected:SetSize(4, 24)
			button.Selected:SetVertexColor(ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3], 1)
		else
			button.Selected:SetSize(2, 24)
			button.Selected:SetVertexColor(ACCENT_COLOR[1] * 0.8, ACCENT_COLOR[2] * 0.8, ACCENT_COLOR[3] * 0.8, 0.8)
		end
	else
		button.Selected:Hide()
	end
end

function ProfileGUI:SelectProfile(profileKey)
	self.SelectedProfile = profileKey

	-- Refresh current character metadata when selecting profiles
	self:StoreCharacterMetadata(K.Name, K.Realm)

	-- Update visual feedback for all profile buttons
	if self.ProfileScrollFrame and self.ProfileScrollFrame.Child then
		for _, button in ipairs({ self.ProfileScrollFrame.Child:GetChildren() }) do
			if button.Profile then
				self:UpdateProfileButtonState(button, button.Profile)
			end
		end
	end

	-- Update info panel and button states
	self:UpdateInfoPanel()
	self:UpdateButtonStates()
end

function ProfileGUI:UpdateButtonStates()
	local hasSelection = (self.SelectedProfile ~= nil)
	local profiles = self:GetAllProfiles()
	local selectedProfile = hasSelection and profiles[self.SelectedProfile] or nil
	local isCurrentProfile = selectedProfile and selectedProfile.isCurrent or false

	-- Helper function to set button state
	local function SetButtonState(button, enabled)
		if button then
			button:SetAlpha(enabled and 1 or 0.4)
			button:EnableMouse(enabled)
		end
	end

	-- Switch To button - disabled if no selection or if selected profile is current
	SetButtonState(self.SwitchButton, hasSelection and not isCurrentProfile)

	-- Export button - enabled if has selection
	SetButtonState(self.ExportButton, hasSelection)

	-- Delete button - disabled if no selection or if selected profile is current
	SetButtonState(self.DeleteButton, hasSelection and not isCurrentProfile)

	-- Copy button - enabled if has selection
	SetButtonState(self.CopyButton, hasSelection)

	-- Rename button - disabled if no selection or if selected profile is current
	SetButtonState(self.RenameButton, hasSelection and not isCurrentProfile)

	-- Reset button - enabled if has selection
	SetButtonState(self.ResetButton, hasSelection)
end

-- Enhanced info panel with comprehensive profile details
function ProfileGUI:UpdateInfoPanel()
	if not self.InfoPanel then
		return
	end

	-- Store references to existing UI elements to avoid recreating them
	if not self.InfoElements then
		self.InfoElements = {}
	end

	-- Hide all existing elements first
	for _, element in pairs(self.InfoElements) do
		if element and element.Hide then
			element:Hide()
		end
	end

	if not self.SelectedProfile then
		-- Show "Select a profile" message
		if not self.InfoElements.NoSelectionText then
			self.InfoElements.NoSelectionText = self.InfoPanel:CreateFontString(nil, "OVERLAY")
			self.InfoElements.NoSelectionText:SetFontObject(K.UIFont)
			self.InfoElements.NoSelectionText:SetTextColor(0.6, 0.6, 0.6, 1)
			self.InfoElements.NoSelectionText:SetPoint("CENTER", 0, 0)
		end

		self.InfoElements.NoSelectionText:SetText("Select a profile to view details")
		self.InfoElements.NoSelectionText:Show()
		return
	end

	-- Hide the "no selection" text
	if self.InfoElements.NoSelectionText then
		self.InfoElements.NoSelectionText:Hide()
	end

	local profiles = self:GetAllProfiles()
	local profile = profiles[self.SelectedProfile]

	if not profile then
		return
	end

	local yOffset = -12
	local maxWidth = 290 -- Prevent text overflow

	-- Profile name header
	if not self.InfoElements.NameLabel then
		self.InfoElements.NameLabel = self.InfoPanel:CreateFontString(nil, "OVERLAY")
		self.InfoElements.NameLabel:SetFontObject(K.UIFont)
		self.InfoElements.NameLabel:SetPoint("TOPLEFT", 15, 0)
		self.InfoElements.NameLabel:SetWidth(maxWidth)
		self.InfoElements.NameLabel:SetJustifyH("LEFT")
	end
	self.InfoElements.NameLabel:SetTextColor(ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3], 1)
	self.InfoElements.NameLabel:SetText("Profile: " .. profile.name)
	self.InfoElements.NameLabel:SetPoint("TOPLEFT", 15, yOffset)
	self.InfoElements.NameLabel:Show()
	yOffset = yOffset - 20

	-- Status with visual indicator
	if not self.InfoElements.StatusLabel then
		self.InfoElements.StatusLabel = self.InfoPanel:CreateFontString(nil, "OVERLAY")
		self.InfoElements.StatusLabel:SetFontObject(K.UIFont)
		self.InfoElements.StatusLabel:SetPoint("TOPLEFT", 15, 0)
		self.InfoElements.StatusLabel:SetWidth(maxWidth)
		self.InfoElements.StatusLabel:SetJustifyH("LEFT")
	end
	if profile.isCurrent then
		self.InfoElements.StatusLabel:SetTextColor(SUCCESS_COLOR[1], SUCCESS_COLOR[2], SUCCESS_COLOR[3], 1)
		self.InfoElements.StatusLabel:SetText("Currently Active")
	else
		self.InfoElements.StatusLabel:SetTextColor(0.7, 0.7, 0.7, 1)
		self.InfoElements.StatusLabel:SetText("Available")
	end
	self.InfoElements.StatusLabel:SetPoint("TOPLEFT", 15, yOffset)
	self.InfoElements.StatusLabel:Show()
	yOffset = yOffset - 22

	-- Character info section
	if not self.InfoElements.CharacterHeader then
		self.InfoElements.CharacterHeader = self.InfoPanel:CreateFontString(nil, "OVERLAY")
		self.InfoElements.CharacterHeader:SetFontObject(K.UIFont)
		self.InfoElements.CharacterHeader:SetPoint("TOPLEFT", 15, 0)
		self.InfoElements.CharacterHeader:SetWidth(maxWidth)
		self.InfoElements.CharacterHeader:SetJustifyH("LEFT")
	end
	self.InfoElements.CharacterHeader:SetTextColor(0.8, 0.8, 0.8, 1)
	self.InfoElements.CharacterHeader:SetText("Character Information:")
	self.InfoElements.CharacterHeader:SetPoint("TOPLEFT", 15, yOffset)
	self.InfoElements.CharacterHeader:Show()
	yOffset = yOffset - 16

	-- Character name and realm
	if not self.InfoElements.CharacterLabel then
		self.InfoElements.CharacterLabel = self.InfoPanel:CreateFontString(nil, "OVERLAY")
		self.InfoElements.CharacterLabel:SetFontObject(K.UIFont)
		self.InfoElements.CharacterLabel:SetPoint("TOPLEFT", 15, 0)
		self.InfoElements.CharacterLabel:SetWidth(maxWidth)
		self.InfoElements.CharacterLabel:SetJustifyH("LEFT")
	end
	self.InfoElements.CharacterLabel:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
	self.InfoElements.CharacterLabel:SetText("  Name: " .. profile.name .. " @ " .. profile.realm)
	self.InfoElements.CharacterLabel:SetPoint("TOPLEFT", 15, yOffset)
	self.InfoElements.CharacterLabel:Show()
	yOffset = yOffset - 14

	-- Character class with color
	local characterClass = self:GetClassFromGoldInfo(profile.name, profile.realm)
	if characterClass and characterClass ~= "NONE" then
		-- Class label (normal color)
		if not self.InfoElements.ClassLabel then
			self.InfoElements.ClassLabel = self.InfoPanel:CreateFontString(nil, "OVERLAY")
			self.InfoElements.ClassLabel:SetFontObject(K.UIFont)
			self.InfoElements.ClassLabel:SetPoint("TOPLEFT", 15, 0)
			self.InfoElements.ClassLabel:SetJustifyH("LEFT")
		end
		self.InfoElements.ClassLabel:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
		self.InfoElements.ClassLabel:SetText("  Class: ")
		self.InfoElements.ClassLabel:SetPoint("TOPLEFT", 15, yOffset)
		self.InfoElements.ClassLabel:Show()

		-- Class value (class color)
		if not self.InfoElements.ClassValue then
			self.InfoElements.ClassValue = self.InfoPanel:CreateFontString(nil, "OVERLAY")
			self.InfoElements.ClassValue:SetFontObject(K.UIFont)
			self.InfoElements.ClassValue:SetJustifyH("LEFT")
		end
		local classColor = K.ClassColors and K.ClassColors[characterClass]
		if classColor then
			self.InfoElements.ClassValue:SetTextColor(classColor.r, classColor.g, classColor.b, 1)
		else
			self.InfoElements.ClassValue:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
		end
		self.InfoElements.ClassValue:SetText(characterClass)
		self.InfoElements.ClassValue:SetPoint("LEFT", self.InfoElements.ClassLabel, "RIGHT", 0, 0)
		self.InfoElements.ClassValue:Show()

		yOffset = yOffset - 14
	elseif self.InfoElements.ClassLabel then
		self.InfoElements.ClassLabel:Hide()
		if self.InfoElements.ClassValue then
			self.InfoElements.ClassValue:Hide()
		end
	end

	-- Character race
	local race = self:GetRaceFromPortraitData(profile.name, profile.realm)
	if race then
		if not self.InfoElements.RaceLabel then
			self.InfoElements.RaceLabel = self.InfoPanel:CreateFontString(nil, "OVERLAY")
			self.InfoElements.RaceLabel:SetFontObject(K.UIFont)
			self.InfoElements.RaceLabel:SetPoint("TOPLEFT", 15, 0)
			self.InfoElements.RaceLabel:SetWidth(maxWidth)
			self.InfoElements.RaceLabel:SetJustifyH("LEFT")
		end
		self.InfoElements.RaceLabel:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
		self.InfoElements.RaceLabel:SetText("  Race: " .. race)
		self.InfoElements.RaceLabel:SetPoint("TOPLEFT", 15, yOffset)
		self.InfoElements.RaceLabel:Show()
		yOffset = yOffset - 14
	elseif self.InfoElements.RaceLabel then
		self.InfoElements.RaceLabel:Hide()
	end

	-- Character faction
	local faction = self:GetFactionFromGoldInfo(profile.name, profile.realm)
	if faction and faction ~= "Unknown" then
		-- Faction label (normal color)
		if not self.InfoElements.FactionLabel then
			self.InfoElements.FactionLabel = self.InfoPanel:CreateFontString(nil, "OVERLAY")
			self.InfoElements.FactionLabel:SetFontObject(K.UIFont)
			self.InfoElements.FactionLabel:SetPoint("TOPLEFT", 15, 0)
			self.InfoElements.FactionLabel:SetJustifyH("LEFT")
		end
		self.InfoElements.FactionLabel:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
		self.InfoElements.FactionLabel:SetText("  Faction: ")
		self.InfoElements.FactionLabel:SetPoint("TOPLEFT", 15, yOffset)
		self.InfoElements.FactionLabel:Show()

		-- Faction value (faction color)
		if not self.InfoElements.FactionValue then
			self.InfoElements.FactionValue = self.InfoPanel:CreateFontString(nil, "OVERLAY")
			self.InfoElements.FactionValue:SetFontObject(K.UIFont)
			self.InfoElements.FactionValue:SetJustifyH("LEFT")
		end
		-- Color faction appropriately
		if faction == "Alliance" then
			self.InfoElements.FactionValue:SetTextColor(0.2, 0.5, 1, 1)
		elseif faction == "Horde" then
			self.InfoElements.FactionValue:SetTextColor(1, 0.2, 0.2, 1)
		else
			self.InfoElements.FactionValue:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
		end
		self.InfoElements.FactionValue:SetText(faction)
		self.InfoElements.FactionValue:SetPoint("LEFT", self.InfoElements.FactionLabel, "RIGHT", 0, 0)
		self.InfoElements.FactionValue:Show()

		yOffset = yOffset - 14
	elseif self.InfoElements.FactionLabel then
		self.InfoElements.FactionLabel:Hide()
		if self.InfoElements.FactionValue then
			self.InfoElements.FactionValue:Hide()
		end
	end

	-- Profile metadata section
	if not self.InfoElements.MetadataHeader then
		self.InfoElements.MetadataHeader = self.InfoPanel:CreateFontString(nil, "OVERLAY")
		self.InfoElements.MetadataHeader:SetFontObject(K.UIFont)
		self.InfoElements.MetadataHeader:SetPoint("TOPLEFT", 15, 0)
		self.InfoElements.MetadataHeader:SetWidth(maxWidth)
		self.InfoElements.MetadataHeader:SetJustifyH("LEFT")
	end
	self.InfoElements.MetadataHeader:SetTextColor(0.8, 0.8, 0.8, 1)
	self.InfoElements.MetadataHeader:SetText("Profile Details:")
	self.InfoElements.MetadataHeader:SetPoint("TOPLEFT", 15, yOffset - 4)
	self.InfoElements.MetadataHeader:Show()
	yOffset = yOffset - 20

	-- Last modified date
	if profile.lastModified and profile.lastModified > 946684800 then
		if not self.InfoElements.ModifiedLabel then
			self.InfoElements.ModifiedLabel = self.InfoPanel:CreateFontString(nil, "OVERLAY")
			self.InfoElements.ModifiedLabel:SetFontObject(K.UIFont)
			self.InfoElements.ModifiedLabel:SetPoint("TOPLEFT", 15, 0)
			self.InfoElements.ModifiedLabel:SetWidth(maxWidth)
			self.InfoElements.ModifiedLabel:SetJustifyH("LEFT")
		end
		self.InfoElements.ModifiedLabel:SetTextColor(0.7, 0.7, 0.7, 1)
		self.InfoElements.ModifiedLabel:SetText("  Modified: " .. date("%Y-%m-%d %H:%M", profile.lastModified))
		self.InfoElements.ModifiedLabel:SetPoint("TOPLEFT", 15, yOffset)
		self.InfoElements.ModifiedLabel:Show()
		yOffset = yOffset - 14
	end

	-- Action hint
	if not self.InfoElements.HintLabel then
		self.InfoElements.HintLabel = self.InfoPanel:CreateFontString(nil, "OVERLAY")
		self.InfoElements.HintLabel:SetFontObject(K.UIFont)
		self.InfoElements.HintLabel:SetPoint("TOPLEFT", 15, 0)
		self.InfoElements.HintLabel:SetWidth(maxWidth)
		self.InfoElements.HintLabel:SetJustifyH("LEFT")
	end
	self.InfoElements.HintLabel:SetTextColor(0.5, 0.5, 0.5, 1)
	if profile.isCurrent then
		self.InfoElements.HintLabel:SetText("This profile is currently active")
	else
		self.InfoElements.HintLabel:SetText("Use 'Switch To' to activate this profile")
	end
	self.InfoElements.HintLabel:SetPoint("TOPLEFT", 15, yOffset - 4)
	self.InfoElements.HintLabel:Show()
end

-- Main UI Creation with Simplified Design
function ProfileGUI:CreateMainFrame()
	if self.Frame then
		return self.Frame
	end

	-- Main frame (matching main GUI exactly)
	local frame = CreateFrame("Frame", "KkthnxUI_ProfileGUI", UIParent)
	frame:SetSize(PANEL_WIDTH, PANEL_HEIGHT)
	frame:SetPoint("CENTER")
	frame:EnableMouse(true)
	frame:SetMovable(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnDragStart", frame.StartMoving)
	frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
	frame:SetFrameStrata("HIGH")
	frame:SetFrameLevel(100)
	frame:Hide()

	-- Modern background with subtle shadow effect
	local mainBg = frame:CreateTexture(nil, "BACKGROUND")
	mainBg:SetAllPoints()
	mainBg:SetTexture(C["Media"].Textures.White8x8Texture)
	mainBg:SetVertexColor(0.08, 0.08, 0.08, 0.95)

	-- Subtle shadow effect
	local shadow = CreateFrame("Frame", nil, frame)
	shadow:SetPoint("TOPLEFT", -8, 8)
	shadow:SetPoint("BOTTOMRIGHT", 8, -8)
	shadow:SetFrameLevel(frame:GetFrameLevel() - 1)
	local shadowTexture = shadow:CreateTexture(nil, "BACKGROUND")
	shadowTexture:SetAllPoints()
	shadowTexture:SetTexture(C["Media"].Textures.White8x8Texture)
	shadowTexture:SetVertexColor(0, 0, 0, 0.4)

	-- Title Bar
	local titleBar = CreateFrame("Frame", nil, frame)
	titleBar:SetPoint("TOPLEFT", 0, 0)
	titleBar:SetPoint("TOPRIGHT", 0, 0)
	titleBar:SetHeight(HEADER_HEIGHT)
	titleBar:EnableMouse(true)
	titleBar:RegisterForDrag("LeftButton")
	titleBar:SetScript("OnDragStart", function()
		frame:StartMoving()
	end)
	titleBar:SetScript("OnDragStop", function()
		frame:StopMovingOrSizing()
	end)

	CreateColoredBackground(titleBar, ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3])

	-- Title text
	local title = titleBar:CreateFontString(nil, "OVERLAY")
	title:SetFontObject(K.UIFont)
	title:SetTextColor(1, 1, 1, 1)
	title:SetText("Profile Manager")
	title:SetPoint("LEFT", 15, 0)

	-- Close Button
	local closeButton = CreateFrame("Button", nil, titleBar)
	closeButton:SetSize(32, 32)
	closeButton:SetPoint("RIGHT", -4, 0)

	local closeBg = closeButton:CreateTexture(nil, "BACKGROUND")
	closeBg:SetAllPoints()
	closeBg:SetTexture(C["Media"].Textures.White8x8Texture)
	closeBg:SetVertexColor(0, 0, 0, 0)

	closeButton.Icon = closeButton:CreateTexture(nil, "ARTWORK")
	closeButton.Icon:SetSize(16, 16)
	closeButton.Icon:SetPoint("CENTER")
	closeButton.Icon:SetAtlas("uitools-icon-close")
	closeButton.Icon:SetVertexColor(1, 1, 1, 0.8)

	closeButton:SetScript("OnClick", function()
		self:Hide()
	end)

	closeButton:SetScript("OnEnter", function(self)
		self.Icon:SetVertexColor(1, 1, 1, 1)
		closeBg:SetVertexColor(1, 0.2, 0.2, 0.3)
	end)

	closeButton:SetScript("OnLeave", function(self)
		self.Icon:SetVertexColor(1, 1, 1, 0.8)
		closeBg:SetVertexColor(0, 0, 0, 0)
	end)

	-- Content area
	local content = CreateFrame("Frame", nil, frame)
	content:SetPoint("TOPLEFT", 0, -HEADER_HEIGHT)
	content:SetPoint("BOTTOMRIGHT", 0, 0)

	CreateColoredBackground(content, BG_COLOR[1], BG_COLOR[2], BG_COLOR[3], BG_COLOR[4])

	-- Left panel (Profile List)
	local leftPanel = CreateFrame("Frame", nil, content)
	leftPanel:SetPoint("TOPLEFT", SPACING, -SPACING)
	leftPanel:SetPoint("BOTTOMLEFT", SPACING, SPACING)
	leftPanel:SetWidth(LIST_WIDTH)

	CreateColoredBackground(leftPanel, SIDEBAR_COLOR[1], SIDEBAR_COLOR[2], SIDEBAR_COLOR[3], SIDEBAR_COLOR[4])

	-- Profile list title
	local listTitle = leftPanel:CreateFontString(nil, "OVERLAY")
	listTitle:SetFontObject(K.UIFont)
	listTitle:SetTextColor(ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3], 1)
	listTitle:SetText("Available Profiles")
	listTitle:SetPoint("TOPLEFT", 12, -12)

	-- Profile scroll frame
	local profileScrollFrame = self:CreateScrollFrame(leftPanel, LIST_WIDTH - 20, LIST_HEIGHT - 46)
	profileScrollFrame:ClearAllPoints()
	profileScrollFrame:SetPoint("TOPLEFT", 10, -35)
	profileScrollFrame:SetPoint("BOTTOMRIGHT", -10, 10)
	self.ProfileScrollFrame = profileScrollFrame

	-- Right panel (Info and Controls)
	local rightPanel = CreateFrame("Frame", nil, content)
	rightPanel:SetPoint("TOPLEFT", leftPanel, "TOPRIGHT", SPACING, 0)
	rightPanel:SetPoint("BOTTOMRIGHT", -SPACING, SPACING)

	CreateColoredBackground(rightPanel, SIDEBAR_COLOR[1], SIDEBAR_COLOR[2], SIDEBAR_COLOR[3], SIDEBAR_COLOR[4])

	-- Info panel
	local infoPanel = CreateFrame("Frame", nil, rightPanel)
	infoPanel:SetPoint("TOPLEFT", 15, -15)
	infoPanel:SetPoint("TOPRIGHT", -15, -15)
	infoPanel:SetHeight(178) -- Fixed height for info panel

	CreateColoredBackground(infoPanel, WIDGET_BG[1], WIDGET_BG[2], WIDGET_BG[3], WIDGET_BG[4])
	self.InfoPanel = infoPanel

	-- Control panel
	local controlPanel = CreateFrame("Frame", nil, rightPanel)
	controlPanel:SetPoint("TOPLEFT", infoPanel, "BOTTOMLEFT", 0, -SPACING - 10)
	controlPanel:SetPoint("BOTTOMRIGHT", -15, 15)

	CreateColoredBackground(controlPanel, WIDGET_BG[1], WIDGET_BG[2], WIDGET_BG[3], WIDGET_BG[4])

	-- Create control buttons
	self:CreateControlButtons(controlPanel)

	-- Status text
	local statusText = controlPanel:CreateFontString(nil, "OVERLAY")
	statusText:SetFontObject(K.UIFont)
	statusText:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
	statusText:SetText("")
	statusText:SetPoint("BOTTOMLEFT", controlPanel, "BOTTOMLEFT", 15, 15)
	statusText:SetPoint("BOTTOMRIGHT", controlPanel, "BOTTOMRIGHT", -15, 15)
	statusText:SetJustifyH("LEFT")
	self.StatusText = statusText

	self.Frame = frame
	return frame
end

function ProfileGUI:CreateControlButtons(parent)
	local buttonWidth = 100
	local yOffset = -15

	-- Section header
	local operationsTitle = parent:CreateFontString(nil, "OVERLAY")
	operationsTitle:SetFontObject(K.UIFont)
	operationsTitle:SetTextColor(ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3], 1)
	operationsTitle:SetText("Profile Operations")
	operationsTitle:SetPoint("TOPLEFT", 15, yOffset)
	yOffset = yOffset - 30

	-- Switch profile button
	local switchButton = CreateButton(parent, "Switch To", buttonWidth, BUTTON_HEIGHT, function()
		self:SwitchToSelectedProfile()
	end)
	switchButton:SetPoint("TOPLEFT", 15, yOffset)
	self.SwitchButton = switchButton

	-- Reset profile button
	local resetButton = CreateButton(parent, "Reset", buttonWidth, BUTTON_HEIGHT, function()
		self:ShowResetConfirmation()
	end)
	resetButton:SetPoint("TOPLEFT", switchButton, "TOPRIGHT", SPACING, 0)
	self.ResetButton = resetButton

	yOffset = yOffset - (BUTTON_HEIGHT + SPACING)

	-- Create new profile button
	local createButton = CreateButton(parent, "Create New", buttonWidth, BUTTON_HEIGHT, function()
		self:ShowCreateProfileDialog()
	end)
	createButton:SetPoint("TOPLEFT", 15, yOffset)
	self.CreateProfileButton = createButton

	-- Copy profile button
	local copyButton = CreateButton(parent, "Copy", buttonWidth, BUTTON_HEIGHT, function()
		self:ShowCopyProfileDialog()
	end)
	copyButton:SetPoint("TOPLEFT", createButton, "TOPRIGHT", SPACING, 0)
	self.CopyButton = copyButton

	yOffset = yOffset - (BUTTON_HEIGHT + SPACING)

	-- Rename profile button
	local renameButton = CreateButton(parent, "Rename", buttonWidth, BUTTON_HEIGHT, function()
		self:ShowRenameProfileDialog()
	end)
	renameButton:SetPoint("TOPLEFT", 15, yOffset)
	self.RenameButton = renameButton

	-- Delete profile button
	local deleteButton = CreateButton(parent, "Delete", buttonWidth, BUTTON_HEIGHT, function()
		self:ShowDeleteConfirmation()
	end)
	deleteButton:SetPoint("TOPLEFT", renameButton, "TOPRIGHT", SPACING, 0)
	self.DeleteButton = deleteButton

	yOffset = yOffset - (BUTTON_HEIGHT + SPACING * 2)

	-- Import section header
	local importTitle = parent:CreateFontString(nil, "OVERLAY")
	importTitle:SetFontObject(K.UIFont)
	importTitle:SetTextColor(ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3], 1)
	importTitle:SetText("Import or Export Profile")
	importTitle:SetPoint("TOPLEFT", 15, yOffset)
	yOffset = yOffset - 25

	-- Import button
	local importButton = CreateButton(parent, "Import", buttonWidth, BUTTON_HEIGHT, function()
		self:ShowImportDialog()
	end)
	importButton:SetPoint("TOPLEFT", 15, yOffset)
	self.ImportButton = importButton

	-- Export profile button
	local exportButton = CreateButton(parent, "Export", buttonWidth, BUTTON_HEIGHT, function()
		self:ShowExportDialog()
	end)
	exportButton:SetPoint("TOPLEFT", importButton, "TOPRIGHT", SPACING, 0)
	self.ExportButton = exportButton
end

-- Status Message Functions
function ProfileGUI:ShowStatusMessage(message, messageType)
	if not self.StatusText then
		return
	end

	local color = TEXT_COLOR
	if messageType == "success" then
		color = SUCCESS_COLOR
	elseif messageType == "error" then
		color = ERROR_COLOR
	elseif messageType == "warning" then
		color = WARNING_COLOR
	end

	self.StatusText:SetTextColor(color[1], color[2], color[3], 1)
	self.StatusText:SetText(message)

	-- Auto-clear message after 5 seconds
	C_Timer.After(5, function()
		if self.StatusText then
			self.StatusText:SetText("")
		end
	end)
end

-- Main control functions
function ProfileGUI:SwitchToSelectedProfile()
	if not self.SelectedProfile then
		self:ShowStatusMessage("No profile selected", "error")
		return
	end

	self:SwitchToProfile(self.SelectedProfile)
end

-- Export Dialog - Enhanced with better styling
function ProfileGUI:ShowExportDialog()
	if not self.SelectedProfile then
		self:ShowStatusMessage("No profile selected", "error")
		return
	end

	local exportString, error = self:ExportProfile(self.SelectedProfile)
	if not exportString then
		self:ShowStatusMessage(error, "error")
		return
	end

	-- Create dialog with main GUI styling
	local dialog = CreateFrame("Frame", nil, UIParent)
	dialog.__KKUI_ProfileGUI = true
	dialog:SetSize(500, 400)
	dialog:SetPoint("CENTER")
	dialog:SetFrameStrata("TOOLTIP")
	dialog:SetFrameLevel(120)
	dialog:EnableMouse(true)
	dialog:SetMovable(true)
	dialog:RegisterForDrag("LeftButton")
	dialog:SetScript("OnDragStart", dialog.StartMoving)
	dialog:SetScript("OnDragStop", dialog.StopMovingOrSizing)

	-- Background and shadow
	local mainBg = dialog:CreateTexture(nil, "BACKGROUND")
	mainBg:SetAllPoints()
	mainBg:SetTexture(C["Media"].Textures.White8x8Texture)
	mainBg:SetVertexColor(0.08, 0.08, 0.08, 0.95)

	local shadow = CreateFrame("Frame", nil, dialog)
	shadow:SetPoint("TOPLEFT", -8, 8)
	shadow:SetPoint("BOTTOMRIGHT", 8, -8)
	shadow:SetFrameLevel(dialog:GetFrameLevel() - 1)
	local shadowTexture = shadow:CreateTexture(nil, "BACKGROUND")
	shadowTexture:SetAllPoints()
	shadowTexture:SetTexture(C["Media"].Textures.White8x8Texture)
	shadowTexture:SetVertexColor(0, 0, 0, 0.4)

	-- Title Bar
	local titleBar = CreateFrame("Frame", nil, dialog)
	titleBar:SetPoint("TOPLEFT", 0, 0)
	titleBar:SetPoint("TOPRIGHT", 0, 0)
	titleBar:SetHeight(HEADER_HEIGHT)
	titleBar:EnableMouse(true)
	titleBar:RegisterForDrag("LeftButton")
	titleBar:SetScript("OnDragStart", function()
		dialog:StartMoving()
	end)
	titleBar:SetScript("OnDragStop", function()
		dialog:StopMovingOrSizing()
	end)

	CreateColoredBackground(titleBar, ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3])

	-- Title text
	local titleText = titleBar:CreateFontString(nil, "OVERLAY")
	titleText:SetFontObject(K.UIFont)
	titleText:SetTextColor(1, 1, 1, 1)
	titleText:SetText("Export Profile")
	titleText:SetPoint("LEFT", 15, 0)

	-- Close Button
	local closeButton = CreateFrame("Button", nil, titleBar)
	closeButton:SetSize(32, 32)
	closeButton:SetPoint("RIGHT", -4, 0)

	local closeBg = closeButton:CreateTexture(nil, "BACKGROUND")
	closeBg:SetAllPoints()
	closeBg:SetTexture(C["Media"].Textures.White8x8Texture)
	closeBg:SetVertexColor(0, 0, 0, 0)

	closeButton.Icon = closeButton:CreateTexture(nil, "ARTWORK")
	closeButton.Icon:SetSize(16, 16)
	closeButton.Icon:SetPoint("CENTER")
	closeButton.Icon:SetAtlas("uitools-icon-close")
	closeButton.Icon:SetVertexColor(1, 1, 1, 0.8)

	closeButton:SetScript("OnClick", function()
		dialog:Hide()
		dialog:SetParent(nil)
	end)
	dialog:EnableKeyboard(true)
	if dialog.SetPropagateKeyboardInput then
		dialog:SetPropagateKeyboardInput(false)
	end
	dialog:SetScript("OnKeyDown", function(self, key)
		if key == "ESCAPE" then
			self:Hide()
		end
	end)

	closeButton:SetScript("OnEnter", function(self)
		self.Icon:SetVertexColor(1, 1, 1, 1)
		closeBg:SetVertexColor(1, 0.2, 0.2, 0.3)
	end)

	closeButton:SetScript("OnLeave", function(self)
		self.Icon:SetVertexColor(1, 1, 1, 0.8)
		closeBg:SetVertexColor(0, 0, 0, 0)
	end)

	-- Content area
	local content = CreateFrame("Frame", nil, dialog)
	content:SetPoint("TOPLEFT", 0, -HEADER_HEIGHT)
	content:SetPoint("BOTTOMRIGHT", 0, 0)

	CreateColoredBackground(content, BG_COLOR[1], BG_COLOR[2], BG_COLOR[3], BG_COLOR[4])

	-- Profile info
	local profiles = self:GetAllProfiles()
	local profile = profiles[self.SelectedProfile]
	local infoText = "Profile: " .. profile.name .. " (" .. profile.realm .. ")"

	local profileInfo = content:CreateFontString(nil, "OVERLAY")
	profileInfo:SetFontObject(K.UIFont)
	profileInfo:SetTextColor(ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3], 1)
	profileInfo:SetText(infoText)
	profileInfo:SetPoint("TOP", content, "TOP", 0, -15)

	-- Instructions
	local instructText = content:CreateFontString(nil, "OVERLAY")
	instructText:SetFontObject(K.UIFont)
	instructText:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
	instructText:SetText("Copy the code below to share your profile:")
	instructText:SetPoint("TOP", profileInfo, "BOTTOM", 0, -10)

	-- Scrollable text area
	local scrollFrame = CreateFrame("ScrollFrame", nil, content)
	scrollFrame:SetSize(460, 220)
	scrollFrame:SetPoint("TOP", instructText, "BOTTOM", 0, -15)

	CreateColoredBackground(scrollFrame, WIDGET_BG[1], WIDGET_BG[2], WIDGET_BG[3], WIDGET_BG[4])

	-- Simple border
	local scrollBorder = CreateFrame("Frame", nil, scrollFrame)
	scrollBorder:SetPoint("TOPLEFT", -1, 1)
	scrollBorder:SetPoint("BOTTOMRIGHT", 1, -1)
	scrollBorder:SetFrameLevel(scrollFrame:GetFrameLevel() - 1)
	local borderTexture = scrollBorder:CreateTexture(nil, "BACKGROUND")
	borderTexture:SetAllPoints()
	borderTexture:SetTexture(C["Media"].Textures.White8x8Texture)
	borderTexture:SetVertexColor(0.3, 0.3, 0.3, 0.8)

	local scrollChild = CreateFrame("Frame", nil, scrollFrame)
	scrollChild:SetSize(440, 220)
	scrollFrame:SetScrollChild(scrollChild)

	-- Export code editbox
	local exportBox = CreateFrame("EditBox", nil, scrollChild)
	exportBox:SetSize(440, 220)
	exportBox:SetPoint("TOPLEFT", 10, -10)
	exportBox:SetFontObject(K.UIFont)
	exportBox:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
	exportBox:SetAutoFocus(false)
	exportBox:SetMultiLine(true)
	exportBox:SetMaxLetters(0)
	exportBox:SetTextInsets(10, 10, 10, 10)
	exportBox:EnableMouse(true)
	exportBox:SetText(exportString)
	exportBox:SetCursorPosition(0)

	-- Auto-select on focus
	exportBox:SetScript("OnEditFocusGained", function(self)
		self:HighlightText()
	end)

	-- Status message
	local statusText = content:CreateFontString(nil, "OVERLAY")
	statusText:SetFontObject(K.UIFont)
	statusText:SetTextColor(SUCCESS_COLOR[1], SUCCESS_COLOR[2], SUCCESS_COLOR[3], 1)
	statusText:SetText("Profile exported successfully - click in the text area to select all")
	statusText:SetPoint("TOP", scrollFrame, "BOTTOM", 0, -10)
	statusText:SetWidth(460)
	statusText:SetJustifyH("CENTER")

	-- Buttons
	local selectAllButton = CreateButton(content, "Select All", 100, BUTTON_HEIGHT, function()
		exportBox:SetFocus()
		exportBox:HighlightText()
	end)
	selectAllButton:SetPoint("BOTTOMLEFT", content, "BOTTOMLEFT", 20, 15)

	local cancelButton = CreateButton(content, "Close", 100, BUTTON_HEIGHT, function()
		dialog:Hide()
		dialog:SetParent(nil)
	end)
	cancelButton:SetPoint("BOTTOMRIGHT", content, "BOTTOMRIGHT", -20, 15)

	-- Auto-focus the export box
	C_Timer.After(0.1, function()
		exportBox:SetFocus()
		exportBox:HighlightText()
	end)

	return dialog
end

-- Import Dialog - Enhanced with better styling
function ProfileGUI:ShowImportDialog()
	-- Create dialog with main GUI styling
	local dialog = CreateFrame("Frame", nil, UIParent)
	dialog.__KKUI_ProfileGUI = true
	dialog:SetSize(500, 400)
	dialog:SetPoint("CENTER")
	dialog:SetFrameStrata("TOOLTIP")
	dialog:SetFrameLevel(120)
	dialog:EnableMouse(true)
	dialog:SetMovable(true)
	dialog:RegisterForDrag("LeftButton")
	dialog:SetScript("OnDragStart", dialog.StartMoving)
	dialog:SetScript("OnDragStop", dialog.StopMovingOrSizing)

	-- Background and shadow
	local mainBg = dialog:CreateTexture(nil, "BACKGROUND")
	mainBg:SetAllPoints()
	mainBg:SetTexture(C["Media"].Textures.White8x8Texture)
	mainBg:SetVertexColor(0.08, 0.08, 0.08, 0.95)

	local shadow = CreateFrame("Frame", nil, dialog)
	shadow:SetPoint("TOPLEFT", -8, 8)
	shadow:SetPoint("BOTTOMRIGHT", 8, -8)
	shadow:SetFrameLevel(dialog:GetFrameLevel() - 1)
	local shadowTexture = shadow:CreateTexture(nil, "BACKGROUND")
	shadowTexture:SetAllPoints()
	shadowTexture:SetTexture(C["Media"].Textures.White8x8Texture)
	shadowTexture:SetVertexColor(0, 0, 0, 0.4)

	-- Title Bar
	local titleBar = CreateFrame("Frame", nil, dialog)
	titleBar:SetPoint("TOPLEFT", 0, 0)
	titleBar:SetPoint("TOPRIGHT", 0, 0)
	titleBar:SetHeight(HEADER_HEIGHT)
	titleBar:EnableMouse(true)
	titleBar:RegisterForDrag("LeftButton")
	titleBar:SetScript("OnDragStart", function()
		dialog:StartMoving()
	end)
	titleBar:SetScript("OnDragStop", function()
		dialog:StopMovingOrSizing()
	end)

	CreateColoredBackground(titleBar, ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3])

	-- Title text
	local titleText = titleBar:CreateFontString(nil, "OVERLAY")
	titleText:SetFontObject(K.UIFont)
	titleText:SetTextColor(1, 1, 1, 1)
	titleText:SetText("Import Profile")
	titleText:SetPoint("LEFT", 15, 0)

	-- Close Button
	local closeButton = CreateFrame("Button", nil, titleBar)
	closeButton:SetSize(32, 32)
	closeButton:SetPoint("RIGHT", -4, 0)

	local closeBg = closeButton:CreateTexture(nil, "BACKGROUND")
	closeBg:SetAllPoints()
	closeBg:SetTexture(C["Media"].Textures.White8x8Texture)
	closeBg:SetVertexColor(0, 0, 0, 0)

	closeButton.Icon = closeButton:CreateTexture(nil, "ARTWORK")
	closeButton.Icon:SetSize(16, 16)
	closeButton.Icon:SetPoint("CENTER")
	closeButton.Icon:SetAtlas("uitools-icon-close")
	closeButton.Icon:SetVertexColor(1, 1, 1, 0.8)

	closeButton:SetScript("OnClick", function()
		dialog:Hide()
		dialog:SetParent(nil)
	end)
	dialog:EnableKeyboard(true)
	if dialog.SetPropagateKeyboardInput then
		dialog:SetPropagateKeyboardInput(false)
	end
	dialog:SetScript("OnKeyDown", function(self, key)
		if key == "ESCAPE" then
			self:Hide()
		end
	end)

	closeButton:SetScript("OnEnter", function(self)
		self.Icon:SetVertexColor(1, 1, 1, 1)
		closeBg:SetVertexColor(1, 0.2, 0.2, 0.3)
	end)

	closeButton:SetScript("OnLeave", function(self)
		self.Icon:SetVertexColor(1, 1, 1, 0.8)
		closeBg:SetVertexColor(0, 0, 0, 0)
	end)

	-- Content area
	local content = CreateFrame("Frame", nil, dialog)
	content:SetPoint("TOPLEFT", 0, -HEADER_HEIGHT)
	content:SetPoint("BOTTOMRIGHT", 0, 0)

	CreateColoredBackground(content, BG_COLOR[1], BG_COLOR[2], BG_COLOR[3], BG_COLOR[4])

	-- Instructions
	local instructText = content:CreateFontString(nil, "OVERLAY")
	instructText:SetFontObject(K.UIFont)
	instructText:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
	instructText:SetText("Paste your profile code below:")
	instructText:SetPoint("TOP", content, "TOP", 0, -15)

	-- Current character info
	local charInfo = content:CreateFontString(nil, "OVERLAY")
	charInfo:SetFontObject(K.UIFont)
	charInfo:SetTextColor(ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3], 1)
	charInfo:SetText("Will apply to: " .. K.Name .. " @ " .. K.Realm)
	charInfo:SetPoint("TOP", instructText, "BOTTOM", 0, -5)

	-- Scrollable text area
	local scrollFrame = CreateFrame("ScrollFrame", nil, content)
	scrollFrame:SetSize(460, 180)
	scrollFrame:SetPoint("TOP", charInfo, "BOTTOM", 0, -10)

	CreateColoredBackground(scrollFrame, WIDGET_BG[1], WIDGET_BG[2], WIDGET_BG[3], WIDGET_BG[4])

	-- Simple border
	local scrollBorder = CreateFrame("Frame", nil, scrollFrame)
	scrollBorder:SetPoint("TOPLEFT", -1, 1)
	scrollBorder:SetPoint("BOTTOMRIGHT", 1, -1)
	scrollBorder:SetFrameLevel(scrollFrame:GetFrameLevel() - 1)
	local borderTexture = scrollBorder:CreateTexture(nil, "BACKGROUND")
	borderTexture:SetAllPoints()
	borderTexture:SetTexture(C["Media"].Textures.White8x8Texture)
	borderTexture:SetVertexColor(0.3, 0.3, 0.3, 0.8)

	local scrollChild = CreateFrame("Frame", nil, scrollFrame)
	scrollChild:SetSize(440, 180)
	scrollFrame:SetScrollChild(scrollChild)

	-- Import code editbox
	local importBox = CreateFrame("EditBox", nil, scrollChild)
	importBox:SetSize(440, 180)
	importBox:SetPoint("TOPLEFT", 10, -10)
	importBox:SetFontObject(K.UIFont)
	importBox:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
	importBox:SetAutoFocus(false)
	importBox:SetMultiLine(true)
	importBox:SetMaxLetters(0)
	importBox:SetTextInsets(10, 10, 10, 10)
	importBox:EnableMouse(true)
	importBox:SetCursorPosition(0)

	-- Placeholder
	local placeholder = "Paste your KkthnxUI profile code here..."
	local isPlaceholder = true

	importBox:SetText(placeholder)
	importBox:SetTextColor(0.6, 0.6, 0.6, 1)

	importBox:SetScript("OnEditFocusGained", function(self)
		if isPlaceholder then
			self:SetText("")
			self:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
			isPlaceholder = false
		end
	end)

	importBox:SetScript("OnEditFocusLost", function(self)
		local text = self:GetText()
		if text == "" or text:trim() == "" then
			self:SetText(placeholder)
			self:SetTextColor(0.6, 0.6, 0.6, 1)
			isPlaceholder = true
		end
	end)

	-- Status message
	local statusText = content:CreateFontString(nil, "OVERLAY")
	statusText:SetFontObject(K.UIFont)
	statusText:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
	statusText:SetText("Ready to import...")
	statusText:SetPoint("TOP", scrollFrame, "BOTTOM", 0, -10)
	statusText:SetWidth(460)
	statusText:SetJustifyH("CENTER")

	-- Import mode selection
	local applyToCurrent = true

	local modeLabel = content:CreateFontString(nil, "OVERLAY")
	modeLabel:SetFontObject(K.UIFont)
	modeLabel:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
	modeLabel:SetText("Import Mode:")
	modeLabel:SetPoint("BOTTOMLEFT", statusText, "BOTTOMLEFT", 5, -30)

	-- Apply to current button
	local applyButton = CreateButton(content, "Apply to Current", 140, 24, function()
		applyToCurrent = true
		applyButton.Text:SetTextColor(ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3], 1)
		createButton.Text:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
		charInfo:SetText("Will apply to: " .. K.Name .. " @ " .. K.Realm)
	end)
	applyButton:SetPoint("LEFT", modeLabel, "RIGHT", 10, 0)
	applyButton.Text:SetTextColor(ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3], 1)

	-- Create new profile button
	local createButton = CreateButton(content, "Create New Profile", 140, 24, function()
		applyToCurrent = false
		createButton.Text:SetTextColor(ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3], 1)
		applyButton.Text:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
		charInfo:SetText("Will create new profile entry")
	end)
	createButton:SetPoint("LEFT", applyButton, "RIGHT", 10, 0)

	-- Validation function
	local function ValidateImportCode()
		local code = importBox:GetText()
		if isPlaceholder or not code or code == "" or code:trim() == "" then
			statusText:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
			statusText:SetText("Please paste a profile code")
			return false
		end

		-- Trim the code
		code = code:trim()

		-- Check format
		local isValidFormat = code:find("KkthnxUI:Profile:", 1, true)

		if not isValidFormat then
			statusText:SetTextColor(ERROR_COLOR[1], ERROR_COLOR[2], ERROR_COLOR[3], 1)
			statusText:SetText("Invalid format - code must start with 'KkthnxUI:Profile:'")
			return false
		end

		statusText:SetTextColor(SUCCESS_COLOR[1], SUCCESS_COLOR[2], SUCCESS_COLOR[3], 1)
		statusText:SetText("Valid profile code detected")
		return true
	end

	-- Buttons
	local validateButton = CreateButton(content, "Validate", 80, BUTTON_HEIGHT, ValidateImportCode)
	validateButton:SetPoint("BOTTOMLEFT", content, "BOTTOMLEFT", 20, 15)

	local importButton = CreateButton(content, "Import", 80, BUTTON_HEIGHT, function()
		if not ValidateImportCode() then
			return
		end

		local success, error = self:ImportProfile(importBox:GetText(), applyToCurrent)
		if success then
			self:ShowStatusMessage(error, "success")
			self:RefreshProfileList()
			self:UpdateInfoPanel()
			self:UpdateButtonStates()
			dialog:Hide()
			dialog:SetParent(nil)

			-- Ask if user wants to reload UI
			if applyToCurrent then
				self:ShowReloadUIDialog("Profile applied successfully. Would you like to reload the UI to ensure all changes take effect?")
			end
		else
			statusText:SetTextColor(ERROR_COLOR[1], ERROR_COLOR[2], ERROR_COLOR[3], 1)
			statusText:SetText(error)
		end
	end)
	importButton:SetPoint("BOTTOM", content, "BOTTOM", 0, 15)

	local cancelButton = CreateButton(content, "Cancel", 80, BUTTON_HEIGHT, function()
		dialog:Hide()
		dialog:SetParent(nil)
	end)
	cancelButton:SetPoint("BOTTOMRIGHT", content, "BOTTOMRIGHT", -20, 15)

	-- Auto-validation on text change
	local validateTimer = nil
	importBox:SetScript("OnTextChanged", function(self)
		if validateTimer then
			validateTimer:Cancel()
		end

		if not isPlaceholder then
			validateTimer = C_Timer.NewTimer(1.0, ValidateImportCode)
		end
	end)

	-- Focus the import box
	C_Timer.After(0.1, function()
		importBox:SetFocus()
	end)

	return dialog
end

-- Simple dialog helper for basic text display
function ProfileGUI:CreateSimpleDialog(title, message, content)
	local dialog = CreateFrame("Frame", nil, UIParent)
	dialog:SetSize(400, 250)
	dialog:SetPoint("CENTER")
	dialog:SetFrameStrata("TOOLTIP")
	dialog:EnableMouse(true)

	CreateColoredBackground(dialog, 0.08, 0.08, 0.08, 0.95)

	-- Title
	local titleText = dialog:CreateFontString(nil, "OVERLAY")
	titleText:SetFontObject(K.UIFont)
	titleText:SetTextColor(ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3], 1)
	titleText:SetText(title)
	titleText:SetPoint("TOP", 0, -15)

	-- Message
	local messageText = dialog:CreateFontString(nil, "OVERLAY")
	messageText:SetFontObject(K.UIFont)
	messageText:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
	messageText:SetText(message)
	messageText:SetPoint("TOP", titleText, "BOTTOM", 0, -15)

	-- Content box
	local contentBox = CreateEditBox(dialog, 360, 120, true)
	contentBox:SetPoint("TOP", messageText, "BOTTOM", 0, -15)
	contentBox:SetText(content or "")

	-- Close button
	local closeButton = CreateButton(dialog, "Close", 100, BUTTON_HEIGHT, function()
		dialog:Hide()
		dialog:SetParent(nil)
	end)
	closeButton:SetPoint("BOTTOM", 0, 15)

	return dialog
end

-- Show/Hide functions
function ProfileGUI:Show()
	if not self.Frame then
		self:CreateMainFrame()
	end

	-- Refresh current character metadata when opening ProfileGUI
	self:StoreCharacterMetadata(K.Name, K.Realm)

	-- Try to find the main GUI and anchor to it
	local mainConfig = nil

	-- Try multiple ways to find the main GUI frame
	if _G.KkthnxUI_NewGUI and _G.KkthnxUI_NewGUI.Frame and _G.KkthnxUI_NewGUI.Frame:IsShown() then
		mainConfig = _G.KkthnxUI_NewGUI.Frame
	elseif K.NewGUI and K.NewGUI.Frame and K.NewGUI.Frame:IsShown() then
		mainConfig = K.NewGUI.Frame
	end

	self.Frame:ClearAllPoints()
	if mainConfig then
		-- Anchor to the right of the main GUI
		self.Frame:SetPoint("TOPLEFT", mainConfig, "TOPRIGHT", 18, 0)
		self.Frame:SetHeight(mainConfig:GetHeight())
	else
		-- Center on screen if main GUI is not available
		self.Frame:SetPoint("CENTER", UIParent, "CENTER")
		self.Frame:SetHeight(PANEL_HEIGHT)
	end

	self.Frame:Show()
	self.IsVisible = true

	-- Start periodic check to auto-close if main GUI is closed
	self:StartMainGUICheck()

	-- Refresh data
	self:RefreshProfileList()
	self:UpdateInfoPanel()
	self:UpdateButtonStates()

	-- Refresh all portraits to ensure they're up to date
	self:RefreshAllPortraits()
end

-- Periodic check to close ProfileGUI if main GUI is closed
function ProfileGUI:StartMainGUICheck()
	if self.MainGUICheckTimer then
		self.MainGUICheckTimer:Cancel()
	end

	self.MainGUICheckTimer = C_Timer.NewTicker(1, function()
		if self.IsVisible and not self:IsMainGUIVisible() then
			self:Hide()
		end
	end)
end

function ProfileGUI:StopMainGUICheck()
	if self.MainGUICheckTimer then
		self.MainGUICheckTimer:Cancel()
		self.MainGUICheckTimer = nil
	end
end

function ProfileGUI:Hide()
	-- Stop the main GUI check timer
	self:StopMainGUICheck()

	if self.Frame then
		self.Frame:Hide()
	end
	self.IsVisible = false

	-- Clear any pending status messages
	if self.StatusMessageTimer then
		self.StatusMessageTimer:Cancel()
		self.StatusMessageTimer = nil
	end

	-- Clean up any open dialogs
	for i = 1, UIParent:GetNumChildren() do
		local child = select(i, UIParent:GetChildren())
		if child and child.__KKUI_ProfileGUI and child.Hide and child:IsShown() then
			pcall(function()
				child:Hide()
			end)
		end
	end
end

function ProfileGUI:Toggle()
	if self.IsVisible then
		self:Hide()
	else
		self:Show()
	end
end

-- Check if main GUI is visible for auto-closing
function ProfileGUI:IsMainGUIVisible()
	-- Try multiple ways to detect main GUI visibility
	if _G.KkthnxUI_NewGUI and _G.KkthnxUI_NewGUI.Frame then
		return _G.KkthnxUI_NewGUI.Frame:IsShown()
	elseif K.NewGUI and K.NewGUI.Frame then
		return K.NewGUI.Frame:IsShown()
	elseif K.GUI and K.GUI.Frame then
		return K.GUI.Frame:IsShown()
	end
	return false
end

-- Dialog creation functions
function ProfileGUI:ShowCreateProfileDialog()
	local dialog = self:CreateInputDialog("Create New Profile", "Enter a name for the new profile:", "", function(profileName)
		if not profileName or profileName == "" then
			self:ShowStatusMessage("Profile name cannot be empty", "error")
			return
		end

		local success, error = self:CreateProfile(profileName)
		if success then
			self:ShowStatusMessage("Profile created successfully", "success")
			self:RefreshProfileList()
		else
			self:ShowStatusMessage(error, "error")
		end
	end)
end

function ProfileGUI:ShowCopyProfileDialog()
	if not self.SelectedProfile then
		self:ShowStatusMessage("No profile selected to copy", "error")
		return
	end

	local profiles = self:GetAllProfiles()
	local sourceProfile = profiles[self.SelectedProfile]

	local dialog = self:CreateInputDialog("Copy Profile", "Enter a name for the copied profile:", sourceProfile.name .. " Copy", function(profileName)
		if not profileName or profileName == "" then
			self:ShowStatusMessage("Profile name cannot be empty", "error")
			return
		end

		local success, error = self:CreateProfile(profileName, self.SelectedProfile)
		if success then
			self:ShowStatusMessage("Profile copied successfully", "success")
			self:RefreshProfileList()
		else
			self:ShowStatusMessage(error, "error")
		end
	end)
end

function ProfileGUI:ShowDeleteConfirmation()
	if not self.SelectedProfile then
		self:ShowStatusMessage("No profile selected to delete", "error")
		return
	end

	local profiles = self:GetAllProfiles()
	local profile = profiles[self.SelectedProfile]

	if profile.isCurrent then
		self:ShowStatusMessage("Cannot delete the currently active profile", "error")
		return
	end

	local dialog = self:CreateConfirmDialog("Delete Profile", "Are you sure you want to delete the profile '" .. profile.name .. "'?\n\nThis action cannot be undone.", function()
		local success, error = self:DeleteProfile(self.SelectedProfile)
		if success then
			self:ShowStatusMessage("Profile deleted successfully", "success")
			self.SelectedProfile = nil
			self:RefreshProfileList()
			self:UpdateInfoPanel()
			self:UpdateButtonStates()
		else
			self:ShowStatusMessage(error, "error")
		end
	end)
end

function ProfileGUI:ShowResetConfirmation()
	local profiles = self:GetAllProfiles()
	local profile = self.SelectedProfile and profiles[self.SelectedProfile]
	local profileName = profile and profile.name or "current profile"

	local dialog = self:CreateConfirmDialog("Reset Profile", "Are you sure you want to reset '" .. profileName .. "' to default settings?\n\nThis action cannot be undone.", function()
		local success, error = self:ResetProfile(self.SelectedProfile)
		if success then
			self:ShowStatusMessage("Profile reset successfully", "success")
			self:RefreshProfileList()
		else
			self:ShowStatusMessage(error, "error")
		end
	end)
end

-- Character metadata and utility functions
function ProfileGUI:GetClassFromGoldInfo(name, realm)
	-- First check Gold data (class is at index 2)
	if KkthnxUIDB.Gold and KkthnxUIDB.Gold[realm] and KkthnxUIDB.Gold[realm][name] then
		local classFromGold = KkthnxUIDB.Gold[realm][name][2]
		if classFromGold and classFromGold ~= "NONE" then
			return classFromGold
		end
	end

	-- Fallback to ProfilePortraits if available
	if KkthnxUIDB.ProfilePortraits and KkthnxUIDB.ProfilePortraits[realm] and KkthnxUIDB.ProfilePortraits[realm][name] then
		return KkthnxUIDB.ProfilePortraits[realm][name].class
	end

	return "NONE"
end

-- Store character metadata for better portraits
function ProfileGUI:StoreCharacterMetadata(name, realm)
	-- Only store for current character to avoid API limitations
	if realm == K.Realm and name == K.Name then
		-- Check if we need to refresh the data
		if not self:ShouldRefreshCharacterData(name, realm) then
			return
		end

		-- Ensure ProfilePortraits structure exists
		if not KkthnxUIDB.ProfilePortraits then
			KkthnxUIDB.ProfilePortraits = {}
		end
		if not KkthnxUIDB.ProfilePortraits[realm] then
			KkthnxUIDB.ProfilePortraits[realm] = {}
		end

		-- Get current character data with validation
		local class = K.Class or UnitClass("player")
		local race = K.Race or UnitRace("player")
		local gender = K.Sex or UnitSex("player")
		local faction = K.Faction or UnitFactionGroup("player")

		-- Validate the data before storing
		if class and race and gender and faction then
			-- Store portrait metadata separately from Gold data
			KkthnxUIDB.ProfilePortraits[realm][name] = {
				class = class,
				race = race,
				gender = gender,
				faction = faction,
				lastUpdated = time(),
			}
		end

		-- Ensure current profile has LastModified timestamp
		if KkthnxUIDB.Settings and KkthnxUIDB.Settings[realm] and KkthnxUIDB.Settings[realm][name] then
			if not KkthnxUIDB.Settings[realm][name].LastModified then
				KkthnxUIDB.Settings[realm][name].LastModified = time()
			end
		end
	end
end

-- Get race info from portrait storage
function ProfileGUI:GetRaceFromPortraitData(name, realm)
	if KkthnxUIDB.ProfilePortraits and KkthnxUIDB.ProfilePortraits[realm] and KkthnxUIDB.ProfilePortraits[realm][name] then
		return KkthnxUIDB.ProfilePortraits[realm][name].race
	end
	return nil
end

-- Get gender info from portrait storage
function ProfileGUI:GetGenderFromPortraitData(name, realm)
	if KkthnxUIDB.ProfilePortraits and KkthnxUIDB.ProfilePortraits[realm] and KkthnxUIDB.ProfilePortraits[realm][name] then
		return KkthnxUIDB.ProfilePortraits[realm][name].gender
	end
	return nil
end

-- Helper function to convert race name to atlas format
function ProfileGUI:GetRaceAtlasName(race, gender)
	if not race or not gender then
		return nil
	end

	-- Ensure gender is a number and valid
	local genderNum = tonumber(gender)
	if not genderNum or (genderNum ~= 2 and genderNum ~= 3) then
		return nil
	end

	-- Convert gender number to string
	local genderStr = (genderNum == 3) and "female" or "male"

	-- Map WoW race names to atlas names
	local raceMap = {
		["Human"] = "human",
		["Dwarf"] = "dwarf",
		["Night Elf"] = "nightelf",
		["Gnome"] = "gnome",
		["Draenei"] = "draenei",
		["Worgen"] = "worgen",
		["Void Elf"] = "voidelf",
		["Lightforged Draenei"] = "lightforged",
		["Dark Iron Dwarf"] = "darkirondwarf",
		["KulTiran"] = "kultiran",
		["Mechagnome"] = "mechagnome",
		["Orc"] = "orc",
		["Undead"] = "undead",
		["Tauren"] = "tauren",
		["Troll"] = "troll",
		["Blood Elf"] = "bloodelf",
		["Goblin"] = "goblin",
		["Nightborne"] = "nightborne",
		["Highmountain Tauren"] = "highmountain",
		["Maghar Orc"] = "magharorc",
		["Zandalari Troll"] = "zandalari",
		["Vulpera"] = "vulpera",
		["Pandaren"] = "pandaren",
		["Dracthyr"] = "dracthyr",
		["Earthen"] = "earthen",
	}

	local atlasRace = raceMap[race]
	if atlasRace then
		return "raceicon-" .. atlasRace .. "-" .. genderStr
	end

	return nil
end

-- Portrait setup function
function ProfileGUI:SetupPortrait(portrait, name, realm)
	-- For current character, always use real player portrait
	if realm == K.Realm and name == K.Name then
		-- Use SetPortraitTexture directly but override the mask
		SetPortraitTexture(portrait, "player")
		-- Override the circular mask with square coordinates
		portrait:SetTexCoord(0.15, 0.85, 0.15, 0.85)
	else
		-- For other characters, use priority system:
		-- 1. Try race portrait (with gender)
		-- 2. Fall back to class icon
		-- 3. Fall back to generic race icon
		-- 4. Fall back to unknown icon

		local race = self:GetRaceFromPortraitData(name, realm)
		local gender = self:GetGenderFromPortraitData(name, realm)
		local class = self:GetClassFromGoldInfo(name, realm)

		-- Try race portrait with gender first
		local raceAtlas = self:GetRaceAtlasName(race, gender)
		if raceAtlas then
			local success = pcall(function()
				portrait:SetAtlas(raceAtlas)
			end)
			if success then
				-- Trim race icon padding for cleaner look
				portrait:SetTexCoord(0.1, 0.9, 0.1, 0.9)
				return
			end
		end

		-- Fall back to class icon
		if class and class ~= "NONE" then
			local className = class:lower()
			local success = pcall(function()
				portrait:SetAtlas("classicon-" .. className)
			end)
			if success then
				-- Class icons don't need trimming
				portrait:SetTexCoord(0, 1, 0, 1)
				return
			end
		end

		-- Fall back to generic race icon (human male as default)
		if race then
			local fallbackAtlas = self:GetRaceAtlasName(race, 2) -- Try male version
			if fallbackAtlas then
				local success = pcall(function()
					portrait:SetAtlas(fallbackAtlas)
				end)
				if success then
					portrait:SetTexCoord(0.1, 0.9, 0.1, 0.9)
					return
				end
			end
		end

		-- Final fallback - try human male, then use a solid color if that fails
		local success = pcall(function()
			portrait:SetAtlas("raceicon-human-male")
		end)
		if success then
			portrait:SetTexCoord(0.1, 0.9, 0.1, 0.9)
		else
			-- Ultimate fallback - set to a solid color texture
			portrait:SetTexture(C["Media"].Textures.White8x8Texture)
			portrait:SetVertexColor(0.3, 0.3, 0.3, 1)
			portrait:SetTexCoord(0, 1, 0, 1)
		end
	end
end

-- Helper function to get character faction from gold data
function ProfileGUI:GetFactionFromGoldInfo(name, realm)
	-- First check Gold data (faction is at index 3)
	if KkthnxUIDB.Gold and KkthnxUIDB.Gold[realm] and KkthnxUIDB.Gold[realm][name] then
		local factionFromGold = KkthnxUIDB.Gold[realm][name][3]
		if factionFromGold then
			return factionFromGold
		end
	end

	-- Fallback to ProfilePortraits if available
	if KkthnxUIDB.ProfilePortraits and KkthnxUIDB.ProfilePortraits[realm] and KkthnxUIDB.ProfilePortraits[realm][name] then
		return KkthnxUIDB.ProfilePortraits[realm][name].faction
	end

	return "Unknown"
end

-- Returns (changedCount, totalCount). changedCount compares against K.Defaults if available.
function ProfileGUI:GetProfileDataSize(profileData)
	if not profileData then
		return 0, 0
	end
	-- Ignore metadata keys that are not user configuration
	local META = {
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
	local function countTotal(t, depth)
		depth = depth or 0
		if depth > 20 or type(t) ~= "table" then
			return 0
		end
		local count = 0
		for k, v in pairs(t) do
			if not META[k] then
				count = count + 1
				if type(v) == "table" then
					count = count + countTotal(v, depth + 1)
				end
			end
		end
		return count
	end
	local function countDiffs(curr, defaults, depth)
		depth = depth or 0
		if depth > 20 then
			return 0
		end
		if type(curr) ~= "table" then
			if curr ~= defaults then
				return 1
			else
				return 0
			end
		end
		local diffs = 0
		for k, v in pairs(curr) do
			if not META[k] then
				local dv = (type(defaults) == "table") and defaults[k] or nil
				if type(v) == "table" then
					diffs = diffs + countDiffs(v, dv, depth + 1)
				else
					if v ~= dv then
						diffs = diffs + 1
					end
				end
			end
		end
		return diffs
	end
	local total = countTotal(profileData)
	local changed = 0
	if K.Defaults and type(K.Defaults) == "table" then
		changed = countDiffs(profileData, K.Defaults)
	else
		local function countLeaves(t)
			local c = 0
			if type(t) == "table" then
				for k, v in pairs(t) do
					if not META[k] then
						if type(v) == "table" then
							c = c + countLeaves(v)
						else
							c = c + 1
						end
					end
				end
			end
			return c
		end
		changed = countLeaves(profileData)
	end
	return changed, total
end

-- Returns (enabledCount, disabledCount) by scanning booleans in the profile (ignoring metadata)
function ProfileGUI:GetBooleanStats(profileData)
	if not profileData then
		return 0, 0
	end
	local META = {
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
	local on, off = 0, 0
	local function walk(t, depth)
		depth = depth or 0
		if depth > 20 or type(t) ~= "table" then
			return
		end
		for k, v in pairs(t) do
			if not META[k] then
				if type(v) == "boolean" then
					if v then
						on = on + 1
					else
						off = off + 1
					end
				elseif type(v) == "table" then
					walk(v, depth + 1)
				end
			end
		end
	end
	walk(profileData, 0)
	return on, off
end

-- Dialog Helper Functions
function ProfileGUI:CreateInputDialog(title, message, defaultText, onConfirm)
	local dialog = CreateFrame("Frame", nil, UIParent)
	dialog:SetSize(350, 180)
	dialog:SetPoint("CENTER")
	dialog:SetFrameStrata("TOOLTIP")
	dialog:SetFrameLevel(120)
	dialog:EnableMouse(true)

	CreateColoredBackground(dialog, 0.08, 0.08, 0.08, 0.95)

	-- Title
	local titleText = dialog:CreateFontString(nil, "OVERLAY")
	titleText:SetFontObject(K.UIFont)
	titleText:SetTextColor(ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3], 1)
	titleText:SetText(title)
	titleText:SetPoint("TOP", 0, -15)

	-- Message
	local messageText = dialog:CreateFontString(nil, "OVERLAY")
	messageText:SetFontObject(K.UIFont)
	messageText:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
	messageText:SetText(message)
	messageText:SetPoint("TOP", titleText, "BOTTOM", 0, -15)

	-- Input box
	local inputBox = CreateEditBox(dialog, 250, 28)
	inputBox:SetPoint("TOP", messageText, "BOTTOM", 0, -20)
	inputBox:SetText(defaultText or "")
	inputBox:SetFocus()

	-- Buttons
	local confirmButton = CreateButton(dialog, "OK", 80, BUTTON_HEIGHT, function()
		local text = inputBox:GetText()
		if onConfirm then
			onConfirm(text)
		end
		dialog:Hide()
		dialog:SetParent(nil)
	end)
	confirmButton:SetPoint("BOTTOMRIGHT", dialog, "BOTTOM", -10, 15)

	local cancelButton = CreateButton(dialog, "Cancel", 80, BUTTON_HEIGHT, function()
		dialog:Hide()
		dialog:SetParent(nil)
	end)
	cancelButton:SetPoint("BOTTOMLEFT", dialog, "BOTTOM", 10, 15)

	-- Handle Enter key
	inputBox:SetScript("OnEnterPressed", function()
		confirmButton:Click()
	end)

	-- Handle Escape key
	inputBox:SetScript("OnEscapePressed", function()
		cancelButton:Click()
	end)

	return dialog
end

function ProfileGUI:CreateConfirmDialog(title, message, onConfirm, onCancel)
	local dialog = CreateFrame("Frame", nil, UIParent)
	dialog:SetSize(350, 150)
	dialog:SetPoint("CENTER")
	dialog:SetFrameStrata("TOOLTIP")
	dialog:SetFrameLevel(120)
	dialog:EnableMouse(true)

	CreateColoredBackground(dialog, 0.08, 0.08, 0.08, 0.95)

	-- Title
	local titleText = dialog:CreateFontString(nil, "OVERLAY")
	titleText:SetFontObject(K.UIFont)
	titleText:SetTextColor(ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3], 1)
	titleText:SetText(title)
	titleText:SetPoint("TOP", 0, -15)

	-- Message (support multi-line)
	local messageText = dialog:CreateFontString(nil, "OVERLAY")
	messageText:SetFontObject(K.UIFont)
	messageText:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
	messageText:SetText(message)
	messageText:SetPoint("TOP", titleText, "BOTTOM", 0, -20)
	messageText:SetWidth(300)
	messageText:SetJustifyH("CENTER")

	-- Buttons
	local confirmButton = CreateButton(dialog, "Yes", 80, BUTTON_HEIGHT, function()
		if onConfirm then
			onConfirm()
		end
		dialog:Hide()
		dialog:SetParent(nil)
	end)
	confirmButton:SetPoint("BOTTOMRIGHT", dialog, "BOTTOM", -10, 15)

	local cancelButton = CreateButton(dialog, "No", 80, BUTTON_HEIGHT, function()
		if onCancel then
			onCancel()
		end
		dialog:Hide()
		dialog:SetParent(nil)
	end)
	cancelButton:SetPoint("BOTTOMLEFT", dialog, "BOTTOM", 10, 15)

	return dialog
end

-- Initialize ProfileGUI
K.ProfileGUI = ProfileGUI

-- Enhanced safety check for database integrity
function ProfileGUI:EnsureDatabaseIntegrity()
	if not KkthnxUIDB then
		KkthnxUIDB = {}
	end
	if not KkthnxUIDB.Settings then
		KkthnxUIDB.Settings = {}
	end
	if not KkthnxUIDB.Settings[K.Realm] then
		KkthnxUIDB.Settings[K.Realm] = {}
	end
	if not KkthnxUIDB.Variables then
		KkthnxUIDB.Variables = {}
	end
	if not KkthnxUIDB.Variables[K.Realm] then
		KkthnxUIDB.Variables[K.Realm] = {}
	end
	return true
end

-- Enhanced Profile Switching Functionality
function ProfileGUI:SwitchToProfile(profileKey)
	if not profileKey then
		self:ShowStatusMessage("No profile selected", "error")
		return false
	end

	local profiles = self:GetAllProfiles()
	local targetProfile = profiles[profileKey]

	if not targetProfile then
		self:ShowStatusMessage("Profile not found", "error")
		return false
	end

	if targetProfile.isCurrent then
		self:ShowStatusMessage("Profile is already active", "warning")
		return false
	end

	-- Simple profile switch - copy data to current character
	local success, error = self:SwitchProfile(profileKey)
	if success then
		self:ShowStatusMessage("Switched to profile: " .. targetProfile.name, "success")
		self:RefreshProfileList()
		self:UpdateInfoPanel()
		self:UpdateButtonStates()

		-- Ask if user wants to reload UI
		self:ShowReloadUIDialog("Profile switched successfully. Would you like to reload the UI to ensure all changes take effect?")
		return true
	else
		self:ShowStatusMessage(error or "Failed to switch profile", "error")
		return false
	end
end

function ProfileGUI:ShowReloadUIDialog(message)
	local dialog = self:CreateConfirmDialog("Reload UI", message, function()
		ReloadUI()
	end, function()
		-- User chose not to reload, that's fine
	end)
	return dialog
end

-- Module initialization and exposure
function ProfileGUI:Initialize()
	-- Set up initial state
	self.IsInitialized = true
	self.SelectedProfile = nil

	-- Try to auto-select current profile
	local currentKey = self:GetCurrentProfileKey()
	local profiles = self:GetAllProfiles()
	if profiles[currentKey] then
		self.SelectedProfile = currentKey
	end
end

-- Enable function for integration with Loading.lua
function ProfileGUI:Enable()
	-- Guard against double-enabling
	if self._enabled then
		return true
	end

	-- Ensure database integrity first
	if not self:EnsureDatabaseIntegrity() then
		print("|cffff0000KkthnxUI Error:|r ProfileGUI failed to initialize - database not available!")
		return false
	end

	-- Migrate existing profiles to have LastModified timestamps
	self:MigrateProfileTimestamps()

	-- Store current character metadata for portraits
	self:StoreCharacterMetadata(K.Name, K.Realm)

	-- Ensure current profile has LastModified timestamp
	self:UpdateCurrentProfileTimestamp()

	-- Check for required libraries with better error messages
	if not K.LibSerialize then
		print("|cffff0000KkthnxUI Warning:|r LibSerialize not available - profile import/export disabled!")
	end
	if not K.LibDeflate then
		print("|cffff0000KkthnxUI Warning:|r LibDeflate not available - profile import/export disabled!")
	end

	-- Initialize the ProfileGUI
	self:Initialize()

	-- Expose the timestamp update function globally so other parts of KkthnxUI can call it
	K.UpdateProfileTimestamp = function()
		if ProfileGUI and ProfileGUI.UpdateCurrentProfileTimestamp then
			ProfileGUI:UpdateCurrentProfileTimestamp()
		end
	end

	-- Slash commands are registered centrally in Core/Commands.lua to reduce taint

	self._enabled = true
	return true
end

-- Expose ProfileGUI globally for Loading.lua access
K.ProfileGUI = ProfileGUI

-- Helper function to refresh all portraits in the profile list
function ProfileGUI:RefreshAllPortraits()
	if not self.ProfileScrollFrame or not self.ProfileScrollFrame.Child then
		return
	end

	-- Refresh current character metadata first
	self:StoreCharacterMetadata(K.Name, K.Realm)

	-- Update all portrait textures in the current list
	for _, button in ipairs({ self.ProfileScrollFrame.Child:GetChildren() }) do
		if button.Portrait and button.Profile then
			self:SetupPortrait(button.Portrait, button.Profile.name, button.Profile.realm)
		end
	end
end

-- Helper function to check if character metadata needs refreshing
function ProfileGUI:ShouldRefreshCharacterData(name, realm)
	if not KkthnxUIDB.ProfilePortraits or not KkthnxUIDB.ProfilePortraits[realm] or not KkthnxUIDB.ProfilePortraits[realm][name] then
		return true -- No data exists
	end

	local data = KkthnxUIDB.ProfilePortraits[realm][name]
	local currentTime = time()

	-- Refresh if data is older than 1 hour
	if not data.lastUpdated or (currentTime - data.lastUpdated) > 3600 then
		return true
	end

	-- Refresh if essential data is missing
	if not data.class or not data.race or not data.gender or not data.faction then
		return true
	end

	-- For current character, also check if data has changed
	if realm == K.Realm and name == K.Name then
		local currentClass = K.Class or UnitClass("player")
		local currentRace = K.Race or UnitRace("player")
		local currentGender = K.Sex or UnitSex("player")
		local currentFaction = K.Faction or UnitFactionGroup("player")

		if currentClass and currentRace and currentGender and currentFaction then
			if data.class ~= currentClass or data.race ~= currentRace or data.gender ~= currentGender or data.faction ~= currentFaction then
				return true
			end
		end
	end

	return false
end

-- Helper function to update current profile's LastModified timestamp
function ProfileGUI:UpdateCurrentProfileTimestamp()
	-- Ensure database integrity
	if not self:EnsureDatabaseIntegrity() then
		return
	end

	-- Update the current character's LastModified timestamp
	if not KkthnxUIDB.Settings[K.Realm][K.Name] then
		KkthnxUIDB.Settings[K.Realm][K.Name] = {}
	end

	-- Use time() for proper Unix timestamp
	local currentTime = time()
	KkthnxUIDB.Settings[K.Realm][K.Name].LastModified = currentTime
end

-- Helper function to migrate existing profiles to have LastModified timestamps
function ProfileGUI:MigrateProfileTimestamps()
	if not KkthnxUIDB or not KkthnxUIDB.Settings then
		return
	end

	local currentTime = time()
	local migrated = 0

	for realm, realmData in pairs(KkthnxUIDB.Settings) do
		for name, profileData in pairs(realmData) do
			if type(profileData) == "table" and not profileData.LastModified then
				profileData.LastModified = currentTime
				migrated = migrated + 1
			end
		end
	end
end
