local K, C, L = unpack(select(2, ...))

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: TimerTracker

local BlizzTimerFont = K.GetFont(C["Unitframe"].Font)
local BlizzTimerTexture = K.GetTexture(C["Unitframe"].Texture)

-- Timer tracker
local function SkinIt(bar)
	for i = 1, bar:GetNumRegions() do
		local region = select(i, bar:GetRegions())

		if region:GetObjectType() == "Texture" then
			region:SetTexture(nil)
		elseif region:GetObjectType() == "FontString" then
			region:SetFont(C["Media"].Font, 13, "")
			region:SetShadowOffset(1.25, -1.25)
		end
	end

	bar:SetSize(222, 24)
	bar:SetStatusBarTexture(BlizzTimerTexture)
	bar:SetStatusBarColor(170/255, 10/255, 10/255)
	bar:SetTemplate("Transparent", true)

	bar.spark = bar:CreateTexture(nil, "OVERLAY")
	bar.spark:SetWidth(128)
	bar.spark:SetHeight(bar:GetHeight())
	bar.spark:SetTexture(C["Media"].Spark_128)
	bar.spark:SetBlendMode("ADD")
	bar.spark:SetPoint("CENTER", bar:GetStatusBarTexture(), "RIGHT", 0, 0)
end

local function SkinBlizzTimer()
	if C["Unitframe"].Enable ~= true then return end

	for _, b in pairs(TimerTracker.timerList) do
		if b["bar"] and not b["bar"].skinned then
			SkinIt(b["bar"])
			b["bar"].skinned = true
		end
	end
end

local Loading = CreateFrame("Frame")
Loading:RegisterEvent("START_TIMER")
Loading:SetScript("OnEvent", SkinBlizzTimer)