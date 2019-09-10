local K, C, L = unpack(select(2, ...))

-- Sourced: ElvUI

local _G = _G
local select = _G.select
local string_format = _G.string.format
local table_wipe = _G.table.wipe

local C_Timer_After = _G.C_Timer.After
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
local IsShiftKeyDown = _G.IsShiftKeyDown
local LE_GAME_ERR_GUILD_NOT_ENOUGH_MONEY = _G.LE_GAME_ERR_GUILD_NOT_ENOUGH_MONEY or 140

do -- Auto Sell Junk
	local sellCount, stop, cache = 0, true, {}
	local errorText = _G.ERR_VENDOR_DOESNT_BUY
	local function stopSelling(tell)
		stop = true

		if sellCount > 0 and tell then
			K.Print(string_format(L["Sold Grays"], K.FormatMoney(sellCount)))
		end

		sellCount = 0
	end

	local function startSelling()
		if stop then return end
		for bag = 0, 4 do
			for slot = 1, GetContainerNumSlots(bag) do
				if stop then
					return
				end

				local link = GetContainerItemLink(bag, slot)
				if link then
					local price = select(11, GetItemInfo(link))
					local _, count, _, quality = GetContainerItemInfo(bag, slot)
					if quality == 0 and price > 0 and not cache["b"..bag.."s"..slot] then
						sellCount = sellCount + price * count
						cache["b"..bag.."s"..slot] = true
						_G.UseContainerItem(bag, slot)
						C_Timer_After(0.2, startSelling)
						return
					end
				end
			end
		end
	end

	local function updateSelling(event, ...)
		if not C["Inventory"].AutoSell then
			return
		end

		local _, arg = ...
		if event == "MERCHANT_SHOW" then
			if IsShiftKeyDown() then
				return
			end

			stop = false
			table_wipe(cache)
			startSelling()
			K:RegisterEvent("UI_ERROR_MESSAGE", updateSelling)
		elseif event == "UI_ERROR_MESSAGE" and arg == errorText then
			stopSelling(false)
		elseif event == "MERCHANT_CLOSED" then
			stopSelling(true)
		end
	end

	K:RegisterEvent("MERCHANT_SHOW", updateSelling)
	K:RegisterEvent("MERCHANT_CLOSED", updateSelling)
end

do -- AutoRepair
	local isShown, isBankEmpty, autoRepair, repairAllCost, canRepair
	local function delayFunc()
		if isBankEmpty then
			autoRepair(true)
		else
			print(string_format("%s:|r %s", L["Guild Repair"], K.FormatMoney(repairAllCost)))
		end
	end

	function autoRepair(override)
		if isShown and not override then
			return
		end

		isShown = true
		isBankEmpty = false

		local myMoney = GetMoney()
		repairAllCost, canRepair = GetRepairAllCost()

		if canRepair and repairAllCost > 0 then
			if (not override) and C["Inventory"].AutoRepair.Value == "GUILD" and IsInGuild() and CanGuildBankRepair() and GetGuildBankWithdrawMoney() >= repairAllCost then
				_G.RepairAllItems(true)
			else
				if myMoney > repairAllCost then
					_G.RepairAllItems()
					K.Print(string_format("%s %s", L["Repair Cost"], K.FormatMoney(repairAllCost)))
					return
				else
					K.Print(L["Not Enough Money"])
					return
				end
			end

			C_Timer_After(0.5, delayFunc)
		end
	end

	local function checkBankFund(_, msgType)
		if msgType == LE_GAME_ERR_GUILD_NOT_ENOUGH_MONEY then
			isBankEmpty = true
		end
	end

	local function merchantClose()
		isShown = false
		K:UnregisterEvent("UI_ERROR_MESSAGE", checkBankFund)
		K:UnregisterEvent("MERCHANT_CLOSED", merchantClose)
	end

	local function merchantShow()
		if IsShiftKeyDown() or C["Inventory"].AutoRepair.Value == "NONE" or not CanMerchantRepair() then
			return
		end

		autoRepair()
		K:RegisterEvent("UI_ERROR_MESSAGE", checkBankFund)
		K:RegisterEvent("MERCHANT_CLOSED", merchantClose)
	end

	K:RegisterEvent("MERCHANT_SHOW", merchantShow)
end