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

	if not Module.QuestRewardGoldIconFrame then
		Module.QuestRewardGoldIconFrame = CreateFrame("Frame", nil, firstItem)
		Module.QuestRewardGoldIconFrame:SetFrameStrata("HIGH")
		Module.QuestRewardGoldIconFrame:SetSize(20, 20)

		Module.QuestRewardGoldIconFrame.Icon = Module.QuestRewardGoldIconFrame:CreateTexture(nil, "OVERLAY")
		Module.QuestRewardGoldIconFrame.Icon:SetAllPoints(Module.QuestRewardGoldIconFrame)
		Module.QuestRewardGoldIconFrame.Icon:SetTexture("Interface\\BUTTONS\\UI-GroupLoot-Coin-Up")
	end

	Module.QuestRewardGoldIconFrame:Hide()

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
			Module.QuestRewardGoldIconFrame:ClearAllPoints()
			Module.QuestRewardGoldIconFrame:SetPoint("TOPRIGHT", btn, "TOPRIGHT", -2, -2)
			Module.QuestRewardGoldIconFrame:Show()
		end
	end
end

function Module:CreateAutoBestReward()
    if not C["Automation"].AutoReward then
        return
    end

    K:RegisterEvent("QUEST_COMPLETE", self.SetupAutoBestReward)
end