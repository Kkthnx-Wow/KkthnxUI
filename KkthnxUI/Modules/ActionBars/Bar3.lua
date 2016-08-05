local K, C, L, _ = select(2, ...):unpack()
if C.ActionBar.Enable ~= true then return end

local _G = _G
local CreateFrame = CreateFrame

--	Setup MultiBarLeft as bar #3 by Tukz
local bar = CreateFrame("Frame", "Bar3Holder", RightActionBarAnchor)
bar:SetAllPoints(RightActionBarAnchor)
MultiBarLeft:SetParent(bar)

for i = 1, 12 do
	local b = _G["MultiBarLeftButton"..i]
	local b2 = _G["MultiBarLeftButton"..i-1]
	b:ClearAllPoints()
	if i == 1 then
		if C.ActionBar.RightBars == 3 then
			b:SetPoint("TOP", RightActionBarAnchor, "TOP", 0, 0)
		else
			b:SetPoint("TOPLEFT", RightActionBarAnchor, "TOPLEFT", 0, 0)
		end
	else
		b:SetPoint("TOP", b2, "BOTTOM", 0, -C.ActionBar.ButtonSpace)
	end
end

-- Hide bar
if C.ActionBar.RightBars < 2 then
	bar:Hide()
end