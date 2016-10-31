local K, C, L = select(2, ...):unpack()

local pairs = pairs

local hooksecurefunc = hooksecurefunc
local IsAltKeyDown, IsControlKeyDown = IsAltKeyDown, IsControlKeyDown

-- Quest level(by fgprodigal)
hooksecurefunc("QuestLogQuests_Update", function()
	if ENABLE_COLORBLIND_MODE == "1" then return end

	local numEntries, numQuests = GetNumQuestLogEntries()
	local titleIndex = 1

	for i = 1, numEntries do
		local title, level, suggestedGroup, isHeader, isCollapsed, isComplete, frequency, questID, startEvent, displayQuestID, isOnMap, hasLocalPOI, isTask, isStory = GetQuestLogTitle(i)
		local titleButton = QuestLogQuests_GetTitleButton(titleIndex)
		if title and (not isHeader) and titleButton.questID == questID then
			titleButton.Text:SetText("[" .. level .. "] " .. title)
			titleButton.Check:SetPoint("LEFT", titleButton.Text, titleButton.Text:GetWrappedWidth() + 2, 0)
			titleIndex = titleIndex + 1
		end
	end
end)

-- Ctrl+click to abandon a quest or alt+click to share a quest(by suicidal katt)
hooksecurefunc("QuestMapLogTitleButton_OnClick", function(self)
	local questLogIndex = GetQuestLogIndexByID(self.questID)
	if IsControlKeyDown() then
		QuestMapQuestOptions_AbandonQuest(self.questID)
	elseif IsAltKeyDown() and GetQuestLogPushable(questLogIndex) then
		QuestMapQuestOptions_ShareQuest(self.questID)
	end
end)

hooksecurefunc(QUEST_TRACKER_MODULE, "OnBlockHeaderClick", function(block)
	local questLogIndex = block.questLogIndex
	if IsControlKeyDown() then
		local items = GetAbandonQuestItems()
		if items then
			StaticPopup_Hide("ABANDON_QUEST")
			StaticPopup_Show("ABANDON_QUEST_WITH_ITEMS", GetAbandonQuestName(), items)
		else
			StaticPopup_Hide("ABANDON_QUEST_WITH_ITEMS")
			StaticPopup_Show("ABANDON_QUEST", GetAbandonQuestName())
		end
	elseif IsAltKeyDown() and GetQuestLogPushable(questLogIndex) then
		QuestLogPushQuest(questLogIndex)
	end
end)