local K, C = unpack(select(2, ...))
if C["ActionBar"].Enable ~= true then
	return
end

-- Lua API
local _G = _G

local NUM_ACTIONBAR_BUTTONS = _G.NUM_ACTIONBAR_BUTTONS

local ActionBar3 = CreateFrame("Frame", "Bar3Holder", RightActionBarAnchor)
ActionBar3:SetAllPoints(RightActionBarAnchor)
MultiBarLeft:SetParent(ActionBar3)

for i = 1, NUM_ACTIONBAR_BUTTONS do
	local b = _G["MultiBarLeftButton"..i]
	local b2 = _G["MultiBarLeftButton"..i-1]
	b:ClearAllPoints()
	b.noGrid = false
	b:SetAttribute("showgrid", 1)
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

-- Mouseover bar
--[[if C["ActionBar"].RightMouseover == true then
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
end--]]