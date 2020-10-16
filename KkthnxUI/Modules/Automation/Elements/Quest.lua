local K, _, L = unpack(select(2, ...))

local _G = _G
local ipairs = _G.ipairs
local next = _G.next

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
local C_QuestLog_GetQuestTagInfo = _G.C_QuestLog.GetQuestTagInfo
local C_QuestLog_IsWorldQuest = _G.C_QuestLog.IsWorldQuest
local CloseQuest = _G.CloseQuest
local CompleteQuest = _G.CompleteQuest
local GetActiveQuestID = _G.GetActiveQuestID
local GetActiveTitle = _G.GetActiveTitle
local GetAutoQuestPopUp = _G.GetAutoQuestPopUp
local GetAvailableQuestInfo = _G.GetAvailableQuestInfo
local GetInstanceInfo = _G.GetInstanceInfo
local GetItemInfo = _G.GetItemInfo
local GetItemInfoFromHyperlink = _G.GetItemInfoFromHyperlink
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

local choiceQueue

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
		if name == MINIMAP_TRACKING_TRIVIAL_QUESTS then
			return active
		end
	end
end

QuickQuest:Register("QUEST_GREETING", function()
	local npcID = GetNPCID()
	if K.IgnoreQuestNPC[npcID] then
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
			local isTrivial = GetAvailableQuestInfo(index)
			if not isTrivial or IsTrackingHidden() then
				SelectAvailableQuest(index)
			end
		end
	end
end)

QuickQuest:Register("GOSSIP_SHOW", function()
	local npcID = GetNPCID()
	if K.IgnoreQuestNPC[npcID] then
		return
	end

	local active = C_GossipInfo_GetNumActiveQuests()
	if active > 0 then
		for index, questInfo in ipairs(C_GossipInfo_GetActiveQuests()) do
			local questID = questInfo.questID
			local isWorldQuest = questID and C_QuestLog_IsWorldQuest(questID)
			if questInfo.isComplete and (not questID or not isWorldQuest) then
				C_GossipInfo_SelectActiveQuest(index)
			end
		end
	end

	local available = C_GossipInfo_GetNumAvailableQuests()
	if available > 0 then
		for index, questInfo in ipairs(C_GossipInfo_GetAvailableQuests()) do
			local trivial = questInfo.isTrivial
			if not trivial or IsTrackingHidden() or (trivial and npcID == 64337) then
				C_GossipInfo_SelectAvailableQuest(index)
			end
		end
	end

	if K.RogueClassHallInsignia[npcID] then
		return C_GossipInfo_SelectOption(1)
	end

	if available == 0 and active == 0 then
		local numOptions = C_GossipInfo_GetNumOptions()
		if numOptions == 1 then
			if npcID == 57850 then
				return C_GossipInfo_SelectOption(1)
			end

			local _, instance, _, _, _, _, _, mapID = GetInstanceInfo()
			if instance ~= "raid" and not K.IgnoreGossipNPC[npcID] and not (instance == "scenario" and mapID == 1626) then
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
	if npcID and K.DarkmoonNPC[npcID] then
		C_GossipInfo_SelectOption(index, "", true)
		StaticPopup_Hide("GOSSIP_CONFIRM")
	end
end)

QuickQuest:Register("QUEST_DETAIL", function()
	if not QuestGetAutoAccept() then
		AcceptQuest()
	end
end)

QuickQuest:Register("QUEST_ACCEPT_CONFIRM", AcceptQuest)

QuickQuest:Register("QUEST_ACCEPTED", function()
	if QuestFrame:IsShown() and QuestGetAutoAccept() then
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
		local info = C_QuestLog_GetQuestTagInfo(GetQuestID())
		if info and (info.tagID == 153 or info.worldQuestType) then
			return
		end

		local npcID = GetNPCID()
		if K.IgnoreProgressNPC[npcID] then
			return
		end

		local requiredItems = GetNumQuestItems()
		if requiredItems > 0 then
			for index = 1, requiredItems do
				local link = GetQuestItemLink("required", index)
				if link then
					local id = GetItemInfoFromHyperlink(link)
					for _, itemID in next, K.ItemBlacklist do
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
	-- Blingtron 6000 only!
	local npcID = GetNPCID()
	if npcID == 43929 or npcID == 77789 then
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
				local value = select(11, GetItemInfo(link))
				local itemID = GetItemInfoFromHyperlink(link)
				value = K.CashRewards[itemID] or value

				if value > bestValue then
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
	if GetNumAutoQuestPopUps() > 0 then
		if UnitIsDeadOrGhost("player") then
			QuickQuest:Register("PLAYER_REGEN_ENABLED", AttemptAutoComplete)
			return
		end

		local questID, popUpType = GetAutoQuestPopUp(1)
		if not C_QuestLog_IsWorldQuest(questID) then
			if popUpType == "OFFER" then
				ShowQuestOffer(questID)
			else
				ShowQuestComplete(questID)
			end
		end
	end

	if event == "PLAYER_REGEN_ENABLED" then
		QuickQuest:UnregisterEvent(event)
	end
end
QuickQuest:Register("QUEST_LOG_UPDATE", AttemptAutoComplete)