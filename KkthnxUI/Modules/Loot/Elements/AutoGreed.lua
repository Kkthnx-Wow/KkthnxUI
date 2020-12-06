local K, C = unpack(select(2, ...))
local Module = K:GetModule("Loot")

-- Sourced: ShestakUI (Wetxius, Shestak)

local _G = _G

local GetItemInfo = _G.GetItemInfo
local GetLootRollItemInfo = _G.GetLootRollItemInfo
local GetLootRollItemLink = _G.GetLootRollItemLink
local MAX_PLAYER_LEVEL = _G.MAX_PLAYER_LEVEL
local RollOnLoot = _G.RollOnLoot

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