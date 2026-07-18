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

	-- Map Pin Navigation (super-track arrow)
	local pinSection = GUI:AddSection(worldMapCategory, L["Map Pin Navigation"])
	GUI:CreateSwitch(pinSection, "WorldMap.MapPinNavigation", enableTextColor .. L["Enable Map Pin Navigation"], L["WorldMap.MapPinNavigation Desc"])
	local pinEta = GUI:CreateSwitch(pinSection, "WorldMap.MapPinShowEta", L["Show Arrival ETA"], L["WorldMap.MapPinShowEta Desc"])
	local pinCvar = GUI:CreateSwitch(pinSection, "WorldMap.MapPinRespectNavCVar", L["Require In-Game Navigation"], L["WorldMap.MapPinRespectNavCVar Desc"])
	local pinMeters = GUI:CreateSwitch(pinSection, "WorldMap.MapPinUseMeters", L["Use Meters"], L["WorldMap.MapPinUseMeters Desc"])
	local pinShort = GUI:CreateSwitch(pinSection, "WorldMap.MapPinShortNumbers", L["Abbreviate Distance"], L["WorldMap.MapPinShortNumbers Desc"])
	local pinFadeMouse = GUI:CreateSwitch(pinSection, "WorldMap.MapPinFadeMouseOver", L["Fade on Mouse Over"], L["WorldMap.MapPinFadeMouseOver Desc"])
	local pinAuto = GUI:CreateSwitch(pinSection, "WorldMap.MapPinAutoTrack", L["Auto-Track New Waypoints"], L["WorldMap.MapPinAutoTrack Desc"])
	GUI:DependsOn(pinEta, "WorldMap.MapPinNavigation", true)
	GUI:DependsOn(pinCvar, "WorldMap.MapPinNavigation", true)
	GUI:DependsOn(pinMeters, "WorldMap.MapPinNavigation", true)
	GUI:DependsOn(pinShort, "WorldMap.MapPinNavigation", true)
	GUI:DependsOn(pinFadeMouse, "WorldMap.MapPinNavigation", true)
	GUI:DependsOn(pinAuto, "WorldMap.MapPinNavigation", true)
	local pinMin = GUI:CreateSlider(pinSection, "WorldMap.MapPinMinDistance", L["Minimum Pin Distance"], 0, 500, 25, L["WorldMap.MapPinMinDistance Desc"])
	local pinMax = GUI:CreateSlider(pinSection, "WorldMap.MapPinMaxDistance", L["Maximum Pin Distance"], 0, 10000, 100, L["WorldMap.MapPinMaxDistance Desc"])
	local pinFade = GUI:CreateSlider(pinSection, "WorldMap.MapPinFadeDistance", L["Long-Range Fade Starts"], 0, 5000, 100, L["WorldMap.MapPinFadeDistance Desc"])
	local pinAlphaShort = GUI:CreateSlider(pinSection, "WorldMap.MapPinAlphaShort", L["Close Range Alpha"], 0, 100, 5, L["WorldMap.MapPinAlphaShort Desc"])
	local pinAlphaLong = GUI:CreateSlider(pinSection, "WorldMap.MapPinAlphaLong", L["Long Range Alpha"], 0, 100, 5, L["WorldMap.MapPinAlphaLong Desc"])
	local pinAlphaClamp = GUI:CreateSlider(pinSection, "WorldMap.MapPinAlphaClamped", L["Edge Arrow Alpha"], 0, 100, 5, L["WorldMap.MapPinAlphaClamped Desc"])
	GUI:DependsOn(pinMin, "WorldMap.MapPinNavigation", true)
	GUI:DependsOn(pinMax, "WorldMap.MapPinNavigation", true)
	GUI:DependsOn(pinFade, "WorldMap.MapPinNavigation", true)
	GUI:DependsOn(pinAlphaShort, "WorldMap.MapPinNavigation", true)
	GUI:DependsOn(pinAlphaLong, "WorldMap.MapPinNavigation", true)
	GUI:DependsOn(pinAlphaClamp, "WorldMap.MapPinNavigation", true)

	-- WorldMap Reveal
	local revealWorldMapSection = GUI:AddSection(worldMapCategory, L["GUI.Section.WorldMapReveal"])
	GUI:CreateSwitch(revealWorldMapSection, "WorldMap.MapRevealGlow", L["Map Reveal Shadow"], L["MapRevealTip"])

	-- Sizes
	local sizesWorldMapSection = GUI:AddSection(worldMapCategory, L["Sizes"])
	GUI:CreateSlider(sizesWorldMapSection, "WorldMap.AlphaWhenMoving", L["Alpha When Moving"], 0.1, 1, 0.01, L["WorldMap.AlphaWhenMoving Desc"])
end
