local K, C = unpack(select(2, ...))
if C["DataText"].System ~= true then
	return
end

local _G = _G
local math_floor = math.floor
local select = select

local _, PlayerClass = UnitClass("player")
local PlayerColorStr = RAID_CLASS_COLORS[PlayerClass].colorStr

local FPS_ABBR = "|c" .. PlayerColorStr .. _G.FPS_ABBR .. "|r"
local MILLISECONDS_ABBR = "|c" .. PlayerColorStr .. _G.MILLISECONDS_ABBR .. "|r"
local performance_font = K.GetFont(C["DataText"].Font)
local performance_hz = 1
local performance_string = "%d%s - %d%s"

local PerformanceFrame = CreateFrame("Frame", "SystemInfo", Minimap)
PerformanceFrame:SetPoint("TOP", Minimap, "TOP", 0, -4)
PerformanceFrame:SetSize(Minimap:GetWidth() - 2, 14)
PerformanceFrame:Show()

PerformanceFrame.Text = PerformanceFrame:CreateFontString(nil, "OVERLAY")
PerformanceFrame.Text:SetFontObject(performance_font)
PerformanceFrame.Text:SetFont(select(1, PerformanceFrame.Text:GetFont()), 13, select(3, PerformanceFrame.Text:GetFont()))
PerformanceFrame.Text:SetAllPoints(PerformanceFrame)

PerformanceFrame.Performance = PerformanceFrame.Text

PerformanceFrame:SetScript("OnUpdate", function(self, elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed

	if self.elapsed > performance_hz then
		local _, _, chat_latency, cast_latency = _G.GetNetStats()
		local fps = math_floor(_G.GetFramerate())

		if not cast_latency or cast_latency == 0 then
			cast_latency = chat_latency
		end

		self.Performance:SetFormattedText(performance_string, cast_latency, MILLISECONDS_ABBR, fps, FPS_ABBR)
		self.elapsed = 0
	end
end)

K.PerformanceFrame = PerformanceFrame
