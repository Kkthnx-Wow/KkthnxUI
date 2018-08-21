local K, C = unpack(select(2, ...))
local Module = K:NewModule("UIWidgets", "AceEvent-3.0", "AceHook-3.0")

local _G = _G

local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc

local function BelowMinimapContainer()
	local topCenterContainer = _G["UIWidgetTopCenterContainerFrame"]
	local belowMiniMapcontainer = _G["UIWidgetBelowMinimapContainerFrame"]

	local topCenterHolder = CreateFrame("Frame", "TopCenterContainerHolder", UIParent)
	topCenterHolder:SetPoint("TOP", UIParent, "TOP", 0, -44)
	topCenterHolder:SetSize(180, 20)

	local belowMiniMapHolder = CreateFrame("Frame", "BelowMinimapContainerHolder", UIParent)
	belowMiniMapHolder:SetPoint("TOPRIGHT", _G["Minimap"], "BOTTOMRIGHT", 0, -54)
	belowMiniMapHolder:SetSize(170, 20)

	topCenterContainer:ClearAllPoints()
	topCenterContainer:SetPoint("CENTER", topCenterHolder, "CENTER")
	topCenterContainer:SetParent(topCenterHolder)
	topCenterContainer.ignoreFramePositionManager = true

	belowMiniMapcontainer:ClearAllPoints()
	belowMiniMapcontainer:SetPoint("CENTER", belowMiniMapHolder, "CENTER")
	belowMiniMapcontainer:SetParent(belowMiniMapHolder)
	belowMiniMapcontainer.ignoreFramePositionManager = true

	-- Reposition the TopCenter Widget after layout update
	hooksecurefunc(_G["UIWidgetManager"].registeredWidgetSetContainers[1], "layoutFunc", function(widgetContainer, sortedWidgets, ...)
		widgetContainer:ClearAllPoints()

		if widgetContainer:GetWidth() ~= topCenterHolder:GetWidth() then
			topCenterHolder:SetWidth(widgetContainer:GetWidth())
		end
	end)

	-- Reposition capture bar on layout update
	hooksecurefunc(_G["UIWidgetManager"].registeredWidgetSetContainers[2], "layoutFunc", function(widgetContainer, sortedWidgets, ...)
		widgetContainer:ClearAllPoints()

		if widgetContainer:GetWidth() ~= belowMiniMapHolder:GetWidth() then
			belowMiniMapHolder:SetWidth(widgetContainer:GetWidth())
		end
	end)

	hooksecurefunc(topCenterContainer, "ClearAllPoints", function(self)
		self:SetPoint("CENTER", topCenterHolder, "CENTER")
	end)

	-- And this one cause UIParentManageFramePositions() repositions the widget constantly
	hooksecurefunc(belowMiniMapcontainer, "ClearAllPoints", function(self)
		self:SetPoint("CENTER", belowMiniMapHolder, "CENTER")
	end)

	K.Movers:RegisterFrame(topCenterHolder)
	K.Movers:RegisterFrame(belowMiniMapHolder)
end

function Module:OnEnable()
	BelowMinimapContainer()
end