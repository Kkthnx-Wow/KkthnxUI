local K, C, L, _ = select(2, ...):unpack()
if C.Announcements.Interrupt ~= true then return end

local format = string.format
local CreateFrame = CreateFrame
local SendChatMessage = SendChatMessage

-- Announce your interrupts
local frame = CreateFrame("Frame")
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
frame:SetScript("OnEvent", function(self, _, _, event, _, sourceName, _, _, destName, _, _, _, _, spellID, spellName)
	if not (event == "SPELL_INTERRUPT" and sourceName == K.Name) then return end

	SendChatMessage(format(L_ANNOUNCE_INTERRUPTED, destName, spellID, spellName), K.CheckChat())
end)