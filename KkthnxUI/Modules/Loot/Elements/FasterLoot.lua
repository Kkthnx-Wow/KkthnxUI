--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Speeds up the looting process by immediately calling LootSlot for all items.
-- - Design: Intercepts LOOT_READY and loops through available loot slots with a throttle.
-- - Events: LOOT_READY
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Loot")

-- PERF: Localize global functions and environment for faster lookups.
local _G = _G
local GetCVarBool = _G.GetCVarBool
local GetNumLootItems = _G.GetNumLootItems
local GetTime = _G.GetTime
local IsModifiedClick = _G.IsModifiedClick
local LootSlot = _G.LootSlot

local lastLootTime = 0

-- REASON: Throttled item looting to prevent client/server sync issues while maintaining a fast pace.
local function handleFasterLoot()
	local currentTime = GetTime()
	if currentTime - lastLootTime >= 0.3 then
		lastLootTime = currentTime

		-- REASON: Only auto-loot if the current modifier state matches the expected auto-loot behavior.
		if GetCVarBool("autoLootDefault") ~= IsModifiedClick("AUTOLOOTTOGGLE") then
			for i = GetNumLootItems(), 1, -1 do
				LootSlot(i)
			end
			lastLootTime = currentTime
		end
	end
end

function Module:CreateFasterLoot()
	if C["Loot"].FastLoot then
		K:RegisterEvent("LOOT_READY", handleFasterLoot)
	else
		K:UnregisterEvent("LOOT_READY", handleFasterLoot)
	end
end
