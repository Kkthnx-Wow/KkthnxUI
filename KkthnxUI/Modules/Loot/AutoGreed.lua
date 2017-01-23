local K, C, L = unpack(select(2, ...))

local CreateFrame = CreateFrame
local GetLootRollItemInfo = GetLootRollItemInfo

-- Auto greed & disenchant on green items(by Tekkub) and NeedTheOrb(by Myrilandell of Lothar)
local frame = CreateFrame("Frame")
frame:RegisterEvent("START_LOOT_ROLL")
frame:SetScript("OnEvent", function(self, event, id)
    local _, name, _, quality, bop, _, _, canDisenchant = GetLootRollItemInfo(id)
    if C.Loot.AutoGreed and UnitLevel("player") == MAX_PLAYER_LEVEL and quality == 2 and not bop then
        if canDisenchant then
            RollOnLoot(id, 3)
        else
            RollOnLoot(id, 2)
        end
    end
end)