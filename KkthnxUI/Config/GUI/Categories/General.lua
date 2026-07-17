local K = KkthnxUI[1]
K.GUIBuilder = K.GUIBuilder or {}
local B = K.GUIBuilder

function B.CreateGeneralCategory()
	if not B or not B.Ready() then return end
	local K, GUI, C, L, enableTextColor = B.K, B.GUI, B.C, B.L, B.enableTextColor
	local GENERAL, COLORS, PLAYER, TARGET, FILTERS = B.GENERAL, B.COLORS, B.PLAYER, B.TARGET, B.FILTERS

	local generalIcon = "Interface\\Icons\\INV_Misc_Gear_01"
	local generalCategory = GUI:AddCategory(L["General"], generalIcon, "General")

	-- General
	local generalGeneralSection = GUI:AddSection(generalCategory, GENERAL)
	GUI:CreateSwitch(generalGeneralSection, "General.MinimapIcon", L["Enable Minimap Icon"], L["MinimapIcon Desc"])
	GUI:CreateSwitch(generalGeneralSection, "General.MoveBlizzardFrames", L["Move Blizzard Frames"], L["MoveBlizzardFrames Desc"])
	GUI:CreateSwitch(generalGeneralSection, "General.NoErrorFrame", L["Disable Blizzard Error Frame Combat"], L["General.NoErrorFrame Desc"])
	GUI:CreateSwitch(generalGeneralSection, "General.NoTutorialButtons", L["Disable 'Some' Blizzard Tutorials"], L["NoTutorialButtons Desc"])
	GUI:CreateSwitch(generalGeneralSection, "General.VersionCheck", L["Enable Version Check"], L["General.VersionCheck Desc"])

	-- Button Glow Mode
	local glowModeOptions = {
		{ text = "Pixel", value = 1 },
		{ text = "Autocast", value = 2 },
		{ text = "Action Button", value = 3 },
		{ text = "Proc Glow", value = 4 },
	}
	GUI:CreateDropdown(generalGeneralSection, "General.GlowMode", L["Button Glow Mode"], glowModeOptions, L["GlowMode Desc"], nil, nil, true)

	-- Border Style
	local borderStyleOptions
	if K.GetAllBorderStyles then
		borderStyleOptions = K.GetAllBorderStyles()
	else
		-- Fallback options if function not available
		borderStyleOptions = {
			{ text = "KkthnxUI", value = "KkthnxUI", description = "Default KkthnxUI border style" },
			{ text = "AzeriteUI", value = "AzeriteUI", description = "Clean Azerite-inspired border" },
			{ text = "KkthnxUI Pixel", value = "KkthnxUI_Pixel", description = "Sharp pixel-perfect border" },
			{ text = "KkthnxUI Blank", value = "KkthnxUI_Blank", description = "Minimal blank border style" },
		}
	end
	GUI:CreateDropdown(generalGeneralSection, "General.BorderStyle", L["Border Style"], borderStyleOptions, L["General.BorderStyle Desc"])

	-- Number Prefix
	local numberPrefixOptions = {
		{ text = "Standard: b/m/k", value = 1 },
		{ text = "Asian: y/w", value = 2 },
		{ text = "Full Digits", value = 3 },
	}
	GUI:CreateDropdown(generalGeneralSection, "General.NumberPrefixStyle", L["Number Prefix Style"], numberPrefixOptions, L["General.NumberPrefixStyle Desc"], nil, nil, true)

	-- Smoothing
	GUI:CreateSlider(generalGeneralSection, "General.SmoothAmount", "Smoothing Amount", 0.1, 1, 0.01, L["Setup healthbar smooth frequency for unitframes and nameplates. The lower the smoother."])

	-- Scaling
	local scalingSection = GUI:AddSection(generalCategory, L["Scaling"])
	GUI:CreateSwitch(scalingSection, "General.AutoScale", L["Auto Scale"], L["AutoScaleTip"])
	GUI:CreateSlider(scalingSection, "General.UIScale", L["Set UI scale"], 0.4, 1.15, 0.01, L["UIScaleTip"])

	-- Colors
	local colorsSection = GUI:AddSection(generalCategory, COLORS)
	GUI:CreateSwitch(colorsSection, "General.ColorTextures", L["Color 'Most' KkthnxUI Borders"], L["ColorTextures Desc"])
	GUI:CreateColorPicker(colorsSection, "General.TexturesColor", L["Textures Color"], "Choose the color for KkthnxUI textures and borders")

	-- Texture Section
	local textureSection = GUI:AddSection(generalCategory, L["Texture"])

	-- Enhanced Texture
	GUI:CreateTextureDropdown(textureSection, "General.Texture", L["Set General Texture"], L["Texture Desc"])
end
