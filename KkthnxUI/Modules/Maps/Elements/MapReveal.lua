local K, C, L = unpack(select(2, ...))
local Module = K:GetModule("WorldMap")

local _G = _G
local math_ceil = _G.math.ceil
local mod = _G.mod
local string_split = _G.string.split
local table_insert = _G.table.insert

local C_Map_GetMapArtID = _G.C_Map.GetMapArtID
local C_Map_GetMapArtLayers = _G.C_Map.GetMapArtLayers
local C_MapExplorationInfo_GetExploredMapTextures = _G.C_MapExplorationInfo.GetExploredMapTextures
local CreateFrame = _G.CreateFrame
local GameTooltip = _G.GameTooltip
local hooksecurefunc = _G.hooksecurefunc
local IsAddOnLoaded = _G.IsAddOnLoaded

-- Create table to store revealed overlays
local overlayTextures = {}
local function MapExplorationPin_RefreshOverlays(pin, fullUpdate)
	overlayTextures = {}

	local mapID = WorldMapFrame.mapID
	if not mapID then
		return
	end

	local artID = C_Map_GetMapArtID(mapID)
	if not artID or not C.WorldMapPlusData[artID] then
		return
	end

	local LeaMapsZone = C.WorldMapPlusData[artID]

	-- Store already explored tiles in a table so they can be ignored
	local TileExists = {}
	local exploredMapTextures = C_MapExplorationInfo_GetExploredMapTextures(mapID)
	if exploredMapTextures then
		for _, exploredTextureInfo in ipairs(exploredMapTextures) do
			local key = exploredTextureInfo.textureWidth..":"..exploredTextureInfo.textureHeight..":"..exploredTextureInfo.offsetX..":"..exploredTextureInfo.offsetY
			TileExists[key] = true
		end
	end

	-- Get the sizes
	pin.layerIndex = pin:GetMap():GetCanvasContainer():GetCurrentLayerIndex()

	local layers = C_Map_GetMapArtLayers(mapID)
	local layerInfo = layers and layers[pin.layerIndex]
	if not layerInfo then
		return
	end

	local TILE_SIZE_WIDTH = layerInfo.tileWidth
	local TILE_SIZE_HEIGHT = layerInfo.tileHeight

	-- Show textures if they are in database and have not been explored
	for key, files in pairs(LeaMapsZone) do
		if not TileExists[key] then
			local width, height, offsetX, offsetY = string_split(":", key)
			local fileDataIDs = { string_split(",", files) }
			local numTexturesWide = math_ceil(width / TILE_SIZE_WIDTH)
			local numTexturesTall = math_ceil(height / TILE_SIZE_HEIGHT)
			local texturePixelWidth, textureFileWidth, texturePixelHeight, textureFileHeight
			for j = 1, numTexturesTall do
				if (j < numTexturesTall) then
					texturePixelHeight = TILE_SIZE_HEIGHT
					textureFileHeight = TILE_SIZE_HEIGHT
				else
					texturePixelHeight = mod(height, TILE_SIZE_HEIGHT)
					if (texturePixelHeight == 0) then
						texturePixelHeight = TILE_SIZE_HEIGHT
					end
					textureFileHeight = 16
					while (textureFileHeight < texturePixelHeight) do
						textureFileHeight = textureFileHeight * 2
					end
				end

				for k = 1, numTexturesWide do
					local texture = pin.overlayTexturePool:Acquire()
					if (k < numTexturesWide) then
						texturePixelWidth = TILE_SIZE_WIDTH
						textureFileWidth = TILE_SIZE_WIDTH
					else
						texturePixelWidth = mod(width, TILE_SIZE_WIDTH)
						if (texturePixelWidth == 0) then
							texturePixelWidth = TILE_SIZE_WIDTH
						end
						textureFileWidth = 16
						while(textureFileWidth < texturePixelWidth) do
							textureFileWidth = textureFileWidth * 2
						end
					end

					texture:SetSize(texturePixelWidth, texturePixelHeight)
					texture:SetTexCoord(0, texturePixelWidth/textureFileWidth, 0, texturePixelHeight / textureFileHeight)
					texture:SetPoint("TOPLEFT", offsetX + (TILE_SIZE_WIDTH * (k - 1)), -(offsetY + (TILE_SIZE_HEIGHT * (j - 1))))
					texture:SetTexture(tonumber(fileDataIDs[((j - 1) * numTexturesWide) + k]), nil, nil, "TRILINEAR")
					texture:SetDrawLayer("ARTWORK", -1)

					if KkthnxUIDB.Variables[K.Realm][K.Name].RevealWorldMap then
						texture:Show()
						if fullUpdate then
							pin.textureLoadGroup:AddTexture(texture)
						end
					else
						texture:Hide()
					end

					if C["WorldMap"].MapRevealGlow then
						texture:SetVertexColor(unpack(C["WorldMap"].MapRevealGlowColor))
					else
						texture:SetVertexColor(1, 1, 1)
					end

					table_insert(overlayTextures, texture)
				end
			end
		end
	end
end

-- Reset texture color and alpha
local function TexturePool_ResetVertexColor(pool, texture)
	texture:SetVertexColor(1, 1, 1)
	texture:SetAlpha(1)

	return TexturePool_HideAndClearAnchors(pool, texture)
end

function Module:CreateWorldMapReveal()
	if IsAddOnLoaded("Leatrix_Maps") then
		return
	end

	local bu = CreateFrame("CheckButton", nil, _G.WorldMapFrame.BorderFrame, "OptionsCheckButtonTemplate")
	bu:SetPoint("TOPRIGHT", -260, 0)
	bu:SetSize(24, 24)
	bu:SetChecked(KkthnxUIDB.Variables[K.Realm][K.Name].RevealWorldMap)

	bu.text = bu:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	bu.text:SetPoint("LEFT", 24, 0)
	bu.text:SetText("Map Reveal")
	bu:SetHitRectInsets(0, 0 - bu.text:GetWidth(), 0, 0)
	bu.text:Show()

	-- Show overlays on startup
	for pin in WorldMapFrame:EnumeratePinsByTemplate("MapExplorationPinTemplate") do
		hooksecurefunc(pin, "RefreshOverlays", MapExplorationPin_RefreshOverlays)
		pin.overlayTexturePool.resetterFunc = TexturePool_ResetVertexColor
	end

	function bu.UpdateTooltip(self)
		if (GameTooltip:IsForbidden()) then
			return
		end

		GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, 10)

		local r, g, b = 0.2, 1.0, 0.2

		if KkthnxUIDB.Variables[K.Realm][K.Name].RevealWorldMap == true then
			GameTooltip:AddLine(L["Hide Undiscovered Areas"])
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(L["Disable to hide areas."], r, g, b)
		else
			GameTooltip:AddLine(L["Reveal Hidden Areas"])
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(L["Enable to show hidden areas."], r, g, b)
		end

		GameTooltip:Show()
	end

	bu:HookScript("OnEnter", function(self)
		if (GameTooltip:IsForbidden()) then
			return
		end

		self:UpdateTooltip()
	end)

	bu:HookScript("OnLeave", function()
		if (GameTooltip:IsForbidden()) then
			return
		end

		GameTooltip:Hide()
	end)

	bu:SetScript("OnClick", function(self)
		KkthnxUIDB.Variables[K.Realm][K.Name].RevealWorldMap = self:GetChecked()
		for i = 1, #overlayTextures do
			overlayTextures[i]:SetShown(KkthnxUIDB.Variables[K.Realm][K.Name].RevealWorldMap)
		end
	end)
end