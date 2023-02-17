-- Create a new module for the death counter
local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]

K.Devs = {
	["Kkthnx-Area 52"] = true,
}

local function isDeveloper()
	return K.Devs[K.Name .. "-" .. K.Realm]
end
K.isDeveloper = isDeveloper()

if not K.isDeveloper then
	return
end
