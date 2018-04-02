local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("Vendor", "AceEvent-3.0")

-- Sourced: gUI4 (Goldpaw)

-- Lua API
local _G = _G
local min, max, abs = math.min, math.max, math.abs
local print = print
local select = select

-- WoW API
local BuyMerchantItem = _G.BuyMerchantItem
local CanMerchantRepair = _G.CanMerchantRepair
local GetContainerItemID = _G.GetContainerItemID
local GetContainerItemInfo = _G.GetContainerItemInfo
local GetContainerNumSlots = _G.GetContainerNumSlots
local GetGuildBankMoney = _G.GetGuildBankMoney
local GetGuildBankWithdrawMoney = _G.GetGuildBankWithdrawMoney
local GetItemInfo = _G.GetItemInfo
local GetMerchantItemLink = _G.GetMerchantItemLink
local GetMerchantItemMaxStack = _G.GetMerchantItemMaxStack
local GetMoney = _G.GetMoney
local GetRepairAllCost = _G.GetRepairAllCost
local IsAltKeyDown = _G.IsAltKeyDown
local IsInGuild = _G.IsInGuild
local MerchantGuildBankRepairButton = _G.MerchantGuildBankRepairButton
local RepairAllItems = _G.RepairAllItems
local UseContainerItem = _G.UseContainerItem

local _MerchantItemButton_OnModifiedClick = _G.MerchantItemButton_OnModifiedClick -- We NEED this to be a local!
function _G.MerchantItemButton_OnModifiedClick(self, ...)
	if IsAltKeyDown() then
		local ID = self:GetID()
		if ID then
			local max = select(8, GetItemInfo(GetMerchantItemLink(ID)))
			if max and max > 1 then
				BuyMerchantItem(ID, GetMerchantItemMaxStack(ID))
			end
		end
	end
	_MerchantItemButton_OnModifiedClick(self, ...)
end

_G.ITEM_VENDOR_STACK_BUY = _G.ITEM_VENDOR_STACK_BUY.."|n".."<Alt-Click to buy the maximum amount>"

function Module:UpdateMerchant()
	local gain, sold = 0, 0
	local repaired = false
	local useGuildFunds = IsInGuild() and C["Inventory"].UseGuildRepairFunds
	local usedGuildFunds = false
	local yourGuildFunds = min((GetGuildBankWithdrawMoney() ~= -1) and GetGuildBankWithdrawMoney() or GetGuildBankMoney(), GetGuildBankMoney())
	local repairCost = select(1, GetRepairAllCost()) or 0
	local itemID, count, link, rarity, price, stack

	if C["Inventory"].AutoSell and not(_G.ZygorGuidesViewer and _G.ZygorGuidesViewer.db.profile.autosell) then -- let zygor handle it if available
		for bag = 0, 4, 1 do
			for slot = 1, GetContainerNumSlots(bag), 1 do
				itemID = GetContainerItemID(bag, slot)
				if itemID then
					count = select(2, GetContainerItemInfo(bag, slot))
					_, link, rarity, _, _, _, _, _, _, _, price = GetItemInfo(itemID)
					if rarity == 0 then
						stack = (price or 0) * (count or 1)
						sold = sold + stack
						if C["Inventory"].DetailedReport then
							K.Print(("-%s|cFF00DDDDx%d|r %s"):format(link, count, K.FormatMoney(stack)))
						end
						UseContainerItem(bag, slot)
					end
				end
			end
		end
		gain = gain + sold
	end

	if sold > 0 then
		K.Print(("Earned %s"):format(K.FormatMoney(sold)))
	end

	if C["Inventory"].AutoRepair and CanMerchantRepair() and repairCost > 0 then
		if max(GetMoney(), yourGuildFunds) > repairCost then
			if (useGuildFunds and (yourGuildFunds > repairCost)) and MerchantGuildBankRepairButton:IsEnabled() and MerchantGuildBankRepairButton:IsShown() then
				RepairAllItems(1)
				usedGuildFunds = true
				repaired = true
				K.Print(("You repaired your items for %s using Guild Bank funds"):format(K.FormatMoney(repairCost)))
			elseif GetMoney() > repairCost then
				RepairAllItems()
				repaired = true
				K.Print(("You repaired your items for %s"):format(K.FormatMoney(repairCost)))
				gain = gain - repairCost
			end
		else
			K.Print("You haven't got enough available funds to repair!")
		end
	end

	if gain > 0 then
		K.Print(("Your profit is %s"):format(K.FormatMoney(gain)))
	elseif gain < 0 then
		K.Print(("Your expenses are %s"):format(K.FormatMoney(abs(gain))))
	end
end

function Module:OnInitialize()
	self:RegisterEvent("MERCHANT_SHOW", "UpdateMerchant")
end