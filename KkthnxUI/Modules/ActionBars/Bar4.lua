local K, C, L, _ = select(2, ...):unpack()
if C.ActionBar.Enable ~= true then return end

local _G = _G
local CreateFrame = CreateFrame

--	Setup MultiBarRight as bar #4 by Tukz
local bar = CreateFrame("Frame", "Bar4Holder", RightActionBarAnchor)
bar:SetAllPoints(RightActionBarAnchor)
MultiBarRight:SetParent(bar)

for i = 1, 12 do
	local b = _G["MultiBarRightButton"..i]
	local b2 = _G["MultiBarRightButton"..i-1]
	b:ClearAllPoints()
	if i == 1 then
		b:SetPoint("TOPRIGHT", RightActionBarAnchor, "TOPRIGHT", 0, 0)
	else
		b:SetPoint("TOP", b2, "BOTTOM", 0, -C.ActionBar.ButtonSpace)
	end
end

-- Hide bar
if C.ActionBar.RightBars < 1 then
	bar:Hide()
end