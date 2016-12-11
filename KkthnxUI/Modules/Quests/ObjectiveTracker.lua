local K, C, L = unpack(select(2, ...))
if K.CheckAddOn("DugisGuideViewerZ") then return end

local Movers = K.Movers

-- Move ObjectiveTrackerFrame
local ObjectiveFrameHolder = CreateFrame("Frame", "ObjectiveFrameHolder", UIParent)
ObjectiveFrameHolder:SetPoint(unpack(C.Position.ObjectiveTracker))
ObjectiveFrameHolder:SetHeight(150)
ObjectiveFrameHolder:SetWidth(224)
Movers:RegisterFrame(ObjectiveFrameHolder)

ObjectiveTrackerFrame:ClearAllPoints()
ObjectiveTrackerFrame:SetPoint("TOPLEFT", ObjectiveFrameHolder, "TOPLEFT", 20, 0)
ObjectiveTrackerFrame:SetHeight(K.ScreenHeight / 1.6)

hooksecurefunc(ObjectiveTrackerFrame, "SetPoint", function(_, _, parent)
	if parent ~= ObjectiveFrameHolder then
		ObjectiveTrackerFrame:ClearAllPoints()
		ObjectiveTrackerFrame:SetPoint("TOPLEFT", ObjectiveFrameHolder, "TOPLEFT", 20, 0)
	end
end)

for _, headerName in pairs({"QuestHeader", "AchievementHeader", "ScenarioHeader"}) do
	ObjectiveTrackerFrame.BlocksFrame[headerName].Background:Hide()
end
BONUS_OBJECTIVE_TRACKER_MODULE.Header.Background:Hide()
WORLD_QUEST_TRACKER_MODULE.Header.Background:Hide()

ObjectiveTrackerFrame.HeaderMenu.Title:SetAlpha(0)
OBJECTIVE_TRACKER_DOUBLE_LINE_HEIGHT = 30

-- Difficulty color for ObjectiveTrackerFrame lines
hooksecurefunc(QUEST_TRACKER_MODULE, "Update", function()
	for i = 1, GetNumQuestWatches() do
		local questID, _, questIndex = GetQuestWatchInfo(i)
		if not questID then
			break
		end
		local _, level = GetQuestLogTitle(questIndex)
		local col = GetQuestDifficultyColor(level)
		local block = QUEST_TRACKER_MODULE:GetExistingBlock(questID)
		if block then
			block.HeaderText:SetTextColor(col.r, col.g, col.b)
			block.HeaderText.col = col
		end
	end
end)

hooksecurefunc(DEFAULT_OBJECTIVE_TRACKER_MODULE, "AddObjective", function(self, block)
	if block.module == ACHIEVEMENT_TRACKER_MODULE then
		block.HeaderText:SetTextColor(0.75, 0.61, 0)
		block.HeaderText.col = nil
	end
end)

hooksecurefunc("ObjectiveTrackerBlockHeader_OnLeave", function(self)
	local block = self:GetParent()
	if block.HeaderText.col then
		block.HeaderText:SetTextColor(block.HeaderText.col.r, block.HeaderText.col.g, block.HeaderText.col.b)
	end
end)

-- Set tooltip depending on position
local function IsFramePositionedLeft(frame)
	local x = frame:GetCenter()
	local screenWidth = GetScreenWidth()
	local screenHeight = GetScreenHeight()
	local positionedLeft = false

	if x and x < (screenWidth / 2) then
		positionedLeft = true
	end

	return positionedLeft
end

hooksecurefunc("BonusObjectiveTracker_ShowRewardsTooltip", function(block)
	if IsFramePositionedLeft(ObjectiveTrackerFrame) then
		GameTooltip:ClearAllPoints()
		GameTooltip:SetPoint("TOPLEFT", block, "TOPRIGHT", 0, 0)
	end
end)

-- Kill reward animation when finished dungeon or bonus objectives
ObjectiveTrackerScenarioRewardsFrame.Show = K.Noop

hooksecurefunc("BonusObjectiveTracker_AnimateReward", function(block)
	ObjectiveTrackerBonusRewardsFrame:ClearAllPoints()
	ObjectiveTrackerBonusRewardsFrame:SetPoint("BOTTOM", UIParent, "TOP", 0, 90)
end)