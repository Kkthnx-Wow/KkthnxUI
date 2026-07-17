local K = KkthnxUI[1]
K.GUIBuilder = K.GUIBuilder or {}
local B = K.GUIBuilder

function B.CreateDataTextCategory()
	if not B or not B.Ready() then return end
	local K, GUI, C, L, enableTextColor = B.K, B.GUI, B.C, B.L, B.enableTextColor
	local GENERAL, COLORS, PLAYER, TARGET, FILTERS = B.GENERAL, B.COLORS, B.PLAYER, B.TARGET, B.FILTERS

	local dataTextIcon = "Interface\\Icons\\Achievement_worldevent_childrensweek"
	local dataTextCategory = GUI:AddCategory(L["DataText"], dataTextIcon, "DataText")

	-- General
	local generalDataTextSection = GUI:AddSection(dataTextCategory, GENERAL)
	GUI:CreateSwitch(generalDataTextSection, "DataText.Coords", L["Enable Position Coords"], L["Coords Desc"])
	GUI:CreateSwitch(generalDataTextSection, "DataText.Friends", L["Enable Friends Info"], L["Friends Desc"])
	GUI:CreateSwitch(generalDataTextSection, "DataText.Gold", L["Enable Currency Info"], L["Gold Desc"])
	GUI:CreateSwitch(generalDataTextSection, "DataText.Guild", L["Enable Guild Info"], L["Guild Desc"])
	GUI:CreateSwitch(generalDataTextSection, "DataText.Latency", L["Enable Latency Info"], L["Latency Desc"])
	GUI:CreateSwitch(generalDataTextSection, "DataText.Location", L["Enable Minimap Location"], L["Location Desc"])
	GUI:CreateSwitch(generalDataTextSection, "DataText.Spec", L["Enable Specialization Info"], L["Spec Desc"])
	GUI:CreateSwitch(generalDataTextSection, "DataText.System", L["Enable System Info"], L["System Desc"])
	GUI:CreateSwitch(generalDataTextSection, "DataText.Time", L["Enable Minimap Time"], L["Time Desc"])

	-- Icon Colors
	local iconColorsSection = GUI:AddSection(dataTextCategory, L["Icon Colors"])
	GUI:CreateColorPicker(iconColorsSection, "DataText.IconColor", L["Color The Icons"], L["IconColor Desc"])

	-- Text Toggles
	local textTogglesSection = GUI:AddSection(dataTextCategory, L["Text Toggles"])
	GUI:CreateSwitch(textTogglesSection, "DataText.HideText", L["Hide Icon Text"], L["HideText Desc"])
end
