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
local GetItemInfoFromHyperlink = GetItemInfoFromHyperlink
local GetNumQuestChoices = GetNumQuestChoices
local GetQuestItemInfo = GetQuestItemInfo
local GetQuestItemLink = GetQuestItemLink
local ipairs = ipairs
local select = select

-- ---------------------------------------------------------------------------
-- State
-- ---------------------------------------------------------------------------
local questRewardGoldIconFrame
-- REASON: when an item's link/sell-price hasn't been
-- cached yet, GetQuestItemLink returns nil and the previous code silently
-- treated that choice as worth 0 — meaning the actual best reward could be
-- skipped just because its data hadn't loaded. Track that we're waiting so
-- QUEST_ITEM_UPDATE (already used for exactly this in Automation/Quest.lua's
-- QuickQuest engine) can re-trigger the scan once the data arrives.
local awaitingItemData = false

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
	awaitingItemData = false

	for i, _ in ipairs(questRewards) do
		local questLink = GetQuestItemLink("choice", i)
		if questLink then
			local _, _, amount = GetQuestItemInfo("choice", i)
			local itemSellPrice = select(11, C_Item_GetItemInfo(questLink)) or 0
			local itemRarity = select(3, C_Item_GetItemInfo(questLink)) or 0
			-- BUGFIX: special
			-- cash-equivalent rewards (e.g. Champion's Purse) don't have a normal vendor
			-- sell price; C["AutoQuestData"].CashRewards already exists for exactly this
			-- in QuickQuest, reused here instead of adding a second, duplicate table.
			local itemID = GetItemInfoFromHyperlink and GetItemInfoFromHyperlink(questLink)
			local cashValue = itemID and C["AutoQuestData"] and C["AutoQuestData"].CashRewards and C["AutoQuestData"].CashRewards[itemID]
			if cashValue then
				itemSellPrice = cashValue
			end

			-- SECRET (12.0): sell price / stack amount can be secret values in rare
			-- cases; skip arithmetic on them rather than risk a compare error.
			if K.NotSecret(itemSellPrice) and K.NotSecret(amount) then
				local itemUsefulness = (itemRarity == 6) and 5 or itemRarity
				local totalValue = itemSellPrice * (amount or 1) + itemUsefulness
				if totalValue > bestValue then
					bestValue = totalValue
					bestItem = i
				end
			end
		else
			-- BUGFIX: link not cached yet — prime it and mark
			-- that we need to re-scan once QUEST_ITEM_UPDATE fires, instead of silently
			-- treating this choice as worthless.
			awaitingItemData = true
			GetQuestItemInfo("choice", i)
		end
	end

	return bestItem
end

-- ---------------------------------------------------------------------------
-- Automation Implementation
-- ---------------------------------------------------------------------------
function Module.SetupAutoBestReward(event)
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

-- REASON: named (not anonymous) so it can be correctly
-- unregistered by the same reference when the feature is disabled.
function Module.OnBestRewardItemDataUpdate()
	if awaitingItemData and _G.QuestFrame and _G.QuestFrame:IsShown() then
		Module.SetupAutoBestReward()
	end
end

function Module:CreateAutoBestReward()
	if not C["Automation"].AutoReward then
		if questRewardGoldIconFrame then
			questRewardGoldIconFrame:Hide()
		end
		K:UnregisterEvent("QUEST_COMPLETE", Module.SetupAutoBestReward)
		K:UnregisterEvent("QUEST_ITEM_UPDATE", Module.OnBestRewardItemDataUpdate)
		awaitingItemData = false
		return
	end

	if not questRewardGoldIconFrame then
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
				awaitingItemData = false
			end)
		end
	end

	K:RegisterEvent("QUEST_COMPLETE", Module.SetupAutoBestReward)
	-- REASON: re-run the scan once a previously-uncached
	-- item's data actually arrives, but only while we're actually waiting on one
	-- and the quest reward frame is still open — avoids scanning on every
	-- unrelated QUEST_ITEM_UPDATE firing elsewhere in the game.
	K:RegisterEvent("QUEST_ITEM_UPDATE", Module.OnBestRewardItemDataUpdate)
end
