local K, C = unpack(select(2, ...))
local Module = K:GetModule("Loot")

local _G = _G

local GetItemInfo = _G.GetItemInfo
local GetLootRollItemInfo = _G.GetLootRollItemInfo
local GetLootRollItemLink = _G.GetLootRollItemLink
local MAX_PLAYER_LEVEL = _G.MAX_PLAYER_LEVEL

-- Sourced: ShestakUI (Wetxius, Shestak)

local function SetupAutoGreed(_, _, id)
    local _, _, _, quality, BoP, _, _, canDisenchant = GetLootRollItemInfo(id)
	if id and quality == 2 and not BoP then
		local link = GetLootRollItemLink(id)
		local _, _, _, ilevel = GetItemInfo(link)
		if canDisenchant and ilevel > 270 then
			_G.RollOnLoot(id, 3)
		else
			_G.RollOnLoot(id, 2)
		end
	end
end

function Module:CreateAutoGreed()
    if C["Loot"].AutoGreed ~= true or K.Level ~= MAX_PLAYER_LEVEL then
        return
	end

    K:RegisterEvent("START_LOOT_ROLL", SetupAutoGreed)
end