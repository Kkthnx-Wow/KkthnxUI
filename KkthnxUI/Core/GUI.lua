local K, C, L, _ = select(2, ...):unpack()
if not K.IsAddOnEnabled("KkthnxUI_Config") then return end

local pairs = pairs

-- THIS MODULE LOADS NEW USER SETTINGS IF KKTHNXUI_CONFIG IS LOADED
if not GUIConfigAll then GUIConfigAll = {} end
if GUIConfigAll[K.Realm] == nil then GUIConfigAll[K.Realm] = {} end
if GUIConfigAll[K.Realm][K.Name] == nil then GUIConfigAll[K.Realm][K.Name] = false end

if GUIConfigAll[K.Realm][K.Name] == true and not GUIConfig then return end
if GUIConfigAll[K.Realm][K.Name] == false and not GUIConfigSettings then return end

if GUIConfigAll[K.Realm][K.Name] == true then
	for group, options in pairs(GUIConfig) do
		if C[group] then
			local Count = 0
			for option, value in pairs(options) do
				if C[group][option] ~= nil then
					if C[group][option] == value then
						GUIConfig[group][option] = nil
					else
						Count = Count + 1
						C[group][option] = value
					end
				end
			end
			if Count == 0 then GUIConfig[group] = nil end
		else
			GUIConfig[group] = nil
		end
	end
else
	for group, options in pairs(GUIConfigSettings) do
		if C[group] then
			local Count = 0
			for option, value in pairs(options) do
				if C[group][option] ~= nil then
					if C[group][option] == value then
						GUIConfigSettings[group][option] = nil
					else
						Count = Count + 1
						C[group][option] = value
					end
				end
			end
			if Count == 0 then GUIConfigSettings[group] = nil end
		else
			GUIConfigSettings[group] = nil
		end
	end
end