local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Bags")

-- Cache global references
local C_AzeriteEmpoweredItem_IsAzeriteEmpoweredItemByID = C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItemByID
local C_ToyBox_GetToyInfo = C_ToyBox.GetToyInfo
local C_Item_IsAnimaItemByID = C_Item.IsAnimaItemByID
local C_Item_GetItemSpell = C_Item.GetItemSpell

-- Custom filter lists
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

local primordialStones = {}
for id = 204000, 204030 do
	primordialStones[id] = true
end
for id = 204573, 204579 do
	primordialStones[id] = true
end
primordialStones[203703] = true -- 棱光碎片

local emptyBags = { [0] = true, [11] = true }

-- Function Definitions
local function hasReagentBagEquipped()
	return ContainerFrame_GetContainerNumSlots(5) > 0
end

local function isCustomFilter(item)
	if not C["Inventory"].ItemFilter then
		return
	end

	return CustomFilterList[item.id]
end

local function isItemInBag(item)
	return item.bagId >= 0 and item.bagId <= 4
end

local function isItemInBagReagent(item)
	return item.bagId == 5
end

local function isItemInBank(item)
	return (item.bagId > 5 and item.bagId < 12)
end

local function isItemInAccountBank(item)
	return item.bagId > 11 and item.bagId < 17
end

local function isItemJunk(item)
	if not C["Inventory"].ItemFilter or not C["Inventory"].FilterJunk then
		return
	end

	-- Optimized short-circuiting for database access
	local isCustomJunk = KkthnxUIDB and KkthnxUIDB.Variables and KkthnxUIDB.Variables[K.Realm] and KkthnxUIDB.Variables[K.Realm][K.Name] and KkthnxUIDB.Variables[K.Realm][K.Name].CustomJunkList[item.id]

	return (item.quality == Enum.ItemQuality.Poor or isCustomJunk) and item.hasPrice and not Module:IsPetTrashCurrency(item.id)
end

local function isItemEquipSet(item)
	if not C["Inventory"].ItemFilter or not C["Inventory"].FilterEquipSet then
		return
	end

	return item.isInSet
end

local function isAzeriteArmor(item)
	if not C["Inventory"].ItemFilter or not C["Inventory"].FilterAzerite or not item.link then
		return
	end

	return C_AzeriteEmpoweredItem_IsAzeriteEmpoweredItemByID(item.link)
end

local function isItemEquipment(item)
	if not C["Inventory"].ItemFilter or not C["Inventory"].FilterEquipment or not item.link or item.quality <= Enum.ItemQuality.Common then
		return
	end

	return item.link and item.quality > Enum.ItemQuality.Common and item.ilvl
end

local function isItemLowerLevel(item)
	if not C["Inventory"].ItemFilter then
		return
	end

	if not C["Inventory"].FilterLower then
		return
	end

	return item.link and item.quality > Enum.ItemQuality.Common and item.ilvl and item.ilvl < C["Inventory"].iLvlToShow
end

local function isItemConsumable(item)
	if not C["Inventory"].ItemFilter or not C["Inventory"].FilterConsumable then
		return
	end

	if isCustomFilter(item) == false then
		return
	end
	return isCustomFilter(item) or consumableIDs[item.classID]
end

local function isItemLegendary(item)
	if not C["Inventory"].ItemFilter or not C["Inventory"].FilterLegendary then
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

local toyBlackList = {
	[167698] = true, -- 隐秘之鱼护目镜
}

local function isItemCollection(item)
	if not C["Inventory"].ItemFilter or not C["Inventory"].FilterCollection then
		return
	end

	return item.id and C_ToyBox_GetToyInfo(item.id) and not toyBlackList[item.id] or isMountOrPet(item)
end

local function isItemCustom(item, index)
	if not C["Inventory"].ItemFilter or not C["Inventory"].FilterCustom then
		return
	end

	-- Optimized short-circuiting for database access
	local customIndex = KkthnxUIDB and KkthnxUIDB.Variables and KkthnxUIDB.Variables[K.Realm] and KkthnxUIDB.Variables[K.Realm][K.Name] and KkthnxUIDB.Variables[K.Realm][K.Name].CustomItems[item.id]

	return customIndex and customIndex == index
end

local function isEmptySlot(item)
	if not C["Inventory"].GatherEmpty then
		return
	end

	return Module.initComplete and not item.texture
end

local function isTradeGoods(item)
	if not C["Inventory"].ItemFilter or not C["Inventory"].FilterGoods then
		return
	end

	if isCustomFilter(item) == false then
		return
	end

	return item.classID == Enum.ItemClass.Tradegoods
end

local function isQuestItem(item)
	if not C["Inventory"].ItemFilter or not C["Inventory"].FilterQuest then
		return
	end

	return item.questID or item.isQuestItem
end

local function isAnimaItem(item)
	if not C["Inventory"].ItemFilter or not C["Inventory"].FilterAnima or not item.link then
		return
	end

	return C_Item_IsAnimaItemByID(item.link)
end

local function isPrimordialStone(item)
	if not C["Inventory"].ItemFilter or not C["Inventory"].FilterStone then
		return
	end
	return item.id and primordialStones[item.id]
end

local function isWarboundUntilEquipped(item)
	if not C["Inventory"].ItemFilter or not C["Inventory"].FilterAOE then
		return
	end
	return item.bindOn and item.bindOn == "accountequip"
end

-- Main Module Filters
function Module:GetFilters()
	local filters = {}

	filters.onlyBags = function(item)
		return isItemInBag(item) and not isEmptySlot(item)
	end
	filters.bagAzeriteItem = function(item)
		return isItemInBag(item) and isAzeriteArmor(item)
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
	filters.bagCollection = function(item)
		return isItemInBag(item) and isItemCollection(item)
	end
	filters.bagGoods = function(item)
		return isItemInBag(item) and isTradeGoods(item)
	end
	filters.bagQuest = function(item)
		return isItemInBag(item) and isQuestItem(item)
	end
	filters.bagAnima = function(item)
		return isItemInBag(item) and isAnimaItem(item)
	end
	filters.bagStone = function(item)
		return isItemInBag(item) and isPrimordialStone(item)
	end
	filters.bagAOE = function(item)
		return isItemInBag(item) and isWarboundUntilEquipped(item)
	end
	filters.bagLower = function(item)
		return isItemInBag(item) and isItemLowerLevel(item)
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
	filters.bankCollection = function(item)
		return isItemInBank(item) and isItemCollection(item)
	end
	filters.bankGoods = function(item)
		return isItemInBank(item) and isTradeGoods(item)
	end
	filters.bankQuest = function(item)
		return isItemInBank(item) and isQuestItem(item)
	end
	filters.bankAnima = function(item)
		return isItemInBank(item) and isAnimaItem(item)
	end
	filters.bankAOE = function(item)
		return isItemInBank(item) and isWarboundUntilEquipped(item)
	end
	filters.bankLower = function(item)
		return isItemInBank(item) and isItemLowerLevel(item)
	end

	filters.onlyBagReagent = function(item)
		return (isItemInBagReagent(item) and not isEmptySlot(item)) or (hasReagentBagEquipped() and isItemInBag(item) and isTradeGoods(item))
	end -- reagent bagslot

	filters.accountbank = function(item)
		return isItemInAccountBank(item) and not isEmptySlot(item)
	end
	filters.accountEquipment = function(item)
		return isItemInAccountBank(item) and isItemEquipment(item)
	end
	filters.accountConsumable = function(item)
		return isItemInAccountBank(item) and isItemConsumable(item)
	end
	filters.accountGoods = function(item)
		return isItemInAccountBank(item) and isTradeGoods(item)
	end
	filters.accountAOE = function(item)
		return isItemInAccountBank(item) and isWarboundUntilEquipped(item)
	end

	for i = 1, 5 do
		filters["bagCustom" .. i] = function(item)
			return (isItemInBag(item) or isItemInBagReagent(item)) and isItemCustom(item, i)
		end
		filters["bankCustom" .. i] = function(item)
			return isItemInBank(item) and isItemCustom(item, i)
		end
		filters["accountCustom" .. i] = function(item)
			return isItemInAccountBank(item) and isItemCustom(item, i)
		end
	end

	return filters
end
