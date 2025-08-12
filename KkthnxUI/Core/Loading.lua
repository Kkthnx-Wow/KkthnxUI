local K, C = KkthnxUI[1], KkthnxUI[2]
local KKUI_AddonLoader = CreateFrame("Frame")

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

	if charData.FavouriteItems then
		local customItems = charData.CustomItems
		for itemID in pairs(charData.FavouriteItems) do
			customItems[itemID] = 1
		end
		charData.FavouriteItems = nil
	end

	KkthnxUIDB.Settings = KkthnxUIDB.Settings or {}
	KkthnxUIDB.Settings[K.Realm] = KkthnxUIDB.Settings[K.Realm] or {}
	KkthnxUIDB.Settings[K.Realm][K.Name] = KkthnxUIDB.Settings[K.Realm][K.Name] or {}

	KkthnxUIDB.ChatHistory = KkthnxUIDB.ChatHistory or {}
	KkthnxUIDB.Gold = KkthnxUIDB.Gold or {}
	KkthnxUIDB.ProfilePortraits = KkthnxUIDB.ProfilePortraits or {}
	KkthnxUIDB.ShowSlots = KkthnxUIDB.ShowSlots or false
	KkthnxUIDB.ChangeLog = KkthnxUIDB.ChangeLog or {}
	KkthnxUIDB.KeystoneInfo = KkthnxUIDB.KeystoneInfo or {}
	KkthnxUIDB.DisabledAddOns = KkthnxUIDB.DisabledAddOns or {}
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

	-- ExtraGUI (provides additional config functionality)
	if K.ExtraGUI then
		-- K.ExtraGUI:Enable()
	end

	-- Main GUI system second (provides core configuration)
	if K.NewGUI then
		-- K.NewGUI:Enable()
	end

	-- ProfileGUI last (depends on main GUI being available)
	if K.ProfileGUI then
		-- K.ProfileGUI:Enable()
	end
end

local function KKUI_OnEvent(_, event, addonName)
	if event == "ADDON_LOADED" and addonName == "KkthnxUI" then
		-- Add error handling to prevent crashes during loading
		local success, err = pcall(function()
			KKUI_VerifyDatabase()
			KKUI_LoadVariables()
			K:SetupUIScale(true)
		end)

		if not success then
			print("|cffFF0000KkthnxUI ERROR:|r Critical error during loading: " .. tostring(err))
			print("|cffFF0000KkthnxUI ERROR:|r Please check your installation and try again.")
		end

		KKUI_AddonLoader:UnregisterEvent("ADDON_LOADED")
	end
end

KKUI_AddonLoader:RegisterEvent("ADDON_LOADED")
KKUI_AddonLoader:SetScript("OnEvent", KKUI_OnEvent)
