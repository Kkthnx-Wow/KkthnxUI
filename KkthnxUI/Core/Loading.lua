local K, C = KkthnxUI[1], KkthnxUI[2]

local function createProfileName(server, nickname)
	return table.concat({ server, nickname }, "-")
end

local function KKUI_VerifyDatabase()
	if type(KkthnxUIDB) ~= "table" then
		KkthnxUIDB = { Variables = {} }
	end

	local realmData = type(KkthnxUIDB.Variables) == "table" and KkthnxUIDB.Variables[K.Realm] or {}
	local charData = type(realmData) == "table" and realmData[K.Name] or {
		AuraWatchList = { Switcher = {}, IgnoreSpells = {} },
		AuraWatchMover = {},
		AutoQuest = false,
		AutoQuestIgnoreNPC = {},
		BindType = 1,
		CustomItems = {},
		CustomJunkList = {},
		CustomNames = {},
		DisabledAddOns = {},
		InternalCD = {},
		Mover = {},
		RevealWorldMap = false,
		SplitCount = 1,
		TempAnchor = {},
		Tracking = { PvP = {}, PvE = {} },
	}
	KkthnxUIDB.Variables[K.Realm] = realmData
	realmData[K.Name] = charData

	-- Transfer favourite items logic
	if KkthnxUIDB and charData.FavouriteItems and next(charData.FavouriteItems) then
		charData.CustomItems = charData.CustomItems or {}
		for itemID in pairs(charData.FavouriteItems) do
			charData.CustomItems[itemID] = 1
		end
		charData.FavouriteItems = nil
	end

	-- Initialize other settings and data structures
	KkthnxUIDB.Settings = KkthnxUIDB.Settings or {}
	KkthnxUIDB.Settings[K.Realm] = KkthnxUIDB.Settings[K.Realm] or {}
	KkthnxUIDB.Settings[K.Realm][K.Name] = KkthnxUIDB.Settings[K.Realm][K.Name] or {}

	KkthnxUIDB.ChatHistory = KkthnxUIDB.ChatHistory or {}
	KkthnxUIDB.Gold = KkthnxUIDB.Gold or {}
	KkthnxUIDB.Deaths = KkthnxUIDB.Deaths or {}
	KkthnxUIDB.ShowSlots = KkthnxUIDB.ShowSlots or false
	KkthnxUIDB.ChangeLog = KkthnxUIDB.ChangeLog or {}
	KkthnxUIDB.DetectVersion = KkthnxUIDB.DetectVersion or K.Version
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
	local Settings = KkthnxUIDB.Settings[K.Realm] and KkthnxUIDB.Settings[K.Realm][K.Name]

	if type(Settings) ~= "table" then
		return
	end

	for group, options in pairs(Settings or {}) do
		local Count = 0

		for option, value in pairs(options) do
			if C[group] and C[group][option] ~= nil then
				if C[group][option] == value then
					Settings[group][option] = nil
				else
					Count = Count + 1

					if type(C[group][option]) == "table" and C[group][option].Options then
						C[group][option].Value = value
					else
						C[group][option] = value
					end
				end
			end
		end

		if Count == 0 then
			Settings[group] = nil
		end
	end
end

local function KKUI_LoadProfiles()
	local Profiles = C["General"].Profiles
	local Menu = Profiles.Options
	local GUISettings = KkthnxUIDB.Settings

	if not GUISettings then
		return
	end

	for Server, Table in pairs(GUISettings) do
		for Nickname in pairs(Table) do
			local ProfileName = createProfileName(Server, Nickname)
			local MyProfileName = createProfileName(K.Realm, K.Name)

			if MyProfileName ~= ProfileName then
				Menu[ProfileName] = ProfileName
			end
		end
	end
end

local KKUI_AddonLoader = CreateFrame("Frame")
KKUI_AddonLoader:RegisterEvent("ADDON_LOADED")
KKUI_AddonLoader:SetScript("OnEvent", function(self, _, addon)
	if addon ~= "KkthnxUI" then
		return
	end

	KKUI_VerifyDatabase()
	KKUI_CreateDefaults()
	KKUI_LoadProfiles()
	KKUI_LoadCustomSettings()

	K.GUI:Enable()
	K.Profiles:Enable()
	K.SetupUIScale(true)

	self:UnregisterAllEvents()
end)
