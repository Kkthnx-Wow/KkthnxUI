local K, C, L = unpack(select(2, ...))
if C.Unitframe.Enable ~= true then return end

-- Wow lua
local select, unpack, pairs = select, unpack, pairs

-- WoW API
local CreateFrame = CreateFrame

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: TimerTracker

-- Timer tracker
local function SkinIt(bar)
	for i = 1, bar:GetNumRegions() do
		local Region = select(i, bar:GetRegions())

		if Region:GetObjectType() == "Texture" then
			Region:SetTexture(nil)
		elseif Region:GetObjectType() == "FontString" then
			Region:SetFont(C.Media.Font, C.Media.Font_Size, C.Media.Font_Style)
			Region:SetShadowColor(0, 0, 0, 0)
		end
	end

	bar:SetSize(222, 24)
	bar:StripTextures()
	bar:SetBackdrop(K.BorderBackdrop)
	bar:SetBackdropColor(unpack(C.Media.Backdrop_Color))
	bar:SetStatusBarTexture(C.Media.Texture)
	bar:SetStatusBarColor(170/255, 10/255, 10/255)
	K.CreateBorder(bar, 1)
end

local function SkinBlizzTimer()
	for _, b in pairs(TimerTracker.timerList) do
		if b["bar"] and not b["bar"].skinned then
			SkinIt(b["bar"])
			b["bar"].skinned = true
		end
	end
end

local Timer = CreateFrame("Frame", nil, UIParent)
Timer:RegisterEvent("START_TIMER")
Timer:SetScript("OnEvent", SkinBlizzTimer)