local K, C, L = unpack(select(2, ...))
--if C.Blizzard.ObjectiveTracker ~= true or K.CheckAddOn("DugisGuideViewerZ") then return end
if K.CheckAddOn("DugisGuideViewerZ") then return end

-- Wow Lua
local unpack = unpack
local math_min = math.min

-- Wow API
local GetNumQuestWatches = GetNumQuestWatches
local GetQuestDifficultyColor = GetQuestDifficultyColor
local GetQuestLogTitle = GetQuestLogTitle
local GetQuestWatchInfo = GetQuestWatchInfo

-- Global variables that we don"t cache, list them here for mikk"s FindGlobals script
-- GLOBALS: OBJECTIVE_TRACKER_DOUBLE_LINE_HEIGHT, ObjectiveTrackerFrame, GameTooltip, UIParent
-- GLOBALS: ObjectiveTrackerBonusRewardsFrame, QUEST_TRACKER_MODULE, ACHIEVEMENT_TRACKER_MODULE

local bonusObjectivePosition = "AUTO"
local Movers = K.Movers

-- Blah some shit to skin the button.
local function SetModifiedBackdrop(self)
	if self.backdrop then self = self.backdrop end
	self:SetBackdropBorderColor(K.Color.r, K.Color.g, K.Color.b, C.Media.Border_Color[4])
	self:SetBackdropColor(K.Color.r * .15, K.Color.g * .15, K.Color.b * .15, C.Media.Backdrop_Color[4])
end

local function SetOriginalBackdrop(self)
	if self.backdrop then self = self.backdrop end
	self:SetBackdropBorderColor(C.Media.Border_Color[1], C.Media.Border_Color[2], C.Media.Border_Color[3])
	self:SetBackdropColor(C.Media.Backdrop_Color[1], C.Media.Backdrop_Color[2], C.Media.Backdrop_Color[3], C.Media.Backdrop_Color[4])
	if C.Blizzard.ColorTextures == false then
		self:SetBackdropBorderColor(C.Media.Border_Color[1], C.Media.Border_Color[2], C.Media.Border_Color[3], C.Media.Border_Color[4])
	end
end

-- Blah blah blah. You get the idea.
local function HandleButton(f, strip)
	assert(f, "doesn't exist!")
	if f.Left then f.Left:SetAlpha(0) end
	if f.Middle then f.Middle:SetAlpha(0) end
	if f.Right then f.Right:SetAlpha(0) end
	if f.LeftSeparator then f.LeftSeparator:SetAlpha(0) end
	if f.RightSeparator then f.RightSeparator:SetAlpha(0) end

	if f.SetNormalTexture then f:SetNormalTexture("") end
	if f.SetHighlightTexture then f:SetHighlightTexture("") end
	if f.SetPushedTexture then f:SetPushedTexture("") end
	if f.SetDisabledTexture then f:SetDisabledTexture("") end

	if strip then f:StripTextures() end

	f:HookScript("OnEnter", SetModifiedBackdrop)
	f:HookScript("OnLeave", SetOriginalBackdrop)
end

-- Move ObjectiveTrackerFrame
local ObjectiveFrameHolder = CreateFrame("Frame", "ObjectiveFrameHolder", UIParent)
ObjectiveFrameHolder:SetPoint(unpack(C.Position.ObjectiveTracker))
ObjectiveFrameHolder:SetHeight(150)
ObjectiveFrameHolder:SetWidth(224)
Movers:RegisterFrame(ObjectiveFrameHolder)

local function SetObjectiveFrameHeight()
	local top = ObjectiveTrackerFrame:GetTop() or 0
	local screenHeight = GetScreenHeight()
	local gapFromTop = screenHeight - top
	local maxHeight = screenHeight - gapFromTop
	local objectiveFrameHeight = math_min(maxHeight, 480)

	ObjectiveTrackerFrame:SetHeight(objectiveFrameHeight)
end

ObjectiveTrackerFrame:ClearAllPoints()
ObjectiveTrackerFrame:SetPoint("TOPLEFT", ObjectiveFrameHolder, "TOPLEFT", 20, 0)
SetObjectiveFrameHeight()
ObjectiveTrackerFrame:SetClampedToScreen(false)

hooksecurefunc(ObjectiveTrackerFrame, "SetPoint", function(_, _, parent)
	if parent ~= ObjectiveFrameHolder then
		ObjectiveTrackerFrame:ClearAllPoints()
		ObjectiveTrackerFrame:SetPoint("TOPLEFT", ObjectiveFrameHolder, "TOPLEFT", 20, 0)
	end
end)

ObjectiveTrackerBlocksFrame.QuestHeader:StripTextures()
ObjectiveTrackerBlocksFrame.QuestHeader.Text:SetFont(C.Media.Font, 16)
ObjectiveTrackerBlocksFrame.AchievementHeader:StripTextures()
ObjectiveTrackerBlocksFrame.AchievementHeader.Text:SetFont(C.Media.Font, 16)
ObjectiveTrackerBlocksFrame.ScenarioHeader:StripTextures()
ObjectiveTrackerBlocksFrame.ScenarioHeader.Text:SetFont(C.Media.Font, 16)

BONUS_OBJECTIVE_TRACKER_MODULE.Header:StripTextures()
BONUS_OBJECTIVE_TRACKER_MODULE.Header.Text:SetFont(C.Media.Font, 16)
WORLD_QUEST_TRACKER_MODULE.Header:StripTextures()
WORLD_QUEST_TRACKER_MODULE.Header.Text:SetFont(C.Media.Font, 16)

-- Skin ObjectiveTrackerFrame item buttons
hooksecurefunc(QUEST_TRACKER_MODULE, "SetBlockHeader", function(_, block)
	local item = block.itemButton

	if item and not item.skinned then
		item:SetSize(28, 28)
		K.CreateBorder(item, 1)
		item:SetBackdropBorderColor(1, 1, 0)
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
		item:SetSize(28, 28)
		K.CreateBorder(item, 1)
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

-- Skin the MinimizeButton
local function OnClick(self)
	local textObject = self.text

	if ObjectiveTrackerFrame.collapsed then
		textObject:SetText("+")
	else
		textObject:SetText("-")
	end
end

local minimizeButton = ObjectiveTrackerFrame.HeaderMenu.MinimizeButton
HandleButton(minimizeButton)
minimizeButton:SetSize(16, 14)
minimizeButton:SetBackdrop(K.BorderBackdrop)
minimizeButton:SetBackdropColor(C.Media.Backdrop_Color[1], C.Media.Backdrop_Color[2], C.Media.Backdrop_Color[3], C.Media.Backdrop_Color[4])
K.CreateBorder(minimizeButton)
minimizeButton.text = minimizeButton:CreateFontString(nil, "OVERLAY")
minimizeButton.text:SetFont(C.Media.Font, 15, C.Media.Font_Style)
minimizeButton.text:SetPoint("CENTER", minimizeButton, "CENTER", 0, 0)
minimizeButton.text:SetText("-")
minimizeButton.text:SetJustifyH("CENTER")
minimizeButton.text:SetJustifyV("CENTER")
minimizeButton:HookScript("OnClick", OnClick)

-- Set tooltip depending on position
local function IsFramePositionedLeft(frame)
	local x = frame:GetCenter()
	local screenWidth = GetScreenWidth()
	local positionedLeft = false

	if x and x < (screenWidth / 2) then
		positionedLeft = true
	end

	return positionedLeft
end

local function RewardsFrame_SetPosition(block)
	local rewardsFrame = ObjectiveTrackerBonusRewardsFrame
	rewardsFrame:ClearAllPoints()
		if bonusObjectivePosition == "RIGHT" or (bonusObjectivePosition == "AUTO" and IsFramePositionedLeft(ObjectiveTrackerFrame)) then
			rewardsFrame:SetPoint("TOPLEFT", block, "TOPRIGHT", -10, -4)
	else
			rewardsFrame:SetPoint("TOPRIGHT", block, "TOPLEFT", 10, -4)
	end
end
hooksecurefunc("BonusObjectiveTracker_AnimateReward", RewardsFrame_SetPosition)