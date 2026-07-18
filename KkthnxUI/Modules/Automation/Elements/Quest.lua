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
local C_Minimap_IsTrackingHiddenQuests = C_Minimap.IsTrackingHiddenQuests
local C_QuestLog_GetLogIndexForQuestID = C_QuestLog.GetLogIndexForQuestID
local C_QuestLog_GetQuestTagInfo = C_QuestLog.GetQuestTagInfo
local C_QuestLog_IsPushableQuest = C_QuestLog.IsPushableQuest
local C_QuestLog_IsQuestTrivial = C_QuestLog.IsQuestTrivial
local C_QuestLog_IsWorldQuest = C_QuestLog.IsWorldQuest
local C_TooltipInfo_GetItemByID = C_TooltipInfo and C_TooltipInfo.GetItemByID
local C_QuestLog_GetQuestDifficultyLevel = C_QuestLog.GetQuestDifficultyLevel
local C_QuestLog_RequestLoadQuestByID = C_QuestLog.RequestLoadQuestByID
local C_PlayerInteractionManager_IsInteractingWithNpcOfType = C_PlayerInteractionManager and C_PlayerInteractionManager.IsInteractingWithNpcOfType
local C_Timer_After = C_Timer.After
local GetAvailableLevel = GetAvailableLevel
local GetAvailableQuestInfo = GetAvailableQuestInfo
local InCombatLockdown = InCombatLockdown
local RemoveAutoQuestPopUp = RemoveAutoQuestPopUp
local TaxiNodeInteraction = Enum.PlayerInteractionType and Enum.PlayerInteractionType.TaxiNode
local CloseQuest = CloseQuest
local CompleteQuest = CompleteQuest
local ConfirmAcceptQuest = ConfirmAcceptQuest
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
local GetQuestMoneyToGet = GetQuestMoneyToGet
local GetQuestGetAutoAccept = QuestGetAutoAccept
local GetQuestID = GetQuestID
local GetQuestItemInfo = GetQuestItemInfo
local GetQuestItemLink = GetQuestItemLink
local GetQuestReward = GetQuestReward
local GetQuestIsFromAreaTrigger = QuestIsFromAreaTrigger
local IsAltKeyDown = IsAltKeyDown
local IsInGroup = IsInGroup
local IsInRaid = IsInRaid
local IsQuestCompletable = IsQuestCompletable
local IsShiftKeyDown = IsShiftKeyDown
local QuestLogPushQuest = QuestLogPushQuest
local QuestIsDaily = QuestIsDaily
local QuestIsWeekly = QuestIsWeekly
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
local string_upper = string.upper
local table_wipe = table.wipe

local NotSecret = K.NotSecret

-- ---------------------------------------------------------------------------
-- Constants & State
-- ---------------------------------------------------------------------------

-- REASON: Named constants for magic NPC/Quest IDs to improve patch-time maintainability.
local CALL_OF_THE_WORLDSOUL_QUEST_ID = 82449
local BLINGTRON_4000_NPC_ID = 43929 -- daily lockout protection
local BLINGTRON_5000_NPC_ID = 77789 -- daily lockout protection

local MAX_REQUIRED_ITEMS = _G.MAX_REQUIRED_ITEMS or 8
local QUEST_LABEL_PREPEND = Enum.GossipOptionRecFlags.QuestLabelPrepend
local FlagsUtil_IsSet = FlagsUtil and FlagsUtil.IsSet
local GossipOptionStatus = Enum.GossipOptionStatus
local QUEST_FREQUENCY_DAILY = Enum.QuestFrequency and Enum.QuestFrequency.Daily
local QUEST_FREQUENCY_WEEKLY = Enum.QuestFrequency and Enum.QuestFrequency.Weekly
local QUEST_STRING = "cFF0000FF.-" .. _G.TRANSMOG_SOURCE_2
local IGNORED_TEXT = _G.IGNORED
local STEALTH_CLASS_SKIP = { ROGUE = true, DRUID = true }
local UnitName = UnitName
local format = string.format

local choiceQueue
local created

-- REASON: Module-local runtime ignore cache; never written to C to avoid polluting the shared config namespace.
-- updateIgnoreList() merges the defaults (C["AutoQuestData"]) and user overrides (CharVars) into this table.
local ignoreQuestNPC = {}

-- ---------------------------------------------------------------------------
-- Core Automation Engine (feature-scoped events)
-- ---------------------------------------------------------------------------
local handlers = {}
local registeredEvents = {}
local eventsActive = false
local questDataQueue = {}
local gossipContinueScheduled
local pendingSkipConfirm
local regenRetryRegistered
local regenRetryCallback

local function Automating()
	local charVars = K.GetCharVars()
	return charVars and charVars.AutoQuest and not IsShiftKeyDown()
end

local function SetEventsActive(state)
	if state then
		if eventsActive then
			return
		end
		eventsActive = true
		for i = 1, #registeredEvents do
			local entry = registeredEvents[i]
			K:RegisterEvent(entry[1], entry[2])
		end
	else
		if not eventsActive then
			return
		end
		eventsActive = false
		for i = 1, #registeredEvents do
			local entry = registeredEvents[i]
			K:UnregisterEvent(entry[1], entry[2])
		end
		if regenRetryRegistered then
			regenRetryRegistered = false
			K:UnregisterEvent("PLAYER_REGEN_ENABLED", regenRetryCallback)
		end
	end
end

-- ---------------------------------------------------------------------------
-- Minimap / WorldMap Integration
-- ---------------------------------------------------------------------------
-- After SetEventsActive: Lua 5.1 locals aren't visible above their definition.
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
	mono:SetChecked(K.GetCharVars() and K.GetCharVars().AutoQuest)
	mono:SetScript("OnClick", function(self)
		local charVars = K.GetCharVars()
		if not charVars then
			return
		end
		charVars.AutoQuest = self:GetChecked()
		SetEventsActive(self:GetChecked())
	end)
	K.AddTooltip(mono, "ANCHOR_BOTTOMLEFT", "Automatically interact with quests.|n|nSingle-option gossip will be selected automatically.|n|nHold SHIFT to temporarily pause automation.|n|nTo block an NPC from auto-interaction, hold ALT and click their name in the Gossip or Quest frame.", "info", true)

	created = true
end
if _G.WorldMapFrame then
	_G.WorldMapFrame:HookScript("OnShow", setupCheckButton)
end

local function QuickQuest_Register(event, func)
	handlers[event] = func
	local callback = function(_, ...)
		if not Automating() then
			return
		end
		func(...)
	end
	registeredEvents[#registeredEvents + 1] = { event, callback }
end

local function getNPCID()
	return K.GetNPCID(UnitGUID("npc"))
end

local function WaitForQuestData(questID, callback)
	if not (questID and C_QuestLog_RequestLoadQuestByID) then
		return false
	end
	questDataQueue[questID] = callback
	C_QuestLog_RequestLoadQuestByID(questID)
	return true
end

local function isQuestFrequencyAllowed(frequency)
	if frequency == QUEST_FREQUENCY_DAILY then
		return C["Automation"].AutoQuestAcceptDaily
	elseif frequency == QUEST_FREQUENCY_WEEKLY then
		return C["Automation"].AutoQuestAcceptWeekly
	end
	return C["Automation"].AutoQuestAcceptRegular
end

local function isQuestDetailFrequencyAllowed()
	if QuestIsDaily and QuestIsDaily() then
		return C["Automation"].AutoQuestAcceptDaily
	elseif QuestIsWeekly and QuestIsWeekly() then
		return C["Automation"].AutoQuestAcceptWeekly
	end
	return C["Automation"].AutoQuestAcceptRegular
end

local function AvailableAcceptAllowed(npcID, questID, frequency, isTrivial, isGossipIgnored)
	if isGossipIgnored then
		return false
	end
	if C["AutoQuestData"].BlockQuestID[questID] then
		return false
	end
	if not isQuestFrequencyAllowed(frequency) then
		return false
	end
	if isTrivial and not C_Minimap_IsTrackingHiddenQuests() and npcID ~= 64337 then
		return false
	end
	return true
end

local accountBoundLines = {}
do
	local labels = { _G.ITEM_BNETACCOUNTBOUND, _G.ITEM_BIND_TO_BNETACCOUNT, _G.ITEM_BIND_TO_ACCOUNT, _G.ITEM_ACCOUNTBOUND }
	for i = 1, #labels do
		if labels[i] then
			accountBoundLines[labels[i]] = true
		end
	end
end

local function isCraftingReagent(itemID)
	return select(17, C_Item_GetItemInfo(itemID)) and true or false
end

local function isItemAccountBound(itemID)
	if not C_TooltipInfo_GetItemByID then
		return false
	end
	local data = C_TooltipInfo_GetItemByID(itemID)
	local lines = data and data.lines
	if not lines then
		return false
	end
	for i = 1, #lines do
		local line = lines[i]
		if line and line.leftText and accountBoundLines[line.leftText] then
			return true
		end
	end
	return false
end

local function hasCostlyTurnIn()
	if not C["Automation"].AutoQuestProtectTurnIns then
		return false
	end

	if GetQuestMoneyToGet and (GetQuestMoneyToGet() or 0) > 0 then
		return true
	end

	for index = 1, MAX_REQUIRED_ITEMS do
		local itemButton = _G["QuestProgressItem" .. index]
		if itemButton and itemButton:IsShown() and itemButton.type == "required" then
			if itemButton.objectType == "currency" then
				return true
			elseif itemButton.objectType == "item" then
				local itemID = select(6, GetQuestItemInfo("required", index))
				if itemID and (isCraftingReagent(itemID) or isItemAccountBound(itemID)) then
					return true
				end
			end
		end
	end

	return false
end

-- ---------------------------------------------------------------------------
-- Gossip helpers (Midnight quest/gossip deltas)
-- ---------------------------------------------------------------------------
local function IsQuestLabelPrepend(flags)
	if not flags then
		return false
	end
	if FlagsUtil_IsSet then
		return FlagsUtil_IsSet(flags, QUEST_LABEL_PREPEND)
	end
	return flags == QUEST_LABEL_PREPEND
end

-- Colour / angle-bracket markup usually means teleports, skip-ahead, or
-- consequence choices. Lone special options stay player-driven (purple quest
-- colour FF0008E8 is fine — that is normal quest gossip).
local function HasUnsafeGossipOption(options)
	for i = 1, #options do
		local name = options[i] and options[i].name
		if name then
			local upper = string_upper(name)
			if (string_find(upper, "|C", 1, true) or string_find(upper, "<", 1, true)) and not string_find(upper, "FF0008E8", 1, true) then
				return true
			end
		end
	end
	return false
end

local function IsMiniGameSkipGossip(name)
	if not name then
		return false
	end
	local upper = string_upper(name)
	if not string_find(upper, "<", 1, true) or not string_find(upper, "SKIP", 1, true) then
		return false
	end
	if string_find(upper, "MINI GAME", 1, true) or string_find(upper, "MINIGAME", 1, true) then
		return true
	end
	local miniGameLabel = _G["11_0_0_DELVES_MINIGAME_01"]
	if miniGameLabel then
		return string_find(upper, string_upper(miniGameLabel), 1, true) ~= nil
	end
	return false
end

local function IsSkipGossip(name)
	if not name or IsMiniGameSkipGossip(name) then
		return false
	end
	return string_find(string_upper(name), "<SKIP", 1, true) ~= nil
end

local function IsGossipOptionSelectable(option)
	if not option or not option.gossipOptionID then
		return false
	end
	local status = option.status
	if status == nil or not GossipOptionStatus then
		return true
	end
	return status == GossipOptionStatus.Available or status == GossipOptionStatus.AlreadyComplete
end

local function IsUtilityGossipOption(optionID)
	local rule = C["AutoQuestData"].UtilityGossipOptions and C["AutoQuestData"].UtilityGossipOptions[optionID]
	if rule == true then
		return true
	end
	if rule == "HUNTER" and K.Class == "HUNTER" then
		return true
	end
end

local function TrySelectMiniGameSkipGossip(gossipInfoTable)
	local ignoreOpts = C["AutoQuestData"].IgnoreGossipOptions
	local skipID, numSkips
	for i = 1, #gossipInfoTable do
		local option = gossipInfoTable[i]
		local name = option and option.name
		local optionID = option and option.gossipOptionID
		if name and optionID and IsMiniGameSkipGossip(name) and not (ignoreOpts and ignoreOpts[optionID]) then
			numSkips = (numSkips or 0) + 1
			skipID = optionID
		end
	end
	if numSkips ~= 1 or not skipID then
		return false
	end
	pendingSkipConfirm = true
	C_GossipInfo_SelectOption(skipID)
	return true
end

local function TrySelectStealthClassSkipGossip(gossipInfoTable)
	if not (K.Class and STEALTH_CLASS_SKIP[K.Class]) then
		return false
	end
	local ignoreOpts = C["AutoQuestData"].IgnoreGossipOptions
	local skipID, numSkips
	for i = 1, #gossipInfoTable do
		local option = gossipInfoTable[i]
		local name = option and option.name
		local optionID = option and option.gossipOptionID
		if name and optionID and IsGossipOptionSelectable(option) and string_find(string_upper(name), "STEALTH CLASS", 1, true)
			and not (ignoreOpts and ignoreOpts[optionID]) then
			numSkips = (numSkips or 0) + 1
			skipID = optionID
		end
	end
	if numSkips ~= 1 or not skipID then
		return false
	end
	C_GossipInfo_SelectOption(skipID)
	return true
end

local function TrySelectUtilityGossip(gossipInfoTable)
	for i = 1, #gossipInfoTable do
		local optionID = gossipInfoTable[i] and gossipInfoTable[i].gossipOptionID
		if optionID and IsUtilityGossipOption(optionID) then
			C_GossipInfo_SelectOption(optionID)
			return true
		end
	end
	return false
end

local function ProcessGossipOptions(npcID, available, active)
	local gossipInfoTable = C_GossipInfo_GetOptions()
	if not gossipInfoTable then
		return false
	end

	local data = C["AutoQuestData"]
	local ignoreOpts = data.IgnoreGossipOptions
	local numOptions = #gossipInfoTable
	local firstOptionID = gossipInfoTable[1] and gossipInfoTable[1].gossipOptionID

	if firstOptionID then
		if data.AutoSelectFirstOptionList[npcID] then
			C_GossipInfo_SelectOption(firstOptionID)
			return true
		end

		-- One-action walk: only when the lone option is not "special" markup.
		if available == 0 and active == 0 and numOptions == 1 and not data.IgnoreGossipNPC[npcID]
			and not HasUnsafeGossipOption(gossipInfoTable) and not (ignoreOpts and ignoreOpts[firstOptionID]) then
			local _, instance, _, _, _, _, _, mapID = GetInstanceInfo()
			if instance ~= "raid" and not data.IgnoreInstances[mapID] then
				C_GossipInfo_SelectOption(firstOptionID)
				return true
			end
		end
	end

	local numQuestGossips, numSkipGossips = 0, 0
	local questGossipID, skipGossipID
	local questOpts = data.QuestGossipOptions
	for i = 1, numOptions do
		local option = gossipInfoTable[i]
		local name = option.name
		if name then
			if IsSkipGossip(name) then
				numSkipGossips = numSkipGossips + 1
				skipGossipID = option.gossipOptionID
			end
			if (questOpts and questOpts[option.gossipOptionID]) or string_find(name, QUEST_STRING) or IsQuestLabelPrepend(option.flags) then
				numQuestGossips = numQuestGossips + 1
				questGossipID = option.gossipOptionID
			end
		end
	end

	-- Opt-in story skip (campaign / conversation). Arms GOSSIP_CONFIRM follow-up.
	if C["Automation"].AutoQuestSkipGossip and numSkipGossips == 1 and skipGossipID
		and not (ignoreOpts and ignoreOpts[skipGossipID]) then
		pendingSkipConfirm = true
		local npcName = UnitName("npc")
		if npcName and NotSecret(npcName) then
			K.Print(format("%s%s", K.SystemColor, format(L["Skipped story dialogue from %s."], npcName)))
		else
			K.Print(format("%s%s", K.SystemColor, L["Skipped story dialogue."]))
		end
		C_GossipInfo_SelectOption(skipGossipID)
		return true
	end

	if numQuestGossips == 1 and questGossipID then
		C_GossipInfo_SelectOption(questGossipID)
		return true
	end
	return false
end

local function ProcessGreetingQuests()
	local npcID = getNPCID()
	if ignoreQuestNPC[npcID] then
		return false
	end

	local active = GetNumActiveQuests()
	if active > 0 then
		for index = 1, active do
			local _, isComplete = GetActiveTitle(index)
			local questID = GetActiveQuestID(index)
			if isComplete and not C_QuestLog_IsWorldQuest(questID) then
				SelectActiveQuest(index)
				return true
			end
		end
	end

	local available = GetNumAvailableQuests()
	if available > 0 and not C["AutoQuestData"].SelectOnlyIgnoreNPC[npcID] then
		for index = 1, available do
			local isTrivial, frequency, _, _, questID = GetAvailableQuestInfo(index)
			local questLevel = GetAvailableLevel and GetAvailableLevel(index)
			if questID and (not questLevel or questLevel == 0) then
				if WaitForQuestData(questID, ProcessGreetingQuests) then
					return true
				end
			elseif AvailableAcceptAllowed(npcID, questID, frequency, isTrivial, false) then
				SelectAvailableQuest(index)
				return true
			end
		end
	end
	return false
end

local function ProcessGossipQuests()
	local npcID = getNPCID()
	if ignoreQuestNPC[npcID] then
		return false
	end
	if C_PlayerInteractionManager_IsInteractingWithNpcOfType and TaxiNodeInteraction and C_PlayerInteractionManager_IsInteractingWithNpcOfType(TaxiNodeInteraction) then
		return false
	end
	local wormholes = _G.InteractiveWormholes
	if wormholes and wormholes.IsActive and wormholes:IsActive() then
		return false
	end

	local active = C_GossipInfo_GetNumActiveQuests()
	if active > 0 then
		for _, questInfo in ipairs(C_GossipInfo_GetActiveQuests()) do
			local questID = questInfo.questID
			local isWorldQuest = questID and C_QuestLog_IsWorldQuest(questID)
			if not questInfo.questLevel or questInfo.questLevel == 0 then
				if questID and WaitForQuestData(questID, ProcessGossipQuests) then
					return true
				end
			elseif questInfo.isComplete and not isWorldQuest then
				C_GossipInfo_SelectActiveQuest(questID)
				return true
			end
		end
	end

	local available = C_GossipInfo_GetNumAvailableQuests()
	if available > 0 and not C["AutoQuestData"].SelectOnlyIgnoreNPC[npcID] then
		for _, questInfo in ipairs(C_GossipInfo_GetAvailableQuests()) do
			local questID = questInfo.questID
			if questID == CALL_OF_THE_WORLDSOUL_QUEST_ID then
				C_GossipInfo_SelectAvailableQuest(questID)
				return true
			elseif not questInfo.questLevel or questInfo.questLevel == 0 then
				if questID and WaitForQuestData(questID, ProcessGossipQuests) then
					return true
				end
			elseif AvailableAcceptAllowed(npcID, questID, questInfo.frequency, questInfo.isTrivial, questInfo.isIgnored) then
				C_GossipInfo_SelectAvailableQuest(questID)
				return true
			end
		end
	end

	return ProcessGossipOptions(npcID, available, active)
end

local function ScheduleGossipContinue()
	if gossipContinueScheduled then
		return
	end
	gossipContinueScheduled = true
	C_Timer_After(0, function()
		gossipContinueScheduled = false
		if not Automating() then
			return
		end
		if ProcessGossipQuests() then
			return
		end
		ProcessGreetingQuests()
	end)
end

-- ---------------------------------------------------------------------------
-- Event Handlers
-- ---------------------------------------------------------------------------
QuickQuest_Register("QUEST_DATA_LOAD_RESULT", function(questID, success)
	local callback = questDataQueue[questID]
	if not callback then
		return
	end
	questDataQueue[questID] = nil
	if success ~= false then
		callback()
	end
end)

QuickQuest_Register("QUEST_GREETING", function()
	ProcessGreetingQuests()
end)

QuickQuest_Register("GOSSIP_SHOW", function()
	-- Drop stale skip-confirm arm from a prior window; re-armed below if we skip.
	pendingSkipConfirm = nil

	local gossipInfoTable = C_GossipInfo_GetOptions()
	if gossipInfoTable then
		if TrySelectMiniGameSkipGossip(gossipInfoTable) then
			return
		end
		if TrySelectStealthClassSkipGossip(gossipInfoTable) then
			return
		end
		if TrySelectUtilityGossip(gossipInfoTable) then
			return
		end
	end

	ProcessGossipQuests()
end)

QuickQuest_Register("GOSSIP_CONFIRM", function(gossipID, _, cost)
	if C["AutoQuestData"].SkipConfirmNPCs[getNPCID()] then
		C_GossipInfo_SelectOption(gossipID, "", true)
		StaticPopup_Hide("GOSSIP_CONFIRM")
		return
	end
	if pendingSkipConfirm and (not cost or (NotSecret(cost) and cost == 0)) then
		pendingSkipConfirm = nil
		C_GossipInfo_SelectOption(gossipID, "", true)
		StaticPopup_Hide("GOSSIP_CONFIRM")
		return
	end
	pendingSkipConfirm = nil
end)

local function TryAcceptQuestDetail()
	local questID = GetQuestID()
	if not questID or questID == 0 or questID == CALL_OF_THE_WORLDSOUL_QUEST_ID then
		return
	end

	local questLevel = C_QuestLog_GetQuestDifficultyLevel and C_QuestLog_GetQuestDifficultyLevel(questID)
	if not questLevel or questLevel == 0 then
		WaitForQuestData(questID, TryAcceptQuestDetail)
		return
	end

	if GetQuestIsFromAreaTrigger() then
		AcceptQuest()
	elseif GetQuestGetAutoAccept() then
		AcknowledgeAutoAcceptQuest()
		if RemoveAutoQuestPopUp then
			RemoveAutoQuestPopUp(questID)
		end
	elseif not C_QuestLog_IsQuestTrivial(questID) or C_Minimap_IsTrackingHiddenQuests() then
		if ignoreQuestNPC[getNPCID()] or C["AutoQuestData"].BlockQuestID[questID] then
			return
		end
		if isQuestDetailFrequencyAllowed() then
			AcceptQuest()
		end
	end
end

QuickQuest_Register("QUEST_DETAIL", TryAcceptQuestDetail)

QuickQuest_Register("QUEST_ACCEPT_CONFIRM", function()
	if ConfirmAcceptQuest then
		ConfirmAcceptQuest()
	else
		AcceptQuest()
	end
end)

QuickQuest_Register("QUEST_ACCEPTED", function(questID)
	if _G.QuestFrame:IsShown() and GetQuestGetAutoAccept() then
		CloseQuest()
	end

	if C["Automation"].AutoShareQuest and questID then
		if IsInGroup() and not IsInRaid() then
			local logIndex = C_QuestLog_GetLogIndexForQuestID(questID)
			if logIndex and logIndex > 0 and C_QuestLog_IsPushableQuest(questID) then
				QuestLogPushQuest(logIndex)
			end
		end
	end

	ScheduleGossipContinue()
end)

QuickQuest_Register("QUEST_FINISHED", ScheduleGossipContinue)

QuickQuest_Register("QUEST_ITEM_UPDATE", function()
	if choiceQueue and handlers[choiceQueue] then
		handlers[choiceQueue]()
	end
end)

QuickQuest_Register("QUEST_PROGRESS", function()
	if IsQuestCompletable() then
		local questID = GetQuestID()
		if questID == CALL_OF_THE_WORLDSOUL_QUEST_ID then
			return
		end

		local info = C_QuestLog_GetQuestTagInfo(questID)
		if info and (info.tagID == 153 or info.worldQuestType) then
			return
		end

		if ignoreQuestNPC[getNPCID()] then
			return
		end

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

		if not hasCostlyTurnIn() then
			CompleteQuest()
		end
	end
end)

QuickQuest_Register("QUEST_COMPLETE", function()
	local questID = GetQuestID()
	if questID == CALL_OF_THE_WORLDSOUL_QUEST_ID then
		return
	end

	local npcID = getNPCID()
	if npcID == BLINGTRON_4000_NPC_ID or npcID == BLINGTRON_5000_NPC_ID then
		return
	end
	if C["Automation"].AutoQuestProtectTurnIns and GetQuestMoneyToGet and (GetQuestMoneyToGet() or 0) > 0 then
		return
	end

	local choices = GetNumQuestChoices()
	if choices <= 1 then
		GetQuestReward(1)
	elseif choices > 1 then
		local bestValue, bestIndex = 0

		for index = 1, choices do
			local link = GetQuestItemLink("choice", index)
			if link then
				local value = select(11, C_Item_GetItemInfo(link))
				local itemID = GetItemInfoFromHyperlink(link)
				value = C["AutoQuestData"].CashRewards[itemID] or value

				if value and value > bestValue then
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

local function RegisterRegenRetry()
	if regenRetryRegistered then
		return
	end
	regenRetryRegistered = true
	K:RegisterEvent("PLAYER_REGEN_ENABLED", regenRetryCallback)
end

local function AttemptAutoComplete()
	local numPopUps = GetNumAutoQuestPopUps()
	if numPopUps == 0 then
		return
	end

	local worldMapFrame = _G.WorldMapFrame
	if (worldMapFrame and worldMapFrame:IsShown()) or (_G.QuestFrame and _G.QuestFrame:IsShown()) then
		return
	end

	if UnitIsDeadOrGhost("player") or InCombatLockdown() then
		RegisterRegenRetry()
		return
	end

	for index = 1, numPopUps do
		local questID, popUpType = GetAutoQuestPopUp(index)
		if questID then
			local questLevel = C_QuestLog_GetQuestDifficultyLevel and C_QuestLog_GetQuestDifficultyLevel(questID)
			if not questLevel or questLevel == 0 then
				WaitForQuestData(questID, AttemptAutoComplete)
			elseif not C_QuestLog_IsWorldQuest(questID) then
				if popUpType == "OFFER" then
					ShowQuestOffer(questID)
				elseif popUpType == "COMPLETE" then
					ShowQuestComplete(questID)
				end
				if RemoveAutoQuestPopUp then
					RemoveAutoQuestPopUp(questID)
				end
			end
		end
	end
end

regenRetryCallback = function()
	if regenRetryRegistered then
		regenRetryRegistered = false
		K:UnregisterEvent("PLAYER_REGEN_ENABLED", regenRetryCallback)
	end
	if Automating() then
		AttemptAutoComplete()
	end
end

QuickQuest_Register("QUEST_LOG_UPDATE", AttemptAutoComplete)

local function syncAutoQuestEvents()
	local charVars = K.GetCharVars()
	SetEventsActive(charVars and charVars.AutoQuest)
end

-- ---------------------------------------------------------------------------
-- Ignore List Management
-- ---------------------------------------------------------------------------
local function updateIgnoreList()
	-- REASON: Syncs the local ignore list with both project defaults and user-defined ignores.
	table_wipe(ignoreQuestNPC)

	for npcID, value in next, C["AutoQuestData"].IgnoreQuestNPC do
		ignoreQuestNPC[npcID] = value
	end

	local charVars = K.GetCharVars()
	if charVars and charVars.AutoQuestIgnoreNPC then
		for npcID, value in next, charVars.AutoQuestIgnoreNPC do
			if value and C["AutoQuestData"].IgnoreQuestNPC[npcID] then
				charVars.AutoQuestIgnoreNPC[npcID] = nil
			else
				ignoreQuestNPC[npcID] = value
			end
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
	local charVars = K.GetCharVars()
	local isIgnored = charVars and charVars.AutoQuest and npcID and ignoreQuestNPC[npcID]
	self.__ignore:SetShown(isIgnored)
end

local function toggleQuickQuestStatus(self)
	-- REASON: Allows users to Alt-click NPC names to toggle them on/off the auto-quest ignore list.
	if not self.__ignore then
		return
	end
	if not K.GetCharVars() or not K.GetCharVars().AutoQuest then
		return
	end
	if not IsAltKeyDown() then
		return
	end

	self.__ignore:SetShown(not self.__ignore:IsShown())
	local npcID = getNPCID()
	local charVars = K.GetCharVars()
	if self.__ignore:IsShown() then
		if C["AutoQuestData"].IgnoreQuestNPC[npcID] then
			charVars.AutoQuestIgnoreNPC[npcID] = nil
		else
			charVars.AutoQuestIgnoreNPC[npcID] = true
		end
	else
		if C["AutoQuestData"].IgnoreQuestNPC[npcID] then
			charVars.AutoQuestIgnoreNPC[npcID] = false
		else
			charVars.AutoQuestIgnoreNPC[npcID] = nil
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

updateIgnoreList()

local Automation = K:GetModule("Automation")
function Automation.UpdateAutoQuestIgnoreList()
	updateIgnoreList()
end

function Automation:SyncAutoQuestEvents()
	syncAutoQuestEvents()
end

-- Char vars are created in KKUI_VerifyDatabase on ADDON_LOADED; init after login.
K:RegisterEvent("PLAYER_LOGIN", function()
	syncAutoQuestEvents()
	updateIgnoreList()
end)
