local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Loot")

-- Globals -> locals (perf / safety)
local GetExpansionLevel = GetExpansionLevel
local GetLootRollItemInfo = GetLootRollItemInfo
local GetLootRollItemLink = GetLootRollItemLink
local GetMaxLevelForExpansionLevel = GetMaxLevelForExpansionLevel
local RollOnLoot = RollOnLoot

local Item_CreateFromItemLink = Item.CreateFromItemLink

-- Roll types: 0/nil pass, 1 need, 2 greed, 3 disenchant
local ROLL_GREED = 2
local ROLL_DISENCHANT = 3

-- Adjust/make this a real config field if you want
local DEFAULT_DE_ILVL_CUTOFF = 0 -- 0 = "if DE is available, always DE"

local function SetupAutoGreed(_, rollID)
	if not rollID then
		return
	end

	-- texture, name, count, quality, bindOnPickUp, canNeed, canGreed, canDisenchant, ...
	local _, _, _, quality, bindOnPickUp, _, canGreed, canDisenchant = GetLootRollItemInfo(rollID)

	-- If Need is possible, never auto-roll. Let the player decide.
	if canNeed then
		return
	end

	-- Uncommon only + skip BoP (your original behavior)
	if quality ~= 2 or bindOnPickUp then
		return
	end

	local link = GetLootRollItemLink(rollID)
	if not link then
		return
	end

	-- If we can't even greed, don't do anything.
	if not canGreed and not canDisenchant then
		return
	end

	local item = Item_CreateFromItemLink(link)
	item:ContinueOnItemLoad(function()
		-- Roll might be gone by the time item data finishes loading; re-check quickly.
		local _, nameNow = GetLootRollItemInfo(rollID)
		if not nameNow then
			return
		end

		local ilvl = item:GetCurrentItemLevel() or 0
		local cutoff = (C.Loot and C.Loot.AutoGreedDECutoff) or DEFAULT_DE_ILVL_CUTOFF

		if canDisenchant and ilvl > cutoff then
			RollOnLoot(rollID, ROLL_DISENCHANT)
		else
			RollOnLoot(rollID, ROLL_GREED)
		end
	end)
end

function Module:CreateAutoGreed()
	local maxLevel = GetMaxLevelForExpansionLevel(GetExpansionLevel())
	if not C["Loot"].AutoGreed or K.Level ~= maxLevel then
		return
	end

	K:RegisterEvent("START_LOOT_ROLL", SetupAutoGreed)
end
