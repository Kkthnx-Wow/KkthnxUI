local K, C, L = unpack(KkthnxUI)

K.Devs = {
	["Kkthnx-Arena 52"] = true,
	["Kkthnx-Oribos"] = true,
    ["Ashanarra-Oribos"] = true
}

local function isDeveloper()
	return K.Devs[K.Name.."-"..K.Realm]
end
K.isDeveloper = isDeveloper()

if not K.isDeveloper then
	return
end