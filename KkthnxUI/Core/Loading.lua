local K, C = KkthnxUI[1], KkthnxUI[2]
local KKUI_AddonLoader = CreateFrame("Frame")
local KKUI_ModulesEnabled = false

-- Cache Lua globals
local pairs = pairs
local print = print
local string_format = string.format
local debugprofilestop = debugprofilestop

-- ----------------------------------------------------------------------------
-- Database Handling
-- ----------------------------------------------------------------------------

local function KKUI_CreateDefaults()
	K.Defaults = {}

	for group, options in pairs(C) do
		if not K.Defaults[group] then
			K.Defaults[group] = {}
		end

		for option, value in pairs(options) do
			K.Defaults[group][option] = value
		end
	end
end

local function KKUI_LoadCustomSettings()
	local Settings = KkthnxUIDB.Settings[K.Realm][K.Name]

	-- Schema Migration: Handle legacy settings
	if Settings and Settings.Automation then
		local automation = Settings.Automation
		if automation.AutoSkipCinematic ~= nil and automation.ConfirmCinematicSkip == nil then
			automation.ConfirmCinematicSkip = automation.AutoSkipCinematic
			automation.AutoSkipCinematic = nil
		end
	end

	-- Delta processing: Apply saved values to Config (C)
	-- Remove saved values if they match the defaults to keep DB clean
	for group, options in pairs(Settings) do
		if C[group] then
			local changeCount = 0

			for option, value in pairs(options) do
				if C[group][option] ~= nil then
					if C[group][option] == value then
						Settings[group][option] = nil -- Value matches default, remove from DB
					else
						changeCount = changeCount + 1
						C[group][option] = value -- Overwrite Config with Saved value
					end
				end
			end

			-- Clean up empty groups
			if changeCount == 0 then
				Settings[group] = nil
			end
		else
			-- Clean up groups that no longer exist in Config
			Settings[group] = nil
		end
	end
end

local function KKUI_VerifyDatabase()
	-- 1) Initialize Root Table
	KkthnxUIDB = KkthnxUIDB or {}

	-- 2) Initialize Profile/Char Tables
	KkthnxUIDB.Variables = KkthnxUIDB.Variables or {}
	KkthnxUIDB.Variables[K.Realm] = KkthnxUIDB.Variables[K.Realm] or {}
	KkthnxUIDB.Variables[K.Realm][K.Name] = KkthnxUIDB.Variables[K.Realm][K.Name] or {}

	-- 3) Set Character Variable Defaults
	local charData = KkthnxUIDB.Variables[K.Realm][K.Name]
	charData.AuraWatchList = charData.AuraWatchList or { Switcher = {}, IgnoreSpells = {} }
	charData.AuraWatchMover = charData.AuraWatchMover or {}
	charData.AutoQuest = charData.AutoQuest or false
	charData.AutoQuestIgnoreNPC = charData.AutoQuestIgnoreNPC or {}
	charData.BindType = charData.BindType or 1
	charData.CustomItems = charData.CustomItems or {}
	charData.CustomJunkList = charData.CustomJunkList or {}
	charData.CustomNames = charData.CustomNames or {}
	charData.InternalCD = charData.InternalCD or {}
	charData.Mover = charData.Mover or {}
	charData.RevealWorldMap = charData.RevealWorldMap or false
	charData.SplitCount = charData.SplitCount or 1
	charData.TempAnchor = charData.TempAnchor or {}
	charData.Tracking = charData.Tracking or { PvP = {}, PvE = {} }
	charData.QueueTimer = charData.QueueTimer or { PVEPopTime = 0 }

	-- 4) Initialize Settings Tables
	KkthnxUIDB.Settings = KkthnxUIDB.Settings or {}
	KkthnxUIDB.Settings[K.Realm] = KkthnxUIDB.Settings[K.Realm] or {}
	KkthnxUIDB.Settings[K.Realm][K.Name] = KkthnxUIDB.Settings[K.Realm][K.Name] or {}

	-- 5) Initialize Account-Wide Data
	KkthnxUIDB.ChatHistory = KkthnxUIDB.ChatHistory or {}
	KkthnxUIDB.Gold = KkthnxUIDB.Gold or {}
	KkthnxUIDB.ProfilePortraits = KkthnxUIDB.ProfilePortraits or {}
	KkthnxUIDB.KeystoneInfo = KkthnxUIDB.KeystoneInfo or {}
	KkthnxUIDB.DisabledAddOns = KkthnxUIDB.DisabledAddOns or {}

	-- Explicitly handle booleans (nil protection)
	if KkthnxUIDB.ShowSlots == nil then
		KkthnxUIDB.ShowSlots = false
	end

	-- 6) Versioning & Changelogs
	-- Ensure these exist in the schema, even if nil
	KkthnxUIDB.ChangelogVersion = KkthnxUIDB.ChangelogVersion or nil
	KkthnxUIDB.DetectedVersion = KkthnxUIDB.DetectedVersion or nil

	-- Ensure this is a boolean false if nil
	KkthnxUIDB.ChangelogHighlightLatest = KkthnxUIDB.ChangelogHighlightLatest or false
end

-- ----------------------------------------------------------------------------
-- Module Management
-- ----------------------------------------------------------------------------

local function KKUI_EnableModulesOnce()
	if KKUI_ModulesEnabled then
		return
	end
	KKUI_ModulesEnabled = true

	local startTime
	if K.isDeveloper then
		startTime = debugprofilestop()
	end

	-- 1) Enable Main GUI
	-- Prefer checking the nested table structure if it exists
	if K.GUI and K.GUI.GUI and type(K.GUI.GUI.Enable) == "function" then
		K.GUI.GUI:Enable()
	elseif K.GUI and type(K.GUI.Enable) == "function" then
		K.GUI:Enable()
	end

	-- 2) Enable ExtraGUI and attach Cogwheels
	if K.ExtraGUI and type(K.ExtraGUI.Enable) == "function" then
		K.ExtraGUI:Enable()

		-- Attach Cogwheels Logic
		if K.GUI and type(K.GUI.AttachExtraCogwheels) == "function" then
			K.GUI:AttachExtraCogwheels()
		elseif K.GUI and K.GUI.GUI and type(K.GUI.GUI.AttachExtraCogwheels) == "function" then
			K.GUI.GUI:AttachExtraCogwheels()
		end
	end

	-- 3) Enable ProfileGUI
	if K.ProfileGUI and type(K.ProfileGUI.Enable) == "function" then
		K.ProfileGUI:Enable()
	end

	if K.isDeveloper and startTime then
		local duration = debugprofilestop() - startTime
		K.Print(string_format("[KKUI_DEV] Modules Enabled in %.3f ms", duration))
	end
end

-- ----------------------------------------------------------------------------
-- Event Handler
-- ----------------------------------------------------------------------------

local function KKUI_OnEvent(self, event, arg1)
	if event == "ADDON_LOADED" and arg1 == "KkthnxUI" then
		local startTime
		if K.isDeveloper then
			startTime = debugprofilestop()
		end

		-- Initialize Database
		KKUI_VerifyDatabase()
		KKUI_CreateDefaults()
		KKUI_LoadCustomSettings()

		-- Setup initial scaling
		if K.SetupUIScale then
			K:SetupUIScale(true)
		end

		if K.isDeveloper and startTime then
			local duration = debugprofilestop() - startTime
			K.Print(string_format("[KKUI_DEV] ADDON_LOADED processing in %.3f ms", duration))
		end

		self:UnregisterEvent("ADDON_LOADED")
	elseif event == "PLAYER_LOGIN" then
		-- Enable modules when player is ready
		KKUI_EnableModulesOnce()
		self:UnregisterEvent("PLAYER_LOGIN")
	elseif event == "PLAYER_ENTERING_WORLD" then
		-- Handle timestamp updates
		if K.UpdateProfileTimestamp then
			K.UpdateProfileTimestamp()
		else
			if K.isDeveloper then
				print("|cffff9900KkthnxUI:|r UpdateProfileTimestamp not ready at PLAYER_ENTERING_WORLD")
			end
		end

		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	end
end

-- Register Events
KKUI_AddonLoader:RegisterEvent("ADDON_LOADED")
KKUI_AddonLoader:RegisterEvent("PLAYER_LOGIN")
KKUI_AddonLoader:RegisterEvent("PLAYER_ENTERING_WORLD")
KKUI_AddonLoader:SetScript("OnEvent", KKUI_OnEvent)
