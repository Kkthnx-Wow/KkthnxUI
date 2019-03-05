local K = unpack(select(2, ...))

local _G = _G
local select = select
local pairs = pairs

local Enum = _G.Enum
local IsFalling = _G.IsFalling
local CreateFrame = _G.CreateFrame
local UnitPosition = _G.UnitPosition
local GetUnitSpeed = _G.GetUnitSpeed
local CreateVector2D = _G.CreateVector2D
local C_Map_GetMapInfo = _G.C_Map.GetMapInfo
local C_Map_GetBestMapForUnit = _G.C_Map.GetBestMapForUnit
local C_Map_GetWorldPosFromMapPos = _G.C_Map.GetWorldPosFromMapPos
local MapUtil = _G.MapUtil

K.MapInfo = {}
function K:MapInfo_Update()
	local mapID = C_Map_GetBestMapForUnit("player")

	local mapInfo = mapID and C_Map_GetMapInfo(mapID)
	K.MapInfo.name = (mapInfo and mapInfo.name) or nil
	K.MapInfo.mapType = (mapInfo and mapInfo.mapType) or nil
	K.MapInfo.parentMapID = (mapInfo and mapInfo.parentMapID) or nil

	K.MapInfo.mapID = mapID or nil
	K.MapInfo.zoneText = (mapID and K:GetZoneText(mapID)) or nil

	local continent = mapID and MapUtil.GetMapParentInfo(mapID, Enum.UIMapType.Continent, true)
	K.MapInfo.continentParentMapID = (continent and continent.parentMapID) or nil
	K.MapInfo.continentMapType = (continent and continent.mapType) or nil
	K.MapInfo.continentMapID = (continent and continent.mapID) or nil
	K.MapInfo.continentName = (continent and continent.name) or nil

	K:MapInfo_CoordsUpdate()
end

local coordsWatcher = CreateFrame("Frame")
function K:MapInfo_CoordsStart()
	K.MapInfo.coordsWatching = true
	K.MapInfo.coordsFalling = nil
	coordsWatcher:SetScript("OnUpdate", K.MapInfo_OnUpdate)

	if K.MapInfo.coordsStopTimer then
		K:CancelTimer(K.MapInfo.coordsStopTimer)
		K.MapInfo.coordsStopTimer = nil
	end
end

function K:MapInfo_CoordsStopWatching()
	K.MapInfo.coordsWatching = nil
	K.MapInfo.coordsStopTimer = nil
	coordsWatcher:SetScript("OnUpdate", nil)
end

function K:MapInfo_CoordsStop(event)
	if event == "CRITERIA_UPDATE" then
		if not K.MapInfo.coordsFalling then -- stop if we weren"t falling
			return
		end

		if (GetUnitSpeed("player") or 0) > 0 then -- we are still moving!
			return
		end
		K.MapInfo.coordsFalling = nil -- we were falling!
	elseif (event == "PLAYER_STOPPED_MOVING" or event == "PLAYER_CONTROL_GAINED") and IsFalling() then
		K.MapInfo.coordsFalling = true
		return
	end

	if not K.MapInfo.coordsStopTimer then
		K.MapInfo.coordsStopTimer = K:ScheduleTimer("MapInfo_CoordsStopWatching", 0.5)
	end
end

function K:MapInfo_CoordsUpdate()
	if K.MapInfo.mapID then
		K.MapInfo.x, K.MapInfo.y = K:GetPlayerMapPos(K.MapInfo.mapID)
	else
		K.MapInfo.x, K.MapInfo.y = nil, nil
	end

	if K.MapInfo.x and K.MapInfo.y then
		K.MapInfo.xText = K.Round(100 * K.MapInfo.x, 2)
		K.MapInfo.yText = K.Round(100 * K.MapInfo.y, 2)
	else
		K.MapInfo.xText, K.MapInfo.yText = nil, nil
	end
end

function K:MapInfo_OnUpdate(elapsed)
	self.lastUpdate = (self.lastUpdate or 0) + elapsed
	if self.lastUpdate > 0.1 then
		K:MapInfo_CoordsUpdate()
		self.lastUpdate = 0
	end
end

-- This code fixes C_Map.GetPlayerMapPosition memory leak.
-- Fix stolen from NDui (and modified by Simpy). Credit: siweia.
local mapRects, tempVec2D = {}, CreateVector2D(0, 0)
function K:GetPlayerMapPos(mapID)
	tempVec2D.x, tempVec2D.y = UnitPosition("player")
	if not tempVec2D.x then
		return
	end

	local mapRect = mapRects[mapID]
	if not mapRect then
		mapRect = {select(2, C_Map_GetWorldPosFromMapPos(mapID, CreateVector2D(0, 0))), select(2, C_Map_GetWorldPosFromMapPos(mapID, CreateVector2D(1, 1)))}
		mapRect[2]:Subtract(mapRect[1])
		mapRects[mapID] = mapRect
	end
	tempVec2D:Subtract(mapRect[1])

	return (tempVec2D.y / mapRect[2].y), (tempVec2D.x / mapRect[2].x)
end

-- Code taken from LibTourist-3.0 and rewritten to fit our purpose
local localizedMapNames = {}
local ZoneIDToContinentName = {
	[104] = "Outland",
	[107] = "Outland",
}

local MapIdLookupTable = {
	[101] = "Outland",
	[104] = "Shadowmoon Valley",
	[107] = "Nagrand",
}

local function LocalizeZoneNames()
	local mapInfo
	for mapID, englishName in pairs(MapIdLookupTable) do
		mapInfo = C_Map_GetMapInfo(mapID)
		-- Add combination of English and localized name to lookup table
		if mapInfo and mapInfo.name and not localizedMapNames[englishName] then
			localizedMapNames[englishName] = mapInfo.name
		end
	end
end
LocalizeZoneNames()

-- Add " (Outland)" to the end of zone name for Nagrand and Shadowmoon Valley, if mapID matches Outland continent.
-- We can then use this function when we need to compare the players own zone against return values from stuff like GetFriendInfo and GetGuildRosterInfo,
-- which adds the " (Outland)" part unlike the GetRealZoneText() API.
function K:GetZoneText(mapID)
	if not (mapID and K.MapInfo.name) then
		return
	end

	local continent, zoneName = ZoneIDToContinentName[mapID]
	if continent and continent == "Outland" then
		if K.MapInfo.name == localizedMapNames.Nagrand or K.MapInfo.name == "Nagrand"  then
			zoneName = localizedMapNames.Nagrand.." ("..localizedMapNames.Outland..")"
		elseif K.MapInfo.name == localizedMapNames["Shadowmoon Valley"] or K.MapInfo.name == "Shadowmoon Valley"  then
			zoneName = localizedMapNames["Shadowmoon Valley"].." ("..localizedMapNames.Outland..")"
		end
	end

	return zoneName or K.MapInfo.name
end

K:RegisterEvent("CRITERIA_UPDATE", "MapInfo_CoordsStop") -- when the player goes into an animation (landing)
K:RegisterEvent("PLAYER_STARTED_MOVING", "MapInfo_CoordsStart")
K:RegisterEvent("PLAYER_STOPPED_MOVING", "MapInfo_CoordsStop")
K:RegisterEvent("PLAYER_CONTROL_LOST", "MapInfo_CoordsStart")
K:RegisterEvent("PLAYER_CONTROL_GAINED", "MapInfo_CoordsStop")
K:RegisterEvent("ZONE_CHANGED_NEW_AREA", "MapInfo_Update")
K:RegisterEvent("ZONE_CHANGED_INDOORS", "MapInfo_Update")
K:RegisterEvent("ZONE_CHANGED", "MapInfo_Update")