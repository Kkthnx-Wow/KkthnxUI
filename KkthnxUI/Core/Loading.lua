--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Main addon entry point and module/database loader.
-- - Design: Handles initialization, schema verification, and module loading sequence.
-- - Events: ADDON_LOADED, PLAYER_LOGIN, PLAYER_ENTERING_WORLD
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local KKUI_AddonLoader = CreateFrame("Frame")
local KKUI_ModulesEnabled = false

-- PERF: Local caching for speed in hot loops and strict typing.
local debugprofilestop = debugprofilestop
local print = print
local string_format = string.format
local type = type
local pairs = pairs

-- ---------------------------------------------------------------------------
-- DATABASE HANDLING
-- ---------------------------------------------------------------------------

local function DeepCopy(src)
	local dest = {}
	for k, v in pairs(src) do
		if type(v) == "table" then
			dest[k] = DeepCopy(v)
		else
			dest[k] = v
		end
	end
	return dest
end

local function KKUI_CreateDefaults()
	K.Defaults = {}

	for group, options in pairs(C) do
		if not K.Defaults[group] then
			K.Defaults[group] = {}
		end

		for option, value in pairs(options) do
			if type(value) == "table" then
				K.Defaults[group][option] = DeepCopy(value)
			else
				K.Defaults[group][option] = value
			end
		end
	end
end

local function KKUI_LoadCustomSettings()
	local Settings = KkthnxUIDB.Settings[K.Realm][K.Name]

	-- COMPAT: Schema Migration for legacy settings.
	if Settings and Settings.Automation then
		local automation = Settings.Automation
		if automation.AutoSkipCinematic ~= nil and automation.ConfirmCinematicSkip == nil then
			automation.ConfirmCinematicSkip = automation.AutoSkipCinematic
			automation.AutoSkipCinematic = nil
		end
	end

	-- REASON: Delta processing to keep the database size small by removing values that match defaults.
	for group, options in pairs(Settings) do
		if C[group] then
			local changeCount = 0

			for option, value in pairs(options) do
				if C[group][option] ~= nil then
					if C[group][option] == value then
						Settings[group][option] = nil -- REASON: Value matches default, remove from DB.
					else
						changeCount = changeCount + 1
						C[group][option] = value -- REASON: Overwrite Config with Saved value.
					end
				end
			end

			-- REASON: Clean up empty groups to prevent clutter.
			if changeCount == 0 then
				Settings[group] = nil
			end
		else
			-- REASON: Clean up groups that no longer exist in Config.
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

	-- REASON: Explicitly handle booleans for nil protection.
	if KkthnxUIDB.ShowSlots == nil then
		KkthnxUIDB.ShowSlots = false
	end

	-- 6) Versioning & Changelogs
	-- REASON: Ensure these exist in the schema, even if eventually nil.
	KkthnxUIDB.ChangelogVersion = KkthnxUIDB.ChangelogVersion or nil
	KkthnxUIDB.DetectedVersion = KkthnxUIDB.DetectedVersion or nil

	-- REASON: Ensure this is a boolean false if nil.
	KkthnxUIDB.ChangelogHighlightLatest = KkthnxUIDB.ChangelogHighlightLatest or false
end

-- ---------------------------------------------------------------------------
-- MODULE MANAGEMENT
-- ---------------------------------------------------------------------------

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
	-- REASON: Prefer checking the nested table structure if it exists.
	if K.GUI and K.GUI.GUI and type(K.GUI.GUI.Enable) == "function" then
		K.GUI.GUI:Enable()
	elseif K.GUI and type(K.GUI.Enable) == "function" then
		K.GUI:Enable()
	end

	-- 2) Enable ExtraGUI and attach Cogwheels
	if K.ExtraGUI and type(K.ExtraGUI.Enable) == "function" then
		K.ExtraGUI:Enable()

		-- REASON: Attach Cogwheels Logic.
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

-- ---------------------------------------------------------------------------
-- EVENT HANDLER
-- ---------------------------------------------------------------------------

local function KKUI_OnEvent(self, event, arg1)
	if event == "ADDON_LOADED" and arg1 == "KkthnxUI" then
		local startTime
		if K.isDeveloper then
			startTime = debugprofilestop()
		end

		-- REASON: Initialize Database.
		KKUI_VerifyDatabase()
		KKUI_CreateDefaults()
		KKUI_LoadCustomSettings()

		-- REASON: Setup initial scaling.
		if K.SetupUIScale then
			K:SetupUIScale(true)
		end

		if K.isDeveloper and startTime then
			local duration = debugprofilestop() - startTime
			K.Print(string_format("[KKUI_DEV] ADDON_LOADED processing in %.3f ms", duration))
		end

		self:UnregisterEvent("ADDON_LOADED")
	elseif event == "PLAYER_LOGIN" then
		-- REASON: Enable modules when player is ready.
		KKUI_EnableModulesOnce()
		self:UnregisterEvent("PLAYER_LOGIN")
	elseif event == "PLAYER_ENTERING_WORLD" then
		-- REASON: Handle timestamp updates.
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

-- REASON: Register Events.
KKUI_AddonLoader:RegisterEvent("ADDON_LOADED")
KKUI_AddonLoader:RegisterEvent("PLAYER_LOGIN")
KKUI_AddonLoader:RegisterEvent("PLAYER_ENTERING_WORLD")
KKUI_AddonLoader:SetScript("OnEvent", KKUI_OnEvent)
