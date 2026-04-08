local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:NewModule("VersionCheck")

-- NOTE: Detects newer KkthnxUI versions by communicating with guild/group members via AddonMessages.

-- PERF: Local caching for speed in hot loops and strict typing.
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
local VERSION_CHECK_THROTTLE = 10 -- NOTE: Seconds between broadcasts to limit spam.

-- PERF: Helper to parse version string into major/minor numbers for comparison.
local function ParseVersionTag(version)
	if not version or type(version) ~= "string" then
		return 0, 0
	end

	local major, minor = strsplit(".", version)
	major = tonumber(major) or 0
	minor = tonumber(minor) or 0

	-- WARNING: Basic validation to reject malformed or malicious version strings.
	if major < 0 or major > 999 or minor < 0 or minor > 999 then
		if K.isDeveloper then
			K.Print(string_format("Invalid version detected: %s", version))
		end
		return 0, 0
	end

	return major, minor
end

-- NOTE: Compare two version strings. Returns "IsNew", "IsOld", or nil.
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

-- NOTE: UI notification handling for outdated client.
local function ShowVersionNotification(newerVersion)
	if not C["General"].VersionCheck then
		return
	end

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
		-- NOTE: Update existing popup text if already initialized.
		StaticPopupDialogs[popupName].text = string_format("|cff3c9bedKkthnxUI|r\n\nYour version is outdated!\n\nCurrent: |cffff0000%s|r\nLatest: |cff00ff00%s|r\n\nPlease update to get the latest features and bug fixes.", K.Version, newerVersion)
	end

	StaticPopup_Show(popupName)

	K.Print(string_format("A newer version (%s) is available! You are using version %s. Please update.", newerVersion, K.Version))
end

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
		-- REASON: Detected version is newer than local, notify user.
		local releaseVersion = string_gsub(KkthnxUIDB.DetectedVersion, "(%d+)$", "0")
		ShowVersionNotification(releaseVersion)
	elseif status == "IsOld" then
		-- REASON: Local version is newer than DB, update DB.
		KkthnxUIDB.DetectedVersion = K.Version
	end

	self.isInitialized = true
end

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

-- COMPAT: Determine chat channel based on group type (Retail/Era agnostic).
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

function Module:OnVersionCheckMessage(event, prefix, message, channel, sender)
	if prefix ~= VERSION_CHECK_PREFIX then
		return
	end

	-- REASON: Ignore messages from self to prevent feedback loops.
	local senderName = Ambiguate(sender, "none")
	if senderName == K.Name then
		return
	end

	if not message or message == "" then
		return
	end

	local status = self:CompareVersions(message, KkthnxUIDB.DetectedVersion or K.Version)
	if status == "IsNew" then
		-- REASON: Remote peer has newer version, update tracking and re-init.
		KkthnxUIDB.DetectedVersion = message
		self:InitializeVersionCheck()
	elseif status == "IsOld" then
		-- REASON: Remote peer has older version, broadcast ours to help them update.
		self:SendVersionCheck(channel)
	end
end

function Module:OnGroupRosterUpdate()
	if not IsInGroup() then
		return
	end

	local channel = self:GetMessageChannel()
	if channel then
		self:SendVersionCheck(channel)
	end
end

function Module:OnEnable()
	if not C["General"].VersionCheck then
		return
	end

	self.lastCheckTime = 0
	self.isInitialized = false

	KkthnxUIDB.DetectedVersion = KkthnxUIDB.DetectedVersion or K.Version

	C_ChatInfo_RegisterAddonMessagePrefix(VERSION_CHECK_PREFIX)

	K:RegisterEvent("CHAT_MSG_ADDON", function(...)
		self:OnVersionCheckMessage(...)
	end)

	K:RegisterEvent("GROUP_ROSTER_UPDATE", function()
		self:OnGroupRosterUpdate()
	end)

	-- REASON: Delay initial check to ensure addon loading churn has settled.
	C_Timer_After(2, function()
		self:InitializeVersionCheck()

		if IsInGuild() then
			C_ChatInfo_SendAddonMessage(VERSION_CHECK_PREFIX, K.Version, "GUILD")
			self.lastCheckTime = GetTime()
		end

		self:OnGroupRosterUpdate()
	end)
end
