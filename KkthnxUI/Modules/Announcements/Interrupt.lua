local K, C, L = select(2, ...):unpack()
if C.Announcements.Interrupt ~= true then return end

local format = string.format
local SendChatMessage = SendChatMessage

-- ANNOUNCE YOUR INTERRUPTS
local Interrupts = CreateFrame("Frame")
Interrupts:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
Interrupts:SetScript("OnEvent", function(self, _, ...)
	local _, event, _, sourceGUID, _, _, _, _, destName, _, _, _, _, _, spellID, spellName = ...
	if not (event == "SPELL_INTERRUPT" and (sourceGUID == UnitGUID("player") or sourceGUID == UnitGUID("pet"))) then return end

	SendChatMessage(format(L.Announce.Interrupted, destName, spellID, spellName), K.CheckChat())
end)