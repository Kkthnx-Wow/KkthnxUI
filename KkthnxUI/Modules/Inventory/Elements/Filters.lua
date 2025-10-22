local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Bags")

-- Cache global references
local C_AzeriteEmpoweredItem_IsAzeriteEmpoweredItemByID = C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItemByID
local C_ToyBox_GetToyInfo = C_ToyBox.GetToyInfo
local C_Item_IsAnimaItemByID = C_Item.IsAnimaItemByID
local C_Item_GetItemSpell = C_Item.GetItemSpell
local string_lower = string.lower
local type = type
local CURRENT_EXPANSION = LE_EXPANSION_WAR_WITHIN or 10 -- 11.0

-- Cache character database reference (updated on PLAYER_LOGIN via UpdateCharDB)
local charDB

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

local toyBlackList = {
	[167698] = true, -- 隐秘之鱼护目镜
}

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

	local isCustomJunk = KkthnxUIDB.Variables[K.Realm][K.Name].CustomJunkList[item.id]
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

local function CheckEquip(item)
	return item.link and item.quality > Enum.ItemQuality.Common and item.ilvl
end

local function isItemEquipment(item)
	if not C["Inventory"].ItemFilter or not C["Inventory"].FilterEquipment or not item.link or item.quality <= Enum.ItemQuality.Common then
		return
	end

	return CheckEquip(item)
end

local function isItemLegacy(item)
	if not C["Inventory"].ItemFilter then
		return
	end
	if not C["Inventory"].FilterLegacy then
		return
	end
	return CheckEquip(item) and item.expacID and item.expacID < CURRENT_EXPANSION
end

local function isItemLowerLevel(item)
	if not C["Inventory"].ItemFilter then
		return
	end

	if not C["Inventory"].FilterLower then
		return
	end

	return CheckEquip(item) and item.ilvl < C["Inventory"].iLvlToShow
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

	local customIndex = KkthnxUIDB.Variables[K.Realm][K.Name].CustomItems[item.id]
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

-- Filter factory functions (reusable, optimized)
local function CreateLocationFilter(locationCheck, typeCheck)
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

-- Main Module Filters (using factory pattern)
function Module:GetFilters()
	local filters = {}

	-- Bag filters
	filters.onlyBags = CreateLocationFilter(isItemInBag)
	filters.bagAzeriteItem = CreateLocationFilter(isItemInBag, isAzeriteArmor)
	filters.bagEquipment = CreateLocationFilter(isItemInBag, isItemEquipment)
	filters.bagEquipSet = CreateLocationFilter(isItemInBag, isItemEquipSet)
	filters.bagConsumable = CreateLocationFilter(isItemInBag, isItemConsumable)
	filters.bagsJunk = CreateLocationFilter(isItemInBag, isItemJunk)
	filters.bagCollection = CreateLocationFilter(isItemInBag, isItemCollection)
	filters.bagGoods = CreateLocationFilter(isItemInBag, isTradeGoods)
	filters.bagQuest = CreateLocationFilter(isItemInBag, isQuestItem)
	filters.bagAnima = CreateLocationFilter(isItemInBag, isAnimaItem)
	filters.bagStone = CreateLocationFilter(isItemInBag, isPrimordialStone)
	filters.bagAOE = CreateLocationFilter(isItemInBag, isWarboundUntilEquipped)
	filters.bagLower = CreateLocationFilter(isItemInBag, isItemLowerLevel)
	filters.bagLegacy = CreateLocationFilter(isItemInBag, isItemLegacy)

	-- Bank filters
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

	-- Reagent filters
	filters.onlyBagReagent = function(item)
		return (isItemInBagReagent(item) and not isEmptySlot(item)) or (hasReagentBagEquipped() and isItemInBag(item) and isTradeGoods(item))
	end

	-- Account bank filters
	filters.accountbank = CreateLocationFilter(isItemInAccountBank)
	filters.accountEquipment = CreateLocationFilter(isItemInAccountBank, isItemEquipment)
	filters.accountConsumable = CreateLocationFilter(isItemInAccountBank, isItemConsumable)
	filters.accountGoods = CreateLocationFilter(isItemInAccountBank, isTradeGoods)
	filters.accountAOE = CreateLocationFilter(isItemInAccountBank, isWarboundUntilEquipped)
	filters.accountLegacy = CreateLocationFilter(isItemInAccountBank, isItemLegacy)

	-- Custom filters (dynamic generation)
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
