local K, C = unpack(KkthnxUI)

local function KKUI_CreateDefaults()
	K.Defaults = {}
	-- loop through the config table
	for group, options in pairs(C) do
		-- create a new table for the group if it doesn't exist
		if not K.Defaults[group] then
			K.Defaults[group] = {}
		end

		-- loop through the options in the group
		for option, value in pairs(options) do
			-- save the option's default value in the defaults table
			K.Defaults[group][option] = value

			-- check if the option is a table and has an 'Options' field
			if type(C[group][option]) == "table" then
				if C[group][option].Options then
					K.Defaults[group][option] = value.Value
				else
					K.Defaults[group][option] = value
				end
			else
				K.Defaults[group][option] = value
			end
		end
	end
end

local function KKUI_LoadCustomSettings()
	local Settings = KkthnxUIDB.Settings[K.Realm][K.Name]

	for group, options in pairs(Settings) do
		if C[group] then
			local Count = 0

			-- Iterate through each option and value in the group
			for option, value in pairs(options) do
				if C[group][option] ~= nil then
					-- Check if the current option is already set to the same value
					if C[group][option] == value then
						Settings[group][option] = nil
					else
						Count = Count + 1

						if type(C[group][option]) == "table" then
							if C[group][option].Options then
								C[group][option].Value = value
							else
								C[group][option] = value
							end
						else
							C[group][option] = value
						end
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

-- Create the profile name
-- @param server the name of the server
-- @param nickname the nickname of the player
-- @return the profile name
local function createProfileName(server, nickname)
	return server .. "-" .. nickname
end

-- Load profiles for the user interface
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

local function KKUI_VerifyDatabase()
	if not KkthnxUIDB then
		KkthnxUIDB = {}
	end

	KkthnxUIDB.Variables = KkthnxUIDB.Variables or {}
	KkthnxUIDB.Variables[K.Realm] = KkthnxUIDB.Variables[K.Realm] or {}
	KkthnxUIDB.Variables[K.Realm][K.Name] = KkthnxUIDB.Variables[K.Realm][K.Name] or {}
	KkthnxUIDB.Variables[K.Realm][K.Name].AutoQuest = KkthnxUIDB.Variables[K.Realm][K.Name].AutoQuest or false
	KkthnxUIDB.Variables[K.Realm][K.Name].AutoQuestIgnoreNPC = KkthnxUIDB.Variables[K.Realm][K.Name].AutoQuestIgnoreNPC or {}
	KkthnxUIDB.Variables[K.Realm][K.Name].BindType = KkthnxUIDB.Variables[K.Realm][K.Name].BindType or 1

	-- Transfer favourite items since we made a custom filter
	if KkthnxUIDB and KkthnxUIDB.Variables and KkthnxUIDB.Variables[K.Realm][K.Name].FavouriteItems and next(KkthnxUIDB.Variables[K.Realm][K.Name].FavouriteItems) then
		for itemID in pairs(KkthnxUIDB.Variables[K.Realm][K.Name].FavouriteItems) do
			if not KkthnxUIDB.Variables[K.Realm][K.Name].CustomItems then
				KkthnxUIDB.Variables[K.Realm][K.Name].CustomItems = {}
			end
			KkthnxUIDB.Variables[K.Realm][K.Name].CustomItems[itemID] = 1
		end
		KkthnxUIDB.Variables[K.Realm][K.Name].FavouriteItems = nil
	end

	KkthnxUIDB.Variables[K.Realm][K.Name].CustomItems = KkthnxUIDB.Variables[K.Realm][K.Name].CustomItems or {}
	KkthnxUIDB.Variables[K.Realm][K.Name].CustomNames = KkthnxUIDB.Variables[K.Realm][K.Name].CustomNames or {}
	KkthnxUIDB.Variables[K.Realm][K.Name].CustomJunkList = KkthnxUIDB.Variables[K.Realm][K.Name].CustomJunkList or {}
	KkthnxUIDB.Variables[K.Realm][K.Name].Mover = KkthnxUIDB.Variables[K.Realm][K.Name].Mover or {}
	KkthnxUIDB.Variables[K.Realm][K.Name].AuraWatchMover = KkthnxUIDB.Variables[K.Realm][K.Name].AuraWatchMover or {}
	KkthnxUIDB.Variables[K.Realm][K.Name].Tracking = KkthnxUIDB.Variables[K.Realm][K.Name].Tracking or { PvP = {}, PvE = {} }
	KkthnxUIDB.Variables[K.Realm][K.Name].RevealWorldMap = KkthnxUIDB.Variables[K.Realm][K.Name].RevealWorldMap or false
	KkthnxUIDB.Variables[K.Realm][K.Name].SplitCount = KkthnxUIDB.Variables[K.Realm][K.Name].SplitCount or 1
	KkthnxUIDB.Variables[K.Realm][K.Name].TempAnchor = KkthnxUIDB.Variables[K.Realm][K.Name].TempAnchor or {}
	KkthnxUIDB.Variables[K.Realm][K.Name].InternalCD = KkthnxUIDB.Variables[K.Realm][K.Name].InternalCD or {}
	KkthnxUIDB.Variables[K.Realm][K.Name].AuraWatchList = KkthnxUIDB.Variables[K.Realm][K.Name].AuraWatchList or {}
	KkthnxUIDB.Variables[K.Realm][K.Name].AuraWatchList.Switcher = KkthnxUIDB.Variables[K.Realm][K.Name].AuraWatchList.Switcher or {}
	KkthnxUIDB.Variables[K.Realm][K.Name].AuraWatchList.IgnoreSpells = KkthnxUIDB.Variables[K.Realm][K.Name].AuraWatchList.IgnoreSpells or {}

	-- Settings
	KkthnxUIDB.Settings = KkthnxUIDB.Settings or {}
	KkthnxUIDB.Settings[K.Realm] = KkthnxUIDB.Settings[K.Realm] or {}
	KkthnxUIDB.Settings[K.Realm][K.Name] = KkthnxUIDB.Settings[K.Realm][K.Name] or {}
	KkthnxUIDB.ChatHistory = KkthnxUIDB.ChatHistory or {}
	KkthnxUIDB.Gold = KkthnxUIDB.Gold or {}
	KkthnxUIDB.ShowSlots = KkthnxUIDB.ShowSlots or false
	KkthnxUIDB.ChangeLog = KkthnxUIDB.ChangeLog or {}
	KkthnxUIDB.DetectVersion = KkthnxUIDB.DetectVersion or K.Version
	KkthnxUIDB.KeystoneInfo = KkthnxUIDB.KeystoneInfo or {}
	KkthnxUIDB.FeastTime = KkthnxUIDB.FeastTime or 0
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
