local K = KkthnxUI[1]
K.GUIBuilder = K.GUIBuilder or {}
local B = K.GUIBuilder

function B.CreateBossCategory()
	if not B or not B.Ready() then return end
	local K, GUI, C, L, enableTextColor = B.K, B.GUI, B.C, B.L, B.enableTextColor
	local GENERAL, COLORS, PLAYER, TARGET, FILTERS = B.GENERAL, B.COLORS, B.PLAYER, B.TARGET, B.FILTERS

	local bossIcon = "Interface\\Icons\\Achievement_boss_illidan"
	local bossCategory = GUI:AddCategory(L["Boss"], bossIcon, "Boss")

	-- General
	local generalBossSection = GUI:AddSection(bossCategory, GENERAL)
	GUI:CreateSwitch(generalBossSection, "Boss.Enable", enableTextColor .. L["Enable Boss"], "Toggle Boss Module On/Off")
	GUI:CreateSwitch(generalBossSection, "Boss.Castbars", L["Show Castbars"], L["Boss.Castbars Desc"])
	GUI:CreateSwitch(generalBossSection, "Boss.CastbarIcon", L["Show Castbars Icon"], L["Boss CastbarIcon Desc"])
	GUI:CreateSwitch(generalBossSection, "Boss.Smooth", L["Smooth Bar Transition"], L["Boss.Smooth Desc"])

	-- Sizes
	local bossSizesSection = GUI:AddSection(bossCategory, L["Sizes"])
	GUI:CreateSlider(bossSizesSection, "Boss.HealthHeight", L["Health Height"], 20, 50, 1, L["Boss.HealthHeight Desc"])
	GUI:CreateSlider(bossSizesSection, "Boss.HealthWidth", L["Health Width"], 120, 180, 1, L["Boss.HealthWidth Desc"])
	GUI:CreateSlider(bossSizesSection, "Boss.PowerHeight", L["Power Height"], 10, 30, 1, L["Boss.PowerHeight Desc"])
	GUI:CreateSlider(bossSizesSection, "Boss.YOffset", L["Vertical Offset Between Frames"] .. K.GreyColor .. "(54)|r", 40, 60, 1, L["Boss.VerticalOffset Desc"])

	-- Colors
	local bossColorsSection = GUI:AddSection(bossCategory, COLORS)

	-- Health Color Format
	local healthColorOptions = {
		{ text = "Class", value = 1 },
		{ text = "Dark", value = 2 },
		{ text = "Value", value = 3 },
	}
	GUI:CreateDropdown(bossColorsSection, "Boss.HealthbarColor", L["Health Color Format"], healthColorOptions, L["Boss.HealthbarColor Desc"])
end
