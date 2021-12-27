local K, C = unpack(KkthnxUI)
local Module = K:GetModule("Blizzard")

local _G = _G

local UIParent = _G.UIParent
local hooksecurefunc = _G.hooksecurefunc

local ANCHOR_POINT = "BOTTOM"
local POSITION = "TOP"
local YOFFSET = -10

function Module:PostAlertMove()
	local AlertFrameMover = _G.AlertFrameHolder.Mover
	local AlertFrameHolder = _G.AlertFrameHolder

	local _, y = AlertFrameMover:GetCenter()
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

	local AlertFrame = _G.AlertFrame
	local GroupLootContainer = _G.GroupLootContainer

	local rollBars = K:GetModule("Loot").RollBars
	if C["Loot"].GroupLoot then
		local lastframe, lastShownFrame
		for i, frame in pairs(rollBars) do
			frame:ClearAllPoints()
			if i ~= 1 then
				if POSITION == "TOP" then
					frame:SetPoint("TOP", lastframe, "BOTTOM", 0, -6)
				else
					frame:SetPoint("BOTTOM", lastframe, "TOP", 0, 6)
				end
			else
				if POSITION == "TOP" then
					frame:SetPoint("TOP", AlertFrameHolder, "BOTTOM", 0, -6)
				else
					frame:SetPoint("BOTTOM", AlertFrameHolder, "TOP", 0, 6)
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
	if alertFrameSubSystem.alertFramePool then -- Queued alert system
		alertFrameSubSystem.AdjustAnchors = Module.AdjustQueuedAnchors
	elseif not alertFrameSubSystem.anchorFrame then -- Simple alert system
		alertFrameSubSystem.AdjustAnchors = Module.AdjustAnchors
	elseif alertFrameSubSystem.anchorFrame then -- Anchor frame system
		alertFrameSubSystem.AdjustAnchors = Module.AdjustAnchorsNonAlert
	end
end

local function MoveTalkingHead()
	local TalkingHeadFrame = _G.TalkingHeadFrame
	local AlertFrameHolder = _G.AlertFrameHolder

	TalkingHeadFrame.ignoreFramePositionManager = true
	TalkingHeadFrame:ClearAllPoints()
	TalkingHeadFrame:SetPoint("TOP", AlertFrameHolder, "BOTTOM", 0, 0)

	-- Reset Model Camera
	local model = TalkingHeadFrame.MainFrame.Model
	if model.uiCameraID then
		model:RefreshCamera()
		_G.Model_ApplyUICamera(model, model.uiCameraID)
	end

	for index, alertFrameSubSystem in ipairs(AlertFrame.alertFrameSubSystems) do
		if alertFrameSubSystem.anchorFrame and alertFrameSubSystem.anchorFrame == TalkingHeadFrame then
			tremove(AlertFrame.alertFrameSubSystems, index)
		end
	end
end

local function NoTalkingHeads()
	if not C["Misc"].NoTalkingHead then
		return
	end

	hooksecurefunc(TalkingHeadFrame, "Show", function(self)
		self:Hide()
	end)
end

local function TalkingHeadOnLoad(event, addon)
	if addon == "Blizzard_TalkingHeadUI" then
		MoveTalkingHead()
		NoTalkingHeads()
		K:UnregisterEvent(event, TalkingHeadOnLoad)
	end
end

function Module:CreateAlertFrames()
	local AlertFrameHolder = CreateFrame("Frame", "AlertFrameHolder", UIParent)
	AlertFrameHolder:SetSize(180, 20)
	AlertFrameHolder:SetPoint("TOP", UIParent, "TOP", -1, -18)

	_G.GroupLootContainer:EnableMouse(false) -- Prevent this weird non-clickable area stuff since 8.1; Monitor this, as it may cause addon compatibility.
	_G.UIPARENT_MANAGED_FRAME_POSITIONS.GroupLootContainer = nil

	if not AlertFrameHolder.Mover then
		AlertFrameHolder.Mover = K.Mover(AlertFrameHolder, "AlertFrameMover", "Loot / Alert Frames", {"TOP", UIParent, "TOP", -1, -18})
	else
		AlertFrameHolder.Mover:SetSize(AlertFrameHolder:GetSize())
	end

	-- Replace AdjustAnchors functions to allow alerts to grow down if needed.
	-- We will need to keep an eye on this in case it taints. It shouldn"t, but you never know.
	for _, alertFrameSubSystem in ipairs(_G.AlertFrame.alertFrameSubSystems) do
		AlertSubSystem_AdjustPosition(alertFrameSubSystem)
	end

	-- This should catch any alert systems that are created by other addons
	hooksecurefunc(_G.AlertFrame, "AddAlertFrameSubSystem", function(_, alertFrameSubSystem)
		AlertSubSystem_AdjustPosition(alertFrameSubSystem)
	end)

	hooksecurefunc(_G.AlertFrame, "UpdateAnchors", Module.PostAlertMove)
	hooksecurefunc("GroupLootContainer_Update", Module.GroupLootContainer_Update)

	if IsAddOnLoaded("Blizzard_TalkingHeadUI") then
		MoveTalkingHead()
		NoTalkingHeads()
	else
		K:RegisterEvent("ADDON_LOADED", TalkingHeadOnLoad)
	end
end