local K = KkthnxUI[1]
K.GUIBuilder = K.GUIBuilder or {}
local B = K.GUIBuilder

function B.CreatePartyCategory()
	if not B or not B.Ready() then return end
	local K, GUI, C, L, enableTextColor = B.K, B.GUI, B.C, B.L, B.enableTextColor
	local GENERAL, COLORS, PLAYER, TARGET, FILTERS = B.GENERAL, B.COLORS, B.PLAYER, B.TARGET, B.FILTERS

	local partyIcon = "Interface\\Icons\\Ships_ability_boardingparty"
	local partyCategory = GUI:AddCategory(L["Party"], partyIcon, "Party")

	-- General Section
	local generalPartySection = GUI:AddSection(partyCategory, GENERAL)
	GUI:CreateSwitch(generalPartySection, "Party.Enable", enableTextColor .. L["Enable Party"], "Toggle the entire party frame system on/off")
	GUI:CreateButtonWidget(generalPartySection, "Party.ManageSimpleParty", L["Simple Party Options"], L["Open GUI"], L["Party.ManageSimpleParty Desc"], function()
		if K.ExtraGUI and K.ExtraGUI.ToggleExtraConfig then
			K.ExtraGUI:ToggleExtraConfig("Party.Enable", L["Simple Party Frames"])
		end
	end)
	GUI:CreateSwitch(generalPartySection, "Party.ShowBuffs", L["Show Party Buffs"], L["Party.ShowBuffs Desc"])
	GUI:CreateSwitch(generalPartySection, "Party.ShowHealPrediction", L["Show HealPrediction Statusbars"], L["Party.ShowHealPrediction Desc"])
	GUI:CreateSwitch(generalPartySection, "Party.ShowPartySolo", L["Show Party Frames While Solo"], L["ShowPartySolo Desc"])
	GUI:CreateSwitch(generalPartySection, "Party.ShowPet", L["Show Party Pets"], L["Party.ShowPet Desc"])
	GUI:CreateSwitch(generalPartySection, "Party.ShowPlayer", L["Show Player In Party"], L["Party.ShowPlayer Desc"])
	GUI:CreateSwitch(generalPartySection, "Party.Smooth", L["Smooth Bar Transition"], L["Party.Smooth Desc"])
	GUI:CreateSwitch(generalPartySection, "Party.TargetHighlight", L["Show Highlighted Target"], L["Party.TargetHighlight Desc"])
	GUI:CreateSwitch(generalPartySection, "Party.DispelIcon", L["Raid Dispel Type Icons"], L["Party.DispelIcon Desc"])
	local partyDispelAll = GUI:CreateSwitch(generalPartySection, "Party.DispelIconAll", L["Show All Dispellable Debuffs"], L["Party.DispelIconAll Desc"])
	GUI:DependsOn(partyDispelAll, "Party.DispelIcon", true)

	-- Party Castbars Section
	local castbarsPartySection = GUI:AddSection(partyCategory, L["Party Castbars"])
	GUI:CreateSwitch(castbarsPartySection, "Party.Castbars", L["Show Castbars"], L["Party.Castbars Desc"])
	GUI:CreateSwitch(castbarsPartySection, "Party.CastbarIcon", L["Show Castbars"] .. " Icon", L["Party.CastbarIcon Desc"])

	-- Sizes Section
	local sizesPartySection = GUI:AddSection(partyCategory, L["Sizes"])
	GUI:CreateSlider(sizesPartySection, "Party.HealthHeight", L["Party Frame Health Height"], 20, 50, 1, L["Party.HealthHeight Desc"])
	GUI:CreateSlider(sizesPartySection, "Party.HealthWidth", L["Party Frame Health Width"], 120, 180, 1, L["Party.HealthWidth Desc"])
	GUI:CreateSlider(sizesPartySection, "Party.PowerHeight", L["Party Frame Power Height"], 10, 30, 1, L["Party.PowerHeight Desc"])

	-- Colors Section
	local colorsPartySection = GUI:AddSection(partyCategory, COLORS)
	local healthColorOptions = { -- Health Color Format Dropdown Options
		{ text = "Class", value = 1 },
		{ text = "Dark", value = 2 },
		{ text = "Value", value = 3 },
	}
	GUI:CreateDropdown(colorsPartySection, "Party.HealthbarColor", L["Health Color Format"], healthColorOptions, L["Party.HealthbarColor Desc"])
end
