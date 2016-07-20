local K, C, L, _ = select(2, ...):unpack()
if C.Automation.DeclineDuel ~= true then return end

local format = string.format
local CreateFrame = CreateFrame
local SendChatMessage = SendChatMessage

-- Auto decline duel
local Disable = false
local DeclineDuel = CreateFrame("Frame")
DeclineDuel:RegisterEvent("DUEL_REQUESTED")
DeclineDuel:SetScript("OnEvent", function(self, event, name)
	if Disable == true then return end
	if event == "DUEL_REQUESTED" then
		CancelDuel()
		RaidNotice_AddMessage(RaidWarningFrame, L_INFO_DUEL.."|cffffe02e"..name..".", {r = 0.22, g = 0.62, b = 0.91}, 3)
		K.Print(format("|cff2eb6ff"..L_INFO_DUEL.."|cffffe02e"..name.."."))
		StaticPopup_Hide("DUEL_REQUESTED")
	end
end)

SlashCmdList.DISABLEDECLINE = function()
	if not Disable then
		Disable = true
		K.Print("|cffffe02eDueling is now|r |cFF008000enabled|r")
	else
		Disable = false
		K.Print("|cffffe02eDueling is now|r |cFFFF0000disabled|r")
	end
end

SLASH_DISABLEDECLINE1 = "/disduel"