local K = KkthnxUI[1]
K.GUIBuilder = K.GUIBuilder or {}
local B = K.GUIBuilder

function B.CreateTooltipCategory()
	if not B or not B.Ready() then return end
	local K, GUI, C, L, enableTextColor = B.K, B.GUI, B.C, B.L, B.enableTextColor
	local GENERAL, COLORS, PLAYER, TARGET, FILTERS = B.GENERAL, B.COLORS, B.PLAYER, B.TARGET, B.FILTERS

	local tooltipIcon = "Interface\\Icons\\Inv_inscription_tooltip_darkmooncard_mop"
	local tooltipCategory = GUI:AddCategory(L["Tooltip"], tooltipIcon, "Tooltip")

	-- General
	local generalTooltipSection = GUI:AddSection(tooltipCategory, GENERAL)
	GUI:CreateSwitch(generalTooltipSection, "Tooltip.Enable", enableTextColor .. L["Enable Tooltip"], L["Enable Desc"])
	GUI:CreateSwitch(generalTooltipSection, "Tooltip.CombatHide", L["Hide Tooltip in Combat"], L["Tooltip.CombatHide Desc"])
	GUI:CreateSwitch(generalTooltipSection, "Tooltip.Icons", L["Item Icons"], L["Tooltip.Icons Desc"])
	GUI:CreateSwitch(generalTooltipSection, "Tooltip.ShowIDs", L["Show Tooltip IDs"], L["Tooltip.ShowIDs Desc"])
	GUI:CreateSwitch(generalTooltipSection, "Tooltip.ItemReagents", L["Show Crafting Reagents"], L["Tooltip.ItemReagents Desc"])

	-- Appearance
	local appearanceTooltipSection = GUI:AddSection(tooltipCategory, L["Appearance"])
	GUI:CreateSwitch(appearanceTooltipSection, "Tooltip.ClassColor", L["Quality Color Border"], L["Tooltip.ClassColor Desc"])
	GUI:CreateSwitch(appearanceTooltipSection, "Tooltip.FactionIcon", L["Show Faction Icon"], L["Tooltip.FactionIcon Desc"])
	GUI:CreateSwitch(appearanceTooltipSection, "Tooltip.HideJunkGuild", L["Abbreviate Guild Names"], L["Tooltip.HideJunkGuild Desc"])
	GUI:CreateSwitch(appearanceTooltipSection, "Tooltip.HideRank", L["Hide Guild Rank"], L["Tooltip.HideRank Desc"])
	GUI:CreateSwitch(appearanceTooltipSection, "Tooltip.HideRealm", L["Show realm name by SHIFT"], L["Tooltip.HideRealm Desc"])
	GUI:CreateSwitch(appearanceTooltipSection, "Tooltip.HideTitle", L["Hide Player Title"], L["Tooltip.HideTitle Desc"])

	local healthBarTextOptions = {
		{ text = L["Current / Max"] or "Current / Max", value = "currentmax" },
		{ text = L["Current Only"] or "Current Only", value = "current" },
	}
	GUI:CreateDropdown(appearanceTooltipSection, "Tooltip.HealthBarText", L["Health Bar Text"], healthBarTextOptions, L["Tooltip.HealthBarText Desc"])
	GUI:CreateSlider(appearanceTooltipSection, "Tooltip.StatusBarHeight", L["Status Bar Height"] or "Status Bar Height", 8, 24, 1, L["Tooltip.StatusBarHeight Desc"])

	-- Tooltip Anchor
	local tooltipAnchorOptions = {
		{ text = "TOPLEFT", value = 1 },
		{ text = "TOPRIGHT", value = 2 },
		{ text = "BOTTOMLEFT", value = 3 },
		{ text = "BOTTOMRIGHT", value = 4 },
	}
	GUI:CreateDropdown(appearanceTooltipSection, "Tooltip.TipAnchor", L["Tooltip Anchor"], tooltipAnchorOptions, L["TooltipAnchor Desc"])

	-- Advanced
	local advancedTooltipSection = GUI:AddSection(tooltipCategory, L["Advanced"])
	GUI:CreateSwitch(advancedTooltipSection, "Tooltip.ShowIDs", L["Show Tooltip IDs"], L["Tooltip.ShowIDs Desc"])
	GUI:CreateSwitch(advancedTooltipSection, "Tooltip.ItemReagents", L["Show Crafting Reagents"], L["Tooltip.ItemReagents Desc"])
	GUI:CreateSwitch(advancedTooltipSection, "Tooltip.Achievements", L["Show Achievement Status"], L["Tooltip.Achievements Desc"])
	GUI:CreateSwitch(advancedTooltipSection, "Tooltip.InstanceLock", L["Show Instance Lock Compare"], L["Tooltip.InstanceLock Desc"])
	GUI:CreateSwitch(advancedTooltipSection, "Tooltip.LFDRole", L["Show Roles Assigned Icon"], L["Tooltip.LFDRole Desc"])
	GUI:CreateSwitch(advancedTooltipSection, "Tooltip.SpecLevelByShift", L["Show Spec/ItemLevel by SHIFT"], L["Tooltip.SpecLevelByShift Desc"])
	GUI:CreateSwitch(advancedTooltipSection, "Tooltip.TargetBy", L["Show Player Targeted By"], L["Tooltip.TargetBy Desc"])
	GUI:CreateSwitch(advancedTooltipSection, "Tooltip.ShowMount", L["Show Mount"], L["Tooltip.ShowMount Desc"])
	local vendorLocationMap = GUI:CreateSwitch(advancedTooltipSection, "Tooltip.VendorLocationOpenMap", L["Open Map on Vendor Waypoint"], L["Tooltip.VendorLocationOpenMap Desc"])
	GUI:CreateSwitch(advancedTooltipSection, "Tooltip.VendorLocation", L["Show Vendor Locations"], L["Tooltip.VendorLocation Desc"])
	GUI:DependsOn(vendorLocationMap, "Tooltip.VendorLocation", true)

	-- Follow Cursor
	local cursorModeOptions = {
		{ text = DISABLE, value = 1 },
		{ text = "LEFT", value = 2 },
		{ text = "TOP", value = 3 },
		{ text = "RIGHT", value = 4 },
	}
	GUI:CreateDropdown(advancedTooltipSection, "Tooltip.CursorMode", L["Follow Cursor"], cursorModeOptions, L["Tooltip.CursorMode Desc"])

	-- RaiderIO
	if not K.CheckAddOnState("RaiderIO") then
		local raiderIOSection = GUI:AddSection(tooltipCategory, L["RaiderIO"])
		GUI:CreateSwitch(raiderIOSection, "Tooltip.MDScore", L["Show Mythic+ Rating"], L["Show Mythic+ Rating Desc"])
	end
end
