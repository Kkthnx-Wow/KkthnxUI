local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Bags")

local string_format = string.format

local C_Timer_After = C_Timer.After
local CanGuildBankRepair = CanGuildBankRepair
local CanMerchantRepair = CanMerchantRepair
local GetGuildBankWithdrawMoney = GetGuildBankWithdrawMoney
local GetMoney = GetMoney
local GetRepairAllCost = GetRepairAllCost
local IsInGuild = IsInGuild
local IsShiftKeyDown = IsShiftKeyDown
local LE_GAME_ERR_GUILD_NOT_ENOUGH_MONEY = LE_GAME_ERR_GUILD_NOT_ENOUGH_MONEY

-- Auto repair
local autoRepair
local canRepair
local isBankEmpty
local isShown
local repairAllCost

local function delayFunc()
	if isBankEmpty then
		autoRepair(true)
	else
		K.Print(string_format("%s%s", K.SystemColor .. L["Repaired Items Guild"], K.FormatMoney(repairAllCost)))
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
		if not override and C["Inventory"].AutoRepair.Value == 1 and IsInGuild() and CanGuildBankRepair() and GetGuildBankWithdrawMoney() >= repairAllCost then
			_G.RepairAllItems(true)
		else
			if myMoney > repairAllCost then
				_G.RepairAllItems()
				K.Print(string_format("%s%s", K.SystemColor .. L["Repaired Items"], K.FormatMoney(repairAllCost)))
				return
			else
				K.Print(K.SystemColor .. L["Repaired Failed"] .. K.Name)
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
