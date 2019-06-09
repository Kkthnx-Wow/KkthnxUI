local K = unpack(select(2, ...))
local Module = K:NewModule("UIWidgets")

local _G = _G

local CreateFrame = _G.CreateFrame
local hooksecurefunc = _G.hooksecurefunc
local UIParent = _G.UIParent

local function topCenterPosition(self, _, b)
	local holder = _G.TopCenterContainerHolder
	if b and (b ~= holder) then
		self:ClearAllPoints()
		self:SetPoint("CENTER", holder)
		self:SetParent(holder)
	end
end

local function belowMinimapPosition(self, _, b)
	local holder = _G.BelowMinimapContainerHolder
	if b and (b ~= holder) then
		self:ClearAllPoints()
		self:SetPoint("CENTER", holder, "CENTER")
		self:SetParent(holder)
	end
end

local function UIWidgets()
	local topCenterContainer = _G.UIWidgetTopCenterContainerFrame
	local belowMiniMapcontainer = _G.UIWidgetBelowMinimapContainerFrame

	local topCenterHolder = CreateFrame("Frame", "TopCenterContainerHolder", UIParent)
	topCenterHolder:SetPoint("TOP", UIParent, "TOP", 0, -30)
	topCenterHolder:SetSize(10, 58)

	local belowMiniMapHolder = CreateFrame("Frame", "BelowMinimapContainerHolder", UIParent)
	belowMiniMapHolder:SetPoint("TOPRIGHT", _G["Minimap"], "BOTTOMRIGHT", 0, -16)
	belowMiniMapHolder:SetSize(128, 40)

	K.Mover(topCenterHolder, "TopCenterContainer", "TopCenterContainer", {"TOP", UIParent, "TOP", 0, -30})
	K.Mover(belowMiniMapHolder, "BelowMinimapContainer", "BelowMinimapContainer", {"TOPRIGHT", _G["Minimap"], "BOTTOMRIGHT", 0, -16})

	topCenterContainer:ClearAllPoints()
	topCenterContainer:SetPoint("CENTER", topCenterHolder)

	belowMiniMapcontainer:ClearAllPoints()
	belowMiniMapcontainer:SetPoint("CENTER", belowMiniMapHolder, "CENTER")

	hooksecurefunc(topCenterContainer, "SetPoint", topCenterPosition)
	hooksecurefunc(belowMiniMapcontainer, "SetPoint", belowMinimapPosition)
end

function Module:OnEnable()
	UIWidgets()
end