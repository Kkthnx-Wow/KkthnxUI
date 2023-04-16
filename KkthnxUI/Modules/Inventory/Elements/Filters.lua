local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Bags")

local C_AzeriteEmpoweredItem_IsAzeriteEmpoweredItemByID = C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItemByID
local C_ToyBox_GetToyInfo = C_ToyBox.GetToyInfo

-- Custom filter
local CustomFilterList = {
	[37863] = false,
	[187532] = false,
	[141333] = true,
	[141446] = true,
	[153646] = true,
	[153647] = true,
	[161053] = true,
}

local isPetToy = {
	[174925] = true,
}

local petTrashCurrenies = {
	[3300] = true,
	[3670] = true,
	[6150] = true,
	[11406] = true,
	[11944] = true,
	[25402] = true,
	[36812] = true,
	[62072] = true,
	[67410] = true,
}

local iLvlClassIDs = {
	[Enum.ItemClass.Gem] = Enum.ItemGemSubclass.Artifactrelic,
	[Enum.ItemClass.Armor] = 0,
	[Enum.ItemClass.Weapon] = 0,
}

local collectionIDs = {
	[Enum.ItemMiscellaneousSubclass.Mount] = Enum.ItemClass.Miscellaneous,
	[Enum.ItemMiscellaneousSubclass.CompanionPet] = Enum.ItemClass.Miscellaneous,
}

local relicSpellIDs = {
	[356931] = true,
	[356933] = true,
	[356934] = true,
	[356935] = true,
	[356936] = true,
	[356937] = true,
	[356938] = true,
	[356939] = true,
	[356940] = true,
}

local consumableIDs = {
	[Enum.ItemClass.Consumable] = true,
	[Enum.ItemClass.ItemEnhancement] = true,
}

local function isCustomFilter(item)
	if not C["Inventory"].ItemFilter then
		return
	end

	return CustomFilterList[item.id]
end

-- Default filter
local function isItemInBag(item)
	return item.bagId >= 0 and item.bagId <= 4
end

local function isItemInBagReagent(item)
	return item.bagId == 5
end

local function isItemInBank(item)
	return item.bagId == -1 or (item.bagId > 5 and item.bagId < 13)
end

local function isItemJunk(item)
	if not C["Inventory"].ItemFilter then
		return
	end

	if not C["Inventory"].FilterJunk then
		return
	end

	return (item.quality == Enum.ItemQuality.Poor or KkthnxUIDB.Variables[K.Realm][K.Name].CustomJunkList[item.id]) and item.hasPrice and not Module:IsPetTrashCurrency(item.id)
end

local function isItemEquipSet(item)
	if not C["Inventory"].ItemFilter then
		return
	end

	if not C["Inventory"].FilterEquipSet then
		return
	end

	return item.isItemSet
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

	return C_AzeriteEmpoweredItem_IsAzeriteEmpoweredItemByID(item.link)
end

function Module:IsItemHasLevel(item)
	local index = iLvlClassIDs[item.classID]
	return index and (index == 0 or index == item.subClassID)
end

local function isItemEquipment(item)
	if not C["Inventory"].ItemFilter then
		return
	end

	if not C["Inventory"].FilterEquipment then
		return
	end

	return item.link and item.quality > Enum.ItemQuality.Common and Module:IsItemHasLevel(item)
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
	return isCustomFilter(item) or consumableIDs[item.classID]
end

local function isItemLegendary(item)
	if not C["Inventory"].ItemFilter then
		return
	end

	if not C["Inventory"].FilterLegendary then
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
	if not C["Inventory"].ItemFilter then
		return
	end

	if not C["Inventory"].FilterCollection then
		return
	end

	return item.id and C_ToyBox_GetToyInfo(item.id) or isMountOrPet(item)
end

local function isItemCustom(item, index)
	if not C["Inventory"].ItemFilter then
		return
	end
	if not C["Inventory"].FilterCustom then
		return
	end
	local customIndex = item.id and KkthnxUIDB.Variables[K.Realm][K.Name].CustomItems[item.id]
	return customIndex and customIndex == index
end

local emptyBags = { [0] = true, [11] = true }
local function isEmptySlot(item)
	if not C["Inventory"].GatherEmpty then
		return
	end

	return Module.initComplete and not item.texture and emptyBags[Module.BagsType[item.bagId]]
end

local function isTradeGoods(item)
	if not C["Inventory"].ItemFilter then
		return
	end

	if not C["Inventory"].FilterGoods then
		return
	end

	if isCustomFilter(item) == false then
		return
	end

	return item.classID == Enum.ItemClass.Tradegoods
end

local function isQuestItem(item)
	if not C["Inventory"].ItemFilter then
		return
	end

	if not C["Inventory"].FilterQuest then
		return
	end

	return item.questID or item.isQuestItem
end

local function isAnimaItem(item)
	if not C["Inventory"].ItemFilter then
		return
	end

	if not C["Inventory"].FilterAnima then
		return
	end

	if not item.link then
		return
	end

	return C_Item.IsAnimaItemByID(item.link)
end

local function isKorthiaRelicByID(itemID)
	local _, spellID = GetItemSpell(itemID)
	return spellID and relicSpellIDs[spellID]
end

local function isKorthiaRelic(item)
	if not C["Inventory"].ItemFilter then
		return
	end

	if not C["Inventory"].FilterRelic then
		return
	end

	return item.id and isKorthiaRelicByID(item.id)
end

local primordialStones = {}
for id = 204000, 204030 do
	primordialStones[id] = true
end
local function isPrimordialStone(item)
	if not C["Inventory"].ItemFilter then
		return
	end
	if not C["Inventory"].FilterStone then
		return
	end
	return item.id and primordialStones[item.id]
end

function Module:GetFilters()
	local filters = {}

	filters.onlyBags = function(item)
		return isItemInBag(item) and not isEmptySlot(item)
	end

	filters.bagAzeriteItem = function(item)
		return isItemInBag(item) and isAzeriteArmor(item)
	end

	filters.bagLegendary = function(item)
		return isItemInBag(item) and isItemLegendary(item)
	end

	filters.bagEquipment = function(item)
		return isItemInBag(item) and isItemEquipment(item)
	end

	filters.bagEquipSet = function(item)
		return isItemInBag(item) and isItemEquipSet(item)
	end

	filters.bagConsumable = function(item)
		return isItemInBag(item) and isItemConsumable(item)
	end

	filters.bagsJunk = function(item)
		return isItemInBag(item) and isItemJunk(item)
	end

	filters.bagStone = function(item)
		return isItemInBag(item) and isPrimordialStone(item)
	end

	filters.onlyBank = function(item)
		return isItemInBank(item) and not isEmptySlot(item)
	end

	filters.bankAzeriteItem = function(item)
		return isItemInBank(item) and isAzeriteArmor(item)
	end

	filters.bankLegendary = function(item)
		return isItemInBank(item) and isItemLegendary(item)
	end

	filters.bankEquipment = function(item)
		return isItemInBank(item) and isItemEquipment(item)
	end

	filters.bankEquipSet = function(item)
		return isItemInBank(item) and isItemEquipSet(item)
	end

	filters.bankConsumable = function(item)
		return isItemInBank(item) and isItemConsumable(item)
	end

	filters.onlyReagent = function(item)
		return item.bagId == -3 and not isEmptySlot(item)
	end

	filters.bagCollection = function(item)
		return isItemInBag(item) and isItemCollection(item)
	end

	filters.bankCollection = function(item)
		return isItemInBank(item) and isItemCollection(item)
	end

	filters.bagGoods = function(item)
		return isItemInBag(item) and isTradeGoods(item)
	end

	filters.bankGoods = function(item)
		return isItemInBank(item) and isTradeGoods(item)
	end

	filters.bagQuest = function(item)
		return isItemInBag(item) and isQuestItem(item)
	end

	filters.bankQuest = function(item)
		return isItemInBank(item) and isQuestItem(item)
	end

	filters.bagAnima = function(item)
		return isItemInBag(item) and isAnimaItem(item)
	end

	filters.bankAnima = function(item)
		return isItemInBank(item) and isAnimaItem(item)
	end

	filters.bagRelic = function(item)
		return isItemInBag(item) and isKorthiaRelic(item)
	end

	filters.onlyBagReagent = function(item)
		return isItemInBagReagent(item) and not isEmptySlot(item)
	end

	for i = 1, 5 do
		filters["bagCustom" .. i] = function(item)
			return isItemInBag(item) and isItemCustom(item, i)
		end

		filters["bankCustom" .. i] = function(item)
			return isItemInBank(item) and isItemCustom(item, i)
		end
	end

	return filters
end
