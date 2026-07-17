local K = KkthnxUI[1]
K.GUIBuilder = K.GUIBuilder or {}
local B = K.GUIBuilder

function B.CreateLootCategory()
	if not B or not B.Ready() then return end
	local K, GUI, C, L, enableTextColor = B.K, B.GUI, B.C, B.L, B.enableTextColor
	local GENERAL, COLORS, PLAYER, TARGET, FILTERS = B.GENERAL, B.COLORS, B.PLAYER, B.TARGET, B.FILTERS

	local lootIcon = "Interface\\Icons\\INV_Misc_Coin_02"
	local lootCategory = GUI:AddCategory(L["Loot"], lootIcon, "Loot")

	-- General
	local generalLootSection = GUI:AddSection(lootCategory, GENERAL)
	GUI:CreateSwitch(generalLootSection, "Loot.Enable", enableTextColor .. L["Enable Loot"], L["Enable Desc"])
	GUI:CreateSwitch(generalLootSection, "Loot.GroupLoot", enableTextColor .. L["Enable Group Loot"], L["GroupLoot Desc"])

	-- Auto-Loot
	local autoLootingSection = GUI:AddSection(lootCategory, L["Auto-Looting"])
	GUI:CreateSwitch(autoLootingSection, "Loot.FastLoot", L["Faster Auto-Looting"], L["FastLoot Desc"])

	-- Auto-Confirming
	local autoConfirmSection = GUI:AddSection(lootCategory, L["Auto-Confirm"])
	GUI:CreateSwitch(autoConfirmSection, "Loot.AutoConfirm", L["Auto Confirm Loot Dialogs"], L["Loot.AutoConfirm Desc"])
	GUI:CreateSwitch(autoConfirmSection, "Loot.AutoGreed", L["Auto Greed Green Items"], L["AutoGreed Desc"])
	local preferDE = GUI:CreateSwitch(autoConfirmSection, "Loot.AutoGreedPreferDE", L["Prefer Disenchant"], L["AutoGreedPreferDE Desc"])
	local includeRares = GUI:CreateSwitch(autoConfirmSection, "Loot.AutoGreedIncludeRares", L["Include Rares"], L["AutoGreedIncludeRares Desc"])
	local skipBoP = GUI:CreateSwitch(autoConfirmSection, "Loot.AutoGreedSkipBoP", L["Skip Bind on Pickup"], L["AutoGreedSkipBoP Desc"])
	local maxLevel = GUI:CreateSwitch(autoConfirmSection, "Loot.AutoGreedMaxLevelOnly", L["Max Level Only"], L["AutoGreedMaxLevelOnly Desc"])
	local greedConfirm = GUI:CreateSwitch(autoConfirmSection, "Loot.AutoGreedAutoConfirm", L["Auto-Confirm Auto Greed"], L["AutoGreedAutoConfirm Desc"])
	GUI:DependsOn(preferDE, "Loot.AutoGreed", true)
	GUI:DependsOn(includeRares, "Loot.AutoGreed", true)
	GUI:DependsOn(skipBoP, "Loot.AutoGreed", true)
	GUI:DependsOn(maxLevel, "Loot.AutoGreed", true)
	GUI:DependsOn(greedConfirm, "Loot.AutoGreed", true)
end
