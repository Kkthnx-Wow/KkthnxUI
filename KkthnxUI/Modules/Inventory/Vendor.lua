local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("Vendor", "AceEvent-3.0", "AceTimer-3.0")

-- Sourced: ElvUI

local _G = _G
local select = select
local string_format = string.format

local C_Timer_After = _G.C_Timer.After
local CanGuildBankRepair = _G.CanGuildBankRepair
local CanMerchantRepair = _G.CanMerchantRepair
local GetContainerItemID = _G.GetContainerItemID
local GetContainerItemInfo = _G.GetContainerItemInfo
local GetContainerNumSlots = _G.GetContainerNumSlots
local GetGuildBankWithdrawMoney = _G.GetGuildBankWithdrawMoney
local GetItemInfo = _G.GetItemInfo
local GetRepairAllCost = _G.GetRepairAllCost
local IsShiftKeyDown = _G.IsShiftKeyDown
local RepairAllItems = _G.RepairAllItems
local UseContainerItem = _G.UseContainerItem

local autoRepairStatus
local function AttemptAutoRepair(playerOverride)
	autoRepairStatus = ""
	local autoRepair = C["Inventory"].AutoRepair.Value
	local cost, possible = GetRepairAllCost()
	local withdrawLimit = GetGuildBankWithdrawMoney()
	-- This check evaluates to true even if the guild bank has 0 gold, so we add an override
	if autoRepair == "GUILD" and ((not CanGuildBankRepair() or cost > withdrawLimit) or playerOverride) then
		autoRepair = "PLAYER"
	end

	if cost > 0 then
		if possible then
			RepairAllItems(autoRepair == "GUILD")
			-- Delay this a bit so we have time to catch the outcome of first repair attempt
			C_Timer_After(0.5, function()
				if autoRepair == "GUILD" then
					if autoRepairStatus == "GUILD_REPAIR_FAILED" then
						AttemptAutoRepair(true) -- Try using player money instead
					else
						K.Print("Your items have been repaired using guild bank funds for: " .. K.FormatMoney(cost))
					end
				elseif autoRepair == "PLAYER" then
					if autoRepairStatus == "PLAYER_REPAIR_FAILED" then
						K.Print("You don't have enough money to repair.")
					else
						K.Print("Your items have been repaired for: " .. K.FormatMoney(cost))
					end
				end
			end)
		end
	end
end

local function VendorGrays()
	local goldGained, itemID, link, itype, rarity, itemPrice, stackCount, stackPrice, _ = 0
	for bag = 0, 4, 1 do
		for slot = 1, GetContainerNumSlots(bag), 1 do
			itemID = GetContainerItemID(bag, slot)
			if itemID then
				_, link, rarity, _, _, itype, _, _, _, _, itemPrice = GetItemInfo(itemID)
				stackCount = select(2, GetContainerItemInfo(bag, slot)) or 1

				if (rarity and rarity == 0) and (itype and itype ~= "Quest") then
					stackPrice = (itemPrice or 0) * stackCount
					goldGained = goldGained + stackPrice
					if C["Inventory"].DetailedReport and link then
						K.Print(string_format("%s|cFF00DDDDx%d|r %s", link, stackCount, K.FormatMoney(stackPrice)))
					end
					UseContainerItem(bag, slot)
				end
			end
		end
	end

	if goldGained > 0 then
		K.Print(("Vendored gray items for: %s"):format(K.FormatMoney(goldGained)))
	end
end

function Module:UI_ERROR_MESSAGE(_, messageType)
	if messageType == LE_GAME_ERR_GUILD_NOT_ENOUGH_MONEY then
		autoRepairStatus = "GUILD_REPAIR_FAILED"
	elseif messageType == LE_GAME_ERR_NOT_ENOUGH_MONEY then
		autoRepairStatus = "PLAYER_REPAIR_FAILED"
	end
end

function Module:MERCHANT_CLOSED()
	self:UnregisterEvent("UI_ERROR_MESSAGE")
	self:UnregisterEvent("UPDATE_INVENTORY_DURABILITY")
	self:UnregisterEvent("MERCHANT_CLOSED")
end

function Module:MERCHANT_SHOW()
	if C["Inventory"].AutoSell then
		C_Timer_After(0.5, VendorGrays)
	end

	local autoRepair = C["Inventory"].AutoRepair.Value
	if IsShiftKeyDown() or autoRepair == "NONE" or not CanMerchantRepair() then
		return
	end

	-- Prepare to catch "not enough money" messages
	self:RegisterEvent("UI_ERROR_MESSAGE")
	-- Use this to unregister events afterwards
	self:RegisterEvent("MERCHANT_CLOSED")

	AttemptAutoRepair()
end

function Module:OnEnable()
	-- Fix old database settings and force new ones if found as a boolean
	if C["Inventory"].AutoRepair.Value == true or C["Inventory"].AutoRepair.Value == false then
		C["Inventory"].AutoRepair.Value = "NONE" -- Just reset it to NONE and the user can set it.
	end

	self:RegisterEvent("MERCHANT_SHOW")
end