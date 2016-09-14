local K, C, L, _ = select(2, ...):unpack()
if C.ActionBar.Enable ~= true then return end

-- LUA API
local _G = _G

-- WOW API
local CreateFrame = CreateFrame

--	SETUP MULTIBARRIGHT AS BAR #4 BY TUKZ
local ActionBar4 = CreateFrame("Frame", "Bar4Holder", RightActionBarAnchor, "SecureHandlerStateTemplate")
ActionBar4:SetAllPoints(RightActionBarAnchor)
MultiBarRight:SetParent(ActionBar4)

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

-- HIDE BAR
if C.ActionBar.RightBars < 1 then
	ActionBar4:Hide()
end