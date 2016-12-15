local K, C, L = unpack(select(2, ...))
if C.Announcements.Spells ~= true then return end

-- Lua API
local format = string.format
local gsub = string.gsub
local pairs = pairs

-- Wow API
local CreateFrame = CreateFrame
local GetInstanceInfo = GetInstanceInfo
local GetSpellLink = GetSpellLink
local SendChatMessage = SendChatMessage
local UnitGUID = UnitGUID

-- Announce some spells
local AnnounceSpells = CreateFrame("Frame")
AnnounceSpells:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
AnnounceSpells:SetScript("OnEvent", function(self, _, ...)
	local _, event, _, sourceGUID, sourceName, _, _, _, destName, _, _, spellID = ...
	local spells = K.AnnounceSpells
	local _, _, difficultyID = GetInstanceInfo()
	if difficultyID == 0 or event ~= "SPELL_CAST_SUCCESS" then return end

	if sourceName then sourceName = sourceName:gsub("%-[^|]+", "") end
	if destName then destName = destName:gsub("%-[^|]+", "") end
	if C.Announcements.SpellsFromAll == true and not (sourceGUID == UnitGUID("player") and sourceName == K.Name) then
		if not sourceName then return end

		for i, spells in pairs(spells) do
			if spellID == spells then
				if destName == nil then
					SendChatMessage(format(L.Announce.FPUse, sourceName, GetSpellLink(spellID)), K.CheckChat())
				else
					SendChatMessage(format(L.Announce.FPUse, sourceName, GetSpellLink(spellID).." -> "..destName), K.CheckChat())
				end
			end
		end
	else
		if not (sourceGUID == UnitGUID("player") and sourceName == K.Name) then return end

		for i, spells in pairs(spells) do
			if spellID == spells then
				if destName == nil then
					SendChatMessage(format(L.Announce.FPUse, sourceName, GetSpellLink(spellID)), K.CheckChat())
				else
					SendChatMessage(GetSpellLink(spellID).." -> "..destName, K.CheckChat())
				end
			end
		end
	end
end)