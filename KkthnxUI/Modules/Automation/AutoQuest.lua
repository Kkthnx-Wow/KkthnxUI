local K, C = unpack(select(2, ...))
if C["Automation"].AutoQuest ~= true then
	return
end

local _G = _G
local next = next
local select = select
local string_match = string.match
local tonumber = tonumber
local table_wipe = table.wipe

local IsShiftKeyDown = _G.IsShiftKeyDown
local AcceptQuest = _G.AcceptQuest
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
local GetNumActiveQuests = _G.GetNumActiveQuests
local GetNumAutoQuestPopUps = _G.GetNumAutoQuestPopUps
local GetNumAvailableQuests = _G.GetNumAvailableQuests
local GetNumGossipActiveQuests = _G.GetNumGossipActiveQuests
local GetNumGossipAvailableQuests = _G.GetNumGossipAvailableQuests
local GetNumGossipOptions = _G.GetNumGossipOptions
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
local QuestGetAutoAccept = _G.QuestGetAutoAccept
local QuestInfoItem_OnClick = _G.QuestInfoItem_OnClick
local SelectActiveQuest = _G.SelectActiveQuest
local SelectAvailableQuest = _G.SelectAvailableQuest
local SelectGossipActiveQuest = _G.SelectGossipActiveQuest
local SelectGossipAvailableQuest = _G.SelectGossipAvailableQuest
local SelectGossipOption = _G.SelectGossipOption
local ShowQuestComplete = _G.ShowQuestComplete
local ShowQuestOffer = _G.ShowQuestOffer
local StaticPopup_Hide = _G.StaticPopup_Hide
local UnitGUID = _G.UnitGUID
local UnitIsDeadOrGhost = _G.UnitIsDeadOrGhost

function K.GetNPCID(guid)
	local id = tonumber(string_match((guid or ""), "%-(%d-)%-%x-$"))
	return id
end

local quests, choiceQueue = {}
local QuickQuest = CreateFrame("Frame")
QuickQuest:SetScript("OnEvent", function(self, event, ...)
	self[event](...)
end)

function QuickQuest:Register(event, func)
	self:RegisterEvent(event)
	self[event] = function(...)
		if C["Automation"].AutoQuest and not IsShiftKeyDown() then
			func(...)
		end
	end
end

local function GetNPCID()
	return K.GetNPCID(UnitGUID("npc"))
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
	table_wipe(quests)

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

QuickQuest:Register("QUEST_GREETING", function()
	local npcID = GetNPCID()
	if (K.QuickQuest_IgnoreQuestNPC[npcID]) then
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

-- This Should Be Part Of The Api, Really
local function GetAvailableGossipQuestInfo(index)
	local name, level, isTrivial, frequency, isRepeatable, isLegendary, isIgnored = select(((index * 7) - 7) + 1, GetGossipAvailableQuests())
	return name, level, isTrivial, isIgnored, isRepeatable, frequency == 2, frequency == 3, isLegendary
end

local function GetActiveGossipQuestInfo(index)
	local name, level, isTrivial, isComplete, isLegendary, isIgnored = select(((index * 6) - 6) + 1, GetGossipActiveQuests())
	return name, level, isTrivial, isIgnored, isComplete, isLegendary
end

QuickQuest:Register("GOSSIP_SHOW", function()
	local npcID = GetNPCID()
	if (K.QuickQuest_IgnoreQuestNPC[npcID]) then
		return
	end

	local active = GetNumGossipActiveQuests()
	if (active > 0) then
		local logQuests = GetQuestLogQuests(true)
		for index = 1, active do
			local name, _, _, _, complete = GetActiveGossipQuestInfo(index)
			if (complete) then
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
			elseif (trivial and npcID == 64337) then
				SelectGossipAvailableQuest(index)
			end
		end
	end

	if (K.QuickQuest_RogueClassHallInsignia[npcID]) then
		return SelectGossipOption(1)
	end

	if (available == 0 and active == 0) then
		if GetNumGossipOptions() == 1 then
			if (npcID == 57850) then
				return SelectGossipOption(1)
			end

			local _, instance, _, _, _, _, _, mapID = GetInstanceInfo()
			if (instance ~= "raid" and not K.QuickQuest_IgnoreGossipNPC[npcID] and not (instance == "scenario" and mapID == 1626)) then
				local _, type = GetGossipOptions()
				if (type == "gossip") then
					SelectGossipOption(1)
					return
				end
			end
		elseif K.QuickQuest_FollowerAssignees[npcID] and GetNumGossipOptions() > 1 then
			return SelectGossipOption(1)
		end
	end
end)

QuickQuest:Register("GOSSIP_CONFIRM", function(index)
	local npcID = GetNPCID()
	if (npcID and K.QuickQuest_DarkmoonNPC[npcID]) then
		SelectGossipOption(index, "", true)
		StaticPopup_Hide("GOSSIP_CONFIRM")
	end
end)

QuickQuest:Register("QUEST_DETAIL", function()
	if (not QuestGetAutoAccept()) then
		AcceptQuest()
	end
end)

QuickQuest:Register("QUEST_ACCEPT_CONFIRM", AcceptQuest)

QuickQuest:Register("QUEST_ACCEPTED", function()
	if (QuestFrame:IsShown() and QuestGetAutoAccept()) then
		CloseQuest()
	end
end)

QuickQuest:Register("QUEST_ITEM_UPDATE", function()
	if (choiceQueue and QuickQuest[choiceQueue]) then
		QuickQuest[choiceQueue]()
	end
end)

QuickQuest:Register("QUEST_PROGRESS", function()
	if (IsQuestCompletable()) then
		local id, _, worldQuest = GetQuestTagInfo(GetQuestID())
		if id == 153 or worldQuest then
			return
		end

		local npcID = GetNPCID()
		if K.QuickQuest_IgnoreProgressNPC [npcID] then
			return
		end

		local requiredItems = GetNumQuestItems()
		if (requiredItems > 0) then
			for index = 1, requiredItems do
				local link = GetQuestItemLink("required", index)
				if (link) then
					local id = tonumber(string_match(link, "item:(%d+)"))
					for _, itemID in next, K.QuickQuest_ItemBlacklist do
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

QuickQuest:Register("QUEST_COMPLETE", function()
	-- Blingtron 6000 Only!
	local npcID = GetNPCID()
	if npcID == 43929 or npcID == 77789 then
		return
	end

	local choices = GetNumQuestChoices()
	if (choices <= 1) then
		GetQuestReward(1)
	elseif (choices > 1) then
		local bestValue, bestIndex = 0

		for index = 1, choices do
			local link = GetQuestItemLink("choice", index)
			if (link) then
				local _, _, _, _, _, _, _, _, _, _, value = GetItemInfo(link)
				value = K.QuickQuest_CashRewards[tonumber(string_match(link, "item:(%d+):"))] or value

				if (value > bestValue) then
					bestValue, bestIndex = value, index
				end
			else
				choiceQueue = "QUEST_COMPLETE"
				return GetQuestItemInfo("choice", index)
			end
		end

		local button = bestIndex and QuestInfoRewardsFrame.RewardButtons[bestIndex]
		if button then
			QuestInfoItem_OnClick(button)
		end
	end
end)

local function AttemptAutoComplete(event)
	if (GetNumAutoQuestPopUps() > 0) then
		if (UnitIsDeadOrGhost("player")) then
			QuickQuest:Register("PLAYER_REGEN_ENABLED", AttemptAutoComplete)
			return
		end

		local questID, popUpType = GetAutoQuestPopUp(1)
		local _, _, worldQuest = GetQuestTagInfo(questID)
		if not worldQuest then
			if (popUpType == "OFFER") then
				ShowQuestOffer(GetQuestLogIndexByID(questID))
			else
				ShowQuestComplete(GetQuestLogIndexByID(questID))
			end
		end
	else
		C_Timer_After(1, AttemptAutoComplete)
	end

	if (event == "PLAYER_REGEN_ENABLED") then
		QuickQuest:UnregisterEvent("PLAYER_REGEN_ENABLED")
	end
end
QuickQuest:Register("PLAYER_LOGIN", AttemptAutoComplete)
QuickQuest:Register("QUEST_AUTOCOMPLETE", AttemptAutoComplete)