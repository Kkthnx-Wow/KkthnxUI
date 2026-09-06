--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/Automation/AutoRepair.lua
	Purpose:
		Repair all gear the moment a repair-capable merchant opens, optionally out
		of guild funds first, then fall back to your own coin. A short chat line
		reports what it spent so the gold does not vanish silently. The toggle is
		re-checked on every merchant visit, so it applies without a reload.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

-- The Automation module only registers on retail, so match its siblings and bail
-- before touching it on other flavours (TBC Anniversary, ...).
if not (K.Client and K.Client.IsRetail) then
	return
end

local Module = K:GetModule("Automation")

local CanMerchantRepair = CanMerchantRepair
local GetRepairAllCost = GetRepairAllCost
local RepairAllItems = RepairAllItems
local CanGuildBankRepair = CanGuildBankRepair
local GetGuildBankWithdrawMoney = GetGuildBankWithdrawMoney
local GetMoney = GetMoney
local GetCoinTextureString = GetCoinTextureString
local IsInGuild = IsInGuild

-- Track whether the last attempt used guild money so the durability follow-up
-- can confirm it worked (a guild repair can silently no-op without permission).
local triedGuild

local function Report(cost, guild)
	local where = guild and (" (" .. (_G.GUILD or "Guild") .. ")") or ""
	K.Print("Repaired for %s%s", GetCoinTextureString(cost), where)
end

function Module:MERCHANT_SHOW()
	if not C.Automation.AutoRepair or not CanMerchantRepair() then
		return
	end

	local cost, canRepair = GetRepairAllCost()
	if not canRepair or not cost or cost <= 0 then
		return
	end

	triedGuild = false

	-- Guild funds first when asked and allowed. Withdraw of -1 means unlimited
	-- (guild master), otherwise it is the remaining daily allowance.
	if C.Automation.RepairGuildFunds and IsInGuild() and CanGuildBankRepair() then
		local allowance = GetGuildBankWithdrawMoney()
		if allowance == -1 or allowance >= cost then
			RepairAllItems(true)
			triedGuild = true
			Report(cost, true)
			return
		end
	end

	if GetMoney() >= cost then
		RepairAllItems(false)
		Report(cost, false)
	else
		K.Print("Not enough money to repair.")
	end
end

-- If the guild attempt did not actually mend anything (no permission), the
-- durability event still fires as damaged, so retry once from personal coin.
function Module:UPDATE_INVENTORY_DURABILITY()
	if not triedGuild then
		return
	end
	triedGuild = false
	if not CanMerchantRepair() then
		return
	end
	local cost, canRepair = GetRepairAllCost()
	if canRepair and cost and cost > 0 and GetMoney() >= cost then
		RepairAllItems(false)
		Report(cost, false)
	end
end

function Module:SetupAutoRepair()
	self:RegisterEvent("MERCHANT_SHOW", "MERCHANT_SHOW")
	self:RegisterEvent("UPDATE_INVENTORY_DURABILITY", "UPDATE_INVENTORY_DURABILITY")
end
