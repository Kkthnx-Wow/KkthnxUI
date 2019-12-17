local K = unpack(select(2, ...))
local Module = K:GetModule("Blizzard")

local _G = _G

local UIParent = _G.UIParent
local AlertFrame = _G.AlertFrame
local GroupLootContainer = _G.GroupLootContainer
local CreateFrame = _G.CreateFrame
local hooksecurefunc = _G.hooksecurefunc

local POSITION, ANCHOR_POINT, YOFFSET = "TOP", "BOTTOM", -10
local AlertFrameMover

function Module:AlertFrame_UpdateAnchor()
	local y = select(2, AlertFrameMover:GetCenter())
	local screenHeight = UIParent:GetTop()
	if y > screenHeight/2 then
		POSITION = "TOP"
		ANCHOR_POINT = "BOTTOM"
		YOFFSET = -10
	else
		POSITION = "BOTTOM"
		ANCHOR_POINT = "TOP"
		YOFFSET = 10
	end

	self:ClearAllPoints()
	self:SetPoint(POSITION, AlertFrameMover)
end

function Module:UpdatGroupLootContainer()
	local lastIdx = nil

	for i = 1, self.maxIndex do
		local frame = self.rollFrames[i]
		if frame then
			frame:ClearAllPoints()
			frame:SetPoint("CENTER", self, POSITION, 0, self.reservedSize * (i - 1 + 0.5) * YOFFSET / 10)
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

function Module:AlertFrame_SetPoint(relativeAlert)
	self:ClearAllPoints()
	self:SetPoint(POSITION, relativeAlert, ANCHOR_POINT, 0, YOFFSET)
end

function Module:AlertFrame_AdjustQueuedAnchors(relativeAlert)
	for alertFrame in self.alertFramePool:EnumerateActive() do
		Module.AlertFrame_SetPoint(alertFrame, relativeAlert)
		relativeAlert = alertFrame
	end

	return relativeAlert
end

function Module:AlertFrame_AdjustAnchors(relativeAlert)
	if self.alertFrame:IsShown() then
		Module.AlertFrame_SetPoint(self.alertFrame, relativeAlert)
		return self.alertFrame
	end

	return relativeAlert
end

function Module:AlertFrame_AdjustAnchorsNonAlert(relativeAlert)
	if self.anchorFrame:IsShown() then
		Module.AlertFrame_SetPoint(self.anchorFrame, relativeAlert)
		return self.anchorFrame
	end

	return relativeAlert
end

function Module:AlertFrame_AdjustPosition()
	if self.alertFramePool then
		self.AdjustAnchors = Module.AlertFrame_AdjustQueuedAnchors
	elseif not self.anchorFrame then
		self.AdjustAnchors = Module.AlertFrame_AdjustAnchors
	elseif self.anchorFrame then
		self.AdjustAnchors = Module.AlertFrame_AdjustAnchorsNonAlert
	end
end

function Module:CreateAlertFrames()
	if K.CheckAddOnState("MoveAnything") then
		return
	end

	AlertFrameMover = CreateFrame("Frame", "AlertFrameMover", UIParent)
	AlertFrameMover:SetWidth(180)
	AlertFrameMover:SetHeight(20)
	AlertFrameMover:SetPoint("TOP", UIParent, "TOP", 0, -40)

	K.Mover(AlertFrameMover, "AlertFrame/GroupLoot", "AlertFrame/GroupLoot", {"TOP", UIParent, 0, -40})

	GroupLootContainer:EnableMouse(false)
	GroupLootContainer.ignoreFramePositionManager = true

	for _, alertFrameSubSystem in ipairs(AlertFrame.alertFrameSubSystems) do
		Module.AlertFrame_AdjustPosition(alertFrameSubSystem)
	end

	hooksecurefunc(AlertFrame, "AddAlertFrameSubSystem", function(_, alertFrameSubSystem)
		Module.AlertFrame_AdjustPosition(alertFrameSubSystem)
	end)

	hooksecurefunc(AlertFrame, "UpdateAnchors", Module.AlertFrame_UpdateAnchor)
end