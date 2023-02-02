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

local function createProfileName(server, nickname)
	return server .. "-" .. nickname
end

local function KKUI_LoadProfiles()
	-- Load the `Profiles` table and `Options` menu from the "General" table
	local Profiles = C["General"].Profiles
	local Menu = Profiles.Options

	-- Load the `GUISettings` table from `KkthnxUIDB.Settings`
	local GUISettings = KkthnxUIDB.Settings

	-- Return if `GUISettings` is not found
	if not GUISettings then
		return
	end

	-- Loop through each server and its table in `GUISettings`
	for Server, Table in pairs(GUISettings) do
		-- Loop through each nickname in the table
		for Nickname in pairs(Table) do
			-- Create a profile name from the server and nickname
			local ProfileName = createProfileName(Server, Nickname)

			-- Get the current profile name
			local MyProfileName = K.Realm .. "-" .. K.Name

			-- If the current profile name is different from the new profile name
			if MyProfileName ~= ProfileName then
				-- Add the new profile name to the menu
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

	local charData = KkthnxUIDB.Variables[K.Realm][K.Name]
	charData.AutoQuest = charData.AutoQuest or false
	charData.AutoQuestIgnoreNPC = charData.AutoQuestIgnoreNPC or {}
	charData.BindType = charData.BindType or 1

	-- Transfer favourite items since we made a custom filter
	if KkthnxUIDB and KkthnxUIDB.Variables and charData.FavouriteItems and next(charData.FavouriteItems) then
		for itemID in pairs(charData.FavouriteItems) do
			if not charData.CustomItems then
				charData.CustomItems = {}
			end
			charData.CustomItems[itemID] = 1
		end
		charData.FavouriteItems = nil
	end

	charData.CustomItems = charData.CustomItems or {}
	charData.CustomNames = charData.CustomNames or {}
	charData.CustomJunkList = charData.CustomJunkList or {}
	charData.Mover = charData.Mover or {}
	charData.AuraWatchMover = charData.AuraWatchMover or {}
	charData.Tracking = charData.Tracking or { PvP = {}, PvE = {} }
	charData.RevealWorldMap = charData.RevealWorldMap or false
	charData.SplitCount = charData.SplitCount or 1
	charData.TempAnchor = charData.TempAnchor or {}
	charData.InternalCD = charData.InternalCD or {}
	charData.AuraWatchList = charData.AuraWatchList or {}
	charData.AuraWatchList.Switcher = charData.AuraWatchList.Switcher or {}
	charData.AuraWatchList.IgnoreSpells = charData.AuraWatchList.IgnoreSpells or {}

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
