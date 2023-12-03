local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Loot")

-- Local references to global functions
local GetCVarBool = GetCVarBool
local GetNumLootItems = GetNumLootItems
local GetTime = GetTime
local IsModifiedClick = IsModifiedClick
local LootSlot = LootSlot
local GetItemInfo = GetItemInfo
local GetItemFamily = GetItemFamily
local C_Container_GetContainerNumFreeSlots = C_Container.GetContainerNumFreeSlots
local GetItemCount = GetItemCount
local PlaySound = PlaySound

-- Variable to store the time of the last loot action
local lootDelay = 0
local isItemLocked = false

-- Function to check if an item can be looted based on bag space and item type
local function CanLootItem(itemLink, itemQuantity)
	if not itemLink then
		-- print("Item link is nil.")
		return false
	end

	-- print("Checking if can loot item:", itemLink, itemQuantity)
	local itemStackSize, _, _, _, _, _, _, _, _, isCraftingReagent = select(8, GetItemInfo(itemLink))
	local itemFamily = GetItemFamily(itemLink)

	for i = BACKPACK_CONTAINER, NUM_TOTAL_EQUIPPED_BAG_SLOTS or NUM_BAG_SLOTS do
		local free, bagFamily = C_Container_GetContainerNumFreeSlots(i)
		if i == 5 then
			if isCraftingReagent and free > 0 then
				return true
			end
			break
		end

		if free > 0 then
			if not bagFamily or bagFamily == 0 or (itemFamily and bit.band(itemFamily, bagFamily) > 0) then
				return true
			end
		end
	end

	local inventoryItemCount = GetItemCount(itemLink)
	if inventoryItemCount > 0 and itemStackSize > 1 then
		if ((itemStackSize - inventoryItemCount) % itemStackSize) >= itemQuantity then
			return true
		end
	end

	return false
end

-- Function to play a sound when the inventory is full
local function PlayInventoryFullSound()
	-- if C["Loot"].EnableSound and not isItemLocked then
	if not isItemLocked then
		PlaySound(44321, "master") -- Replace 44321 with your preferred sound ID
	end
end

-- Function to handle error messages related to looting
local function HandleErrorMessage(_, event, errorType)
	-- print("Handling error message:", event, errorType)
	if tContains({ ERR_INV_FULL, ERR_ITEM_MAX_COUNT, ERR_LOOT_ROLL_PENDING }, errorType) then
		PlayInventoryFullSound()
	end
end

-- Function to handle faster looting
local function HandleFasterLoot()
	local thisTime = GetTime()

	if thisTime - lootDelay >= 0.3 then
		lootDelay = thisTime
		isItemLocked = false

		if GetCVarBool("autoLootDefault") ~= IsModifiedClick("AUTOLOOTTOGGLE") then
			for i = GetNumLootItems(), 1, -1 do
				local lootSlotType = GetLootSlotType(i)
				local itemLink = GetLootSlotLink(i)
				local lootQuantity, _, _, lootLocked = GetLootSlotInfo(i)

				if lootLocked then
					isItemLocked = true
				elseif lootSlotType ~= Enum.LootSlotType.Item or CanLootItem(itemLink, lootQuantity) then
					LootSlot(i)
				end
			end
			lootDelay = thisTime
		end
	end
end

-- Function to enable or disable faster loot based on the configuration
function Module:CreateFasterLoot()
	if C["Loot"].FastLoot then
		K:RegisterEvent("LOOT_READY", HandleFasterLoot)
		K:RegisterEvent("UI_ERROR_MESSAGE", HandleErrorMessage)
	else
		K:UnregisterEvent("LOOT_READY", HandleFasterLoot)
		K:UnregisterEvent("UI_ERROR_MESSAGE", HandleErrorMessage)
	end
end
