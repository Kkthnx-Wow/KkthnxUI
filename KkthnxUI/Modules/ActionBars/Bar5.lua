local K, C = unpack(select(2, ...))
if C["ActionBar"].Enable ~= true then
	return
end

local _G = _G

local NUM_ACTIONBAR_BUTTONS = _G.NUM_ACTIONBAR_BUTTONS

local ActionBar5 = CreateFrame("Frame", "Bar5Holder", K.PetBattleHider)
if C["ActionBar"].RightBars < 3 then
	if C["ActionBar"].SplitBars == true then
		ActionBar5:SetAllPoints(SplitBarLeft)
	else
		ActionBar5:SetAllPoints(ActionBarAnchor)
	end
else
	ActionBar5:SetAllPoints(RightActionBarAnchor)
end
MultiBarBottomRight:SetParent(ActionBar5)
ActionBar5:SetFrameStrata("LOW")

for i = 1, NUM_ACTIONBAR_BUTTONS do
	local b = _G["MultiBarBottomRightButton" .. i]
	local b2 = _G["MultiBarBottomRightButton" .. i - 1]
	b:ClearAllPoints()
	b.noGrid = false
	b:SetAttribute("showgrid", 1)
	if C["ActionBar"].SplitBars == true and C["ActionBar"].RightBars < 3 then
		if i == 1 then
			b:SetPoint("TOPLEFT", SplitBarLeft, "TOPLEFT", 0, 0)
		elseif i == 4 then
			b:SetPoint("BOTTOMLEFT", SplitBarLeft, "BOTTOMLEFT", 0, 0)
		elseif i == 7 then
			b:SetPoint("TOPLEFT", SplitBarRight, "TOPLEFT", 0, 0)
		elseif i == 10 then
			b:SetPoint("BOTTOMLEFT", SplitBarRight, "BOTTOMLEFT", 0, 0)
		else
			b:SetPoint("LEFT", b2, "RIGHT", C["ActionBar"].ButtonSpace, 0)
		end
	else
		if i == 1 then
			if C["ActionBar"].RightBars < 3 then
				b:SetPoint("TOPLEFT", Bar1Holder, 0, 0)
			else
				b:SetPoint("TOPLEFT", RightActionBarAnchor, "TOPLEFT", 0, 0)
			end
		else
			if C["ActionBar"].RightBars < 3 then
				b:SetPoint("LEFT", b2, "RIGHT", C["ActionBar"].ButtonSpace, 0)
			else
				b:SetPoint("TOP", b2, "BOTTOM", 0, -C["ActionBar"].ButtonSpace)
			end
		end
	end
end

if C["ActionBar"].RightBars < 3 and C["ActionBar"].BottomBars < 3 then
	ActionBar5:Hide()
end

-- Mouseover bar
--[[if C["ActionBar"].RightMouseover == true and C["ActionBar"].RightBars > 2 then
	for i = 1, NUM_ACTIONBAR_BUTTONS do
		local b = _G["MultiBarBottomRightButton"..i]
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
end--]]