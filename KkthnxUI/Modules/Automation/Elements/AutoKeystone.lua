--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Automatically slots Mythic+ keystones when the Challenge Mode interface opens.
-- - Design: Hooks the ChallengesKeystoneFrame OnShow event and scans containers for the appropriate keystone item.
-- - Events: ADDON_LOADED (Blizzard_ChallengesUI), ChallengesKeystoneFrame:OnShow
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Automation")

-- PERF: Cache globals for performance
local _G = _G
local C_AddOns_IsAddOnLoaded = C_AddOns.IsAddOnLoaded
local C_ChallengeMode_SlotKeystone = C_ChallengeMode.SlotKeystone
local C_Container_GetContainerItemID = C_Container.GetContainerItemID
local C_Container_GetContainerNumSlots = C_Container.GetContainerNumSlots
local C_Container_PickupContainerItem = C_Container.PickupContainerItem
local C_Cursor_GetCursorItem = C_Cursor.GetCursorItem
local C_Item_GetItemInfo = C_Item.GetItemInfo
local Enum_BagIndex_ReagentBag = Enum.BagIndex.ReagentBag
local Enum_ItemClass_Reagent = Enum.ItemClass.Reagent
local Enum_ItemReagentSubclass_Keystone = Enum.ItemReagentSubclass.Keystone
local NUM_BAG_FRAMES = NUM_BAG_FRAMES
local select = select

-- ---------------------------------------------------------------------------
-- Utility Logic
-- ---------------------------------------------------------------------------
local function isKeystone(itemID)
	-- REASON: Filters for Mythic+ Keystones using official ItemClass and Subclass enums.
	local class, subclass = select(12, C_Item_GetItemInfo(itemID))
	return class == Enum_ItemClass_Reagent and subclass == Enum_ItemReagentSubclass_Keystone
end

local function useKeystone()
	-- COMPAT: Include reagent bag (bagID 5) explicitly for safety on modern clients.
	local lastBag = Enum_BagIndex_ReagentBag or (NUM_BAG_FRAMES + 1)
	for bag = 0, lastBag do
		for slot = 1, C_Container_GetContainerNumSlots(bag) do
			local itemID = C_Container_GetContainerItemID(bag, slot)
			if itemID and isKeystone(itemID) then
				C_Container_PickupContainerItem(bag, slot)

				-- REASON: Verify the cursor actually holds an item before attempting to slot it.
				if C_Cursor_GetCursorItem() then
					C_ChallengeMode_SlotKeystone()
					return true
				end
			end
		end
	end
	return false
end

-- ---------------------------------------------------------------------------
-- Automation Functions
-- ---------------------------------------------------------------------------
function Module:SetupAutoKeystone()
	if useKeystone() then
		K.Print(L["Keystone automatically placed"])
	end
end

function Module:LoadAutoKeystone(event, addon)
	if addon == "Blizzard_ChallengesUI" then
		local challengesKeystoneFrame = _G.ChallengesKeystoneFrame
		if challengesKeystoneFrame then
			-- REASON: Hooks the OnShow script to trigger the keystone placement when the UI opens.
			challengesKeystoneFrame:HookScript("OnShow", function()
				self:SetupAutoKeystone()
			end)
		end

		K:UnregisterEvent(event, self.LoadAutoKeystone)
	end
end

function Module:CreateAutoKeystone()
	-- REASON: Avoid conflicts with other keystone addons and respect user configuration.
	if C_AddOns_IsAddOnLoaded("AngryKeystones") or not C["Automation"].AutoKeystone then
		return
	end

	K:RegisterEvent("ADDON_LOADED", self.LoadAutoKeystone, self)
end
