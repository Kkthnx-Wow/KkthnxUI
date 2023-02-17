local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Automation")

local CancelDuel = CancelDuel
local StaticPopup_Hide = StaticPopup_Hide
local C_PetBattles_CancelPVPDuel = C_PetBattles.CancelPVPDuel

-- Cancels a pending duel request
function Module:DUEL_REQUESTED(name)
	CancelDuel() -- Call CancelDuel to cancel the request
	StaticPopup_Hide("DUEL_REQUESTED") -- Hides the pending duel popup
	print("Declined a duel request from: " .. K.InfoColor .. name .. "|r") -- Print confirmation message
end

-- Cancels a pending pet battle pvp duel request
function Module:PET_BATTLE_PVP_DUEL_REQUESTED(name)
	C_PetBattles_CancelPVPDuel() -- Call C_PetBattles_CancelPVPDuel to cancel the request
	StaticPopup_Hide("PET_BATTLE_PVP_DUEL_REQUESTED") -- Hides the pending pet battle pvp duel popup
	print("Declined a pet battle pvp duel request from: " .. K.InfoColor .. name .. "|r") -- Print confirmation message
end
function Module:CreateAutoDeclineDuels()
	if C["Automation"].AutoDeclineDuels then
		K:RegisterEvent("DUEL_REQUESTED", Module.DUEL_REQUESTED)
		K:RegisterEvent("PET_BATTLE_PVP_DUEL_REQUESTED", Module.PET_BATTLE_PVP_DUEL_REQUESTED)
	else
		K:UnregisterEvent("DUEL_REQUESTED", Module.DUEL_REQUESTED)
		K:UnregisterEvent("PET_BATTLE_PVP_DUEL_REQUESTED", Module.PET_BATTLE_PVP_DUEL_REQUESTED)
	end
end
