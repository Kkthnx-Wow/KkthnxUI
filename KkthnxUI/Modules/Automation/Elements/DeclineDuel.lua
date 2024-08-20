local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Automation")

local CancelDuel, StaticPopup_Hide, C_PetBattles_CancelPVPDuel = CancelDuel, StaticPopup_Hide, C_PetBattles.CancelPVPDuel
local confirmationColor = "|cff00ff00"

-- Decline a duel request and hide the popup
function Module:DUEL_REQUESTED(name)
	CancelDuel()
	StaticPopup_Hide("DUEL_REQUESTED")
	K.Print(confirmationColor .. "Declined a duel request from: " .. name .. "|r")
end

-- Decline a pet battle PVP duel request and hide the popup
function Module:PET_BATTLE_PVP_DUEL_REQUESTED(name)
	C_PetBattles_CancelPVPDuel()
	StaticPopup_Hide("PET_BATTLE_PVP_DUEL_REQUESTED")
	K.Print(confirmationColor .. "Declined a pet battle PVP duel request from: " .. name .. "|r")
end

-- Register or unregister events for auto-declining duels
function Module:CreateAutoDeclineDuels()
	if C["Automation"].AutoDeclineDuels then
		K:RegisterEvent("DUEL_REQUESTED", self.DUEL_REQUESTED)
		K:RegisterEvent("PET_BATTLE_PVP_DUEL_REQUESTED", self.PET_BATTLE_PVP_DUEL_REQUESTED)
	else
		K:UnregisterEvent("DUEL_REQUESTED", self.DUEL_REQUESTED)
		K:UnregisterEvent("PET_BATTLE_PVP_DUEL_REQUESTED", self.PET_BATTLE_PVP_DUEL_REQUESTED)
	end
end
