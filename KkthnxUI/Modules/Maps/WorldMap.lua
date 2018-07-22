local K, C = unpack(select(2, ...))
local Module = K:NewModule("WorldMap", "AceHook-3.0", "AceEvent-3.0", "AceTimer-3.0")

K.WorldMap = Module

local _G = _G
local pairs = pairs
local find = string.find

local CreateFrame = CreateFrame
local GetCursorPosition = GetCursorPosition
local SetCVar = SetCVar
local SetUIPanelAttribute = SetUIPanelAttribute
local MOUSE_LABEL = MOUSE_LABEL:gsub("|T.-|t","")
local PLAYER = PLAYER

local WorldMapCoordinates = {
	["enable"] = true,
	["position"] = "BOTTOMLEFT",
	["xOffset"] = 0,
	["yOffset"] = 0,
}

local INVERTED_POINTS = {
	["TOPLEFT"] = "BOTTOMLEFT",
	["TOPRIGHT"] = "BOTTOMRIGHT",
	["BOTTOMLEFT"] = "TOPLEFT",
	["BOTTOMRIGHT"] = "TOPRIGHT",
	["TOP"] = "BOTTOM",
	["BOTTOM"] = "TOP",
}

local tooltips = {
	WorldMapTooltip,
	WorldMapCompareTooltip1,
	WorldMapCompareTooltip2,
	WorldMapCompareTooltip3
}

local smallerMapScale = 0.8

function Module:SetLargeWorldMap()
	WorldMapFrame:SetParent(UIParent)
	WorldMapFrame:SetScale(1)
	WorldMapFrame.ScrollContainer.Child:SetScale(smallerMapScale)

	if WorldMapFrame:GetAttribute("UIPanelLayout-area") ~= "center" then
		SetUIPanelAttribute(WorldMapFrame, "area", "center");
	end

	if WorldMapFrame:GetAttribute("UIPanelLayout-allowOtherPanels") ~= true then
		SetUIPanelAttribute(WorldMapFrame, "allowOtherPanels", true)
	end

	WorldMapFrame:OnFrameSizeChanged()
	if WorldMapFrame:GetMapID() then
		WorldMapFrame.NavBar:Refresh()
	end

	for _, tt in pairs(tooltips) do
		if _G[tt] then _G[tt]:SetFrameStrata("TOOLTIP") end
	end
end

function Module:UpdateMaximizedSize()
	local width, height = WorldMapFrame:GetSize()
	local magicNumber = (1 - smallerMapScale) * 100
	WorldMapFrame:SetSize((width * smallerMapScale) - (magicNumber + 2), (height * smallerMapScale) - 2)
end

function Module:SynchronizeDisplayState()
	if WorldMapFrame:IsMaximized() then
		WorldMapFrame:ClearAllPoints()
		WorldMapFrame:SetPoint("CENTER", UIParent)
	end
end

function Module:SetSmallWorldMap()
	if not WorldMapFrame:IsMaximized() then
		WorldMapFrame:ClearAllPoints()
		WorldMapFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 16, -94)
	end
end

local inRestrictedArea = false
function Module:PLAYER_ENTERING_WORLD()
	K:MapInfo_Update()

	if K.MapInfo.x and K.MapInfo.y then
		inRestrictedArea = false
		CoordsHolder.playerCoords:SetFormattedText("%s: %.2f, %.2f", PLAYER, (K.MapInfo.xText or 0), (K.MapInfo.yText or 0))
	else
		inRestrictedArea = true
		CoordsHolder.playerCoords:SetFormattedText("%s: %s", PLAYER, "N/A")
	end
end

function Module:UpdateCoords()
	if not WorldMapFrame:IsShown() then
		return
	end

	if WorldMapFrame.ScrollContainer:IsMouseOver() then
		local scale = WorldMapFrame.ScrollContainer:GetEffectiveScale()
		local width = WorldMapFrame.ScrollContainer:GetWidth()
		local height = WorldMapFrame.ScrollContainer:GetHeight()
		local centerX, centerY = WorldMapFrame.ScrollContainer:GetCenter()
		local x, y = GetCursorPosition()

		local adjustedX = x and ((x / scale - (centerX - (width/2))) / width)
		local adjustedY = y and ((centerY + (height/2) - y / scale) / height)

		if adjustedX and adjustedY and (adjustedX >= 0 and adjustedY >= 0 and adjustedX <= 1 and adjustedY <= 1) then
			adjustedX = K.Round(100 * adjustedX, 2)
			adjustedY = K.Round(100 * adjustedY, 2)
			CoordsHolder.mouseCoords:SetFormattedText("%s: %.2f, %.2f", MOUSE_LABEL, adjustedX, adjustedY)
		else
			CoordsHolder.mouseCoords:SetText("")
		end
	else
		CoordsHolder.mouseCoords:SetText("")
	end

	if not inRestrictedArea and K.MapInfo.coordsWatching then
		if K.MapInfo.x and K.MapInfo.y then
			CoordsHolder.playerCoords:SetFormattedText("%s: %.2f, %.2f", PLAYER, (K.MapInfo.xText or 0), (K.MapInfo.yText or 0))
		else
			CoordsHolder.playerCoords:SetText("")
		end
	end
end

function Module:PositionCoords()
	local db = WorldMapCoordinates
	local position = db.position
	local xOffset = db.xOffset
	local yOffset = db.yOffset

	local x, y = 5, 5
	if find(position, "RIGHT") then	x = -5 end
	if find(position, "TOP") then y = -5 end

	CoordsHolder.playerCoords:ClearAllPoints()
	CoordsHolder.playerCoords:SetPoint(position, WorldMapFrame.BorderFrame, position, x + xOffset, y + yOffset)
	CoordsHolder.mouseCoords:ClearAllPoints()
	CoordsHolder.mouseCoords:SetPoint(position, CoordsHolder.playerCoords, INVERTED_POINTS[position], 0, y)
end

function Module:OnInitialize()
	if WorldMapCoordinates then
		local CoordsHolder = CreateFrame("Frame", "CoordsHolder", WorldMapFrame)
		CoordsHolder:SetFrameLevel(WorldMapFrame.BorderFrame:GetFrameLevel() + 1)
		CoordsHolder:SetFrameStrata(WorldMapFrame.BorderFrame:GetFrameStrata())
		CoordsHolder.playerCoords = CoordsHolder:CreateFontString(nil, "OVERLAY")
		CoordsHolder.mouseCoords = CoordsHolder:CreateFontString(nil, "OVERLAY")
		CoordsHolder.playerCoords:SetTextColor(1, 1 ,0)
		CoordsHolder.mouseCoords:SetTextColor(1, 1 ,0)
		CoordsHolder.playerCoords:SetFontObject(NumberFontNormal)
		CoordsHolder.mouseCoords:SetFontObject(NumberFontNormal)
		CoordsHolder.playerCoords:SetText(PLAYER..": 0, 0")
		CoordsHolder.mouseCoords:SetText(MOUSE_LABEL..": 0, 0")

		WorldMapFrame:HookScript("OnShow", function()
			if not Module.CoordsTimer then
				Module.CoordsTimer = Module:ScheduleRepeatingTimer("UpdateCoords", 0.1)
			end
		end)

		WorldMapFrame:HookScript("OnHide", function()
			Module:CancelTimer(Module.CoordsTimer)
			Module.CoordsTimer = nil
		end)

		Module:PositionCoords()

		self:RegisterEvent("PLAYER_ENTERING_WORLD")
	end

	if (C["WorldMap"].SmallWorldMap) then
		smallerMapScale = C["WorldMap"].SmallWorldMapScale or 0.9

		WorldMapFrame.BlackoutFrame.Blackout:SetTexture(nil)
		WorldMapFrame.BlackoutFrame:EnableMouse(false)

		self:SecureHook(WorldMapFrame, "Maximize", "SetLargeWorldMap")
		self:SecureHook(WorldMapFrame, "Minimize", "SetSmallWorldMap")
		self:SecureHook(WorldMapFrame, "SynchronizeDisplayState")
		self:SecureHook(WorldMapFrame, "UpdateMaximizedSize")

		self:SecureHookScript(WorldMapFrame, "OnShow", function()
			if WorldMapFrame:IsMaximized() then
				self:SetLargeWorldMap()
			else
				self:SetSmallWorldMap()
			end

			Module:Unhook(WorldMapFrame, "OnShow", nil)
		end)
	end

	--Set alpha used when moving
	WORLD_MAP_MIN_ALPHA = C["WorldMap"].AlphaWhenMoving
	SetCVar("mapAnimMinAlpha", C["WorldMap"].AlphaWhenMoving)

	--Enable/Disable map fading when moving
	SetCVar("mapFade", (C["WorldMap"].FadeWhenMoving == true and 1 or 0))

	if WorldMapFrame.UIElementsFrame and WorldMapFrame.UIElementsFrame.ActionButton.SpellButton.Cooldown then
		WorldMapFrame.UIElementsFrame.ActionButton.SpellButton.Cooldown.CooldownFontSize = 20
	end
end