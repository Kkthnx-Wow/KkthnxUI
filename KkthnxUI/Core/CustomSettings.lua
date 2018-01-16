local K, C = unpack(select(2, ...))

if not IsAddOnLoaded("KkthnxUI_Config") then
	print("I could not detect KkthnxUI_Config. Please make sure it is enabled in your addon list. Stopping process...")
	return
end

local playerName = UnitName("player")
local playerRealm = GetRealmName()

-- Fuck you nil error. Im about sick of your shit. XD
if not KkthnxUIConfigShared then
	KkthnxUIConfigShared = {}
end

if (not KkthnxUIConfigShared.Account) then
	KkthnxUIConfigShared.Account = {}
end

if KkthnxUIConfigShared[playerRealm] == nil then
	KkthnxUIConfigShared[playerRealm] = {}
end

if KkthnxUIConfigShared[playerRealm][playerName] == nil then
	KkthnxUIConfigShared[playerRealm][playerName] = false
end

if KkthnxUIConfigShared[playerRealm][playerName] == true and not KkthnxUIConfigNotShared then
	return
end

if KkthnxUIConfigShared[playerRealm][playerName] == false and not KkthnxUIConfigPerAccount then
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
