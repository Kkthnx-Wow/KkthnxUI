local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("ObjectiveFrame", "AceEvent-3.0", "AceHook-3.0")

local _G = _G
local math_min = math.min

local hooksecurefunc = _G.hooksecurefunc
local GetScreenWidth = _G.GetScreenWidth
local GetScreenHeight = _G.GetScreenHeight

--Global variables that we don"t cache, list them here for mikk"s FindGlobals script
-- GLOBALS: ObjectiveTrackerFrame, ObjectiveFrameMover, ObjectiveTrackerBonusRewardsFrame

local bonusObjectivePosition = "AUTO"

local ObjectiveFrameHolder = CreateFrame("Frame", "ObjectiveFrameHolder", UIParent)
ObjectiveFrameHolder:SetWidth(130)
ObjectiveFrameHolder:SetHeight(22)
ObjectiveFrameHolder:SetPoint("TOPRIGHT", "UIParent", "TOPRIGHT", -200, -270)

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

function Module:OnEnable()
	if IsAddOnLoaded("DugisGuideViewerZ") then return end

	K.Movers:RegisterFrame(ObjectiveFrameHolder)
	ObjectiveFrameHolder:SetPoint("TOPRIGHT", "UIParent", "TOPRIGHT", -200, -270)

	ObjectiveTrackerFrame:ClearAllPoints()
	ObjectiveTrackerFrame:SetPoint("TOP", ObjectiveFrameHolder, "TOP")
	Module:SetObjectiveFrameHeight()
	ObjectiveTrackerFrame:SetClampedToScreen(false)

	local function ObjectiveTrackerFrame_SetPosition(_, _, parent)
		if parent ~= ObjectiveFrameHolder then
			ObjectiveTrackerFrame:ClearAllPoints()
			ObjectiveTrackerFrame:SetPoint("TOP", ObjectiveFrameHolder, "TOP")
		end
	end
	hooksecurefunc(ObjectiveTrackerFrame, "SetPoint", ObjectiveTrackerFrame_SetPosition)

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
end