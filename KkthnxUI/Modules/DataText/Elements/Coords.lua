local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("DataText")

-- Cache frequently used functions
local string_format = string.format
local string_join = string.join
local math_floor = math.floor
local math_max = math.max
local C_Map_GetBestMapForUnit = C_Map.GetBestMapForUnit
local C_Map_GetPlayerMapPosition = C_Map.GetPlayerMapPosition

local CoordsDataText
local coordX, coordY = 0, 0
local faction
local pvpType
local subzone
local zone

-- Cache mapID to avoid expensive C_Map.GetBestMapForUnit calls every frame
local currentMapID = nil

local zoneInfo = {
	arena = { FREE_FOR_ALL_TERRITORY, { 0.84, 0.03, 0.03 } },
	combat = { COMBAT_ZONE, { 0.84, 0.03, 0.03 } },
	contested = { CONTESTED_TERRITORY, { 0.9, 0.85, 0.05 } },
	friendly = { FACTION_CONTROLLED_TERRITORY, { 0.05, 0.85, 0.03 } },
	hostile = { FACTION_CONTROLLED_TERRITORY, { 0.84, 0.03, 0.03 } },
	neutral = { string_format(FACTION_CONTROLLED_TERRITORY, FACTION_STANDING_LABEL4), { 0.9, 0.85, 0.05 } },
	sanctuary = { SANCTUARY_TERRITORY, { 0.035, 0.58, 0.84 } },
}

-- Event driver to update MapID only when needed (zone changes)
local function UpdateMapID()
	currentMapID = C_Map_GetBestMapForUnit("player")
end

-- Optimized coordinate formatting using math instead of string.format
local function formatCoords()
	-- Use math.floor for rounding instead of string formatting (zero GC)
	local x = math_floor(coordX * 100 + 0.5)
	local y = math_floor(coordY * 100 + 0.5)
	return string_join(" ", x, y)
end

local function OnUpdate(self, elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed
	-- Throttle to 10 updates per second (0.1s) to reduce CPU usage
	if self.elapsed > 0.1 then
		self.elapsed = 0

		-- Update mapID only if not cached
		if not currentMapID then
			UpdateMapID()
			return
		end

		-- Use cached mapID instead of calling GetBestMapForUnit every frame
		local position = C_Map_GetPlayerMapPosition(currentMapID, "player")
		if position then
			coordX, coordY = position.x, position.y
			CoordsDataText.Text:SetText(formatCoords())
			CoordsDataText:Show()

			-- Resize container and mover to cover icon + text
			local textW = CoordsDataText.Text:GetStringWidth() or 0
			local textH = CoordsDataText.Text:GetLineHeight() or 12
			local iconW = (CoordsDataText.Texture and CoordsDataText.Texture:GetWidth()) or 0
			local iconH = (CoordsDataText.Texture and CoordsDataText.Texture:GetHeight()) or 0
			local totalW = math_max(textW, iconW)
			local totalH = iconH + 2 + textH
			CoordsDataText:SetSize(math_max(totalW, 56), totalH)
			if CoordsDataText.mover then
				CoordsDataText.mover:SetWidth(math_max(totalW, 56))
				CoordsDataText.mover:SetHeight(totalH)
			end
		else
			-- If position is nil, try to refresh mapID
			currentMapID = nil
			coordX, coordY = 0, 0
			CoordsDataText:Hide()
		end
	end
end

local eventList = {
	"ZONE_CHANGED",
	"ZONE_CHANGED_INDOORS",
	"ZONE_CHANGED_NEW_AREA",
	"PLAYER_ENTERING_WORLD",
}

local function OnEvent(_, event, ...)
	if tContains(eventList, event) then
		-- Update cached mapID when zone changes
		UpdateMapID()
		subzone = GetSubZoneText()
		zone = GetZoneText()
		pvpType, _, faction = C_PvP.GetZonePVPInfo()
		pvpType = pvpType or "neutral"
	end
end

local function OnEnter()
	GameTooltip:SetOwner(CoordsDataText, "ANCHOR_BOTTOM", 0, -15)
	GameTooltip:ClearLines()

	if pvpType and not IsInInstance() then
		local r, g, b = unpack(zoneInfo[pvpType][2])
		if zone and subzone and subzone ~= "" then
			GameTooltip:AddLine(K.GreyColor .. ZONE .. ":|r " .. zone, r, g, b)
			GameTooltip:AddLine(K.GreyColor .. "SubZone" .. ":|r " .. subzone, r, g, b)
		else
			GameTooltip:AddLine(K.GreyColor .. ZONE .. ":|r " .. zone, r, g, b)
		end
		GameTooltip:AddLine(string_format(K.GreyColor .. "PvPType" .. ":|r " .. zoneInfo[pvpType][1], faction or ""), r, g, b)
	end

	GameTooltip:AddLine(" ")
	GameTooltip:AddLine(K.LeftButton .. "Toggle WorldMap", 0.6, 0.8, 1)
	GameTooltip:AddLine(K.RightButton .. "Send My Position", 0.6, 0.8, 1)
	GameTooltip:Show()
end

local function OnLeave()
	GameTooltip:Hide()
end

local zoneString = "|cffffff00|Hworldmap:%d+:%d+:%d+|h[|A:Waypoint-MapPin-ChatIcon:13:13:0:0|a %s: %s (%s) %s]|h|r"
local lastRightClick = 0
local function OnMouseUp(_, btn)
	if btn == "LeftButton" then
		ToggleWorldMap()
	elseif btn == "RightButton" then
		if GetTime() - lastRightClick > 5 then
			local mapID = C_Map.GetBestMapForUnit("player")
			local hasUnit = UnitExists("target") and not UnitIsPlayer("target")
			local unitName = hasUnit and UnitName("target") or ""
			print(format(zoneString, mapID, coordX * 10000, coordY * 10000, "My Position", zone, formatCoords(), unitName))
			lastRightClick = GetTime()
		else
			print("You can send your position again in " .. math.ceil(5 - (GetTime() - lastRightClick)) .. " seconds.")
		end
	end
end

function Module:CreateCoordsDataText()
	if not C["DataText"].Coords then
		return
	end

	CoordsDataText = CreateFrame("Frame", nil, UIParent)
	CoordsDataText:SetHitRectInsets(0, 0, -10, -10)
	CoordsDataText:SetPoint("TOP", UIParent, "TOP", 0, -90)

	-- Icon on top
	CoordsDataText.Texture = CoordsDataText:CreateTexture(nil, "ARTWORK")
	CoordsDataText.Texture:SetPoint("TOP", CoordsDataText, "TOP", 0, 0)
	CoordsDataText.Texture:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\DataText\\coords.blp")
	CoordsDataText.Texture:SetSize(24, 24)
	CoordsDataText.Texture:SetVertexColor(unpack(C["DataText"].IconColor))

	-- Text under icon
	CoordsDataText.Text = K.CreateFontString(CoordsDataText, 12)
	CoordsDataText.Text:ClearAllPoints()
	CoordsDataText.Text:SetPoint("TOP", CoordsDataText.Texture, "BOTTOM", 0, -2)

	local function _OnEvent(...)
		OnEvent(...)
	end

	for _, event in pairs(eventList) do
		CoordsDataText:RegisterEvent(event)
	end

	CoordsDataText:SetScript("OnEvent", _OnEvent)
	CoordsDataText:SetScript("OnEnter", OnEnter)
	CoordsDataText:SetScript("OnLeave", OnLeave)
	CoordsDataText:SetScript("OnMouseUp", OnMouseUp)
	CoordsDataText:SetScript("OnUpdate", OnUpdate)

	-- Make the whole block (icon + text) movable
	CoordsDataText.mover = K.Mover(CoordsDataText, "CoordsDT", "CoordsDT", { "TOP", UIParent, "TOP", 0, -90 }, 56, 24)
end
