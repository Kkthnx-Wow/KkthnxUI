--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/QoL/CombatAlert.lua
	Purpose:
		Put "+Combat" or "-Combat" in the middle of the screen when combat starts
		or ends, for players who watch the action more than their frames.
-----------------------------------------------------------------------------]]

local K, L = KkthnxUI[1], KkthnxUI[3]

if not (K.Client and K.Client.IsRetail) then
	return
end

local Module = K:GetModule("QoL")

local alert

local function OnEnterCombat()
	alert:Flash(L["+Combat"], 1, 0.35, 0.35)
end

local function OnLeaveCombat()
	alert:Flash(L["-Combat"], 0.45, 0.9, 0.5)
end

function Module:SetupCombatAlert()
	alert = self:RegisterAlert("CombatAlert", L["Combat Alert"], "CENTER", 170)
	self:RegisterEvent("PLAYER_REGEN_DISABLED", OnEnterCombat)
	self:RegisterEvent("PLAYER_REGEN_ENABLED", OnLeaveCombat)
end
