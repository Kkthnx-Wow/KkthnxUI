local K, C, L = unpack(select(2, ...))
if C.ActionBar.Enable ~= true then return end

-- Lua API
local _G = _G

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: RightBarMouseOver, HoverBind

-- MultiBarRight(by Tukz)
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

-- Hide bar
if C.ActionBar.RightBars < 1 then
	ActionBar4:Hide()
end

-- Mouseover bar
if C.ActionBar.RightBarsMouseover == true then
	for i = 1, 12 do
		local b = _G["MultiBarRightButton"..i]
		b:SetAlpha(0)
		b:HookScript("OnEnter", function() RightBarMouseOver(1) end)
		b:HookScript("OnLeave", function() if not HoverBind.enabled then RightBarMouseOver(0) end end)
	end
end