local _G = _G

local K, C = _G.unpack(_G.select(2, ...))
if not _G.IsAddOnLoaded("KkthnxUI_Config") then return end

local pairs = pairs
local CreateFrame = CreateFrame

local UnitName = _G.UnitName
local GetRealmName = _G.GetRealmName

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: KkthnxUIConfigShared, KkthnxUIConfigPerAccount

local Settings

if not KkthnxUIConfigShared then KkthnxUIConfigShared = {} end
if KkthnxUIConfigShared[K.Realm] == nil then KkthnxUIConfigShared[K.Realm] = {} end
if KkthnxUIConfigShared[K.Realm][K.Name] == nil then KkthnxUIConfigShared[K.Realm][K.Name] = false end

if KkthnxUIConfigShared[K.Realm][K.Name] == true and not Settings then return end
if KkthnxUIConfigShared[K.Realm][K.Name] == false and not Settings then return end

if (KkthnxUIConfigPerAccount) then
	Settings = KkthnxUIConfigShared.Account
else
	Settings = KkthnxUIConfigShared[K.Realm][K.Name]
end

for group, options in pairs(Settings) do
	if C[group] then
		local Count = 0

		for option, value in pairs(options) do
			if (C[group][option] ~= nil) then
				if (C[group][option] == value) then
					Settings[group][option] = nil
				else
					Count = Count + 1
					C[group][option] = value
				end
			end
		end

		-- Keeps KkthnxUIConfig clean and small
		if (Count == 0) then
			Settings[group] = nil
		end
	else
		Settings[group] = nil
	end
end