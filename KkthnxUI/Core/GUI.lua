local K, C, L = select(2, ...):unpack()
if not IsAddOnLoaded("KkthnxUI_Config") then return end

local pairs = pairs

local Name = UnitName("Player")
local Realm = GetRealmName()

local KCA = KkthnxUIConfigAll
local Private = KkthnxUIConfigPrivate
local Public = KkthnxUIConfigPublic

-- This Module loads new user settings if KkthnxUI_Config is loaded
if not KCA then KCA = {} end
if KCA[Realm] == nil then KCA[Realm] = {} end
if KCA[Realm][Name] == nil then KCA[Realm][Name] = false end

if KCA[Realm][Name] == true and not Private then return end
if KCA[Realm][Name] == false and not Public then return end

if KCA[Realm][Name] == true then
	for group, options in pairs(Private) do
		if C[group] then
			local Count = 0
			for option, value in pairs(options) do
				if C[group][option] ~= nil then
					if C[group][option] == value then
						Private[group][option] = nil
					else
						Count = Count + 1
						C[group][option] = value
					end
				end
			end
			if Count == 0 then Private[group] = nil end
		else
			Private[group] = nil
		end
	end
else
	for group, options in pairs(Public) do
		if C[group] then
			local Count = 0
			for option, value in pairs(options) do
				if C[group][option] ~= nil then
					if C[group][option] == value then
						Public[group][option] = nil
					else
						Count = Count + 1
						C[group][option] = value
					end
				end
			end
			if Count == 0 then Public[group] = nil end
		else
			Public[group] = nil
		end
	end
end