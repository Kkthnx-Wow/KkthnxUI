local K, C, L, _ = select(2, ...):unpack()
if not IsAddOnLoaded("KkthnxUI_Config") then return end

local pairs = pairs

-- This Module loads new user settings if KkthnxUI_Config is loaded
if not GUIConfigAll then GUIConfigAll = {} end
if GUIConfigAll[K.Realm] == nil then GUIConfigAll[K.Realm] = {} end
if GUIConfigAll[K.Realm][K.Name] == nil then GUIConfigAll[K.Realm][K.Name] = false end

if GUIConfigAll[K.Realm][K.Name] == true and not GUIConfig then return end
if GUIConfigAll[K.Realm][K.Name] == false and not GUIConfigSettings then return end

if GUIConfigAll[K.Realm][K.Name] == true then
	for group, options in pairs(GUIConfig) do
		if C[group] then
			local count = 0
			for option, value in pairs(options) do
				if (C[group][option] ~= nil) then
					if (C[group][option] == value) then
						GUIConfig[group][option] = nil
					else
						count = count + 1
						C[group][option] = value
					end
				end
			end
			if (count == 0) then GUIConfig[group] = nil end
		else
			GUIConfig[group] = nil
		end
	end
else
	for group, options in pairs(GUIConfigSettings) do
		if C[group] then
			local count = 0
			for option, value in pairs(options) do
				if C[group][option] ~= nil then
					if C[group][option] == value then
						GUIConfigSettings[group][option] = nil
					else
						count = count + 1
						C[group][option] = value
					end
				end
			end
			if (count == 0) then GUIConfigSettings[group] = nil end
		else
			GUIConfigSettings[group] = nil
		end
	end
end