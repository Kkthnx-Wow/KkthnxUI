local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Bags")

-- Locals for speed / clarity
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

-- Auto repair
local autoRepair -- forward declaration as local to avoid global pollution
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

local function autoRepair(override)
	if isShown and not override then
		return
	end

	isShown = true
	isBankEmpty = false

	local myMoney = GetMoney()
	repairAllCost, canRepair = GetRepairAllCost()

	if canRepair and repairAllCost > 0 then
		local t0

		if not override and C["Inventory"].AutoRepair == 1 and IsInGuild() and CanGuildBankRepair() and GetGuildBankWithdrawMoney() >= repairAllCost then
			RepairAllItems(true)
		else
			if myMoney > repairAllCost then
				RepairAllItems()
				K.Print(string_format("%s%s", K.SystemColor .. L["Repaired Items"], K.FormatMoney(repairAllCost)))
				return
			else
				K.Print(K.SystemColor .. L["Repaired Failed"] .. K.Name)
				return
			end
		end

		K.Delay(0.5, delayFunc)
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
	local mode = C["Inventory"].AutoRepair
	if IsShiftKeyDown() or mode == 3 or not CanMerchantRepair() then
		return
	end

	autoRepair()
	K:RegisterEvent("UI_ERROR_MESSAGE", checkBankFund)
	K:RegisterEvent("MERCHANT_CLOSED", merchantClose)
end

function Module:CreateAutoRepair()
	K:RegisterEvent("MERCHANT_SHOW", merchantShow)
end
