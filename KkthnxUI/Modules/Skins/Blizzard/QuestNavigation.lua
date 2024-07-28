local C = KkthnxUI[2]

-- Cache frequently used global variables locally
local TIMER_MINUTES_DISPLAY = TIMER_MINUTES_DISPLAY
local GetDistance, WasClampedToScreen = C_Navigation.GetDistance, C_Navigation.WasClampedToScreen

-- Cache math functions
local math_abs, math_floor = math.abs, math.floor

-- Variables to keep track of distance and update time
local lastDistance, lastUpdate = nil, 0

local function updateArrival(self, elapsed)
	if self.isClamped then
		self.TimeText:Hide()
		lastDistance = nil
		return
	end

	lastUpdate = lastUpdate + elapsed

	-- Update time display only when distance changes and enough time has passed
	local distance = GetDistance()
	if distance ~= lastDistance and lastUpdate >= 0.3 then
		local speed = (((lastDistance or 0) - distance) / lastUpdate) or 0
		lastDistance = distance

		if speed > 0 then
			local time = math_abs(distance / speed)
			self.TimeText:SetText(TIMER_MINUTES_DISPLAY:format(math_floor(time / 60), math_floor(time % 60)))
			self.TimeText:Show()
		else
			self.TimeText:Hide()
		end

		lastUpdate = 0
	end
end

local function updateAlpha(self)
	if not WasClampedToScreen() and GetDistance() > 0 then
		self:SetAlpha(0.9)
	end
end

C.themes["Blizzard_QuestNavigation"] = function()
	local time = SuperTrackedFrame:CreateFontString(nil, "BACKGROUND", "GameFontNormal")
	time:SetPoint("TOP", SuperTrackedFrame.DistanceText, "BOTTOM", 0, -2)
	time:SetHeight(20)
	time:SetJustifyV("TOP")

	SuperTrackedFrame.TimeText = time
	SuperTrackedFrame:HookScript("OnUpdate", updateArrival)

	hooksecurefunc(SuperTrackedFrame, "UpdateAlpha", updateAlpha)
end
