local K, C, L = unpack(select(2, ...))
if K.CheckAddOn("DugisGuideViewerZ") then return end

-- Wow Lua
local unpack = unpack

-- Wow API
local GetNumQuestWatches = GetNumQuestWatches
local GetQuestDifficultyColor = GetQuestDifficultyColor
local GetQuestLogTitle = GetQuestLogTitle
local GetQuestWatchInfo = GetQuestWatchInfo
local GetScreenHeight = GetScreenHeight
local GetScreenWidth = GetScreenWidth

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: OBJECTIVE_TRACKER_DOUBLE_LINE_HEIGHT, ObjectiveTrackerFrame, GameTooltip, UIParent
-- GLOBALS: ObjectiveTrackerBonusRewardsFrame, QUEST_TRACKER_MODULE, ACHIEVEMENT_TRACKER_MODULE

local Movers = K.Movers
local SetModifiedBackdrop = function(self)
	if self:GetButtonState() == "DISABLED" then return end
	self:SetBackdropColor(K.Color.r * 0.3, K.Color.g * 0.3, K.Color.b * 0.3)
	if self.overlay then
		self.overlay:SetVertexColor(K.Color.r * 0.3, K.Color.g * 0.3, K.Color.b * 0.3, 1)
	end
end

local SetOriginalBackdrop = function(self)
	if self:GetButtonState() == "DISABLED" then return end
	self:SetBackdropColor(unpack(C.Media.Backdrop_Color))
	if self.overlay then
		self.overlay:SetVertexColor(0.1, 0.1, 0.1, 1)
	end
end

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

-- Skin ObjectiveTrackerFrame item buttons
hooksecurefunc(QUEST_TRACKER_MODULE, "SetBlockHeader", function(_, block)
	local item = block.itemButton

	if item and not item.skinned then
		item:SetSize(C.ActionBar.ButtonSize - 5, C.ActionBar.ButtonSize - 5)
		item:SetBackdrop(K.BorderBackdrop)
		item:CreateShadow()
		item:SetBackdropColor(0.65, 0.63, 0.35)
		item:StyleButton()

		item:SetNormalTexture(nil)

		item.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
		item.icon:SetPoint("TOPLEFT", item, 2, -2)
		item.icon:SetPoint("BOTTOMRIGHT", item, -2, 2)

		item.Cooldown:SetAllPoints(item.icon)

		item.Count:ClearAllPoints()
		item.Count:SetPoint("TOPLEFT", 1, -1)
		item.Count:SetFont(C.Media.Font, C.Media.Font_Size, C.Media.Font_Style)
		item.Count:SetShadowOffset(0, 0)

		item.skinned = true
	end
end)

hooksecurefunc(WORLD_QUEST_TRACKER_MODULE, "AddObjective", function(_, block)
	local item = block.itemButton

	if item and not item.skinned then
		item:SetSize(C.ActionBar.ButtonSize - 5, C.ActionBar.ButtonSize - 5)
		item:SetBackdrop(K.BorderBackdrop)
		item:CreateShadow()
		item:SetBackdropColor(0.65, 0.63, 0.35)
		item:StyleButton()

		item:SetNormalTexture(nil)

		item.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
		item.icon:SetPoint("TOPLEFT", item, 2, -2)
		item.icon:SetPoint("BOTTOMRIGHT", item, -2, 2)

		item.Cooldown:SetAllPoints(item.icon)

		item.Count:ClearAllPoints()
		item.Count:SetPoint("TOPLEFT", 1, -1)
		item.Count:SetFont(C.Media.Font, C.Media.Font_Size, C.Media.Font_Style)
		item.Count:SetShadowOffset(0, 0)

		item.skinned = true
	end
end)

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

-- Skin ObjectiveTrackerFrame.HeaderMenu.MinimizeButton
local button = ObjectiveTrackerFrame.HeaderMenu.MinimizeButton
button:SetSize(17, 17)
button:StripTextures()
button:SetBackdrop(K.BorderBackdrop)
button:SetBackdropColor(unpack(C.Media.Backdrop_Color))

button.minus = button:CreateTexture(nil, "OVERLAY")
button.minus:SetSize(10, 2)
button.minus:SetPoint("CENTER")
button.minus:SetTexture(C.Media.Blank)

button.plus = button:CreateTexture(nil, "OVERLAY")
button.plus:SetSize(2, 10)
button.plus:SetPoint("CENTER")
button.plus:SetTexture(C.Media.Blank)

button:HookScript("OnEnter", SetModifiedBackdrop)
button:HookScript("OnLeave", SetOriginalBackdrop)

button.plus:Hide()
hooksecurefunc("ObjectiveTracker_Collapse", function()
	button.plus:Show()
end)

hooksecurefunc("ObjectiveTracker_Expand", function()
	button.plus:Hide()
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