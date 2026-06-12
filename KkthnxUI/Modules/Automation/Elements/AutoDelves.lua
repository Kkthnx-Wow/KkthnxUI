--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Automatically accepts Delve Companion power selections when inside a Delve.
-- - Design: Monitors PLAYER_CHOICE_UPDATE while inside a Delve (detected via C_PartyInfo.IsDelveInProgress).
-- - Events: PLAYER_CHOICE_UPDATE, PLAYER_ENTERING_WORLD, PLAYER_LEAVING_WORLD
-- WARNING: C_PlayerChoice.SendPlayerChoiceResponse is a protected call; avoid calling from tainted code.
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Automation")

-- PERF: Localize frequently used globals
local C_PartyInfo_IsDelveInProgress = C_PartyInfo.IsDelveInProgress
local C_PlayerChoice_GetCurrentPlayerChoiceInfo = C_PlayerChoice.GetCurrentPlayerChoiceInfo
local C_PlayerChoice_OnUIClosed = C_PlayerChoice.OnUIClosed
local C_PlayerChoice_SendPlayerChoiceResponse = C_PlayerChoice.SendPlayerChoiceResponse
local C_Timer_After = C_Timer.After

-- ---------------------------------------------------------------------------
-- Utility Logic
-- ---------------------------------------------------------------------------

-- REASON: C_PartyInfo.IsDelveInProgress() is the correct Delve-specific API.
-- IsPartyWalkIn() is for walk-in parties in general and does NOT exclusively
-- identify Delves; it would also trigger inside Timewalking parties, etc.
local function isInDelves()
	return C_PartyInfo_IsDelveInProgress and C_PartyInfo_IsDelveInProgress()
end

-- ---------------------------------------------------------------------------
-- Internal Logic
-- ---------------------------------------------------------------------------
local function handlePlayerChoice()
	-- REASON: Double-check we're still in a Delve before auto-accepting
	-- to prevent accepting non-Delve player choices.
	if not isInDelves() then
		return
	end

	local choiceInfo = C_PlayerChoice_GetCurrentPlayerChoiceInfo()
	if not choiceInfo then
		return
	end

	-- REASON: Only auto-accept when there's exactly one option with one button (single choice)
	if not (choiceInfo.options and #choiceInfo.options == 1) then
		return
	end

	local optionInfo = choiceInfo.options[1]
	if not (optionInfo.buttons and #optionInfo.buttons == 1 and optionInfo.spellID) then
		return
	end

	local header = optionInfo.header
	local spellID = optionInfo.spellID
	local responseID = optionInfo.buttons[1].id
	-- REASON: Enum.PlayerChoiceRarity is ItemQuality - 1, so we add 1 to get proper item quality tier.
	local quality = (optionInfo.rarity or 0) + 1

	-- Accept the choice
	C_PlayerChoice_SendPlayerChoiceResponse(responseID)
	C_PlayerChoice_OnUIClosed()

	-- Print confirmation using KkthnxUI's K.Print, applying quality color from the K.QualityColors table.
	-- REASON: Build spellLink with direct concat; no string_format needed for two constant segments.
	local spellLink = "|Hspell:" .. spellID .. ":0|h[" .. header .. "]|h"
	local color = K.QualityColors and K.QualityColors[quality] or K.QualityColors and K.QualityColors[1]
	local coloredText
	if color then
		coloredText = K.RGBToHex(color.r, color.g, color.b) .. spellLink .. "|r"
	else
		coloredText = spellLink
	end
	K.Print(L["Auto Selected"] .. " " .. coloredText)
end

local function updateDelvesState()
	-- REASON: Register/unregister based on whether we're currently inside a Delve.
	-- Avoids keeping PLAYER_CHOICE_UPDATE active outside of Delves (e.g. in group content).
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
	-- REASON: Respect user configuration before registering any events.
	if not C["Automation"].AutoDelves then
		return
	end

	-- REASON: Re-evaluate Delve state on every zone transition.
	-- PLAYER_ENTERING_WORLD fires on login, /reload, and all zone changes.
	K:RegisterEvent("PLAYER_ENTERING_WORLD", function()
		-- REASON: Small delay ensures zone data is fully loaded before querying IsDelveInProgress.
		C_Timer_After(0.5, updateDelvesState)
	end)

	-- REASON: Unregister PLAYER_CHOICE_UPDATE immediately when leaving to prevent stale handlers.
	K:RegisterEvent("PLAYER_LEAVING_WORLD", function()
		K:UnregisterEvent("PLAYER_CHOICE_UPDATE", handlePlayerChoice)
	end)

	-- REASON: Initial check on module load (handles /reload or login while already inside a Delve).
	C_Timer_After(1, updateDelvesState)
end
