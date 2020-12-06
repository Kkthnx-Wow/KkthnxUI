local _, C = unpack(select(2, ...))

if IsAddOnLoaded("UnlimitedMapPinDistance") then
    return
end

-- Sourced: Unlimited Map Pin Distance (XAAM)
-- Edited: KkthnxUI

local _G = _G
local string_gsub = _G.string.gsub
local string_len = _G.string.len
local string_lower = _G.string.lower
local string_match = _G.string.match
local table_insert = _G.table.insert

local C_Map_GetBestMapForUnit = _G.C_Map.GetBestMapForUnit
local C_Map_GetMapInfo = _G.C_Map.GetMapInfo
local C_Map_SetUserWaypoint = _G.C_Map.SetUserWaypoint
local C_Navigation_GetDistance = _G.C_Navigation.GetDistance
local C_SuperTrack_SetSuperTrackedUserWaypoint = _G.C_SuperTrack.SetSuperTrackedUserWaypoint
local IsAddOnLoaded = _G.IsAddOnLoaded

do
	local trackedAlphaBase = SuperTrackedFrame.GetTargetAlphaBaseValue
    function SuperTrackedFrame:GetTargetAlphaBaseValue()
		if trackedAlphaBase(self) == 0 and C_Navigation_GetDistance() >= 1000 then
			return 0.6
		else
			return trackedAlphaBase(self)
		end
	end
end

local function FindTheZone(z, s)
	for i = 0, 2000 do
		if C_Map_GetMapInfo(i) then
			local info = C_Map_GetMapInfo(i)
			if string_lower(info.name) == z then
				if s ~= 0 then
					if info.parentMapID == s then
						return i
					end
				else
					return i
				end
			end
		end
	end
	return 0
end

_G.SlashCmdList["KKUI_UPD"] = function(msg)
	local zoneFound = 0
	msg = msg and string.lower(msg)

	local wrongseparator = "(%d)"..(tonumber("1.1") and "," or ".").."(%d)"
	local rightseparator = "%1"..(tonumber("1.1") and "." or ",").."%2"
	local tokens = {}

	msg = msg:gsub("(%d)[%.,] (%d)", "%1 %2"):gsub(wrongseparator, rightseparator)
	for token in msg:gmatch("%S+") do
		table_insert(tokens, token)
	end

	for i = 1, #tokens do
		local token = tokens[i]
		if tonumber(token) then
			zoneFound = i - 1
			break
		end
	end

	local unitCoord = {}
	local unitPlayer = "player"
	local unitBestMap = C_Map_GetBestMapForUnit(unitPlayer)

	unitCoord.z, unitCoord.x, unitCoord.y = table.concat(tokens, " ", 1, zoneFound), select(zoneFound + 1, unpack(tokens))
	if unitCoord.x and unitCoord.y then
		if unitCoord.z and string_len(unitCoord.z) > 1 then
			unitCoord.s = string_match(unitCoord.z, ":([a-z%s'`]+)")
			unitCoord.z = string_match(unitCoord.z, "([a-z%s'`]+)")
			unitCoord.z = string_gsub(unitCoord.z, "[ \t]+%f[\r\n%z]", "")

			local sub = 0
			if unitCoord.s and string_len(unitCoord.s) > 0 then
				unitCoord.s = string_gsub(unitCoord.s, "[ \t]+%f[\r\n%z]", "")
				sub = FindTheZone(unitCoord.s, 0)
			end

			local zone = FindTheZone(unitCoord.z, sub)
			if zone ~= 0 then
				unitBestMap = zone
			end
		end

		C_Map_SetUserWaypoint(UiMapPoint.CreateFromCoordinates(unitBestMap, tonumber(unitCoord.x) / 100, tonumber(unitCoord.y) / 100))
		C_SuperTrack_SetSuperTrackedUserWaypoint(true)
	end
end
_G.SLASH_KKUI_UPD1 = "/kway"
_G.SLASH_KKUI_UPD2 = "/kkway"

if not IsAddOnLoaded("SlashPin") then
	_G.SLASH_KKUI_UPD3 = "/pin"
end

if not IsAddOnLoaded("TomTom") then
	_G.SLASH_KKUI_UPD4 = "/way"
end