--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/Bags/Categories.lua
	Purpose:
		Sort each item into one of our display sections. The order here is the
		order the sections appear in the window, top to bottom. Classification
		reads the container and item data, so it stays correct as items load in.
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]

-- Match Core.lua: load wherever C_Container is present, not only on retail.
if not (C_Container and C_Container.GetContainerNumSlots) then
	return
end

local Module = K:GetModule("Bags")

local IsSecret = K.IsSecret
local Enum = Enum
local C_NewItems = C_NewItems
local GetContainerItemQuestInfo = C_Container.GetContainerItemQuestInfo
local GetItemInfoInstant = C_Item.GetItemInfoInstant

local ItemClass = Enum.ItemClass
local POOR = Enum.ItemQuality and Enum.ItemQuality.Poor or 0

-- The sections, in the order they render. key is used internally, name is shown.
Module.Categories = {
	{ key = "Favourites", name = L["Favourites"] },
	{ key = "New", name = L["New"] },
	{ key = "Equipment", name = L["Equipment"] },
	{ key = "Consumable", name = L["Consumables"] },
	{ key = "TradeGoods", name = L["Trade Goods"] },
	{ key = "ReagentBag", name = L["Reagent Bag"] },
	{ key = "GearEnhancement", name = L["Gear Enhancements"] },
	{ key = "Profession", name = L["Professions"] },
	{ key = "Housing", name = L["Housing"] },
	{ key = "Collectible", name = L["Collectibles"] },
	{ key = "Container", name = L["Bags"] },
	{ key = "Quest", name = L["Quest"] },
	{ key = "Miscellaneous", name = L["Miscellaneous"] },
	{ key = "Junk", name = L["Junk"] },
}

local next = next
local ipairs = ipairs
local pairs = pairs
local tsort = table.sort

-- Render order of the gear slots when the group-by-slot layout is on.
local GEAR_ORDER = {
	"Head", "Neck", "Shoulder", "Back", "Chest", "Wrist", "Hands", "Waist",
	"Legs", "Feet", "Ring", "Trinket", "Weapon", "Off Hand", "Ranged", "Shirt", "Tabard",
}

-- The render order, expanding Equipment into per-slot shelves when that layout is
-- on, and dropping any custom categories in just ahead of the Miscellaneous
-- catch-all so their assigned items lead it. Empty shelves render nothing.
function Module:OrderedCategories()
	local custom = C.Bags.CustomCategories
	local bySlot = C.Bags.GroupGearBySlot
	if (not custom or not next(custom)) and not bySlot then
		return self.Categories
	end

	local keys = {}
	if custom then
		for key in pairs(custom) do
			keys[#keys + 1] = key
		end
		tsort(keys, function(a, b)
			return custom[a] < custom[b]
		end)
	end

	local out = {}
	for _, cat in ipairs(self.Categories) do
		if cat.key == "Equipment" and bySlot then
			for _, slot in ipairs(GEAR_ORDER) do
				out[#out + 1] = { key = "Equipment:" .. slot, name = slot }
			end
		elseif cat.key == "Miscellaneous" then
			for _, key in ipairs(keys) do
				out[#out + 1] = { key = key, name = custom[key] }
			end
			out[#out + 1] = cat
		else
			out[#out + 1] = cat
		end
	end
	return out
end

-- Miscellaneous subclasses that are really collectibles (mounts and pets).
local MiscSub = Enum.ItemMiscellaneousSubclass
local COLLECTIBLE_MISC = {
	[MiscSub.CompanionPet] = true,
	[MiscSub.Mount] = true,
	[MiscSub.MountEquipment] = true,
}

-- Item classes that read as wearable gear.
local EQUIP_CLASS = {
	[ItemClass.Weapon] = true,
	[ItemClass.Armor] = true,
}

-- Equip location to a slot name, for the optional group-gear-by-slot layout.
local EQUIP_SLOT = {
	INVTYPE_HEAD = "Head",
	INVTYPE_NECK = "Neck",
	INVTYPE_SHOULDER = "Shoulder",
	INVTYPE_CLOAK = "Back",
	INVTYPE_CHEST = "Chest",
	INVTYPE_ROBE = "Chest",
	INVTYPE_BODY = "Shirt",
	INVTYPE_TABARD = "Tabard",
	INVTYPE_WRIST = "Wrist",
	INVTYPE_HAND = "Hands",
	INVTYPE_WAIST = "Waist",
	INVTYPE_LEGS = "Legs",
	INVTYPE_FEET = "Feet",
	INVTYPE_FINGER = "Ring",
	INVTYPE_TRINKET = "Trinket",
	INVTYPE_WEAPON = "Weapon",
	INVTYPE_2HWEAPON = "Weapon",
	INVTYPE_WEAPONMAINHAND = "Weapon",
	INVTYPE_WEAPONOFFHAND = "Weapon",
	INVTYPE_HOLDABLE = "Off Hand",
	INVTYPE_SHIELD = "Off Hand",
	INVTYPE_RANGED = "Ranged",
	INVTYPE_RANGEDRIGHT = "Ranged",
}

-- Raw crafting and gathering stock.
local TRADE_CLASS = {
	[ItemClass.Tradegoods] = true,
	[ItemClass.Reagent] = true,
}

-- Gems and enchants: things you slot or apply to gear, kept apart from raw
-- trade goods so upgrade mats are easy to find.
local ENHANCE_CLASS = {
	[ItemClass.Gem] = true,
	[ItemClass.ItemEnhancement] = true,
}

-- Recipes and profession tools/equipment.
local PROFESSION_CLASS = {
	[ItemClass.Recipe] = true,
	[ItemClass.Profession] = true,
}

-- The dedicated reagent pouch, so its contents can group as one shelf.
local REAGENT_BAG = Enum.BagIndex and Enum.BagIndex.ReagentBag or 5

-- Return the section key an item belongs to. bag/slot locate it, info is the
-- already fetched container info so callers do not query twice.
function Module:GetCategory(bag, slot, info)
	if not info then
		return "Miscellaneous"
	end

	local itemID = info.itemID
	if itemID and not IsSecret(itemID) then
		-- An explicit per-item assignment wins over the automatic sorting.
		local assigned = C.Bags.ItemAssignments and C.Bags.ItemAssignments[itemID]
		if assigned then
			return assigned
		end
		-- Player-pinned favourites sit above everything else.
		if C.Bags.Favorites[itemID] then
			return "Favourites"
		end
		-- Items the player flagged as junk sort with the rest of the trash.
		if C.Bags.JunkList and C.Bags.JunkList[itemID] then
			return "Junk"
		end
	end

	-- Anything sitting in the dedicated reagent bag groups together, so crafters
	-- can see that pouch as one shelf rather than scattered through Trade Goods.
	if C.Bags.ReagentBagSection and bag == REAGENT_BAG then
		return "ReagentBag"
	end

	-- Freshly looted items float to the top while the flag lasts.
	if C.Bags.ShowNewItems and C_NewItems and C_NewItems.IsNewItem and C_NewItems.IsNewItem(bag, slot) then
		return "New"
	end

	-- Grey items are junk, unless the client marked them worthless-but-not-grey.
	local quality = info.quality
	if not IsSecret(quality) and quality == POOR then
		return "Junk"
	end

	-- Quest items get their own shelf so they are easy to find.
	local quest = GetContainerItemQuestInfo and GetContainerItemQuestInfo(bag, slot)
	if quest and (quest.isQuestItem or quest.questID) then
		return "Quest"
	end

	if itemID and not IsSecret(itemID) then
		local _, _, _, equipLoc, _, classID, subclassID = GetItemInfoInstant(itemID)
		if classID == ItemClass.Questitem then
			return "Quest"
		elseif classID == ItemClass.Battlepet then
			return "Collectible"
		elseif classID == ItemClass.Miscellaneous and COLLECTIBLE_MISC[subclassID] then
			return "Collectible"
		elseif classID == ItemClass.Container or classID == ItemClass.Quiver then
			return "Container"
		elseif classID == ItemClass.Housing then
			return "Housing"
		elseif EQUIP_CLASS[classID] then
			-- Optionally split gear into its own per-slot shelves.
			if C.Bags.GroupGearBySlot then
				local gearSlot = EQUIP_SLOT[equipLoc]
				if gearSlot then
					return "Equipment:" .. gearSlot
				end
			end
			return "Equipment"
		elseif classID == ItemClass.Consumable then
			return "Consumable"
		elseif ENHANCE_CLASS[classID] then
			return "GearEnhancement"
		elseif PROFESSION_CLASS[classID] then
			return "Profession"
		elseif TRADE_CLASS[classID] then
			return "TradeGoods"
		end
	end

	return "Miscellaneous"
end
