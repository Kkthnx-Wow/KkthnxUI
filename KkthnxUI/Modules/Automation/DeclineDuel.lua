local K, C, L = select(2, ...):unpack()
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
		RaidNotice_AddMessage(RaidWarningFrame, L.Info.Duel.."|cffffff00"..name..".", {r = 0.22, g = 0.62, b = 0.91}, 3)
		K.Print(format("|cff3c9bed"..L.Info.Duel.."|cffffff00"..name.."."))
		StaticPopup_Hide("DUEL_REQUESTED")
	elseif event == "PET_BATTLE_PVP_DUEL_REQUESTED" then
		C_PetBattles.CancelPVPDuel()
		RaidNotice_AddMessage(RaidWarningFrame, L.Info.PetDuel.."|cffffff00"..name..".", {r = 0.22, g = 0.62, b = 0.91}, 3)
		K.Print(format("|cffffff00"..L.Info.PetDuel..name.."."))
		StaticPopup_Hide("PET_BATTLE_PVP_DUEL_REQUESTED")
	end
end)

SlashCmdList.DISABLEDECLINE = function()
	if not Disable then
		Disable = true
		K.Print("|cffffff00Dueling is now|r |cFF008000enabled|r")
	else
		Disable = false
		K.Print("|cffffff00Dueling is now|r |cFFFF0000disabled|r")
	end
end

SLASH_DISABLEDECLINE1 = "/disduel"