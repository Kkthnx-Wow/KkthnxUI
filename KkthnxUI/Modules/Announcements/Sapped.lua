local K, C, L = unpack(select(2, ...))
if C["Announcements"].SaySapped ~= true then return end

local _G = _G

-- Wow API
local SendChatMessage = _G.SendChatMessage

local SaySapped = CreateFrame("Frame")
SaySapped:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
SaySapped:SetScript("OnEvent", function()
	local _, event, _, _, sourceName, _, _, _, destName, _, _, spellID = CombatLogGetCurrentEventInfo()
	if ((spellID == 6770) and (destName == K.Name) and (event == "SPELL_AURA_APPLIED" or event == "SPELL_AURA_REFRESH")) then
		SendChatMessage(L["Announcements"].Sapped, "SAY")
		K.Print(L["Announcements"].Sapped_By..(sourceName or "(unknown)"))
	end
end)