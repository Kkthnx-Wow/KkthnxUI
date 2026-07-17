local K, C = KkthnxUI[1], KkthnxUI[2]

--[[-----------------------------------------------------------------------------
-- GUIConfigService
--
-- Shared config-path storage helpers for GUI.lua and ExtraGUI.lua.
-----------------------------------------------------------------------------]]

local type = type

local GUIConfigService = {}
K.GUIConfigService = GUIConfigService

local function shouldPruneToDefault(value, defaultValue)
	if defaultValue == nil then
		return false
	end
	if type(value) == "table" or type(defaultValue) == "table" then
		return false
	end
	return value == defaultValue
end

function GUIConfigService:GetValue(configPath)
	return K.GetValueByPath(C, configPath)
end

function GUIConfigService:GetDefaultValue(configPath)
	-- REASON: Never fall back to live C here. SetValue writes C first; reading C
	-- as "default" made every false→true toggle look like a no-op and get pruned.
	if K.Defaults then
		return K.GetValueByPath(K.Defaults, configPath)
	end

	return nil
end

function GUIConfigService:EnsureSettingsTable()
	if not KkthnxUIDB then
		return nil
	end

	if type(KkthnxUIDB.Settings) ~= "table" then
		KkthnxUIDB.Settings = {}
	end
	if type(KkthnxUIDB.Settings[K.Realm]) ~= "table" then
		KkthnxUIDB.Settings[K.Realm] = {}
	end
	if type(KkthnxUIDB.Settings[K.Realm][K.Name]) ~= "table" then
		KkthnxUIDB.Settings[K.Realm][K.Name] = {}
	end

	return KkthnxUIDB.Settings[K.Realm][K.Name]
end

function GUIConfigService:SetValue(configPath, value)
	if type(configPath) ~= "string" or configPath == "" then
		return nil
	end

	local oldValue = self:GetValue(configPath)
	-- Snapshot default before mutating C so prune compares against real defaults.
	local defaultValue = self:GetDefaultValue(configPath)

	K.SetValueByPath(C, configPath, value)

	local settings = self:EnsureSettingsTable()
	if settings then
		if shouldPruneToDefault(value, defaultValue) then
			K.RemoveValueByPath(settings, configPath)
		else
			K.SetValueByPath(settings, configPath, value)
		end
	end

	return oldValue
end
