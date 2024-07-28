local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Announcements")

-- Cache WoW API functions
local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo
local SendChatMessage = SendChatMessage
local UNKNOWN = UNKNOWN

local function HandleSapEvent()
	local _, eventType, _, _, sourceName, _, _, _, destName, spellID = CombatLogGetCurrentEventInfo()

	if (spellID == 6770) and (destName == K.Name) and (eventType == "SPELL_AURA_APPLIED" or eventType == "SPELL_AURA_REFRESH") then
		SendChatMessage(L["Sapped"], "SAY")
		K.Print(L["SappedBy"] .. (sourceName or UNKNOWN))
	end
end

function Module:ToggleSapAnnounce()
	if C["Announcements"].SaySapped then
		K:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", HandleSapEvent)
	else
		K:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED", HandleSapEvent)
	end
end
