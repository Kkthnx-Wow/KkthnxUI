--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Automatically accepts Delve Companion power selections when entering Delves.
-- - Design: Monitors PLAYER_CHOICE_UPDATE events when player is in a Delve instance.
-- - Events: PLAYER_CHOICE_UPDATE, PLAYER_ENTERING_WORLD
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Automation")

-- PERF: Localize globals for performance
local _G = _G
local C_PartyInfo_IsPartyWalkIn = C_PartyInfo.IsPartyWalkIn
local C_PlayerChoice_GetCurrentPlayerChoiceInfo = C_PlayerChoice.GetCurrentPlayerChoiceInfo
local C_PlayerChoice_OnUIClosed = C_PlayerChoice.OnUIClosed
local C_PlayerChoice_SendPlayerChoiceResponse = C_PlayerChoice.SendPlayerChoiceResponse
local C_Timer_After = C_Timer.After
local string_format = string.format

-- ---------------------------------------------------------------------------
-- Utility Logic
-- ---------------------------------------------------------------------------
local function isInDelves()
	-- REASON: C_PartyInfo.IsPartyWalkIn() is more reliable than scenario name checking
	-- as it works correctly even when relogging inside a Delve.
	return C_PartyInfo_IsPartyWalkIn and C_PartyInfo_IsPartyWalkIn()
end

-- ---------------------------------------------------------------------------
-- Internal Logic
-- ---------------------------------------------------------------------------
local function handlePlayerChoice()
	-- REASON: Double-check we're still in a Delve before auto-accepting
	-- to prevent accepting non-Delve player choices
	if not isInDelves() then
		return
	end

	local choiceInfo = C_PlayerChoice_GetCurrentPlayerChoiceInfo()
	if not choiceInfo then
		return
	end

	-- REASON: Only auto-accept when there's exactly one option with one button (single choice)
	if choiceInfo.options and #choiceInfo.options == 1 then
		local optionInfo = choiceInfo.options[1]
		if not (optionInfo.buttons and #optionInfo.buttons == 1 and optionInfo.spellID) then
			return
		end

		local header = optionInfo.header
		local spellID = optionInfo.spellID
		local responseID = optionInfo.buttons[1].id
		-- REASON: Enum.PlayerChoiceRarity is ItemQuality - 1, so we add 1 to get proper quality
		local quality = (optionInfo.rarity or 0) + 1

		-- Accept the choice
		C_PlayerChoice_SendPlayerChoiceResponse(responseID)
		C_PlayerChoice_OnUIClosed()

		-- Print confirmation message
		local spellLink = string_format("|Hspell:%d:0|h[%s]|h", spellID, header)
		local coloredText = _G.ColorManager.GetFormattedStringForItemQuality(spellLink, quality)
		K.Print(string_format("%s %s", L["Auto Selected"], coloredText))
	end
end

local function updateDelvesState()
	-- REASON: Register/unregister event based on whether we're in a Delve
	if isInDelves() then
		K:RegisterEvent("PLAYER_CHOICE_UPDATE", handlePlayerChoice)
	else
		K:UnregisterEvent("PLAYER_CHOICE_UPDATE", handlePlayerChoice)
	end
end

-- ---------------------------------------------------------------------------
-- Module Registration
-- ---------------------------------------------------------------------------
function Module:CreateAutoDelves()
	-- REASON: Respect user configuration
	if not C["Automation"].AutoDelves then
		return
	end

	-- REASON: Monitor zone changes to detect entering/leaving Delves
	-- PLAYER_ENTERING_WORLD fires on login, UI reload, and zone transitions
	K:RegisterEvent("PLAYER_ENTERING_WORLD", function()
		-- REASON: Small delay to ensure all zone data is loaded
		C_Timer_After(0.5, updateDelvesState)
	end)

	-- REASON: Initial check on module load (handles /reload or login inside a Delve)
	C_Timer_After(1, updateDelvesState)
end
