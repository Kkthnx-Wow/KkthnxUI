local K, C, L = unpack(KkthnxUI)
local Module = K:GetModule("WorldMap")

local _G = _G
local math_ceil = _G.math.ceil
local mod = _G.mod
local table_wipe = _G.table.wipe
local table_insert = _G.table.insert

local C_Map_GetMapArtID = _G.C_Map.GetMapArtID
local C_Map_GetMapArtLayers = _G.C_Map.GetMapArtLayers
local C_MapExplorationInfo_GetExploredMapTextures = _G.C_MapExplorationInfo.GetExploredMapTextures
local CreateFrame = _G.CreateFrame
local hooksecurefunc = _G.hooksecurefunc

local shownMapCache, exploredCache, fileDataIDs = {}, {}, {}

local function GetStringFromInfo(info)
	return string.format("W%dH%dX%dY%d", info.textureWidth, info.textureHeight, info.offsetX, info.offsetY)
end

local function GetShapesFromString(str)
	local w, h, x, y = string.match(str, "W(%d*)H(%d*)X(%d*)Y(%d*)")
	return tonumber(w), tonumber(h), tonumber(x), tonumber(y)
end

local function RefreshFileIDsByString(str)
	table_wipe(fileDataIDs)

	for fileID in gmatch(str, "%d+") do
		table_insert(fileDataIDs, fileID)
	end
end

function Module:MapData_RefreshOverlays(fullUpdate)
	table_wipe(shownMapCache)
	table_wipe(exploredCache)

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
			exploredCache[GetStringFromInfo(exploredTextureInfo)] = true
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

	local TILE_SIZE_WIDTH = layerInfo.tileWidth
	local TILE_SIZE_HEIGHT = layerInfo.tileHeight

	-- Blizzard_SharedMapDataProviders\MapExplorationDataProvider: MapExplorationPinMixin:RefreshOverlays
	for i, exploredInfoString in pairs(mapData) do
		if not exploredCache[i] then
			local width, height, offsetX, offsetY = GetShapesFromString(i)
			RefreshFileIDsByString(exploredInfoString)
			local numTexturesWide = math_ceil(width / TILE_SIZE_WIDTH)
			local numTexturesTall = math_ceil(height / TILE_SIZE_HEIGHT)
			local texturePixelWidth, textureFileWidth, texturePixelHeight, textureFileHeight

			for j = 1, numTexturesTall do
				if j < numTexturesTall then
					texturePixelHeight = TILE_SIZE_HEIGHT
					textureFileHeight = TILE_SIZE_HEIGHT
				else
					texturePixelHeight = mod(height, TILE_SIZE_HEIGHT)
					if texturePixelHeight == 0 then
						texturePixelHeight = TILE_SIZE_HEIGHT
					end

					textureFileHeight = 16
					while textureFileHeight < texturePixelHeight do
						textureFileHeight = textureFileHeight * 2
					end
				end

				for k = 1, numTexturesWide do
					local texture = self.overlayTexturePool:Acquire()
					if k < numTexturesWide then
						texturePixelWidth = TILE_SIZE_WIDTH
						textureFileWidth = TILE_SIZE_WIDTH
					else
						texturePixelWidth = width % TILE_SIZE_WIDTH
						if texturePixelWidth == 0 then
							texturePixelWidth = TILE_SIZE_WIDTH
						end
						textureFileWidth = 16
						while textureFileWidth < texturePixelWidth do
							textureFileWidth = textureFileWidth * 2
						end
					end

					texture:SetWidth(texturePixelWidth)
					texture:SetHeight(texturePixelHeight)
					texture:SetTexCoord(0, texturePixelWidth / textureFileWidth, 0, texturePixelHeight / textureFileHeight)
					texture:SetPoint("TOPLEFT", offsetX + (TILE_SIZE_WIDTH * (k - 1)), -(offsetY + (TILE_SIZE_HEIGHT * (j - 1))))
					texture:SetTexture(fileDataIDs[((j - 1) * numTexturesWide) + k], nil, nil, "TRILINEAR")

					if KkthnxUIDB.Variables[K.Realm][K.Name].RevealWorldMap then
						if C["WorldMap"].MapRevealGlow then
							texture:SetVertexColor(0.7, 0.7, 0.7)
						else
							texture:SetVertexColor(1, 1, 1)
						end
						texture:SetDrawLayer("ARTWORK", -1)
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
	if IsAddOnLoaded("Leatrix_Maps") then
		return
	end

	local bu = CreateFrame("CheckButton", nil, WorldMapFrame.BorderFrame, "OptionsBaseCheckButtonTemplate")
	bu:SetHitRectInsets(-5, -5, -5, -5)
	bu:SetPoint("TOPRIGHT", -260, 0)
	bu:SetSize(24, 24)
	bu:SetFrameLevel(999)
	bu:SetChecked(KkthnxUIDB.Variables[K.Realm][K.Name].RevealWorldMap)

	bu.text = bu:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	bu.text:SetPoint("LEFT", 24, 0)
	bu.text:SetText("Map Reveal")

	for pin in WorldMapFrame:EnumeratePinsByTemplate("MapExplorationPinTemplate") do
		hooksecurefunc(pin, "RefreshOverlays", Module.MapData_RefreshOverlays)
		pin.overlayTexturePool.resetterFunc = Module.MapData_ResetTexturePool
	end

	bu:SetScript("OnClick", function(self)
		KkthnxUIDB.Variables[K.Realm][K.Name].RevealWorldMap = self:GetChecked()

		for i = 1, #shownMapCache do
			shownMapCache[i]:SetShown(KkthnxUIDB.Variables[K.Realm][K.Name].RevealWorldMap)
		end
	end)
end
