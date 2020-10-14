local K, C = unpack(select(2, ...))
local Module = K:GetModule("Bags")

local _G = _G

local C_AzeriteEmpoweredItem_IsAzeriteEmpoweredItemByID = _G.C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItemByID
local EJ_LOOT_SLOT_FILTER_ARTIFACT_RELIC = _G.EJ_LOOT_SLOT_FILTER_ARTIFACT_RELIC
local LE_ITEM_CLASS_ARMOR = _G.LE_ITEM_CLASS_ARMOR
local LE_ITEM_CLASS_CONSUMABLE = _G.LE_ITEM_CLASS_CONSUMABLE
local LE_ITEM_CLASS_ITEM_ENHANCEMENT = _G.LE_ITEM_CLASS_ITEM_ENHANCEMENT
local LE_ITEM_CLASS_MISCELLANEOUS = _G.LE_ITEM_CLASS_MISCELLANEOUS
local LE_ITEM_CLASS_TRADEGOODS = _G.LE_ITEM_CLASS_TRADEGOODS
local LE_ITEM_CLASS_WEAPON = _G.LE_ITEM_CLASS_WEAPON
local LE_ITEM_MISCELLANEOUS_COMPANION_PET = _G.LE_ITEM_MISCELLANEOUS_COMPANION_PET
local LE_ITEM_MISCELLANEOUS_MOUNT = _G.LE_ITEM_MISCELLANEOUS_MOUNT

-- Custom filter
local CustomFilterList = {
	[141333] = true, -- Codex of the Tranquil Mind
	[141446] = true, -- Tome of the Tranquil Mind
	[153646] = true, -- Codex of the Quiet Mind
	[153647] = true, -- Tome of the Quiet Mind
	[161053] = true, -- Salty Dog Crackers
	[37863] = false, -- Direbrew's Remote
}

local isPetToy = {
	[174925] = true,
}

local function isCustomFilter(item)
	if not C["Inventory"].ItemFilter then
		return
	end

	return CustomFilterList[item.id]
end

-- Default filter
local function isItemInBag(item)
	return item.bagID >= 0 and item.bagID <= 4
end

local function isItemInBank(item)
	return item.bagID == -1 or item.bagID >= 5 and item.bagID <= 11
end

local function isItemJunk(item)
	if not C["Inventory"].ItemFilter then
		return
	end

	if not C["Inventory"].FilterJunk then
		return
	end

	return (item.rarity == LE_ITEM_QUALITY_POOR or KkthnxUIData[K.Realm][K.Name].CustomJunkList[item.id]) and item.sellPrice and item.sellPrice > 0
end

local function isAzeriteArmor(item)
	if not C["Inventory"].ItemFilter then
		return
	end

	if not C["Inventory"].FilterAzerite then
		return
	end

	if not item.link then
		return
	end

	return C_AzeriteEmpoweredItem_IsAzeriteEmpoweredItemByID(item.link) and not (C["Inventory"].ItemSetFilter and item.isInSet)
end

local function isItemEquipment(item)
	if not C["Inventory"].ItemFilter then
		return
	end

	if not C["Inventory"].FilterEquipment then
		return
	end

	if C["Inventory"].ItemSetFilter then
		return item.isInSet
	else
		return item.level and item.rarity > LE_ITEM_QUALITY_COMMON and (item.subType == EJ_LOOT_SLOT_FILTER_ARTIFACT_RELIC or item.classID == LE_ITEM_CLASS_WEAPON or item.classID == LE_ITEM_CLASS_ARMOR)
	end
end

local function isItemConsumable(item)
	if not C["Inventory"].ItemFilter then
		return
	end

	if not C["Inventory"].FilterConsumable then
		return
	end

	if isCustomFilter(item) == false then
		return
	end

	return isCustomFilter(item) or (item.classID and (item.classID == LE_ITEM_CLASS_CONSUMABLE or item.classID == LE_ITEM_CLASS_ITEM_ENHANCEMENT))
end

local function isItemLegendary(item)
	if not C["Inventory"].ItemFilter then
		return
	end

	if not C["Inventory"].FilterLegendary then
		return
	end

	return item.rarity == LE_ITEM_QUALITY_LEGENDARY
end

local function isMountAndPet(item)
	if not C["Inventory"].ItemFilter then
		return
	end

	if not C["Inventory"].FilterMount then
		return
	end

	return (not isPetToy[item.id]) and item.classID == LE_ITEM_CLASS_MISCELLANEOUS and (item.subClassID == LE_ITEM_MISCELLANEOUS_MOUNT or item.subClassID == LE_ITEM_MISCELLANEOUS_COMPANION_PET)
end

local function isItemFavourite(item)
	if not C["Inventory"].ItemFilter then
		return
	end

	if not C["Inventory"].FilterFavourite then
		return
	end

	return item.id and KkthnxUIData[K.Realm][K.Name].FavouriteItems[item.id]
end

local function isEmptySlot(item)
	if not C["Inventory"].GatherEmpty then
		return
	end

	return Module.initComplete and not item.texture and Module.BagsType[item.bagID] == 0
end

local function isTradeGoods(item)
	if not C["Inventory"].ItemFilter then
		return
	end

	if not C["Inventory"].FilterGoods then
		return
	end

	return item.classID == LE_ITEM_CLASS_TRADEGOODS
end

local function isItemQuest(item)
	if not C["Inventory"].ItemFilter then
		return
	end

	if not C["Inventory"].FilterQuest then
		return
	end

	return item.classID == LE_ITEM_CLASS_QUESTITEM
end

function Module:GetFilters()
	local filters = {}

	filters.onlyBags = function(item) return isItemInBag(item) and not isItemEquipment(item) and not isItemLegendary(item) and not isItemConsumable(item) and not isAzeriteArmor(item) and not isItemJunk(item) and not isMountAndPet(item) and not isItemFavourite(item) and not isEmptySlot(item) and not isTradeGoods(item) and not isItemQuest(item) end
	filters.bagAzeriteItem = function(item) return isItemInBag(item) and isAzeriteArmor(item) end
	filters.bagEquipment = function(item) return isItemInBag(item) and isItemEquipment(item) end
	filters.bagConsumable = function(item) return isItemInBag(item) and isItemConsumable(item) end
	filters.bagsJunk = function(item) return isItemInBag(item) and isItemJunk(item) end
	filters.onlyBank = function(item) return isItemInBank(item) and not isItemEquipment(item) and not isItemLegendary(item) and not isItemConsumable(item) and not isAzeriteArmor(item) and not isMountAndPet(item) and not isItemFavourite(item) and not isEmptySlot(item) and not isTradeGoods(item) and not isItemQuest(item) end
	filters.bankAzeriteItem = function(item) return isItemInBank(item) and isAzeriteArmor(item) end
	filters.bagLegendary = function(item) return isItemInBag(item) and isItemLegendary(item) end
	filters.bankLegendary = function(item) return isItemInBank(item) and isItemLegendary(item) end
	filters.bankEquipment = function(item) return isItemInBank(item) and isItemEquipment(item) end
	filters.bankConsumable = function(item) return isItemInBank(item) and isItemConsumable(item) end
	filters.onlyReagent = function(item) return item.bagID == -3 and not isEmptySlot(item) end
	filters.bagMountPet = function(item) return isItemInBag(item) and isMountAndPet(item) end
	filters.bankMountPet = function(item) return isItemInBank(item) and isMountAndPet(item) end
	filters.bagFavourite = function(item) return isItemInBag(item) and isItemFavourite(item) end
	filters.bankFavourite = function(item) return isItemInBank(item) and isItemFavourite(item) end
	filters.bagGoods = function(item) return isItemInBag(item) and isTradeGoods(item) end
	filters.bankGoods = function(item) return isItemInBank(item) and isTradeGoods(item) end
	filters.bagQuest = function(item) return isItemInBag(item) and isItemQuest(item) end
	filters.bankQuest = function(item) return isItemInBank(item) and isItemQuest(item) end

	return filters
end