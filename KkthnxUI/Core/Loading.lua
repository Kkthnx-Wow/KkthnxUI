local K, C = KkthnxUI[1], KkthnxUI[2]

local function createProfileName(server, nickname)
	return server .. "-" .. nickname
end

local function KKUI_VerifyDatabase()
	if not KkthnxUIDB then
		KkthnxUIDB = { Variables = {} }
	end

	local charData = KkthnxUIDB.Variables[K.Realm] and KkthnxUIDB.Variables[K.Realm][K.Name]
	if not charData then
		charData = {
			AutoQuest = false,
			AutoQuestIgnoreNPC = {},
			BindType = 1,
			CustomItems = {},
			CustomNames = {},
			CustomJunkList = {},
			Mover = {},
			AuraWatchMover = {},
			Tracking = { PvP = {}, PvE = {} },
			RevealWorldMap = false,
			SplitCount = 1,
			TempAnchor = {},
			InternalCD = {},
			AuraWatchList = {
				Switcher = {},
				IgnoreSpells = {},
			},
		}
		KkthnxUIDB.Variables[K.Realm] = KkthnxUIDB.Variables[K.Realm] or {}
		KkthnxUIDB.Variables[K.Realm][K.Name] = charData
	end

	-- Transfer favourite items since we made a custom filter
	if KkthnxUIDB and charData.FavouriteItems and next(charData.FavouriteItems) then
		charData.CustomItems = charData.CustomItems or {}
		for itemID in pairs(charData.FavouriteItems) do
			charData.CustomItems[itemID] = 1
		end
		charData.FavouriteItems = nil
	end

	-- Settings
	KkthnxUIDB.Settings = KkthnxUIDB.Settings or {}
	KkthnxUIDB.Settings[K.Realm] = KkthnxUIDB.Settings[K.Realm] or {}
	KkthnxUIDB.Settings[K.Realm][K.Name] = KkthnxUIDB.Settings[K.Realm][K.Name] or {}

	KkthnxUIDB.ChatHistory = KkthnxUIDB.ChatHistory or {}
	KkthnxUIDB.Gold = KkthnxUIDB.Gold or {}
	KkthnxUIDB.Deaths = KkthnxUIDB.Deaths or {}
	KkthnxUIDB.ShowSlots = KkthnxUIDB.ShowSlots or false
	KkthnxUIDB.ChangeLog = KkthnxUIDB.ChangeLog or {}
	KkthnxUIDB.DetectVersion = KkthnxUIDB.DetectVersion or K.Version or nil
	KkthnxUIDB.KeystoneInfo = KkthnxUIDB.KeystoneInfo or {}
end

local function KKUI_CreateDefaults()
	K.Defaults = {}

	for group, options in pairs(C) do
		K.Defaults[group] = {}

		for option, value in pairs(options) do
			local defaultValue = value
			if type(value) == "table" and value.Options then
				defaultValue = value.Value
			end

			K.Defaults[group][option] = defaultValue
		end
	end
end

local function KKUI_LoadCustomSettings()
	local Settings = KkthnxUIDB.Settings[K.Realm] and KkthnxUIDB.Settings[K.Realm][K.Name]

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
			local MyProfileName = K.Realm .. "-" .. K.Name

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
