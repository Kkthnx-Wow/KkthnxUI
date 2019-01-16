local K, C, L = unpack(select(2, ...))

hooksecurefunc("QuestLogQuests_Update", function()
	for button in QuestScrollFrame.titleFramePool:EnumerateActive() do
		if button and button:IsShown() then
			local link = GetQuestLink(button.questID)
			if link then
				local level = strmatch(link, "quest:%d+:(%d+)")
				local title = button.Text:GetText()
				if level and title then
					local height = button.Text:GetHeight()
					button.Text:SetFormattedText("[%d] %s", level, title)
					button.Check:SetPoint("LEFT", button.Text, button.Text:GetWrappedWidth() + 2, 0)
					button:SetHeight(button:GetHeight() - height + button.Text:GetHeight())
				end
			end
		end
	end
end)
