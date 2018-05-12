local K, C, L = unpack(select(2, ...))

local _G = _G
local pairs = pairs
local table_insert = table.insert
local tonumber = tonumber

local COOLDOWN_TYPE_LOSS_OF_CONTROL = _G.COOLDOWN_TYPE_LOSS_OF_CONTROL
local GetCVar = _G.GetCVar
local GetFramerate = _G.GetFramerate
local hooksecurefunc = _G.hooksecurefunc
local SetCVar = _G.SetCVar

hooksecurefunc("CooldownFrame_Set", function(self)
	if self.currentCooldownType == COOLDOWN_TYPE_LOSS_OF_CONTROL then
		self:SetCooldown(0, 0)
	end
end)

-- Performance Bullshit

local Module = CreateFrame("Frame")

Module.RangeTimer = 0
local CurrentValue
local LastAverageValue = 0
local AverageValue = 0 -- Current average framerate
local AverageTickCount = 0
local AverageTicks = {} -- Store ticks to compute the average over UPDATE_FREQUENCY seconds
local AverageTimer = 0
local TARGET_FRAMERATE, FRAMERATE_TOLERANCE, CURRENT_FRAMERATE_AVERAGE, GFX_SETTINGS, AVERAGE_UPDATE_FREQUENCY, UPDATE_FREQUENCY, AVERAGE_IMPROVEMENT_THRESHOLD

AVERAGE_IMPROVEMENT_THRESHOLD = 5 -- Average should improve by a minimum of X before settings everything higher
TARGET_FRAMERATE = 60
FRAMERATE_TOLERANCE = 7.5
GFX_SETTINGS = {[1] = "graphicsViewDistance", [2] = "graphicsShadowQuality"}
AVERAGE_UPDATE_FREQUENCY = 0.1
UPDATE_FREQUENCY = 4

function Module:Optimize()

	AverageTickCount = 0

	-- Process average data first
	for k,v in pairs(AverageTicks) do
		AverageValue = AverageValue + v -- Add tick value to total
		AverageTickCount = AverageTickCount + 1
	end

	-- Results finally in an average framerate over the course of UPDATE_FREQUENCY seconds. Each check was made in AVERAGE_UPDATE_FREQUENCY intervals.
	AverageValue = AverageValue / AverageTickCount

	-- print(AverageValue)

	CurrentValue = 1
	-- If our tolerance of stuttering is over
	if (AverageValue < TARGET_FRAMERATE - FRAMERATE_TOLERANCE) then
		-- Only update if average improved by
		if AverageValue > LastAverageValue then
			-- @TODO:
			-- Create a priority table of most affecting settings
			-- We HAVE to rely on an average framerate in a timespan of X seconds to get proper results.
			-- Also, this system has to be somewhat intelligent and lower settings that do not affect the visual quality that much
			-- print("Down")
			for k,v in pairs(GFX_SETTINGS) do
				CurrentValue = GetCVar(v)
				if tonumber(CurrentValue) > 1 then
					SetCVar(v, CurrentValue - 1)
				end
			end
		end
	else
		if AverageValue + AVERAGE_IMPROVEMENT_THRESHOLD > LastAverageValue and AverageValue >= TARGET_FRAMERATE then
			-- print("Up")
			for k,v in pairs(GFX_SETTINGS) do
				CurrentValue = GetCVar(v)
				if tonumber(CurrentValue) < 10 then
					SetCVar(v, CurrentValue + 1)
				end
			end
		end
	end

	LastAverageValue = AverageValue
end

function Module:ComputeAveragePerformance(elapsed)
	-- Check elapsed for any value less than UPDATE_FREQUENCY
	-- Compute average
	-- Reset average data otherwise

	local Timer = AverageTimer
	if (Timer) then
		Timer = Timer - elapsed
		if (Timer <= 0) then
			table_insert(AverageTicks, GetFramerate())
			Timer = AVERAGE_UPDATE_FREQUENCY
		end

		AverageTimer = Timer
	end
end

Module:SetScript("OnUpdate", function(self, elapsed)
	local RangeTimer = self.RangeTimer

	Module:ComputeAveragePerformance(elapsed) -- Fill data each frame
	if (RangeTimer) then
		RangeTimer = RangeTimer - elapsed

		if (RangeTimer <= 0) then
			Module:Optimize()
			AverageTicks = {}
			RangeTimer = UPDATE_FREQUENCY
		end

		self.RangeTimer = RangeTimer
	end
end)