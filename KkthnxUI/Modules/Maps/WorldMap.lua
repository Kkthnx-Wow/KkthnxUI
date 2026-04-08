--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Manages WorldMap adjustments, coordinates, and fading when moving.
-- - Design: Hooks into WorldMapFrame to provide a smaller, movable map with coordinates.
-- - Events: OnFrameSizeChanged, OnMapChanged, OnShow, OnHide
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:NewModule("WorldMap")

-- PERF: Localize global functions and environment for faster lookups.
local pcall = _G.pcall
local select = _G.select
local strmatch = _G.strmatch
local tostring = _G.tostring
local type = _G.type

local _G = _G
local C_Map_GetBestMapForUnit = _G.C_Map.GetBestMapForUnit
local CreateFrame = _G.CreateFrame
local IsPlayerMoving = _G.IsPlayerMoving
local PLAYER = _G.PLAYER
local PlayerMovementFrameFader = _G.PlayerMovementFrameFader
local UIFrameFade = _G.UIFrameFade
local UIParent = _G.UIParent
local hooksecurefunc = _G.hooksecurefunc

local currentMapID, playerCoords, cursorCoords
local smallerMapScale = 0.8

function Module:SetLargeWorldMap()
	local worldMapFrame = _G.WorldMapFrame
	worldMapFrame:SetParent(UIParent)
	worldMapFrame:SetScale(1)
	worldMapFrame.ScrollContainer.Child:SetScale(smallerMapScale)

	worldMapFrame:OnFrameSizeChanged()
	if worldMapFrame:GetMapID() then
		worldMapFrame.NavBar:Refresh()
	end
end

function Module:UpdateMaximizedSize()
	local worldMapFrame = _G.WorldMapFrame
	local width, height = worldMapFrame:GetSize()
	local magicNumber = (1 - smallerMapScale) * 100
	worldMapFrame:SetSize((width * smallerMapScale) - (magicNumber + 2), (height * smallerMapScale) - 2)
end

function Module:SynchronizeDisplayState()
	local worldMapFrame = _G.WorldMapFrame
	if worldMapFrame:IsMaximized() then
		worldMapFrame:ClearAllPoints()
		worldMapFrame:SetPoint("CENTER", UIParent)
	end

	K.RestoreMoverFrame(self)
end

function Module:SetSmallWorldMap()
	local worldMapFrame = _G.WorldMapFrame
	worldMapFrame:ClearAllPoints()
	worldMapFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 16, -94)
end

function Module:GetCursorCoords()
	local worldMapFrame = _G.WorldMapFrame
	if not worldMapFrame.ScrollContainer:IsMouseOver() then
		return
	end

	local cursorX, cursorY = worldMapFrame.ScrollContainer:GetNormalizedCursorPosition()
	if cursorX < 0 or cursorX > 1 or cursorY < 0 or cursorY > 1 then
		return
	end

	return cursorX, cursorY
end

local function coordsFormat(owner, isNone)
	local text = isNone and ": --, --" or ": %.1f, %.1f"
	return owner .. K.MyClassColor .. text
end

function Module:UpdateCoords(elapsed)
	local worldMapFrame = _G.WorldMapFrame
	if not worldMapFrame:IsShown() then
		return
	end

	self.elapsed = (self.elapsed or 0) + elapsed
	if self.elapsed > 0.2 then
		local cursorX, cursorY = Module:GetCursorCoords()
		cursorCoords:SetFormattedText(coordsFormat("Mouse", not cursorX), 100 * (cursorX or 0), 100 * (cursorY or 0))

		local x, y = K.GetPlayerMapPos(currentMapID)
		playerCoords:SetFormattedText(coordsFormat(PLAYER, not (currentMapID and x and (x ~= 0 or y ~= 0))), 100 * (x or 0), 100 * (y or 0))

		self.elapsed = 0
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
	-- REASON: Determines if the map should fade based on movement and mouse interaction.
	return C["WorldMap"].FadeWhenMoving and not _G.WorldMapFrame:IsMouseOver()
end

function Module:MapFadeOnUpdate(elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed
	if self.elapsed > 0.1 then
		self.elapsed = 0

		local fadeObject = self.FadeObject
		local settings = fadeObject and fadeObject.FadeSettings
		if not settings then
			return
		end

		local isFadingOut = IsPlayerMoving() and (not settings.fadePredicate or settings.fadePredicate())
		local endAlpha = (isFadingOut and (settings.minAlpha or 0.5)) or settings.maxAlpha or 1
		local startAlpha = _G.WorldMapFrame:GetAlpha()

		fadeObject.timeToFade = settings.durationSec or 0.5
		fadeObject.startAlpha = startAlpha
		fadeObject.endAlpha = endAlpha
		fadeObject.diffAlpha = endAlpha - startAlpha

		if fadeObject.fadeTimer then
			fadeObject.fadeTimer = nil
		end

		UIFrameFade(_G.WorldMapFrame, fadeObject)
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

		fadeFrame.FadeObject = {}
		fadeFrame.FadeObject.FadeSettings = {}
	end

	local settings = fadeFrame.FadeObject.FadeSettings
	settings.fadePredicate = Module.MapShouldFade
	settings.durationSec = 0.2
	settings.minAlpha = C["WorldMap"].AlphaWhenMoving
	settings.maxAlpha = 1

	fadeFrame:Show()
end

-- REASON: Intercepts Blizzard's frame fader to apply custom fading logic to the WorldMap.
function Module.UpdateMapFade(...)
	local arg1, arg2 = ...

	local frame
	if type(arg1) == "table" and type(arg1.IsShown) == "function" and arg1 ~= PlayerMovementFrameFader then
		frame = arg1
	elseif arg1 == PlayerMovementFrameFader and type(arg2) == "table" and type(arg2.IsShown) == "function" then
		frame = arg2
	elseif type(arg2) == "table" and type(arg2.IsShown) == "function" then
		frame = arg2
	else
		return
	end

	local fadePredicate
	for i = 6, 1, -1 do
		local val = select(i, ...)
		if type(val) == "function" then
			fadePredicate = val
			break
		end
	end

	if frame == _G.WorldMapFrame and frame:IsShown() and fadePredicate ~= Module.MapShouldFade then
		PlayerMovementFrameFader.RemoveFrame(frame)
		if C["WorldMap"].FadeWhenMoving then
			Module:EnableMapFading(frame)
		end
	end
end

function Module:WorldMap_OnShow()
	if Module.CoordsUpdater then
		Module.CoordsUpdater:SetScript("OnUpdate", Module.UpdateCoords)
	end

	if Module.mapSizeAdjusted then
		return
	end

	local worldMapFrame = _G.WorldMapFrame
	local isMaximized = worldMapFrame:IsMaximized()
	if isMaximized then
		worldMapFrame:UpdateMaximizedSize()
	end

	if C["WorldMap"].SmallWorldMap then
		if isMaximized then
			Module:SetLargeWorldMap()
		else
			Module:SetSmallWorldMap()
		end
	end

	Module.mapSizeAdjusted = true
end

function Module:WorldMap_OnHide()
	if Module.CoordsUpdater then
		Module.CoordsUpdater:SetScript("OnUpdate", nil)
	end
end

function Module:OnEnable()
	local worldMapFrame = _G.WorldMapFrame
	if C["WorldMap"].Coordinates then
		local textColor = { r = 240 / 255, g = 197 / 255, b = 0 }

		local coordsFrame = CreateFrame("Frame", nil, worldMapFrame.ScrollContainer)
		coordsFrame:SetSize(worldMapFrame:GetWidth(), 17)
		coordsFrame:SetPoint("BOTTOMLEFT", 17, 0)
		coordsFrame:SetPoint("BOTTOMRIGHT", 0, 0)

		coordsFrame.texture = coordsFrame:CreateTexture(nil, "BACKGROUND")
		coordsFrame.texture:SetAllPoints()
		coordsFrame.texture:SetTexture(C["Media"].Textures.White8x8Texture)
		coordsFrame.texture:SetVertexColor(0.04, 0.04, 0.04, 0.5)

		cursorCoords = worldMapFrame.ScrollContainer:CreateFontString(nil, "OVERLAY")
		cursorCoords:SetFontObject(K.UIFontOutline)
		cursorCoords:SetFont(select(1, cursorCoords:GetFont()), 13, select(3, cursorCoords:GetFont()))
		cursorCoords:SetSize(200, 16)
		cursorCoords:SetParent(coordsFrame)
		cursorCoords:ClearAllPoints()
		cursorCoords:SetPoint("BOTTOMLEFT", 152, 1)
		cursorCoords:SetTextColor(textColor.r, textColor.g, textColor.b)
		cursorCoords:SetAlpha(0.9)

		playerCoords = worldMapFrame.ScrollContainer:CreateFontString(nil, "OVERLAY")
		playerCoords:SetFontObject(K.UIFontOutline)
		playerCoords:SetFont(select(1, playerCoords:GetFont()), 13, select(3, playerCoords:GetFont()))
		playerCoords:SetSize(200, 16)
		playerCoords:SetParent(coordsFrame)
		playerCoords:ClearAllPoints()
		playerCoords:SetPoint("BOTTOMRIGHT", -132, 1)
		playerCoords:SetTextColor(textColor.r, textColor.g, textColor.b)
		playerCoords:SetAlpha(0.9)

		hooksecurefunc(worldMapFrame, "OnFrameSizeChanged", self.UpdateMapID)
		hooksecurefunc(worldMapFrame, "OnMapChanged", self.UpdateMapID)

		self.CoordsUpdater = CreateFrame("Frame", nil, worldMapFrame.ScrollContainer)
		self.CoordsUpdater:SetScript("OnUpdate", self.UpdateCoords)
	end

	if C["WorldMap"].SmallWorldMap then
		smallerMapScale = C["WorldMap"].SmallWorldMapScale or 0.9

		K.CreateMoverFrame(worldMapFrame, nil, true)

		worldMapFrame.BlackoutFrame.Blackout:SetTexture()
		worldMapFrame.BlackoutFrame:EnableMouse(false)

		hooksecurefunc(worldMapFrame, "Maximize", self.SetLargeWorldMap)
		hooksecurefunc(worldMapFrame, "Minimize", self.SetSmallWorldMap)
		hooksecurefunc(worldMapFrame, "SynchronizeDisplayState", self.SynchronizeDisplayState)
		hooksecurefunc(worldMapFrame, "UpdateMaximizedSize", self.UpdateMaximizedSize)
	end

	worldMapFrame:HookScript("OnShow", Module.WorldMap_OnShow)
	worldMapFrame:HookScript("OnHide", Module.WorldMap_OnHide)

	hooksecurefunc(PlayerMovementFrameFader, "AddDeferredFrame", Module.UpdateMapFade)

	-- REASON: Kill the tutorial buttons if the option is enabled to clean up the map interface.
	if C["General"].NoTutorialButtons then
		worldMapFrame.BorderFrame.Tutorial:Kill()
	end

	local loadWorldMapModules = {
		"CreateWorldMapReveal",
		"CreateWowHeadLinks",
		"CreateWorldMapPins",
	}

	for _, funcName in ipairs(loadWorldMapModules) do
		local func = self[funcName]
		if type(func) == "function" then
			local success, err = pcall(func, self)
			if not success then
				_G.error("Error in function " .. funcName .. ": " .. tostring(err), 2)
			end
		end
	end
end
