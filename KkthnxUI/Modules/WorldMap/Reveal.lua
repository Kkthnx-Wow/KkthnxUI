--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/WorldMap/Reveal.lua
	Purpose:
		Map Reveal: draw the parts of a zone map the player has not explored yet, so
		the whole map is visible instead of fogged. The overlay tiles come from the
		raw data in RawMapData.lua (Blizzard's own map art, collected from a fully
		explored account), rendered the way the client tiles its exploration
		overlays. A labelled checkbox on the world map's title bar quick-toggles it
		on and off, and the choice is saved.

		The heavy function is hooked onto each MapExplorationPin's RefreshOverlays,
		so it runs whenever the map redraws its exploration layer. Retail only.
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]

if not (K.Client and K.Client.IsRetail) then
	return
end

local Module = K:GetModule("WorldMap")

local _G = _G
local pairs = pairs
local wipe = wipe
local ceil = math.ceil
local tinsert = table.insert
local tonumber = tonumber
local gmatch = string.gmatch
local strmatch = string.match
local format = string.format
local hooksecurefunc = hooksecurefunc
local CreateFrame = CreateFrame
local C_Map = C_Map
local C_MapExplorationInfo = C_MapExplorationInfo
local WorldMapFrame = _G.WorldMapFrame
local GameTooltip = _G.GameTooltip
local TexturePool_HideAndClearAnchors = _G.TexturePool_HideAndClearAnchors

-- Scratch tables reused across refreshes so a redraw never churns garbage. shown
-- holds the overlays we drew this pass (so the toggle can show/hide them live).
local shown, exploredKeys, fileIDs, active = {}, {}, {}, {}

-- The overlay data keys a region as "W<w>H<h>X<x>Y<y>". These turn a live explored
-- texture into that key, and a key back into its numbers.
local function KeyFromInfo(info)
	return format("W%dH%dX%dY%d", info.textureWidth, info.textureHeight, info.offsetX, info.offsetY)
end

local function ShapeFromKey(key)
	local w, h, x, y = strmatch(key, "W(%d+)H(%d+)X(%d+)Y(%d+)")
	return tonumber(w), tonumber(h), tonumber(x), tonumber(y)
end

local function FileIDsFromString(str)
	wipe(fileIDs)
	for id in gmatch(str, "%d+") do
		tinsert(fileIDs, tonumber(id))
	end
end

-- Smallest power of two at or above n, for the ragged edge tiles whose file is
-- padded up to a power of two even though the drawn pixels are not.
local function NextPow2(n)
	local size = 16
	while size < n do
		size = size * 2
	end
	return size
end

-- Hooked onto a MapExplorationPin's RefreshOverlays, so `pin` is that pin. For the
-- current map it walks our raw overlay data and draws every region the player has
-- not explored, tiling each region exactly the way the client does its own
-- exploration overlays.
local function RefreshOverlays(pin, fullUpdate)
	wipe(shown)
	wipe(exploredKeys)
	for _, tex in pairs(active) do
		tex:SetVertexColor(1, 1, 1)
	end
	wipe(active)

	-- With reveal off, do no further work in this hook. Running the overlay draw
	-- here taints the map's refresh, which then breaks Blizzard's own secret sized
	-- widget tooltips on area points of interest. Off means untouched.
	if not C.WorldMap.Reveal then
		return
	end

	local mapID = WorldMapFrame:GetMapID()
	if not mapID then
		return
	end
	local artID = C_Map.GetMapArtID(mapID)
	local data = artID and Module.RawMapData[artID]
	if not data then
		return
	end

	-- Regions the player already explored are drawn by the client, so skip ours for
	-- those or they would double up.
	local explored = C_MapExplorationInfo.GetExploredMapTextures(mapID)
	if explored then
		for _, info in pairs(explored) do
			exploredKeys[KeyFromInfo(info)] = true
		end
	end

	if not pin.__kkuiLayer then
		pin.__kkuiLayer = WorldMapFrame.ScrollContainer:GetCurrentLayerIndex()
	end
	local layers = C_Map.GetMapArtLayers(mapID)
	local layer = layers and layers[pin.__kkuiLayer]
	if not layer then
		return
	end
	local tileW, tileH = layer.tileWidth, layer.tileHeight

	local reveal = C.WorldMap.Reveal
	local shade = C.WorldMap.RevealDim and 0.7 or 1

	for key, idString in pairs(data) do
		if not exploredKeys[key] then
			local width, height, offsetX, offsetY = ShapeFromKey(key)
			FileIDsFromString(idString)
			local wide = ceil(width / tileW)
			local tall = ceil(height / tileH)

			for row = 1, tall do
				local pixelH = (row < tall) and tileH or (height % tileH)
				if pixelH == 0 then
					pixelH = tileH
				end
				local fileH = (row < tall) and tileH or NextPow2(pixelH)

				for col = 1, wide do
					local pixelW = (col < wide) and tileW or (width % tileW)
					if pixelW == 0 then
						pixelW = tileW
					end
					local fileW = (col < wide) and tileW or NextPow2(pixelW)

					local texture = pin.overlayTexturePool:Acquire()
					tinsert(active, texture)
					texture:SetWidth(pixelW)
					texture:SetHeight(pixelH)
					texture:SetTexCoord(0, pixelW / fileW, 0, pixelH / fileH)
					texture:SetPoint("TOPLEFT", offsetX + tileW * (col - 1), -(offsetY + tileH * (row - 1)))
					texture:SetTexture(fileIDs[(row - 1) * wide + col], nil, nil, "TRILINEAR")

					if reveal then
						texture:SetVertexColor(shade, shade, shade)
						texture:SetDrawLayer("ARTWORK", -1)
						texture:Show()
						if fullUpdate and pin.textureLoadGroup then
							pin.textureLoadGroup:AddTexture(texture)
						end
					else
						texture:Hide()
					end
					tinsert(shown, texture)
				end
			end
		end
	end
end

-- Return a pooled overlay texture to a clean state before it is reused.
local function ResetTexture(pool, texture)
	texture:SetVertexColor(1, 1, 1)
	texture:SetAlpha(1)
	return TexturePool_HideAndClearAnchors(pool, texture)
end

-- The pins are created when the map first draws, so hooking may need a retry on
-- the first show. Runs once successfully.
local hooked
local function HookPins()
	-- Only take the hook while reveal is on. A secure hook here spreads taint into
	-- the map refresh, so an off setting must leave the map completely alone.
	if not C.WorldMap.Reveal or hooked or not WorldMapFrame.EnumeratePinsByTemplate then
		return
	end
	for pin in WorldMapFrame:EnumeratePinsByTemplate("MapExplorationPinTemplate") do
		hooked = true
		hooksecurefunc(pin, "RefreshOverlays", RefreshOverlays)
		if pin.overlayTexturePool then
			pin.overlayTexturePool.resetterFunc = ResetTexture
		end
	end
end

function Module:SetupReveal()
	if not Module.RawMapData then
		return
	end

	local border = WorldMapFrame.BorderFrame
	local check = CreateFrame("CheckButton", "KKUI_MapRevealCheck", border or WorldMapFrame, "UICheckButtonTemplate")
	check:SetSize(24, 24)
	check:SetHitRectInsets(-4, -4, -4, -4)
	-- The border frame draws its own title art over its children, so lift the box
	-- (and its label) above it or it hides behind the map header.
	check:SetFrameLevel((border and border:GetFrameLevel() or 1) + 10)

	-- Sit just to the left of the map's maximize/minimize button, where the title
	-- bar has open room. The label reads inward, to the left of the box.
	local maxMin = border and border.MaximizeMinimizeButton
	if maxMin then
		check:SetPoint("RIGHT", maxMin, "LEFT", -4, 0)
	else
		check:SetPoint("TOPRIGHT", WorldMapFrame, "TOPRIGHT", -60, -4)
	end
	if K.SkinCheckBox then
		K.SkinCheckBox(check)
	end
	check:SetChecked(C.WorldMap.Reveal)

	local label = check:CreateFontString(nil, "OVERLAY")
	K.SetFont(label, 13, K.FontOutlineStyle())
	label:SetPoint("RIGHT", check, "LEFT", -2, 0)
	label:SetText(L["Map Reveal"])

	-- Quick toggle: flip the saved setting and show or hide what is already drawn,
	-- so it applies instantly without waiting for the next map redraw.
	check:SetScript("OnClick", function(self)
		local on = self:GetChecked() and true or false
		C.WorldMap.Reveal = on
		if on then
			-- Take the hook now if this is the first time on, then draw for the pins
			-- already on the map so it applies without waiting for a redraw.
			HookPins()
			if WorldMapFrame.EnumeratePinsByTemplate then
				for pin in WorldMapFrame:EnumeratePinsByTemplate("MapExplorationPinTemplate") do
					if pin.RefreshOverlays then
						pin:RefreshOverlays(true)
					end
				end
			end
		else
			for i = 1, #shown do
				shown[i]:SetShown(false)
			end
		end
	end)

	check:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_LEFT")
		GameTooltip:AddLine(L["Map Reveal"])
		GameTooltip:AddLine(L["Show the parts of the zone you have not explored yet."], 0.6, 0.6, 0.6, true)
		GameTooltip:Show()
	end)
	check:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)

	HookPins()
	WorldMapFrame:HookScript("OnShow", HookPins)
end
