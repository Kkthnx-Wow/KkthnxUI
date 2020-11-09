local K, C, L = unpack(select(2, ...))
local Module = K:GetModule("Bags")

local _G = _G
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
local isShown, isBankEmpty, autoRepair, repairAllCost, canRepair

local function delayFunc()
	if isBankEmpty then
		autoRepair(true)
	else
		K.Print(string_format("%s%s", K.SystemColor..L["Repaired Items Guild"], K.FormatMoney(repairAllCost)))
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
		if (not override) and C["Inventory"].AutoRepair.Value == 1 and IsInGuild() and CanGuildBankRepair() and GetGuildBankWithdrawMoney() >= repairAllCost then
			_G.RepairAllItems(true)
		else
			if myMoney > repairAllCost then
				_G.RepairAllItems()
				K.Print(string_format("%s%s", K.SystemColor..L["Repaired Items"], K.FormatMoney(repairAllCost)))
				return
			else
				K.Print(K.SystemColor..L["Repaired Failed"]..K.Name)
				return
			end
		end

		C_Timer_After(.5, delayFunc)
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
	if IsShiftKeyDown() or C["Inventory"].AutoRepair.Value == 0 or not CanMerchantRepair() then
		return
	end

	autoRepair()
	K:RegisterEvent("UI_ERROR_MESSAGE", checkBankFund)
	K:RegisterEvent("MERCHANT_CLOSED", merchantClose)
end

function Module:CreateAutoRepair()
	K:RegisterEvent("MERCHANT_SHOW", merchantShow)
end