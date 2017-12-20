local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("VendorStuff", "AceEvent-3.0", "AceTimer-3.0")

-- Lua WoW
local _G = _G

local autoRepairStatus
local function AttemptAutoRepair(playerOverride)
	autoRepairStatus = ""
	local autoRepair = C["Misc"].AutoRepair
	local cost, possible = GetRepairAllCost()
	local withdrawLimit = GetGuildBankWithdrawMoney();
	-- This check evaluates to true even if the guild bank has 0 gold, so we add an override
	if autoRepair == "GUILD" and ((not CanGuildBankRepair() or cost > withdrawLimit) or playerOverride) then
		autoRepair = "PLAYER"
	end

	if cost > 0 then
		if possible then
			RepairAllItems(autoRepair == "GUILD")

			-- Delay this a bit so we have time to catch the outcome of first repair attempt
			C_Timer.After(0.5, function()
				if autoRepair == "GUILD" then
					if autoRepairStatus == "GUILD_REPAIR_FAILED" then
						AttemptAutoRepair(true) --Try using player money instead
					else
						K.Print("Your items have been repaired using guild bank funds for: "..K.FormatMoney(cost)) --Amount, style, textOnly
					end
				elseif autoRepair == "PLAYER" then
					if autoRepairStatus == "PLAYER_REPAIR_FAILED" then
						K.Print("You don't have enough money to repair.")
					else
						K.Print("Your items have been repaired for: "..K.FormatMoney(cost)) --Amount, style, textOnly
					end
				end
			end)
		end
	end
end

local function VendorGrays()
	K:GetModule("Bags"):VendorGrays()
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
	if C["Misc"].AutoSell then
		C_Timer.After(0.5, VendorGrays)
	end

	local autoRepair = C["Misc"].AutoRepair
	if IsShiftKeyDown() or autoRepair == "NONE" or not CanMerchantRepair() then return end

	-- Prepare to catch "not enough money" messages
	self:RegisterEvent("UI_ERROR_MESSAGE")
	-- Use this to unregister events afterwards
	self:RegisterEvent("MERCHANT_CLOSED")

	AttemptAutoRepair()
end

function Module:OnEnable()
	self:RegisterEvent("MERCHANT_SHOW")
end