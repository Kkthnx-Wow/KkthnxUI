--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/Automation/AutoRepair.lua
	Purpose:
		Repair all gear the moment a repair-capable merchant opens, optionally out
		of guild funds first, then fall back to your own coin.

		Nothing is reported until the game confirms it. RepairAllItems can be
		refused by the server without raising an error, so the chat line is driven
		by UPDATE_INVENTORY_DURABILITY, which fires only when gear actually mends.
		A refused repair therefore prints nothing rather than claiming success.

		The verification event is registered only while a repair is in flight, so
		an idle session never pays for it.
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

-- The repair in flight: the bill, whether guild funds were asked for, and the
-- purse before the attempt so the real spend can be read back afterwards.
local pending

local function StopWatching()
	pending = nil
	Module:UnregisterEvent("UPDATE_INVENTORY_DURABILITY", Module.UPDATE_INVENTORY_DURABILITY)
	Module:UnregisterEvent("MERCHANT_CLOSED", Module.MERCHANT_CLOSED)
end

local function Attempt(cost, useGuild)
	pending = { cost = cost, guild = useGuild, money = GetMoney() }
	-- Registered per attempt rather than for the session: outside a repair these
	-- events are pure noise, and durability ticks constantly in combat.
	Module:RegisterEvent("UPDATE_INVENTORY_DURABILITY", Module.UPDATE_INVENTORY_DURABILITY)
	Module:RegisterEvent("MERCHANT_CLOSED", Module.MERCHANT_CLOSED)
	RepairAllItems(useGuild)
end

function Module:MERCHANT_SHOW()
	if not C.Automation.AutoRepair or not CanMerchantRepair() then
		return
	end

	local cost, canRepair = GetRepairAllCost()
	if not canRepair or cost <= 0 then
		return
	end

	-- Guild funds first when asked and allowed. A withdraw limit of -1 means
	-- unlimited (guild master), otherwise it is the remaining daily allowance.
	if C.Automation.RepairGuildFunds and IsInGuild() and CanGuildBankRepair() then
		local allowance = GetGuildBankWithdrawMoney()
		if allowance == -1 or allowance >= cost then
			Attempt(cost, true)
			return
		end
	end

	if GetMoney() < cost then
		K.Print("Not enough money to repair (%s).", GetCoinTextureString(cost))
		return
	end

	Attempt(cost, false)
end

-- Gear actually mended, so the attempt landed. Anything still damaged after a
-- guild attempt means the guild bank refused it, which the server does silently,
-- so pay the rest personally.
function Module:UPDATE_INVENTORY_DURABILITY()
	if not pending then
		return
	end

	local remaining, canRepair = GetRepairAllCost()
	if pending.guild and canRepair and remaining > 0 then
		if GetMoney() >= remaining then
			Attempt(remaining, false)
		else
			K.Print("Guild funds were refused and you cannot cover the rest (%s).", GetCoinTextureString(remaining))
			StopWatching()
		end
		return
	end

	-- Coin that left the purse is the player's share. Nothing spent on a guild
	-- attempt means the guild bank paid the whole bill.
	local spent = pending.money - GetMoney()
	local cost = pending.cost
	StopWatching()

	if spent > 0 then
		K.Print("Repaired for %s", GetCoinTextureString(spent))
	else
		K.Print("Repaired for %s (%s)", GetCoinTextureString(cost), _G.GUILD or "Guild")
	end
end

-- Walking away from the merchant ends the attempt, so the watch never outlives
-- the visit that started it.
function Module:MERCHANT_CLOSED()
	if pending then
		StopWatching()
	end
end

function Module:SetupAutoRepair()
	self:RegisterEvent("MERCHANT_SHOW", "MERCHANT_SHOW")
end
