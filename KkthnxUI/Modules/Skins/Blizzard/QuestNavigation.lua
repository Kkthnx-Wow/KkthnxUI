--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Skins the Blizzard Quest Navigation (Super Track) frame.
-- - Design: Adds arrival time estimation and skins the distance text.
-- - Events: N/A
-----------------------------------------------------------------------------]]

local C = KkthnxUI[2]

-- REASON: Localize globals for performance and stack safety.
local _G = _G
local math_abs = _G.math.abs
local math_floor = _G.math.floor
local math_max = _G.math.max
local hooksecurefunc = _G.hooksecurefunc

local C_Navigation = _G.C_Navigation
local SuperTrackedFrame = _G.SuperTrackedFrame
local TIMER_MINUTES_DISPLAY = _G.TIMER_MINUTES_DISPLAY

local GetDistance = C_Navigation and C_Navigation.GetDistance
local WasClampedToScreen = C_Navigation and C_Navigation.WasClampedToScreen

-- Variables to keep track of distance and update time
local lastDistance, lastUpdate = nil, 0
local emaSpeed -- exponentially smoothed speed (yards/sec)

local function updateArrival(self, elapsed)
	if not C_Navigation or not GetDistance then
		return
	end

	if self.isClamped then
		if self.TimeText then
			self.TimeText:Hide()
		end
		lastDistance, lastUpdate, emaSpeed = nil, 0, nil
		return
	end

	lastUpdate = (lastUpdate or 0) + (elapsed or 0)
	if lastUpdate < 0.5 then
		return
	end

	local distance = GetDistance() or 0
	if distance <= 0 then
		if self.TimeText then
			self.TimeText:Hide()
		end
		lastDistance, lastUpdate = distance, 0
		return
	end

	local prev = lastDistance or distance
	local instSpeed = (prev - distance) / lastUpdate -- yards/s; positive when approaching
	lastDistance = distance
	lastUpdate = 0

	if not instSpeed or instSpeed <= 0 then
		if self.TimeText then
			self.TimeText:Hide()
		end
		return
	end

	-- Exponential moving average to reduce flicker
	if emaSpeed then
		emaSpeed = emaSpeed * 0.6 + instSpeed * 0.4
	else
		emaSpeed = instSpeed
	end

	local safeSpeed = math_max(emaSpeed, 0.1)
	local eta = math_abs(distance / safeSpeed)
	local minutes = math_floor(eta / 60)
	local seconds = math_floor(eta % 60)

	if self.TimeText then
		self.TimeText:SetText(TIMER_MINUTES_DISPLAY:format(minutes, seconds))
		self.TimeText:Show()
	end
end

local function updateAlpha(self)
	if not WasClampedToScreen or not GetDistance then
		return
	end
	local clamped = WasClampedToScreen()
	local dist = GetDistance() or 0
	if not clamped and dist > 0 then
		self:SetAlpha(1)
	end
end

local function SetupQuestNavigation()
	if not SuperTrackedFrame or not SuperTrackedFrame.DistanceText then
		return
	end

	-- Create or reuse the timer text
	if not SuperTrackedFrame.TimeText then
		local time = SuperTrackedFrame:CreateFontString(nil, "BACKGROUND", "GameFontNormal")
		time:SetPoint("TOP", SuperTrackedFrame.DistanceText, "BOTTOM", 0, -2)
		time:SetHeight(20)
		time:SetJustifyV("TOP")
		time:SetWordWrap(false) -- avoid wrapping; let width be automatic
		SuperTrackedFrame.TimeText = time
	end

	-- Hook updates (idempotent hooks are safe)
	SuperTrackedFrame:HookScript("OnUpdate", updateArrival)
	hooksecurefunc(SuperTrackedFrame, "UpdateAlpha", updateAlpha)
end

-- REASON: Main entry point for Blizzard Quest Navigation skinning.
C.themes["Blizzard_QuestNavigation"] = function()
	SetupQuestNavigation()
end
