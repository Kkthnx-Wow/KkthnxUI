--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Notes:
-- - Purpose: Session tracker for newly looted backpack items.
-- - Design: GUID baseline during 5s login startup, then unseen GUIDs become "recent".
--   Combined with C_NewItems for category routing + glow. Session-only (no SavedVars).
-- - Events: BAG_UPDATE_DELAYED owns Scan; BAG_NEW_ITEMS_UPDATED refreshes open bags only.
-- - Midnight: skip secret GUIDs via K.CanAccessValue — Blizzard flag still works alone.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Bags")

local C_Container = C_Container
local C_Item = C_Item
local C_NewItems = C_NewItems
local C_Timer = C_Timer
local GetTime = GetTime
local ItemLocation = ItemLocation
local pairs = pairs
local wipe = wipe

local RECENT_TIMEOUT = 600
local STARTUP_BASELINE_SECONDS = 5
local BACKPACK_FIRST = 0
local BACKPACK_LAST = 5 -- include reagent bag

local seenGUIDs = {}
local recentGUIDs = {} -- guid -> firstSeenTime
local slotGUIDs = {} -- slotKey -> guid
local guidSlots = {} -- guid -> slotKey
local firstStart = true
local currentSlots = {}
local recentSetup = false

local function SlotKey(bag, slot)
	return bag * 1000 + slot
end

local function GUIDAccessible(guid)
	return guid and K.CanAccessValue(guid)
end

local function GUIDEqual(a, b)
	if a == b then
		return true
	end
	if not a or not b then
		return false
	end
	if K.IsSecret(a) or K.IsSecret(b) then
		return false
	end
	return a == b
end

local function GetSlotGUID(bag, slot)
	if not (ItemLocation and C_Item and C_Item.GetItemGUID) then
		return nil
	end
	local location = ItemLocation:CreateFromBagAndSlot(bag, slot)
	if not (location and C_Item.DoesItemExist and C_Item.DoesItemExist(location)) then
		return nil
	end
	return C_Item.GetItemGUID(location)
end

local function ClearExpired(now)
	for guid, started in pairs(recentGUIDs) do
		if now - started >= RECENT_TIMEOUT then
			recentGUIDs[guid] = nil
			local key = guidSlots[guid]
			if key and slotGUIDs[key] == guid then
				slotGUIDs[key] = nil
			end
			guidSlots[guid] = nil
		end
	end
end

local function BlizzardIsNewItem(bag, slot)
	if not (C_NewItems and C_NewItems.IsNewItem) then
		return false
	end
	return C_NewItems.IsNewItem(bag, slot) == true
end

local function RemoveBlizzardNewItem(bag, slot)
	if C_NewItems and C_NewItems.RemoveNewItem then
		C_NewItems.RemoveNewItem(bag, slot)
	end
end

function Module:RecentIsStartup()
	return firstStart
end

function Module:RecentScan()
	local now = GetTime()
	ClearExpired(now)
	wipe(currentSlots)

	for bag = BACKPACK_FIRST, BACKPACK_LAST do
		local numSlots = C_Container.GetContainerNumSlots(bag) or 0
		for slot = 1, numSlots do
			local guid = GetSlotGUID(bag, slot)
			if GUIDAccessible(guid) then
				local key = SlotKey(bag, slot)
				local wasSeen = seenGUIDs[guid]
				currentSlots[key] = guid
				seenGUIDs[guid] = true

				-- Login baseline: everything currently carried is "seen", not recent.
				if firstStart then
					RemoveBlizzardNewItem(bag, slot)
				elseif not wasSeen then
					recentGUIDs[guid] = now
				end

				if recentGUIDs[guid] then
					slotGUIDs[key] = guid
					guidSlots[guid] = key
				end
			end
		end
	end

	for key, guid in pairs(slotGUIDs) do
		if not GUIDEqual(currentSlots[key], guid) then
			slotGUIDs[key] = nil
		end
	end
	for guid, key in pairs(guidSlots) do
		if not GUIDAccessible(guid) or not GUIDEqual(currentSlots[key], guid) then
			guidSlots[guid] = nil
		end
	end
end

function Module:RecentEndStartup()
	if not firstStart then
		return
	end
	firstStart = false
	self:RecentScan()
	if self.Bags and self.Bags:IsShown() then
		self:UpdateAllBags()
	end
end

--- True when this slot should count as newly looted (glow + optional Recent category).
function Module:IsRecentItem(bag, slot)
	if firstStart then
		return false
	end
	if BlizzardIsNewItem(bag, slot) then
		return true
	end
	local guid = GetSlotGUID(bag, slot)
	if not GUIDAccessible(guid) then
		return false
	end
	return recentGUIDs[guid] ~= nil and GUIDEqual(slotGUIDs[SlotKey(bag, slot)], guid)
end

function Module:ClearRecentItem(bag, slot)
	RemoveBlizzardNewItem(bag, slot)
	local key = SlotKey(bag, slot)
	local guid = slotGUIDs[key]
	if not GUIDAccessible(guid) then
		return
	end
	recentGUIDs[guid] = nil
	slotGUIDs[key] = nil
	guidSlots[guid] = nil
end

function Module:ClearRecentAll()
	wipe(recentGUIDs)
	wipe(slotGUIDs)
	wipe(guidSlots)
end

--- Sort is an organize action — drop Recent membership and Blizzard new flags.
function Module:ClearRecentBackpack()
	for bag = BACKPACK_FIRST, BACKPACK_LAST do
		local numSlots = C_Container.GetContainerNumSlots(bag) or 0
		for slot = 1, numSlots do
			local info = C_Container.GetContainerItemInfo(bag, slot)
			if info and info.iconFileID then
				RemoveBlizzardNewItem(bag, slot)
			end
		end
	end
	self:ClearRecentAll()
end

local function RefreshOpenBagsAfterRecent()
	-- Recent only tracks backpack (+ reagent). Don't dirty-walk bank/warbank.
	if not (Module.Bags and Module.Bags:IsShown()) then
		return
	end
	for bag = BACKPACK_FIRST, BACKPACK_LAST do
		Module.Bags:UpdateBag(bag)
	end
end

local onBagUpdateDelayed = K.Debounce(0.1, function()
	Module:RecentScan()
	-- Re-paint backpack so GUID-recent slots pick up glow / Recent category after the scan.
	-- 0.1s debounce — loot BAG_UPDATE storms coalesce before a backpack re-paint.
	RefreshOpenBagsAfterRecent()
end)

local onNewItemsUpdated = K.Debounce(0.1, function()
	RefreshOpenBagsAfterRecent()
end)

function Module:SetupRecentItems()
	if recentSetup then
		return
	end
	recentSetup = true

	K:RegisterEvent("BAG_UPDATE_DELAYED", onBagUpdateDelayed)
	K:RegisterEvent("BAG_NEW_ITEMS_UPDATED", onNewItemsUpdated)
	K:RegisterEvent("PLAYER_ENTERING_WORLD", onBagUpdateDelayed)

	C_Timer.After(STARTUP_BASELINE_SECONDS, function()
		if recentSetup then
			Module:RecentEndStartup()
		end
	end)

	self:RecentScan()
end
