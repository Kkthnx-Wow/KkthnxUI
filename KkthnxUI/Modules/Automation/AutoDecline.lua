local K, _, L = unpack(select(2, ...))
local Module = K:GetModule("Automation")

-- Auto decline duels

local _G = _G
local string_format = string.format

local C_PetBattles_CancelPVPDuel = _G.C_PetBattles.CancelPVPDuel
local CancelDuel = _G.CancelDuel
local StaticPopup_Hide = _G.StaticPopup_Hide
local RaidNotice_AddMessage = _G.RaidNotice_AddMessage

local isDisabled = false
local function SetupAutoDeclineDuels(_, event, name)
	if isDisabled == true then
		return
	end

	if event == "DUEL_REQUESTED" then
		CancelDuel()
		RaidNotice_AddMessage(RaidWarningFrame, L["DuelCanceled"]..name, {r = 0.41, g = 0.8, b = 0.94}, 3)
		K.Print(string_format("|cffffff00"..L["DuelCanceled"]..name.."."))
		StaticPopup_Hide("DUEL_REQUESTED")
	elseif event == "PET_BATTLE_PVP_DUEL_REQUESTED" then
		C_PetBattles_CancelPVPDuel()
		RaidNotice_AddMessage(RaidWarningFrame, L["DuelCanceledPet"]..name, {r = 0.41, g = 0.8, b = 0.94}, 3)
		K.Print(string_format("|cffffff00"..L["DuelCanceledPet"]..name.."."))
		StaticPopup_Hide("PET_BATTLE_PVP_DUEL_REQUESTED")
	end
end

function Module:CreateAutoDeclineDuels()
	K:RegisterEvent("DUEL_REQUESTED", SetupAutoDeclineDuels)
	K:RegisterEvent("PET_BATTLE_PVP_DUEL_REQUESTED", SetupAutoDeclineDuels)

	SlashCmdList.DISABLEAUTODECLINE = function()
		if not isDisabled then
			isDisabled = true
			K.Print("Auto Decline Duels is DISABLED")
		else
			isDisabled = false
			K.Print("Auto Decline Duels is ENABLED")
		end
	end

	SLASH_DISABLEAUTODECLINE1 = "/disduel"
	SLASH_DISABLEAUTODECLINE2 = "/kkduel"
end