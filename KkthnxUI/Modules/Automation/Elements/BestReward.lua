local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Automation")

local GetNumQuestChoices = GetNumQuestChoices
local GetQuestItemLink = GetQuestItemLink
local GetQuestItemInfo = GetQuestItemInfo
local C_Item_GetItemInfo = C_Item.GetItemInfo

local questRewardGoldIconFrame

-- Function to retrieve quest rewards
local function getQuestRewards()
	local numChoices = GetNumQuestChoices()
	if numChoices < 2 then
		return nil
	end

	local questRewards = {}
	for i = 1, numChoices do
		local btn = QuestInfoRewardsFrame.RewardButtons[i]
		if btn and btn.type == "choice" then
			questRewards[i] = btn
		end
	end
	return questRewards
end

-- Function to calculate the best quest reward based on sell price and usefulness
local function getBestQuestReward(questRewards)
	local bestValue, bestItem = 0, nil

	for i, btn in ipairs(questRewards) do
		local questLink = GetQuestItemLink("choice", i)
		if questLink then
			local _, _, amount = GetQuestItemInfo("choice", i)
			local itemSellPrice = select(11, C_Item_GetItemInfo(questLink)) or 0
			local itemRarity = select(3, C_Item_GetItemInfo(questLink)) or 0
			local itemUsefulness = (itemRarity == 6) and 5 or itemRarity

			local totalValue = itemSellPrice * amount + itemUsefulness
			if totalValue > bestValue then
				bestValue = totalValue
				bestItem = i
			end
		end
	end

	return bestItem
end

-- Function to set up the display for the best reward
function Module:SetupAutoBestReward()
	local questRewards = getQuestRewards()
	if not questRewards then
		return
	end

	local bestItem = getBestQuestReward(questRewards)
	if bestItem then
		local btn = questRewards[bestItem]
		questRewardGoldIconFrame:ClearAllPoints()
		questRewardGoldIconFrame:SetPoint("TOPRIGHT", btn, "TOPRIGHT", -2, -2)
		questRewardGoldIconFrame:Show()
	end
end

-- Initialization function to create the frame and set up the event handling
function Module:CreateAutoBestReward()
	if C["Automation"].AutoReward then
		questRewardGoldIconFrame = CreateFrame("Frame", "KKUI_QuestRewardGoldIconFrame", _G.UIParent)
		questRewardGoldIconFrame:SetFrameStrata("HIGH")
		questRewardGoldIconFrame:SetSize(20, 20)
		questRewardGoldIconFrame:Hide()

		local icon = questRewardGoldIconFrame:CreateTexture(nil, "OVERLAY")
		icon:SetAllPoints(questRewardGoldIconFrame)
		icon:SetTexture("Interface\\BUTTONS\\UI-GroupLoot-Coin-Up")

		-- Hide the reward icon when the QuestFrameRewardPanel is hidden
		_G.QuestFrameRewardPanel:HookScript("OnHide", function()
			questRewardGoldIconFrame:Hide()
		end)

		-- Register the QUEST_COMPLETE event to determine the best reward
		K:RegisterEvent("QUEST_COMPLETE", self.SetupAutoBestReward)
	else
		-- Unregister the event if AutoReward is disabled
		K:UnregisterEvent("QUEST_COMPLETE", self.SetupAutoBestReward)
	end
end
