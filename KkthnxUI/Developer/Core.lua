local K, C, L = unpack(KkthnxUI)

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
