--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/WorldMap/Core.lua
	Purpose:
		Two world map quality-of-life features:
			Smaller map   shrink the maximized world map so it no longer swallows
			              the whole screen, keeping it out of the way while questing.
			Coordinates   player and cursor coordinates in a corner of the map, read
			              from C_Map and the scroll container's normalized cursor.

		Everything is cosmetic (SetScale, secure hooks on Maximize/Minimize, a corner
		font string), so no taint on the secure map. Retail only: older flavours use
		a different world map frame with no ScrollContainer.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

if not (K.Client and K.Client.IsRetail) then
	return
end

local Module = K:NewModule("WorldMap")

local _G = _G
local next = next
local hooksecurefunc = hooksecurefunc
local CreateFrame = CreateFrame
local C_Map = C_Map
local IsSecret = K.IsSecret

-- Strip the icon markup off the stock "Mouse" label, and the player label.
local MOUSE_LABEL = (_G.MOUSE_LABEL or "Mouse"):gsub("|[TA].-|[ta]", "")
local PLAYER_LABEL = _G.PLAYER or "Player"

-- Where the mouse line sits relative to the player line: the opposite vertical
-- edge, so the two stack cleanly from whichever corner they anchor to.
local INVERTED = {
	TOPLEFT = "BOTTOMLEFT",
	TOPRIGHT = "BOTTOMRIGHT",
	BOTTOMLEFT = "TOPLEFT",
	BOTTOMRIGHT = "TOPRIGHT",
	TOP = "BOTTOM",
	BOTTOM = "TOP",
}

local scale = 0.9
local coords

-- ---------------------------------------------------------------------------
-- Smaller map
-- ---------------------------------------------------------------------------

function Module:SetLargeWorldMap()
	local map = _G.WorldMapFrame
	map:SetScale(1)
	if map.ScrollContainer and map.ScrollContainer.Child then
		map.ScrollContainer.Child:SetScale(scale)
	end
	if map.OnFrameSizeChanged then
		map:OnFrameSizeChanged()
	end
	if map:GetMapID() and map.NavBar and map.NavBar.Refresh then
		map.NavBar:Refresh()
	end
end

function Module:SetSmallWorldMap()
	local map = _G.WorldMapFrame
	if not map:IsMaximized() then
		map:ClearAllPoints()
		map:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 16, -94)
	end
end

function Module:UpdateMaximizedSize()
	local map = _G.WorldMapFrame
	local width, height = map:GetSize()
	local magic = (1 - scale) * 100
	map:SetSize((width * scale) - (magic + 2), (height * scale) - 2)
end

function Module:SynchronizeDisplayState()
	local map = _G.WorldMapFrame
	if map:IsMaximized() then
		map:ClearAllPoints()
		map:SetPoint("CENTER", UIParent)
	end
end

-- Apply the right state once the map first shows, then stop caring.
function Module:FirstShow()
	local map = _G.WorldMapFrame
	local maxed = map.IsMaximized and map:IsMaximized()
	if maxed then
		self:UpdateMaximizedSize()
		self:SetLargeWorldMap()
	else
		self:SetSmallWorldMap()
	end
end

-- ---------------------------------------------------------------------------
-- Coordinates
-- ---------------------------------------------------------------------------

local function PlayerXY()
	local mapID = C_Map.GetBestMapForUnit("player")
	if not mapID then
		return
	end
	local pos = C_Map.GetPlayerMapPosition(mapID, "player")
	if not pos then
		return
	end
	local x, y = pos:GetXY()
	-- Instanced content can hand back a secret position, which cannot be scaled.
	if not x or IsSecret(x) then
		return
	end
	return x, y
end

function Module:UpdateCoords()
	local map = _G.WorldMapFrame
	if not coords or not map:IsShown() then
		return
	end

	local sc = map.ScrollContainer
	if sc and sc:IsMouseOver() then
		local mx, my = sc:GetNormalizedCursorPosition()
		if mx and my and mx >= 0 and my >= 0 then
			coords.mouse:SetFormattedText("%s:  %.1f, %.1f", MOUSE_LABEL, mx * 100, my * 100)
		else
			coords.mouse:SetText("")
		end
	else
		coords.mouse:SetText("")
	end

	local px, py = PlayerXY()
	if px then
		coords.player:SetFormattedText("%s:  %.1f, %.1f", PLAYER_LABEL, px * 100, py * 100)
	else
		coords.player:SetFormattedText("%s:  %s", PLAYER_LABEL, "N/A")
	end
end

function Module:CreateCoords()
	local map = _G.WorldMapFrame

	coords = CreateFrame("Frame", nil, map)
	coords:SetFrameStrata("MEDIUM")
	coords:SetFrameLevel(10)

	local player = coords:CreateFontString(nil, "OVERLAY")
	K.SetFont(player, 13, K.FontOutlineStyle())
	player:SetTextColor(1, 1, 0)
	coords.player = player

	local mouse = coords:CreateFontString(nil, "OVERLAY")
	K.SetFont(mouse, 13, K.FontOutlineStyle())
	mouse:SetTextColor(1, 1, 0)
	coords.mouse = mouse

	local pos = C.WorldMap.CoordPosition or "BOTTOMLEFT"
	local x = pos:find("RIGHT") and -6 or 6
	local y = pos:find("TOP") and -6 or 6
	player:ClearAllPoints()
	player:SetPoint(pos, map.ScrollContainer, pos, x, y)
	mouse:ClearAllPoints()
	mouse:SetPoint(pos, player, INVERTED[pos] or "TOP", 0, y)

	-- Throttled while the map is up. The holder is parented to the map, so the
	-- OnUpdate stops on its own the moment the map hides.
	coords.elapsed = 0
	coords:SetScript("OnUpdate", function(self, elapsed)
		self.elapsed = self.elapsed + elapsed
		if self.elapsed > 0.1 then
			self.elapsed = 0
			Module:UpdateCoords()
		end
	end)
end

-- ---------------------------------------------------------------------------
-- Lifecycle
-- ---------------------------------------------------------------------------

function Module:OnEnable()
	if not C.WorldMap.Enable then
		return
	end
	local map = _G.WorldMapFrame
	if not map then
		return
	end
	scale = C.WorldMap.Scale or 0.9

	if C.WorldMap.SmallerMap then
		if map.BlackoutFrame then
			if map.BlackoutFrame.Blackout then
				map.BlackoutFrame.Blackout:SetTexture(nil)
			end
			map.BlackoutFrame:EnableMouse(false)
		end
		hooksecurefunc(map, "Maximize", function()
			Module:SetLargeWorldMap()
		end)
		hooksecurefunc(map, "Minimize", function()
			Module:SetSmallWorldMap()
		end)
		hooksecurefunc(map, "SynchronizeDisplayState", function()
			Module:SynchronizeDisplayState()
		end)
		hooksecurefunc(map, "UpdateMaximizedSize", function()
			Module:UpdateMaximizedSize()
		end)

		-- Apply the right state on the first open only.
		local applied
		map:HookScript("OnShow", function()
			if not applied then
				applied = true
				Module:FirstShow()
			end
		end)
	end

	if C.WorldMap.Coordinates then
		-- Drop Blizzard's own coords panel so we do not double up.
		if map.overlayFrames then
			for _, frame in next, map.overlayFrames do
				if frame.PlayerCoords and frame.CursorCoords then
					frame:Hide()
					break
				end
			end
		end
		Module:CreateCoords()
	end

	-- Map reveal (Reveal.lua): the unexplored-overlay drawing and its on-map toggle.
	if self.SetupReveal then
		self:SetupReveal()
	end
end
