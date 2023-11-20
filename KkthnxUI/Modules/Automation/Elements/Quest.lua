local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]

local next, ipairs, select = next, ipairs, select

local C_GossipInfo_GetActiveQuests = C_GossipInfo.GetActiveQuests
local C_GossipInfo_GetAvailableQuests = C_GossipInfo.GetAvailableQuests
local C_GossipInfo_GetNumActiveQuests = C_GossipInfo.GetNumActiveQuests
local C_GossipInfo_GetNumAvailableQuests = C_GossipInfo.GetNumAvailableQuests
local C_GossipInfo_GetOptions = C_GossipInfo.GetOptions
local C_GossipInfo_SelectActiveQuest = C_GossipInfo.SelectActiveQuest
local C_GossipInfo_SelectAvailableQuest = C_GossipInfo.SelectAvailableQuest
local C_GossipInfo_SelectOption = C_GossipInfo.SelectOption
local C_QuestLog_GetQuestTagInfo = C_QuestLog.GetQuestTagInfo
local C_QuestLog_IsQuestTrivial = C_QuestLog.IsQuestTrivial
local C_QuestLog_IsWorldQuest = C_QuestLog.IsWorldQuest
local GetInstanceInfo, GetQuestID = GetInstanceInfo, GetQuestID
local GetNumActiveQuests, GetActiveTitle, GetActiveQuestID, SelectActiveQuest = GetNumActiveQuests, GetActiveTitle, GetActiveQuestID, SelectActiveQuest
local GetNumAutoQuestPopUps, GetAutoQuestPopUp, ShowQuestOffer, ShowQuestComplete = GetNumAutoQuestPopUps, GetAutoQuestPopUp, ShowQuestOffer, ShowQuestComplete
local GetNumAvailableQuests, GetAvailableQuestInfo, SelectAvailableQuest = GetNumAvailableQuests, GetAvailableQuestInfo, SelectAvailableQuest
local GetNumQuestChoices, GetQuestReward, GetItemInfo, GetQuestItemInfo = GetNumQuestChoices, GetQuestReward, GetItemInfo, GetQuestItemInfo
local GetNumTrackingTypes = C_Minimap.GetNumTrackingTypes
local GetTrackingInfo = C_Minimap.GetTrackingInfo
local IsAltKeyDown = IsAltKeyDown
local IsQuestCompletable, GetNumQuestItems, GetQuestItemLink, QuestIsFromAreaTrigger = IsQuestCompletable, GetNumQuestItems, GetQuestItemLink, QuestIsFromAreaTrigger
local MINIMAP_TRACKING_TRIVIAL_QUESTS = MINIMAP_TRACKING_TRIVIAL_QUESTS
local QuestGetAutoAccept, AcceptQuest, CloseQuest, CompleteQuest, AcknowledgeAutoAcceptQuest = QuestGetAutoAccept, AcceptQuest, CloseQuest, CompleteQuest, AcknowledgeAutoAcceptQuest
local QuestLabelPrepend = Enum.GossipOptionRecFlags.QuestLabelPrepend
local UnitGUID, IsShiftKeyDown, GetItemInfoFromHyperlink = UnitGUID, IsShiftKeyDown, GetItemInfoFromHyperlink

local choiceQueue

-- Minimap checkbox
local isCheckButtonCreated
local function setupCheckButton()
	if isCheckButtonCreated then
		return
	end

	local AutoQuestCheckButton = CreateFrame("CheckButton", nil, WorldMapFrame.BorderFrame.TitleContainer, "OptionsBaseCheckButtonTemplate")
	AutoQuestCheckButton:SetPoint("TOPRIGHT", -140, 0)
	AutoQuestCheckButton:SetSize(24, 24)

	AutoQuestCheckButton.text = AutoQuestCheckButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	AutoQuestCheckButton.text:SetPoint("LEFT", 24, 0)
	AutoQuestCheckButton.text:SetText(L["Auto Quest"])

	AutoQuestCheckButton:SetHitRectInsets(0, 0 - AutoQuestCheckButton.text:GetWidth(), 0, 0)
	AutoQuestCheckButton:SetChecked(KkthnxUIDB.Variables[K.Realm][K.Name].AutoQuest)
	AutoQuestCheckButton:SetScript("OnClick", function(self)
		KkthnxUIDB.Variables[K.Realm][K.Name].AutoQuest = self:GetChecked()
	end)

	isCheckButtonCreated = true

	function AutoQuestCheckButton.UpdateTooltip(self)
		if GameTooltip:IsForbidden() then
			return
		end

		GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, 10)

		local r, g, b = 0.2, 1.0, 0.2

		if KkthnxUIDB.Variables[K.Realm][K.Name].AutoQuest == true then
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
		if GameTooltip:IsForbidden() then
			return
		end

		self:UpdateTooltip()
	end)

	AutoQuestCheckButton:HookScript("OnLeave", function()
		if GameTooltip:IsForbidden() then
			return
		end

		GameTooltip:Hide()
	end)

	AutoQuestCheckButton:SetScript("OnClick", function(self)
		KkthnxUIDB.Variables[K.Realm][K.Name].AutoQuest = self:GetChecked()
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
		if KkthnxUIDB.Variables[K.Realm][K.Name].AutoQuest and not IsShiftKeyDown() then
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
			local isTrivial = GetAvailableQuestInfo(index)
			if not isTrivial or IsTrackingHidden() then
				SelectAvailableQuest(index)
			end
		end
	end
end)

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
			if not trivial or IsTrackingHidden() or (trivial and npcID == 64337) then
				C_GossipInfo_SelectAvailableQuest(questInfo.questID)
			end
		end
	end

	local gossipInfoTable = C_GossipInfo_GetOptions()
	if not gossipInfoTable then
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

	-- Automatically select a quest with only one quest option
	local numQuestGossips = 0
	local questGossipID

	for i = 1, numOptions do
		local option = gossipInfoTable[i]
		if option.name and (strfind(option.name, "cFF0000FF") or option.flags == QuestLabelPrepend) then
			numQuestGossips = numQuestGossips + 1
			questGossipID = option.gossipOptionID
		end
	end

	if numQuestGossips == 1 and questGossipID then
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
	elseif not C_QuestLog_IsQuestTrivial(GetQuestID()) or IsTrackingHidden() then
		if not C.IgnoreQuestNPC[GetNPCID()] then
			AcceptQuest()
		end
	end
end)

QuickQuest:Register("QUEST_ACCEPT_CONFIRM", AcceptQuest)

local CFG_AutoShareQuest = false -- Put this into our config later.
QuickQuest:Register("QUEST_ACCEPTED", function(questID)
	if QuestFrame:IsShown() and QuestGetAutoAccept() then
		CloseQuest()
	end

	if CFG_AutoShareQuest then
		-- Check if the player is in a group (1-5 players)
		local isInGroup = IsInGroup(LE_PARTY_CATEGORY_HOME)

		-- Check if the player is not in a raid
		local notInRaid = not IsInRaid()

		if isInGroup and notInRaid then
			local questLogIndex = C_QuestLog.GetLogIndexForQuestID(questID)
			if questLogIndex then
				-- print("Auto-sharing quest:", questID)
				QuestLogPushQuest(questLogIndex)
			else
				-- print("QuestLog index not found for quest:", questID)
			end
		else
			-- print("Not auto-sharing quest in raid or not in a group.")
		end
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
		local bestValue = 0
		local bestIndex

		for index = 1, choices do
			local link = GetQuestItemLink("choice", index)
			if link then
				local value = select(11, GetItemInfo(link))
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
		frame:SetPoint("TOP", self, "BOTTOM", 0, -2)
		K.AddTooltip(frame, "ANCHOR_RIGHT", "You no longer auto interact quests with current NPC. You can hold key ALT and click the name above to undo this.", "info", true)
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
