local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Automation")

local GetNumQuestChoices = GetNumQuestChoices
local GetQuestItemLink = GetQuestItemLink
local GetQuestItemInfo = GetQuestItemInfo
local select = select
local GetItemInfo = GetItemInfo

function Module:SetupAutoBestReward()
	local firstItem = QuestInfoRewardsFrameQuestInfoItem1
	if not firstItem then
		return
	end

	local numQuests = GetNumQuestChoices()
	if numQuests < 2 then
		return
	end

	-- Create a table to store references to the QuestInfoRewardsFrameQuestInfoItem buttons
	local questRewards = {}
	for i = 1, numQuests do
		local btn = _G["QuestInfoRewardsFrameQuestInfoItem" .. i]
		if btn and btn.type == "choice" then
			questRewards[i] = btn
		end
	end

	local bestValue = 0
	local bestItem
	for i, btn in pairs(questRewards) do
		local questLink = GetQuestItemLink("choice", i)
		local _, _, amount = GetQuestItemInfo("choice", i)
		local itemSellPrice = questLink and select(11, GetItemInfo(questLink))

		-- Add the item's rarity and usefulness to the value calculation
		local itemRarity = questLink and select(3, GetItemInfo(questLink))
		local itemUsefulness = (itemRarity == 6) and 5 or itemRarity

		local totalValue = (itemSellPrice and itemSellPrice * amount) + itemUsefulness
		if totalValue > bestValue then
			bestValue = totalValue
			bestItem = i
		end
	end

	if bestItem then
		local btn = questRewards[bestItem]
		Module.QuestRewardGoldIconFrame:ClearAllPoints()
		Module.QuestRewardGoldIconFrame:SetPoint("TOPRIGHT", btn, "TOPRIGHT", -2, -2)
		Module.QuestRewardGoldIconFrame:Show()
	end
end

function Module:CreateAutoBestReward()
	if not C["Automation"].AutoReward then
		return
	end

	do -- questRewardMostValueIcon
		local MostValue = CreateFrame("Frame", "KKUI_QuestRewardGoldIconFrame", _G.UIParent)
		MostValue:SetFrameStrata("HIGH")
		MostValue:SetSize(20, 20)
		MostValue:Hide()

		MostValue.Icon = MostValue:CreateTexture(nil, "OVERLAY")
		MostValue.Icon:SetAllPoints(MostValue)
		MostValue.Icon:SetTexture("Interface\\BUTTONS\\UI-GroupLoot-Coin-Up")

		Module.QuestRewardGoldIconFrame = MostValue

		hooksecurefunc(_G.QuestFrameRewardPanel, "Hide", function()
			if Module.QuestRewardGoldIconFrame then
				Module.QuestRewardGoldIconFrame:Hide()
			end
		end)
	end

	K:RegisterEvent("QUEST_COMPLETE", self.SetupAutoBestReward)
end
