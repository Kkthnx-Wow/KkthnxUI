local K, C = unpack(select(2, ...))
if C["ActionBar"].Enable ~= true then return end

-- Lua API
local _G = _G

local ActionBar3 = CreateFrame("Frame", "Bar3Holder", RightActionBarAnchor)
ActionBar3:SetAllPoints(RightActionBarAnchor)
MultiBarLeft:SetParent(ActionBar3)
MultiBarLeft:SetScale(1)
MultiBarLeft.SetScale = K.Noop

for i = 1, 12 do
	local b = _G["MultiBarLeftButton"..i]
	local b2 = _G["MultiBarLeftButton"..i-1]
	b:ClearAllPoints()
	if i == 1 then
		if C["ActionBar"].RightBars == 3 then
			b:SetPoint("TOP", RightActionBarAnchor, "TOP", 0, 0)
		else
			b:SetPoint("TOPLEFT", RightActionBarAnchor, "TOPLEFT", 0, 0)
		end
	else
		b:SetPoint("TOP", b2, "BOTTOM", 0, -C["ActionBar"].ButtonSpace)
	end
end

if C["ActionBar"].RightBars < 2 then
	ActionBar3:Hide()
end