local K, C, L = unpack(select(2, ...))
if not IsAddOnLoaded("KkthnxUI_Config") then return end

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: KkthnxUIConfigAll

-- This Module loads new user settings if KkthnxUI_Config is loaded
if not KkthnxUIConfigAll then KkthnxUIConfigAll = {} end
if KkthnxUIConfigAll[K.Realm] == nil then KkthnxUIConfigAll[K.Realm] = {} end
if KkthnxUIConfigAll[K.Realm][K.Name] == nil then KkthnxUIConfigAll[K.Realm][K.Name] = false end

if KkthnxUIConfigAll[K.Realm][K.Name] == true and not KkthnxUIConfigPrivate then return end
if KkthnxUIConfigAll[K.Realm][K.Name] == false and not KkthnxUIConfigPublic then return end

if KkthnxUIConfigAll[K.Realm][K.Name] == true then
	for group, options in pairs(KkthnxUIConfigPrivate) do
		if C[group] then
			local count = 0
			for option, value in pairs(options) do
				if C[group][option] ~= nil then
					if C[group][option] == value then
						KkthnxUIConfigPrivate[group][option] = nil
					else
						count = count + 1
						C[group][option] = value
					end
				end
			end
			if count == 0 then KkthnxUIConfigPrivate[group] = nil end
		else
			KkthnxUIConfigPrivate[group] = nil
		end
	end
else
	for group, options in pairs(KkthnxUIConfigPublic) do
		if C[group] then
			local count = 0
			for option, value in pairs(options) do
				if C[group][option] ~= nil then
					if C[group][option] == value then
						KkthnxUIConfigPublic[group][option] = nil
					else
						count = count + 1
						C[group][option] = value
					end
				end
			end
			if count == 0 then KkthnxUIConfigPublic[group] = nil end
		else
			KkthnxUIConfigPublic[group] = nil
		end
	end
end