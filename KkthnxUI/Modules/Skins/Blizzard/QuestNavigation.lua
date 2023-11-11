local C = KkthnxUI[2]

local abs = math.abs
local C_Navigation_GetDistance = C_Navigation.GetDistance

local THROTTLE_INTERVAL = 0.5
local lastDistance, throttle

-- Create a backup of the original function
local originalGetTargetAlphaBaseValue = _G.SuperTrackedFrame.GetTargetAlphaBaseValue

-- Replace the original function with the modified version
_G.SuperTrackedFrame.GetTargetAlphaBaseValue = function(frame)
	if C_Navigation_GetDistance() > 999 then
		return 1
	else
		return originalGetTargetAlphaBaseValue(frame)
	end
end

local function onUpdate(self, elapsed)
	if self.isClamped then
		self.arrival:Hide()
		lastDistance = nil
		return
	end

	throttle = (throttle or 0) + elapsed
	if throttle >= THROTTLE_INTERVAL then
		local distance = C_Navigation_GetDistance()
		local speed = lastDistance and (lastDistance - distance) / throttle or 0
		lastDistance = distance

		if speed > 0 then
			local time = abs(distance / speed)
			self.arrival:SetText(TIMER_MINUTES_DISPLAY:format(time / 60, time % 60))
			self.arrival:Show()
		else
			self.arrival:Hide()
		end

		throttle = 0
	end
end

local function createArrivalFontString(frame)
	local arrival = frame:CreateFontString("$parentArrival", "BACKGROUND", "GameFontNormal", nil, 1)
	arrival:SetPoint("TOP", frame.DistanceText, "BOTTOM", 0, -2)
	arrival:SetJustifyV("TOP")
	arrival:SetTextColor(0.8, 0.8, 0.8)
	frame.arrival = arrival
end

C.themes["Blizzard_QuestNavigation"] = function()
	createArrivalFontString(SuperTrackedFrame)
	SuperTrackedFrame:HookScript("OnUpdate", onUpdate)
end
