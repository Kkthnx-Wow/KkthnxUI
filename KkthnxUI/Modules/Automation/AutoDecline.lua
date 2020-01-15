local K, C = unpack(select(2, ...))
local Module = K:GetModule("Automation")

local _G = _G
local string_format = _G.string.format

local C_PetBattles_CancelPVPDuel = _G.C_PetBattles.CancelPVPDuel
local CancelDuel = _G.CancelDuel
local StaticPopup_Hide = _G.StaticPopup_Hide
local RaidNotice_AddMessage = _G.RaidNotice_AddMessage

local function SetupAutoDeclineDuels(_, event, name)
	-- Block duel requests
	if event == "DUEL_REQUESTED" and C["Automation"].AutoDeclineDuels then
		CancelDuel()
		RaidNotice_AddMessage(_G.RaidWarningFrame, "Declined duel request from "..name, {r = 0.41, g = 0.8, b = 0.94}, 3)
		K.Print(string_format(K.InfoColor.."Declined duel request from "..name.."."))
		StaticPopup_Hide("DUEL_REQUESTED")
		-- Block pet battle duel requests
	elseif event == "PET_BATTLE_PVP_DUEL_REQUESTED" and C["Automation"].AutoDeclinePetDuels then
		RaidNotice_AddMessage(_G.RaidWarningFrame, "Declined pet duel request from "..name, {r = 0.41, g = 0.8, b = 0.94}, 3)
		K.Print(string_format(K.InfoColor.."Declined pet duel request from "..name.."."))
		C_PetBattles_CancelPVPDuel()
	end
end

function Module:CreateAutoDeclineDuels()
	K:RegisterEvent("DUEL_REQUESTED", SetupAutoDeclineDuels)
	K:RegisterEvent("PET_BATTLE_PVP_DUEL_REQUESTED", SetupAutoDeclineDuels)
end