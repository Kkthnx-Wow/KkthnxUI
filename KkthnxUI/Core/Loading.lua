local K, C = KkthnxUI[1], KkthnxUI[2]
local KKUI_AddonLoader = CreateFrame("Frame")
local KKUI_ModulesEnabled = false
local pcall = pcall
local pairs = pairs
local print = print
local debugprofilestop = debugprofilestop

local function KKUI_EnableModulesOnce()
	local t0
	if K.isDeveloper then
		t0 = debugprofilestop()
	end
	if KKUI_ModulesEnabled then
		return
	end
	KKUI_ModulesEnabled = true

	-- 1) Main GUI
	if K.GUI and K.GUI.GUI and K.GUI.GUI.Enable then
		pcall(function()
			K.GUI.GUI:Enable()
		end)
	elseif K.GUI and K.GUI.Enable then
		pcall(function()
			K.GUI:Enable()
		end)
	end

	-- 2) ExtraGUI
	if K.ExtraGUI and K.ExtraGUI.Enable then
		local ok = pcall(function()
			K.ExtraGUI:Enable()
		end)
		if ok and K.GUI and K.GUI.AttachExtraCogwheels then
			pcall(function()
				K.GUI:AttachExtraCogwheels()
			end)
		elseif ok and K.GUI and K.GUI.GUI and K.GUI.GUI.AttachExtraCogwheels then
			pcall(function()
				K.GUI.GUI:AttachExtraCogwheels()
			end)
		end
	end

	-- 3) ProfileGUI
	if K.ProfileGUI and K.ProfileGUI.Enable then
		pcall(function()
			K.ProfileGUI:Enable()
		end)
	end

	if K.isDeveloper and t0 then
		local dt = debugprofilestop() - t0
		K.Print(string.format("[KKUI_DEV] EnableModulesOnce %.3f ms", dt))
	end
end

local function KKUI_VerifyDatabase()
	KkthnxUIDB = KkthnxUIDB or {}
	KkthnxUIDB.Variables = KkthnxUIDB.Variables or {}
	KkthnxUIDB.Variables[K.Realm] = KkthnxUIDB.Variables[K.Realm] or {}
	KkthnxUIDB.Variables[K.Realm][K.Name] = KkthnxUIDB.Variables[K.Realm][K.Name] or {}

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
	charData.QueueTimer = charData.QueueTimer or { PVEPopTime = {}, PVEQueuedTime = {} }

	KkthnxUIDB.Settings = KkthnxUIDB.Settings or {}
	KkthnxUIDB.Settings[K.Realm] = KkthnxUIDB.Settings[K.Realm] or {}
	KkthnxUIDB.Settings[K.Realm][K.Name] = KkthnxUIDB.Settings[K.Realm][K.Name] or {}

	KkthnxUIDB.ChatHistory = KkthnxUIDB.ChatHistory or {}
	KkthnxUIDB.Gold = KkthnxUIDB.Gold or {}
	KkthnxUIDB.ProfilePortraits = KkthnxUIDB.ProfilePortraits or {}
	KkthnxUIDB.ShowSlots = KkthnxUIDB.ShowSlots or false
	KkthnxUIDB.KeystoneInfo = KkthnxUIDB.KeystoneInfo or {}
	KkthnxUIDB.DisabledAddOns = KkthnxUIDB.DisabledAddOns or {}
	KkthnxUIDB.ChangelogVersion = KkthnxUIDB.ChangelogVersion or nil
	KkthnxUIDB.ChangelogHighlightLatest = KkthnxUIDB.ChangelogHighlightLatest or false
	KkthnxUIDB.DetectedVersion = KkthnxUIDB.DetectedVersion or nil
end

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

	-- Migration: Automation.AutoSkipCinematic -> Automation.ConfirmCinematicSkip
	if Settings and Settings.Automation then
		local s = Settings.Automation
		if s.AutoSkipCinematic ~= nil and Settings.Automation.ConfirmCinematicSkip == nil then
			Settings.Automation.ConfirmCinematicSkip = s.AutoSkipCinematic
			s.AutoSkipCinematic = nil
		end
	end

	for group, options in pairs(Settings) do
		if C[group] then
			local Count = 0

			for option, value in pairs(options) do
				if C[group][option] ~= nil then
					if C[group][option] == value then
						Settings[group][option] = nil
					else
						Count = Count + 1
						C[group][option] = value
					end
				end
			end

			-- Keeps settings clean and small
			if Count == 0 then
				Settings[group] = nil
			end
		else
			Settings[group] = nil
		end
	end
end

local function KKUI_LoadVariables()
	KKUI_CreateDefaults()
	KKUI_LoadCustomSettings()
end

local function KKUI_OnEvent(_, event, addonName)
	if event == "ADDON_LOADED" and addonName == "KkthnxUI" then
		local t0
		if K.isDeveloper then
			t0 = debugprofilestop()
		end
		local success, err = pcall(function()
			KKUI_VerifyDatabase()
			KKUI_LoadVariables()
			K:SetupUIScale(true)

			-- Initialize subsystems once
			KKUI_EnableModulesOnce()
		end)

		if not success then
			print("|cffFF0000KkthnxUI ERROR:|r Critical error during loading: " .. tostring(err))
			print("|cffFF0000KkthnxUI ERROR:|r Please check your installation and try again.")
		elseif K.isDeveloper and t0 then
			local dt = debugprofilestop() - t0
			K.Print(string.format("[KKUI_DEV] ADDON_LOADED %.3f ms", dt))
		end
	elseif event == "PLAYER_LOGIN" then
		-- Ensure subsystems are enabled exactly once
		KKUI_EnableModulesOnce()

		-- Use a wrapper to avoid passing a potentially nil function reference at load time
		K:RegisterEvent("PLAYER_ENTERING_WORLD", function()
			if K.UpdateProfileTimestamp then
				K.UpdateProfileTimestamp()
			else
				-- Soft log to help diagnose load-order issues; this will run once at PEW
				print("|cffff9900KkthnxUI:|r UpdateProfileTimestamp not ready at PLAYER_ENTERING_WORLD")
			end
		end)
		K:UnregisterEvent(event, KKUI_OnEvent)
	end
end

KKUI_AddonLoader:RegisterEvent("ADDON_LOADED")
KKUI_AddonLoader:RegisterEvent("PLAYER_LOGIN")
KKUI_AddonLoader:SetScript("OnEvent", KKUI_OnEvent)
