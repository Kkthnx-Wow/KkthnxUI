--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Displays the player's current map coordinates as a DataText element.
-- - Design: Throttled OnUpdate script for performance, with event-based map and zone lookups.
-- - Events: ZONE_CHANGED, ZONE_CHANGED_INDOORS, ZONE_CHANGED_NEW_AREA, PLAYER_ENTERING_WORLD
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("DataText")

-- PERF: Localize globals and API functions to reduce lookup overhead.
local _G = _G
local C_Map_GetBestMapForUnit = _G.C_Map.GetBestMapForUnit
local C_Map_GetPlayerMapPosition = _G.C_Map.GetPlayerMapPosition
local C_PvP_GetZonePVPInfo = _G.C_PvP.GetZonePVPInfo
local CreateFrame = _G.CreateFrame
local GameTooltip = _G.GameTooltip
local GetSubZoneText = _G.GetSubZoneText
local GetTime = _G.GetTime
local GetZoneText = _G.GetZoneText
local IsInInstance = _G.IsInInstance
local ToggleWorldMap = _G.ToggleWorldMap
local UIParent = _G.UIParent
local UnitExists = _G.UnitExists
local UnitIsPlayer = _G.UnitIsPlayer
local UnitName = _G.UnitName
local ipairs = ipairs
local math_ceil = math.ceil
local math_floor = math.floor
local math_max = math.max
local pairs = pairs
local print = print
local string_format = string.format
local string_join = string.join
local tContains = tContains
local unpack = unpack

-- ---------------------------------------------------------------------------
-- State & Constants
-- ---------------------------------------------------------------------------
local coordsDataText
local coordX, coordY = 0, 0
local currentMapID
local faction
local lastRightClick = 0
local pvpType
local subZoneText
local zoneText

local ZONE_INFO = {
	arena = { _G.FREE_FOR_ALL_TERRITORY, { 0.84, 0.03, 0.03 } },
	combat = { _G.COMBAT_ZONE, { 0.84, 0.03, 0.03 } },
	contested = { _G.CONTESTED_TERRITORY, { 0.9, 0.85, 0.05 } },
	friendly = { _G.FACTION_CONTROLLED_TERRITORY, { 0.05, 0.85, 0.03 } },
	hostile = { _G.FACTION_CONTROLLED_TERRITORY, { 0.84, 0.03, 0.03 } },
	neutral = { string_format(_G.FACTION_CONTROLLED_TERRITORY, _G.FACTION_STANDING_LABEL4), { 0.9, 0.85, 0.05 } },
	sanctuary = { _G.SANCTUARY_TERRITORY, { 0.035, 0.58, 0.84 } },
}

local EVENT_LIST = {
	"ZONE_CHANGED",
	"ZONE_CHANGED_INDOORS",
	"ZONE_CHANGED_NEW_AREA",
	"PLAYER_ENTERING_WORLD",
}

-- ---------------------------------------------------------------------------
-- Internal Logic
-- ---------------------------------------------------------------------------
local function updateMapID()
	-- REASON: Retrieves the current MapID for the player, which is required for coordinate lookups.
	currentMapID = C_Map_GetBestMapForUnit("player")
end

local function formatCoords()
	-- REASON: Optimized coordinate formatting using floor/rounding to avoid high-frequency string logic.
	local x = math_floor(coordX * 100 + 0.5)
	local y = math_floor(coordY * 100 + 0.5)
	return string_join(" ", x, y)
end

local function onUpdate(self, elapsed)
	-- REASON: Throttled update cycle to maintain high UI performance while providing smooth coordinate readout.
	self.elapsed = (self.elapsed or 0) + elapsed
	if self.elapsed > 0.1 then
		self.elapsed = 0

		if not currentMapID then
			updateMapID()
			return
		end

		local position = C_Map_GetPlayerMapPosition(currentMapID, "player")
		if position then
			coordX, coordY = position.x, position.y
			coordsDataText.Text:SetText(formatCoords())
			coordsDataText:Show()

			-- REASON: Dynamically resize the mover and frame to accommodate changing text widths.
			local textW = coordsDataText.Text:GetStringWidth() or 0
			local textH = coordsDataText.Text:GetLineHeight() or 12
			local iconW = (coordsDataText.Texture and coordsDataText.Texture:GetWidth()) or 0
			local iconH = (coordsDataText.Texture and coordsDataText.Texture:GetHeight()) or 0
			local totalW = math_max(textW, iconW)
			local totalH = iconH + 2 + textH
			coordsDataText:SetSize(math_max(totalW, 56), totalH)

			if coordsDataText.mover then
				coordsDataText.mover:SetWidth(math_max(totalW, 56))
				coordsDataText.mover:SetHeight(totalH)
			end
		else
			-- REASON: Clear cached MapID if position lookup fails (e.g., world map transition).
			currentMapID = nil
			coordX, coordY = 0, 0
			coordsDataText:Hide()
		end
	end
end

local function onEvent(_, event)
	-- REASON: Updates zone information and MapID whenever the player transitions between areas.
	if tContains(EVENT_LIST, event) then
		updateMapID()
		subZoneText = GetSubZoneText()
		zoneText = GetZoneText()
		pvpType, _, faction = C_PvP_GetZonePVPInfo()
		pvpType = pvpType or "neutral"
	end
end

local function onEnter()
	-- REASON: Displays detailed zone and PvP status information in the tooltip.
	GameTooltip:SetOwner(coordsDataText, "ANCHOR_BOTTOM", 0, -15)
	GameTooltip:ClearLines()

	if pvpType and not IsInInstance() then
		local r, g, b = unpack(ZONE_INFO[pvpType][2])
		if zoneText and subZoneText and subZoneText ~= "" then
			GameTooltip:AddLine(K.GreyColor .. _G.ZONE .. ":|r " .. zoneText, r, g, b)
			GameTooltip:AddLine(K.GreyColor .. "SubZone" .. ":|r " .. subZoneText, r, g, b)
		else
			GameTooltip:AddLine(K.GreyColor .. _G.ZONE .. ":|r " .. zoneText, r, g, b)
		end
		GameTooltip:AddLine(string_format(K.GreyColor .. "PvPType" .. ":|r " .. ZONE_INFO[pvpType][1], faction or ""), r, g, b)
	end

	GameTooltip:AddLine(" ")
	GameTooltip:AddLine(K.LeftButton .. "Toggle WorldMap", 0.6, 0.8, 1)
	GameTooltip:AddLine(K.RightButton .. "Send My Position", 0.6, 0.8, 1)
	GameTooltip:Show()
end

local function onLeave()
	GameTooltip:Hide()
end

local function onMouseUp(_, btn)
	-- REASON: Handles interaction: Left-click for World Map, Right-click for sharing position link.
	if btn == "LeftButton" then
		ToggleWorldMap()
	elseif btn == "RightButton" then
		if GetTime() - lastRightClick > 5 then
			local mapID = C_Map_GetBestMapForUnit("player")
			local hasUnit = UnitExists("target") and not UnitIsPlayer("target")
			local unitName = hasUnit and UnitName("target") or ""
			local zoneString = "|cffffff00|Hworldmap:%d+:%d+:%d+|h[|A:Waypoint-MapPin-ChatIcon:13:13:0:0|a %s: %s (%s) %s]|h|r"
			print(string_format(zoneString, mapID, coordX * 10000, coordY * 10000, "My Position", zoneText, formatCoords(), unitName))
			lastRightClick = GetTime()
		else
			print("You can send your position again in " .. math_ceil(5 - (GetTime() - lastRightClick)) .. " seconds.")
		end
	end
end

-- ---------------------------------------------------------------------------
-- Initialization
-- ---------------------------------------------------------------------------
function Module:CreateCoordsDataText()
	-- REASON: Entry point for coordinate DataText creation; initializes frame, textures, and scripts.
	if not C["DataText"].Coords then
		return
	end

	coordsDataText = CreateFrame("Frame", nil, UIParent)
	coordsDataText:SetHitRectInsets(0, 0, -10, -10)
	coordsDataText:SetPoint("TOP", UIParent, "TOP", 0, -90)

	-- REASON: Create the icon representing coordinates.
	coordsDataText.Texture = coordsDataText:CreateTexture(nil, "ARTWORK")
	coordsDataText.Texture:SetPoint("TOP", coordsDataText, "TOP", 0, 0)
	coordsDataText.Texture:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\DataText\\coords.blp")
	coordsDataText.Texture:SetSize(24, 24)
	coordsDataText.Texture:SetVertexColor(unpack(C["DataText"].IconColor))

	-- REASON: Create the text string displayed below the icon.
	coordsDataText.Text = K.CreateFontString(coordsDataText, 12)
	coordsDataText.Text:ClearAllPoints()
	coordsDataText.Text:SetPoint("TOP", coordsDataText.Texture, "BOTTOM", 0, -2)

	for _, event in pairs(EVENT_LIST) do
		coordsDataText:RegisterEvent(event)
	end

	coordsDataText:SetScript("OnEvent", onEvent)
	coordsDataText:SetScript("OnEnter", onEnter)
	coordsDataText:SetScript("OnLeave", onLeave)
	coordsDataText:SetScript("OnMouseUp", onMouseUp)
	coordsDataText:SetScript("OnUpdate", onUpdate)

	-- REASON: Registers the frame with the KkthnxUI mover system for user-controlled positioning.
	coordsDataText.mover = K.Mover(coordsDataText, "CoordsDT", "CoordsDT", { "TOP", UIParent, "TOP", 0, -90 }, 56, 24)
end
