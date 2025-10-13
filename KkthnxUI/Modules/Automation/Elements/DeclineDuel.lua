local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Automation")

-- Localize frequently used globals/functions for performance (Lua 5.1)
local CancelDuel = CancelDuel
local StaticPopup_Hide = StaticPopup_Hide
local C_PetBattles_CancelPVPDuel = C_PetBattles and C_PetBattles.CancelPVPDuel
local debugprofilestop = debugprofilestop
local format = string.format
local UNKNOWN_NAME = UNKNOWN

-- Constants
local confirmationColor = "|cff00ff00"
local colorReset = "|r"

-- Decline a duel request and hide the popup
function Module:DUEL_REQUESTED(name)
	local t0
	if K.isDeveloper then
		t0 = debugprofilestop()
	end

	CancelDuel()
	StaticPopup_Hide("DUEL_REQUESTED")

	name = name or UNKNOWN_NAME
	local MSG_DUEL = L["Declined a duel request from: %s"]
	K.Print(confirmationColor .. format(MSG_DUEL, name) .. colorReset)

	if K.isDeveloper then
		local dt = debugprofilestop() - t0
		K.Print(format("[KKUI_DEV] %s handled in %.3f ms", "DUEL_REQUESTED", dt))
	end
end

-- Decline a pet battle PVP duel request and hide the popup
function Module:PET_BATTLE_PVP_DUEL_REQUESTED(name)
	local t0
	if K.isDeveloper then
		t0 = debugprofilestop()
	end

	C_PetBattles_CancelPVPDuel()
	StaticPopup_Hide("PET_BATTLE_PVP_DUEL_REQUESTED")

	name = name or UNKNOWN_NAME
	local MSG_PET = L["Declined a pet battle PVP duel request from: %s"]
	K.Print(confirmationColor .. format(MSG_PET, name) .. colorReset)

	if K.isDeveloper then
		local dt = debugprofilestop() - t0
		K.Print(format("[KKUI_DEV] %s handled in %.3f ms", "PET_BATTLE_PVP_DUEL_REQUESTED", dt))
	end
end

-- Register or unregister events for auto-declining duels
function Module:CreateAutoDeclineDuels()
	local automationConfig = C["Automation"]

	-- Handle regular PvP duels
	local declineDuels = automationConfig and automationConfig.AutoDeclineDuels
	if declineDuels then
		K:RegisterEvent("DUEL_REQUESTED", self.DUEL_REQUESTED)
	else
		K:UnregisterEvent("DUEL_REQUESTED", self.DUEL_REQUESTED)
	end

	-- Handle pet battle duels separately
	local declinePetDuels = automationConfig and automationConfig.AutoDeclinePetDuels
	if declinePetDuels then
		K:RegisterEvent("PET_BATTLE_PVP_DUEL_REQUESTED", self.PET_BATTLE_PVP_DUEL_REQUESTED)
	else
		K:UnregisterEvent("PET_BATTLE_PVP_DUEL_REQUESTED", self.PET_BATTLE_PVP_DUEL_REQUESTED)
	end
end
