local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Automation")

-- Performance optimizations
local ReagentClass, KeystoneClass = Enum.ItemClass.Reagent, Enum.ItemReagentSubclass.Keystone
local GetContainerItemID, GetContainerNumSlots, GetItemInfo = C_Container.GetContainerItemID, C_Container.GetContainerNumSlots, C_Item.GetItemInfo
local PickupContainerItem, GetCursorItem, SlotKeystone = C_Container.PickupContainerItem, C_Cursor.GetCursorItem, C_ChallengeMode.SlotKeystone
local select = select

local function isKeystone(itemID)
	local class, subclass = select(12, GetItemInfo(itemID))
	return class == ReagentClass and subclass == KeystoneClass
end

local function useKeystone()
	-- Include reagent bag (bagID 5) explicitly for safety on modern clients
	local lastBag = (Enum.BagIndex and Enum.BagIndex.ReagentBag) or (NUM_BAG_FRAMES + 1)
	for bag = 0, lastBag do
		for slot = 1, GetContainerNumSlots(bag) do
			local itemID = GetContainerItemID(bag, slot)
			if itemID and isKeystone(itemID) then
				PickupContainerItem(bag, slot)

				-- Verify cursor has item before slotting
				if GetCursorItem() then
					SlotKeystone()
					return true
				end
			end
		end
	end
	return false
end

function Module:SetupAutoKeystone()
	if useKeystone() then
		K.Print(L["Keystone automatically placed"])
	end
end

function Module:LoadAutoKeystone(event, addon)
	if addon == "Blizzard_ChallengesUI" then
		ChallengesKeystoneFrame:HookScript("OnShow", function()
			self:SetupAutoKeystone()
		end)

		K:UnregisterEvent(event, self.LoadAutoKeystone)
	end
end

function Module:CreateAutoKeystone()
	if C_AddOns.IsAddOnLoaded("AngryKeystones") or not C["Automation"].AutoKeystone then
		return
	end

	K:RegisterEvent("ADDON_LOADED", self.LoadAutoKeystone, self)
end
