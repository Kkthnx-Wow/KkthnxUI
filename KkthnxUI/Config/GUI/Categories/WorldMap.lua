local K = KkthnxUI[1]
K.GUIBuilder = K.GUIBuilder or {}
local B = K.GUIBuilder

function B.CreateWorldMapCategory()
	if not B or not B.Ready() then return end
	local K, GUI, C, L, enableTextColor = B.K, B.GUI, B.C, B.L, B.enableTextColor
	local GENERAL, COLORS, PLAYER, TARGET, FILTERS = B.GENERAL, B.COLORS, B.PLAYER, B.TARGET, B.FILTERS

	local worldMapIcon = "Interface\\Icons\\Icon_treasuremap"
	local worldMapCategory = GUI:AddCategory(L["WorldMap"], worldMapIcon, "WorldMap")

	-- General
	local generalWorldMapSection = GUI:AddSection(worldMapCategory, GENERAL)
	GUI:CreateSwitch(generalWorldMapSection, "WorldMap.Coordinates", L["Show Player/Mouse Coordinates"], L["WorldMap.Coordinates Desc"])
	GUI:CreateSwitch(generalWorldMapSection, "WorldMap.FadeWhenMoving", L["Fade Worldmap When Moving"], L["WorldMap.FadeWhenMoving Desc"])
	GUI:CreateSwitch(generalWorldMapSection, "WorldMap.SmallWorldMap", L["Show Smaller Worldmap"], L["WorldMap.SmallWorldMap Desc"])

	-- Waypoint options
	GUI:CreateSwitch(generalWorldMapSection, "WorldMap.AutoOpenWaypoint", L["Auto-open world map when setting waypoint"], L["WorldMap.AutoOpenWaypoint Desc"])

	-- WorldMap Reveal
	local revealWorldMapSection = GUI:AddSection(worldMapCategory, L["GUI.Section.WorldMapReveal"])
	GUI:CreateSwitch(revealWorldMapSection, "WorldMap.MapRevealGlow", L["Map Reveal Shadow"], L["MapRevealTip"])

	-- Sizes
	local sizesWorldMapSection = GUI:AddSection(worldMapCategory, L["Sizes"])
	GUI:CreateSlider(sizesWorldMapSection, "WorldMap.AlphaWhenMoving", L["Alpha When Moving"], 0.1, 1, 0.01, L["WorldMap.AlphaWhenMoving Desc"])
end
