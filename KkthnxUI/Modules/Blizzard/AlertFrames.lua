local K, C, L = unpack(select(2, ...))
local AlertFrames = K:NewModule("AlertFrames", "AceEvent-3.0", "AceHook-3.0")

-- Wow Lua
local _G = _G
local pairs = pairs

-- WoW API
local MAX_ACHIEVEMENT_ALERTS = _G.MAX_ACHIEVEMENT_ALERTS
local UIParent = _G.UIParent
local hooksecurefunc = _G.hooksecurefunc

-- Global variables that we don"t cache, list them here for mikk"s FindGlobals script
-- GLOBALS: AchievementAlertFrame1, CriteriaAlertFrame1, ChallengeModeAlertFrame1
-- GLOBALS: AlertFrame, AlertFrameMover, MissingLootFrame, GroupLootContainer
-- GLOBALS: DungeonCompletionAlertFrame1, StorePurchaseAlertFrame, ScenarioAlertFrame1
-- GLOBALS: GarrisonMissionAlertFrame, GarrisonFollowerAlertFrame, GarrisonShipFollowerAlertFrame
-- GLOBALS: GarrisonShipMissionAlertFrame, UIPARENT_MANAGED_FRAME_POSITIONS
-- GLOBALS: GuildChallengeAlertFrame, DigsiteCompleteToastFrame, GarrisonBuildingAlertFrame
-- GLOBALS: LOOT_WON_ALERT_FRAMES, LOOT_UPGRADE_ALERT_FRAMES, MONEY_WON_ALERT_FRAMES

local AlertFrameHolder = CreateFrame("Frame", "AlertFrameHolder", UIParent)
AlertFrameHolder:SetWidth(180)
AlertFrameHolder:SetHeight(20)
AlertFrameHolder:SetPoint("TOP", UIParent, "TOP", 0, -18)

local POSITION, ANCHOR_POINT, YOFFSET = "TOP", "BOTTOM", -10
local FORCE_POSITION = false

function AlertFrames:PostAlertMove(screenQuadrant)
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
			AlertFrames.GroupLootContainer_Update(GroupLootContainer)
		end
	else
		AlertFrame:ClearAllPoints()
		AlertFrame:SetAllPoints(AlertFrameHolder)
		GroupLootContainer:ClearAllPoints()
		GroupLootContainer:SetPoint(POSITION, AlertFrameHolder, ANCHOR_POINT, 0, YOFFSET)
		if GroupLootContainer:IsShown() then
			AlertFrames.GroupLootContainer_Update(GroupLootContainer)
		end
	end
end

function AlertFrames:AdjustAnchors(relativeAlert)
	if self.alertFrame:IsShown() then
		self.alertFrame:ClearAllPoints()
		self.alertFrame:SetPoint(POSITION, relativeAlert, ANCHOR_POINT, 0, YOFFSET)
		return self.alertFrame
	end
	return relativeAlert
end

function AlertFrames:AdjustQueuedAnchors(relativeAlert)
	for alertFrame in self.alertFramePool:EnumerateActive() do
		alertFrame:ClearAllPoints()
		alertFrame:SetPoint(POSITION, relativeAlert, ANCHOR_POINT, 0, YOFFSET)
		relativeAlert = alertFrame
	end
	return relativeAlert
end

function AlertFrames:GroupLootContainer_Update()
	local lastIdx = nil

	for i = 1, self.maxIndex do
		local frame = self.rollFrames[i]
		local prevFrame = self.rollFrames[i-1]
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
	if alertFrameSubSystem.alertFramePool then --queued alert system
		alertFrameSubSystem.AdjustAnchors = AlertFrames.AdjustQueuedAnchors
	elseif not alertFrameSubSystem.anchorFrame then --simple alert system
		alertFrameSubSystem.AdjustAnchors = AlertFrames.AdjustAnchors
	end
end

function AlertFrames:OnEnable()
	if K.IsAddOnEnabled("MoveAnything") then return end

	UIPARENT_MANAGED_FRAME_POSITIONS["GroupLootContainer"] = nil
	K.Movers:RegisterFrame(AlertFrameHolder)

	-- Replace AdjustAnchors functions to allow alerts to grow down if needed.
	-- We will need to keep an eye on this in case it taints. It shouldn't, but you never know.
	for i, alertFrameSubSystem in ipairs(AlertFrame.alertFrameSubSystems) do
		AlertSubSystem_AdjustPosition(alertFrameSubSystem)
	end

	-- This should catch any alert systems that are created by other addons
	hooksecurefunc(AlertFrame, "AddAlertFrameSubSystem", function(self, alertFrameSubSystem)
		AlertSubSystem_AdjustPosition(alertFrameSubSystem)
	end)

	self:SecureHook(AlertFrame, "UpdateAnchors", AlertFrames.PostAlertMove)
	hooksecurefunc("GroupLootContainer_Update", AlertFrames.GroupLootContainer_Update)

	-- Code you can use for alert testing
	-- Queued Alerts:
	-- /run AchievementAlertSystem:AddAlert(5192)
	-- /run CriteriaAlertSystem:AddAlert(9023, "Doing great!")
	-- /run LootAlertSystem:AddAlert("\124cffa335ee\124Hitem:18832::::::::::\124h[Brutality Blade]\124h\124r", 1, 1, 1, 1, false, false, 0, false, false)
	-- /run LootUpgradeAlertSystem:AddAlert("\124cffa335ee\124Hitem:18832::::::::::\124h[Brutality Blade]\124h\124r", 1, 1, 1, nil, nil, false)
	-- /run MoneyWonAlertSystem:AddAlert(815)
	-- /run NewRecipeLearnedAlertSystem:AddAlert(204)
	--
	-- --Simple Alerts
	-- /run GuildChallengeAlertSystem:AddAlert(3, 2, 5)
	-- /run InvasionAlertSystem:AddAlert(1)
	-- /run WorldQuestCompleteAlertSystem:AddAlert(112)
	-- /run GarrisonBuildingAlertSystem:AddAlert("Barracks")
	-- /run GarrisonFollowerAlertSystem:AddAlert(204, "Ben Stone", 90, 3, false)
	-- /run GarrisonMissionAlertSystem:AddAlert(681) (Requires a mission ID that is in your mission list.)
	-- /run GarrisonShipFollowerAlertSystem:AddAlert(592, "Test", "Transport", "GarrBuilding_Barracks_1_H", 3, 2, 1)
	-- /run LegendaryItemAlertSystem:AddAlert("\124cffa335ee\124Hitem:18832::::::::::\124h[Brutality Blade]\124h\124r")
	-- /run StorePurchaseAlertSystem:AddAlert("\124cffa335ee\124Hitem:180545::::::::::\124h[Mystic Runesaber]\124h\124r", "", "", 214)
	-- /run DigsiteCompleteAlertSystem:AddAlert(1)
end