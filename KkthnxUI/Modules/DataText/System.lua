local K, C = unpack(select(2, ...))
if C["DataText"].System ~= true then return end

local _G = _G
local math_floor = math.floor

local PerformanceFrame = CreateFrame("Frame", "SystemDT", K.PetBattleHider)
PerformanceFrame:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -2, 2)
PerformanceFrame:SetSize(90, 13)
K["Movers"]:RegisterFrame(PerformanceFrame)

local Performance = K.SetFontString(PerformanceFrame, C["Media"].Font, 12, C["DataText"].Outline and "OUTLINE" or "", "CENTER")
Performance:SetDrawLayer("ARTWORK")
Performance:SetAllPoints(PerformanceFrame)

PerformanceFrame.Performance = Performance

local performance_string = "%d%s - %d%s"
local performance_hz = 1
local MILLISECONDS_ABBR = MILLISECONDS_ABBR
local FPS_ABBR = FPS_ABBR

PerformanceFrame:SetScript("OnUpdate", function(self, elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed
	if self.elapsed > performance_hz then
		local _, _, chat_latency, cast_latency = _G.GetNetStats()
		local fps = math_floor(_G.GetFramerate())
		if not cast_latency or cast_latency == 0 then
			cast_latency = chat_latency
		end
		self.Performance:SetFormattedText(performance_string, cast_latency, MILLISECONDS_ABBR, fps, FPS_ABBR)
		self.Performance:SetTextColor(1, 1, 1, 1)
		self.elapsed = 0
	end
end)