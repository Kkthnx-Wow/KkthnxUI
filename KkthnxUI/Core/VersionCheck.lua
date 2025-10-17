local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:NewModule("VersionCheck")

--[[
	KkthnxUI Version Check
	Detects and notifies users when a newer version of KkthnxUI is available
	by communicating with other users in guild or group via addon messages
]]

-- Localize frequently used functions
local string_format = string.format
local string_gsub = string.gsub
local tonumber = tonumber
local strsplit = strsplit

local Ambiguate = Ambiguate
local C_ChatInfo_RegisterAddonMessagePrefix = C_ChatInfo.RegisterAddonMessagePrefix
local C_ChatInfo_SendAddonMessage = C_ChatInfo.SendAddonMessage
local C_Timer_After = C_Timer.After
local GetTime = GetTime
local IsInGuild = IsInGuild
local IsInGroup = IsInGroup
local IsInRaid = IsInRaid
local OKAY = OKAY
local StaticPopup_Show = StaticPopup_Show
local StaticPopupDialogs = StaticPopupDialogs

-- Constants
local VERSION_CHECK_PREFIX = "KKUIVersionCheck"
local VERSION_CHECK_THROTTLE = 10 -- Seconds between version broadcasts

-- Helper function to parse version string into major and minor numbers
local function ParseVersionTag(version)
	if not version or type(version) ~= "string" then
		return 0, 0
	end

	local major, minor = strsplit(".", version)
	major = tonumber(major) or 0
	minor = tonumber(minor) or 0

	-- Validate version numbers
	if major < 0 or major > 999 or minor < 0 or minor > 999 then
		if K.isDeveloper then
			K.Print(string_format("Invalid version detected: %s", version))
		end
		return 0, 0
	end

	return major, minor
end

-- Compare two version strings
-- Returns: "IsNew" if new > old, "IsOld" if new < old, nil if equal
function Module:CompareVersions(newVersion, oldVersion)
	local newMajor, newMinor = ParseVersionTag(newVersion)
	local oldMajor, oldMinor = ParseVersionTag(oldVersion)

	if newMajor > oldMajor or (newMajor == oldMajor and newMinor > oldMinor) then
		return "IsNew"
	elseif newMajor < oldMajor or (newMajor == oldMajor and newMinor < oldMinor) then
		return "IsOld"
	end

	return nil
end

-- Create a visual notification for outdated version
local function ShowVersionNotification(newerVersion)
	if not C["General"].VersionCheck then
		return
	end

	-- Use a simple StaticPopup for notification
	local popupName = "KKUI_VERSION_OUTDATED"
	if not StaticPopupDialogs[popupName] then
		StaticPopupDialogs[popupName] = {
			text = string_format("|cff3c9bedKkthnxUI|r\n\nYour version is outdated!\n\nCurrent: |cffff0000%s|r\nLatest: |cff00ff00%s|r\n\nPlease update to get the latest features and bug fixes.", K.Version, newerVersion),
			button1 = OKAY,
			timeout = 0,
			whileDead = true,
			hideOnEscape = true,
			preferredIndex = 3,
		}
	else
		-- Update the text with the new version
		StaticPopupDialogs[popupName].text = string_format("|cff3c9bedKkthnxUI|r\n\nYour version is outdated!\n\nCurrent: |cffff0000%s|r\nLatest: |cff00ff00%s|r\n\nPlease update to get the latest features and bug fixes.", K.Version, newerVersion)
	end

	StaticPopup_Show(popupName)

	-- Also print to chat
	K.Print(string_format("A newer version (%s) is available! You are using version %s. Please update.", newerVersion, K.Version))
end

-- Initialize version check (check stored version against current)
function Module:InitializeVersionCheck()
	if self.isInitialized then
		return
	end

	if not KkthnxUIDB.DetectedVersion then
		KkthnxUIDB.DetectedVersion = K.Version
		self.isInitialized = true
		return
	end

	local status = self:CompareVersions(KkthnxUIDB.DetectedVersion, K.Version)
	if status == "IsNew" then
		-- A newer version has been detected by others
		local releaseVersion = string_gsub(KkthnxUIDB.DetectedVersion, "(%d+)$", "0")
		ShowVersionNotification(releaseVersion)
	elseif status == "IsOld" then
		-- Our version is newer, update the database
		KkthnxUIDB.DetectedVersion = K.Version
	end

	self.isInitialized = true
end

-- Send version check message to specified channel
function Module:SendVersionCheck(channel)
	if not channel then
		return
	end

	local currentTime = GetTime()
	if currentTime - self.lastCheckTime >= VERSION_CHECK_THROTTLE then
		C_ChatInfo_SendAddonMessage(VERSION_CHECK_PREFIX, K.Version, channel)
		self.lastCheckTime = currentTime
	end
end

-- Get appropriate message channel based on group status
function Module:GetMessageChannel()
	if IsInGroup(2) then -- LE_PARTY_CATEGORY_INSTANCE
		return "INSTANCE_CHAT"
	elseif IsInRaid() then
		return "RAID"
	elseif IsInGroup() then
		return "PARTY"
	end
	return nil
end

-- Handle incoming version check messages
function Module:OnVersionCheckMessage(event, prefix, message, channel, sender)
	if prefix ~= VERSION_CHECK_PREFIX then
		return
	end

	-- Ignore messages from ourselves
	local senderName = Ambiguate(sender, "none")
	if senderName == K.Name then
		return
	end

	-- Validate the received version
	if not message or message == "" then
		return
	end

	local status = self:CompareVersions(message, KkthnxUIDB.DetectedVersion or K.Version)
	if status == "IsNew" then
		-- Someone has a newer version
		KkthnxUIDB.DetectedVersion = message
		self:InitializeVersionCheck()
	elseif status == "IsOld" then
		-- We have a newer version, broadcast it
		self:SendVersionCheck(channel)
	end
end

-- Update version check when group roster changes
function Module:OnGroupRosterUpdate()
	if not IsInGroup() then
		return
	end

	local channel = self:GetMessageChannel()
	if channel then
		self:SendVersionCheck(channel)
	end
end

-- Module OnEnable function (called by KkthnxUI module system)
function Module:OnEnable()
	-- Check if version checking is enabled
	if not C["General"].VersionCheck then
		return
	end

	-- Initialize module state
	self.lastCheckTime = 0
	self.isInitialized = false

	-- Initialize database
	KkthnxUIDB.DetectedVersion = KkthnxUIDB.DetectedVersion or K.Version

	-- Register addon message prefix
	C_ChatInfo_RegisterAddonMessagePrefix(VERSION_CHECK_PREFIX)

	-- Register event for receiving messages
	K:RegisterEvent("CHAT_MSG_ADDON", function(...)
		self:OnVersionCheckMessage(...)
	end)

	-- Register for group roster updates
	K:RegisterEvent("GROUP_ROSTER_UPDATE", function()
		self:OnGroupRosterUpdate()
	end)

	-- Delay initial check to ensure everything is loaded
	C_Timer_After(2, function()
		-- Perform initial version check
		self:InitializeVersionCheck()

		-- Send initial version broadcast to guild if available
		if IsInGuild() then
			C_ChatInfo_SendAddonMessage(VERSION_CHECK_PREFIX, K.Version, "GUILD")
			self.lastCheckTime = GetTime()
		end

		-- Check group and send to group channel
		self:OnGroupRosterUpdate()
	end)
end
