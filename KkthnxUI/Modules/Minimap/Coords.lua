--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/Minimap/Coords.lua
	Purpose:
		A small player-coordinate readout in the bottom-left of the minimap, updated
		on a light throttle. Hidden wherever the map has no player position (most
		instances), so it never shows a stale or zeroed reading.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

local Module = K:GetModule("Minimap")

local _G = _G
local C_Map = _G.C_Map
local IsSecret = K.IsSecret

local Minimap = _G.Minimap

local function PlayerXY()
	if not (C_Map and C_Map.GetBestMapForUnit and C_Map.GetPlayerMapPosition) then
		return nil
	end
	local mapID = C_Map.GetBestMapForUnit("player")
	if not mapID then
		return nil
	end
	local pos = C_Map.GetPlayerMapPosition(mapID, "player")
	if not pos then
		return nil
	end
	local x, y = pos:GetXY()
	-- Guard the Midnight secret case before any arithmetic or formatting.
	if not x or not y or IsSecret(x) or IsSecret(y) or (x == 0 and y == 0) then
		return nil
	end
	return x * 100, y * 100
end

function Module:CreateCoords()
	if not C.Minimap.ShowCoords then
		return
	end

	local coords = Minimap:CreateFontString(nil, "OVERLAY")
	K.SetFont(coords, C.Minimap.LocationFontSize or 12, K.FontOutlineStyle())
	coords:SetPoint("BOTTOMLEFT", Minimap, "BOTTOMLEFT", 4, 4)
	coords:SetTextColor(K.Colors.gold[1], K.Colors.gold[2], K.Colors.gold[3])
	coords:SetDrawLayer("OVERLAY", 7)
	self.coords = coords

	-- A FontString cannot take an OnUpdate, so a small driver frame runs the
	-- throttled poll and writes the text. Cheaper than a coordinate event and
	-- always current.
	local driver = CreateFrame("Frame", nil, Minimap)
	local elapsed = 0.5
	driver:SetScript("OnUpdate", function(_, delta)
		elapsed = elapsed + delta
		if elapsed < 0.5 then
			return
		end
		elapsed = 0
		local x, y = PlayerXY()
		if x then
			coords:SetFormattedText("%.1f, %.1f", x, y)
			coords:Show()
		else
			coords:SetText("")
		end
	end)
	self.coordsDriver = driver
end
