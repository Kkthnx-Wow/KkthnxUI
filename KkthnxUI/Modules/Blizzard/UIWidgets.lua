local K = unpack(select(2, ...))
local Module = K:GetModule("Blizzard")

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

function Module:CreateUIWidgets()
	local topCenterContainer = _G.UIWidgetTopCenterContainerFrame
	local belowMiniMapcontainer = _G.UIWidgetBelowMinimapContainerFrame

	local topCenterHolder = CreateFrame("Frame", "TopCenterContainerHolder", UIParent)
	topCenterHolder:SetPoint("TOP", UIParent, "TOP", 0, -80)
	topCenterHolder:SetSize(128, 30)

	local belowMiniMapHolder = CreateFrame("Frame", "BelowMinimapContainerHolder", UIParent)
	belowMiniMapHolder:SetPoint("TOP", UIParent, "TOP", 0, -80)
	belowMiniMapHolder:SetSize(128, 30)

	K.Mover(topCenterHolder, "TopCenterContainer", "TopCenterContainer", {"TOP", UIParent, "TOP", 0, -46}, 128, 30)
	K.Mover(belowMiniMapHolder, "BelowMinimapContainer", "BelowMinimapContainer", {"TOP", UIParent, "TOP", 0, -76}, 128, 30)

	topCenterContainer:ClearAllPoints()
	topCenterContainer:SetPoint("CENTER", topCenterHolder)

	belowMiniMapcontainer:ClearAllPoints()
	belowMiniMapcontainer:SetPoint("CENTER", belowMiniMapHolder, "CENTER")

	hooksecurefunc(topCenterContainer, "SetPoint", topCenterPosition)
	hooksecurefunc(belowMiniMapcontainer, "SetPoint", belowMinimapPosition)
end