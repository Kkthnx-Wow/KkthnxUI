local K, C = unpack(select(2, ...))
local Module = K:GetModule("Loot")

local _G = _G

local GetItemInfo = _G.GetItemInfo
local GetLootRollItemInfo = _G.GetLootRollItemInfo
local GetLootRollItemLink = _G.GetLootRollItemLink
local MAX_PLAYER_LEVEL = _G.MAX_PLAYER_LEVEL or 120

-- Sourced: Auto Greed/Disenchant on green items (Tekkub)
-- Sourced: NeedTheOrb (Myrilandell of Lothar)

-- Update this list as we go.
local NeedLootList = {
    33865, -- Amani Hex Stick
}

-- event returns: https://wow.gamepedia.com/START_LOOT_ROLL
local function SetupAutoGreed(_, id)
    local _, name, _, quality, BoP, canNeed, _, canDisenchant = GetLootRollItemInfo(id)
	if id and quality == 2 and not BoP then
		for i in pairs(NeedLootList) do
			local itemName = GetItemInfo(NeedLootList[i])
			if name == itemName and canNeed then
				_G.RollOnLoot(id, 1)
				return
			end
        end

		local link = GetLootRollItemLink(id)
		local _, _, _, ilevel = GetItemInfo(link)
		if canDisenchant and ilevel > 482 then -- Update this as needed.
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