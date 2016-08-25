local K, C, L, _ = select(2, ...):unpack()

local pairs = pairs
local strmatch = string.match

local hooksecurefunc = hooksecurefunc
local IsAltKeyDown, IsControlKeyDown = IsAltKeyDown, IsControlKeyDown

-- QUEST LEVEL(YQUESTLEVEL BY YLEAF)
hooksecurefunc("QuestLogQuests_Update", function()
	for i, button in pairs(QuestMapFrame.QuestsFrame.Contents.Titles) do
		if button:IsShown() then
			local level = strmatch(GetQuestLink(button.questLogIndex), "quest:%d+:(%d+)")
			if level then
				local height = button.Text:GetHeight()
				button.Text:SetFormattedText("[%d] %s", level, button.Text:GetText())
				button.Check:SetPoint("LEFT", button.Text, button.Text:GetWrappedWidth() + 2, 0)
				button:SetHeight(button:GetHeight() - height + button.Text:GetHeight())
			end
		end
	end
end)

-- CTRL+CLICK TO ABANDON A QUEST OR ALT+CLICK TO SHARE A QUEST(BY SUICIDAL KATT)
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