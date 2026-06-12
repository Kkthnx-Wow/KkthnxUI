local K, C = KkthnxUI[1], KkthnxUI[2]

--[[-----------------------------------------------------------------------------
-- GUIConfigService
--
-- Shared config-path storage helpers for GUI.lua and ExtraGUI.lua.
--
-- REASON: both GUI layers were carrying their own versions of "get current",
-- "get default", and "write runtime + SavedVariables" logic. That makes defaults
-- and DB plumbing drift. This service owns the shared data work; GUI.lua still
-- owns live hooks/reload prompts because those are main-config UI behavior.
-----------------------------------------------------------------------------]]

local type = type

local GUIConfigService = {}
K.GUIConfigService = GUIConfigService

function GUIConfigService:GetValue(configPath)
	return K.GetValueByPath(C, configPath)
end

function GUIConfigService:GetDefaultValue(configPath)
	if K.Defaults then
		local defaultValue = K.GetValueByPath(K.Defaults, configPath)
		if defaultValue ~= nil then
			return defaultValue
		end
	end

	-- Fallback mirrors the old GUI/ExtraGUI behavior: if defaults are not ready,
	-- read the current config tree rather than returning nil and breaking reset UI.
	return K.GetValueByPath(C, configPath)
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
	local oldValue = self:GetValue(configPath)

	K.SetValueByPath(C, configPath, value)

	local settings = self:EnsureSettingsTable()
	if settings then
		K.SetValueByPath(settings, configPath, value)
	end

	return oldValue
end

