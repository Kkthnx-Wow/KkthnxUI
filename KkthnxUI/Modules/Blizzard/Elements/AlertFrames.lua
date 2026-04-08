--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Manages and anchors Blizzard's alert frames and group loot roll frames.
-- - Design: Hooks AlertFrame sub-systems to redirect anchors to a custom mover frame.
-- - Events: Hooked into AlertFrame and GroupLootContainer updates.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Blizzard")

-- PERF: Localize globals and API functions to reduce lookup overhead.
local _G = _G
local CreateFrame = CreateFrame
local UIParent = _G.UIParent
local GroupLootContainer = _G.GroupLootContainer
local AlertFrame = _G.AlertFrame
local hooksecurefunc = hooksecurefunc
local ipairs = ipairs
local select = select
local table_remove = table.remove

-- ---------------------------------------------------------------------------
-- State & Constants
-- ---------------------------------------------------------------------------
local parentFrame
local anchorPosition = "TOP"
local anchorPoint = "BOTTOM"
local anchorYOffset = -6

-- ---------------------------------------------------------------------------
-- Anchor Logic
-- ---------------------------------------------------------------------------
-- REASON: Recalculates anchor direction based on the current position of the AlertFrameMover.
-- This ensures alerts extend towards the center of the screen rather than off-screen.
function Module:AlertFrame_UpdateAnchor()
	local y = select(2, parentFrame:GetCenter())
	local screenHeight = UIParent:GetTop()

	if y > screenHeight / 2 then
		anchorPosition = "TOP"
		anchorPoint = "BOTTOM"
		anchorYOffset = -6
	else
		anchorPosition = "BOTTOM"
		anchorPoint = "TOP"
		anchorYOffset = 6
	end

	self:ClearAllPoints()
	self:SetPoint(anchorPosition, parentFrame)
	GroupLootContainer:ClearAllPoints()
	GroupLootContainer:SetPoint(anchorPosition, parentFrame)
end

-- REASON: Custom positioning for individual loot roll frames to maintain consistency with UI scaling.
function Module:UpdateGroupLootContainer()
	local lastIdx = nil

	for i = 1, self.maxIndex do
		local frame = self.rollFrames[i]
		if frame then
			frame:ClearAllPoints()
			frame:SetPoint("CENTER", self, anchorPosition, 0, self.reservedSize * (i - 1 + 0.5) * anchorYOffset / 6)
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
	self:SetPoint(anchorPosition, relativeAlert, anchorPoint, 0, anchorYOffset)
end

-- REASON: Recursively adjusts anchors for active alert frame pools to ensure they stack correctly.
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

-- REASON: Dispatches the appropriate anchor adjustment function based on the sub-system type.
function Module:AlertFrame_AdjustPosition()
	if self.alertFramePool then
		self.AdjustAnchors = Module.AlertFrame_AdjustQueuedAnchors
	elseif not self.anchorFrame then
		self.AdjustAnchors = Module.AlertFrame_AdjustAnchors
	elseif self.anchorFrame then
		self.AdjustAnchors = Module.AlertFrame_AdjustAnchorsNonAlert
	end
end

-- ---------------------------------------------------------------------------
-- Talking Head Suppression
-- ---------------------------------------------------------------------------
-- REASON: Disables the Talking Head UI if requested by the user to reduce screen clutter.
local function noTalkingHeads()
	if not C["Misc"].NoTalkingHead then
		return
	end

	local talkingHeadFrame = _G.TalkingHeadFrame
	if talkingHeadFrame then
		talkingHeadFrame:UnregisterAllEvents()
		hooksecurefunc(talkingHeadFrame, "Show", function(self)
			self:Hide()
		end)
	end
end

-- ---------------------------------------------------------------------------
-- Module Registration
-- ---------------------------------------------------------------------------
function Module:CreateAlertFrames()
	-- REASON: Entry point for alert frame management; creates the mover and hooks Blizzard's sub-systems.
	parentFrame = CreateFrame("Frame", nil, UIParent)
	parentFrame:SetSize(200, 30)
	K.Mover(parentFrame, "AlertFrameMover", "AlertFrameMover", { "TOP", UIParent, 0, -40 })

	GroupLootContainer:EnableMouse(false)
	GroupLootContainer.ignoreFramePositionManager = true

	-- REASON: Iterate through existing Blizzard sub-systems to apply custom anchoring.
	-- We remove the TalkingHeadFrame sub-system if it exists to handle it independently.
	-- PERF: Iterate backwards when removing elements from a table to avoid index shifts.
	local alertFrameSubSystems = AlertFrame.alertFrameSubSystems
	for i = #alertFrameSubSystems, 1, -1 do
		local alertFrameSubSystem = alertFrameSubSystems[i]
		if alertFrameSubSystem.anchorFrame and alertFrameSubSystem.anchorFrame == _G.TalkingHeadFrame then
			table_remove(alertFrameSubSystems, i)
		else
			Module.AlertFrame_AdjustPosition(alertFrameSubSystem)
		end
	end

	-- WARNING: Hook insecurely to allow dynamic additions of alert sub-systems by other addons or future Blizzard updates.
	hooksecurefunc(AlertFrame, "AddAlertFrameSubSystem", function(_, alertFrameSubSystem)
		Module.AlertFrame_AdjustPosition(alertFrameSubSystem)
	end)

	hooksecurefunc(AlertFrame, "UpdateAnchors", Module.AlertFrame_UpdateAnchor)
	hooksecurefunc("GroupLootContainer_Update", Module.UpdateGroupLootContainer)

	if _G.TalkingHeadFrame then
		noTalkingHeads()
	end
end
