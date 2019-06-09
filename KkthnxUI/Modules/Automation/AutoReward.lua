local K, C = unpack(select(2, ...))
local Module = K:NewModule("AutoReward", "AceEvent-3.0")

-- Sourced: ElvUI Shadow & Light (Darth_Predator, Repooc)

local _G = _G

local settings = {
	UiQuestRewards = true
}

local isHooked = false
local rewardsFrames = {
	{
		name = "MapQuestInfoRewardsFrame",
		icons = {}
	},

	{
		name = "QuestInfoRewardsFrame",
		icons = {}
	}
}

local function valuableIconHide(frameInfo)
	-- Hide All The Valuable Icons
	for _, icon in _G.ipairs(frameInfo.icons) do
		icon:Hide()
	end

	frameInfo.icons[0] = 0

	return
end

-- Function To Show The Next Valuable Icon On A Reward Button
local function valuableIconShow(frameInfo, button)
	-- Local Variables
	local iconTexture
	local iconFrame
	local iconIdx

	-- Work Out Which Icon To Use
	iconIdx = (frameInfo.icons[0] or 0) + 1
	iconFrame = frameInfo.icons[iconIdx]

	-- Create The Frame And Texture For A Valuable Icon, If Required
	if (iconFrame == nil) then
		iconFrame = _G.CreateFrame("FRAME", nil, _G[frameInfo.name], nil)
		iconFrame:SetSize(16, 16)

		iconTexture = iconFrame:CreateTexture(nil, "BORDER")
		iconTexture:SetAtlas("bags-junkcoin", true)
		iconTexture:SetPoint("TOPLEFT", 0, 0)
		frameInfo.icons[iconIdx] = iconFrame
	end

	-- Position and show the icon
	iconFrame:SetPoint("TOPLEFT", button, 0, 0)
	iconFrame:Show()
	frameInfo.icons[0] = iconIdx

	-- return frame --> iconFrame??
end

-- Function To Update The Quest Item Buttons To Indicate Which Reward Is Most Valuable When Sold To A Merchant
function Module:QuestsItemInfoUpdate()
	-- Local Variables
	local itemCount
	local itemLink
	local itemValue
	local maxValue = 0
	local maxValueButtons = {}
	local missingInfo = false
	local numMaxValue = 0
	local numShown = 0
	local rewardButtons

	-- Check The Most Valuable Quest Reward Is To Be Indicated
	if (settings.UiQuestRewards) then
		-- Process All Quest Rewards Frames
		for frameIdx = 1, #rewardsFrames do
			-- Hide All The Valuable Icons
			valuableIconHide(rewardsFrames[frameIdx])
			-- Check At Least One Item Is Shown In The Current Rewards Frame
			local rewardFrame = _G[rewardsFrames[frameIdx].name]
			if ((rewardFrame ~= nil) and
			(rewardFrame:IsShown()) and
			(rewardFrame.RewardButtons[1] ~= nil) and
			(rewardFrame.RewardButtons[1]:IsShown())) then
				-- Assign Info To More Convenient Variables
				rewardButtons = rewardFrame.RewardButtons
				-- Get The Item Info For All Buttons Showing Quest Rewards
				for _, button in _G.ipairs(rewardButtons) do
					-- Check The Button Is Showing A Quest Reward
					if (button:IsShown()) then
						-- Check The Button Is Showing A Choice
						if ((button.type == "choice") and (button.objectType == "item")) then
							-- Get The Link For The Button's Item
							if (QuestInfoFrame.questLog) then
								itemLink = _G.GetQuestLogItemLink("choice", button:GetID())
								_, _, itemCount = _G.GetQuestLogChoiceInfo(button:GetID())
							else
								itemLink = _G.GetQuestItemLink("choice", button:GetID())
								_, _, itemCount = _G.GetQuestItemInfo("choice", button:GetID())
							end

							if ((itemLink ~= nil) and (itemCount ~= nil)) then
								-- Get The Item's Value
								_, _, _, _, _, _, _, _, _, _, itemValue = _G.GetItemInfo(itemLink)
								if (itemValue ~= nil) then
									itemValue = itemValue*itemCount
									if (itemValue > maxValue) then
										maxValue = itemValue
										numMaxValue = 0
									end
									if (itemValue == maxValue) then
										numMaxValue = numMaxValue + 1
										maxValueButtons[numMaxValue] = button
									end
								else
									maxValue = 0
									numMaxValue = 0
									missingInfo = true
									break
								end
							else
								maxValue = 0
								numMaxValue = 0
								missingInfo = true
								break
							end
							numShown = numShown + 1
						end
					end
				end

				-- Show The Icons For The Most Valuable Items
				if ((maxValue > 0) and (numShown > 1) and (numMaxValue >= 1)) then
					for idx = 1, numMaxValue do
						valuableIconShow(rewardsFrames[frameIdx], maxValueButtons[idx])
					end
				end
			end
		end

		-- Check If The Value Of Any Items Couldn't Be Obtained
		if ((settings.UiQuestRewards) and (missingInfo)) then
			_G.C_Timer.After(0.25, Module.QuestsItemInfoUpdate)
		end
	end
	return
end

function Module:SelectQuestReward(index)
	local frame = QuestInfoFrame.rewardsFrame

	local button = _G.QuestInfo_GetRewardButton(frame, index)
	if (button.type == "choice") then
		QuestInfoItemHighlight:ClearAllPoints()
		QuestInfoItemHighlight:SetAllPoints(button.Icon)
		QuestInfoItemHighlight:SetPoint("TOPLEFT", button, "TOPLEFT", -8, 7)
		QuestInfoItemHighlight:Show()

		-- Set Choice
		QuestInfoFrame.itemChoice = button:GetID()
	end
end

function Module:QUEST_COMPLETE()
	local choice, highest = 1, 0
	local num = _G.GetNumQuestChoices()

	if num <= 0 then -- No Choices
		return
	end

	for index = 1, num do
		local link = _G.GetQuestItemLink("choice", index)
		if link then
			local price = _G.select(11, _G.GetItemInfo(link))
			if price and price > highest then
				highest = price
				choice = index
			end
		end
	end

	Module:SelectQuestReward(choice)
end

function Module:OnEnable()
	if not C["Automation"].AutoReward then
		return
	end

	self:RegisterEvent("QUEST_COMPLETE")

	-- Hook The Function That Updates The Quest Info Item Buttons, If Required
	if ((not isHooked) and (settings.UiQuestRewards)) then
		_G.hooksecurefunc("QuestInfo_Display", Module.QuestsItemInfoUpdate)
		isHooked = true
	end

	-- Check If The Quest Info Frames Actually Need To Be Enabled / Disabled
	if (not settings.UiQuestRewards) then
		-- Hide The Most Valuable Quest Reward Indicators
		for idx = 1, #rewardsFrames do
			valuableIconHide(rewardsFrames[idx])
		end
	end
	return
end
