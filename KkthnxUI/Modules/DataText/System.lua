local K, C = unpack(select(2, ...))
if C["DataText"].System ~= true then
	return
end

local _G = _G
local math_floor = math.floor
local select = select

local FPS_ABBR = _G.FPS_ABBR
local MILLISECONDS_ABBR = _G.MILLISECONDS_ABBR
local performance_font = K.GetFont(C["DataText"].Font)
local performance_hz = 1
local performance_string = "%d%s - %d%s"

-- How many people are going to hate me for this! :D
local function PerformanceTextColor()
	local pvpType = GetZonePVPInfo()

	if pvpType == "arena" then
		return 0.84, 0.03, 0.03
	elseif pvpType == "friendly" then
		return 0.05, 0.85, 0.03
	elseif pvpType == "contested" then
		return 0.9, 0.85, 0.05
	elseif pvpType == "hostile" then
		return 0.84, 0.03, 0.03
	elseif pvpType == "sanctuary" then
		return 0.035, 0.58, 0.84
	elseif pvpType == "combat" then
		return 0.84, 0.03, 0.03
	else
		return 0.9, 0.85, 0.05
	end
end

local PerformanceFrame = CreateFrame("Frame", "SystemInfo", K.PetBattleHider)
PerformanceFrame:SetPoint("BOTTOM", Minimap, "BOTTOM", 0, 16)
PerformanceFrame:SetSize(Minimap:GetWidth() - 2, 14)
PerformanceFrame:Hide()

PerformanceFrame.Text = PerformanceFrame:CreateFontString(nil, "OVERLAY")
PerformanceFrame.Text:SetFontObject(performance_font)
PerformanceFrame.Text:SetFont(select(1, PerformanceFrame.Text:GetFont()), 12, select(3, PerformanceFrame.Text:GetFont()))
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
		self.Performance:SetTextColor(PerformanceTextColor())
		self.elapsed = 0
	end
end)

Minimap:SetScript("OnEnter", function()
	if not IsShiftKeyDown() then
		return
	end

	PerformanceFrame:Show()
end)

Minimap:SetScript("OnLeave", function()
	PerformanceFrame:Hide()
end)