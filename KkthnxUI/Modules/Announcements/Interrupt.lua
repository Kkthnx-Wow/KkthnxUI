local K, C, L, _ = select(2, ...):unpack()
if C.Announcements.Interrupt ~= true then return end

local GetSpellLink = GetSpellLink
local CreateFrame = CreateFrame
local SendChatMessage = SendChatMessage

-- ANNOUNCE YOUR INTERRUPTS
local Interrupt = CreateFrame("Frame")
Interrupt:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
Interrupt:SetScript("OnEvent", function(self, _, ...)
	local _, event, _, sourceGUID, _, _, _, _, destName, _, _, spellID = ...
	if not (event == "SPELL_INTERRUPT" and (sourceGUID == UnitGUID("player") or sourceGUID == UnitGUID("pet"))) then return end

	SendChatMessage(L_ANNOUNCE_INTERRUPTED.." "..destName..": "..GetSpellLink(spellID), K.CheckChat())
end)