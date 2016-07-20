local K, _ = select(2, ...):unpack()

local _G = _G
local select = select
local find = string.find
local IsAltKeyDown = IsAltKeyDown
local GetItemInfo = GetItemInfo

-- Alt+Click to buy a stack
local SavedMerchantItemButton_OnModifiedClick = MerchantItemButton_OnModifiedClick
function MerchantItemButton_OnModifiedClick(self, ...)
	if ( IsAltKeyDown() ) then
		local maxStack = select(8, GetItemInfo(GetMerchantItemLink(this:GetID())))
		local name, texture, price, quantity, numAvailable, isUsable, extendedCost = GetMerchantItemInfo(this:GetID())
		if ( maxStack and maxStack > 1 ) then
			BuyMerchantItem(this:GetID(), floor(maxStack / quantity))
		end
	end
	SavedMerchantItemButton_OnModifiedClick(self, ...)
end