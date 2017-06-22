local K, C, L = unpack(select(2, ...))
local M = K:NewModule("WorldMap", "AceHook-3.0", "AceEvent-3.0", "AceTimer-3.0")
K.WorldMap = M

-- Lua API
local string_find = string.find
local unpack = unpack

-- Wow API
local CreateFrame = _G.CreateFrame
local GetCursorPosition = _G.GetCursorPosition
local GetPlayerMapPosition = _G.GetPlayerMapPosition
local InCombatLockdown = _G.InCombatLockdown
local IsInInstance = _G.IsInInstance
local MOUSE_LABEL = _G.MOUSE_LABEL
local PLAYER = _G.PLAYER
local SetCVar = _G.SetCVar
local SetUIPanelAttribute = _G.SetUIPanelAttribute
local WORLDMAP_FULLMAP_SIZE = _G.WORLDMAP_FULLMAP_SIZE
local WORLDMAP_WINDOWED_SIZE = _G.WORLDMAP_WINDOWED_SIZE

-- Global variables that we don"t cache, list them here for mikk"s FindGlobals script
-- GLOBALS: NumberFontNormal, WORLDMAP_SETTINGS, BlackoutWorld, WorldMapScrollFrame
-- GLOBALS: UIParent, CoordsHolder, WorldMapDetailFrame, DropDownList1, WORLD_MAP_MIN_ALPHA
-- GLOBALS: WorldMapFrame, WorldMapFrameSizeUpButton, WorldMapFrameSizeDownButton
-- GLOBALS: WorldMapTooltip, WorldMapCompareTooltip1, WorldMapCompareTooltip2

local WorldMapCoordinates = {
	-- ["Enable"] = true,
	["Position"] = "BOTTOMLEFT",
	["XOffset"] = 0,
	["YOffset"] = 0,
}

local INVERTED_POINTS = {
	["TOPLEFT"] = "BOTTOMLEFT",
	["TOPRIGHT"] = "BOTTOMRIGHT",
	["BOTTOMLEFT"] = "TOPLEFT",
	["BOTTOMRIGHT"] = "TOPRIGHT",
	["TOP"] = "BOTTOM",
	["BOTTOM"] = "TOP",
}

function M:SetLargeWorldMap()
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

	WorldMapFrameSizeUpButton:Hide()
	WorldMapFrameSizeDownButton:Show()

	WorldMapFrame:ClearAllPoints()
	WorldMapFrame:SetPoint(unpack(C.Position.WorldMap))
	WorldMapFrame:SetSize(1002, 668)
end

function M:SetSmallWorldMap()
	if InCombatLockdown() then return end

	WorldMapFrameSizeUpButton:Show()
	WorldMapFrameSizeDownButton:Hide()
end

function M:PLAYER_REGEN_ENABLED()
	WorldMapFrameSizeDownButton:Enable()
	WorldMapFrameSizeUpButton:Enable()
end

function M:PLAYER_REGEN_DISABLED()
	WorldMapFrameSizeDownButton:Disable()
	WorldMapFrameSizeUpButton:Disable()
end

local inRestrictedArea = false
function M:PLAYER_ENTERING_WORLD()
	local x = GetPlayerMapPosition("player")
	if not x then
		inRestrictedArea = true
		self:CancelTimer(self.CoordsTimer)
		self.CoordsTimer = nil
		CoordsHolder.PlayerCoords:SetText("")
		CoordsHolder.MouseCoords:SetText("")
	elseif not self.CoordsTimer then
		inRestrictedArea = false
		self.CoordsTimer = self:ScheduleRepeatingTimer("UpdateCoords", 0.05)
	end
end

function M:UpdateCoords()
	if (not WorldMapFrame:IsShown() or inRestrictedArea) then return end

	local X, Y = GetPlayerMapPosition("player")

	X = X and K.Round(100 * X, 2) or 0
	Y = Y and K.Round(100 * Y, 2) or 0

	if X ~= 0 and Y ~= 0 then
		CoordsHolder.PlayerCoords:SetText(PLAYER..": "..X..", "..Y)
	else
		CoordsHolder.PlayerCoords:SetText("")
	end

	local Scale = WorldMapDetailFrame:GetEffectiveScale()
	local Width = WorldMapDetailFrame:GetWidth()
	local Height = WorldMapDetailFrame:GetHeight()
	local CenterX, CenterY = WorldMapDetailFrame:GetCenter()
	local X, Y = GetCursorPosition()
	local AdjustedX = (X / Scale - (CenterX - (Width/2))) / Width
	local AdjustedY = (CenterY + (Height/2) - Y / Scale) / Height

	if (AdjustedX >= 0 and AdjustedY >= 0 and AdjustedX <= 1 and AdjustedY <= 1) then
		AdjustedX = K.Round(100 * AdjustedX, 2)
		AdjustedY = K.Round(100 * AdjustedY, 2)
		CoordsHolder.MouseCoords:SetText(MOUSE_LABEL..": "..AdjustedX..", "..AdjustedY)
	else
		CoordsHolder.MouseCoords:SetText("")
	end
end

function M:PositionCoords()
	local DataBase = WorldMapCoordinates -- Plan to change all this at a later time.
	local Position = DataBase.Position
	local XOffset = DataBase.XOffset
	local YOffset = DataBase.YOffset

	local X, Y = 5, 5
	if string_find(Position, "RIGHT") then X = -5 end
	if string_find(Position, "TOP") then Y = -5 end

	CoordsHolder.PlayerCoords:ClearAllPoints()
	CoordsHolder.PlayerCoords:SetPoint(Position, WorldMapScrollFrame, Position, X + XOffset, Y + YOffset)
	CoordsHolder.MouseCoords:ClearAllPoints()
	CoordsHolder.MouseCoords:SetPoint(Position, CoordsHolder.PlayerCoords, INVERTED_POINTS[Position], 0, Y)
end

function M:Initialize()
	if (C.WorldMap.Coordinates) then
		local CoordsHolder = CreateFrame("Frame", "CoordsHolder", WorldMapFrame)
		CoordsHolder:SetFrameLevel(WorldMapDetailFrame:GetFrameLevel() + 1)
		CoordsHolder:SetFrameStrata(WorldMapDetailFrame:GetFrameStrata())
		CoordsHolder.PlayerCoords = CoordsHolder:CreateFontString(nil, "OVERLAY")
		CoordsHolder.MouseCoords = CoordsHolder:CreateFontString(nil, "OVERLAY")
		CoordsHolder.PlayerCoords:SetTextColor(1, 1 ,0)
		CoordsHolder.MouseCoords:SetTextColor(1, 1 ,0)
		CoordsHolder.PlayerCoords:SetFontObject(NumberFontNormal)
		CoordsHolder.MouseCoords:SetFontObject(NumberFontNormal)
		CoordsHolder.PlayerCoords:SetText(PLAYER..": 0, 0")
		CoordsHolder.MouseCoords:SetText(MOUSE_LABEL..": 0, 0")

		self.CoordsTimer = self:ScheduleRepeatingTimer("UpdateCoords", 0.05)
		M:PositionCoords()

		self:RegisterEvent("PLAYER_ENTERING_WORLD")
	end

	if (C.WorldMap.SmallWorldMap) then
		BlackoutWorld:SetTexture(nil)
		self:SecureHook("WorldMap_ToggleSizeDown", "SetSmallWorldMap")
		self:SecureHook("WorldMap_ToggleSizeUp", "SetLargeWorldMap")
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
		self:RegisterEvent("PLAYER_REGEN_DISABLED")

		if WORLDMAP_SETTINGS.size == WORLDMAP_FULLMAP_SIZE then
			self:SetLargeWorldMap()
		elseif WORLDMAP_SETTINGS.size == WORLDMAP_WINDOWED_SIZE then
			self:SetSmallWorldMap()
		end
	end

	-- Set alpha used when moving
	WORLD_MAP_MIN_ALPHA = C.WorldMap.AlphaWhenMoving
	SetCVar("mapAnimMinAlpha", C.WorldMap.AlphaWhenMoving)

	-- Enable/Disable map fading when moving
	SetCVar("mapFade", (C.WorldMap.FadeWhenMoving == true and 1 or 0))
end

local Loading = CreateFrame("Frame")
Loading:RegisterEvent("PLAYER_LOGIN")
Loading:SetScript("OnEvent", function()
	M:Initialize()
end)