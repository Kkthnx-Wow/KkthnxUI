local K, C = unpack(select(2, ...))
if K.CheckAddOnState("QuickQuest") or K.CheckAddOnState("AutoTurnIn") then
	return
end

if C["Automation"].AutoQuest ~= true then
	return
end

local _G = _G
local next = next
local select = select
local string_find = string.find
local string_match = string.match
local string_sub = string.sub
local tonumber = tonumber

local AcceptQuest = _G.AcceptQuest
local AcknowledgeAutoAcceptQuest = _G.AcknowledgeAutoAcceptQuest
local C_Timer_After = _G.C_Timer.After
local CompleteQuest = _G.CompleteQuest
local GetActiveTitle = _G.GetActiveTitle
local GetAutoQuestPopUp = _G.GetAutoQuestPopUp
local GetAvailableQuestInfo = _G.GetAvailableQuestInfo
local GetGossipActiveQuests = _G.GetGossipActiveQuests
local GetGossipAvailableQuests = _G.GetGossipAvailableQuests
local GetGossipOptions = _G.GetGossipOptions
local GetInstanceInfo = _G.GetInstanceInfo
local GetItemInfo = _G.GetItemInfo
local GetItemInfoFromHyperlink = _G.GetItemInfoFromHyperlink
local GetNumActiveQuests = _G.GetNumActiveQuests
local GetNumAutoQuestPopUps = _G.GetNumAutoQuestPopUps
local GetNumAvailableQuests = _G.GetNumAvailableQuests
local GetNumGossipActiveQuests = _G.GetNumGossipActiveQuests
local GetNumGossipAvailableQuests = _G.GetNumGossipAvailableQuests
local GetNumGossipOptions = _G.GetNumGossipOptions
local GetNumGroupMembers = _G.GetNumGroupMembers
local GetNumQuestChoices = _G.GetNumQuestChoices
local GetNumQuestItems = _G.GetNumQuestItems
local GetNumQuestLogEntries = _G.GetNumQuestLogEntries
local GetNumTrackingTypes = _G.GetNumTrackingTypes
local GetQuestID = _G.GetQuestID
local GetQuestItemInfo = _G.GetQuestItemInfo
local GetQuestItemLink = _G.GetQuestItemLink
local GetQuestLogIndexByID = _G.GetQuestLogIndexByID
local GetQuestLogTitle = _G.GetQuestLogTitle
local GetQuestReward = _G.GetQuestReward
local GetQuestTagInfo = _G.GetQuestTagInfo
local GetTrackingInfo = _G.GetTrackingInfo
local IsQuestCompletable = _G.IsQuestCompletable
local QuestFrame_OnEvent = _G.QuestFrame_OnEvent
local QuestGetAutoAccept = _G.QuestGetAutoAccept
local QuestInfoItem_OnClick = _G.QuestInfoItem_OnClick
local QuestIsFromAreaTrigger = _G.QuestIsFromAreaTrigger
local SelectActiveQuest = _G.SelectActiveQuest
local SelectAvailableQuest = _G.SelectAvailableQuest
local SelectGossipActiveQuest = _G.SelectGossipActiveQuest
local SelectGossipAvailableQuest = _G.SelectGossipAvailableQuest
local SelectGossipOption = _G.SelectGossipOption
local SelectGossipOption = _G.SelectGossipOption
local ShowQuestComplete = _G.ShowQuestComplete
local ShowQuestOffer = _G.ShowQuestOffer
local StaticPopup_Hide = _G.StaticPopup_Hide
local UnitGUID = _G.UnitGUID
local UnitIsDeadOrGhost = _G.UnitIsDeadOrGhost

local AutoQuestDB = {
	["FairePort"] = true,
	["Gossip"] = true,
	["GossipRaid"] = 1,
	["Items"] = true,
	["Modifier"] = "SHIFT",
	["Nomi"] = true,
	["Reverse"] = false,
	["Share"] = false,
	["Withered"] = true,
}

local AutoQuest = CreateFrame("Frame")
AutoQuest:SetScript("OnEvent", function(self, event, ...)
	self[event](...)
end)

local metatable = {
	__call = function(methods, ...)
		for _, method in next, methods do
			method(...)
		end
	end
}

local modifier = false
function AutoQuest:Register(event, method, override)
	local newmethod
	if (not override) then
		newmethod = function(...)
			if (AutoQuestDB.Reverse == modifier) then
				method(...)
			end
		end
	end

	local methods = self[event]
	if (methods) then
		self[event] = setmetatable({methods, newmethod or method}, metatable)
	else
		self[event] = newmethod or method
		self:RegisterEvent(event)
	end
end

local function GetNPCID()
	return tonumber(string_match(UnitGUID("npc") or "", "Creature%-.-%-.-%-.-%-.-%-(.-)%-"))
end

local function IsTrackingHidden()
	for index = 1, GetNumTrackingTypes() do
		local name, _, active = GetTrackingInfo(index)
		if (name == (MINIMAP_TRACKING_TRIVIAL_QUESTS or MINIMAP_TRACKING_HIDDEN_QUESTS)) then
			return active
		end
	end
end

local function GetQuestLogQuests(onlyComplete)
	local quests = {}
	for index = 1, GetNumQuestLogEntries() do
		local title, _, _, isHeader, _, isComplete, _, questID = GetQuestLogTitle(index)
		if (not isHeader) then
			if (onlyComplete and isComplete or not onlyComplete) then
				quests[title] = questID
			end
		end
	end

	return quests
end

AutoQuest:Register("QUEST_GREETING", function()
	local npcID = GetNPCID()
	if (K.IgnoreQuestNPC[npcID]) then
		return
	end

	local active = GetNumActiveQuests()
	if (active > 0) then
		local logQuests = GetQuestLogQuests(true)
		for index = 1, active do
			local name, complete = GetActiveTitle(index)
			if (complete) then
				local questID = logQuests[name]
				if (not questID) then
					SelectActiveQuest(index)
				else
					local _, _, worldQuest = GetQuestTagInfo(questID)
					if (not worldQuest) then
						SelectActiveQuest(index)
					end
				end
			end
		end
	end

	local available = GetNumAvailableQuests()
	if (available > 0) then
		for index = 1, available do
			local isTrivial, _, _, _, isIgnored = GetAvailableQuestInfo(index)
			if ((not isTrivial and not isIgnored) or IsTrackingHidden()) then
				SelectAvailableQuest(index)
			end
		end
	end
end)

local function GetAvailableGossipQuestInfo(index)
	local name, level, isTrivial, frequency, isRepeatable, isLegendary, isIgnored = select(((index * 7) - 7) + 1, GetGossipAvailableQuests())
	return name, level, isTrivial, isIgnored, isRepeatable, frequency == 2, frequency == 3, isLegendary
end

local function GetActiveGossipQuestInfo(index)
	local name, level, isTrivial, isComplete, isLegendary, isIgnored = select(((index * 6) - 6) + 1, GetGossipActiveQuests())
	return name, level, isTrivial, isIgnored, isComplete, isLegendary
end

AutoQuest:Register("GOSSIP_SHOW", function()
	local npcID = GetNPCID()
	if (K.IgnoreQuestNPC[npcID]) then
		return
	end

	local active = GetNumGossipActiveQuests()
	if (active > 0) then
		local logQuests = GetQuestLogQuests(true)
		for index = 1, active do
			local name, _, _, _, completed = GetActiveGossipQuestInfo(index)
			if (completed) then
				local questID = logQuests[name]
				if (not questID) then
					SelectGossipActiveQuest(index)
				else
					local _, _, worldQuest = GetQuestTagInfo(questID)
					if (not worldQuest) then
						SelectGossipActiveQuest(index)
					end
				end
			end
		end
	end

	local available = GetNumGossipAvailableQuests()
	if (available > 0) then
		for index = 1, available do
			local _, _, trivial, ignored = GetAvailableGossipQuestInfo(index)
			if ((not trivial and not ignored) or IsTrackingHidden()) then
				SelectGossipAvailableQuest(index)
			elseif (trivial and npcID == 64337 and AutoQuestDB.Nomi) then
				SelectGossipAvailableQuest(index)
			end
		end
	end

	if (K.RogueClassHallInsignia[npcID]) then
		return SelectGossipOption(1)
	end

	if (K.DarkmoonDailyNPCs[npcID] and active == 1 and not select(5, GetActiveGossipQuestInfo(1))) then
		-- auto-start the daily interaction
		for index = 1, GetNumGossipOptions() do
			if (string_find((select((index * 2) - 1, GetGossipOptions())), "FF0008E8")) then
				-- matching by the blue text color is sufficient
				return SelectGossipOption(index)
			end
		end
	end

	if (available == 0 and active == 0 and GetNumGossipOptions() == 1) then
		if (string_match((GetGossipOptions()), TRACKER_HEADER_PROVINGGROUNDS)) then
			-- ignore proving grounds queue
			return
		end

		if (AutoQuestDB.FairePort) then
			if (npcID == 57850) then
				return SelectGossipOption(1)
			end
		end

		if (AutoQuestDB.Gossip) then
			local _, instanceType, _, _, _, _, _, instanceMapID = GetInstanceInfo()
			if (AutoQuestDB.Withered and instanceType == "scenario" and instanceMapID == 1626) then
				return
			end

			if (instanceType == "raid" and AutoQuestDB.GossipRaid > 0) then
				if (GetNumGroupMembers() > 1 and AutoQuestDB.GossipRaid < 2) then
					return
				end

				SelectGossipOption(1)
			elseif (instanceType ~= "raid" and not K.IgnoreGossipNPC[npcID]) then
				SelectGossipOption(1)
			end
		end
	end
end)

AutoQuest:Register("GOSSIP_CONFIRM", function(index)
	if (not AutoQuestDB.FairePort) then return end

	local npcID = GetNPCID()
	if (npcID and K.DarkmoonNPC[npcID]) then
		SelectGossipOption(index, "", true)
		StaticPopup_Hide("GOSSIP_CONFIRM")
	end
end)

QuestFrame:UnregisterEvent("QUEST_DETAIL")
AutoQuest:Register("QUEST_DETAIL", function(...)
	if (not QuestGetAutoAccept() and not QuestIsFromAreaTrigger() and not K.AutoQuestBlacklistDB[GetQuestID()]) then
		QuestFrame_OnEvent(QuestFrame, "QUEST_DETAIL", ...)
	end
end, true)

AutoQuest:Register("QUEST_DETAIL", function(questStartItemID)
	if (QuestGetAutoAccept() or (questStartItemID ~= nil and questStartItemID ~= 0)) then
		AcknowledgeAutoAcceptQuest()
	else
		-- XXX: no way to tell if the quest is trivial
		AcceptQuest()
	end
end)

local function AttemptAutoComplete(event)
	if (GetNumAutoQuestPopUps() > 0) then
		if (UnitIsDeadOrGhost("player")) then
			AutoQuest:Register("PLAYER_REGEN_ENABLED", AttemptAutoComplete)
			return
		end

		local questID, popUpType = GetAutoQuestPopUp(1)
		if (popUpType == "OFFER") then
			ShowQuestOffer(GetQuestLogIndexByID(questID))
		else
			ShowQuestComplete(GetQuestLogIndexByID(questID))
		end
	else
		C_Timer_After(1, AttemptAutoComplete)
	end

	if (event == "PLAYER_REGEN_ENABLED") then
		AutoQuest:UnregisterEvent("PLAYER_REGEN_ENABLED")
	end
end

AutoQuest:Register("PLAYER_LOGIN", AttemptAutoComplete)
AutoQuest:Register("QUEST_AUTOCOMPLETE", AttemptAutoComplete)
AutoQuest:Register("QUEST_ACCEPT_CONFIRM", AcceptQuest)

AutoQuest:Register("QUEST_ACCEPTED", function(id)
	if (AutoQuestDB.Share) then
		QuestLogPushQuest(id)
	end
end)

local choiceQueue
AutoQuest:Register("QUEST_ITEM_UPDATE", function()
	if (choiceQueue and AutoQuest[choiceQueue]) then
		AutoQuest[choiceQueue]()
	end
end, true)

AutoQuest:Register("QUEST_PROGRESS", function()
	if (IsQuestCompletable()) then
		local requiredItems = GetNumQuestItems()
		if (requiredItems > 0) then
			for index = 1, requiredItems do
				local link = GetQuestItemLink("required", index)
				if (link) then
					local id = GetItemInfoFromHyperlink(link)
					for _, itemID in next, K.AutoQuestBlacklistDB.items do
						if (itemID == id) then
							return
						end
					end
				else
					choiceQueue = "QUEST_PROGRESS"
					return
				end
			end
		end

		CompleteQuest()
	end
end)

AutoQuest:Register("QUEST_COMPLETE", function()
	local choices = GetNumQuestChoices()
	if (choices <= 1) then
		GetQuestReward(1)
	end
end)

AutoQuest:Register("QUEST_COMPLETE", function()
	local choices = GetNumQuestChoices()
	if (choices > 1) then
		local bestValue, bestIndex = 0

		for index = 1, choices do
			local link = GetQuestItemLink("choice", index)
			if (link) then
				local _, _, _, _, _, _, _, _, _, _, value = GetItemInfo(link)
				value = K.CashRewards[(GetItemInfoFromHyperlink(link))] or value

				if (value > bestValue) then
					bestValue, bestIndex = value, index
				end
			else
				choiceQueue = "QUEST_COMPLETE"
				return GetQuestItemInfo("choice", index)
			end
		end

		if (bestIndex) then
			QuestInfoItem_OnClick(QuestInfoRewardsFrame.RewardButtons[bestIndex])
		end
	end
end, true)

local sub = string_sub
AutoQuest:Register("MODIFIER_STATE_CHANGED", function(key, state)
	if (sub(key, 2) == AutoQuestDB.Modifier) then
		modifier = state == 1
	end
end, true)