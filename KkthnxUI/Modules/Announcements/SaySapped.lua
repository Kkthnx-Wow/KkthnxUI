local K, C, L = unpack(select(2, ...))
if C.Announcements.SaySapped ~= true then return end

-- Wow API
local SendChatMessage = SendChatMessage

local SaySapped = CreateFrame("Frame")

SaySapped:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
SaySapped:SetScript("OnEvent", function(self, _, ...)
	local _, event, _, _, sourceName, _, _,	_, destName, _, _, spellID = ...
	if ((spellID == 6770)
	and (destName == K.Name) and (event == "SPELL_AURA_APPLIED" or event == "SPELL_AURA_REFRESH"))
	then
		SendChatMessage(L.Announce.Sapped, "SAY")
		K.Print(L.Announce.SappedBy..(sourceName or "(unknown)"))
	end
end)