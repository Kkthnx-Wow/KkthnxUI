local K = KkthnxUI[1]
K.GUIBuilder = K.GUIBuilder or {}
local B = K.GUIBuilder

function B.CreateNameplateCategory()
	if not B or not B.Ready() then return end
	local K, GUI, C, L, enableTextColor = B.K, B.GUI, B.C, B.L, B.enableTextColor
	local GENERAL, COLORS, PLAYER, TARGET, FILTERS = B.GENERAL, B.COLORS, B.PLAYER, B.TARGET, B.FILTERS

	local nameplateIcon = "Interface\\Icons\\Spell_Arcane_MindMastery"
	local nameplateCategory = GUI:AddCategory(L["Nameplate"], nameplateIcon, "Nameplate")

	-- General
	local generalNameplateSection = GUI:AddSection(nameplateCategory, GENERAL)

	GUI:CreateSwitch(generalNameplateSection, "Nameplate.Enable", enableTextColor .. L["Enable Nameplates"], "Toggle the entire nameplate system on/off")
	GUI:CreateSwitch(generalNameplateSection, "Nameplate.ClassIcon", L["Show Enemy Class Icons"], L["Nameplate.ClassIcon Desc"])
	GUI:CreateSwitch(generalNameplateSection, "Nameplate.CustomUnitColor", L["Colored Custom Units"], L["Nameplate.CustomUnitColor Desc"])
	GUI:CreateSwitch(generalNameplateSection, "Nameplate.FriendlyCC", L["Show Friendly ClassColor"], L["Nameplate.FriendlyCC Desc"])
	GUI:CreateSwitch(generalNameplateSection, "Nameplate.HostileCC", L["Show Hostile ClassColor"], L["Nameplate.HostileCC Desc"])
	GUI:CreateSwitch(generalNameplateSection, "Nameplate.FullHealth", L["Show Health Value"], L["Nameplate.FullHealth Desc"])
	GUI:CreateSwitch(generalNameplateSection, "Nameplate.InsideView", L["Interacted Nameplate Stay Inside"], L["Nameplate.InsideView Desc"])
	GUI:CreateSwitch(generalNameplateSection, "Nameplate.NameOnly", L["Show Only Names For Friendly"], L["Nameplate.NameOnly Desc"])
	GUI:CreateSwitch(generalNameplateSection, "Nameplate.NameplateClassPower", "Show Nameplate Class Power", L["Nameplate.NameplateClassPower Desc"])

	-- Auras
	local aurasNameplateSection = GUI:AddSection(nameplateCategory, L["Auras"])
	local auraFilterOptions = {
		{ text = "White & Black List", value = 1 },
		{ text = "List & Player", value = 2 },
		{ text = "List & Player & CCs", value = 3 },
	}
	GUI:CreateDropdown(aurasNameplateSection, "Nameplate.AuraFilter", L["Auras Filter Style"], auraFilterOptions, L["Nameplate.AuraFilter Desc"])
	GUI:CreateSlider(aurasNameplateSection, "Nameplate.AuraSize", L["Auras Size"], 18, 40, 1, L["Nameplate.AuraSize Desc"])
	GUI:CreateSlider(aurasNameplateSection, "Nameplate.MaxAuras", L["Max Auras"], 4, 8, 1, L["Nameplate.MaxAuras Desc"])
	GUI:CreateSwitch(aurasNameplateSection, "Nameplate.PlateAuras", L["Target Nameplate Auras"], L["TargetPlateAuras Desc"])

	-- Targeting & Indicators
	local indicatorsSection = GUI:AddSection(nameplateCategory, L["Targeting & Indicators"])
	local targetIndicatorOptions = {
		{ text = "Disable", value = 1 },
		{ text = "Top Arrow", value = 2 },
		{ text = "Right Arrow", value = 3 },
		{ text = "Border Glow", value = 4 },
		{ text = "Top Arrow + Glow", value = 5 },
		{ text = "Right Arrow + Glow", value = 6 },
	}
	GUI:CreateDropdown(indicatorsSection, "Nameplate.TargetIndicator", L["TargetIndicator Style"], targetIndicatorOptions, L["Nameplate.TargetIndicator Desc"])
	local targetIndicatorTextureOptions = {
		{ text = "Blue Arrow 2" .. "|TInterface\\Addons\\KkthnxUI\\Media\\Nameplates\\BlueArrow2:0|t", value = "Interface\\Addons\\KkthnxUI\\Media\\Nameplates\\BlueArrow2" },
		{ text = "Blue Arrow" .. "|TInterface\\Addons\\KkthnxUI\\Media\\Nameplates\\BlueArrow:0|t", value = "Interface\\Addons\\KkthnxUI\\Media\\Nameplates\\BlueArrow" },
		{ text = "Neon Blue Arrow" .. "|TInterface\\Addons\\KkthnxUI\\Media\\Nameplates\\NeonBlueArrow:0|t", value = "Interface\\Addons\\KkthnxUI\\Media\\Nameplates\\NeonBlueArrow" },
		{ text = "Neon Green Arrow" .. "|TInterface\\Addons\\KkthnxUI\\Media\\Nameplates\\NeonGreenArrow:0|t", value = "Interface\\Addons\\KkthnxUI\\Media\\Nameplates\\NeonGreenArrow" },
		{ text = "Neon Pink Arrow" .. "|TInterface\\Addons\\KkthnxUI\\Media\\Nameplates\\NeonPinkArrow:0|t", value = "Interface\\Addons\\KkthnxUI\\Media\\Nameplates\\NeonPinkArrow" },
		{ text = "Neon Red Arrow" .. "|TInterface\\Addons\\KkthnxUI\\Media\\Nameplates\\NeonRedArrow:0|t", value = "Interface\\Addons\\KkthnxUI\\Media\\Nameplates\\NeonRedArrow" },
		{ text = "Neon Purple Arrow" .. "|TInterface\\Addons\\KkthnxUI\\Media\\Nameplates\\NeonPurpleArrow:0|t", value = "Interface\\Addons\\KkthnxUI\\Media\\Nameplates\\NeonPurpleArrow" },
		{ text = "Purple Arrow" .. "|TInterface\\Addons\\KkthnxUI\\Media\\Nameplates\\PurpleArrow:0|t", value = "Interface\\Addons\\KkthnxUI\\Media\\Nameplates\\PurpleArrow" },
		{ text = "Red Arrow 2" .. "|TInterface\\Addons\\KkthnxUI\\Media\\Nameplates\\RedArrow2.tga:0|t", value = "Interface\\Addons\\KkthnxUI\\Media\\Nameplates\\RedArrow2" },
		{ text = "Red Arrow" .. "|TInterface\\Addons\\KkthnxUI\\Media\\Nameplates\\RedArrow:0|t", value = "Interface\\Addons\\KkthnxUI\\Media\\Nameplates\\RedArrow" },
		{ text = "Red Chevron Arrow" .. "|TInterface\\Addons\\KkthnxUI\\Media\\Nameplates\\RedChevronArrow:0|t", value = "Interface\\Addons\\KkthnxUI\\Media\\Nameplates\\RedChevronArrow" },
		{ text = "Red Chevron Arrow2" .. "|TInterface\\Addons\\KkthnxUI\\Media\\Nameplates\\RedChevronArrow2:0|t", value = "Interface\\Addons\\KkthnxUI\\Media\\Nameplates\\RedChevronArrow2" },
	}
	GUI:CreateDropdown(indicatorsSection, "Nameplate.TargetIndicatorTexture", L["TargetIndicator Texture"], targetIndicatorTextureOptions, L["TargetIndicatorTexture Desc"])
	GUI:CreateColorPicker(indicatorsSection, "Nameplate.TargetIndicatorColor", L["TargetIndicator Color"], "Color for target indicators")

	-- Custom Lists
	local customListsSection = GUI:AddSection(nameplateCategory, L["Custom Lists"])
	-- REASON: The full add/remove editors (with portraits + default rows) live in ExtraGUI.
	-- Expose them through a Manage button rather than a clear-on-submit buffer input that hid the
	-- real list manager behind a cogwheel. The button configPath is a synthetic identifier so no
	-- redundant cogwheel attaches on top of the button.
	GUI:CreateButtonWidget(customListsSection, "Nameplate.CustomUnitListManage", L["Custom UnitColor List"], L["Open GUI"], L["CustomUnitTip"], function()
		if K.ExtraGUI and K.ExtraGUI.ToggleExtraConfig then
			K.ExtraGUI:ToggleExtraConfig("Nameplate.CustomUnitList", L["Custom UnitColor List"])
		end
	end)
	GUI:CreateButtonWidget(customListsSection, "Nameplate.PowerUnitListManage", L["Custom PowerUnit List"], L["Open GUI"], L["CustomUnitTip"], function()
		if K.ExtraGUI and K.ExtraGUI.ToggleExtraConfig then
			K.ExtraGUI:ToggleExtraConfig("Nameplate.PowerUnitList", L["Custom PowerUnit List"])
		end
	end)

	-- Castbar
	local castbarSection = GUI:AddSection(nameplateCategory, L["Castbar"])
	GUI:CreateSwitch(castbarSection, "Nameplate.CastTarget", L["Show Nameplate Target Of Casting Spell"], L["CastTarget Desc"])
	GUI:CreateSwitch(castbarSection, "Nameplate.CastOverlay", L["Cast In Front Of Nameplates"], L["Nameplate.CastOverlay Desc"])
	GUI:CreateSwitch(castbarSection, "Nameplate.CastbarGlow", L["Force Crucial Spells To Glow"], L["CastbarGlow Desc"])
	GUI:CreateSwitch(castbarSection, "Nameplate.HideNameWhileCasting", L["Hide Name While Casting"], L["HideNameWhileCasting Desc"])

	-- Threat
	local threatSection = GUI:AddSection(nameplateCategory, L["Threat"])
	GUI:CreateSwitch(threatSection, "Nameplate.DPSRevertThreat", L["Revert Threat Color If Not Tank"], L["Nameplate.DPSRevertThreat Desc"])
	GUI:CreateSwitch(threatSection, "Nameplate.TankMode", L["Force TankMode Colored"], L["Nameplate.TankMode Desc"])

	-- Quest
	local questNameplateSection = GUI:AddSection(nameplateCategory, L["GUI.Section.NameplateQuest"])
	GUI:CreateSwitch(questNameplateSection, "Nameplate.QuestIndicator", L["Quest Progress Indicator"], L["Nameplate.QuestIndicator Desc"])
	local questProgressModeOptions = {
		{ text = L["Always"], value = 1 },
		{ text = L["On Your Target"], value = 2 },
		{ text = L["On Mouseover"], value = 3 },
		{ text = L["While Holding a Key"], value = 4 },
		{ text = L["Never"], value = 5 },
	}
	GUI:CreateDropdown(questNameplateSection, "Nameplate.QuestProgressMode", L["Show Objective Progress"], questProgressModeOptions, L["Nameplate.QuestProgressMode Desc"])
	local questProgressKeyOptions = {
		{ text = L["Alt"], value = 1 },
		{ text = L["Ctrl"], value = 2 },
		{ text = L["Shift"], value = 3 },
	}
	GUI:CreateDropdown(questNameplateSection, "Nameplate.QuestProgressModifier", L["Progress Modifier Key"], questProgressKeyOptions, L["Nameplate.QuestProgressModifier Desc"])
	local questProgressFormatOptions = {
		{ text = L["Completed (3/7)"], value = 1 },
		{ text = L["Remaining (4)"], value = 2 },
	}
	GUI:CreateDropdown(questNameplateSection, "Nameplate.QuestProgressFormat", L["Progress Format"], questProgressFormatOptions, L["Nameplate.QuestProgressFormat Desc"])
	GUI:CreateSwitch(questNameplateSection, "Nameplate.QuestShowPartyQuest", L["Show Party Quests"], L["Nameplate.QuestShowPartyQuest Desc"])
	local questIndicatorStyleOptions = {
		{ text = "Standard", value = 1 },
		{ text = "Enhanced (Icons)", value = 2 },
	}
	GUI:CreateDropdown(questNameplateSection, "Nameplate.QuestIconStyle", L["Quest Icon Style"], questIndicatorStyleOptions, L["Nameplate.QuestIconStyle Desc"])

	-- Miscellaneous
	local miscellaneousNameplateSection = GUI:AddSection(nameplateCategory, L["Miscellaneous"])
	GUI:CreateSwitch(miscellaneousNameplateSection, "Nameplate.AKSProgress", L["Show AngryKeystones Progress"], L["Nameplate.AKSProgress Desc"])
	GUI:CreateSwitch(miscellaneousNameplateSection, "Nameplate.Smooth", L["Smooth Bars Transition"], L["Nameplate.Smooth Desc"])

	-- Sizes
	local sizesNameplateSection = GUI:AddSection(nameplateCategory, L["Sizes"])
	GUI:CreateSlider(sizesNameplateSection, "Nameplate.HealthTextSize", L["HealthText FontSize"], 8, 16, 1, L["Nameplate.HealthTextSize Desc"])
	GUI:CreateSlider(sizesNameplateSection, "Nameplate.MinAlpha", L["Non-Target Nameplate Alpha"], 0.1, 1, 0.1, L["Nameplate.MinAlpha Desc"])
	GUI:CreateSlider(sizesNameplateSection, "Nameplate.MinScale", L["Non-Target Nameplate Scale"], 0.1, 3, 0.1, L["Nameplate.MinScale Desc"])
	GUI:CreateSlider(sizesNameplateSection, "Nameplate.NameTextSize", L["NameText FontSize"], 8, 16, 1, L["Nameplate.NameTextSize Desc"])
	GUI:CreateSlider(sizesNameplateSection, "Nameplate.PlateHeight", L["Nameplate Height"], 6, 28, 1, L["Nameplate.PlateHeight Desc"])
	GUI:CreateSlider(sizesNameplateSection, "Nameplate.PlateWidth", L["Nameplate Width"], 80, 240, 1, L["Nameplate.PlateWidth Desc"])
	GUI:CreateSlider(sizesNameplateSection, "Nameplate.VerticalSpacing", L["Nameplate Vertical Spacing"], 0.5, 2.5, 0.1, L["Nameplate.VerticalSpacing Desc"])
	GUI:CreateSlider(sizesNameplateSection, "Nameplate.SelectedScale", L["Selected Nameplate Scale"], 1, 1.4, 0.1, L["SelectedScale Desc"])
	GUI:CreateSlider(sizesNameplateSection, "Nameplate.ExecuteRatio", L["Execute Ratio"], 0, 50, 1, L["Nameplate.ExecuteRatio Desc"])
	GUI:CreateSlider(sizesNameplateSection, "Nameplate.MaxAlpha", L["Nameplate Max Alpha"], 0.1, 1, 0.1, L["Nameplate.MaxAlpha Desc"])
	GUI:CreateSlider(sizesNameplateSection, "Nameplate.MaxScale", L["Nameplate Max Scale"], 0.1, 3, 0.1, L["Nameplate.MaxScale Desc"])

	-- Advanced / CVars
	local advancedNameplateSection = GUI:AddSection(nameplateCategory, L["GUI.Section.NameplateAdvanced"])
	GUI:CreateSwitch(advancedNameplateSection, "Nameplate.CVarOnlyNames", L["CVar Only Names"], L["Nameplate.CVarOnlyNames Desc"])
	GUI:CreateSwitch(advancedNameplateSection, "Nameplate.CVarShowNPCs", L["CVar Show NPCs"], L["Nameplate.CVarShowNPCs Desc"])
	GUI:CreateSwitch(advancedNameplateSection, "Nameplate.EnemyThru", L["Enemy Click-Through"], L["Nameplate.EnemyThru Desc"])
	GUI:CreateSwitch(advancedNameplateSection, "Nameplate.FriendlyThru", L["Friendly Click-Through"], L["Nameplate.FriendlyThru Desc"])
	GUI:CreateSlider(advancedNameplateSection, "Nameplate.HarmWidth", L["Enemy Clickable Width"], 100, 300, 1, L["Nameplate.HarmWidth Desc"])
	GUI:CreateSlider(advancedNameplateSection, "Nameplate.HarmHeight", L["Enemy Clickable Height"], 20, 100, 1, L["Nameplate.HarmHeight Desc"])
	GUI:CreateSlider(advancedNameplateSection, "Nameplate.HelpWidth", L["Friendly Clickable Width"], 100, 300, 1, L["Nameplate.HelpWidth Desc"])
	GUI:CreateSlider(advancedNameplateSection, "Nameplate.HelpHeight", L["Friendly Clickable Height"], 20, 100, 1, L["Nameplate.HelpHeight Desc"])

	-- Player Nameplate Toggles
	local playerTogglesSection = GUI:AddSection(nameplateCategory, L["Player Nameplate Toggles"])
	GUI:CreateSwitch(playerTogglesSection, "Nameplate.ShowPlayerPlate", enableTextColor .. L["Enable Personal Resource"], "Show your personal resource nameplate")
	local ppGcd = GUI:CreateSwitch(playerTogglesSection, "Nameplate.PPGCDTicker", L["Enable GCD Ticker"], L["Nameplate.PPGCDTicker Desc"])
	local ppHide = GUI:CreateSwitch(playerTogglesSection, "Nameplate.PPHideOOC", L["Only Visible in Combat"], L["Nameplate.PPHideOOC Desc"])
	local ppPower = GUI:CreateSwitch(playerTogglesSection, "Nameplate.PPPowerText", L["Show Power Value"], L["Nameplate.PPPowerText Desc"])
	GUI:DependsOn(ppGcd, "Nameplate.ShowPlayerPlate", true)
	GUI:DependsOn(ppHide, "Nameplate.ShowPlayerPlate", true)
	GUI:DependsOn(ppPower, "Nameplate.ShowPlayerPlate", true)

	-- Player Nameplate Values
	local playerValuesSection = GUI:AddSection(nameplateCategory, L["Player Nameplate Values"])
	local ppHeight = GUI:CreateSlider(playerValuesSection, "Nameplate.PPHeight", L["Classpower/Healthbar Height"], 4, 10, 1, L["Nameplate.PPHeight Desc"])
	local ppIcon = GUI:CreateSlider(playerValuesSection, "Nameplate.PPIconSize", L["PlayerPlate IconSize"], 20, 40, 1, L["Nameplate.PPIconSize Desc"])
	local pppHeight = GUI:CreateSlider(playerValuesSection, "Nameplate.PPPHeight", L["PlayerPlate Powerbar Height"], 4, 10, 1, L["Nameplate.PPPHeight Desc"])
	GUI:DependsOn(ppHeight, "Nameplate.ShowPlayerPlate", true)
	GUI:DependsOn(ppIcon, "Nameplate.ShowPlayerPlate", true)
	GUI:DependsOn(pppHeight, "Nameplate.ShowPlayerPlate", true)

	-- Colors
	local colorsNameplateSection = GUI:AddSection(nameplateCategory, COLORS)
	GUI:CreateColorPicker(colorsNameplateSection, "Nameplate.CustomColor", L["Custom Color"], "Color for custom units")
	GUI:CreateColorPicker(colorsNameplateSection, "Nameplate.InsecureColor", L["Insecure Color"], "Color for insecure threat level")
	GUI:CreateColorPicker(colorsNameplateSection, "Nameplate.OffTankColor", L["Off-Tank Color"], "Color for off-tank units")
	GUI:CreateColorPicker(colorsNameplateSection, "Nameplate.SecureColor", L["Secure Color"], "Color for secure threat level")
	GUI:CreateColorPicker(colorsNameplateSection, "Nameplate.TransColor", L["Transition Color"], "Color for threat transition states")
	GUI:CreateColorPicker(colorsNameplateSection, "Nameplate.ExecuteColor", "Execute Color", "Color for health bars in execute range")
	GUI:CreateColorPicker(colorsNameplateSection, "Nameplate.QuestSkullColor", "Quest Kill Color", "Color for quest kill objectives")
	GUI:CreateColorPicker(colorsNameplateSection, "Nameplate.QuestItemColor", "Quest Item Color", "Color for quest item objectives")
	GUI:CreateColorPicker(colorsNameplateSection, "Nameplate.QuestChatColor", "Quest Chat Color", "Color for quest interaction objectives")
end
