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

local CURRENT_SCHEMA_VERSION = 1

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

local function DeepEqual(left, right)
	if left == right then
		return true
	end

	local leftType, rightType = type(left), type(right)
	if leftType ~= rightType then
		return false
	end

	if leftType ~= "table" then
		return false
	end

	for key, value in pairs(left) do
		if not DeepEqual(value, right[key]) then
			return false
		end
	end

	for key in pairs(right) do
		if left[key] == nil then
			return false
		end
	end

	return true
end

local schemaMigrations = {
	[1] = function()
		for _, realmData in pairs(KkthnxUIDB.Settings) do
			if type(realmData) == "table" then
				for _, settings in pairs(realmData) do
					if type(settings) == "table" then
						local automation = settings.Automation
						if automation and automation.AutoSkipCinematic ~= nil and automation.ConfirmCinematicSkip == nil then
							automation.ConfirmCinematicSkip = automation.AutoSkipCinematic
							automation.AutoSkipCinematic = nil
						end
					end
				end
			end
		end
	end,
}

local function KKUI_RunDatabaseMigrations()
	local version = KkthnxUIDB.SchemaVersion or 0
	if version >= CURRENT_SCHEMA_VERSION then
		return
	end

	for targetVersion = version + 1, CURRENT_SCHEMA_VERSION do
		local migration = schemaMigrations[targetVersion]
		if migration then
			migration()
		end
	end

	KkthnxUIDB.SchemaVersion = CURRENT_SCHEMA_VERSION
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
	local removeGroups = {}

	-- REASON: Delta processing keeps the database small by pruning values that match defaults.
	for group, options in pairs(Settings) do
		local defaults = C[group]
		if defaults and type(options) == "table" then
			local changeCount = 0
			local removeOptions = {}

			for option, value in pairs(options) do
				local defaultValue = defaults[option]
				if defaultValue ~= nil then
					if DeepEqual(defaultValue, value) then
						removeOptions[#removeOptions + 1] = option
					else
						changeCount = changeCount + 1
						-- Copy table settings so runtime config changes cannot mutate SavedVariables by reference.
						if type(value) == "table" then
							defaults[option] = DeepCopy(value)
						else
							defaults[option] = value
						end
					end
				else
					removeOptions[#removeOptions + 1] = option
				end
			end

			for i = 1, #removeOptions do
				options[removeOptions[i]] = nil
			end

			if changeCount == 0 then
				removeGroups[#removeGroups + 1] = group
			end
		else
			removeGroups[#removeGroups + 1] = group
		end
	end

	for i = 1, #removeGroups do
		Settings[removeGroups[i]] = nil
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
	KkthnxUIDB.SchemaVersion = KkthnxUIDB.SchemaVersion or 0

	-- REASON: Explicitly handle booleans for nil protection.
	if KkthnxUIDB.ShowSlots == nil then
		KkthnxUIDB.ShowSlots = false
	end

	-- 6) Versioning & Changelogs
	-- NOTE: These fields are managed externally; no initialization needed here.

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
		KKUI_RunDatabaseMigrations()
		KKUI_CreateDefaults()
		KKUI_LoadCustomSettings()

		-- TEMPORARY (Midnight 12.0): force-disable AuraWatch, the Swing timer, and
		-- floating CombatText regardless of the saved profile while their secret-value
		-- handling is being reworked. Applied after settings load so it overrides the
		-- profile; remove this block to restore the user's configured values.
		if C["AuraWatch"] then
			C["AuraWatch"].Enable = false
		end
		if C["Unitframe"] then
			C["Unitframe"].CombatText = false
			C["Unitframe"].PetCombatText = false
			C["Unitframe"].SwingBar = false
		end

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
