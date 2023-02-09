local _, C = unpack(KkthnxUI)

-- Returns the base value for target alpha, which is always 1
local function getTargetAlphaBaseValue()
	return 1
end

-- Updates the arrival time display on the SuperTrackedFrame
local function updateArrival(superTrackedFrame, elapsed)
	-- Increase the throttle by the elapsed time
	local throttle = (superTrackedFrame.throttle or 0) + elapsed
	-- If the throttle is less than 0.5, return without doing anything
	if throttle < 0.5 then
		return
	end

	-- Get the current distance
	local distance = C_Navigation.GetDistance()
	-- Calculate the speed based on the last distance and the elapsed time
	local speed = (((superTrackedFrame.lastDistance or 0) - distance) / throttle) or 0
	-- Store the current distance as the last distance
	superTrackedFrame.lastDistance = distance

	-- If the frame is clamped, hide the arrival time display and reset throttle and last distance
	if superTrackedFrame.isClamped then
		superTrackedFrame.arrival:Hide()
		superTrackedFrame.lastDistance = nil
		superTrackedFrame.throttle = 0
		return
	end

	-- If the speed is greater than 0, calculate and display the arrival time
	if speed > 0 then
		local time = math.abs(distance / speed)
		local minutes = math.floor(time / 60)
		local seconds = math.floor(time % 60)
		superTrackedFrame.arrival:SetText(string.format("%d:%02d", minutes, seconds))
		superTrackedFrame.arrival:Show()
	else
		-- If the speed is not greater than 0, hide the arrival time display
		superTrackedFrame.arrival:Hide()
	end

	-- Reset the throttle
	superTrackedFrame.throttle = 0
end

-- Adds the arrival time display to the SuperTrackedFrame
C.themes["Blizzard_QuestNavigation"] = function()
	-- Set the OnUpdate script for the SuperTrackedFrame
	SuperTrackedFrame:SetScript("OnUpdate", updateArrival)

	-- Create the arrival time display font string
	local arrival = SuperTrackedFrame:CreateFontString("$parentArrival", "BACKGROUND", "GameFontNormal")
	arrival:SetPoint("TOP", SuperTrackedFrame.DistanceText, "BOTTOM", 0, -2)
	arrival:SetSize(0, 20)
	arrival:SetJustifyV("TOP")

	-- Store the arrival time display font string on the SuperTrackedFrame
	SuperTrackedFrame.arrival = arrival
	-- Store the getTargetAlphaBaseValue function on the SuperTrackedFrame
	SuperTrackedFrame.getTargetAlphaBaseValue = getTargetAlphaBaseValue
end
