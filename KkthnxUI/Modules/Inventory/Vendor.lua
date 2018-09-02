local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("Vendor", "AceEvent-3.0")

-- Sourced: Tukui

local _G = _G
local select = select
local math_floor = math.floor
local string_match = string.match

local BlizzardMerchantClick = _G.MerchantItemButton_OnModifiedClick -- We NEED this to be a local!
local CanGuildBankRepair = _G.CanGuildBankRepair
local CanMerchantRepair = _G.CanMerchantRepair
local GetContainerItemID = _G.GetContainerItemID
local GetContainerItemInfo = _G.GetContainerItemInfo
local GetContainerItemLink = _G.GetContainerItemLink
local GetContainerNumSlots = _G.GetContainerNumSlots
local GetGuildBankWithdrawMoney = _G.GetGuildBankWithdrawMoney
local GetItemInfo = _G.GetItemInfo
local GetMerchantItemLink = _G.GetMerchantItemLink
local GetMerchantItemMaxStack = _G.GetMerchantItemMaxStack
local GetRepairAllCost = _G.GetRepairAllCost
local IsAltKeyDown = _G.IsAltKeyDown
local IsInGuild = _G.IsInGuild
local IsShiftKeyDown = _G.IsShiftKeyDown
local RepairAllItems = _G.RepairAllItems
local UseContainerItem = _G.UseContainerItem

function Module:MERCHANT_SHOW()
	if C["Inventory"].AutoSell then
		local Cost = 0

		for Bag = 0, 4 do
			for Slot = 1, GetContainerNumSlots(Bag) do
				local Link, ID = GetContainerItemLink(Bag, Slot), GetContainerItemID(Bag, Slot)

				if (Link and ID and type(Link) == "string") then
					if (string_match(Link, "battlepet:") or string_match(Link, "keystone:")) then -- Empty branch
						-- Do nothing, never sell/destroy pets or keystones
					else
						local Price = 0
						local Mult1, Mult2 = select(11, GetItemInfo(Link)), select(2, GetContainerItemInfo(Bag, Slot))

						if (Mult1 and Mult2) then
							Price = Mult1 * Mult2
						end

						if (select(3, GetItemInfo(Link)) == 0 and Price > 0) then
							UseContainerItem(Bag, Slot)
							PickupMerchantItem()
							Cost = Cost + Price
						end
					end
				end
			end
		end

		if (Cost > 0) then
			K.Print((L["Inventory"].SoldTrash.." %s"):format(K.FormatMoney(Cost)))
		end
	end

	if (not IsShiftKeyDown()) then
		if (CanMerchantRepair() and C["Inventory"].AutoRepair) then
			local Cost, Possible = GetRepairAllCost()

			if (Cost > 0) then
				if (IsInGuild() and C["Inventory"].UseGuildRepairFunds) then
					local CanGuildRepair = (CanGuildBankRepair() and (Cost <= GetGuildBankWithdrawMoney()))

					if CanGuildRepair then
						RepairAllItems(1)

						return
					end
				end

				if Possible then
					-- if max(GetMoney(), CanGuildRepair) > Cost then
					RepairAllItems()
					K.Print((L["Inventory"].RepairCost.." %s"):format(K.FormatMoney(Cost)))
				else
					K.Print(L["Inventory"].NotEnoughMoney)
				end
			end
		end
	end
end

function Module:MerchantClick(...)
	if (IsAltKeyDown()) then
		local MaxStack = select(8, GetItemInfo(GetMerchantItemLink(self:GetID())))

		if (MaxStack and MaxStack > 1) then
			BuyMerchantItem(self:GetID(), GetMerchantItemMaxStack(self:GetID()))
		end
	end

	BlizzardMerchantClick(self, ...)
end

function Module:OnEnable()
	self:RegisterEvent("MERCHANT_SHOW")

	MerchantItemButton_OnModifiedClick = self.MerchantClick
end

function Module:OnDisable()
	self:UnregisterEvent("MERCHANT_SHOW")

	MerchantItemButton_OnModifiedClick = BlizzardMerchantClick
end