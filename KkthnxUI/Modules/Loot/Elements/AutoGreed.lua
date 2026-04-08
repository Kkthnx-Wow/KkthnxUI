--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Automatically rolls Greed or Disenchant on uncommon items at max level.
-- - Design: Only triggers for non-BoP items of uncommon quality when Need is not an option.
-- - Events: START_LOOT_ROLL
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Loot")

-- PERF: Localize global functions and environment for faster lookups.
local _G = _G
local GetExpansionLevel = _G.GetExpansionLevel
local GetLootRollItemInfo = _G.GetLootRollItemInfo
local GetLootRollItemLink = _G.GetLootRollItemLink
local GetMaxLevelForExpansionLevel = _G.GetMaxLevelForExpansionLevel
local RollOnLoot = _G.RollOnLoot
local Item_CreateFromItemLink = _G.Item.CreateFromItemLink

-- REASON: Roll types defined by the WoW API: 0/nil pass, 1 need, 2 greed, 3 disenchant.
local ROLL_GREED = 2
local ROLL_DISENCHANT = 3
local DEFAULT_DE_ILVL_CUTOFF = 0

local function setupAutoGreed(_, rollID)
	if not rollID then
		return
	end

	local _, _, _, quality, bindOnPickUp, canNeed, canGreed, canDisenchant = GetLootRollItemInfo(rollID)

	-- REASON: If Need is possible, never auto-roll to allow the player manually deciding the priority.
	if canNeed then
		return
	end

	-- REASON: Uncommon quality only (quality 2) and skip BoP items to prevent accidental soulbinding.
	if quality ~= 2 or bindOnPickUp then
		return
	end

	local link = GetLootRollItemLink(rollID)
	if not link then
		return
	end

	-- REASON: If no automated roll option is available, exit early.
	if not canGreed and not canDisenchant then
		return
	end

	local item = Item_CreateFromItemLink(link)
	item:ContinueOnItemLoad(function()
		-- REASON: Roll might have expired or been completed by the time item data is ready; re-verify.
		local _, nameNow = GetLootRollItemInfo(rollID)
		if not nameNow then
			return
		end

		local itemLevel = item:GetCurrentItemLevel() or 0
		local cutoff = (C["Loot"] and C["Loot"].AutoGreedDECutoff) or DEFAULT_DE_ILVL_CUTOFF

		if canDisenchant and itemLevel > cutoff then
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

	K:RegisterEvent("START_LOOT_ROLL", setupAutoGreed)
end
