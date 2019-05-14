local K, C = unpack(select(2, ...))
if C["ActionBar"].Enable ~= true then
	return
end

-- Lua API
local _G = _G

local NUM_ACTIONBAR_BUTTONS = _G.NUM_ACTIONBAR_BUTTONS

if not C["ActionBar"].BottomFour == true then
	local ActionBar3 = CreateFrame("Frame", "Bar3Holder", RightActionBarAnchor)
	ActionBar3:SetAllPoints(RightActionBarAnchor)
	MultiBarLeft:SetParent(ActionBar3)
	MultiBarLeft:EnableMouse(false)
else
	local ActionBar3 = CreateFrame("Frame", "Bar3Holder", BottomBar4Anchor)
	ActionBar3:SetAllPoints(BottomBar4Anchor)
	MultiBarLeft:SetParent(ActionBar3)
	MultiBarLeft:EnableMouse(false)
end

for i = 1, NUM_ACTIONBAR_BUTTONS do
	local b = _G["MultiBarLeftButton"..i]
	local b2 = _G["MultiBarLeftButton"..i - 1]

	b:ClearAllPoints()
		
	if C["ActionBar"].BottomFour == true and not C["ActionBar"].ToggleMode == true and C["ActionBar"].RightBars == 2 and C["ActionBar"].BottomBars == 3 then
		if i == 1 then
			b:SetPoint("BOTTOMLEFT", BottomBar4Anchor, 0, 0)
		else
			b:SetPoint("LEFT", b2, "RIGHT", C["ActionBar"].ButtonSpace, 0)
		end
	end

	if not C["ActionBar"].BottomFour == true then
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
end

if C["ActionBar"].RightBars < 2 and not C["ActionBar"].BottomFour == true then
	ActionBar3:Hide()
end

-- Mouseover bar
if C["ActionBar"].RightMouseover == true then
	for i = 1, NUM_ACTIONBAR_BUTTONS do
		local b = _G["MultiBarLeftButton"..i]
		b:SetAlpha(0)
		b:HookScript("OnEnter", function()
			RightBarMouseOver(1)
		end)

		b:HookScript("OnLeave", function()
			if not HoverBind.enabled then
				RightBarMouseOver(0)
			end
		end)
	end
end