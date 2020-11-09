local K, C = unpack(select(2, ...))
local Module = K:GetModule("Blizzard")

local _G = _G
local math_min = _G.math.min

local CreateFrame = _G.CreateFrame
local GetScreenHeight = _G.GetScreenHeight
local GetScreenWidth = _G.GetScreenWidth
local hooksecurefunc = _G.hooksecurefunc
local UIParent = _G.UIParent

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

function Module:SetObjectiveFrameAutoHide()
	if not _G.ObjectiveTrackerFrame.AutoHider then -- Kaliel"s Tracker prevents Module:MoveObjectiveFrame() from executing
		return
	end

	if C["Automation"].AutoCollapse then
		RegisterStateDriver(_G.ObjectiveTrackerFrame.AutoHider, "objectiveHider", "[@arena1,exists][@arena2,exists][@arena3,exists][@arena4,exists][@arena5,exists][@boss1,exists][@boss2,exists][@boss3,exists][@boss4,exists] 1;0")
	else
		UnregisterStateDriver(_G.ObjectiveTrackerFrame.AutoHider, "objectiveHider")
	end
end

function Module:MoveObjectiveFrame()
	local ObjectiveFrameHolder = CreateFrame("Frame", "ObjectiveFrameHolder", UIParent)
	ObjectiveFrameHolder:SetSize(130, 22)
	ObjectiveFrameHolder:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -200, -300)

	K.Mover(ObjectiveFrameHolder, "ObjectiveFrameMover", "Objective Frame", {"TOPRIGHT", UIParent, "TOPRIGHT", -200, -300})

	local ObjectiveTrackerFrame = _G.ObjectiveTrackerFrame
	ObjectiveTrackerFrame:ClearAllPoints()
	ObjectiveTrackerFrame:SetPoint("TOP", ObjectiveFrameHolder, "TOP")
	Module:SetObjectiveFrameHeight()
	ObjectiveTrackerFrame:SetClampedToScreen(false)

	ObjectiveTrackerFrame:SetMovable(true)

	if ObjectiveTrackerFrame:IsMovable() then
		ObjectiveTrackerFrame:SetUserPlaced(true) -- UIParent.lua line 3090 stops it from being moved <3
	end

	ObjectiveTrackerFrame:ClearAllPoints()
	ObjectiveTrackerFrame:SetPoint("TOP", ObjectiveFrameHolder, "TOP")

	local function RewardsFrame_SetPosition(block)
		local rewardsFrame = _G.ObjectiveTrackerBonusRewardsFrame;
		rewardsFrame:ClearAllPoints()
		if IsFramePositionedLeft(ObjectiveTrackerFrame) then
			rewardsFrame:SetPoint("TOPLEFT", block, "TOPRIGHT", -10, -4)
		else
			rewardsFrame:SetPoint("TOPRIGHT", block, "TOPLEFT", 10, -4)
		end
	end
	hooksecurefunc("BonusObjectiveTracker_AnimateReward", RewardsFrame_SetPosition)

	-- objectiveFrameAutoHide
	ObjectiveTrackerFrame.AutoHider = CreateFrame("Frame", nil, ObjectiveTrackerFrame, "SecureHandlerStateTemplate")
	ObjectiveTrackerFrame.AutoHider:SetAttribute("_onstate-objectiveHider", "if newstate == 1 then self:Hide() else self:Show() end")
	ObjectiveTrackerFrame.AutoHider:SetScript("OnHide", function()
		if not ObjectiveTrackerFrame.collapsed then
			local _, _, difficultyID = GetInstanceInfo()
			if difficultyID then
				_G.ObjectiveTracker_Collapse()
			end
		end
	end)

	ObjectiveTrackerFrame.AutoHider:SetScript("OnShow", function()
		if ObjectiveTrackerFrame.collapsed then
			_G.ObjectiveTracker_Expand()
		end
	end)

	self:SetObjectiveFrameAutoHide()
end

function Module:CreateObjectiveFrame()
	Module:MoveObjectiveFrame()
end