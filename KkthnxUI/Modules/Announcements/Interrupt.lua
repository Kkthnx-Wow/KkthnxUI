local K, C, L, _ = select(2, ...):unpack()
if C.Announcements.Interrupt ~= true then return end

local format = string.format
local CreateFrame = CreateFrame
local SendChatMessage = SendChatMessage

-- Announce your interrupts
local frame = CreateFrame("Frame")
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
frame:SetScript("OnEvent", function(self, _, ...)
	--local _, event, _, sourceGUID, _, _, _, destName, _, _, spellID = ...
	local _, event, _, sourceGUID, _, _, _, _, destName, _, _, _, _, _, spellID = ...
	if not (event == "SPELL_INTERRUPT" and (sourceGUID == UnitGUID("player") or sourceGUID == UnitGUID("pet"))) then return end

	SendChatMessage(L_ANNOUNCE_INTERRUPTED.." "..destName..": "..GetSpellLink(spellID), K.CheckChat())
end)