local K, C = unpack(select(2, ...))
local Module = K:GetModule("Automation")

local _G = _G
local select = _G.select

local GetItemInfo = _G.GetItemInfo
local GetNumQuestChoices = _G.GetNumQuestChoices
local GetQuestItemInfo = _G.GetQuestItemInfo
local GetQuestItemLink = _G.GetQuestItemLink
local hooksecurefunc = _G.hooksecurefunc

function Module:SetupAutoBestReward()
	local firstItem = _G.QuestInfoRewardsFrameQuestInfoItem1
	if not firstItem then
		return
	end

	local numQuests = GetNumQuestChoices()
	if numQuests < 2 then
		return
	end

	local bestValue, bestItem = 0
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

	do	-- questRewardMostValueIcon
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
end