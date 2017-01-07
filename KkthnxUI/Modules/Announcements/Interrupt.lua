local K, C, L = unpack(select(2, ...))
if C.Announcements.Interrupt ~= true then return end

-- Lua Wow
local _G = _G
local pairs = pairs
local format = string.format

-- Wow API
local UnitGUID = UnitGUID
local SendChatMessage = SendChatMessage
local IsInGroup = IsInGroup

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: SLASH_ERROR1

-- Interrupt announcement
local Interrupts = CreateFrame("Frame")
Interrupts:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
Interrupts:SetScript("OnEvent", function(self, _, ...)
	local inGroup = IsInGroup()
	local _, event, _, sourceGUID, _, _, _, _, destName, _, _, _, _, _, spellID, spellName = ...
	if not (event == "SPELL_INTERRUPT" and (sourceGUID == UnitGUID("player") or sourceGUID == UnitGUID("pet"))) then return end

	if not inGroup then
		SendChatMessage(format(L.Announce.Interrupted, destName, spellID, spellName), "EMOTE")
	else
		SendChatMessage(format(L.Announce.Interrupted, destName, spellID, spellName), K.CheckChat())
	end
end)