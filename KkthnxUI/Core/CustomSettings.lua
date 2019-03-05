local K, C = unpack(select(2, ...))
if not IsAddOnLoaded("KkthnxUI_Config") then
	return
end

local pairs = pairs

-- Blizzard has too many issues with per character saved variables.
if (not KkthnxUIConfigShared) then
	KkthnxUIConfigShared = {}
end

if (not KkthnxUIConfigShared.Account) then
	KkthnxUIConfigShared.Account = {}
end

if (not KkthnxUIConfigShared[K.Realm]) then
	KkthnxUIConfigShared[K.Realm] = {}
end

if (not KkthnxUIConfigShared[K.Realm][K.Name]) then
	KkthnxUIConfigShared[K.Realm][K.Name] = {}
end

if (KkthnxUIConfigNotShared) then
	KkthnxUIConfigShared[K.Realm][K.Name] = KkthnxUIConfigNotShared
	KkthnxUIConfigNotShared = nil
end

local Settings
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

		-- Keeps KkthnxUI_Config clean and small
		if (Count == 0) then
			Settings[group] = nil
		end
	else
		Settings[group] = nil
	end
end

--[[if not KkthnxUIConfigShared then
	KkthnxUIConfigShared = {}
end

if KkthnxUIConfigShared[K.Realm] == nil then
	KkthnxUIConfigShared[K.Realm] = {}
end

if KkthnxUIConfigShared[K.Realm][K.Name] == nil then
	KkthnxUIConfigShared[K.Realm][K.Name] = false
end

if KkthnxUIConfigShared[K.Realm][K.Name] == true and not KkthnxUIConfigNotShared then
	return
end

if KkthnxUIConfigShared[K.Realm][K.Name] == false and not KkthnxUIConfigPerAccount then
	return
end

if Settings == true then
	for group, options in pairs(Settings) do
		if C[group] then
			local count = 0
			for option, value in pairs(options) do
				if C[group][option] ~= nil then
					if C[group][option] == value then
						Settings[group][option] = nil
					else
						count = count + 1
						C[group][option] = value
					end
				end
			end
			if count == 0 then
				Settings[group] = nil
			end
		else
			Settings[group] = nil
		end
	end
else
	for group, options in pairs(Settings) do
		if C[group] then
			local count = 0
			for option, value in pairs(options) do
				if C[group][option] ~= nil then
					if C[group][option] == value then
						Settings[group][option] = nil
					else
						count = count + 1
						C[group][option] = value
					end
				end
			end
			if count == 0 then
				Settings[group] = nil
			end
		else
			Settings[group] = nil
		end
	end
end--]]