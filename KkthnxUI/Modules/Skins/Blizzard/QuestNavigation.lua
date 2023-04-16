local C = KkthnxUI[2]

local THROTTLE_INTERVAL = 0.5

-- Always show pins in the world, regardless of distance.
function SuperTrackedFrame:GetTargetAlphaBaseValue()
	return 1
end

-- Show time to arrival on pins in the world.
local lastDistance, throttle

local function onUpdate(self, elapsed)
	if self.isClamped then
		self.arrival:Hide()
		lastDistance = nil
		return
	end

	throttle = (throttle or 0) + elapsed
	if throttle >= THROTTLE_INTERVAL then
		local distance = C_Navigation.GetDistance()
		local speed = (lastDistance and (lastDistance - distance) / throttle) or 0
		lastDistance = distance

		if speed > 0 then
			local time = math.abs(distance / speed)
			self.arrival:SetText(TIMER_MINUTES_DISPLAY:format(time / 60, time % 60))
			self.arrival:Show()
		else
			self.arrival:Hide()
		end

		throttle = 0
	end
end

-- Create a font string for showing time to arrival on pins in the world.
local function createArrivalFontString(frame)
	local arrival = frame:CreateFontString("$parentArrival", "BACKGROUND", "GameFontNormal", nil, 1)
	arrival:SetPoint("TOP", frame.DistanceText, "BOTTOM", 0, -2)
	arrival:SetJustifyV("TOP")
	arrival:SetTextColor(0.8, 0.8, 0.8)
	frame.arrival = arrival
end

-- Theme function for Blizzard_QuestNavigation.
C.themes["Blizzard_QuestNavigation"] = function()
	-- Add font string for time to arrival.
	createArrivalFontString(SuperTrackedFrame)

	-- Hook script to update time to arrival.
	SuperTrackedFrame:HookScript("OnUpdate", onUpdate)
end
