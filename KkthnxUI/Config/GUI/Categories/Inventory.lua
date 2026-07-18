local K = KkthnxUI[1]
K.GUIBuilder = K.GUIBuilder or {}
local B = K.GUIBuilder

function B.CreateInventoryCategory()
	if not B or not B.Ready() then return end
	local K, GUI, C, L, enableTextColor = B.K, B.GUI, B.C, B.L, B.enableTextColor
	local GENERAL, COLORS, PLAYER, TARGET, FILTERS = B.GENERAL, B.COLORS, B.PLAYER, B.TARGET, B.FILTERS

	local inventoryIcon = "Interface\\Icons\\INV_Misc_Bag_07"
	local inventoryCategory = GUI:AddCategory(L["Inventory"], inventoryIcon, "Inventory")

	-- General
	local generalInventorySection = GUI:AddSection(inventoryCategory, GENERAL)
	GUI:CreateSwitch(generalInventorySection, "Inventory.Enable", enableTextColor .. L["Enable Inventory"], L["Inventory.Enable Desc"] or L["Enable Desc"])
	GUI:CreateSwitch(generalInventorySection, "Inventory.AutoSell", L["Auto Vendor Grays"], L["Inventory.AutoSell Desc"])

	-- Bags Section
	local bagsSection = GUI:AddSection(inventoryCategory, L["Bags"])
	GUI:CreateSwitch(bagsSection, "Inventory.ColorUnusableItems", L["Color Unusable Items"], L["ColorUnusableItems Desc"])
	GUI:CreateSwitch(bagsSection, "Inventory.BagsBindOnEquip", L["Display Bind Status"], L["BagsBindOnEquip Desc"])
	GUI:CreateSwitch(bagsSection, "Inventory.BagsItemLevel", L["Display Item Level"], L["BagsItemLevel Desc"])
	GUI:CreateSwitch(bagsSection, "Inventory.DeleteButton", L["Bags Delete Button"], L["Inventory.DeleteButton Desc"])
	GUI:CreateSwitch(bagsSection, "Inventory.DeleteCheapest", L["Delete Cheapest"], L["Inventory.DeleteCheapest Desc"])
	local dcConsumable = GUI:CreateSwitch(bagsSection, "Inventory.DeleteCheapestFilterConsumable", L["Protect Consumables"], L["Inventory.DeleteCheapestFilterConsumable Desc"])
	local dcContainer = GUI:CreateSwitch(bagsSection, "Inventory.DeleteCheapestFilterContainer", L["Protect Containers"], L["Inventory.DeleteCheapestFilterContainer Desc"])
	local dcWeapon = GUI:CreateSwitch(bagsSection, "Inventory.DeleteCheapestFilterWeapon", L["Protect Weapons"], L["Inventory.DeleteCheapestFilterWeapon Desc"])
	local dcArmor = GUI:CreateSwitch(bagsSection, "Inventory.DeleteCheapestFilterArmor", L["Protect Armor"], L["Inventory.DeleteCheapestFilterArmor Desc"])
	local dcReagent = GUI:CreateSwitch(bagsSection, "Inventory.DeleteCheapestFilterReagent", L["Protect Reagents"], L["Inventory.DeleteCheapestFilterReagent Desc"])
	local dcTradeskill = GUI:CreateSwitch(bagsSection, "Inventory.DeleteCheapestFilterTradeskill", L["Protect Trade Goods"], L["Inventory.DeleteCheapestFilterTradeskill Desc"])
	local dcQuest = GUI:CreateSwitch(bagsSection, "Inventory.DeleteCheapestFilterQuest", L["Protect Quest Items"], L["Inventory.DeleteCheapestFilterQuest Desc"])
	GUI:DependsOn(dcConsumable, "Inventory.DeleteCheapest", true)
	GUI:DependsOn(dcContainer, "Inventory.DeleteCheapest", true)
	GUI:DependsOn(dcWeapon, "Inventory.DeleteCheapest", true)
	GUI:DependsOn(dcArmor, "Inventory.DeleteCheapest", true)
	GUI:DependsOn(dcReagent, "Inventory.DeleteCheapest", true)
	GUI:DependsOn(dcTradeskill, "Inventory.DeleteCheapest", true)
	GUI:DependsOn(dcQuest, "Inventory.DeleteCheapest", true)
	GUI:CreateSwitch(bagsSection, "Inventory.ReverseSort", L["Reverse the Sorting"], L["ReverseSort Desc"])
	GUI:CreateSwitch(bagsSection, "Inventory.ShowNewItem", L["Show New Item Glow"], L["Inventory.ShowNewItem Desc"])
	GUI:CreateSwitch(bagsSection, "Inventory.UpgradeIcon", L["Show Upgrade Icon"], L["Inventory.UpgradeIcon Desc"])
	GUI:CreateSwitch(bagsSection, "Inventory.SpecialBagsColor", L["Special Bags Color"], L["Inventory.SpecialBagsColor Desc"])
	GUI:CreateSlider(bagsSection, "Inventory.BagsPerRow", L["Bags Per Row"], 1, 20, 1, L["BagsPerRow Desc"])
	GUI:CreateSlider(bagsSection, "Inventory.iLvlToShow", "ItemLevel Threshold", 1, 800, 1, L["iLvlToShow Desc"])

	-- Bank Section
	local bankSection = GUI:AddSection(inventoryCategory, BANK)
	GUI:CreateSlider(bankSection, "Inventory.BankPerRow", L["Bank Bags Per Row"], 1, 20, 1, L["BankPerRow Desc"])

	-- Other Section
	local otherInventorySection = GUI:AddSection(inventoryCategory, OTHER)
	GUI:CreateSwitch(otherInventorySection, "Inventory.PetTrash", L["Pet Trash Currencies"], L["Inventory.PetTrash Desc"])

	-- Auto Repair
	local autoRepairOptions = {
		{ text = GUILD, value = 1 },
		{ text = PLAYER, value = 2 },
		{ text = DISABLE, value = 3 },
	}
	GUI:CreateDropdown(otherInventorySection, "Inventory.AutoRepair", L["Auto Repair Gear"], autoRepairOptions, L["Inventory.AutoRepair Desc"])

	local warbandGoldSwitch = GUI:CreateSwitch(otherInventorySection, "Inventory.AutoWarbandGold", L["Auto Warband Gold"], L["Inventory.AutoWarbandGold Desc"])
	local warbandTargetSlider = GUI:CreateSlider(otherInventorySection, "Inventory.WarbandGoldTarget", L["Warband Gold Target"], 100, 1000000, 100, L["Inventory.WarbandGoldTarget Desc"])
	local warbandWithdrawSwitch = GUI:CreateSwitch(otherInventorySection, "Inventory.WarbandGoldWithdraw", L["Warband Gold Withdraw"], L["Inventory.WarbandGoldWithdraw Desc"])
	GUI:DependsOn(warbandTargetSlider, "Inventory.AutoWarbandGold", true, nil, L["Auto Warband Gold"])
	GUI:DependsOn(warbandWithdrawSwitch, "Inventory.AutoWarbandGold", true, nil, L["Auto Warband Gold"])

	-- Filters
	local filtersSection = GUI:AddSection(inventoryCategory, FILTERS)
	local _ = GUI:CreateSwitch(filtersSection, "Inventory.ItemFilter", L["Filter Items Into Categories"], L["ItemFilter Desc"])
	local gatherEmptySwitch = GUI:CreateSwitch(filtersSection, "Inventory.GatherEmpty", L["Gather Empty Slots Into One Button"], L["GatherEmpty Desc"])
	-- Dependency: Only allow Gather Empty when ItemFilter is enabled
	GUI:DependsOn(gatherEmptySwitch, "Inventory.ItemFilter", true, nil, L["Filter Items Into Categories"])

	-- Sizes
	local inventorySizesSection = GUI:AddSection(inventoryCategory, L["Sizes"])
	GUI:CreateSlider(inventorySizesSection, "Inventory.BagsWidth", L["Bags Width"], 8, 16, 1, L["BagsWidth Desc"])
	GUI:CreateSlider(inventorySizesSection, "Inventory.BankWidth", L["Bank Width"], 10, 18, 1, L["BankWidth Desc"])
	GUI:CreateSlider(inventorySizesSection, "Inventory.IconSize", L["Slot Icon Size"], 28, 40, 1, L["IconSize Desc"])

	-- Bag Bar
	local bagBarSection = GUI:AddSection(inventoryCategory, L["Bag Bar"])
	GUI:CreateSwitch(bagBarSection, "Inventory.BagBar", enableTextColor .. L["Enable Bagbar"], L["BagBar Desc"])
	GUI:CreateSwitch(bagBarSection, "Inventory.BagBarMouseover", L["Bag Bar Mouseover"], L["Inventory.BagBarMouseover Desc"])
	GUI:CreateSwitch(bagBarSection, "Inventory.JustBackpack", L["Just Show Main Backpack"], L["JustBackpack Desc"])
	GUI:CreateSlider(bagBarSection, "Inventory.BagBarSize", L["BagBar Size"], 20, 34, 1, L["BagBarSize Desc"])

	-- Growth
	local growthDirectionOptions = {
		{ text = "Horizontal", value = 1 },
		{ text = "Vertical", value = 2 },
	}
	GUI:CreateDropdown(bagBarSection, "Inventory.GrowthDirection", L["Growth Direction"], growthDirectionOptions, L["GrowthDirection Desc"])

	-- Sort
	local sortDirectionOptions = {
		{ text = "Ascending", value = 1 },
		{ text = "Descending", value = 2 },
	}
	GUI:CreateDropdown(bagBarSection, "Inventory.SortDirection", L["Sort Direction"], sortDirectionOptions, L["Inventory.SortDirection Desc"])
end
