local K, C, L, _ = select(2, ...):unpack()

-- Announce Feasts/Souls/Repair Bots/Portals/Ritual of Summoning
-- It's better to use (self, event, ...) in the function, than put local _, subEvent, blabla = ... later, then it's easier to get the right arguments for each game client
local frame = CreateFrame("Frame")
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
frame:SetScript("OnEvent", function(self, _, ...)
	local _, subEvent, _, _, srcName, _, _, _, destName, _, _, spellID = ...
	if not IsInGroup() or InCombatLockdown() or not subEvent or not spellID or not srcName then return end
	if not UnitInRaid(srcName) and not UnitInParty(srcName) then return end

	local srcName = srcName:gsub("%-[^|]+", "")
	if subEvent == "SPELL_CAST_SUCCESS" then
		-- Feasts
		if C.Announcements.Feasts and (spellID == 126492 or spellID == 126494) then
			SendChatMessage(string.format(L_ANNOUNCE_FP_STAT, srcName, GetSpellLink(spellID), SPELL_STAT1_NAME), K.CheckChat(true))
		elseif C.Announcements.Feasts and (spellID == 126495 or spellID == 126496) then
			SendChatMessage(string.format(L_ANNOUNCE_FP_STAT, srcName, GetSpellLink(spellID), SPELL_STAT2_NAME), K.CheckChat(true))
		elseif C.Announcements.Feasts and (spellID == 126501 or spellID == 126502) then
			SendChatMessage(string.format(L_ANNOUNCE_FP_STAT, srcName, GetSpellLink(spellID), SPELL_STAT3_NAME), K.CheckChat(true))
		elseif C.Announcements.Feasts and (spellID == 126497 or spellID == 126498) then
			SendChatMessage(string.format(L_ANNOUNCE_FP_STAT, srcName, GetSpellLink(spellID), SPELL_STAT4_NAME), K.CheckChat(true))
		elseif C.Announcements.Feasts and (spellID == 126499 or spellID == 126500) then
			SendChatMessage(string.format(L_ANNOUNCE_FP_STAT, srcName, GetSpellLink(spellID), SPELL_STAT5_NAME), K.CheckChat(true))
		elseif C.Announcements.Feasts and (spellID == 104958 or spellID == 105193 or spellID == 126503 or spellID == 126504 or spellID == 145166 or spellID == 145169 or spellID == 145196) then
			SendChatMessage(string.format(L_ANNOUNCE_FP_PRE, srcName, GetSpellLink(spellID)), K.CheckChat(true))
		-- Refreshment Table
		elseif C.Announcements.Feasts and spellID == 43987 then
			SendChatMessage(string.format(L_ANNOUNCE_FP_PRE, srcName, GetSpellLink(spellID)), K.CheckChat(true))
		-- Ritual of Summoning
		elseif C.Announcements.Portals and spellID == 698 then
			SendChatMessage(string.format(L_ANNOUNCE_FP_CLICK, srcName, GetSpellLink(spellID)), K.CheckChat(true))
		-- Piccolo of the Flaming Fire
		elseif C.Announcements.Toys and spellID == 18400 then
			SendChatMessage(string.format(L_ANNOUNCE_FP_USE, srcName, GetSpellLink(spellID)), K.CheckChat(true))
		end
	elseif subEvent == "SPELL_SUMMON" then
		-- Repair Bots
		if C.Announcements.Feasts and K.AnnounceBots[spellID] then
			SendChatMessage(string.format(L_ANNOUNCE_FP_PUT, srcName, GetSpellLink(spellID)), K.CheckChat(true))
		end
	elseif subEvent == "SPELL_CREATE" then
		-- Ritual of Souls and MOLL-E
		if C.Announcements.Feasts and (spellID == 29893 or spellID == 54710) then
			SendChatMessage(string.format(L_ANNOUNCE_FP_PUT, srcName, GetSpellLink(spellID)), K.CheckChat(true))
		-- Toys
		elseif C.Announcements.Toys and K.AnnounceToys[spellID] then
			SendChatMessage(string.format(L_ANNOUNCE_FP_PUT, srcName, GetSpellLink(spellID)), K.CheckChat(true))
		-- Portals
		elseif C.Announcements.Portals and K.AnnouncePortals[spellID] then
			SendChatMessage(string.format(L_ANNOUNCE_FP_CAST, srcName, GetSpellLink(spellID)), K.CheckChat(true))
		end
	elseif subEvent == "SPELL_AURA_APPLIED" then
		-- Turkey Feathers and Party G.R.E.N.A.D.E.
		if C.Announcements.Toys and (spellID == 61781 or ((spellID == 51508 or spellID == 51510) and destName == K.Name)) then
			SendChatMessage(string.format(L_ANNOUNCE_FP_USE, srcName, GetSpellLink(spellID)), K.CheckChat(true))
		end
	end
end)