local K, C = unpack(select(2, ...))
local Module = K:GetModule("Automation")

local _G = _G

local GetQuestItemLink = _G.GetQuestItemLink
local GetQuestItemInfo = _G.GetQuestItemInfo
local GetItemInfo = _G.GetItemInfo
local GetNumQuestChoices = _G.GetNumQuestChoices

function Module:SetupAutoBestReward()
	local firstItem = _G.QuestInfoRewardsFrameQuestInfoItem1
    if not firstItem then
        return
    end

	local bestValue, bestItem = 0
	local numQuests = GetNumQuestChoices()

	if not self.QuestRewardGoldIconFrame then
		local frame = CreateFrame("Frame", nil, firstItem)
		frame:SetFrameStrata("HIGH")
		frame:SetSize(20, 20)
		frame.Icon = frame:CreateTexture(nil, "OVERLAY")
		frame.Icon:SetAllPoints(frame)
		frame.Icon:SetTexture([[Interface\MONEYFRAME\UI-GoldIcon]])
		self.QuestRewardGoldIconFrame = frame
	end

	self.QuestRewardGoldIconFrame:Hide()

	if numQuests < 2 then
		return
	end

	for i = 1, numQuests do
		local questLink = GetQuestItemLink("choice", i)
		local _, _, amount = GetQuestItemInfo("choice", i)
		local itemSellPrice = questLink and select(11, GetItemInfo(questLink))

		local totalValue = (itemSellPrice and itemSellPrice * amount) or 0
		if totalValue > bestValue then
			bestValue = totalValue
			bestItem = i
		end
	end

	if bestItem then
		local btn = _G["QuestInfoRewardsFrameQuestInfoItem"..bestItem]
		if btn and btn.type == "choice" then
			self.QuestRewardGoldIconFrame:ClearAllPoints()
			self.QuestRewardGoldIconFrame:Point("TOPRIGHT", btn, "TOPRIGHT", -2, -2)
			self.QuestRewardGoldIconFrame:Show()
		end
	end
end

function Module:CreateAutoBestReward()
    if not C["Automation"].QuestRewardMostValue then
        return
    end

    K:RegisterEvent("QUEST_COMPLETE", self.SetupAutoBestReward)
end