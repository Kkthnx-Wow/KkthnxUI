local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Automation")

local CancelDuel = CancelDuel
local StaticPopup_Hide = StaticPopup_Hide
local C_PetBattles_CancelPVPDuel = C_PetBattles.CancelPVPDuel
local confirmationColor = "|cff00ff00"

-- Declines a pending duel request
function Module:DUEL_REQUESTED(name)
	CancelDuel() -- Cancel the duel request
	StaticPopup_Hide("DUEL_REQUESTED") -- Hide the pending duel popup
	print("Declined a duel request from: " .. confirmationColor .. name .. "|r") -- Print confirmation message
end

-- Declines a pending pet battle PVP duel request
function Module:PET_BATTLE_PVP_DUEL_REQUESTED(name)
	C_PetBattles_CancelPVPDuel() -- Cancel the pet battle PVP duel request
	StaticPopup_Hide("PET_BATTLE_PVP_DUEL_REQUESTED") -- Hide the pending pet battle PVP duel popup
	print("Declined a pet battle PVP duel request from: " .. confirmationColor .. name .. "|r") -- Print confirmation message
end

-- Registers or unregisters the event handlers for auto-declining duels
function Module:CreateAutoDeclineDuels()
	if C["Automation"].AutoDeclineDuels then
		K:RegisterEvent("DUEL_REQUESTED", Module.DUEL_REQUESTED) -- Register the DUEL_REQUESTED event
		K:RegisterEvent("PET_BATTLE_PVP_DUEL_REQUESTED", Module.PET_BATTLE_PVP_DUEL_REQUESTED) -- Register the PET_BATTLE_PVP_DUEL_REQUESTED event
	else
		K:UnregisterEvent("DUEL_REQUESTED", Module.DUEL_REQUESTED) -- Unregister the DUEL_REQUESTED event
		K:UnregisterEvent("PET_BATTLE_PVP_DUEL_REQUESTED", Module.PET_BATTLE_PVP_DUEL_REQUESTED) -- Unregister the PET_BATTLE_PVP_DUEL_REQUESTED event
	end
end
