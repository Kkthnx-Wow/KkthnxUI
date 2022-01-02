local _, C = unpack(KkthnxUI)

local math_abs = math.abs

-- always show pins in the world, regardless of distance
function SuperTrackedFrame:GetTargetAlphaBaseValue()
	return 1
end

-- show time to arrival on pins in the world
local throttle, lastDistance
local function updateArrival(self, elapsed)
	if self.isClamped then
		self.arrival:Hide()
		lastDistance = nil
		return
	end

	throttle = (throttle or 0) + elapsed
	if throttle >= 0.5 then
		local distance = C_Navigation.GetDistance()
		local speed = (((lastDistance or 0) - distance) / throttle) or 0
		lastDistance = distance

		if speed > 0 then
			local time = math_abs(distance / speed)
			self.arrival:SetText(TIMER_MINUTES_DISPLAY:format(time / 60, time % 60))
			self.arrival:Show()
		else
			self.arrival:Hide()
		end

		throttle = 0
	end
end

C.themes["Blizzard_QuestNavigation"] = function()
	local arrival = SuperTrackedFrame:CreateFontString("$parentArrival", "BACKGROUND", "GameFontNormal")
	arrival:SetPoint("TOP", SuperTrackedFrame.DistanceText, "BOTTOM", 0, -2)
	arrival:SetSize(0, 20)
	arrival:SetJustifyV("TOP")

	SuperTrackedFrame.arrival = arrival
	SuperTrackedFrame:HookScript("OnUpdate", updateArrival)
end