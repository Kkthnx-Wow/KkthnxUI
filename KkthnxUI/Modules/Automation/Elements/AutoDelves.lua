--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Automatically accepts Delve Companion power selections when inside a Delve.
-- - Design: PLAYER_CHOICE_UPDATE gated while in a Delve (IsDelveInProgress / IsPartyWalkIn).
-- - Events: PLAYER_CHOICE_UPDATE, PLAYER_ENTERING_WORLD, PLAYER_LEAVING_WORLD, WALK_IN_DATA_UPDATE
-- WARNING: C_PlayerChoice.SendPlayerChoiceResponse is a protected call; avoid calling from tainted code.
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Automation")

local C_EventUtils = _G.C_EventUtils
local C_PartyInfo = _G.C_PartyInfo
local C_PartyInfo_IsDelveInProgress = C_PartyInfo and C_PartyInfo.IsDelveInProgress
local C_PartyInfo_IsPartyWalkIn = C_PartyInfo and C_PartyInfo.IsPartyWalkIn
local C_PlayerChoice_GetCurrentPlayerChoiceInfo = C_PlayerChoice.GetCurrentPlayerChoiceInfo
local C_PlayerChoice_OnUIClosed = C_PlayerChoice.OnUIClosed
local C_PlayerChoice_SendPlayerChoiceResponse = C_PlayerChoice.SendPlayerChoiceResponse
local C_Timer_After = C_Timer.After

local HAS_WALK_IN_EVENT = C_EventUtils and C_EventUtils.IsEventValid and C_EventUtils.IsEventValid("WALK_IN_DATA_UPDATE")

local eventsRegistered = false
local walkInRegistered = false

local updateDelvesState

local function isInDelves()
	if C_PartyInfo_IsDelveInProgress and C_PartyInfo_IsDelveInProgress() then
		return true
	end
	return C_PartyInfo_IsPartyWalkIn and C_PartyInfo_IsPartyWalkIn() or false
end

local function handlePlayerChoice()
	if not isInDelves() then
		return
	end

	local choiceInfo = C_PlayerChoice_GetCurrentPlayerChoiceInfo()
	if not choiceInfo then
		return
	end

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
	local quality = (optionInfo.rarity or 0) + 1

	C_PlayerChoice_SendPlayerChoiceResponse(responseID)
	C_PlayerChoice_OnUIClosed()

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

local function registerWalkInEvent()
	if not HAS_WALK_IN_EVENT or walkInRegistered then
		return
	end
	walkInRegistered = true
	K:RegisterEvent("WALK_IN_DATA_UPDATE", updateDelvesState)
end

local function unregisterWalkInEvent()
	if not walkInRegistered then
		return
	end
	walkInRegistered = false
	K:UnregisterEvent("WALK_IN_DATA_UPDATE", updateDelvesState)
end

updateDelvesState = function()
	if not C["Automation"].AutoDelves then
		K:UnregisterEvent("PLAYER_CHOICE_UPDATE", handlePlayerChoice)
		return
	end

	if isInDelves() then
		K:RegisterEvent("PLAYER_CHOICE_UPDATE", handlePlayerChoice)
	else
		K:UnregisterEvent("PLAYER_CHOICE_UPDATE", handlePlayerChoice)
	end
end

local function onPlayerEnteringWorld()
	C_Timer_After(0.5, updateDelvesState)
end

local function onPlayerLeavingWorld()
	K:UnregisterEvent("PLAYER_CHOICE_UPDATE", handlePlayerChoice)
end

function Module:CreateAutoDelves()
	if not C["Automation"].AutoDelves then
		if eventsRegistered then
			K:UnregisterEvent("PLAYER_ENTERING_WORLD", onPlayerEnteringWorld)
			K:UnregisterEvent("PLAYER_LEAVING_WORLD", onPlayerLeavingWorld)
			K:UnregisterEvent("PLAYER_CHOICE_UPDATE", handlePlayerChoice)
			unregisterWalkInEvent()
			eventsRegistered = false
		end
		return
	end

	if eventsRegistered then
		updateDelvesState()
		return
	end

	eventsRegistered = true
	registerWalkInEvent()
	K:RegisterEvent("PLAYER_ENTERING_WORLD", onPlayerEnteringWorld)
	K:RegisterEvent("PLAYER_LEAVING_WORLD", onPlayerLeavingWorld)
	C_Timer_After(1, updateDelvesState)
end
