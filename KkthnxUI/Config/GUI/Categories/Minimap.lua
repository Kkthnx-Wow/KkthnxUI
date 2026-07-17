local K = KkthnxUI[1]
K.GUIBuilder = K.GUIBuilder or {}
local B = K.GUIBuilder

function B.CreateMinimapCategory()
	if not B or not B.Ready() then return end
	local K, GUI, C, L, enableTextColor = B.K, B.GUI, B.C, B.L, B.enableTextColor
	local GENERAL, COLORS, PLAYER, TARGET, FILTERS = B.GENERAL, B.COLORS, B.PLAYER, B.TARGET, B.FILTERS

	local minimapIcon = "Interface\\Icons\\INV_Misc_Map_01"
	local minimapCategory = GUI:AddCategory(L["Minimap"], minimapIcon, "Minimap")

	-- General
	local generalMinimapSection = GUI:AddSection(minimapCategory, GENERAL)
	GUI:CreateSwitch(generalMinimapSection, "Minimap.Enable", enableTextColor .. L["Enable Minimap"], L["Enable Desc"])
	GUI:CreateSwitch(generalMinimapSection, "Minimap.Calendar", L["Show Minimap Calendar"], L["If enabled, show minimap calendar icon on minimap.|nYou can simply click mouse middle button on minimap to toggle calendar even without this option."])

	-- Features
	local featuresSection = GUI:AddSection(minimapCategory, L["Features"])
	GUI:CreateSwitch(featuresSection, "Minimap.EasyVolume", L["EasyVolume"], L["EasyVolumeTip"])
	GUI:CreateSwitch(featuresSection, "Minimap.MailPulse", L["Pulse Minimap Mail"], L["MailPulse Desc"])
	GUI:CreateSwitch(featuresSection, "Minimap.QueueStatusText", L["QueueStatus"], L["Minimap.QueueStatusText Desc"])
	GUI:CreateSwitch(featuresSection, "Minimap.ShowRecycleBin", L["Show Minimap Button Collector"], L["ShowRecycleBin Desc"])

	-- Recycle Bin
	local recycleBinSection = GUI:AddSection(minimapCategory, L["Recycle Bin"])

	-- RecycleBin Position
	local recycleBinPositionOptions = {
		{ text = "BottomLeft", value = 1 },
		{ text = "BottomRight", value = 2 },
		{ text = "TopLeft", value = 3 },
		{ text = "TopRight", value = 4 },
	}
	GUI:CreateDropdown(recycleBinSection, "Minimap.RecycleBinPosition", L["Set RecycleBin Position"], recycleBinPositionOptions, L["RecycleBinPosition Desc"])

	-- Location Section
	local locationSection = GUI:AddSection(minimapCategory, L["Location"])

	-- Location Text Style
	local locationTextOptions = {
		{ text = "Always Display", value = 1 },
		{ text = "Hide", value = 2 },
		{ text = "Minimap Mouseover", value = 3 },
	}
	GUI:CreateDropdown(locationSection, "Minimap.LocationText", L["Location Text Style"], locationTextOptions, L["Minimap.LocationText Desc"])

	-- Size
	local sizeSection = GUI:AddSection(minimapCategory, L["Size"])
	GUI:CreateSlider(sizeSection, "Minimap.Size", L["Minimap Size"], 120, 300, 1, L["Size Desc"])
end
