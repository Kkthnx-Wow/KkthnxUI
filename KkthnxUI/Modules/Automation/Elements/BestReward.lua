local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Automation")

local GetNumQuestChoices = GetNumQuestChoices
local GetQuestItemLink = GetQuestItemLink
local GetQuestItemInfo = GetQuestItemInfo
local select = select
local GetItemInfo = GetItemInfo

local questRewardGoldIconFrame

local function getQuestRewards()
	local numChoices = GetNumQuestChoices()
	if numChoices < 2 then
		return nil
	end

	local questRewards = {}
	for i = 1, numChoices do
		local btn = _G["QuestInfoRewardsFrameQuestInfoItem" .. i]
		if btn and btn.type == "choice" then
			questRewards[i] = btn
		end
	end

	return questRewards
end

local function getBestQuestReward(questRewards)
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

	return bestItem
end

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

function Module:CreateAutoBestReward()
	if not C["Automation"].AutoReward then
		return
	end

	questRewardGoldIconFrame = CreateFrame("Frame", "KKUI_QuestRewardGoldIconFrame", _G.UIParent)
	questRewardGoldIconFrame:SetFrameStrata("HIGH")
	questRewardGoldIconFrame:SetSize(20, 20)
	questRewardGoldIconFrame:Hide()

	local icon = questRewardGoldIconFrame:CreateTexture(nil, "OVERLAY")
	icon:SetAllPoints(questRewardGoldIconFrame)
	icon:SetTexture("Interface\\BUTTONS\\UI-GroupLoot-Coin-Up")

	_G.QuestFrameRewardPanel:HookScript("OnHide", function()
		questRewardGoldIconFrame:Hide()
	end)

	K:RegisterEvent("QUEST_COMPLETE", self.SetupAutoBestReward)
end
