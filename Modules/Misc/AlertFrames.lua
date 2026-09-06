--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/Misc/AlertFrames.lua
	Purpose:
		Collect Blizzard's alert popups (achievements, loot rolls, world quest
		rewards, and the rest) onto one movable anchor near the top of the screen,
		and make the group-loot roll bars stack in the same column with a
		configurable gap. Optionally silences the Talking Head frame.

		Everything runs through hooksecurefunc, so no secure path is tainted. The
		anchor is a standard KkthnxUI mover, so it drags and resets like every
		other frame. Stacking sorts by the order alerts appeared, so a new popup
		always lands at the end of the column instead of jumping the queue.

		Retail only.
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]

if not (K.Client and K.Client.IsRetail) then
	return
end

local Module = K:NewModule("AlertFrames")

local _G = _G
local ipairs = ipairs
local select = select
local tremove = table.remove
local wipe = wipe

local CreateFrame = CreateFrame
local UIParent = UIParent
local AlertFrame = AlertFrame
local GroupLootContainer = GroupLootContainer

-- Toast art (achievement/loot templates) carries transparent padding that reads
-- as an extra gap when we anchor frame edges, so trim pulls the stack tighter.
local STACK_ART_TRIM = 6

-- Current stacking direction, resynced from the mover before every anchor pass.
local POSITION, ANCHOR_POINT = "TOP", "BOTTOM"
local parentFrame

-- Monotonic counter stamped on each alert as it appears, so the stack keeps the
-- order alerts arrived in rather than pool-enumeration order.
local showSequence = 0
local hooksInstalled = false
local talkingHeadHidden = false

local function IsActive()
	return C.AlertFrames and C.AlertFrames.Enable and parentFrame ~= nil
end

local function GetStackYOffset()
	local spacing = (C.AlertFrames.StackSpacing or 0) + STACK_ART_TRIM
	if POSITION == "TOP" then
		return -spacing
	end
	return spacing
end

-- ---------------------------------------------------------------------------
-- Stack ordering
--   Enumerate the active alerts of a pool, drop hidden ones (a frame can still
--   read active while its anchors are cleared mid-release), and order them by
--   appearance. Frame objects and GetTop() are never compared: tables cannot
--   use <, and cleared anchors make GetTop() nil or secret during release.
-- ---------------------------------------------------------------------------
local scratchAlerts = {}
local scratchSeen = {}
local scratchOrder = {}

local function QueuedAlertsInStackOrder(pool)
	wipe(scratchAlerts)
	wipe(scratchSeen)
	wipe(scratchOrder)
	local collectIdx = 0
	for alert in pool:EnumerateActive() do
		if alert:IsShown() and not scratchSeen[alert] then
			scratchSeen[alert] = true
			collectIdx = collectIdx + 1
			scratchOrder[alert] = collectIdx
			scratchAlerts[#scratchAlerts + 1] = alert
		end
	end
	table.sort(scratchAlerts, function(a, b)
		local orderA, orderB = a.KKUI_ShowSequence or 0, b.KKUI_ShowSequence or 0
		if orderA ~= orderB then
			return orderA < orderB
		end
		return (scratchOrder[a] or 0) < (scratchOrder[b] or 0)
	end)
	return scratchAlerts
end

-- ---------------------------------------------------------------------------
-- Anchor chain
-- ---------------------------------------------------------------------------
local function SetAlertPoint(self, relativeAlert)
	self:ClearAllPoints()
	self:SetPoint(POSITION, relativeAlert, ANCHOR_POINT, 0, GetStackYOffset())
end

local function AdjustQueuedAnchors(self, relativeAlert)
	local alerts = QueuedAlertsInStackOrder(self.alertFramePool)
	for i = 1, #alerts do
		SetAlertPoint(alerts[i], relativeAlert)
		relativeAlert = alerts[i]
	end
	return relativeAlert
end

local function AdjustAnchors(self, relativeAlert)
	if self.alertFrame:IsShown() then
		SetAlertPoint(self.alertFrame, relativeAlert)
		return self.alertFrame
	end
	return relativeAlert
end

local function AdjustAnchorsNonAlert(self, relativeAlert)
	if self.anchorFrame:IsShown() then
		SetAlertPoint(self.anchorFrame, relativeAlert)
		return self.anchorFrame
	end
	return relativeAlert
end

-- Swap in the right anchor routine for a subsystem based on how it stores its
-- frames (pooled queue, single alert frame, or a plain anchor frame).
local function AdjustPosition(subSystem)
	if subSystem.alertFramePool then
		subSystem.AdjustAnchors = AdjustQueuedAnchors
	elseif not subSystem.anchorFrame then
		subSystem.AdjustAnchors = AdjustAnchors
	else
		subSystem.AdjustAnchors = AdjustAnchorsNonAlert
	end
end

-- Flip stacking direction depending on which half of the screen the mover sits
-- in, then point Blizzard's own base anchor (and the loot container) at it.
local function SyncAnchorDirection(alertContainer)
	local y = select(2, parentFrame:GetCenter())
	local screenHeight = UIParent:GetTop()
	if y and screenHeight and y > screenHeight / 2 then
		POSITION, ANCHOR_POINT = "TOP", "BOTTOM"
	else
		POSITION, ANCHOR_POINT = "BOTTOM", "TOP"
	end

	if alertContainer.SetBaseAnchorFrame then
		alertContainer:SetBaseAnchorFrame(parentFrame)
	end
	if GroupLootContainer then
		GroupLootContainer:ClearAllPoints()
		GroupLootContainer:SetPoint(POSITION, parentFrame)
	end
end

-- Re-run the whole anchor chain with the current direction and spacing. The
-- Blizzard post-hook can fire before direction is synced, so this settles it.
local function RepositionAllAlerts(alertContainer)
	if alertContainer.CleanAnchorPriorities then
		alertContainer:CleanAnchorPriorities()
	end
	local relativeFrame = alertContainer.baseAnchorFrame or alertContainer
	for _, subSystem in ipairs(alertContainer.alertFrameSubSystems) do
		AdjustPosition(subSystem)
		local resultFrame = subSystem:AdjustAnchors(relativeFrame)
		if not resultFrame or not resultFrame.IsInDefaultPosition or resultFrame:IsInDefaultPosition() then
			relativeFrame = resultFrame
		end
	end
end

local function OnUpdateAnchors(alertContainer)
	if not IsActive() then
		return
	end
	SyncAnchorDirection(alertContainer)
	RepositionAllAlerts(alertContainer)
	if GroupLootContainer and _G.GroupLootContainer_Update then
		_G.GroupLootContainer_Update(GroupLootContainer)
	end
end

-- Stack the group-loot roll bars in the same column and collapse to nothing when
-- there are no active rolls.
local function OnGroupLootUpdate(self)
	if not IsActive() then
		return
	end
	local yOffset = GetStackYOffset()
	local lastIdx
	for i = 1, self.maxIndex do
		local frame = self.rollFrames[i]
		if frame then
			frame:ClearAllPoints()
			frame:SetPoint("CENTER", self, POSITION, 0, self.reservedSize * (i - 1 + 0.5) * yOffset / 10)
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

local function RefreshLayout()
	if not IsActive() then
		return
	end
	if AlertFrame and AlertFrame.UpdateAnchors then
		AlertFrame:UpdateAnchors()
	end
	if GroupLootContainer and _G.GroupLootContainer_Update then
		_G.GroupLootContainer_Update(GroupLootContainer)
	end
end

-- ---------------------------------------------------------------------------
-- Talking Head
-- ---------------------------------------------------------------------------
local function HideTalkingHead()
	if not (C.AlertFrames and C.AlertFrames.HideTalkingHead) then
		return
	end
	local frame = _G.TalkingHeadFrame
	if not frame or talkingHeadHidden then
		return
	end
	talkingHeadHidden = true
	frame:UnregisterAllEvents()
	hooksecurefunc(frame, "Show", function(self)
		self:Hide()
	end)
end

-- ---------------------------------------------------------------------------
-- Hook installation
-- ---------------------------------------------------------------------------
local function InstallHooks()
	if hooksInstalled then
		return
	end
	hooksInstalled = true

	GroupLootContainer:EnableMouse(false)
	GroupLootContainer.ignoreFramePositionManager = true

	-- Take the Talking Head subsystem out of the alert stack (we place or hide it
	-- ourselves) and prime the anchor routine on every other subsystem.
	for index = #AlertFrame.alertFrameSubSystems, 1, -1 do
		local subSystem = AlertFrame.alertFrameSubSystems[index]
		if subSystem.anchorFrame and subSystem.anchorFrame == _G.TalkingHeadFrame then
			tremove(AlertFrame.alertFrameSubSystems, index)
		else
			AdjustPosition(subSystem)
		end
	end

	hooksecurefunc(AlertFrame, "AddAlertFrameSubSystem", function(_, subSystem)
		AdjustPosition(subSystem)
	end)
	hooksecurefunc(AlertFrame, "UpdateAnchors", OnUpdateAnchors)
	hooksecurefunc("GroupLootContainer_Update", OnGroupLootUpdate)

	-- Stamp appearance order so the stack keeps the sequence alerts arrived in.
	if _G.AlertFrame_ShowNewAlert then
		hooksecurefunc("AlertFrame_ShowNewAlert", function(frame)
			showSequence = showSequence + 1
			frame.KKUI_ShowSequence = showSequence
		end)
	end
end

-- ---------------------------------------------------------------------------
-- Lifecycle
-- ---------------------------------------------------------------------------
function Module:ADDON_LOADED(_, addon)
	if addon == "Blizzard_TalkingHeadUI" then
		HideTalkingHead()
	end
end

-- Re-run when the stack-spacing slider changes so it applies live.
function Module:Refresh()
	RefreshLayout()
end

function Module:OnEnable()
	if not (C.AlertFrames and C.AlertFrames.Enable) then
		return
	end
	if self.setupDone then
		return
	end
	self.setupDone = true

	parentFrame = CreateFrame("Frame", nil, UIParent)
	parentFrame:SetSize(200, 30)
	K.CreateMover(parentFrame, "AlertFrames", L["Alert Frames"], { "TOP", UIParent, "TOP", 0, -40 })

	InstallHooks()
	RefreshLayout()
	HideTalkingHead()

	self:RegisterEvent("ADDON_LOADED")
end
