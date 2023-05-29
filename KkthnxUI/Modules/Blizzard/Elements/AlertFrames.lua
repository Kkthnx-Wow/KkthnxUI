local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Blizzard")

local UIParent = UIParent
local hooksecurefunc = hooksecurefunc

local ANCHOR_POINT = "BOTTOM"
local POSITION = "TOP"
local YOFFSET = -6

local AlertFrameHolder

function Module:UpdateAnchors()
	local AlertFrameMover = _G.KKUI_AlertFrameHolder.Mover
	local AlertFrameHolder = _G.KKUI_AlertFrameHolder

	local _, y = AlertFrameMover:GetCenter()
	local screenHeight = UIParent:GetTop()
	if y > (screenHeight * 0.5) then
		POSITION = "TOP"
		ANCHOR_POINT = "BOTTOM"
		YOFFSET = -6
	else
		POSITION = "BOTTOM"
		ANCHOR_POINT = "TOP"
		YOFFSET = 6
	end

	local AlertFrame = _G.AlertFrame
	local GroupLootContainer = _G.GroupLootContainer

	AlertFrame:ClearAllPoints()
	GroupLootContainer:ClearAllPoints()

	local lastRollFrame = C["Loot"].GroupLoot and K:GetModule("Loot"):UpdateLootRollAnchors(POSITION)
	if lastRollFrame then
		AlertFrame:SetAllPoints(lastRollFrame)
		GroupLootContainer:SetPoint(POSITION, lastRollFrame, ANCHOR_POINT, 0, YOFFSET)
	else
		AlertFrame:SetAllPoints(AlertFrameHolder)
		GroupLootContainer:SetPoint(POSITION, AlertFrameHolder, ANCHOR_POINT, 0, YOFFSET)
	end

	if GroupLootContainer:IsShown() then
		Module.GroupLootContainer_Update(GroupLootContainer)
	end
end

function Module:AdjustAnchors(relativeAlert)
	if self.alertFrame:IsShown() then
		self.alertFrame:ClearAllPoints()
		self.alertFrame:SetPoint(POSITION, relativeAlert, ANCHOR_POINT, 0, YOFFSET)
		return self.alertFrame
	end
	return relativeAlert
end

function Module:AdjustAnchorsNonAlert(relativeAlert)
	if self.anchorFrame:IsShown() then
		self.anchorFrame:ClearAllPoints()
		self.anchorFrame:SetPoint(POSITION, relativeAlert, ANCHOR_POINT, 0, YOFFSET)
		return self.anchorFrame
	end
	return relativeAlert
end

function Module:AdjustQueuedAnchors(relativeAlert)
	for alertFrame in self.alertFramePool:EnumerateActive() do
		alertFrame:ClearAllPoints()
		alertFrame:SetPoint(POSITION, relativeAlert, ANCHOR_POINT, 0, YOFFSET)
		relativeAlert = alertFrame
	end
	return relativeAlert
end

function Module:GroupLootContainer_Update()
	local lastIdx

	for i = 1, self.maxIndex do
		local frame = self.rollFrames[i]
		if frame then
			frame:ClearAllPoints()

			local prevFrame = self.rollFrames[i - 1]
			if prevFrame and prevFrame ~= frame then
				frame:SetPoint(POSITION, prevFrame, ANCHOR_POINT, 0, YOFFSET)
			else
				frame:SetPoint(POSITION, self, POSITION, 0, YOFFSET)
			end

			lastIdx = i
		end
	end

	if lastIdx then
		self:SetHeight(self.reservedSize * lastIdx)
		self:Show()
	else
		self:Hide()
	end
end

local function AlertSubSystem_AdjustPosition(alertFrameSubSystem)
	if alertFrameSubSystem.alertFramePool then --queued alert system
		alertFrameSubSystem.AdjustAnchors = Module.AdjustQueuedAnchors
	elseif not alertFrameSubSystem.anchorFrame then --simple alert system
		alertFrameSubSystem.AdjustAnchors = Module.AdjustAnchors
	elseif alertFrameSubSystem.anchorFrame then --anchor frame system
		alertFrameSubSystem.AdjustAnchors = Module.AdjustAnchorsNonAlert
	end
end

local function NoTalkingHeads()
	if not C["Misc"].NoTalkingHead then
		return
	end

	TalkingHeadFrame:UnregisterAllEvents() -- needs review
	hooksecurefunc(TalkingHeadFrame, "Show", function(self)
		self:Hide()
	end)
end

function Module:CreateAlertFrames()
	AlertFrameHolder = CreateFrame("Frame", "KKUI_AlertFrameHolder", UIParent)
	AlertFrameHolder:SetSize(180, 20)
	AlertFrameHolder:SetPoint("TOP", UIParent, "TOP", -1, -18)

	GroupLootContainer:EnableMouse(false)
	GroupLootContainer.ignoreFramePositionManager = true

	if not AlertFrameHolder.Mover then
		AlertFrameHolder.Mover = K.Mover(AlertFrameHolder, "AlertFrameMover", "AlertFrameMover", { "TOP", UIParent, "TOP", 0, -140 })
	else
		AlertFrameHolder.Mover:SetSize(AlertFrameHolder:GetSize())
	end

	for index, alertFrameSubSystem in ipairs(AlertFrame.alertFrameSubSystems) do
		if alertFrameSubSystem.anchorFrame and alertFrameSubSystem.anchorFrame == TalkingHeadFrame then
			tremove(AlertFrame.alertFrameSubSystems, index)
		else
			AlertSubSystem_AdjustPosition(alertFrameSubSystem)
		end
	end

	hooksecurefunc(AlertFrame, "AddAlertFrameSubSystem", function(_, alertFrameSubSystem)
		AlertSubSystem_AdjustPosition(alertFrameSubSystem)
	end)

	hooksecurefunc(_G.AlertFrame, "UpdateAnchors", Module.UpdateAnchors)
	hooksecurefunc("GroupLootContainer_Update", Module.GroupLootContainer_Update)

	if TalkingHeadFrame then
		NoTalkingHeads()
	end
end
