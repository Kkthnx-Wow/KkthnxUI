local K, C, L = unpack(KkthnxUI)
local Module = K:GetModule("Bags")

local string_format = _G.string.format

local C_Timer_After = _G.C_Timer.After
local CanGuildBankRepair = _G.CanGuildBankRepair
local CanMerchantRepair = _G.CanMerchantRepair
local GetGuildBankWithdrawMoney = _G.GetGuildBankWithdrawMoney
local GetMoney = _G.GetMoney
local GetRepairAllCost = _G.GetRepairAllCost
local IsInGuild = _G.IsInGuild
local IsShiftKeyDown = _G.IsShiftKeyDown
local LE_GAME_ERR_GUILD_NOT_ENOUGH_MONEY = _G.LE_GAME_ERR_GUILD_NOT_ENOUGH_MONEY

-- Auto repair
local autoRepair -- function that handles the repair of all items
local canRepair -- boolean indicating if repair is possible
local isBankEmpty -- boolean indicating if guild bank is empty
local isShown -- boolean indicating if the function is currently shown
local repairAllCost -- cost to repair all items

local function delayFunc()
	-- Check if the guild bank is empty
	if isBankEmpty then
		-- Call the autoRepair function with the override argument set to true
		autoRepair(true)
	else
		-- Print a message indicating that the repair was done with the guild bank
		K.Print(string_format("%s%s", K.SystemColor .. L["Repaired Items Guild"], K.FormatMoney(repairAllCost)))
	end
end

function autoRepair(override)
	-- If the function is already shown and override is not set, return immediately
	if isShown and not override then
		return
	end

	-- set isShown to true and isBankEmpty to false
	isShown = true
	isBankEmpty = false

	-- Get the player's current money
	local myMoney = GetMoney()

	-- Get the cost to repair all items and check if repair is possible
	repairAllCost, canRepair = GetRepairAllCost()

	-- If repair is possible and there is a cost to repair
	if canRepair and repairAllCost > 0 then
		-- If override is not set, check if C["Inventory"].AutoRepair.Value is 1 and the player is in a guild and the guild bank can repair
		if not override and C["Inventory"].AutoRepair.Value == 1 and IsInGuild() and CanGuildBankRepair() and GetGuildBankWithdrawMoney() >= repairAllCost then
			_G.RepairAllItems(true)
		else
			-- If the player has enough money, repair the items and print a message
			if myMoney > repairAllCost then
				_G.RepairAllItems()
				K.Print(string_format("%s%s", K.SystemColor .. L["Repaired Items"], K.FormatMoney(repairAllCost)))
				return
			else
				-- If the player doesn't have enough money, print a message
				K.Print(K.SystemColor .. L["Repaired Failed"] .. K.Name)
				return
			end
		end

		-- Wait 0.5 seconds before calling delayFunc
		C_Timer_After(0.5, delayFunc)
	end
end

local function checkBankFund(_, msgType)
	-- Check if the message type is indicating that the guild doesn't have enough money
	if msgType == LE_GAME_ERR_GUILD_NOT_ENOUGH_MONEY then
		-- Set the isBankEmpty variable to true
		isBankEmpty = true
	end
end

local function merchantClose()
	-- Set isShown to false
	isShown = false
	-- Unregister the UI_ERROR_MESSAGE event
	K:UnregisterEvent("UI_ERROR_MESSAGE", checkBankFund)
	-- Unregister the MERCHANT_CLOSED event
	K:UnregisterEvent("MERCHANT_CLOSED", merchantClose)
end

local function merchantShow()
	-- If shift key is down or C["Inventory"].AutoRepair.Value is 0 or the merchant can't repair, return
	if IsShiftKeyDown() or C["Inventory"].AutoRepair.Value == 0 or not CanMerchantRepair() then
		return
	end

	-- Call the autoRepair function
	autoRepair()
	-- Register the UI_ERROR_MESSAGE event
	K:RegisterEvent("UI_ERROR_MESSAGE", checkBankFund)
	-- Register the MERCHANT_CLOSED event
	K:RegisterEvent("MERCHANT_CLOSED", merchantClose)
end

function Module:CreateAutoRepair()
	-- Register the MERCHANT_SHOW event
	K:RegisterEvent("MERCHANT_SHOW", merchantShow)
end
