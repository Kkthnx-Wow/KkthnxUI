local K, C, L = unpack(select(2, ...))
local Module = K:GetModule("Announcements")

local _G = _G

local CombatLogGetCurrentEventInfo = _G.CombatLogGetCurrentEventInfo
local SendChatMessage = _G.SendChatMessage
local UNKNOWN = _G.UNKNOWN

function Module:SetupSaySapped()
	local _, event, _, _, sourceName, _, _, _, destName, _, _, spellID = CombatLogGetCurrentEventInfo()

	if ((spellID == 6770) and (destName == K.Name) and (event == "SPELL_AURA_APPLIED" or event == "SPELL_AURA_REFRESH")) then
		SendChatMessage(L["Sapped"], "SAY")
		K.Print(L["SappedBy"]..(sourceName or UNKNOWN))
	end
end

function Module:CreateSaySappedAnnounce()
	if C["Announcements"].SaySapped then
		K:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", Module.SetupSaySapped)
	else
		K:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED", Module.SetupSaySapped)
	end
end