--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/Automation/DeclineDuel.lua
	Purpose:
		Turn away duel and pet-battle duel requests, hide the popup, and say who
		was declined. The events register once and each handler checks its toggle
		when it fires, so switching them on or off needs no reload. Retail only.
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]

if not (K.Client and K.Client.IsRetail) then
	return
end

local Module = K:GetModule("Automation")

local format = string.format
local CancelDuel = CancelDuel
local StaticPopup_Hide = StaticPopup_Hide
local CancelPVPDuel = C_PetBattles and C_PetBattles.CancelPVPDuel
local UNKNOWN = _G.UNKNOWN or "Unknown"

function Module:DUEL_REQUESTED(_, name)
	if not C.Automation.DeclineDuels then
		return
	end
	CancelDuel()
	StaticPopup_Hide("DUEL_REQUESTED")
	K.Print(format(L["Declined a duel from %s."], name or UNKNOWN))
end

function Module:PET_BATTLE_PVP_DUEL_REQUESTED(_, name)
	if not C.Automation.DeclinePetDuels then
		return
	end
	if CancelPVPDuel then
		CancelPVPDuel()
	end
	StaticPopup_Hide("PET_BATTLE_PVP_DUEL_REQUESTED")
	K.Print(format(L["Declined a pet battle duel from %s."], name or UNKNOWN))
end

function Module:SetupDeclineDuel()
	self:RegisterEvent("DUEL_REQUESTED", "DUEL_REQUESTED")
	self:RegisterEvent("PET_BATTLE_PVP_DUEL_REQUESTED", "PET_BATTLE_PVP_DUEL_REQUESTED")
end
