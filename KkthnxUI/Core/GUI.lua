local K, C, L = select(2, ...):unpack()
if not IsAddOnLoaded("KkthnxUI_Config") then return end

local pairs = pairs

local Name = UnitName("Player")
local Realm = GetRealmName()

-- THIS MODULE LOADS NEW USER SETTINGS IF KKTHNXUI_CONFIG IS LOADED
if not KkthnxUIConfigAll then KkthnxUIConfigAll = {} end
if KkthnxUIConfigAll[Realm] == nil then KkthnxUIConfigAll[Realm] = {} end
if KkthnxUIConfigAll[Realm][Name] == nil then KkthnxUIConfigAll[Realm][Name] = false end

if KkthnxUIConfigAll[Realm][Name] == true and not KkthnxUIConfigPrivate then return end
if KkthnxUIConfigAll[Realm][Name] == false and not KkthnxUIConfigPublic then return end

if KkthnxUIConfigAll[Realm][Name] == true then
	for group, options in pairs(KkthnxUIConfigPrivate) do
		if C[group] then
			local Count = 0
			for option, value in pairs(options) do
				if C[group][option] ~= nil then
					if C[group][option] == value then
						KkthnxUIConfigPrivate[group][option] = nil
					else
						Count = Count + 1
						C[group][option] = value
					end
				end
			end
			if Count == 0 then KkthnxUIConfigPrivate[group] = nil end
		else
			KkthnxUIConfigPrivate[group] = nil
		end
	end
else
	for group, options in pairs(KkthnxUIConfigPublic) do
		if C[group] then
			local Count = 0
			for option, value in pairs(options) do
				if C[group][option] ~= nil then
					if C[group][option] == value then
						KkthnxUIConfigPublic[group][option] = nil
					else
						Count = Count + 1
						C[group][option] = value
					end
				end
			end
			if Count == 0 then KkthnxUIConfigPublic[group] = nil end
		else
			KkthnxUIConfigPublic[group] = nil
		end
	end
end