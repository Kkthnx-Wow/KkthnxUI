local K, C, L = unpack(KkthnxUI)

K.Devs = {
	["Ashanarra-Oribos"] = true,
	["Informant-Oribos"] = true,
	["Kkthnx-Arena 52"] = true,
	["Kkthnx-Oribos"] = true,
	["Swipers-Oribos"] = true,
}

local function isDeveloper()
	return K.Devs[K.Name .. "-" .. K.Realm]
end
K.isDeveloper = isDeveloper()

if not K.isDeveloper then
	return
end
