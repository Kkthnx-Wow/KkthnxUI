local K, C = unpack(select(2, ...))

-- Sourced: NDui

local _G = _G
local string_format = _G.string.format

local CanGuildBankRepair = _G.CanGuildBankRepair
local CanMerchantRepair = _G.CanMerchantRepair
local GetContainerItemInfo = _G.GetContainerItemInfo
local GetContainerItemLink = _G.GetContainerItemLink
local GetContainerNumSlots = _G.GetContainerNumSlots
local GetGuildBankWithdrawMoney = _G.GetGuildBankWithdrawMoney
local GetItemInfo = _G.GetItemInfo
local GetMoney = _G.GetMoney
local GetRepairAllCost = _G.GetRepairAllCost
local IsInGuild = _G.IsInGuild
local RepairAllItems = _G.RepairAllItems
local UseContainerItem = _G.UseContainerItem

local AutoVendor = K:NewModule("AutoVendor") -- Auto sell useless items

AutoVendor.Filter = {
	[6196] = true,
}

function AutoVendor:GetTrashValue()
	local Profit = 0
	local TotalCount = 0

	for Bag = 0, 4 do
		for Slot = 1, GetContainerNumSlots(Bag) do
			local Link, ID = GetContainerItemLink(Bag, Slot), GetContainerItemID(Bag, Slot)

			if (Link and ID and not AutoVendor.Filter[ID]) then
				local TotalPrice = 0
				local Quality = select(3, GetItemInfo(Link))
				local SellPrice = select(11, GetItemInfo(Link))
				local Count = select(2, GetContainerItemInfo(Bag, Slot))

				if ((SellPrice and (SellPrice > 0)) and Count) then
					TotalPrice = SellPrice * Count
				end

				if ((Quality and Quality <= 0) and TotalPrice > 0) then
					Profit = Profit + TotalPrice
					TotalCount = TotalCount + Count
				end
			end
		end
	end

	return TotalCount, Profit
end

function AutoVendor:OnEvent()
	local Profit = 0
	local TotalCount = 0

	for Bag = 0, 4 do
		for Slot = 1, GetContainerNumSlots(Bag) do
			local Link, ID = GetContainerItemLink(Bag, Slot), GetContainerItemID(Bag, Slot)

			if (Link and ID and not AutoVendor.Filter[ID]) then
				local TotalPrice = 0
				local Quality = select(3, GetItemInfo(Link))
				local SellPrice = select(11, GetItemInfo(Link))
				local Count = select(2, GetContainerItemInfo(Bag, Slot))

				if ((SellPrice and (SellPrice > 0)) and Count) then
					TotalPrice = SellPrice * Count
				end

				if ((Quality and Quality <= 0) and TotalPrice > 0) then
					UseContainerItem(Bag, Slot)
					PickupMerchantItem()
					Profit = Profit + TotalPrice
					TotalCount = TotalCount + Count
				end
			end
		end
	end

	if (Profit > 0) then
		K.Print(string_format("You sold %d %s for a total of %s", TotalCount, TotalCount > 0 and "items" or "item", K.FormatMoney(Profit)))
	end
end

function AutoVendor:OnEnable()
	if C["Inventory"].AutoSell then
		K:RegisterEvent("MERCHANT_SHOW", AutoVendor.OnEvent)
	end
end

local AutoRepair = K:NewModule("AutoRepair") -- Check against the rep with the faction of the merchant, add option to repair if honored +

function AutoRepair:OnEvent()
	local Money = GetMoney()

	if CanMerchantRepair() then
		local Cost = GetRepairAllCost()
		local CostString = K.FormatMoney(Cost)

		if (Cost > 0) then
			if (IsInGuild() and C["Inventory"].AutoRepair.Value == "GUILD") then
				local CanGuildRepair = (CanGuildBankRepair() and (Cost <= GetGuildBankWithdrawMoney()))

				if CanGuildRepair then
					RepairAllItems(1)

					K.Print(string_format("Your equipped items have been repaired using guild bank funds for %s", CostString))

					return
				end
			else
				if (Money > Cost) then
					RepairAllItems()

					K.Print(string_format("Your equipped items have been repaired for %s", CostString))
				else
					local Required = Cost - Money
					local RequiredString = K.FormatMoney(Required)

					K.Print(string_format("You require %s to repair all equipped items (costs %s total)", RequiredString, CostString))
				end
			end
		end
	end
end

function AutoRepair:OnEnable()
	if C["Inventory"].AutoRepair.Value ~= "NONE" then
		K:RegisterEvent("MERCHANT_SHOW", AutoRepair.OnEvent)
	end
end