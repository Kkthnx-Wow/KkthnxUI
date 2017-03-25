local K, C, L = unpack(select(2, ...))
if C.Automation.DeclineDuel ~= true then return end

-- Lua API
local _G = _G
local print = print
local string_format = string.format

-- Wow API
local C_PetBattles_CancelPVPDuel = _G.C_PetBattles.CancelPVPDuel
local CALENDAR_STATUS_ACCEPTED = _G.CALENDAR_STATUS_ACCEPTED
local CALENDAR_STATUS_DECLINED = _G.CALENDAR_STATUS_DECLINED
local CancelDuel = _G.CancelDuel
local CreateFrame = _G.CreateFrame
local DUEL = _G.DUEL
local StaticPopup_Hide = _G.StaticPopup_Hide

local disableDuels = false

-- Auto decline duels
local DeclineDuel = CreateFrame("Frame")
DeclineDuel:RegisterEvent("DUEL_REQUESTED")
DeclineDuel:RegisterEvent("PET_BATTLE_PVP_DUEL_REQUESTED")
DeclineDuel:SetScript("OnEvent", function(self, event, name)
	if disableDuels == true then return end
	if event == "DUEL_REQUESTED" then
		CancelDuel()
		print(string_format("|cff3c9bed"..L.Info.Duel.."|cffffff00"..name.."."))
		StaticPopup_Hide("DUEL_REQUESTED")
	elseif event == "PET_BATTLE_PVP_DUEL_REQUESTED" then
		C_PetBattles_CancelPVPDuel()
		print(string_format("|cffffff00"..L.Info.PetDuel..name.."."))
		StaticPopup_Hide("PET_BATTLE_PVP_DUEL_REQUESTED")
	end
end)

SlashCmdList.DISABLEDECLINE = function()
	if not disableDuels then
		disableDuels = true
		print(DUEL.."s "..CALENDAR_STATUS_ACCEPTED) -- Start using global strings that exsit in wow to prevent having to local them.
	else
		disableDuels = false
		print(DUEL.."s "..CALENDAR_STATUS_DECLINED) -- Start using global strings that exsit in wow to prevent having to local them.
	end
end

_G.SLASH_DISABLEDECLINE1 = "/disduel"