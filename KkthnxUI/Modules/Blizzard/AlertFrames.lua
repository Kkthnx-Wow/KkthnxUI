local K, C = unpack(select(2, ...))
local Module = K:NewModule("AlertFrames", "AceEvent-3.0", "AceHook-3.0")

local _G = _G
local pairs = pairs

local hooksecurefunc = _G.hooksecurefunc

local AlertFrameHolder = CreateFrame("Frame", "AlertFrameHolder", UIParent)
AlertFrameHolder:SetSize(180, 20)
AlertFrameHolder:SetPoint("TOP", UIParent, "TOP", 0, -18)

local POSITION, ANCHOR_POINT, YOFFSET = "TOP", "BOTTOM", -10

function Module:PostAlertMove()
	local _, y = AlertFrameHolder:GetCenter()
	local screenHeight = UIParent:GetTop()
	if y > (screenHeight / 2) then
		POSITION = "TOP"
		ANCHOR_POINT = "BOTTOM"
		YOFFSET = -10
	else
		POSITION = "BOTTOM"
		ANCHOR_POINT = "TOP"
		YOFFSET = 10
	end

	local rollBars = K:GetModule("GroupLoot").RollBars
	if C["Loot"].GroupLoot then
		local lastframe, lastShownFrame
		for i, frame in pairs(rollBars) do
			frame:ClearAllPoints()
			if i ~= 1 then
				if POSITION == "TOP" then
					frame:SetPoint("TOP", lastframe, "BOTTOM", 0, -4)
				else
					frame:SetPoint("BOTTOM", lastframe, "TOP", 0, 4)
				end
			else
				if POSITION == "TOP" then
					frame:SetPoint("TOP", AlertFrameHolder, "BOTTOM", 0, -4)
				else
					frame:SetPoint("BOTTOM", AlertFrameHolder, "TOP", 0, 4)
				end
			end
			lastframe = frame

			if frame:IsShown() then
				lastShownFrame = frame
			end
		end

		AlertFrame:ClearAllPoints()
		GroupLootContainer:ClearAllPoints()

		if lastShownFrame then
			AlertFrame:SetAllPoints(lastShownFrame)
			GroupLootContainer:SetPoint(POSITION, lastShownFrame, ANCHOR_POINT, 0, YOFFSET)
		else
			AlertFrame:SetAllPoints(AlertFrameHolder)
			GroupLootContainer:SetPoint(POSITION, AlertFrameHolder, ANCHOR_POINT, 0, YOFFSET)
		end

		if GroupLootContainer:IsShown() then
			Module.GroupLootContainer_Update(GroupLootContainer)
		end
	else
		AlertFrame:ClearAllPoints()
		AlertFrame:SetAllPoints(AlertFrameHolder)
		GroupLootContainer:ClearAllPoints()
		GroupLootContainer:SetPoint(POSITION, AlertFrameHolder, ANCHOR_POINT, 0, YOFFSET)

		if GroupLootContainer:IsShown() then
			Module.GroupLootContainer_Update(GroupLootContainer)
		end
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
	local lastIdx = nil

	for i = 1, self.maxIndex do
		local frame = self.rollFrames[i]
		local prevFrame = self.rollFrames[i - 1]
		if (frame) then
			frame:ClearAllPoints()
			if prevFrame and not (prevFrame == frame) then
				frame:SetPoint(POSITION, prevFrame, ANCHOR_POINT, 0, YOFFSET)
			else
				frame:SetPoint(POSITION, self, POSITION, 0, 0)
			end
			lastIdx = i
		end
	end

	if (lastIdx) then
		self:SetHeight(self.reservedSize * lastIdx)
		self:Show()
	else
		self:Hide()
	end
end

local function AlertSubSystem_AdjustPosition(alertFrameSubSystem)
	if alertFrameSubSystem.alertFramePool then -- queued alert system
		alertFrameSubSystem.AdjustAnchors = Module.AdjustQueuedAnchors
	elseif not alertFrameSubSystem.anchorFrame then -- simple alert system
		alertFrameSubSystem.AdjustAnchors = Module.AdjustAnchors
	elseif alertFrameSubSystem.anchorFrame then -- anchor frame system
		alertFrameSubSystem.AdjustAnchors = Module.AdjustAnchorsNonAlert
	end
end

function Module:OnEnable()
	if K.CheckAddOnState("MoveAnything") then
		return
	end

	_G.UIPARENT_MANAGED_FRAME_POSITIONS["GroupLootContainer"] = nil
	K.Movers:RegisterFrame(AlertFrameHolder)

	-- Replace AdjustAnchors functions to allow alerts to grow down if needed.
	-- We will need to keep an eye on this in case it taints. It shouldn't, but you never know.
	for _, alertFrameSubSystem in ipairs(AlertFrame.alertFrameSubSystems) do
		AlertSubSystem_AdjustPosition(alertFrameSubSystem)
	end

	-- This should catch any alert systems that are created by other addons
	hooksecurefunc(AlertFrame, "AddAlertFrameSubSystem", function(alertFrameSubSystem)
		AlertSubSystem_AdjustPosition(alertFrameSubSystem)
	end)

	self:SecureHook(AlertFrame, "UpdateAnchors", Module.PostAlertMove)
	hooksecurefunc("GroupLootContainer_Update", Module.GroupLootContainer_Update)
end
