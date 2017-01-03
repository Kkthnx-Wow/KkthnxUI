local K, C, L = unpack(select(2, ...))
if C.Misc.AutoSellGrays ~= true or C.Misc.SellMisc ~= true then return end

-- Lua API
local _G = _G
local math_floor = math.floor
local select = select

-- Wow API
local CanGuildBankRepair = CanGuildBankRepair
local CanMerchantRepair = CanMerchantRepair
local GetContainerItemID = GetContainerItemID
local GetContainerItemInfo = GetContainerItemInfo
local GetContainerItemLink = GetContainerItemLink
local GetContainerNumSlots = GetContainerNumSlots
local GetGuildBankWithdrawMoney = GetGuildBankWithdrawMoney
local GetItemInfo = GetItemInfo
local GetMerchantItemInfo = GetMerchantItemInfo
local GetMerchantItemLink= GetMerchantItemLink
local GetMerchantItemMaxStack = GetMerchantItemMaxStack
local GetMouseFocus = GetMouseFocus
local GetRepairAllCost = GetRepairAllCost
local IsAltKeyDown = IsAltKeyDown
local IsInGuild = IsInGuild
local IsShiftKeyDown = IsShiftKeyDown
local UseContainerItem = UseContainerItem

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: PickupMerchantItem, DEFAULT_CHAT_FRAME, RepairAllItems, BuyMerchantItem
-- GLOBALS: MerchantFrame, GameTooltip, ITEM_VENDOR_STACK_BUY

local MerchantScript = CreateFrame("Frame")

K.MerchantFilter = {
	[41808] = true, -- Bonescale Snapper
	[42336] = true, -- Bloodstone Band
	[42337] = true, -- Sun Rock Ring
	[43244] = true, -- Crystal Citrine Necklace
	[43571] = true, -- Sewer Carp
	[43572] = true, -- Magic Eater
	[6289] = true, -- Raw Longjaw Mud Snapper
	[6291] = true, -- Raw Brilliant Smallfish
	[6308] = true, -- Raw Bristle Whisker Catfish
	[6309] = true, -- 17 Pound Catfish
	[6310] = true, -- 19 Pound Catfish
}

MerchantScript:SetScript("OnEvent", function()
	if C.Misc.AutoSellGrays or C.Misc.SellMisc then
		local Cost = 0

		for Bag = 0, 4 do
			for Slot = 1, GetContainerNumSlots(Bag) do
				local Link, ID = GetContainerItemLink(Bag, Slot), GetContainerItemID(Bag, Slot)

				if (Link and ID) then
					local Price = 0
					local Mult1, Mult2 = select(11, GetItemInfo(Link)), select(2, GetContainerItemInfo(Bag, Slot))
					if (Mult1 and Mult2) then
						Price = Mult1 * Mult2
					end

					if (C.Misc.AutoSellGrays and select(3, GetItemInfo(Link)) == 0 and Price > 0) then
						UseContainerItem(Bag, Slot)
						PickupMerchantItem()
						Cost = Cost + Price
					end

					if C.Misc.SellMisc and K.MerchantFilter[ID] then
						UseContainerItem(Bag, Slot)
						PickupMerchantItem()
						Cost = Cost + Price
					end
				end
			end
		end

		if (Cost > 0) then
			local Gold, Silver, Copper = math_floor(Cost / 10000) or 0, math_floor((Cost % 10000) / 100) or 0, Cost % 100
			DEFAULT_CHAT_FRAME:AddMessage(L.Merchant.SoldTrash.." |cffffffff"..Gold..L.Misc.GoldShort.." |cffffffff"..Silver..L.Misc.SilverShort.." |cffffffff"..Copper..L.Misc.CopperShort..".", 0255, 255, 0)
		end
	end

	if (not IsShiftKeyDown()) then
		if (CanMerchantRepair() and C.Misc.AutoRepair) then
			local Cost, Possible = GetRepairAllCost()

			if (Cost > 0) then
				if (IsInGuild() and C.Misc.UseGuildRepair) then
					local CanGuildRepair = (CanGuildBankRepair() and (Cost <= GetGuildBankWithdrawMoney()))

					if CanGuildRepair then
						RepairAllItems(1)
						return
					end
				end

				if Possible then
					RepairAllItems()

					local Copper = Cost % 100
					local Silver = math_floor((Cost % 10000) / 100)
					local Gold = math_floor(Cost / 10000)
					DEFAULT_CHAT_FRAME:AddMessage(L.Merchant.RepairCost.." |cffffffff"..Gold..L.Misc.GoldShort.." |cffffffff"..Silver..L.Misc.SilverShort.." |cffffffff"..Copper..L.Misc.CopperShort..".", 255, 255, 0)
				else
					DEFAULT_CHAT_FRAME:AddMessage(L.Merchant.NotEnoughMoney, 255, 0, 0)
				end
			end
		end
	end
end)
MerchantScript:RegisterEvent("MERCHANT_SHOW")

-- Alt+Click to buy a stack
hooksecurefunc("MerchantItemButton_OnModifiedClick", function(self, ...)
	if IsAltKeyDown() then
		local itemLink = GetMerchantItemLink(self:GetID())
		if not itemLink then return end

		local maxStack = select(8, GetItemInfo(itemLink))
		if maxStack and maxStack > 1 then
			local numAvailable = select(5, GetMerchantItemInfo(self:GetID()))
			if numAvailable > -1 then
				BuyMerchantItem(self:GetID(), numAvailable)
			else
				BuyMerchantItem(self:GetID(), GetMerchantItemMaxStack(self:GetID()))
			end
		end
	end
end)

local function IsMerchantButtonOver()
	return GetMouseFocus():GetName() and GetMouseFocus():GetName():find("MerchantItem%d")
end

GameTooltip:HookScript("OnTooltipSetItem", function(self)
	if MerchantFrame:IsShown() and IsMerchantButtonOver() then
		for i = 2, GameTooltip:NumLines() do
			if _G["GameTooltipTextLeft"..i]:GetText():find(ITEM_VENDOR_STACK_BUY) then
				GameTooltip:AddLine("|cff00ff00<"..L.Misc.BuyStack..">|r")
			end
		end
	end
end)