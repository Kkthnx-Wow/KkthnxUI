local K, C = unpack(select(2, ...))
local Module = K:NewModule("WorldMap")

local _G = _G

local C_Map_GetBestMapForUnit = _G.C_Map.GetBestMapForUnit
local C_Map_GetWorldPosFromMapPos = _G.C_Map.GetWorldPosFromMapPos
local CreateFrame = _G.CreateFrame
local CreateVector2D = _G.CreateVector2D
local IsPlayerMoving = _G.IsPlayerMoving
local PLAYER = _G.PLAYER
local SetUIPanelAttribute = _G.SetUIPanelAttribute
local UIParent = _G.UIParent
local UnitPosition = _G.UnitPosition
-- local WorldMapFrame = _G.WorldMapFrame
local hooksecurefunc = _G.hooksecurefunc

local mapRects = {}
local tempVec2D = CreateVector2D(0, 0)
local currentMapID, playerCoords, cursorCoords
local smallerMapScale = 0.8

function Module:SetLargeWorldMap()
	local WorldMapFrame = _G.WorldMapFrame
	WorldMapFrame:SetParent(UIParent)
	WorldMapFrame:SetScale(1)
	WorldMapFrame.ScrollContainer.Child:SetScale(smallerMapScale)

	if WorldMapFrame:GetAttribute("UIPanelLayout-area") ~= "center" then
		SetUIPanelAttribute(WorldMapFrame, "area", "center")
	end

	if WorldMapFrame:GetAttribute("UIPanelLayout-allowOtherPanels") ~= true then
		SetUIPanelAttribute(WorldMapFrame, "allowOtherPanels", true)
	end

	WorldMapFrame:OnFrameSizeChanged()
	if WorldMapFrame:GetMapID() then
		WorldMapFrame.NavBar:Refresh()
	end
end

function Module:UpdateMaximizedSize()
	local WorldMapFrame = _G.WorldMapFrame
	local width, height = WorldMapFrame:GetSize()
	local magicNumber = (1 - smallerMapScale) * 100
	WorldMapFrame:SetSize((width * smallerMapScale) - (magicNumber + 2), (height * smallerMapScale) - 2)
end

function Module:SynchronizeDisplayState()
	local WorldMapFrame = _G.WorldMapFrame
	if WorldMapFrame:IsMaximized() then
		WorldMapFrame:ClearAllPoints()
		WorldMapFrame:SetPoint("CENTER", UIParent)
	end
end

function Module:SetSmallWorldMap()
	local WorldMapFrame = _G.WorldMapFrame
	if not WorldMapFrame:IsMaximized() then
		WorldMapFrame:ClearAllPoints()
		WorldMapFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 16, -94)
	end
end

function Module:GetPlayerMapPos(mapID)
	tempVec2D.x, tempVec2D.y = UnitPosition("player")
	if not tempVec2D.x then
		return
	end

	local mapRect = mapRects[mapID]
	if not mapRect then
		mapRect = {}
		mapRect[1] = select(2, C_Map_GetWorldPosFromMapPos(mapID, CreateVector2D(0, 0)))
		mapRect[2] = select(2, C_Map_GetWorldPosFromMapPos(mapID, CreateVector2D(1, 1)))
		mapRect[2]:Subtract(mapRect[1])

		mapRects[mapID] = mapRect
	end
	tempVec2D:Subtract(mapRect[1])

	return tempVec2D.y / mapRect[2].y, tempVec2D.x / mapRect[2].x
end

function Module:GetCursorCoords()
	local WorldMapFrame = _G.WorldMapFrame
	if not WorldMapFrame.ScrollContainer:IsMouseOver() then
		return
	end

	local cursorX, cursorY = WorldMapFrame.ScrollContainer:GetNormalizedCursorPosition()
	if cursorX < 0 or cursorX > 1 or cursorY < 0 or cursorY > 1 then
		return
	end

	return cursorX, cursorY
end

local function CoordsFormat(owner, none)
	local text = none and ": --, --" or ": %.1f, %.1f"

	return owner..K.MyClassColor..text
end

function Module:UpdateCoords(elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed
	if self.elapsed > 0.1 then
		self.elapsed = 0

		local cursorX, cursorY = Module:GetCursorCoords()
		if cursorX and cursorY then
			cursorCoords:SetFormattedText(CoordsFormat("Mouse"), 100 * cursorX, 100 * cursorY)
		else
			cursorCoords:SetText(CoordsFormat("Mouse", true))
		end

		if not currentMapID then
			playerCoords:SetText(CoordsFormat(PLAYER, true))
		else
			local x, y = Module:GetPlayerMapPos(currentMapID)
			if not x or (x == 0 and y == 0) then
				playerCoords:SetText(CoordsFormat(PLAYER, true))
			else
				playerCoords:SetFormattedText(CoordsFormat(PLAYER), 100 * x, 100 * y)
			end
		end
	end
end

function Module:UpdateMapID()
	if self:GetMapID() == C_Map_GetBestMapForUnit("player") then
		currentMapID = self:GetMapID()
	else
		currentMapID = nil
	end
end

function Module:MapShouldFade()
	-- normally we would check GetCVarBool('mapFade') here instead of the setting
	return C["WorldMap"].FadeWhenMoving and not _G.WorldMapFrame:IsMouseOver()
end

function Module:MapFadeOnUpdate(elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed
	if self.elapsed > 0.1 then
		self.elapsed = 0

		local object = self.FadeObject
		local settings = object and object.FadeSettings
		if not settings then
			return
		end

		local fadeOut = IsPlayerMoving() and (not settings.fadePredicate or settings.fadePredicate())
		local endAlpha = (fadeOut and (settings.minAlpha or 0.5)) or settings.maxAlpha or 1
		local startAlpha = _G.WorldMapFrame:GetAlpha()

		object.timeToFade = settings.durationSec or 0.5
		object.startAlpha = startAlpha
		object.endAlpha = endAlpha
		object.diffAlpha = endAlpha - startAlpha

		if object.fadeTimer then
			object.fadeTimer = nil
		end

		K.UIFrameFade(_G.WorldMapFrame, object)
	end
end

local fadeFrame
function Module:StopMapFromFading()
	if fadeFrame then
		fadeFrame:Hide()
	end
end

function Module:EnableMapFading(frame)
	if not fadeFrame then
		fadeFrame = CreateFrame("Frame")
		fadeFrame:SetScript("OnUpdate", Module.MapFadeOnUpdate)
		frame:HookScript("OnHide", Module.StopMapFromFading)
	end

	if not fadeFrame.FadeObject then
		fadeFrame.FadeObject = {}
	end

	if not fadeFrame.FadeObject.FadeSettings then
		fadeFrame.FadeObject.FadeSettings = {}
	end

	local settings = fadeFrame.FadeObject.FadeSettings
	settings.fadePredicate = Module.MapShouldFade
	settings.durationSec = 0.2
	settings.minAlpha = C["WorldMap"].AlphaWhenMoving
	settings.maxAlpha = 1

	fadeFrame:Show()
end

function Module:UpdateMapFade(_, _, _, fadePredicate) -- self is frame
	if self:IsShown() and (self == _G.WorldMapFrame and fadePredicate ~= Module.MapShouldFade) then
		-- blizzard spams code in OnUpdate and doesnt finish their functions, so we shut their fader down :L
		PlayerMovementFrameFader.RemoveFrame(self)

		-- replacement function which is complete :3
		if C["WorldMap"].FadeWhenMoving then
			Module:EnableMapFading(self)
		end
	end
end

function Module:OnEnable()
	if C["WorldMap"].Coordinates then
		local coordsFrame = CreateFrame("FRAME", nil, WorldMapFrame.ScrollContainer)
		coordsFrame:SetSize(WorldMapFrame:GetWidth(), 17)
		coordsFrame:SetPoint("BOTTOMLEFT", 17)
		coordsFrame:SetPoint("BOTTOMRIGHT", 0)

		coordsFrame.Texture = coordsFrame:CreateTexture(nil, "BACKGROUND")
		coordsFrame.Texture:SetAllPoints()
		coordsFrame.Texture:SetTexture(C["Media"].Blank)
		coordsFrame.Texture:SetVertexColor(0.04, 0.04, 0.04, 0.5)

		-- Create cursor coordinates frame
		cursorCoords = WorldMapFrame.ScrollContainer:CreateFontString(nil, "OVERLAY")
		cursorCoords:FontTemplate(nil, 13, "OUTLINE")
		cursorCoords:SetSize(200, 16)
		cursorCoords:SetParent(coordsFrame)
		cursorCoords:ClearAllPoints()
		cursorCoords:SetPoint("BOTTOMLEFT", 152, 1)
		cursorCoords:SetTextColor(255/255, 204/255, 102/255)

		-- Create player coordinates frame
		playerCoords = WorldMapFrame.ScrollContainer:CreateFontString(nil, "OVERLAY")
		playerCoords:FontTemplate(nil, 13, "OUTLINE")
		playerCoords:SetSize(200, 16)
		playerCoords:SetParent(coordsFrame)
		playerCoords:ClearAllPoints()
		playerCoords:SetPoint("BOTTOMRIGHT", -132, 1)
		playerCoords:SetTextColor(255/255, 204/255, 102/255)

		hooksecurefunc(WorldMapFrame, "OnFrameSizeChanged", self.UpdateMapID)
		hooksecurefunc(WorldMapFrame, "OnMapChanged", self.UpdateMapID)

		local CoordsUpdater = CreateFrame("Frame", nil, WorldMapFrame.ScrollContainer)
		CoordsUpdater:SetScript("OnUpdate", self.UpdateCoords)
	end

	if C["WorldMap"].SmallWorldMap then
		smallerMapScale = C["WorldMap"].SmallWorldMapScale or 0.9

		WorldMapFrame.BlackoutFrame.Blackout:SetTexture()
		WorldMapFrame.BlackoutFrame:EnableMouse(false)

		hooksecurefunc(WorldMapFrame, "Maximize", Module.SetLargeWorldMap)
		hooksecurefunc(WorldMapFrame, "Minimize", Module.SetSmallWorldMap)
		hooksecurefunc(WorldMapFrame, "SynchronizeDisplayState", Module.SynchronizeDisplayState)
		hooksecurefunc(WorldMapFrame, "UpdateMaximizedSize", Module.UpdateMaximizedSize)

		if (not WorldMapFrame.isHooked) then
			WorldMapFrame:HookScript("OnShow", function()
				if WorldMapFrame:IsMaximized() then
					WorldMapFrame:UpdateMaximizedSize()
					Module:SetLargeWorldMap()
				else
					Module:SetSmallWorldMap()
				end
			end)

			WorldMapFrame.isHooked = true
		end
	end

	-- This lets us control the maps fading function
	hooksecurefunc(PlayerMovementFrameFader, "AddDeferredFrame", Module.UpdateMapFade)

	-- Enable/Disable map fading when moving
	-- currently we dont need to touch this cvar because we have our own control for this currently
	-- see the comment in `M:UpdateMapFade` about `durationSec` for more information
	-- SetCVar("mapFade", E.global.general.fadeMapWhenMoving and 1 or 0)

	self:CreateWorldMapReveal()
	self:CreateWowHeadLinks()
end