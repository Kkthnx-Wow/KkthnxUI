local K, C, L = select(2, ...):unpack()

-- Lua API
local _G = _G

-- Quest Rewards
local QuestReward = CreateFrame("Frame")
QuestReward:SetScript("OnEvent", function(self, event, ...) self[event](...) end)

local metatable = {
	__call = function(methods, ...)
		for _, method in next, methods do method(...) end
	end
}

local modifier = false
function QuestReward:Register(event, method, override)
	local newmethod
	local methods = self[event]

	if methods then
		self[event] = setmetatable({methods, newmethod or method}, metatable)
	else
		self[event] = newmethod or method
		self:RegisterEvent(event)
	end
end

local cashRewards = {
	[45724] = 1e5, -- Champion's Purse
	[64491] = 2e6, -- Royal Reward
}

QuestReward:Register("QUEST_COMPLETE", function()
	local choices = GetNumQuestChoices()
	if choices > 1 then
		local bestValue, bestIndex = 0

		for index = 1, choices do
			local link = GetQuestItemLink("choice", index)
			if link then
				local _, _, _, _, _, _, _, _, _, _, value = GetItemInfo(link)
				value = cashRewards[tonumber(string.match(link, "item:(%d+):"))] or value

				if value > bestValue then bestValue, bestIndex = value, index end
			else
				choiceQueue = "QUEST_COMPLETE"
				return GetQuestItemInfo("choice", index)
			end
		end

		if bestIndex then QuestInfoItem_OnClick(QuestInfoRewardsFrame.RewardButtons[bestIndex]) end
	end
end, true)
