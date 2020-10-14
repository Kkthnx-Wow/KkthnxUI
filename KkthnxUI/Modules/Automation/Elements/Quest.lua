local K, C, L = unpack(select(2, ...))

local _G = _G
local ipairs = _G.ipairs
local next = _G.next
local string_match = _G.string.match
local tonumber = _G.tonumber
local wipe = _G.wipe

local AcceptQuest = _G.AcceptQuest
local C_GossipInfo_GetActiveQuests = _G.C_GossipInfo.GetActiveQuests
local C_GossipInfo_GetAvailableQuests = _G.C_GossipInfo.GetAvailableQuests
local C_GossipInfo_GetNumActiveQuests = _G.C_GossipInfo.GetNumActiveQuests
local C_GossipInfo_GetNumAvailableQuests = _G.C_GossipInfo.GetNumAvailableQuests
local C_GossipInfo_GetNumOptions = _G.C_GossipInfo.GetNumOptions
local C_GossipInfo_GetOptions = _G.C_GossipInfo.GetOptions
local C_GossipInfo_SelectActiveQuest = _G.C_GossipInfo.SelectActiveQuest
local C_GossipInfo_SelectAvailableQuest = _G.C_GossipInfo.SelectAvailableQuest
local C_GossipInfo_SelectOption = _G.C_GossipInfo.SelectOption
local C_QuestLog_GetInfo = _G.C_QuestLog.GetInfo
local C_QuestLog_GetLogIndexForQuestID = _G.C_QuestLog.GetLogIndexForQuestID
local C_QuestLog_GetNumQuestLogEntries = _G.C_QuestLog.GetNumQuestLogEntries
local C_QuestLog_GetQuestTagInfo = _G.C_QuestLog.GetQuestTagInfo
local C_QuestLog_IsComplete = _G.C_QuestLog.IsComplete
local C_Timer_After = _G.C_Timer.After
local CloseQuest = _G.CloseQuest
local CompleteQuest = _G.CompleteQuest
local GetActiveTitle = _G.GetActiveTitle
local GetAutoQuestPopUp = _G.GetAutoQuestPopUp
local GetAvailableQuestInfo = _G.GetAvailableQuestInfo
local GetInstanceInfo = _G.GetInstanceInfo
local GetItemInfo = _G.GetItemInfo
local GetNumActiveQuests = _G.GetNumActiveQuests
local GetNumAutoQuestPopUps = _G.GetNumAutoQuestPopUps
local GetNumAvailableQuests = _G.GetNumAvailableQuests
local GetNumQuestChoices = _G.GetNumQuestChoices
local GetNumQuestItems = _G.GetNumQuestItems
local GetNumTrackingTypes = _G.GetNumTrackingTypes
local GetQuestID = _G.GetQuestID
local GetQuestItemInfo = _G.GetQuestItemInfo
local GetQuestItemLink = _G.GetQuestItemLink
local GetQuestReward = _G.GetQuestReward
local GetTrackingInfo = _G.GetTrackingInfo
local IsQuestCompletable = _G.IsQuestCompletable
local IsShiftKeyDown = _G.IsShiftKeyDown
local MINIMAP_TRACKING_TRIVIAL_QUESTS = _G.MINIMAP_TRACKING_TRIVIAL_QUESTS
local QuestGetAutoAccept = _G.QuestGetAutoAccept
local SelectActiveQuest = _G.SelectActiveQuest
local SelectAvailableQuest = _G.SelectAvailableQuest
local ShowQuestComplete = _G.ShowQuestComplete
local ShowQuestOffer = _G.ShowQuestOffer
local UnitGUID = _G.UnitGUID
local UnitIsDeadOrGhost = _G.UnitIsDeadOrGhost

local quests, choiceQueue = {}

-- Minimap checkbox
local isCheckButtonCreated
local function setupCheckButton()
	if isCheckButtonCreated then
		return
	end

	local AutoQuestCheckButton = CreateFrame("CheckButton", nil, WorldMapFrame.BorderFrame, "OptionsCheckButtonTemplate")
	AutoQuestCheckButton:SetPoint("TOPRIGHT", -140, 0)
	AutoQuestCheckButton:SetSize(24, 24)

	AutoQuestCheckButton.text = AutoQuestCheckButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	AutoQuestCheckButton.text:SetPoint("LEFT", 24, 0)
	AutoQuestCheckButton.text:SetText(L["Auto Quest"])

	AutoQuestCheckButton:SetHitRectInsets(0, 0 - AutoQuestCheckButton.text:GetWidth(), 0, 0)
	AutoQuestCheckButton:SetChecked(KkthnxUIData[K.Realm][K.Name].AutoQuest)
	AutoQuestCheckButton:SetScript("OnClick", function(self)
		KkthnxUIData[K.Realm][K.Name].AutoQuest = self:GetChecked()
	end)

	isCheckButtonCreated = true

	function AutoQuestCheckButton.UpdateTooltip(self)
		if (GameTooltip:IsForbidden()) then
			return
		end

		GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, 10)

		local r, g, b = 0.2, 1.0, 0.2

		if KkthnxUIData[K.Realm][K.Name].AutoQuest == true then
			GameTooltip:AddLine(L["Auto Quest Enabled"])
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(L["Auto Quest Enabled Desc"], r, g, b)
		else
			GameTooltip:AddLine(L["Auto Quest Disabled"])
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(L["Auto Quest Disabled Desc"], r, g, b)
		end

		GameTooltip:Show()
	end

	AutoQuestCheckButton:HookScript("OnEnter", function(self)
		if (GameTooltip:IsForbidden()) then
			return
		end

		self:UpdateTooltip()
	end)

	AutoQuestCheckButton:HookScript("OnLeave", function()
		if (GameTooltip:IsForbidden()) then
			return
		end

		GameTooltip:Hide()
	end)

	AutoQuestCheckButton:SetScript("OnClick", function(self)
		KkthnxUIData[K.Realm][K.Name].AutoQuest = self:GetChecked()
	end)
end
WorldMapFrame:HookScript("OnShow", setupCheckButton)

-- Main
local QuickQuest = CreateFrame("Frame")
QuickQuest:SetScript("OnEvent", function(self, event, ...)
	self[event](...)
end)

function QuickQuest:Register(event, func)
	self:RegisterEvent(event)
	self[event] = function(...)
		if KkthnxUIData[K.Realm][K.Name].AutoQuest and not IsShiftKeyDown() then
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
	wipe(quests)

	for index = 1, C_QuestLog_GetNumQuestLogEntries() do
		local info = C_QuestLog_GetInfo(index)
		local title = info.title
		local questID = info.questID
		local isHeader = info.isHeader
		local isComplete = C_QuestLog_IsComplete(questID)
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
					local _, _, worldQuest = C_QuestLog_GetQuestTagInfo(questID)
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

QuickQuest:Register("GOSSIP_SHOW", function()
	local npcID = GetNPCID()
	if (K.IgnoreQuestNPC[npcID]) then
		return
	end

	local active = C_GossipInfo_GetNumActiveQuests()
	if (active > 0) then
		local gossipQuests = C_GossipInfo_GetActiveQuests()
		for index, questInfo in ipairs(gossipQuests) do
			local complete, questID = questInfo.isComplete, questInfo.questID
			if (complete) then
				if (not questID) then
					C_GossipInfo_SelectActiveQuest(index)
				else
					local _, _, worldQuest = C_QuestLog_GetQuestTagInfo(questID)
					if(not worldQuest) then
						C_GossipInfo_SelectActiveQuest(index)
					end
				end
			end
		end
	end

	local available = C_GossipInfo_GetNumAvailableQuests()
	if (available > 0) then
		local GossipQuests = C_GossipInfo_GetAvailableQuests()
		for index, questInfo in ipairs(GossipQuests) do
			local trivial, ignored = questInfo.isTrivial, questInfo.isIgnored
			if ((not trivial and not ignored) or IsTrackingHidden()) then
				C_GossipInfo_SelectAvailableQuest(index)
			elseif (trivial and npcID == 64337) then
				C_GossipInfo_SelectAvailableQuest(index)
			end
		end
	end

	if (K.RogueClassHallInsignia[npcID]) then
		return C_GossipInfo_SelectOption(1)
	end

	if (available == 0 and active == 0) then
		local numOptions = C_GossipInfo_GetNumOptions()
		if numOptions == 1 then
			if (npcID == 57850) then
				return C_GossipInfo_SelectOption(1)
			end

			local _, instance, _, _, _, _, _, mapID = GetInstanceInfo()
			if (instance ~= "raid" and not K.IgnoreGossipNPC[npcID] and not (instance == "scenario" and mapID == 1626)) then
				local gossipInfoTable = C_GossipInfo_GetOptions()
				if gossipInfoTable[1].type == "gossip" then
					C_GossipInfo_SelectOption(1)
					return
				end
			end
		elseif K.FollowerAssignees[npcID] and numOptions > 1 then
			return C_GossipInfo_SelectOption(1)
		end
	end
end)

QuickQuest:Register("GOSSIP_CONFIRM", function(index)
	local npcID = GetNPCID()
	if (npcID and K.DarkmoonNPC[npcID]) then
		C_GossipInfo_SelectOption(index, "", true)
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
		local id, _, worldQuest = C_QuestLog_GetQuestTagInfo(GetQuestID())
		if id == 153 or worldQuest then
			return
		end

		local npcID = GetNPCID()
		if K.IgnoreProgressNPC[npcID] then
			return
		end

		local requiredItems = GetNumQuestItems()
		if (requiredItems > 0) then
			for index = 1, requiredItems do
				local link = GetQuestItemLink("required", index)
				if (link) then
					local id = tonumber(string_match(link, "item:(%d+)"))
					for _, itemID in next, K.ItemBlacklist do
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
	-- Blingtron 6000 only!
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
				value = K.CashRewards[tonumber(string_match(link, "item:(%d+):"))] or value

				if(value > bestValue) then
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
		local _, _, worldQuest = C_QuestLog_GetQuestTagInfo(questID)
		if not worldQuest then
			local questLogIndex = C_QuestLog_GetLogIndexForQuestID(questID)
			if (popUpType == "OFFER") then
				ShowQuestOffer(questLogIndex)
			else
				ShowQuestComplete(questLogIndex)
			end
		end
	else
		C_Timer_After(1, AttemptAutoComplete)
	end

	if(event == "PLAYER_REGEN_ENABLED") then
		QuickQuest:UnregisterEvent("PLAYER_REGEN_ENABLED")
	end
end
QuickQuest:Register("PLAYER_LOGIN", AttemptAutoComplete)
QuickQuest:Register("QUEST_AUTOCOMPLETE", AttemptAutoComplete)