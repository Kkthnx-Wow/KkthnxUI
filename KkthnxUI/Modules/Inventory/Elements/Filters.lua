--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Defines logical item filters for virtual bag categorization.
-- - Design: Uses cargBags filter system to group items by type, quality, or custom flags.
-- - Events: N/A (Functional library)
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Bags")

-- PERF: Cache global references to avoid hashtable lookups during high-volume item filtering.
-- REASON: These C_ functions are called repeatedly for every item in every bag during initialization and updates.
local _G = _G
local C_AzeriteEmpoweredItem_IsAzeriteEmpoweredItemByID = _G.C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItemByID
local C_ToyBox_GetToyInfo = _G.C_ToyBox.GetToyInfo
local C_Item_IsAnimaItemByID = _G.C_Item.IsAnimaItemByID
local C_Item_IsItemKeystoneByID = _G.C_Item.IsItemKeystoneByID

-- FIX: Fallback for 'LE_EXPANSION_WAR_WITHIN' if not defined in older clients (though this is 11.0 code).
local CURRENT_EXPANSION = _G.LE_EXPANSION_WAR_WITHIN or 10 -- 11.0
local Enum = _G.Enum
local REAGENT_BAG = (Enum.BagIndex and Enum.BagIndex.ReagentBag) or 5
local BACKPACK_MAX = (Enum.BagIndex and Enum.BagIndex.Bag_5 and (Enum.BagIndex.Bag_5 - 1)) or 4

local CustomFilterList = {
	[37863] = false,
	[187532] = false,
	[141333] = true,
	[141446] = true,
	[153646] = true,
	[153647] = true,
	[161053] = true,
	[224185] = true, -- Coffer Key Shard
}

local isPetToy = {
	[174925] = true, -- Noxious Breath
}

local petTrashCurrenies = {
	[3300] = true, -- Rabbit's Foot
	[3670] = true, -- Large Slimy Bone
	[6150] = true, -- A Frayed Knot
	[11406] = true, -- Rotting Bear Carcass"
	[11944] = true, -- Dark Iron Baby Booties
	[25402] = true, -- The Stoppable Force
	[30507] = true, -- Lucky Rock
	[36812] = true, -- Ground Gear
	[62072] = true, -- Robble's Wobbly Staff
	[67410] = true, -- Very Unlucky Rock
	[190382] = true, -- Warped Pocket Dimension
}

local collectionIDs = {
	[Enum.ItemMiscellaneousSubclass.Mount] = Enum.ItemClass.Miscellaneous,
	[Enum.ItemMiscellaneousSubclass.CompanionPet] = Enum.ItemClass.Miscellaneous,
}

local consumableIDs = {
	[Enum.ItemClass.Consumable] = true,
	[Enum.ItemClass.ItemEnhancement] = true,
}

-- REASON: Dragonflight Primordial Stones specific logic.
local primordialStones = {}
for id = 204000, 204030 do
	primordialStones[id] = true
end
for id = 204573, 204579 do
	primordialStones[id] = true
end
primordialStones[203703] = true -- 棱光碎片

local emptyBags = { [0] = true, [11] = true }

local function hasReagentBagEquipped()
	return C_Container.GetContainerNumSlots(REAGENT_BAG) > 0
end

local function CheckFilterSetting(setting)
	-- REASON: Central check to ensure main 'ItemFilter' toggle is enabled before checking specific sub-filters.
	return C["Inventory"].ItemFilter and C["Inventory"][setting]
end

local function isCustomFilter(item)
	if not C["Inventory"].ItemFilter then
		return
	end

	return CustomFilterList[item.id]
end

local function isItemInBag(item)
	-- REASON: Validate item is in standard bag slots (Backpack to Bag 4/5).
	return item.bagId >= 0 and item.bagId <= BACKPACK_MAX
end

local function isItemInBagReagent(item)
	return item.bagId == REAGENT_BAG
end

local function isItemInBank(item)
	-- REASON: Bag IDs 6-12 are Bank bags; -1 is the main Bank window.
	return item.bagId == -1 or (item.bagId > 5 and item.bagId < 13)
end

local function isItemInAccountBank(item)
	-- REASON: Warband Bank (Account Bank) uses Bag IDs 13-17.
	return item.bagId > 12 and item.bagId < 18
end

local function isItemJunk(item)
	if not CheckFilterSetting("FilterJunk") then
		return
	end

	-- PERF: Retrieve character-specific junk list on demand.
	local vars = K.GetCharVars()
	local isCustomJunk = vars and vars.CustomJunkList and vars.CustomJunkList[item.id]
	return (item.quality == Enum.ItemQuality.Poor or isCustomJunk) and item.hasPrice and not Module:IsPetTrashCurrency(item.id)
end

local function isItemEquipSet(item)
	if not CheckFilterSetting("FilterEquipSet") then
		return
	end

	-- REASON: Specifically checks for items that are part of a user-defined Equipment Set.
	return item.isItemSet
end

local function isAzeriteArmor(item)
	if not CheckFilterSetting("FilterAzerite") or not item.link then
		return
	end

	return C_AzeriteEmpoweredItem_IsAzeriteEmpoweredItemByID(item.link)
end

local function CheckEquip(item)
	return item.link and item.quality > Enum.ItemQuality.Common and item.ilvl
end

local function isItemEquipment(item)
	if not CheckFilterSetting("FilterEquipment") then
		return
	end

	return CheckEquip(item)
end

local function isItemLegacy(item)
	if not CheckFilterSetting("FilterLegacy") then
		return
	end

	-- REASON: Checks if item belongs to a previous expansion relative to 'CURRENT_EXPANSION'.
	-- This helps separate active gear from legacy collectible or sentimental items.
	return CheckEquip(item) and item.expacID and item.expacID < CURRENT_EXPANSION
end

local function isItemLowerLevel(item)
	if not CheckFilterSetting("FilterLower") then
		return
	end

	-- REASON: Filters equipment below a user-configured item level threshold.
	return CheckEquip(item) and item.ilvl < C["Inventory"].iLvlToShow
end

local function isItemConsumable(item)
	if not CheckFilterSetting("FilterConsumable") then
		return
	end

	if isCustomFilter(item) == false then
		-- REASON: Explicitly excluded by 'CustomFilterList'.
		return
	end
	return isCustomFilter(item) or consumableIDs[item.classID]
end

local function isItemLegendary(item)
	if not CheckFilterSetting("FilterLegendary") then
		return
	end

	return item.quality == Enum.ItemQuality.Legendary
end

local function isMountOrPet(item)
	return not isPetToy[item.id] and item.subClassID and collectionIDs[item.subClassID] == item.classID
end

function Module:IsPetTrashCurrency(itemID)
	return C["Inventory"].PetTrash and petTrashCurrenies[itemID]
end

local function isItemCollection(item)
	if not CheckFilterSetting("FilterCollection") then
		return
	end

	return item.id and C_ToyBox_GetToyInfo(item.id) or isMountOrPet(item)
end

local function isItemCustom(item, index)
	if not CheckFilterSetting("FilterCustom") then
		return
	end

	-- REASON: Checks against user-defined custom categories (1-5).
	local vars = K.GetCharVars()
	local customIndex = vars and vars.CustomItems and vars.CustomItems[item.id]
	return customIndex and customIndex == index
end

local function isEmptySlot(item)
	if not C["Inventory"].GatherEmpty then
		return
	end

	return Module.initComplete and not item.texture and emptyBags[Module.BagsType[item.bagId]]
end

local function isTradeGoods(item)
	if not CheckFilterSetting("FilterGoods") then
		return
	end

	-- REASON: Identifies items belonging to the 'Trade Goods' category.
	return item.classID == Enum.ItemClass.Tradegoods
end

local function isQuestItem(item)
	if not CheckFilterSetting("FilterQuest") then
		return
	end

	-- REASON: Identifies items explicitly marked as Quest items, including those that start quests.
	return item.questID or item.isQuestItem
end

local function isAnimaItem(item)
	if not CheckFilterSetting("FilterAnima") or not item.link then
		return
	end

	return C_Item_IsAnimaItemByID(item.link)
end

local function isPrimordialStone(item)
	if not CheckFilterSetting("FilterStone") then
		return
	end
	return item.id and primordialStones[item.id]
end

local function isItemKeystone(item)
	if not CheckFilterSetting("FilterKeystone") then
		return
	end

	if isCustomFilter(item) == false then
		return
	end

	if item.id and C_Item_IsItemKeystoneByID(item.id) then
		return true
	end
	return item.classID == Enum.ItemClass.Reagent and item.subClassID == Enum.ItemReagentSubclass.Keystone
end

local function isWarboundUntilEquipped(item)
	if not CheckFilterSetting("FilterAOE") then
		return
	end
	-- REASON: 'accountequip' is the internal binding type for Warbound items.
	return item.bindOn and item.bindOn == "accountequip"
end

local function CreateLocationFilter(locationCheck, typeCheck)
	-- REASON: Returns a closure that combines location validation with type checking.
	-- PERF: Avoids redundant conditional logic in the main loop by baking the structure here.
	if typeCheck then
		return function(item)
			return locationCheck(item) and typeCheck(item)
		end
	else
		return function(item)
			return locationCheck(item) and not isEmptySlot(item)
		end
	end
end

function Module:GetFilters()
	local filters = {}

	filters.onlyBags = CreateLocationFilter(isItemInBag)
	filters.bagAzeriteItem = CreateLocationFilter(isItemInBag, isAzeriteArmor)
	filters.bagEquipment = CreateLocationFilter(isItemInBag, isItemEquipment)
	filters.bagEquipSet = CreateLocationFilter(isItemInBag, isItemEquipSet)
	filters.bagConsumable = CreateLocationFilter(isItemInBag, isItemConsumable)
	filters.bagKeystone = CreateLocationFilter(isItemInBag, isItemKeystone)
	filters.bagsJunk = CreateLocationFilter(isItemInBag, isItemJunk)
	filters.bagCollection = CreateLocationFilter(isItemInBag, isItemCollection)
	filters.bagGoods = CreateLocationFilter(isItemInBag, isTradeGoods)
	filters.bagQuest = CreateLocationFilter(isItemInBag, isQuestItem)
	filters.bagAnima = CreateLocationFilter(isItemInBag, isAnimaItem)
	filters.bagStone = CreateLocationFilter(isItemInBag, isPrimordialStone)
	filters.bagAOE = CreateLocationFilter(isItemInBag, isWarboundUntilEquipped)
	filters.bagLower = CreateLocationFilter(isItemInBag, isItemLowerLevel)
	filters.bagLegacy = CreateLocationFilter(isItemInBag, isItemLegacy)

	filters.onlyBank = CreateLocationFilter(isItemInBank)
	filters.bankAzeriteItem = CreateLocationFilter(isItemInBank, isAzeriteArmor)
	filters.bankLegendary = CreateLocationFilter(isItemInBank, isItemLegendary)
	filters.bankEquipment = CreateLocationFilter(isItemInBank, isItemEquipment)
	filters.bankEquipSet = CreateLocationFilter(isItemInBank, isItemEquipSet)
	filters.bankConsumable = CreateLocationFilter(isItemInBank, isItemConsumable)
	filters.bankCollection = CreateLocationFilter(isItemInBank, isItemCollection)
	filters.bankGoods = CreateLocationFilter(isItemInBank, isTradeGoods)
	filters.bankQuest = CreateLocationFilter(isItemInBank, isQuestItem)
	filters.bankAnima = CreateLocationFilter(isItemInBank, isAnimaItem)
	filters.bankAOE = CreateLocationFilter(isItemInBank, isWarboundUntilEquipped)
	filters.bankLower = CreateLocationFilter(isItemInBank, isItemLowerLevel)
	filters.bankLegacy = CreateLocationFilter(isItemInBank, isItemLegacy)

	filters.onlyReagent = function(item)
		return item.bagId == -3 and not isEmptySlot(item)
	end -- reagent bank
	filters.onlyBagReagent = function(item)
		return (isItemInBagReagent(item) and not isEmptySlot(item)) or (hasReagentBagEquipped() and isItemInBag(item) and isTradeGoods(item))
	end -- reagent bagslot

	filters.accountbank = CreateLocationFilter(isItemInAccountBank)
	filters.accountEquipment = CreateLocationFilter(isItemInAccountBank, isItemEquipment)
	filters.accountConsumable = CreateLocationFilter(isItemInAccountBank, isItemConsumable)
	filters.accountGoods = CreateLocationFilter(isItemInAccountBank, isTradeGoods)
	filters.accountAOE = CreateLocationFilter(isItemInAccountBank, isWarboundUntilEquipped)
	filters.accountLegacy = CreateLocationFilter(isItemInAccountBank, isItemLegacy)

	-- REASON: Custom filters (dynamic generation)
	for i = 1, 5 do
		local customIndex = i -- Capture for closure
		filters["bagCustom" .. i] = function(item)
			return (isItemInBag(item) or isItemInBagReagent(item)) and isItemCustom(item, customIndex)
		end
		filters["bankCustom" .. i] = function(item)
			return isItemInBank(item) and isItemCustom(item, customIndex)
		end
		filters["accountCustom" .. i] = function(item)
			return isItemInAccountBank(item) and isItemCustom(item, customIndex)
		end
	end

	return filters
end
