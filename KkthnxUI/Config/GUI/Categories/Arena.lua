local K = KkthnxUI[1]
K.GUIBuilder = K.GUIBuilder or {}
local B = K.GUIBuilder

function B.CreateArenaCategory()
	if not B or not B.Ready() then return end
	local K, GUI, C, L, enableTextColor = B.K, B.GUI, B.C, B.L, B.enableTextColor
	local GENERAL, COLORS, PLAYER, TARGET, FILTERS = B.GENERAL, B.COLORS, B.PLAYER, B.TARGET, B.FILTERS

	local arenaCategory = GUI:AddCategory(L["Arena"], "Interface\\Icons\\Achievement_Arena_2v2_7", "Arena")

	-- General
	local generalArenaSection = GUI:AddSection(arenaCategory, GENERAL)
	GUI:CreateSwitch(generalArenaSection, "Arena.Enable", enableTextColor .. L["Enable Arena"], "Toggle Arena Module On/Off")
	GUI:CreateSwitch(generalArenaSection, "Arena.Castbars", L["Show Castbars"], L["Arena.Castbars Desc"])
	GUI:CreateSwitch(generalArenaSection, "Arena.CastbarIcon", L["Show Castbars Icon"], L["Arena CastbarIcon Desc"])
	GUI:CreateSwitch(generalArenaSection, "Arena.Smooth", L["Smooth Bar Transition"], L["Arena.Smooth Desc"])

	-- Sizes
	local arenaSizesSection = GUI:AddSection(arenaCategory, L["Sizes"])
	GUI:CreateSlider(arenaSizesSection, "Arena.HealthHeight", L["Health Height"], 20, 50, 1, L["Arena.HealthHeight Desc"])
	GUI:CreateSlider(arenaSizesSection, "Arena.HealthWidth", L["Health Width"], 120, 180, 1, L["Arena.HealthWidth Desc"])
	GUI:CreateSlider(arenaSizesSection, "Arena.PowerHeight", L["Power Height"], 10, 30, 1, L["Arena.PowerHeight Desc"])
	GUI:CreateSlider(arenaSizesSection, "Arena.YOffset", L["Vertical Offset Between Frames"] .. K.GreyColor .. "(54)|r", 40, 60, 1, L["Arena.VerticalOffset Desc"])

	-- Colors
	local arenaColorsSection = GUI:AddSection(arenaCategory, COLORS)

	-- Health Color Format
	local healthColorOptions = {
		{ text = "Class", value = 1 },
		{ text = "Dark", value = 2 },
		{ text = "Value", value = 3 },
	}
	GUI:CreateDropdown(arenaColorsSection, "Arena.HealthbarColor", L["Health Color Format"], healthColorOptions, L["Arena.HealthbarColor Desc"])
end
