--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/QoL/Durability.lua
	Purpose:
		Pulse a warning in the middle of the screen while the most worn piece of
		gear is below a chosen percentage, and drop it once gear is repaired.

		Driven by the durability event, which fires when gear actually changes, so
		nothing polls. The check also runs on login and zone changes to catch a
		character that arrives already worn.
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]

if not (K.Client and K.Client.IsRetail) then
	return
end

local Module = K:GetModule("QoL")

local floor = math.floor
local format = string.format
local GetInventoryItemDurability = GetInventoryItemDurability

-- Slots that can wear: head through off hand, minus shirt (4) and tabard (19).
local LAST_SLOT = 18
local SKIP = { [4] = true }

local alert

local function WorstPercent()
	local worst
	for slot = 1, LAST_SLOT do
		if not SKIP[slot] then
			local current, maximum = GetInventoryItemDurability(slot)
			if current and maximum and maximum > 0 then
				local percent = current / maximum * 100
				if not worst or percent < worst then
					worst = percent
				end
			end
		end
	end
	return worst
end

local function Check()
	local worst = WorstPercent()
	if worst and worst < (C.QoL.DurabilityThreshold or 25) then
		alert:Pulse(format(L["Low Durability (%d%%)"], floor(worst)), 1, 0.27, 0.27)
	else
		alert:Clear()
	end
end

function Module:SetupDurability()
	alert = self:RegisterAlert("DurabilityAlert", L["Durability Warning"], "CENTER", 250)
	self:RegisterEvent("UPDATE_INVENTORY_DURABILITY", Check)
	self:RegisterEvent("PLAYER_ENTERING_WORLD", Check)
end
