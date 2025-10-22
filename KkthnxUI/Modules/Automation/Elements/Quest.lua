local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]

local next, ipairs, select = next, ipairs, select
local IsAltKeyDown = IsAltKeyDown
local UnitGUID, IsShiftKeyDown, GetItemInfoFromHyperlink = UnitGUID, IsShiftKeyDown, GetItemInfoFromHyperlink
local GetInstanceInfo, GetQuestID = GetInstanceInfo, GetQuestID
local GetNumActiveQuests, GetActiveTitle, GetActiveQuestID, SelectActiveQuest = GetNumActiveQuests, GetActiveTitle, GetActiveQuestID, SelectActiveQuest
local IsQuestCompletable, GetNumQuestItems, GetQuestItemLink, QuestIsFromAreaTrigger = IsQuestCompletable, GetNumQuestItems, GetQuestItemLink, QuestIsFromAreaTrigger
local QuestGetAutoAccept, AcceptQuest, CloseQuest, CompleteQuest, AcknowledgeAutoAcceptQuest = QuestGetAutoAccept, AcceptQuest, CloseQuest, CompleteQuest, AcknowledgeAutoAcceptQuest
local GetNumQuestChoices, GetQuestReward, GetQuestItemInfo = GetNumQuestChoices, GetQuestReward, GetQuestItemInfo
local GetNumAvailableQuests, GetAvailableQuestInfo, SelectAvailableQuest = GetNumAvailableQuests, GetAvailableQuestInfo, SelectAvailableQuest
local GetNumAutoQuestPopUps, GetAutoQuestPopUp, ShowQuestOffer, ShowQuestComplete = GetNumAutoQuestPopUps, GetAutoQuestPopUp, ShowQuestOffer, ShowQuestComplete
local C_QuestLog_IsWorldQuest = C_QuestLog.IsWorldQuest
local C_QuestLog_IsQuestTrivial = C_QuestLog.IsQuestTrivial
local C_QuestLog_GetQuestTagInfo = C_QuestLog.GetQuestTagInfo
local C_GossipInfo_GetOptions = C_GossipInfo.GetOptions
local C_GossipInfo_SelectOption = C_GossipInfo.SelectOption
local C_GossipInfo_GetActiveQuests = C_GossipInfo.GetActiveQuests
local C_GossipInfo_SelectActiveQuest = C_GossipInfo.SelectActiveQuest
local C_GossipInfo_GetAvailableQuests = C_GossipInfo.GetAvailableQuests
local C_GossipInfo_GetNumActiveQuests = C_GossipInfo.GetNumActiveQuests
local C_GossipInfo_SelectAvailableQuest = C_GossipInfo.SelectAvailableQuest
local C_GossipInfo_GetNumAvailableQuests = C_GossipInfo.GetNumAvailableQuests
local QuestLabelPrepend = Enum.GossipOptionRecFlags.QuestLabelPrepend

local choiceQueue

-- Minimap checkbox
local created
local function setupCheckButton()
	if created then
		return
	end
	local mono = CreateFrame("CheckButton", nil, WorldMapFrame.BorderFrame.TitleContainer, "OptionsBaseCheckButtonTemplate")
	mono:SetHitRectInsets(-5, -5, -5, -5)
	mono:SetPoint("TOPRIGHT", -140, 0)
	mono:SetSize(24, 24)
	mono:SetFrameLevel(999)
	mono.text = K.CreateFontString(mono, 12, "Auto Quest", "", "system", "LEFT", 24, 0)
	mono:SetChecked(KkthnxUIDB.Variables[K.Realm][K.Name].AutoQuest)
	mono:SetScript("OnClick", function(self)
		KkthnxUIDB.Variables[K.Realm][K.Name].AutoQuest = self:GetChecked()
	end)
	K.AddTooltip(mono, "ANCHOR_BOTTOMLEFT", "Automatically interact with quests.|n|nSingle-option gossip will be selected automatically.|n|nHold SHIFT to temporarily pause automation.|n|nTo block an NPC from auto-interaction, hold ALT and click their name in the Gossip or Quest frame.", "info", true)

	created = true
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
		if KkthnxUIDB.Variables[K.Realm][K.Name].AutoQuest and not IsShiftKeyDown() then
			func(...)
		end
	end
end

local function GetNPCID()
	return K.GetNPCID(UnitGUID("npc"))
end

local function IsAccountCompleted(questID)
	return C_Minimap.IsFilteredOut(Enum.MinimapTrackingFilter.AccountCompletedQuests) and C_QuestLog.IsQuestFlaggedCompletedOnAccount(questID)
end

C.IgnoreQuestNPC = {}

QuickQuest:Register("QUEST_GREETING", function()
	local npcID = GetNPCID()
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
			if not IsAccountCompleted(questID) and (not isTrivial or C_Minimap.IsTrackingHiddenQuests()) then
				SelectAvailableQuest(index)
			end
		end
	end
end)

local QUEST_STRING = "cFF0000FF.-" .. TRANSMOG_SOURCE_2

-- If any gossip option contains color codes or
-- angle-bracketed subtext (eg. Skip campaign), suspend automation.
local function ShouldSuspendForSkipGossip()
	local gossipInfoTable = C_GossipInfo_GetOptions()
	if not gossipInfoTable then
		return false
	end
	for i = 1, #gossipInfoTable do
		local nameText = gossipInfoTable[i].name
		if nameText then
			-- Explicit red "<...>" prefix used for Skip options
			if nameText:sub(1, 11) == "|cFFFF0000<" then
				return true
			end
			-- Any colored or angle-bracketed line (except known purple DMF quests)
			local upper = strupper(nameText)
			if (strfind(upper, "|C", 1, true) or strfind(upper, "<", 1, true)) and not strfind(nameText, "FF0008E8", 1, true) then
				return true
			end
		end
	end
	return false
end

QuickQuest:Register("GOSSIP_SHOW", function()
	local npcID = GetNPCID()
	if C.IgnoreQuestNPC[npcID] then
		return
	end

	local active = C_GossipInfo_GetNumActiveQuests()
	if active > 0 then
		for index, questInfo in ipairs(C_GossipInfo_GetActiveQuests()) do
			local questID = questInfo.questID
			local isWorldQuest = questID and C_QuestLog_IsWorldQuest(questID)
			if questInfo.isComplete and not isWorldQuest then
				C_GossipInfo_SelectActiveQuest(questID)
			end
		end
	end

	local available = C_GossipInfo_GetNumAvailableQuests()
	if available > 0 then
		for index, questInfo in ipairs(C_GossipInfo_GetAvailableQuests()) do
			local trivial = questInfo.isTrivial
			local questID = questInfo.questID
			if not IsAccountCompleted(questID) and (not trivial or C_Minimap.IsTrackingHiddenQuests() or (trivial and npcID == 64337)) then
				C_GossipInfo_SelectAvailableQuest(questInfo.questID)
			end
		end
	end

	local gossipInfoTable = C_GossipInfo_GetOptions()
	if not gossipInfoTable then
		return
	end

	if ShouldSuspendForSkipGossip() then
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

	-- 自动选择只有一个带有任务选项的任务
	local numQuestGossips = 0
	local questGossipID
	for i = 1, numOptions do
		local option = gossipInfoTable[i]
		if option.name and (strfind(option.name, QUEST_STRING) or option.flags == QuestLabelPrepend) then
			numQuestGossips = numQuestGossips + 1
			questGossipID = option.gossipOptionID
		end
	end
	if numQuestGossips == 1 then
		return C_GossipInfo_SelectOption(questGossipID)
	end
end)

QuickQuest:Register("GOSSIP_CONFIRM", function(index)
	if C["AutoQuestData"].SkipConfirmNPCs[GetNPCID()] then
		C_GossipInfo_SelectOption(index, "", true)
		StaticPopup_Hide("GOSSIP_CONFIRM")
	end
end)

QuickQuest:Register("QUEST_DETAIL", function()
	if QuestIsFromAreaTrigger() then
		AcceptQuest()
	elseif QuestGetAutoAccept() then
		AcknowledgeAutoAcceptQuest()
	elseif not C_QuestLog_IsQuestTrivial(GetQuestID()) or C_Minimap.IsTrackingHiddenQuests() then
		if not C.IgnoreQuestNPC[GetNPCID()] then
			AcceptQuest()
		end
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
		if C.IgnoreQuestNPC[npcID] then
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
				local value = select(11, C_Item.GetItemInfo(link))
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
			elseif popUpType == "COMPLETE" then
				ShowQuestComplete(questID)
			end
			RemoveAutoQuestPopUp(questID) -- needs review, taint?
		end
	end

	if event == "PLAYER_REGEN_ENABLED" then
		QuickQuest:UnregisterEvent(event)
	end
end
QuickQuest:Register("QUEST_LOG_UPDATE", AttemptAutoComplete)

-- Handle ignore list
local function UpdateIgnoreList()
	wipe(C.IgnoreQuestNPC)

	for npcID, value in pairs(C["AutoQuestData"].IgnoreQuestNPC) do
		C.IgnoreQuestNPC[npcID] = value
	end

	for npcID, value in pairs(KkthnxUIDB.Variables[K.Realm][K.Name].AutoQuestIgnoreNPC) do
		if value and C["AutoQuestData"].IgnoreQuestNPC[npcID] then
			KkthnxUIDB.Variables[K.Realm][K.Name].AutoQuestIgnoreNPC[npcID] = nil
		else
			C.IgnoreQuestNPC[npcID] = value
		end
	end
end

local function UnitQuickQuestStatus(self)
	if not self.__ignore then
		local frame = CreateFrame("Frame", nil, self)
		frame:SetSize(100, 14)
		frame:SetPoint("TOP", self, "BOTTOM", 0, -6)
		K.AddTooltip(frame, "ANCHOR_RIGHT", L["AutoQuest Ignored Tooltip"], "info", true)
		K.CreateFontString(frame, 14, IGNORED):SetTextColor(1, 0, 0)

		self.__ignore = frame

		UpdateIgnoreList()
	end

	local npcID = GetNPCID()
	local isIgnored = KkthnxUIDB.Variables[K.Realm][K.Name].AutoQuest and npcID and C.IgnoreQuestNPC[npcID]
	self.__ignore:SetShown(isIgnored)
end

local function ToggleQuickQuestStatus(self)
	if not self.__ignore then
		return
	end
	if not KkthnxUIDB.Variables[K.Realm][K.Name].AutoQuest then
		return
	end
	if not IsAltKeyDown() then
		return
	end

	self.__ignore:SetShown(not self.__ignore:IsShown())
	local npcID = GetNPCID()
	if self.__ignore:IsShown() then
		if C["AutoQuestData"].IgnoreQuestNPC[npcID] then
			KkthnxUIDB.Variables[K.Realm][K.Name].AutoQuestIgnoreNPC[npcID] = nil
		else
			KkthnxUIDB.Variables[K.Realm][K.Name].AutoQuestIgnoreNPC[npcID] = true
		end
	else
		if C["AutoQuestData"].IgnoreQuestNPC[npcID] then
			KkthnxUIDB.Variables[K.Realm][K.Name].AutoQuestIgnoreNPC[npcID] = false
		else
			KkthnxUIDB.Variables[K.Realm][K.Name].AutoQuestIgnoreNPC[npcID] = nil
		end
	end

	UpdateIgnoreList()
end

QuestNpcNameFrame:HookScript("OnShow", UnitQuickQuestStatus)
QuestNpcNameFrame:HookScript("OnMouseDown", ToggleQuickQuestStatus)
local frame = GossipFrame.TitleContainer
if frame then
	GossipFrameCloseButton:SetFrameLevel(frame:GetFrameLevel() + 1) -- fix clicking on gossip close button
	frame:HookScript("OnShow", UnitQuickQuestStatus)
	frame:HookScript("OnMouseDown", ToggleQuickQuestStatus)
end
