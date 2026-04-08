--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Provides a "Reveal World Map" feature to show unexplored areas (fog-of-war removal).
-- - Design: Hooks into MapExplorationPins to acquire textures and apply unexplored overlays.
-- - Events: RefreshOverlays hook on MapExplorationPinTemplate.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("WorldMap")

-- PERF: Localize global functions and environment for faster lookups.
local _G = _G
local gmatch = _G.gmatch
local math_ceil = _G.math.ceil
local mod = _G.mod
local pairs = _G.pairs
local string_format = _G.string.format
local string_match = _G.string.match
local table_insert = _G.table.insert
local table_wipe = _G.table.wipe
local tonumber = _G.tonumber

local _G = _G
local C_AddOns = _G.C_AddOns
local C_Map_GetMapArtID = _G.C_Map.GetMapArtID
local C_Map_GetMapArtLayers = _G.C_Map.GetMapArtLayers
local C_MapExplorationInfo_GetExploredMapTextures = _G.C_MapExplorationInfo.GetExploredMapTextures
local CreateFrame = _G.CreateFrame
local TexturePool_HideAndClearAnchors = _G.TexturePool_HideAndClearAnchors
local WorldMapFrame = _G.WorldMapFrame
local hooksecurefunc = _G.hooksecurefunc

local shownMapCache, exploredCache, fileDataIDs, storedTex = {}, {}, {}, {}

local function getStringFromInfo(info)
	return string_format("W%dH%dX%dY%d", info.textureWidth, info.textureHeight, info.offsetX, info.offsetY)
end

local function getShapesFromString(str)
	local w, h, x, y = string_match(str, "W(%d*)H(%d*)X(%d*)Y(%d*)")
	return tonumber(w), tonumber(h), tonumber(x), tonumber(y)
end

local function refreshFileIDsByString(str)
	table_wipe(fileDataIDs)

	for fileID in gmatch(str, "%d+") do
		table_insert(fileDataIDs, fileID)
	end
end

-- REASON: Main overlay refresh logic. Scans unexplored regions and acquires textures from the pin's pool.
function Module:MapData_RefreshOverlays(fullUpdate)
	table_wipe(shownMapCache)
	table_wipe(exploredCache)
	for _, tex in pairs(storedTex) do
		tex:SetVertexColor(1, 1, 1)
	end
	table_wipe(storedTex)

	local mapID = WorldMapFrame.mapID
	if not mapID then
		return
	end

	local mapArtID = C_Map_GetMapArtID(mapID)
	local mapData = mapArtID and C.WorldMapPlusData[mapArtID]
	if not mapData then
		return
	end

	local exploredMapTextures = C_MapExplorationInfo_GetExploredMapTextures(mapID)
	if exploredMapTextures then
		for _, exploredTextureInfo in pairs(exploredMapTextures) do
			exploredCache[getStringFromInfo(exploredTextureInfo)] = true
		end
	end

	if not self.layerIndex then
		self.layerIndex = WorldMapFrame.ScrollContainer:GetCurrentLayerIndex()
	end
	local layers = C_Map_GetMapArtLayers(mapID)
	local layerInfo = layers and layers[self.layerIndex]
	if not layerInfo then
		return
	end

	local tileSizeWidth = layerInfo.tileWidth
	local tileSizeHeight = layerInfo.tileHeight

	-- Blizzard_SharedMapDataProviders\MapExplorationDataProvider: MapExplorationPinMixin:RefreshOverlays
	for i, exploredInfoString in pairs(mapData) do
		if not exploredCache[i] then
			local width, height, offsetX, offsetY = getShapesFromString(i)
			refreshFileIDsByString(exploredInfoString)
			local numTexturesWide = math_ceil(width / tileSizeWidth)
			local numTexturesTall = math_ceil(height / tileSizeHeight)
			local texturePixelWidth, textureFileWidth, texturePixelHeight, textureFileHeight

			for j = 1, numTexturesTall do
				if j < numTexturesTall then
					texturePixelHeight = tileSizeHeight
					textureFileHeight = tileSizeHeight
				else
					texturePixelHeight = mod(height, tileSizeHeight)
					if texturePixelHeight == 0 then
						texturePixelHeight = tileSizeHeight
					end
					textureFileHeight = 16
					while textureFileHeight < texturePixelHeight do
						textureFileHeight = textureFileHeight * 2
					end
				end
				for k = 1, numTexturesWide do
					local texture = self.overlayTexturePool:Acquire()
					table_insert(storedTex, texture)
					if k < numTexturesWide then
						texturePixelWidth = tileSizeWidth
						textureFileWidth = tileSizeWidth
					else
						texturePixelWidth = width % tileSizeWidth
						if texturePixelWidth == 0 then
							texturePixelWidth = tileSizeWidth
						end
						textureFileWidth = 16
						while textureFileWidth < texturePixelWidth do
							textureFileWidth = textureFileWidth * 2
						end
					end
					texture:SetWidth(texturePixelWidth)
					texture:SetHeight(texturePixelHeight)
					texture:SetTexCoord(0, texturePixelWidth / textureFileWidth, 0, texturePixelHeight / textureFileHeight)
					texture:SetPoint("TOPLEFT", offsetX + (tileSizeWidth * (k - 1)), -(offsetY + (tileSizeHeight * (j - 1))))
					texture:SetTexture(fileDataIDs[((j - 1) * numTexturesWide) + k], nil, nil, "TRILINEAR")

					if K.GetCharVars().RevealWorldMap then
						if C["WorldMap"].MapRevealGlow then
							texture:SetVertexColor(0.7, 0.7, 0.7)
						else
							texture:SetVertexColor(1, 1, 1)
						end
						texture:SetDrawLayer("ARTWORK", -2)
						texture:Show()
						if fullUpdate then
							self.textureLoadGroup:AddTexture(texture)
						end
					else
						texture:Hide()
					end
					table_insert(shownMapCache, texture)
				end
			end
		end
	end
end

function Module:MapData_ResetTexturePool(texture)
	texture:SetVertexColor(1, 1, 1)
	texture:SetAlpha(1)
	return TexturePool_HideAndClearAnchors(self, texture)
end

function Module:CreateWorldMapReveal()
	if C_AddOns.IsAddOnLoaded("Leatrix_Maps") then
		return
	end

	-- REASON: CheckButton placed in the WorldMap header to toggle the reveal feature.
	local revealButton = CreateFrame("CheckButton", nil, WorldMapFrame.BorderFrame.TitleContainer, "OptionsBaseCheckButtonTemplate")
	revealButton:SetHitRectInsets(-5, -5, -5, -5)
	revealButton:SetPoint("TOPRIGHT", -260, 0)
	revealButton:SetSize(24, 24)
	revealButton:SetChecked(K.GetCharVars().RevealWorldMap)
	revealButton.text = K.CreateFontString(revealButton, 12, "Map Reveal", "", "system", "LEFT", 24, 0)
	K.AddTooltip(revealButton, "ANCHOR_BOTTOMLEFT", "Show unexplored areas on the world map (removes fog of war).|n|nWhen enabled, hidden tiles are revealed so the full map is visible.", "info", true)

	for pin in WorldMapFrame:EnumeratePinsByTemplate("MapExplorationPinTemplate") do
		hooksecurefunc(pin, "RefreshOverlays", Module.MapData_RefreshOverlays)
		pin.overlayTexturePool.resetterFunc = Module.MapData_ResetTexturePool
	end

	revealButton:SetScript("OnClick", function(self)
		K.GetCharVars().RevealWorldMap = self:GetChecked()

		for i = 1, #shownMapCache do
			shownMapCache[i]:SetShown(K.GetCharVars().RevealWorldMap)
		end
	end)
end
