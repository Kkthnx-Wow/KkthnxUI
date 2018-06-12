local K = unpack(select(2, ...))
local Module = K:NewModule("ObjectiveFrame", "AceEvent-3.0", "AceHook-3.0")

local _G = _G
local math_min = math.min

local hooksecurefunc = _G.hooksecurefunc
local GetScreenWidth = _G.GetScreenWidth
local GetScreenHeight = _G.GetScreenHeight

function Module:SetObjectiveFrameHeight()
	local top = ObjectiveTrackerFrame:GetTop() or 0
	local screenHeight = GetScreenHeight()
	local gapFromTop = screenHeight - top
	local maxHeight = screenHeight - gapFromTop
	local objectiveFrameHeight = math_min(maxHeight, 480)

	ObjectiveTrackerFrame:SetHeight(objectiveFrameHeight)
end

local function IsFramePositionedLeft(frame)
	local x = frame:GetCenter()
	local screenWidth = GetScreenWidth()
	local positionedLeft = false

	if x and x < (screenWidth / 2) then
		positionedLeft = true
	end

	return positionedLeft
end

function Module:MoveObjectiveFrame()
	local Anchor1, Parent, Anchor2, X, Y = "TOPRIGHT", UIParent, "TOPRIGHT", -200, -270
	local Data = KkthnxUIData[GetRealmName()][UnitName("player")]

	local ObjectiveFrameHolder = CreateFrame("Frame", "TrackerFrameHolder", UIParent)
	ObjectiveFrameHolder:SetSize(130, 22)
	ObjectiveFrameHolder:SetPoint(Anchor1, Parent, Anchor2, X, Y)

	ObjectiveTrackerFrame:ClearAllPoints()
	ObjectiveTrackerFrame:SetPoint("TOP", ObjectiveFrameHolder, "TOP")
	Module:SetObjectiveFrameHeight()
	ObjectiveTrackerFrame:SetClampedToScreen(false)

	function ObjectiveTrackerFrame.IsUserPlaced()
		return true
	end

	K.Movers:RegisterFrame(ObjectiveFrameHolder)
	K.Movers:SaveDefaults(self, Anchor1, Parent, Anchor2, X, Y)

	if Data and Data.Movers and Data.Movers.TrackerFrameHolder then
		ObjectiveFrameHolder:ClearAllPoints()
		ObjectiveFrameHolder:SetPoint(
			Data.Movers.TrackerFrameHolder[1],
			Data.Movers.TrackerFrameHolder[2],
			Data.Movers.TrackerFrameHolder[3],
			Data.Movers.TrackerFrameHolder[4],
			Data.Movers.TrackerFrameHolder[5]
		)
	end

	local function RewardsFrame_SetPosition(block)
		local rewardsFrame = ObjectiveTrackerBonusRewardsFrame
		rewardsFrame:ClearAllPoints()
		if IsFramePositionedLeft(ObjectiveTrackerFrame) then
			rewardsFrame:SetPoint("TOPLEFT", block, "TOPRIGHT", -10, -4)
		else
			rewardsFrame:SetPoint("TOPRIGHT", block, "TOPLEFT", 10, -4)
		end
	end

	hooksecurefunc("BonusObjectiveTracker_AnimateReward", RewardsFrame_SetPosition)
end

function Module:OnEnable()
	if not K.CheckAddOnState("DugisGuideViewerZ") then
		self:MoveObjectiveFrame()
	end
end
