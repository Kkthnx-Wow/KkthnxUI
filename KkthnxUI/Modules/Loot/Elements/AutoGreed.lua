--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Notes:
-- - Purpose: Auto Greed / Disenchant on low-rarity group loot at max level.
-- - Design: Skip when Need is available; only confirm BoP/DE prompts for rolls
--   we started (ourRolls) — never silently confirm a manual click.
-- - Midnight: GetLootRollItemInfo quality is not SecretReturns (12.0.7).
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Loot")

local _G = _G
local GetLootRollItemInfo = _G.GetLootRollItemInfo
local RollOnLoot = _G.RollOnLoot
local ConfirmLootRoll = _G.ConfirmLootRoll
local StaticPopup_Hide = _G.StaticPopup_Hide
local GetMaxLevelForPlayerExpansion = _G.GetMaxLevelForPlayerExpansion
local wipe = wipe

local ROLL_GREED = _G.LOOT_ROLL_TYPE_GREED or 2
local ROLL_DISENCHANT = _G.LOOT_ROLL_TYPE_DISENCHANT or 3

local UNCOMMON = Enum.ItemQuality.Uncommon
local RARE = Enum.ItemQuality.Rare

-- Roll IDs we initiated — only auto-confirm those.
local ourRolls = {}
local eventsRegistered = false

local function AtMaxLevel()
	return (K.Level or 0) >= GetMaxLevelForPlayerExpansion()
end

local function ChooseRoll(canGreed, canDisenchant)
	local preferDE = C["Loot"].AutoGreedPreferDE ~= false
	if preferDE and canDisenchant then
		return ROLL_DISENCHANT
	end
	if canGreed then
		return ROLL_GREED
	end
	if canDisenchant then
		return ROLL_DISENCHANT
	end
	return nil
end

local function OnStartLootRoll(_, rollID)
	if not C["Loot"].AutoGreed or not rollID then
		return
	end
	if C["Loot"].AutoGreedMaxLevelOnly ~= false and not AtMaxLevel() then
		return
	end

	local _, name, _, quality, bindOnPickUp, canNeed, canGreed, canDisenchant = GetLootRollItemInfo(rollID)
	if not name then
		return
	end

	-- Need is possible — leave the decision to the player.
	if canNeed then
		return
	end

	-- Cold loot data: don't guess rarity.
	if quality == nil then
		return
	end

	local maxQuality = C["Loot"].AutoGreedIncludeRares and RARE or UNCOMMON
	if quality < UNCOMMON or quality > maxQuality then
		return
	end

	if bindOnPickUp and C["Loot"].AutoGreedSkipBoP ~= false then
		return
	end

	local rollType = ChooseRoll(canGreed, canDisenchant)
	if not rollType then
		return
	end

	ourRolls[rollID] = rollType
	RollOnLoot(rollID, rollType)
end

local function ConfirmOurRoll(_, rollID, rollType)
	if not C["Loot"].AutoGreed or C["Loot"].AutoGreedAutoConfirm == false then
		return
	end
	if not ourRolls[rollID] then
		return
	end

	ourRolls[rollID] = nil
	ConfirmLootRoll(rollID, rollType)
	StaticPopup_Hide("CONFIRM_LOOT_ROLL")
end

local function OnCancelLootRoll(_, rollID)
	ourRolls[rollID] = nil
end

function Module:CreateAutoGreed()
	if C["Loot"].AutoGreed then
		if eventsRegistered then
			return
		end
		eventsRegistered = true
		K:RegisterEvent("START_LOOT_ROLL", OnStartLootRoll)
		K:RegisterEvent("CONFIRM_LOOT_ROLL", ConfirmOurRoll)
		K:RegisterEvent("CONFIRM_DISENCHANT_ROLL", ConfirmOurRoll)
		K:RegisterEvent("CANCEL_LOOT_ROLL", OnCancelLootRoll)
	else
		if not eventsRegistered then
			return
		end
		eventsRegistered = false
		wipe(ourRolls)
		K:UnregisterEvent("START_LOOT_ROLL", OnStartLootRoll)
		K:UnregisterEvent("CONFIRM_LOOT_ROLL", ConfirmOurRoll)
		K:UnregisterEvent("CONFIRM_DISENCHANT_ROLL", ConfirmOurRoll)
		K:UnregisterEvent("CANCEL_LOOT_ROLL", OnCancelLootRoll)
	end
end
