--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Automatically announces when the player is Sapped in PvP.
-- - Design: Monitors COMBAT_LOG_EVENT_UNFILTERED for the Sap spell ID (6770).
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Announcements")

-- ---------------------------------------------------------------------------
-- LOCALS & CACHING
-- ---------------------------------------------------------------------------

-- PERF: Cache frequent CLEU and chat globals.
local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo
local SendChatMessage = SendChatMessage
local UNKNOWN = UNKNOWN

-- ---------------------------------------------------------------------------
-- EVENT LOGIC
-- ---------------------------------------------------------------------------

-- REASON: Detects Sap application or refreshes on the player.
local function HandleSapEvent()
	local _, eventType, _, _, sourceName, _, _, _, destName, spellID = CombatLogGetCurrentEventInfo()

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
