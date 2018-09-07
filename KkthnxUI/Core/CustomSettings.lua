local _, C = unpack(select(2, ...))

local pairs = pairs

local playerName = UnitName("player")
local playerRealm = GetRealmName()

-- Fuck you nil error. Im about sick of your shit. XD
if IsAddOnLoaded("KkthnxUI_Config") then
	if not KkthnxUIConfigShared then
		KkthnxUIConfigShared = {}
	end

	if not KkthnxUIConfigShared[playerRealm] then
		KkthnxUIConfigShared[playerRealm] = {}
	end

	if not KkthnxUIConfigShared[playerRealm][playerName] then
		KkthnxUIConfigShared[playerRealm][playerName] = {}
	end
else
	return
end

local Settings
if (KkthnxUIConfigPerAccount) then
	Settings = KkthnxUIConfigShared.Account
else
	Settings = KkthnxUIConfigShared[playerRealm][playerName]
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