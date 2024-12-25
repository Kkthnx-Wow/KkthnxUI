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

	KkthnxUIDB.Settings = KkthnxUIDB.Settings or {}
	KkthnxUIDB.Settings[K.Realm] = KkthnxUIDB.Settings[K.Realm] or {}
	KkthnxUIDB.Settings[K.Realm][K.Name] = KkthnxUIDB.Settings[K.Realm][K.Name] or {}

	KkthnxUIDB.ChatHistory = KkthnxUIDB.ChatHistory or {}
	KkthnxUIDB.Gold = KkthnxUIDB.Gold or {}
	KkthnxUIDB.ShowSlots = KkthnxUIDB.ShowSlots or false
	KkthnxUIDB.ChangeLog = KkthnxUIDB.ChangeLog or {}
	KkthnxUIDB.KeystoneInfo = KkthnxUIDB.KeystoneInfo or {}
	KkthnxUIDB.DisabledAddOns = KkthnxUIDB.DisabledAddOns or {}
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
	local Profiles = C["General"].Profiles
	local Menu = Profiles.Options
	local Data = KkthnxUIDB.Variables
	local GUISettings = KkthnxUIDB.Settings
	local Nickname = K.Name
	local Server = K.Realm

	if not GUISettings then
		return
	end

	for Index, Table in pairs(GUISettings) do
		local Server = Index

		for Nickname, Settings in pairs(Table) do
			local ProfileName = Server .. "-" .. Nickname
			local MyProfileName = K.Realm .. "-" .. K.Name

			if MyProfileName ~= ProfileName then
				Menu[ProfileName] = ProfileName
			end
		end
	end
end

local function KKUI_LoadVariables()
	KKUI_CreateDefaults()
	KKUI_LoadProfiles()
	KKUI_LoadCustomSettings()
	K.GUI:Enable()
	K.Profiles:Enable()
end

local function KKUI_OnEvent(_, event, addonName)
	if event == "ADDON_LOADED" and addonName == "KkthnxUI" then
		KKUI_VerifyDatabase()
		KKUI_LoadVariables()
		K:SetupUIScale(true)
		KKUI_AddonLoader:UnregisterEvent("ADDON_LOADED")
	end
end

KKUI_AddonLoader:RegisterEvent("ADDON_LOADED")
KKUI_AddonLoader:SetScript("OnEvent", KKUI_OnEvent)
