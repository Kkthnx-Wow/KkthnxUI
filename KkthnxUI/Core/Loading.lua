local K, C = KkthnxUI[1], KkthnxUI[2]
local KKUI_AddonLoader = CreateFrame("Frame")

local function createProfileName(server, nickname)
	return table.concat({ server, nickname }, "-")
end

local function KKUI_VerifyDatabase()
	local db = KkthnxUIDB or {}
	KkthnxUIDB = db

	local variables = db.Variables or {}
	db.Variables = variables

	local realmData = variables[K.Realm] or {}
	variables[K.Realm] = realmData

	local charData = realmData[K.Name] or {}
	realmData[K.Name] = charData

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
	charData.AutoDeposit = charData.AutoDeposit or false
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

	local settings = db.Settings or {}
	db.Settings = settings

	local realmSettings = settings[K.Realm] or {}
	settings[K.Realm] = realmSettings

	realmSettings[K.Name] = realmSettings[K.Name] or {}

	db.ChatHistory = db.ChatHistory or {}
	db.Gold = db.Gold or {}
	db.ShowSlots = db.ShowSlots or false
	db.ChangeLog = db.ChangeLog or {}
	db.KeystoneInfo = db.KeystoneInfo or {}
	db.DisabledAddOns = db.DisabledAddOns or {}
end

local function KKUI_CreateDefaults()
	K.Defaults = {}

	for group, options in pairs(C) do
		if type(options) == "table" then
			K.Defaults[group] = {}

			for option, value in pairs(options) do
				local defaultValue = type(value) == "table" and value.Options and value.Value or value
				K.Defaults[group][option] = defaultValue
			end
		end
	end
end

local function KKUI_LoadCustomSettings()
	local settings = KkthnxUIDB.Settings[K.Realm] and KkthnxUIDB.Settings[K.Realm][K.Name]
	if type(settings) ~= "table" then
		return
	end

	for group, options in pairs(settings) do
		local count = 0
		for option, value in pairs(options) do
			if C[group] and C[group][option] ~= nil then
				if C[group][option] == value then
					options[option] = nil
				else
					count = count + 1
					if type(C[group][option]) == "table" and C[group][option].Options then
						C[group][option].Value = value
					else
						C[group][option] = value
					end
				end
			end
		end

		if count == 0 then
			settings[group] = nil
		end
	end
end

local function KKUI_LoadProfiles()
	local profiles = C["General"].Profiles
	local menu = profiles.Options
	local guiSettings = KkthnxUIDB.Settings

	if not guiSettings then
		return
	end

	local myProfileName = createProfileName(K.Realm, K.Name)

	for server, table in pairs(guiSettings) do
		for nickname in pairs(table) do
			local profileName = createProfileName(server, nickname)
			if profileName ~= myProfileName then
				menu[profileName] = profileName
			end
		end
	end
end
K.LoadProfiles = KKUI_LoadProfiles

local function KKUI_LoadVariables()
	KKUI_CreateDefaults()
	KKUI_LoadProfiles()
	KKUI_LoadCustomSettings()

	K.GUI:Enable()
	K.Profiles:Enable()
end

local function KKUI_LoadAddon()
	K.SetupUIScale(true)
	KKUI_AddonLoader:UnregisterEvent("ADDON_LOADED")
end

local function KKUI_OnEvent(_, event, addonName)
	if event == "VARIABLES_LOADED" then
		KKUI_VerifyDatabase()
		KKUI_LoadVariables()
	elseif event == "ADDON_LOADED" and addonName == "KkthnxUI" then
		KKUI_LoadAddon()
	end

	if EditModeManagerFrame then
		EditModeManagerFrame:UnregisterAllEvents()
		EditModeManagerFrame:RegisterEvent("EDIT_MODE_LAYOUTS_UPDATED")
	end
end

KKUI_AddonLoader:RegisterEvent("ADDON_LOADED")
KKUI_AddonLoader:RegisterEvent("VARIABLES_LOADED")
KKUI_AddonLoader:SetScript("OnEvent", KKUI_OnEvent)
