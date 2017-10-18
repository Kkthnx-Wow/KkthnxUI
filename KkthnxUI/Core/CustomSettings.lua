local _G = _G

local K, C = _G.unpack(_G.select(2, ...))
if not _G.IsAddOnLoaded("KkthnxUI_Config") then return end

local pairs = pairs
local CreateFrame = CreateFrame

local UnitName = _G.UnitName
local GetRealmName = _G.GetRealmName

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: KkthnxUIConfigShared, KkthnxUIConfigPerAccount

local Name = UnitName("Player")
local Realm = GetRealmName()
local Settings

if (not KkthnxUIConfigShared) then KkthnxUIConfigShared = {} or KkthnxUIConfigShared end
if (not KkthnxUIConfigShared.Account) then KkthnxUIConfigShared.Account = {} or KkthnxUIConfigShared.Account end
if (not KkthnxUIConfigShared[Realm][Name]) then KkthnxUIConfigShared[Realm][Name] = {} or KkthnxUIConfigShared[Realm][Name] end

if (KkthnxUIConfigPerAccount) then
	Settings = KkthnxUIConfigShared.Account
else
	Settings = KkthnxUIConfigShared[Realm][Name]
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