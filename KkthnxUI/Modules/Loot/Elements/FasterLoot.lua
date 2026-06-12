--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Speeds up the looting process by immediately calling LootSlot for all unlocked items.
-- - Design: Intercepts LOOT_READY (with LOOT_OPENED as a safety net) and loops through loot slots with a throttle.
-- - Events: LOOT_READY, LOOT_OPENED
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Loot")

-- PERF: Localize global functions and environment for faster lookups.
local _G = _G
local GetCVarBool = _G.GetCVarBool
local GetLootSlotInfo = _G.GetLootSlotInfo
local GetNumLootItems = _G.GetNumLootItems
local GetTime = _G.GetTime
local IsModifiedClick = _G.IsModifiedClick
local LootSlot = _G.LootSlot
local select = _G.select
local type = type

local lastLootTime = 0

-- REASON: Throttled item looting to prevent client/server sync issues while maintaining a fast pace.
local function handleFasterLoot()
	local currentTime = GetTime()
	-- The throttle also dedupes the rapid LOOT_READY -> LOOT_OPENED pair so a single
	-- loot session isn't walked twice in the same instant.
	if currentTime - lastLootTime < 0.3 then
		return
	end
	lastLootTime = currentTime

	-- REASON: Only auto-loot if the current modifier state matches the expected auto-loot behavior.
	if GetCVarBool("autoLootDefault") ~= IsModifiedClick("AUTOLOOTTOGGLE") then
		for i = GetNumLootItems(), 1, -1 do
			-- WARNING: never LootSlot a locked slot (e.g. a BoP confirm or in-use slot).
			-- GetLootSlotInfo's locked flag shifted return position across patches, so accept
			-- both the legacy boolean-at-5 and the modern boolean-at-6 shapes.
			local maybeLocked, modernLocked = select(5, GetLootSlotInfo(i))
			local locked = type(maybeLocked) == "boolean" and maybeLocked or modernLocked
			if not locked then
				LootSlot(i)
			end
		end
	end
end

function Module:CreateFasterLoot()
	if C["Loot"].FastLoot then
		K:RegisterEvent("LOOT_READY", handleFasterLoot)
		K:RegisterEvent("LOOT_OPENED", handleFasterLoot)
	else
		K:UnregisterEvent("LOOT_READY", handleFasterLoot)
		K:UnregisterEvent("LOOT_OPENED", handleFasterLoot)
	end
end
