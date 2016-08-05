local K, C, L, _ = select(2, ...):unpack()
if C.ActionBar.Enable ~= true then return end

local _G = _G
local CreateFrame = CreateFrame

--	Setup MultiBarBottomLeft as bar #2 by Tukz
local bar = CreateFrame("Frame", "Bar2Holder", ActionBarAnchor)
bar:SetAllPoints(ActionBarAnchor)
MultiBarBottomLeft:SetParent(bar)

for i = 1, 12 do
	local b = _G["MultiBarBottomLeftButton"..i]
	local b2 = _G["MultiBarBottomLeftButton"..i-1]
	b:ClearAllPoints()
	if i == 1 then
		b:SetPoint("BOTTOM", ActionButton1, "TOP", 0, C.ActionBar.ButtonSpace)
	else
		b:SetPoint("LEFT", b2, "RIGHT", C.ActionBar.ButtonSpace, 0)
	end
end

-- Hide bar
if C.ActionBar.BottomBars == 1 then
	bar:Hide()
end