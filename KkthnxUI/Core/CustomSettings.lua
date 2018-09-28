local K, C = unpack(select(2, ...))

local pairs = pairs

-- Attempt to fix a rare nil error on new char.
if IsAddOnLoaded("KkthnxUI_Config") then
	if not KkthnxUIConfigShared then
		KkthnxUIConfigShared = {}
	end

	if not KkthnxUIConfigShared[K.Realm] then
		KkthnxUIConfigShared[K.Realm] = {}
	end

	if not KkthnxUIConfigShared[K.Realm][K.Name] then
		KkthnxUIConfigShared[K.Realm][K.Name] = {}
	end
else
	return
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

		-- Keeps KkthnxUIConfig clean and small
		if (Count == 0) then
			Settings[group] = nil
		end
	else
		Settings[group] = nil
	end
end