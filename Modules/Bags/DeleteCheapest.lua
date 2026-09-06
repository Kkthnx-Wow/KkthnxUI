--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/Bags/DeleteCheapest.lua
	Purpose:
		A one-shot bag action for a full bag in the field: find the lowest value
		grey (or player-flagged) item and, after a confirm, delete it to free a slot.
		Handy when a drop cannot fit and there is no vendor nearby.
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]

local Module = K:GetModule("Bags")
if not Module then
	return
end

local _G = _G
local ipairs = ipairs
local select = select
local Enum = Enum
local IsSecret = K.IsSecret
local InCombatLockdown = InCombatLockdown
local C_Container = C_Container
local C_Item = C_Item
local GetCoinTextureString = GetCoinTextureString
local format = string.format

local POOR = Enum.ItemQuality and Enum.ItemQuality.Poor or 0

-- Walk the bags for the cheapest sellable item that reads as junk, either grey or
-- flagged by the player. Returns the slot and its total value.
function Module:FindCheapestJunk()
	local best, bestPrice
	for _, bag in ipairs(self.BagIDs) do
		local numSlots = C_Container.GetContainerNumSlots(bag) or 0
		for slot = 1, numSlots do
			local info = C_Container.GetContainerItemInfo(bag, slot)
			if info and info.hyperlink and not info.hasNoValue then
				local flagged = info.itemID and not IsSecret(info.itemID) and C.Bags.JunkList and C.Bags.JunkList[info.itemID]
				local grey = not IsSecret(info.quality) and info.quality == POOR
				if grey or flagged then
					local price = select(11, C_Item.GetItemInfo(info.hyperlink)) or 0
					local total = price * (info.stackCount or 1)
					if total > 0 and (not bestPrice or total < bestPrice) then
						bestPrice = total
						best = { bag = bag, slot = slot, link = info.hyperlink }
					end
				end
			end
		end
	end
	return best, bestPrice
end

function Module:DeleteCheapestJunk()
	if InCombatLockdown() then
		return
	end
	local item, price = self:FindCheapestJunk()
	if not item then
		K.Print(L["No junk to delete."])
		return
	end
	K.Confirm(format(L["Delete %s\nworth %s?"], item.link, GetCoinTextureString(price or 0)), function()
		-- Re-check combat: the dialog stays open across a pull, and the pickup and
		-- delete pair is blocked once the player is in combat.
		if InCombatLockdown() then
			return
		end
		C_Container.PickupContainerItem(item.bag, item.slot)
		if _G.DeleteCursorItem then
			_G.DeleteCursorItem()
		end
	end)
end
