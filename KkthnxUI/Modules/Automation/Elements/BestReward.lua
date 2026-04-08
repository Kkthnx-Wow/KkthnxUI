--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Automatically identifies and highlights the best quest reward by sell price.
-- - Design: Scans item sell prices when QUEST_COMPLETE triggers and adds a coin icon to the best option.
-- - Events: QUEST_COMPLETE, QuestFrameRewardPanel:OnHide
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Automation")

-- PERF: Localize globals to reduce lookup overhead.
local _G = _G
local C_Item_GetItemInfo = C_Item.GetItemInfo
local CreateFrame = CreateFrame
local GetNumQuestChoices = GetNumQuestChoices
local GetQuestItemInfo = GetQuestItemInfo
local GetQuestItemLink = GetQuestItemLink
local ipairs = ipairs
local select = select

-- ---------------------------------------------------------------------------
-- State
-- ---------------------------------------------------------------------------
local questRewardGoldIconFrame

-- ---------------------------------------------------------------------------
-- Internal Logic
-- ---------------------------------------------------------------------------
local function getQuestRewards()
	-- REASON: Aggregates quest choice buttons to iterate and evaluate potential rewards.
	local numChoices = GetNumQuestChoices()
	if numChoices < 2 then
		return nil
	end

	local questRewards = {}
	local questInfoRewardsFrame = _G.QuestInfoRewardsFrame
	if questInfoRewardsFrame then
		for i = 1, numChoices do
			local btn = questInfoRewardsFrame.RewardButtons[i]
			if btn and btn.type == "choice" then
				questRewards[i] = btn
			end
		end
	end
	return questRewards
end

local function getBestQuestReward(questRewards)
	-- REASON: Calculates the highest value reward based on vendor sell price and item rarity.
	local bestValue, bestItem = 0, nil

	for i, _ in ipairs(questRewards) do
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

-- ---------------------------------------------------------------------------
-- Automation Implementation
-- ---------------------------------------------------------------------------
function Module:SetupAutoBestReward()
	-- REASON: Discovers the best reward and updates the visual highlight icon position.
	local questRewards = getQuestRewards()
	if not questRewards then
		return
	end

	local bestItem = getBestQuestReward(questRewards)
	if bestItem then
		local btn = questRewards[bestItem]
		if btn then
			questRewardGoldIconFrame:ClearAllPoints()
			questRewardGoldIconFrame:SetPoint("TOPRIGHT", btn, "TOPRIGHT", -2, -2)
			questRewardGoldIconFrame:Show()
		end
	end
end

function Module:CreateAutoBestReward()
	-- REASON: Feature entry point; initializes the coin icon indicator and hooks standard quest panels.
	if C["Automation"].AutoReward then
		questRewardGoldIconFrame = CreateFrame("Frame", "KKUI_QuestRewardGoldIconFrame", _G.UIParent)
		questRewardGoldIconFrame:SetFrameStrata("HIGH")
		questRewardGoldIconFrame:SetSize(20, 20)
		questRewardGoldIconFrame:Hide()

		local icon = questRewardGoldIconFrame:CreateTexture(nil, "OVERLAY")
		icon:SetAllPoints(questRewardGoldIconFrame)
		icon:SetTexture("Interface\\BUTTONS\\UI-GroupLoot-Coin-Up")

		local questFrameRewardPanel = _G.QuestFrameRewardPanel
		if questFrameRewardPanel then
			questFrameRewardPanel:HookScript("OnHide", function()
				questRewardGoldIconFrame:Hide()
			end)
		end

		K:RegisterEvent("QUEST_COMPLETE", self.SetupAutoBestReward)
	else
		K:UnregisterEvent("QUEST_COMPLETE", self.SetupAutoBestReward)
	end
end
