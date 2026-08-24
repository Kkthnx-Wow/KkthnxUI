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
local StaticPopup_Show = StaticPopup_Show

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
	StaticPopup_Show("KKUI_BAGS_DELETE_JUNK", item.link, GetCoinTextureString(price or 0), item)
end

_G.StaticPopupDialogs = _G.StaticPopupDialogs or {}
_G.StaticPopupDialogs["KKUI_BAGS_DELETE_JUNK"] = {
	text = L["Delete %s\nworth %s?"],
	button1 = _G.YES,
	button2 = _G.NO,
	OnAccept = function(_, data)
		if data and not InCombatLockdown() then
			C_Container.PickupContainerItem(data.bag, data.slot)
			if _G.DeleteCursorItem then
				_G.DeleteCursorItem()
			end
		end
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	showAlert = true,
}
