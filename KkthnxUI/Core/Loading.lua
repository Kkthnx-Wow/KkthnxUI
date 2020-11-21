local K, C = unpack(select(2, ...))

local function KKUI_CreateDefaults()
	K.Defaults = {}

	for group, options in pairs(C) do
		if (not K.Defaults[group]) then
			K.Defaults[group] = {}
		end

		for option, value in pairs(options) do
			K.Defaults[group][option] = value

			if (type(C[group][option]) == "table") then
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
	local Settings

	if (not KkthnxUISettingsPerCharacter) then
		KkthnxUISettingsPerCharacter = {}
	end

	if (not KkthnxUISettingsPerCharacter[K.Realm]) then
		KkthnxUISettingsPerCharacter[K.Realm] = {}
	end

	if (not KkthnxUISettingsPerCharacter[K.Realm][K.Name]) then
		KkthnxUISettingsPerCharacter[K.Realm][K.Name] = {}
	end

	if not KkthnxUISettings then
		KkthnxUISettings = {}
	end

	-- Globals settings will be removed in the next coming weeks, if currently using globals, move into current character profile
	if KkthnxUISettingsPerCharacter[K.Realm][K.Name].General and KkthnxUISettingsPerCharacter[K.Realm][K.Name].General.UseGlobal == true then
		KkthnxUISettingsPerCharacter[K.Realm][K.Name] = KkthnxUISettings

		if KkthnxUISettingsPerCharacter[K.Realm][K.Name].General then
			KkthnxUISettingsPerCharacter[K.Realm][K.Name].General.UseGlobal = false
		end
	end

	Settings = KkthnxUISettingsPerCharacter[K.Realm][K.Name]
	for group, options in pairs(Settings) do
		if C[group] then
			local Count = 0

			for option, value in pairs(options) do
				if (C[group][option] ~= nil) then
					if (C[group][option] == value) then
						Settings[group][option] = nil
					else
						Count = Count + 1

						if (type(C[group][option]) == "table") then
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
			if (Count == 0) then
				Settings[group] = nil
			end
		else
			Settings[group] = nil
		end
	end
end

local function KKUI_LoadProfiles()
	local Profiles = C["General"].Profiles
	local Menu = Profiles.Options
	local Data = KkthnxUIData
	local GUISettings = KkthnxUISettingsPerCharacter
	local Nickname = K.Name
	local Server = K.Realm

	if not GUISettings then
		return
	end

	for Index, Table in pairs(GUISettings) do
		local Server = Index

		for Nickname, Settings in pairs(Table) do
			local ProfileName = Server.."-"..Nickname
			local MyProfileName = K.Realm.."-"..K.Name

			if MyProfileName ~= ProfileName then
				Menu[ProfileName] = ProfileName
			end
		end
	end
end

K:RegisterEvent("VARIABLES_LOADED", function()
	KKUI_CreateDefaults()
	KKUI_LoadProfiles()
	KKUI_LoadCustomSettings()
	K.SetupUIScale(true)
	K.GUI:Enable()
end)