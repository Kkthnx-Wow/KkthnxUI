local K, C, L = unpack(select(2, ...))
if C["DataText"].System ~= true then return end

local math_floor = math.floor

<<<<<<< HEAD
local PerformanceFrame = CreateFrame("Frame")
=======
local PerformanceFrame = CreateFrame("Frame", "PerformanceFrame", K.PetBattleHider)
PerformanceFrame:SetScale(1)
>>>>>>> 215d330... Misc updates.

local Performance = K.SetFontString(PerformanceFrame, C["Media"].Font, K.Scale(9), C["DataText"].Outline and "OUTLINE" or "", "CENTER")
Performance:SetDrawLayer("ARTWORK")
Performance:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -2, 2)

PerformanceFrame.Performance = Performance

local performance_string = "%d%s - %d%s"
local performance_hz = 1
local MILLISECONDS_ABBR = MILLISECONDS_ABBR
local FPS_ABBR = FPS_ABBR

PerformanceFrame:SetScript("OnUpdate", function(self, elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed
	if self.elapsed > performance_hz then
		local _, _, chat_latency, cast_latency = GetNetStats()
		local fps = math_floor(GetFramerate())
		if not cast_latency or cast_latency == 0 then
			cast_latency = chat_latency
		end
		self.Performance:SetFormattedText(performance_string, cast_latency, MILLISECONDS_ABBR, fps, FPS_ABBR)
		self.Performance:SetTextColor(1, 1, 1, 1)
		self.elapsed = 0
	end
end)