--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Automatically declines duel and pet battle pvp requests.
-- - Design: Hooks DUEL_REQUESTED and PET_BATTLE_PVP_DUEL_REQUESTED events to cancel requests instantly.
-- - Events: DUEL_REQUESTED, PET_BATTLE_PVP_DUEL_REQUESTED
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Automation")

-- PERF: Localize frequently used globals/functions for performance (Lua 5.1)
local C_PetBattles_CancelPVPDuel = C_PetBattles and C_PetBattles.CancelPVPDuel
local CancelDuel = CancelDuel
local StaticPopup_Hide = StaticPopup_Hide
local string_format = string.format

-- ---------------------------------------------------------------------------
-- Constants
-- ---------------------------------------------------------------------------
local CONFIRMATION_COLOR = "|cff00ff00"
local COLOR_RESET = "|r"
local UNKNOWN_NAME = _G.UNKNOWN or "Unknown"

-- ---------------------------------------------------------------------------
-- Internal Logic
-- ---------------------------------------------------------------------------
function Module:duelRequested(name)
	-- REASON: Instantly cancels the duel request and hides the associated blizzard popup.
	CancelDuel()
	StaticPopup_Hide("DUEL_REQUESTED")

	name = name or UNKNOWN_NAME
	local msgDuel = L["Declined a duel request from: %s"]
	K.Print(CONFIRMATION_COLOR .. string_format(msgDuel, name) .. COLOR_RESET)
end

function Module:petBattleDuelRequested(name)
	-- REASON: Instantly cancels the pet battle pvp duel request and hides the associated blizzard popup.
	if C_PetBattles_CancelPVPDuel then
		C_PetBattles_CancelPVPDuel()
	end
	StaticPopup_Hide("PET_BATTLE_PVP_DUEL_REQUESTED")

	name = name or UNKNOWN_NAME
	local msgPet = L["Declined a pet battle PVP duel request from: %s"]
	K.Print(CONFIRMATION_COLOR .. string_format(msgPet, name) .. COLOR_RESET)
end

-- ---------------------------------------------------------------------------
-- Module Registration
-- ---------------------------------------------------------------------------
function Module:CreateAutoDeclineDuels()
	-- REASON: Entry point to enable/disable auto-decline features for duels and pet battles.
	local automationConfig = C["Automation"]
	if not automationConfig then
		return
	end

	if automationConfig.AutoDeclineDuels then
		K:RegisterEvent("DUEL_REQUESTED", self.duelRequested)
	else
		K:UnregisterEvent("DUEL_REQUESTED", self.duelRequested)
	end

	if automationConfig.AutoDeclinePetDuels then
		K:RegisterEvent("PET_BATTLE_PVP_DUEL_REQUESTED", self.petBattleDuelRequested)
	else
		K:UnregisterEvent("PET_BATTLE_PVP_DUEL_REQUESTED", self.petBattleDuelRequested)
	end
end
