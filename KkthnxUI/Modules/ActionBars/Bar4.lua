local K, C = unpack(select(2, ...))
if C["ActionBar"].Enable ~= true then
	return
end

local _G = _G

local NUM_ACTIONBAR_BUTTONS = _G.NUM_ACTIONBAR_BUTTONS

local ActionBar4 = CreateFrame("Frame", "Bar4Holder", RightActionBarAnchor, "SecureHandlerStateTemplate")
ActionBar4:SetAllPoints(RightActionBarAnchor)
MultiBarRight:SetParent(ActionBar4)

for i = 1, NUM_ACTIONBAR_BUTTONS do
	local b = _G["MultiBarRightButton" .. i]
	local b2 = _G["MultiBarRightButton" .. i - 1]
	b:ClearAllPoints()
	b.noGrid = false
	b:SetAttribute("showgrid", 1)
	if i == 1 then
		b:SetPoint("TOPRIGHT", RightActionBarAnchor, "TOPRIGHT", 0, 0)
	else
		b:SetPoint("TOP", b2, "BOTTOM", 0, -C["ActionBar"].ButtonSpace)
	end
end

if C["ActionBar"].RightBars < 1 then
	ActionBar4:Hide()
end

-- Mouseover bar
--[[if C["ActionBar"].RightMouseover == true then
	for i = 1, NUM_ACTIONBAR_BUTTONS do
		local b = _G["MultiBarRightButton"..i]
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