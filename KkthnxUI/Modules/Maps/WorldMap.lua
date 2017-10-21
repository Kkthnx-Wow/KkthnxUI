local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("WorldMap", "AceHook-3.0", "AceEvent-3.0", "AceTimer-3.0")

local _G = _G
local string_find = string.find

local CreateFrame = _G.CreateFrame
local GetCursorPosition = _G.GetCursorPosition
local GetPlayerMapPosition = _G.GetPlayerMapPosition
local InCombatLockdown = _G.InCombatLockdown
local MOUSE_LABEL = _G.MOUSE_LABEL
local NumberFontNormal = _G.NumberFontNormal
local PLAYER = _G.PLAYER
local SetCVar = _G.SetCVar
local SetUIPanelAttribute = _G.SetUIPanelAttribute
local WORLDMAP_FULLMAP_SIZE = _G.WORLDMAP_FULLMAP_SIZE
local WORLDMAP_WINDOWED_SIZE = _G.WORLDMAP_WINDOWED_SIZE

local INVERTED_POINTS = {
	["TOPLEFT"] = "BOTTOMLEFT",
	["TOPRIGHT"] = "BOTTOMRIGHT",
	["BOTTOMLEFT"] = "TOPLEFT",
	["BOTTOMRIGHT"] = "TOPRIGHT",
	["TOP"] = "BOTTOM",
	["BOTTOM"] = "TOP",
}

local WorldMapCoordinates = {
	["enable"] = true,
	["position"] = "BOTTOMLEFT",
	["xOffset"] = 0,
	["yOffset"] = 0,
}

function Module:SetLargeWorldMap()
	if InCombatLockdown() then return end

	WorldMapFrame:SetParent(UIParent)
	WorldMapFrame:EnableKeyboard(false)
	WorldMapFrame:SetScale(1)
	WorldMapFrame:EnableMouse(true)
	WorldMapTooltip:SetFrameStrata("TOOLTIP")
	WorldMapCompareTooltip1:SetFrameStrata("TOOLTIP")
	WorldMapCompareTooltip2:SetFrameStrata("TOOLTIP")

	if WorldMapFrame:GetAttribute("UIPanelLayout-area") ~= "center" then
		SetUIPanelAttribute(WorldMapFrame, "area", "center")
	end

	if WorldMapFrame:GetAttribute("UIPanelLayout-allowOtherPanels") ~= true then
		SetUIPanelAttribute(WorldMapFrame, "allowOtherPanels", true)
	end

	WorldMapFrame:ClearAllPoints()
	WorldMapFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 100)
	WorldMapFrame:SetSize(1002, 668)
end

function Module:SetSmallWorldMap()
	if InCombatLockdown() then return end
end

function Module:PLAYER_REGEN_ENABLED()

end

function Module:PLAYER_REGEN_DISABLED()

end

local inRestrictedArea = false
function Module:PLAYER_ENTERING_WORLD()
	local x = GetPlayerMapPosition("player")
	if not x then
		inRestrictedArea = true
		self:CancelTimer(self.CoordsTimer)
		self.CoordsTimer = nil
		CoordsHolder.playerCoords:SetText("")
		CoordsHolder.mouseCoords:SetText("")
	elseif not self.CoordsTimer then
		inRestrictedArea = false
		self.CoordsTimer = self:ScheduleRepeatingTimer("UpdateCoords", 0.05)
	end
end

function Module:UpdateCoords()
	if (not WorldMapFrame:IsShown() or inRestrictedArea) then return end
	local x, y = GetPlayerMapPosition("player")
	x = x and K.Round(100 * x, 2) or 0
	y = y and K.Round(100 * y, 2) or 0

	if x ~= 0 and y ~= 0 then
		CoordsHolder.playerCoords:SetText(PLAYER..":   "..x..", "..y)
	else
		CoordsHolder.playerCoords:SetText("")
	end

	local scale = WorldMapDetailFrame:GetEffectiveScale()
	local width = WorldMapDetailFrame:GetWidth()
	local height = WorldMapDetailFrame:GetHeight()
	local centerX, centerY = WorldMapDetailFrame:GetCenter()
	local x, y = GetCursorPosition()
	local adjustedX = (x / scale - (centerX - (width / 2))) / width
	local adjustedY = (centerY + (height / 2) - y / scale) / height

	if (adjustedX >= 0  and adjustedY >= 0 and adjustedX <= 1 and adjustedY <= 1) then
		adjustedX = K.Round(100 * adjustedX, 2)
		adjustedY = K.Round(100 * adjustedY, 2)
		CoordsHolder.mouseCoords:SetText(MOUSE_LABEL..":   "..adjustedX..", "..adjustedY)
	else
		CoordsHolder.mouseCoords:SetText("")
	end
end

function Module:PositionCoords()
	local db = WorldMapCoordinates
	local position = db.position
	local xOffset = db.xOffset
	local yOffset = db.yOffset

	local x, y = 5, 5
	if string_find(position, "RIGHT") then	x = -5 end
	if string_find(position, "TOP") then y = -5 end

	CoordsHolder.playerCoords:ClearAllPoints()
	CoordsHolder.playerCoords:SetPoint(position, WorldMapScrollFrame, position, x + xOffset, y + yOffset)
	CoordsHolder.mouseCoords:ClearAllPoints()
	CoordsHolder.mouseCoords:SetPoint(position, CoordsHolder.playerCoords, INVERTED_POINTS[position], 0, y)
end

function Module:OnEnable()
	if (C["WorldMap"].Coordinates) then
		local CoordsHolder = CreateFrame("Frame", "CoordsHolder", WorldMapFrame)
		CoordsHolder:SetFrameLevel(WorldMapDetailFrame:GetFrameLevel() + 1)
		CoordsHolder:SetFrameStrata(WorldMapDetailFrame:GetFrameStrata())
		CoordsHolder.playerCoords = CoordsHolder:CreateFontString(nil, "OVERLAY")
		CoordsHolder.mouseCoords = CoordsHolder:CreateFontString(nil, "OVERLAY")
		CoordsHolder.playerCoords:SetTextColor(1, 1 ,0)
		CoordsHolder.mouseCoords:SetTextColor(1, 1 ,0)
		CoordsHolder.playerCoords:SetFontObject(NumberFontNormal)
		CoordsHolder.mouseCoords:SetFontObject(NumberFontNormal)
		CoordsHolder.playerCoords:SetText(PLAYER..":   0, 0")
		CoordsHolder.mouseCoords:SetText(MOUSE_LABEL..":   0, 0")

		self.CoordsTimer = self:ScheduleRepeatingTimer("UpdateCoords", 0.05)
		Module:PositionCoords()

		self:RegisterEvent("PLAYER_ENTERING_WORLD")
	end

	if (C["WorldMap"].SmallWorldMap) then
		BlackoutWorld:SetTexture(nil)
		self:SecureHook("WorldMap_ToggleSizeDown", "SetSmallWorldMap")
		self:SecureHook("WorldMap_ToggleSizeUp", "SetLargeWorldMap")
		-- self:RegisterEvent("PLAYER_REGEN_ENABLED")
		-- self:RegisterEvent("PLAYER_REGEN_DISABLED")

		if WORLDMAP_SETTINGS.size == WORLDMAP_FULLMAP_SIZE then
			self:SetLargeWorldMap()
		elseif WORLDMAP_SETTINGS.size == WORLDMAP_WINDOWED_SIZE then
			self:SetSmallWorldMap()
		end
	end

	-- Set alpha used when moving
	WORLD_MAP_MIN_ALPHA = C["WorldMap"].AlphaWhenMoving
	SetCVar("mapAnimMinAlpha", C["WorldMap"].AlphaWhenMoving)
	-- Enable/Disable map fading when moving
	SetCVar("mapFade", (C["WorldMap"].FadeWhenMoving == true and 1 or 0))
end