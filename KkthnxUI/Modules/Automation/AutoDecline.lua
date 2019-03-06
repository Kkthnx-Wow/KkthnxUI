local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("DeclineDuel", "AceHook-3.0", "AceEvent-3.0")

local _G = _G
local string_format = string.format

local CancelDuel = _G.CancelDuel
local CancelPetPVPDuel = _G.CancelPetPVPDuel
local StaticPopup_Hide = _G.StaticPopup_Hide

-- Auto decline duels
function Module:DeclineDuels(event, name)
	local cancelled = false
	if event == "DUEL_REQUESTED" and C["Automation"].DeclinePvPDuel then
		CancelDuel()
		StaticPopup_Hide("DUEL_REQUESTED")
		cancelled = "Regular"
	elseif event == "PET_BATTLE_PVP_DUEL_REQUESTED" and C["Automation"].DeclinePetDuel then
		CancelPetPVPDuel()
		StaticPopup_Hide("PET_BATTLE_PVP_DUEL_REQUESTED")
		cancelled = "Pet"
	end

	if cancelled then
		K.Print(string_format(L["Automation"]["DuelCanceled_"..cancelled], "|cff4488ff"..name.."|r"))
	end
end

function Module:OnEnable()
	self:RegisterEvent("DUEL_REQUESTED", "DeclineDuels")
	self:RegisterEvent("PET_BATTLE_PVP_DUEL_REQUESTED", "DeclineDuels")
end

function Module:OnDisable()
	self:UnregisterEvent("DUEL_REQUESTED")
	self:UnregisterEvent("PET_BATTLE_PVP_DUEL_REQUESTED")
end
