local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("AutoReward", "AceEvent-3.0")

-- Sourced: ElvUI Shadow & Light (Darth_Predator, Repooc)

function Module:SelectQuestReward(index)
	local frame = QuestInfoFrame.rewardsFrame;

	local button = QuestInfo_GetRewardButton(frame, index)
	if (button.type == "choice") then
		QuestInfoItemHighlight:ClearAllPoints()
		QuestInfoItemHighlight:SetOutside(button.Icon)
		QuestInfoItemHighlight:SetPoint("TOPLEFT", button, "TOPLEFT", -8, 7)
		-- button.Name:SetTextColor(1, 1, 0)
		QuestInfoItemHighlight:Show()

		-- set choice
		QuestInfoFrame.itemChoice = button:GetID()
	end
end

function Module:QUEST_COMPLETE()
	if not C["Misc"].AutoReward then return end
	local choice, highest = 1, 0
	local num = GetNumQuestChoices()

	if num <= 0 then return end -- no choices

	for index = 1, num do
		local link = GetQuestItemLink("choice", index);
		if link then
			local price = select(11, GetItemInfo(link))
			if price and price > highest then
				highest = price
				choice = index
			end
		end
	end

	Module:SelectQuestReward(choice)
end

function Module:OnInitialize()
	if not C["Misc"].AutoReward then return end
	self:RegisterEvent("QUEST_COMPLETE")
end

function Module:OnDisble()
	self:UnregisterEvent("QUEST_COMPLETE")
end