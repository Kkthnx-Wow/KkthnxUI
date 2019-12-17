local K, _, L = unpack(select(2, ...))

if GetLocale() ~= "deDE" then
	return
end

L["Ghost"] = "Geist"
L["General"] = "Allgemein"
L["Combat"] = "Kampflog"
L["Whisper"] = "Flüstern"
L["Trade"] = "Handel"
L["Loot"] = "Beute"
L["ConfigPerAccount"] = "Deine momentane Speichereinstellung steht auf per Charakter. Mit dieser Einstellung kannst Du den Befehl nicht nutzen!"