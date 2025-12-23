local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Loot")

-- Sourced: ShestakUI (Wetxius, Shestak)

local C_Item_GetItemInfo = C_Item.GetItemInfo
local GetLootRollItemInfo = GetLootRollItemInfo
local GetLootRollItemLink = GetLootRollItemLink
local RollOnLoot = RollOnLoot

local function SetupAutoGreed(_, _, id)
	local _, _, _, quality, BoP, _, _, canDisenchant = GetLootRollItemInfo(id)
	if id and quality == 2 and not BoP then
		local link = GetLootRollItemLink(id)
		local _, _, _, ilevel = C_Item_GetItemInfo(link)
		if canDisenchant and ilevel > 270 then
			RollOnLoot(id, 3)
		else
			RollOnLoot(id, 2)
		end
	end
end

function Module:CreateAutoGreed()
	local maxLevel = GetMaxLevelForExpansionLevel(GetExpansionLevel())
	if not C["Loot"].AutoGreed or K.Level ~= maxLevel then
		return
	end

	K:RegisterEvent("START_LOOT_ROLL", SetupAutoGreed)
end
