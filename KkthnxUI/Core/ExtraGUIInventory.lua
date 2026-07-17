---@diagnostic disable: undefined-global
local K = unpack(KkthnxUI)

--[[-----------------------------------------------------------------------------
-- ExtraGUIInventory
--
-- Registers inventory-related extra configuration panels for ExtraGUI.
--
-- REASON: The item filter panel was a long sequence of identical switches and
-- a reset button. Keeping the rows in data makes defaults, labels, and hooks
-- auditable without digging through a giant inline ExtraGUI registration block.
-----------------------------------------------------------------------------]]

local ExtraGUIInventory = {}
K.ExtraGUIInventory = ExtraGUIInventory

local filterRows = {
	{ "Inventory.FilterAOE", "Filter Warband BOE", "Filter Warband bind-on-equip items", true },
	{ "Inventory.FilterAnima", "Filter Anima Items", "Filter anima items into separate category", true },
	{ "Inventory.FilterAzerite", "Filter Azerite Items", "Filter azerite items into separate category", false },
	{ "Inventory.FilterCollection", "Filter Collection Items", "Filter collection items (pets, mounts, toys)", true },
	{ "Inventory.FilterConsumable", "Filter Consumables", "Filter consumable items (food, potions, etc.)", true },
	{ "Inventory.FilterDecor", "Filter Housing Decor", "Filter player housing decor items into a separate category", true },
	{ "Inventory.FilterEquipment", "Filter Equipment", "Filter equipment items", true },
	{ "Inventory.FilterEquipSet", "Filter Equipment Sets", "Filter equipment-set items into a separate category", false },
	{ "Inventory.FilterGoods", "Filter Trade Goods", "Filter trade goods and crafting materials", false },
	{ "Inventory.FilterJunk", "Filter Junk Items", "Filter junk items for easy selling", true },
	{ "Inventory.FilterQuest", "Filter Quest Items", "Filter quest items into separate category", true },
	{ "Inventory.FilterRecent", "Filter Recent Items", "Group newly looted items into a Recent Items category until clicked or sorted", true },
	{ "Inventory.FilterCustom", "Filter Custom Items", "Filter custom defined items", true },
	{ "Inventory.FilterLegendary", "Filter Legendary Items", "Filter legendary items", true },
	{ "Inventory.FilterLower", "Filter Lower Item Level", "Filter items with lower item level", true },
	{ "Inventory.FilterLegacy", "Filter Legacy Items", "Filter legacy items", false },
	{ "Inventory.FilterStone", "Filter Primordial Stones", "Filter primordial stones", true },
	{ "Inventory.FilterKeystone", "Filter Keystone Items", "Filter Mythic Keystone items", true },
}

local gatherEmptyRow = { "Inventory.GatherEmpty", "Gather Empty Slots", "Gather empty slots into one button" }

local function SetConfigValue(configPath, value, settingName)
	if K.NewGUI and K.NewGUI.SetConfigValue then
		K.NewGUI:SetConfigValue(configPath, value, false, settingName)
		return
	end

	K.GUIConfigService:SetValue(configPath, value)
end

function ExtraGUIInventory:Register(extraGUI)
	extraGUI:RegisterExtraConfig("Inventory.ItemFilter", function(parent)
		local yOffset = -10
		local widgets = {}

		for i = 1, #filterRows do
			local row = filterRows[i]
			local switch = extraGUI:CreateSwitch(parent, row[1], row[2], row[3])
			switch:SetPoint("TOPLEFT", 0, yOffset)
			widgets[#widgets + 1] = switch
			yOffset = yOffset - 35
		end

		local gatherEmptySwitch = extraGUI:CreateSwitch(parent, gatherEmptyRow[1], gatherEmptyRow[2], gatherEmptyRow[3])
		gatherEmptySwitch:SetPoint("TOPLEFT", 0, yOffset)
		widgets[#widgets + 1] = gatherEmptySwitch
		yOffset = yOffset - 35

		local resetButton = extraGUI:CreateButton(parent, "Reset Filters", 120, 25, function()
			for i = 1, #filterRows do
				local row = filterRows[i]
				SetConfigValue(row[1], row[4])
			end

			for i = 1, #widgets do
				widgets[i]:UpdateValue()
			end
		end)
		resetButton:SetPoint("TOPLEFT", 10, yOffset)
		yOffset = yOffset - 35

		parent:SetHeight(math.abs(yOffset) + 20)
	end, "Inventory Filters")
end

