local K, C = unpack(select(2, ...))
local Module = K:GetModule("Blizzard")

local _G = _G
local ipairs = _G.ipairs
local pairs = _G.pairs

local AlertFrame = _G.AlertFrame
local CreateFrame = _G.CreateFrame
local GroupLootContainer = _G.GroupLootContainer
local hooksecurefunc = _G.hooksecurefunc
local UIParent = _G.UIParent

local POSITION, ANCHOR_POINT, YOFFSET = "TOP", "BOTTOM", -18
function Module:PostAlertMove()
	local AlertFrameHolder = _G.AlertFrameHolder

	local _, y = AlertFrameHolder:GetCenter()
	local screenHeight = UIParent:GetTop()
	if y > (screenHeight / 2) then
		POSITION = "TOP"
		ANCHOR_POINT = "BOTTOM"
		YOFFSET = -18
	else
		POSITION = "BOTTOM"
		ANCHOR_POINT = "TOP"
		YOFFSET = 18
	end

	local rollBars = K.GroupLoot.RollBars
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
	local lastIdx

	for i = 1, self.maxIndex do
		local frame = self.rollFrames[i]
		if frame then
			frame:ClearAllPoints()
			local prevFrame = self.rollFrames[i-1]
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
	if alertFrameSubSystem.alertFramePool then -- queued alert system
		alertFrameSubSystem.AdjustAnchors = Module.AdjustQueuedAnchors
	elseif not alertFrameSubSystem.anchorFrame then -- simple alert system
		alertFrameSubSystem.AdjustAnchors = Module.AdjustAnchors
	elseif alertFrameSubSystem.anchorFrame then -- anchor frame system
		alertFrameSubSystem.AdjustAnchors = Module.AdjustAnchorsNonAlert
	end
end

function Module:CreateAlertFrames()
	local AlertFrameHolder = CreateFrame("Frame", "AlertFrameHolder", UIParent)
	AlertFrameHolder:SetSize(180, 20)
	AlertFrameHolder:SetHeight(20)

	_G.GroupLootContainer:EnableMouse(false) -- Prevent this weird non-clickable area stuff since 8.1; Monitor this, as it may cause addon compatibility.
	_G.UIPARENT_MANAGED_FRAME_POSITIONS.GroupLootContainer = nil
	K.Mover(AlertFrameHolder, "AlertFrame/GroupLoot", "AlertFrame/GroupLoot", {"TOP", UIParent, "TOP", 0, -18})

	-- Replace AdjustAnchors functions to allow alerts to grow down if needed.
	-- We will need to keep an eye on this in case it taints. It shouldn"t, but you never know.
	for _, alertFrameSubSystem in ipairs(_G.AlertFrame.alertFrameSubSystems) do
		AlertSubSystem_AdjustPosition(alertFrameSubSystem)
	end

	-- This should catch any alert systems that are created by other addons
	hooksecurefunc(_G.AlertFrame, "AddAlertFrameSubSystem", function(_, alertFrameSubSystem)
		AlertSubSystem_AdjustPosition(alertFrameSubSystem)
	end)

	hooksecurefunc(AlertFrame, "UpdateAnchors", Module.PostAlertMove)
	hooksecurefunc("GroupLootContainer_Update", Module.GroupLootContainer_Update)
end