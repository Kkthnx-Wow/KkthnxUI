local K, C = unpack(KkthnxUI)
local Module = K:GetModule("Blizzard")

local CreateFrame = CreateFrame
local GetInstanceInfo = GetInstanceInfo
local IsInJailersTower = IsInJailersTower
local hooksecurefunc = hooksecurefunc

local function IsFramePositionedLeft(frame)
	local x = frame:GetCenter()
	return x and x < (K.ScreenWidth * 0.5) -- positioned on left side
end

local function RewardsFrame_SetPosition(block)
	local rewards = _G.ObjectiveTrackerBonusRewardsFrame
	rewards:ClearAllPoints()

	if IsFramePositionedLeft(_G.ObjectiveTrackerFrame) then
		rewards:SetPoint("TOPLEFT", block, "TOPRIGHT", -10, -4)
	else
		rewards:SetPoint("TOPRIGHT", block, "TOPLEFT", 10, -4)
	end
end

local function AutoHider_OnHide()
	if not _G.ObjectiveTrackerFrame.collapsed then
		local _, _, difficultyID = GetInstanceInfo()
		if difficultyID ~= 8 then -- ignore hide in keystone runs
			_G.ObjectiveTracker_Collapse()
		end
	end
end

local function AutoHider_OnShow()
	if _G.ObjectiveTrackerFrame.collapsed then
		_G.ObjectiveTracker_Expand()
	end
end

local function MawBuffsList_OnShow(list)
	list.button:SetHighlightAtlas("jailerstower-animapowerbutton-highlight", true)
	list.button:SetPushedAtlas("jailerstower-animapowerbutton-normalpressed", true)
	list.button:SetButtonState("PUSHED", true)
	list.button:SetButtonState("NORMAL")
end

function Module:HandleMawBuffsFrame()
	if not IsInJailersTower() then
		return
	end

	local container = _G.ScenarioBlocksFrame.MawBuffsBlock.Container
	container.List:ClearAllPoints()

	if IsFramePositionedLeft(_G.ScenarioBlocksFrame) then
		container.List:SetPoint("TOPLEFT", container, "TOPRIGHT", 15, 1)
		container.List:SetScript("OnShow", MawBuffsList_OnShow)
	else
		container.List:SetPoint("TOPRIGHT", container, "TOPLEFT", 15, 1)
	end
end

function Module:SetObjectiveFrameAutoHide()
	if not _G.ObjectiveTrackerFrame.AutoHider then
		return -- Kaliel's Tracker prevents Module:MoveObjectiveFrame() from executing
	end

	if C["Automation"].AutoCollapse then
		RegisterStateDriver(_G.ObjectiveTrackerFrame.AutoHider, "objectiveHider", "[@arena1,exists][@arena2,exists][@arena3,exists][@arena4,exists][@arena5,exists][@boss1,exists][@boss2,exists][@boss3,exists][@boss4,exists][@boss5,exists] 1;0")
	else
		UnregisterStateDriver(_G.ObjectiveTrackerFrame.AutoHider, "objectiveHider")
	end
end

-- keeping old name, not used to move just to handle the objective things
-- wrath has it's own file, which actually has the mover on that client
function Module:CreateObjectiveFrame()
	local tracker = _G.ObjectiveTrackerFrame
	tracker.AutoHider = CreateFrame("Frame", nil, tracker, "SecureHandlerStateTemplate")
	tracker.AutoHider:SetAttribute("_onstate-objectiveHider", "if newstate == 1 then self:Hide() else self:Show() end")
	tracker.AutoHider:SetScript("OnHide", AutoHider_OnHide)
	tracker.AutoHider:SetScript("OnShow", AutoHider_OnShow)
	Module:SetObjectiveFrameAutoHide()

	hooksecurefunc("BonusObjectiveTracker_AnimateReward", RewardsFrame_SetPosition)

	K:RegisterEvent("ZONE_CHANGED_NEW_AREA", Module.HandleMawBuffsFrame)
	Module:HandleMawBuffsFrame()
end
