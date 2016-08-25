local K, C, L, _ = select(2, ...):unpack()

-- LUA API
local format = string.format
local gsub = string.gsub

-- WOW API
local GetSpellLink = GetSpellLink
local SendChatMessage = SendChatMessage
local InCombatLockdown = InCombatLockdown
local UnitInParty, UnitInRaid = UnitInParty, UnitInRaid

-- ANNOUNCE FEASTS/SOULS/REPAIR BOTS/PORTALS/RITUAL OF SUMMONING
-- IT'S BETTER TO USE (self, event, ...) IN THE FUNCTION, THAN PUT local _, subEvent, blabla = ... LATER, THEN IT'S EASIER TO GET THE RIGHT ARGUMENTS FOR EACH GAME CLIENT
local frame = CreateFrame("Frame")
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
frame:SetScript("OnEvent", function(self, _, ...)
	local _, subEvent, _, _, srcName, _, _, _, destName, _, _, spellID = ...
	if not IsInGroup() or InCombatLockdown() or not subEvent or not spellID or not srcName then return end
	if not UnitInRaid(srcName) and not UnitInParty(srcName) then return end

	local srcName = srcName:gsub("%-[^|]+", "")
	if subEvent == "SPELL_CAST_SUCCESS" then
		-- FEASTS
		if C.Announcements.Feasts and (spellID == 126492 or spellID == 126494) then
			SendChatMessage(format(L_ANNOUNCE_FP_STAT, srcName, GetSpellLink(spellID), SPELL_STAT1_NAME), K.CheckChat(true))
		elseif C.Announcements.Feasts and (spellID == 126495 or spellID == 126496) then
			SendChatMessage(format(L_ANNOUNCE_FP_STAT, srcName, GetSpellLink(spellID), SPELL_STAT2_NAME), K.CheckChat(true))
		elseif C.Announcements.Feasts and (spellID == 126501 or spellID == 126502) then
			SendChatMessage(format(L_ANNOUNCE_FP_STAT, srcName, GetSpellLink(spellID), SPELL_STAT3_NAME), K.CheckChat(true))
		elseif C.Announcements.Feasts and (spellID == 126497 or spellID == 126498) then
			SendChatMessage(format(L_ANNOUNCE_FP_STAT, srcName, GetSpellLink(spellID), SPELL_STAT4_NAME), K.CheckChat(true))
		elseif C.Announcements.Feasts and (spellID == 126499 or spellID == 126500) then
			SendChatMessage(format(L_ANNOUNCE_FP_STAT, srcName, GetSpellLink(spellID), SPELL_STAT5_NAME), K.CheckChat(true))
		elseif C.Announcements.Feasts and (spellID == 104958 or spellID == 105193 or spellID == 126503 or spellID == 126504 or spellID == 145166 or spellID == 145169 or spellID == 145196) then
			SendChatMessage(format(L_ANNOUNCE_FP_PRE, srcName, GetSpellLink(spellID)), K.CheckChat(true))
			-- REFRESHMENT TABLE
		elseif C.Announcements.Feasts and spellID == 43987 then
			SendChatMessage(format(L_ANNOUNCE_FP_PRE, srcName, GetSpellLink(spellID)), K.CheckChat(true))
			-- RITUAL OF SUMMONING
		elseif C.Announcements.Portals and spellID == 698 then
			SendChatMessage(format(L_ANNOUNCE_FP_CLICK, srcName, GetSpellLink(spellID)), K.CheckChat(true))
			-- PICCOLO OF THE FLAMING FIRE
		elseif C.Announcements.Toys and spellID == 18400 then
			SendChatMessage(format(L_ANNOUNCE_FP_USE, srcName, GetSpellLink(spellID)), K.CheckChat(true))
		end
	elseif subEvent == "SPELL_SUMMON" then
		-- REPAIR BOTS
		if C.Announcements.Feasts and K.AnnounceBots[spellID] then
			SendChatMessage(format(L_ANNOUNCE_FP_PUT, srcName, GetSpellLink(spellID)), K.CheckChat(true))
		end
	elseif subEvent == "SPELL_CREATE" then
		-- RITUAL OF SOULS AND MOLL-E
		if C.Announcements.Feasts and (spellID == 29893 or spellID == 54710) then
			SendChatMessage(format(L_ANNOUNCE_FP_PUT, srcName, GetSpellLink(spellID)), K.CheckChat(true))
			-- TOYS
		elseif C.Announcements.Toys and K.AnnounceToys[spellID] then
			SendChatMessage(format(L_ANNOUNCE_FP_PUT, srcName, GetSpellLink(spellID)), K.CheckChat(true))
			-- PORTALS
		elseif C.Announcements.Portals and K.AnnouncePortals[spellID] then
			SendChatMessage(format(L_ANNOUNCE_FP_CAST, srcName, GetSpellLink(spellID)), K.CheckChat(true))
		end
	elseif subEvent == "SPELL_AURA_APPLIED" then
		-- TURKEY FEATHERS AND PARTY G.R.E.N.A.D.E.
		if C.Announcements.Toys and (spellID == 61781 or ((spellID == 51508 or spellID == 51510) and destName == K.Name)) then
			SendChatMessage(format(L_ANNOUNCE_FP_USE, srcName, GetSpellLink(spellID)), K.CheckChat(true))
		end
	end
end)