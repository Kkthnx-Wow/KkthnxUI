local K, C, L = unpack(select(2, ...))

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: TimerTracker

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
	bar:StripTextures()
	bar:SetBackdrop({bgFile = C["Media"].Blank, insets = {left = 0, right = 0, top = 0, bottom = 0}})
	bar:SetBackdropColor(C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Media"].BackdropColor[4])
	bar:SetStatusBarTexture(C["Media"].Texture)
	bar:SetStatusBarColor(170/255, 10/255, 10/255)
	K.CreateBorder(bar, 4)

	bar.spark = bar:CreateTexture(nil, "ARTWORK", nil, 1)
	bar.spark:SetWidth(12)
	bar.spark:SetHeight(bar:GetHeight() * 3.2)
	bar.spark:SetTexture(C["Media"].Spark)
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