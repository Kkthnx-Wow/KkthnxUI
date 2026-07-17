--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Sync character gold with the Warband bank when opening the bank.
-- - Design: Deposits surplus above target; optional withdraw when below target.
-- - Events: BANKFRAME_OPENED
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Bags")

local C_Bank = _G.C_Bank
local C_Timer_After = _G.C_Timer.After
local Enum = _G.Enum
local GetMoney = GetMoney
local math_floor = math.floor
local math_min = math.min

local COPPER_PER_GOLD = 10000
local eventsRegistered = false

local function getBankType()
	return Enum.BankType and Enum.BankType.Account
end

local function autoSyncWarbandGold()
	if not C["Inventory"].AutoWarbandGold then
		return
	end

	local bankType = getBankType()
	if not bankType then
		return
	end
	if not C_Bank or not C_Bank.DoesBankTypeSupportMoneyTransfer or not C_Bank.DoesBankTypeSupportMoneyTransfer(bankType) then
		return
	end
	if not C_Bank.CanUseBank or not C_Bank.CanUseBank(bankType) then
		return
	end

	local targetGold = tonumber(C["Inventory"].WarbandGoldTarget) or 10000
	if targetGold < 0 then
		targetGold = 0
	end
	local targetCopper = math_floor((targetGold * COPPER_PER_GOLD) + 0.5)
	local playerMoney = GetMoney()
	if K.IsSecret(playerMoney) then
		return
	end
	playerMoney = playerMoney or 0

	if playerMoney > targetCopper then
		if not C_Bank.CanDepositMoney or not C_Bank.CanDepositMoney(bankType) then
			return
		end
		local amountToDeposit = playerMoney - targetCopper
		if amountToDeposit <= 0 then
			return
		end
		C_Bank.DepositMoney(bankType, amountToDeposit)
		K.Print(string.format(L["Warband Gold Deposited"], K.FormatMoney(amountToDeposit)))
		return
	end

	if not C["Inventory"].WarbandGoldWithdraw then
		return
	end
	if playerMoney >= targetCopper then
		return
	end
	if not C_Bank.CanWithdrawMoney or not C_Bank.CanWithdrawMoney(bankType) then
		return
	end

	local warbandMoney = 0
	if C_Bank.FetchDepositedMoney then
		local ok, money = pcall(C_Bank.FetchDepositedMoney, bankType)
		if ok and K.NotSecret(money) then
			warbandMoney = money or 0
		end
	end

	local amountToWithdraw = math_min(targetCopper - playerMoney, warbandMoney)
	if amountToWithdraw <= 0 then
		return
	end

	C_Bank.WithdrawMoney(bankType, amountToWithdraw)
	K.Print(string.format(L["Warband Gold Withdrew"], K.FormatMoney(amountToWithdraw)))
end

local function onBankOpened()
	C_Timer_After(0.1, autoSyncWarbandGold)
end

function Module:CreateAutoWarbandGold()
	if not C["Inventory"].AutoWarbandGold then
		if eventsRegistered then
			K:UnregisterEvent("BANKFRAME_OPENED", onBankOpened)
			eventsRegistered = false
		end
		return
	end

	if eventsRegistered then
		return
	end

	eventsRegistered = true
	K:RegisterEvent("BANKFRAME_OPENED", onBankOpened)
end
