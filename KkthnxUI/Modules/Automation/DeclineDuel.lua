local K, C, L, _ = select(2, ...):unpack()
if C.Automation.DeclineDuel ~= true then return end

-- LUA API
local format = string.format

-- WOW API
local CreateFrame = CreateFrame
local SendChatMessage = SendChatMessage

-- AUTO DECLINE DUEL
local Disable = false
local DeclineDuel = CreateFrame("Frame")
DeclineDuel:RegisterEvent("DUEL_REQUESTED")
DeclineDuel:RegisterEvent("PET_BATTLE_PVP_DUEL_REQUESTED")
DeclineDuel:SetScript("OnEvent", function(self, event, name)
	if Disable == true then return end
	if event == "DUEL_REQUESTED" then
		CancelDuel()
		RaidNotice_AddMessage(RaidWarningFrame, L_INFO_DUEL.."|cffffd100"..name..".", {r = 0.22, g = 0.62, b = 0.91}, 3)
		K.Print(format("|cff4285f4"..L_INFO_DUEL.."|cffffd100"..name.."."))
		StaticPopup_Hide("DUEL_REQUESTED")
	elseif event == "PET_BATTLE_PVP_DUEL_REQUESTED" then
		C_PetBattles.CancelPVPDuel()
		RaidNotice_AddMessage(RaidWarningFrame, L_INFO_PET_DUEL.."|cffffd100"..name..".", {r = 0.22, g = 0.62, b = 0.91}, 3)
		K.Print(format("|cffffff00"..L_INFO_PET_DUEL..name.."."))
		StaticPopup_Hide("PET_BATTLE_PVP_DUEL_REQUESTED")
	end
end)

SlashCmdList.DISABLEDECLINE = function()
	if not Disable then
		Disable = true
		K.Print("|cffffd100Dueling is now|r |cFF008000enabled|r")
	else
		Disable = false
		K.Print("|cffffd100Dueling is now|r |cFFFF0000disabled|r")
	end
end

SLASH_DISABLEDECLINE1 = "/disduel"