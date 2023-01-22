local K, C, L = unpack(KkthnxUI)
local Module = K:GetModule("Announcements")

local _G = _G

local CombatLogGetCurrentEventInfo = _G.CombatLogGetCurrentEventInfo
local SendChatMessage = _G.SendChatMessage
local UNKNOWN = _G.UNKNOWN

-- SetupSaySapped() checks for when Sap is applied or refreshed on the player, and then sends a chat message and prints a message in the chat window.
local function SetupSaySapped()
	-- Get combat log info for the current event.
	local _, event, _, _, sourceName, _, _, _, destName, spellID = CombatLogGetCurrentEventInfo()

	-- If the spellID is Sap (6770), the destination name is the player's name and the event type is either "SPELL_AURA_APPLIED" or "SPELL_AURA_REFRESH", then execute this code.
	if (spellID == 6770) and (destName == K.Name) and (event == "SPELL_AURA_APPLIED" or event == "SPELL_AURA_REFRESH") then
		-- Send a chat message saying "Sapped".
		SendChatMessage(L["Sapped"], "SAY")

		-- Print a message in the chat window saying "<Player Name> sapped you!" where <Player Name> is either the source name or UNKNOWN if it can't be determined.
		K.Print(L["SappedBy"] .. (sourceName or UNKNOWN))
	end
end

function Module:CreateSaySappedAnnounce()
	if not C["Announcements"].SaySapped then
		K:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED", SetupSaySapped)
	else
		K:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", SetupSaySapped)
	end
end
