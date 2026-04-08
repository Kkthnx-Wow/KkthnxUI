--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Automatically interacts with quest NPCs for faster questing.
-- - Design: Hooks quest and gossip events to automate acceptance, progress, and turn-ins.
-- - Events: GOSSIP_SHOW, QUEST_GREETING, QUEST_DETAIL, QUEST_PROGRESS, QUEST_COMPLETE, etc.
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]

-- PERF: Localize globals and API functions to minimize lookup overhead.
local _G = _G
local AcknowledgeAutoAcceptQuest = AcknowledgeAutoAcceptQuest
local AcceptQuest = AcceptQuest
local C_GossipInfo_GetActiveQuests = C_GossipInfo.GetActiveQuests
local C_GossipInfo_GetAvailableQuests = C_GossipInfo.GetAvailableQuests
local C_GossipInfo_GetNumActiveQuests = C_GossipInfo.GetNumActiveQuests
local C_GossipInfo_GetNumAvailableQuests = C_GossipInfo.GetNumAvailableQuests
local C_GossipInfo_GetOptions = C_GossipInfo.GetOptions
local C_GossipInfo_SelectActiveQuest = C_GossipInfo.SelectActiveQuest
local C_GossipInfo_SelectAvailableQuest = C_GossipInfo.SelectAvailableQuest
local C_GossipInfo_SelectOption = C_GossipInfo.SelectOption
local C_Item_GetItemInfo = C_Item.GetItemInfo
local C_Minimap_IsFilteredOut = C_Minimap.IsFilteredOut
local C_Minimap_IsTrackingHiddenQuests = C_Minimap.IsTrackingHiddenQuests
local C_QuestLog_GetQuestTagInfo = C_QuestLog.GetQuestTagInfo
local C_QuestLog_IsQuestFlaggedCompletedOnAccount = C_QuestLog.IsQuestFlaggedCompletedOnAccount
local C_QuestLog_IsQuestTrivial = C_QuestLog.IsQuestTrivial
local C_QuestLog_IsWorldQuest = C_QuestLog.IsWorldQuest
local CloseQuest = CloseQuest
local CompleteQuest = CompleteQuest
local CreateFrame = CreateFrame
local GetActiveQuestID = GetActiveQuestID
local GetActiveTitle = GetActiveTitle
local GetAutoQuestPopUp = GetAutoQuestPopUp
local GetInstanceInfo = GetInstanceInfo
local GetItemInfoFromHyperlink = GetItemInfoFromHyperlink
local GetNumActiveQuests = GetNumActiveQuests
local GetNumAutoQuestPopUps = GetNumAutoQuestPopUps
local GetNumAvailableQuests = GetNumAvailableQuests
local GetNumQuestChoices = GetNumQuestChoices
local GetNumQuestItems = GetNumQuestItems
local GetQuestGetAutoAccept = QuestGetAutoAccept
local GetQuestID = GetQuestID
local GetQuestItemInfo = GetQuestItemInfo
local GetQuestItemLink = GetQuestItemLink
local GetQuestReward = GetQuestReward
local GetQuestIsFromAreaTrigger = QuestIsFromAreaTrigger
local IsAltKeyDown = IsAltKeyDown
local IsQuestCompletable = IsQuestCompletable
local IsShiftKeyDown = IsShiftKeyDown
local RemoveAutoQuestPopUp = RemoveAutoQuestPopUp
local SelectActiveQuest = SelectActiveQuest
local SelectAvailableQuest = SelectAvailableQuest
local ShowQuestComplete = ShowQuestComplete
local ShowQuestOffer = ShowQuestOffer
local StaticPopup_Hide = StaticPopup_Hide
local UnitGUID = UnitGUID
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local ipairs = ipairs
local next = next
local select = select
local string_find = string.find
local string_sub = string.sub
local string_upper = string.upper
local table_wipe = table.wipe

-- ---------------------------------------------------------------------------
-- Constants & State
-- ---------------------------------------------------------------------------
local QUEST_LABEL_PREPEND = Enum.GossipOptionRecFlags.QuestLabelPrepend
local MINIMAP_ACCOUNT_COMPLETED = Enum.MinimapTrackingFilter.AccountCompletedQuests
local QUEST_STRING = "cFF0000FF.-" .. _G.TRANSMOG_SOURCE_2
local IGNORED_TEXT = _G.IGNORED

local choiceQueue
local created

-- ---------------------------------------------------------------------------
-- Minimap / WorldMap Integration
-- ---------------------------------------------------------------------------
local function setupCheckButton()
	-- REASON: Adds a toggle button to the World Map for easy access to AutoQuest settings.
	if created then
		return
	end

	local worldMapFrame = _G.WorldMapFrame
	if not worldMapFrame then
		return
	end

	local mono = CreateFrame("CheckButton", nil, worldMapFrame.BorderFrame.TitleContainer, "OptionsBaseCheckButtonTemplate")
	mono:SetHitRectInsets(-5, -5, -5, -5)
	mono:SetPoint("TOPRIGHT", -140, 0)
	mono:SetSize(24, 24)
	mono:SetFrameLevel(999)
	mono.text = K.CreateFontString(mono, 12, "Auto Quest", "", "system", "LEFT", 24, 0)
	mono:SetChecked(K.GetCharVars().AutoQuest)
	mono:SetScript("OnClick", function(self)
		K.GetCharVars().AutoQuest = self:GetChecked()
	end)
	K.AddTooltip(mono, "ANCHOR_BOTTOMLEFT", "Automatically interact with quests.|n|nSingle-option gossip will be selected automatically.|n|nHold SHIFT to temporarily pause automation.|n|nTo block an NPC from auto-interaction, hold ALT and click their name in the Gossip or Quest frame.", "info", true)

	created = true
end
_G.WorldMapFrame:HookScript("OnShow", setupCheckButton)

-- ---------------------------------------------------------------------------
-- Core Automation Engine
-- ---------------------------------------------------------------------------
local QuickQuest = CreateFrame("Frame")
QuickQuest:SetScript("OnEvent", function(self, event, ...)
	self[event](...)
end)

function QuickQuest:Register(event, func)
	-- REASON: Wraps event handlers with automation checks (AutoQuest setting and Shift key bypass).
	self:RegisterEvent(event)
	self[event] = function(...)
		if K.GetCharVars().AutoQuest and not IsShiftKeyDown() then
			func(...)
		end
	end
end

local function getNPCID()
	return K.GetNPCID(UnitGUID("npc"))
end

local function isAccountCompleted(questID)
	-- REASON: Checks if the quest is already completed on account and if the minimap is filtering them.
	return C_Minimap_IsFilteredOut(MINIMAP_ACCOUNT_COMPLETED) and C_QuestLog_IsQuestFlaggedCompletedOnAccount(questID)
end

C.IgnoreQuestNPC = {}

-- ---------------------------------------------------------------------------
-- Event Handlers
-- ---------------------------------------------------------------------------
QuickQuest:Register("QUEST_GREETING", function()
	local npcID = getNPCID()
	if C.IgnoreQuestNPC[npcID] then
		return
	end

	local active = GetNumActiveQuests()
	if active > 0 then
		for index = 1, active do
			local _, isComplete = GetActiveTitle(index)
			local questID = GetActiveQuestID(index)
			if isComplete and not C_QuestLog_IsWorldQuest(questID) then
				SelectActiveQuest(index)
			end
		end
	end

	local available = GetNumAvailableQuests()
	if available > 0 then
		for index = 1, available do
			local isTrivial, _, _, _, questID = GetAvailableQuestInfo(index)
			if not isAccountCompleted(questID) and (not isTrivial or C_Minimap_IsTrackingHiddenQuests()) then
				SelectAvailableQuest(index)
			end
		end
	end
end)

local function shouldSuspendForSkipGossip()
	-- REASON: Suspends automation if the gossip text implies a "Skip" or "Campaign" choice that requires user attention.
	local gossipInfoTable = C_GossipInfo_GetOptions()
	if not gossipInfoTable then
		return false
	end
	for i = 1, #gossipInfoTable do
		local nameText = gossipInfoTable[i].name
		if nameText then
			-- Explicit red "<...>" prefix used for Skip options in Dragonflight/War Within
			if string_sub(nameText, 1, 11) == "|cFFFF0000<" then
				return true
			end
			-- Any colored or angle-bracketed line (except known purple DMF quests)
			local upper = string_upper(nameText)
			if (string_find(upper, "|C", 1, true) or string_find(upper, "<", 1, true)) and not string_find(nameText, "FF0008E8", 1, true) then
				return true
			end
		end
	end
	return false
end

QuickQuest:Register("GOSSIP_SHOW", function()
	local npcID = getNPCID()
	if C.IgnoreQuestNPC[npcID] then
		return
	end

	local active = C_GossipInfo_GetNumActiveQuests()
	if active > 0 then
		for _, questInfo in ipairs(C_GossipInfo_GetActiveQuests()) do
			local questID = questInfo.questID
			local isWorldQuest = questID and C_QuestLog_IsWorldQuest(questID)
			if questInfo.isComplete and not isWorldQuest then
				C_GossipInfo_SelectActiveQuest(questID)
			end
		end
	end

	local available = C_GossipInfo_GetNumAvailableQuests()
	if available > 0 then
		for _, questInfo in ipairs(C_GossipInfo_GetAvailableQuests()) do
			local trivial = questInfo.isTrivial
			local questID = questInfo.questID
			if not isAccountCompleted(questID) and (not trivial or C_Minimap_IsTrackingHiddenQuests() or (trivial and npcID == 64337)) then
				C_GossipInfo_SelectAvailableQuest(questID)
			end
		end
	end

	local gossipInfoTable = C_GossipInfo_GetOptions()
	if not gossipInfoTable then
		return
	end

	if shouldSuspendForSkipGossip() then
		return
	end

	local numOptions = #gossipInfoTable
	local firstOptionID = gossipInfoTable[1] and gossipInfoTable[1].gossipOptionID

	if firstOptionID then
		if C["AutoQuestData"].AutoSelectFirstOptionList[npcID] then
			return C_GossipInfo_SelectOption(firstOptionID)
		end

		if available == 0 and active == 0 and numOptions == 1 then
			local _, instance, _, _, _, _, _, mapID = GetInstanceInfo()
			if instance ~= "raid" and not C["AutoQuestData"].IgnoreGossipNPC[npcID] and not C["AutoQuestData"].IgnoreInstances[mapID] then
				return C_GossipInfo_SelectOption(firstOptionID)
			end
		end
	end

	-- REASON: Automatically select gossip option if it's the only quest-related interaction.
	local numQuestGossips = 0
	local questGossipID
	for i = 1, numOptions do
		local option = gossipInfoTable[i]
		if option.name and (string_find(option.name, QUEST_STRING) or option.flags == QUEST_LABEL_PREPEND) then
			numQuestGossips = numQuestGossips + 1
			questGossipID = option.gossipOptionID
		end
	end
	if numQuestGossips == 1 then
		return C_GossipInfo_SelectOption(questGossipID)
	end
end)

QuickQuest:Register("GOSSIP_CONFIRM", function(index)
	-- REASON: Skips confirmation dialogs for specific NPCs (e.g., flight masters, transporters).
	if C["AutoQuestData"].SkipConfirmNPCs[getNPCID()] then
		C_GossipInfo_SelectOption(index, "", true)
		StaticPopup_Hide("GOSSIP_CONFIRM")
	end
end)

QuickQuest:Register("QUEST_DETAIL", function()
	local questID = GetQuestID()
	if questID == 82449 then -- REASON: Call of the Worldsoul - requires manual choice.
		return
	end

	if GetQuestIsFromAreaTrigger() then
		AcceptQuest()
	elseif GetQuestGetAutoAccept() then
		AcknowledgeAutoAcceptQuest()
	elseif not C_QuestLog_IsQuestTrivial(questID) or C_Minimap_IsTrackingHiddenQuests() then
		if not C.IgnoreQuestNPC[getNPCID()] and not isAccountCompleted(questID) then
			AcceptQuest()
		end
	end
end)

QuickQuest:Register("QUEST_ACCEPT_CONFIRM", AcceptQuest)

QuickQuest:Register("QUEST_ACCEPTED", function()
	-- REASON: Auto-closes the quest frame if the quest was automatically accepted.
	if _G.QuestFrame:IsShown() and GetQuestGetAutoAccept() then
		CloseQuest()
	end
end)

QuickQuest:Register("QUEST_ITEM_UPDATE", function()
	if choiceQueue and QuickQuest[choiceQueue] then
		QuickQuest[choiceQueue]()
	end
end)

QuickQuest:Register("QUEST_PROGRESS", function()
	if IsQuestCompletable() then
		local questID = GetQuestID()
		if questID == 82449 then -- Call of the Worldsoul
			return
		end

		local info = C_QuestLog_GetQuestTagInfo(questID)
		if info and (info.tagID == 153 or info.worldQuestType) then
			return
		end

		if C.IgnoreQuestNPC[getNPCID()] then
			return
		end

		-- REASON: Checks for blacklisted items in quest requirements to prevent accidental turn-ins.
		local requiredItems = GetNumQuestItems()
		if requiredItems > 0 then
			for index = 1, requiredItems do
				local link = GetQuestItemLink("required", index)
				if link then
					local id = GetItemInfoFromHyperlink(link)
					for _, itemID in next, C["AutoQuestData"].ItemBlacklist do
						if itemID == id then
							CloseQuest()
							return
						end
					end
				else
					choiceQueue = "QUEST_PROGRESS"
					GetQuestItemInfo("required", index)
					return
				end
			end
		end

		CompleteQuest()
	end
end)

QuickQuest:Register("QUEST_COMPLETE", function()
	local questID = GetQuestID()
	if questID == 82449 then -- Call of the Worldsoul
		return
	end

	-- WARNING: Protect specific NPCs (Blingtron) from auto-turn-in to avoid wasting daily lockouts.
	local npcID = getNPCID()
	if npcID == 43929 or npcID == 77789 then
		return
	end

	local choices = GetNumQuestChoices()
	if choices <= 1 then
		GetQuestReward(choices)
	elseif choices > 1 then
		-- REASON: Automatically pick the reward with the highest sell price.
		local bestValue, bestIndex = 0

		for index = 1, choices do
			local link = GetQuestItemLink("choice", index)
			if link then
				local value = select(11, C_Item_GetItemInfo(link))
				local itemID = GetItemInfoFromHyperlink(link)
				value = C["AutoQuestData"].CashRewards[itemID] or value

				if value > bestValue then
					bestValue, bestIndex = value, index
				end
			else
				choiceQueue = "QUEST_COMPLETE"
				return GetQuestItemInfo("choice", index)
			end
		end

		local button = bestIndex and _G.QuestInfoRewardsFrame.RewardButtons[bestIndex]
		if button then
			_G.QuestInfoItem_OnClick(button)
		end
	end
end)

local function AttemptAutoComplete(event)
	-- REASON: Handles automatic quest offers and completions that pop up without NPC interaction.
	if GetNumAutoQuestPopUps() > 0 then
		if UnitIsDeadOrGhost("player") then
			QuickQuest:Register("PLAYER_REGEN_ENABLED", AttemptAutoComplete)
			return
		end

		local questID, popUpType = GetAutoQuestPopUp(1)
		if not C_QuestLog_IsWorldQuest(questID) then
			if popUpType == "OFFER" then
				ShowQuestOffer(questID)
			elseif popUpType == "COMPLETE" then
				ShowQuestComplete(questID)
			end
			_G.RemoveAutoQuestPopUp(questID)
		end
	end

	if event == "PLAYER_REGEN_ENABLED" then
		QuickQuest:UnregisterEvent(event)
	end
end
QuickQuest:Register("QUEST_LOG_UPDATE", AttemptAutoComplete)

-- ---------------------------------------------------------------------------
-- Ignore List Management
-- ---------------------------------------------------------------------------
local function updateIgnoreList()
	-- REASON: Syncs the local ignore list with both project defaults and user-defined ignores.
	table_wipe(C.IgnoreQuestNPC)

	for npcID, value in next, C["AutoQuestData"].IgnoreQuestNPC do
		C.IgnoreQuestNPC[npcID] = value
	end

	for npcID, value in next, K.GetCharVars().AutoQuestIgnoreNPC do
		if value and C["AutoQuestData"].IgnoreQuestNPC[npcID] then
			K.GetCharVars().AutoQuestIgnoreNPC[npcID] = nil
		else
			C.IgnoreQuestNPC[npcID] = value
		end
	end
end

local function unitQuickQuestStatus(self)
	-- REASON: Displays an "IGNORED" label on NPC frames if they are in the auto-quest ignore list.
	if not self.__ignore then
		local frame = CreateFrame("Frame", nil, self)
		frame:SetSize(100, 14)
		frame:SetPoint("TOP", self, "BOTTOM", 0, -6)
		K.AddTooltip(frame, "ANCHOR_RIGHT", L["AutoQuest Ignored Tooltip"], "info", true)
		K.CreateFontString(frame, 14, IGNORED_TEXT):SetTextColor(1, 0, 0)

		self.__ignore = frame

		updateIgnoreList()
	end

	local npcID = getNPCID()
	local isIgnored = K.GetCharVars().AutoQuest and npcID and C.IgnoreQuestNPC[npcID]
	self.__ignore:SetShown(isIgnored)
end

local function toggleQuickQuestStatus(self)
	-- REASON: Allows users to Alt-click NPC names to toggle them on/off the auto-quest ignore list.
	if not self.__ignore then
		return
	end
	if not K.GetCharVars().AutoQuest then
		return
	end
	if not IsAltKeyDown() then
		return
	end

	self.__ignore:SetShown(not self.__ignore:IsShown())
	local npcID = getNPCID()
	if self.__ignore:IsShown() then
		if C["AutoQuestData"].IgnoreQuestNPC[npcID] then
			K.GetCharVars().AutoQuestIgnoreNPC[npcID] = nil
		else
			K.GetCharVars().AutoQuestIgnoreNPC[npcID] = true
		end
	else
		if C["AutoQuestData"].IgnoreQuestNPC[npcID] then
			K.GetCharVars().AutoQuestIgnoreNPC[npcID] = false
		else
			K.GetCharVars().AutoQuestIgnoreNPC[npcID] = nil
		end
	end

	updateIgnoreList()
end

-- ---------------------------------------------------------------------------
-- Hooks
-- ---------------------------------------------------------------------------
_G.QuestNpcNameFrame:HookScript("OnShow", unitQuickQuestStatus)
_G.QuestNpcNameFrame:HookScript("OnMouseDown", toggleQuickQuestStatus)

local gossipTitleFrame = _G.GossipFrame and _G.GossipFrame.TitleContainer
if gossipTitleFrame then
	_G.GossipFrameCloseButton:SetFrameLevel(gossipTitleFrame:GetFrameLevel() + 1)
	gossipTitleFrame:HookScript("OnShow", unitQuickQuestStatus)
	gossipTitleFrame:HookScript("OnMouseDown", toggleQuickQuestStatus)
end
