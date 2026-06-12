--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Automatically announces when the player is Sapped in PvP.
-- - Design: Monitors COMBAT_LOG_EVENT_UNFILTERED for the Sap spell ID (6770).
-- - Events: COMBAT_LOG_EVENT_UNFILTERED
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Announcements")

-- ---------------------------------------------------------------------------
-- LOCALS & CACHING
-- ---------------------------------------------------------------------------

-- PERF: Cache frequent CLEU and chat globals.
local SendChatMessage = SendChatMessage
local UNKNOWN = UNKNOWN

-- ---------------------------------------------------------------------------
-- EVENT LOGIC
-- ---------------------------------------------------------------------------

-- REASON: Detects Sap application or refreshes on the player.
-- FIX: Correct return index miscounting by adding correct placeholders and mapping arguments directly.
-- PERF: Use passed varargs directly to avoid redundant CombatLogGetCurrentEventInfo calls.
local function HandleSapEvent(_, _, eventType, _, _, sourceName, _, _, _, destName, _, _, spellID)
	-- NOTE: spellID 6770 corresponds to Rogue's Sap.
	if spellID == 6770 and destName == K.Name and (eventType == "SPELL_AURA_APPLIED" or eventType == "SPELL_AURA_REFRESH") then
		SendChatMessage(L["Sapped"], "SAY")
		K.Print(L["SappedBy"] .. (sourceName or UNKNOWN))
	end
end

-- ---------------------------------------------------------------------------
-- REGISTRATION
-- ---------------------------------------------------------------------------

-- NOTE: This function is used to toggle the listener based on user configuration.
function Module:ToggleSapAnnounce()
	if C["Announcements"].SaySapped then
		K:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", HandleSapEvent)
	else
		K:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED", HandleSapEvent)
	end
end
