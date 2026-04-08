--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Provides questing enhancements like action bar glows for specific mechanics and NPC identification.
-- - Design: Maintains a cache of tracked quests and reacts to monster emotes or gossip interactions for specific IDs.
-- - Events: QUEST_ACCEPTED, QUEST_REMOVED, CHAT_MSG_MONSTER_SAY, GOSSIP_SHOW
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Miscellaneous")

-- PERF: Localize global functions and environment for faster lookups.
local pairs = _G.pairs
local strfind = _G.strfind

local _G = _G
local C_GossipInfo_GetNumOptions = _G.C_GossipInfo.GetNumOptions
local C_GossipInfo_SelectOption = _G.C_GossipInfo.SelectOption
local C_Item_GetItemCount = _G.C_Item.GetItemCount
local C_QuestLog_GetLogIndexForQuestID = _G.C_QuestLog.GetLogIndexForQuestID
local C_Spell_GetSpellInfo = _G.C_Spell.GetSpellInfo
local CreateFrame = _G.CreateFrame
local GetActionInfo = _G.GetActionInfo
local GetOverrideBarSkin = _G.GetOverrideBarSkin
local UnitGUID = _G.UnitGUID

-- SG: Quest Configuration
local WATCHED_QUESTS = {
	-- SG: Check NPC identities
	[60739] = true, -- Tough Crowd
	[62453] = true, -- Into the Unknown
	-- SG: Enable Action Bar Glows
	[59585] = true, -- We'll Make an Aspirant Out of You
	[64271] = true, -- A More Civilized Way
}

local activeQuestCache = {}

local QUEST_TARGET_NPCS = {
	[170080] = true, -- Boggart
	[174498] = true, -- Shimmersod
}

local ACTION_REPLACEMENT_STRINGS = {
	["Sweep"] = "Lunge",
	["Assault"] = "Assault",
}

-- REASON: Initializes the active quest cache by checking the player's current quest log against tracked IDs.
function Module:initializeActiveQuestCache()
	for questID, isActive in pairs(WATCHED_QUESTS) do
		if C_QuestLog_GetLogIndexForQuestID(questID) then
			activeQuestCache[questID] = isActive
		end
	end
end

function Module:onQuestAcceptedUpdateCache(questID)
	if WATCHED_QUESTS[questID] then
		activeQuestCache[questID] = WATCHED_QUESTS[questID]
	end
end

function Module:onQuestRemovedUpdateCache(questID)
	if WATCHED_QUESTS[questID] then
		activeQuestCache[questID] = nil
	end
end

local function isActionTextMatch(message, searchText)
	return searchText and strfind(message, searchText)
end

-- REASON: Analyzes monster emotes to apply overlay glows to specific action bar buttons required for quest mechanics.
function Module:updateQuestActionGlow(monsterMessage)
	if GetOverrideBarSkin() and (activeQuestCache[59585] or activeQuestCache[64271]) then
		for i = 1, 3 do
			local actionButton = _G["ActionButton" .. i]
			local _, spellID = GetActionInfo(actionButton.action)
			local spellName = spellID and C_Spell_GetSpellInfo(spellID)
			if (ACTION_REPLACEMENT_STRINGS[spellName] and isActionTextMatch(monsterMessage, ACTION_REPLACEMENT_STRINGS[spellName])) or isActionTextMatch(monsterMessage, spellName) then
				K.ShowOverlayGlow(actionButton)
			else
				K.HideOverlayGlow(actionButton)
			end
		end
		Module.isQuestGlowActive = true
	else
		Module:clearQuestActionGlow()
	end
end

function Module:clearQuestActionGlow()
	if Module.isQuestGlowActive then
		Module.isQuestGlowActive = nil
		for i = 1, 3 do
			K.HideOverlayGlow(_G["ActionButton" .. i])
		end
	end
end

-- REASON: Adds an indicator to unit tooltips when a specific NPC required for a tracked quest is identified.
function Module:onQuestUnitTooltipUpdate()
	if not activeQuestCache[60739] and not activeQuestCache[62453] then
		return
	end

	local unitGUID = UnitGUID("mouseover")
	local npcID = unitGUID and K.GetNPCID(unitGUID)
	if QUEST_TARGET_NPCS[npcID] then
		self:AddLine(L["QuestTool NPCisTrue"])
	end
end

function Module:CreateQuestTool()
	if not C["Misc"].QuestTool then
		return
	end

	local questHandler = CreateFrame("Frame", nil, _G.UIParent)
	Module.QuestHandler = questHandler

	local questTipText = K.CreateFontString(questHandler, 20)
	questTipText:ClearAllPoints()
	questTipText:SetPoint("TOP", _G.UIParent, 0, -200)
	questTipText:SetWidth(800)
	questTipText:SetWordWrap(true)
	questTipText:Hide()
	Module.QuestTip = questTipText

	Module:initializeActiveQuestCache()
	K:RegisterEvent("QUEST_ACCEPTED", Module.onQuestAcceptedUpdateCache)
	K:RegisterEvent("QUEST_REMOVED", Module.onQuestRemovedUpdateCache)

	-- SG: Action Bar integration for quests with special override bars
	if C["ActionBar"].Enable then
		K:RegisterEvent("CHAT_MSG_MONSTER_SAY", Module.updateQuestActionGlow)
		K:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN", Module.clearQuestActionGlow)
	end

	-- SG: Tooltip identification for specific npc-finding quests
	_G.TooltipDataProcessor.AddTooltipPostCall(_G.Enum.TooltipDataType.Unit, Module.onQuestUnitTooltipUpdate)

	-- REASON: Automates specific gossip options for select NPCs to streamline repetitive quest interactions.
	local isFirstAutomationStep = false
	K:RegisterEvent("GOSSIP_SHOW", function()
		local unitGUID = UnitGUID("npc")
		if unitGUID then
			local npcID = K.GetNPCID(unitGUID)
			if npcID == 174498 then
				C_GossipInfo_SelectOption(3)
			elseif npcID == 174371 then
				if C_Item_GetItemCount(183961) > 0 and C_GossipInfo_GetNumOptions() == 5 then
					C_GossipInfo_SelectOption(isFirstAutomationStep and 2 or 5)
					isFirstAutomationStep = not isFirstAutomationStep
				end
			end
		end
	end)
end

Module:RegisterMisc("QuestTool", Module.CreateQuestTool)
