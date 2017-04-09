local K, C, L = unpack(select(2, ...))
if C.Announcements.Interrupt ~= true then return end

-- Lua Wow
local _G = _G
local string_format = string.format

-- Wow API
local UnitGUID = _G.UnitGUID
local SendChatMessage = _G.SendChatMessage
local IsInGroup = _G.IsInGroup

-- Interrupt announcement
local Interrupts = CreateFrame("Frame")
Interrupts:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
Interrupts:SetScript("OnEvent", function(self, _, ...)
	local inGroup = IsInGroup()
	local _, event, _, sourceGUID, _, _, _, _, destName, _, _, _, _, _, spellID, spellName = ...
	if not (event == "SPELL_INTERRUPT" and (sourceGUID == UnitGUID("player") or sourceGUID == UnitGUID("pet"))) then return end

	if not inGroup then
		SendChatMessage(string_format(L.Announce.Interrupted, destName, spellID, spellName), "EMOTE")
	else
		SendChatMessage(string_format(L.Announce.Interrupted, destName, spellID, spellName), K.CheckChat())
	end
end)