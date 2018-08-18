local K = unpack(select(2, ...))
local Module = K:GetModule("Skins")

local _G = _G

local hooksecurefunc = _G.hooksecurefunc

local function BelowMinimapContainer()
	local UIWidgetsHolder = CreateFrame("Frame", "BelowMinimapContainerHolder", UIParent)
	UIWidgetsHolder:ClearAllPoints()
	UIWidgetsHolder:SetPoint("TOP", UIParent, "TOP", 0, -170)
	UIWidgetsHolder:SetSize(128, 40)

	local UIWidgetsContainer = _G["UIWidgetBelowMinimapContainerFrame"]
	UIWidgetsContainer:ClearAllPoints()
	UIWidgetsContainer:SetPoint("CENTER", UIWidgetsHolder, "CENTER")
	UIWidgetsContainer:SetParent(UIWidgetsHolder)
	UIWidgetsContainer.ignoreFramePositionManager = true

	-- Reposition capture bar on layout update
	hooksecurefunc(_G["UIWidgetManager"].registeredWidgetSetContainers[2], "layoutFunc", function(widgetContainer, sortedWidgets, ...)
		widgetContainer:ClearAllPoints()
		if widgetContainer:GetWidth() ~= UIWidgetsHolder:GetWidth() then
			UIWidgetsHolder:SetWidth(widgetContainer:GetWidth())
		end
	end)

	-- And this one cause UIParentManageFramePositions() repositions the widget constantly
	hooksecurefunc(UIWidgetsContainer, "ClearAllPoints", function(self)
		self:SetPoint("CENTER", UIWidgetsHolder, "CENTER")
	end)

	K.Movers:RegisterFrame(UIWidgetsHolder)
end

local function SkinUIWidgets()
	BelowMinimapContainer()
end

Module.SkinFuncs["Blizzard_UIWidgets"] = SkinUIWidgets