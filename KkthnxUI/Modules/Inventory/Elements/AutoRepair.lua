--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Automates equipment repair at qualified vendors.
-- - Design: Monitors merchant interactions and triggers repair using player or guild funds based on configuration.
-- - Events: MERCHANT_SHOW
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Bags")

-- PERF: Localize global functions to avoid hashtable lookups in high-frequency events or loops.
-- REASON: Ensures consistent behavior if global functions are hooked or tainted by other AddOns.
local string_format = string.format

local CanGuildBankRepair = CanGuildBankRepair
local CanMerchantRepair = CanMerchantRepair
local GetGuildBankWithdrawMoney = GetGuildBankWithdrawMoney
local GetMoney = GetMoney
local GetRepairAllCost = GetRepairAllCost
local IsInGuild = IsInGuild
local IsShiftKeyDown = IsShiftKeyDown
local LE_GAME_ERR_GUILD_NOT_ENOUGH_MONEY = LE_GAME_ERR_GUILD_NOT_ENOUGH_MONEY
local RepairAllItems = RepairAllItems

-- REASON: Define upvalues for state management across local functions.
-- NOTE: 'autoRepair' is forward-declared to handle cyclic dependencies in 'delayFunc'.
local autoRepair -- forward declaration as local to avoid global pollution
local canRepair
local isBankEmpty
local isShown
local repairAllCost

local function delayFunc()
	if isBankEmpty then
		-- REASON: Guild repair failed (flagged by checkBankFund); retry with personal funds.
		autoRepair(true)
	else
		K.Print(string_format("%s%s", K.SystemColor .. L["Repaired Items Guild"], K.FormatMoney(repairAllCost)))
	end
end

local function autoRepair(override)
	if isShown and not override then
		-- REASON: Prevent double-execution if the function is re-triggered rapidly.
		return
	end

	isShown = true
	isBankEmpty = false

	local myMoney = GetMoney()
	-- COMPAT: 'GetRepairAllCost' returns cost and a boolean 'canRepair' (item durability state).
	repairAllCost, canRepair = GetRepairAllCost()

	if canRepair and repairAllCost > 0 then
		local t0

		-- REASON: Check Guild Repair eligibility:
		-- 1. Not in override mode (personal repair fallback).
		-- 2. User setting 'AutoRepair' is set to 1 (Guild).
		-- 3. Player is in a guild, maintains permission, and has sufficient withdraw allowance.
		-- NOTE: 'GetGuildBankWithdrawMoney' creates a server query; result might be slightly latent.
		if not override and C["Inventory"].AutoRepair == 1 and IsInGuild() and CanGuildBankRepair() and GetGuildBankWithdrawMoney() >= repairAllCost then
			-- REASON: 'true' argument specifies using Guild Bank funds.
			RepairAllItems(true)
		else
			if myMoney > repairAllCost then
				-- REASON: No argument defaults to using personal funds.
				RepairAllItems()
				K.Print(string_format("%s%s", K.SystemColor .. L["Repaired Items"], K.FormatMoney(repairAllCost)))
				return
			else
				K.Print(K.SystemColor .. L["Repaired Failed"] .. K.Name)
				return
			end
		end

		-- REASON: Small delay prevents race conditions where 'UI_ERROR_MESSAGE' (insufficient guild funds)
		-- fires *after* the success message logic would typically execute.
		K.Delay(0.5, delayFunc)
	end
end

local function checkBankFund(_, msgType)
	-- REASON: Detect specific UI errors indicating guild bank failure (e.g., daily withdraw limit reached).
	-- NOTE: Sets 'isBankEmpty' flag to trigger personal fund fallback in 'delayFunc'.
	if msgType == LE_GAME_ERR_GUILD_NOT_ENOUGH_MONEY then
		isBankEmpty = true
	end
end

local function merchantClose()
	isShown = false
	-- PERF: Unregistering events prevents unnecessary script execution when not visiting a merchant.
	K:UnregisterEvent("UI_ERROR_MESSAGE", checkBankFund)
	K:UnregisterEvent("MERCHANT_CLOSED", merchantClose)
end

local function merchantShow()
	local mode = C["Inventory"].AutoRepair
	-- REASON: Bypass auto-repair if Shift is held (user override), mode is disabled, or
	-- 'CanMerchantRepair' is false (e.g., vendor only sells items but cannot repair).
	if IsShiftKeyDown() or mode == 3 or not CanMerchantRepair() then
		return
	end

	autoRepair()
	-- REASON: Register events only during the interaction window to monitor for specific failures.
	K:RegisterEvent("UI_ERROR_MESSAGE", checkBankFund)
	K:RegisterEvent("MERCHANT_CLOSED", merchantClose)
end

function Module:CreateAutoRepair()
	-- REASON: Initialize the module by registering the 'MERCHANT_SHOW' event.
	K:RegisterEvent("MERCHANT_SHOW", merchantShow)
end
