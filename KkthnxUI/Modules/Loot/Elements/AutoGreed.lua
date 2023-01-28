local K, C = unpack(KkthnxUI)
local Module = K:GetModule("Loot")

-- Sourced: ShestakUI (Wetxius, Shestak)

local GetItemInfo = GetItemInfo
local GetLootRollItemInfo = GetLootRollItemInfo
local GetLootRollItemLink = GetLootRollItemLink
local MAX_PLAYER_LEVEL = MAX_PLAYER_LEVEL
local RollOnLoot = RollOnLoot

local function SetupAutoGreed(_, _, id)
	local _, _, _, quality, BoP, _, _, canDisenchant = GetLootRollItemInfo(id)
	if id and quality == 2 and not BoP then
		local link = GetLootRollItemLink(id)
		local _, _, _, ilevel = GetItemInfo(link)
		if canDisenchant and ilevel > 270 then
			RollOnLoot(id, 3)
		else
			RollOnLoot(id, 2)
		end
	end
end

function Module:CreateAutoGreed()
	if not C["Loot"].AutoGreed or K.Level ~= MAX_PLAYER_LEVEL then
		return
	end

	K:RegisterEvent("START_LOOT_ROLL", SetupAutoGreed)
end
