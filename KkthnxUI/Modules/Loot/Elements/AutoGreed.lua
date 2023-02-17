local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Loot")

-- Sourced: ShestakUI (Wetxius, Shestak)

local GetItemInfo = GetItemInfo
local GetLootRollItemInfo = GetLootRollItemInfo
local GetLootRollItemLink = GetLootRollItemLink
local MAX_PLAYER_LEVEL = MAX_PLAYER_LEVEL
local RollOnLoot = RollOnLoot

local function SetupAutoGreed(_, _, id)
	-- Get the loot roll item information
	local _, _, _, quality, BoP, _, _, canDisenchant = GetLootRollItemInfo(id)

	-- Check if the id is present and the quality is equal to 2
	if id and quality == 2 and not BoP then
		-- Get the loot roll item link
		local link = GetLootRollItemLink(id)
		-- Get the item name
		local itemName = GetItemInfo(link)
		-- Get the item information
		local _, _, _, ilevel = GetItemInfo(link)
		-- Check if the item can be disenchanted and its item level is greater than 270
		if canDisenchant and ilevel > 270 then
			-- Roll on the loot as greed
			RollOnLoot(id, 3)
			K.Print(format("Auto Greed: %s", itemName))
		else
			-- Roll on the loot as need
			RollOnLoot(id, 2)
			K.Print(format("Auto Greed: %s", itemName))
		end
	end
end

function Module:CreateAutoGreed()
	-- Check if auto greed is enabled and the player is at max level
	if not C["Loot"].AutoGreed or K.Level ~= MAX_PLAYER_LEVEL then
		return
	end

	-- Register the event to listen for the start of a loot roll
	K:RegisterEvent("START_LOOT_ROLL", SetupAutoGreed)
end
