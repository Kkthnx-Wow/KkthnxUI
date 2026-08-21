--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/Automation/TurnIn.lua
	Purpose:
		Handing quests in: continuing through the progress page and completing the
		quest. When a quest offers a choice of rewards and reward selection is on,
		the highest vendor-value item is picked automatically, with a few known
		hidden-value items corrected. Retail only.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

if not (K.Client and K.Client.IsRetail) then
	return
end

local Module = K:GetModule("Automation")

local select = select
local IsSecret = K.IsSecret
local C_Item = C_Item

local GetQuestID = GetQuestID
local IsQuestCompletable = IsQuestCompletable
local CompleteQuest = CompleteQuest
local GetNumQuestChoices = GetNumQuestChoices
local GetQuestItemInfo = GetQuestItemInfo
local GetQuestReward = GetQuestReward

-- A few reward items carry hidden gold that GetItemInfo reports as no value, so
-- correct them here to keep the "best reward" pick sensible.
local HIDDEN_VALUE = {
	[45724] = 100000, -- Champion's Purse, 10 gold
	[64491] = 2000000, -- Royal Reward, 200 gold
}

-- Continue past the progress page when the quest can be turned in.
function Module:OnQuestProgress()
	if self:IsPaused() or not C.AutoQuest.TurnIn then
		return
	end
	if IsQuestCompletable() and self:ShouldAccept(GetQuestID()) then
		CompleteQuest()
	end
end

-- Complete the quest, picking the most valuable reward on a choice.
function Module:OnQuestComplete()
	if self:IsPaused() or not C.AutoQuest.TurnIn then
		return
	end
	if not self:ShouldAccept(GetQuestID()) then
		return
	end

	local numChoices = GetNumQuestChoices()
	if numChoices and numChoices > 1 then
		if not C.AutoQuest.SelectReward then
			return
		end

		local bestIndex, bestValue
		for index = 1, numChoices do
			local itemID = select(6, GetQuestItemInfo("choice", index))
			if itemID and not IsSecret(itemID) then
				local value = select(11, C_Item.GetItemInfo(itemID))
				if not value then
					-- Reward not cached yet, retry once it loads.
					self:WaitForItemData(itemID, function()
						self:OnQuestComplete()
					end)
					return
				end
				value = HIDDEN_VALUE[itemID] or value or 0
				if not bestValue or value > bestValue then
					bestValue = value
					bestIndex = index
				end
			end
		end

		if bestIndex then
			GetQuestReward(bestIndex)
		end
	else
		GetQuestReward(1)
	end
end

function Module:SetupTurnIn()
	self:RegisterEvent("QUEST_PROGRESS", "OnQuestProgress")
	self:RegisterEvent("QUEST_COMPLETE", "OnQuestComplete")
end
