local K, C, _ = select(2, ...):unpack()
if C.Announcements.SaySapped ~= true then return end

local SaySapped = CreateFrame("Frame")
SaySapped:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
SaySapped:SetScript("OnEvent", function(self, _, ...) 
	local _, event, _, sourceName, _, _, destName, _, spellID = ...
	if ((spellID == 51724 or spellID == 11297 or spellID == 2070 or spellID == 6770)
	and (destName == K.Name) and (event == "SPELL_AURA_APPLIED" or event == "SPELL_AURA_REFRESH"))
	then
		SendChatMessage(L_ANNOUNCE_SAPPED, "SAY")
		K.Print(L_ANNOUNCE_SAPPED_BY..(sourceName or "(unknown)"))
	end
end)