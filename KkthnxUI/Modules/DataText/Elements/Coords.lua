local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("DataText")

local string_format = string.format

local COMBAT_ZONE = COMBAT_ZONE
local CONTESTED_TERRITORY = CONTESTED_TERRITORY
local C_Map_GetBestMapForUnit = C_Map.GetBestMapForUnit
local FACTION_CONTROLLED_TERRITORY = FACTION_CONTROLLED_TERRITORY
local FACTION_STANDING_LABEL4 = FACTION_STANDING_LABEL4
local FREE_FOR_ALL_TERRITORY = FREE_FOR_ALL_TERRITORY
local GameTooltip = GameTooltip
local GetSubZoneText = GetSubZoneText
local GetZonePVPInfo = GetZonePVPInfo
local GetZoneText = GetZoneText
local IsInInstance = IsInInstance
local SANCTUARY_TERRITORY = SANCTUARY_TERRITORY
local UnitExists = UnitExists
local UnitIsPlayer = UnitIsPlayer
local UnitName = UnitName
local ZONE = ZONE

local CoordsDataTextFrame
local coordX = 0
local coordY = 0
local faction
local pvpType
local subzone
local zone

local zoneInfo = {
	arena = { FREE_FOR_ALL_TERRITORY, { 0.84, 0.03, 0.03 } },
	combat = { COMBAT_ZONE, { 0.84, 0.03, 0.03 } },
	contested = { CONTESTED_TERRITORY, { 0.9, 0.85, 0.05 } },
	friendly = { FACTION_CONTROLLED_TERRITORY, { 0.05, 0.85, 0.03 } },
	hostile = { FACTION_CONTROLLED_TERRITORY, { 0.84, 0.03, 0.03 } },
	neutral = { string_format(FACTION_CONTROLLED_TERRITORY, FACTION_STANDING_LABEL4), { 0.9, 0.85, 0.05 } },
	sanctuary = { SANCTUARY_TERRITORY, { 0.035, 0.58, 0.84 } },
}

local function formatCoords()
	return string_format("%.1f, %.1f", coordX * 100, coordY * 100)
end

local function OnUpdate(self, elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed
	if self.elapsed > 0.1 then
		local x, y = K.GetPlayerMapPos(C_Map_GetBestMapForUnit("player"))
		if x then
			coordX, coordY = x, y
			CoordsDataTextFrame.Text:SetText(formatCoords())
			CoordsDataTextFrame:SetScript("OnUpdate", OnUpdate)
			CoordsDataTextFrame:Show()
		else
			coordX, coordY = 0, 0
			CoordsDataTextFrame.Text:SetText(formatCoords())
			CoordsDataTextFrame:SetScript("OnUpdate", nil)
			CoordsDataTextFrame:Hide()
		end

		self.elapsed = 0
	end
end

local eventList = {
	"ZONE_CHANGED",
	"ZONE_CHANGED_INDOORS",
	"ZONE_CHANGED_NEW_AREA",
	"PLAYER_ENTERING_WORLD",
}

local function OnEvent()
	subzone = GetSubZoneText()
	zone = GetZoneText()
	pvpType, _, faction = GetZonePVPInfo()
	pvpType = pvpType or "neutral"
end

local function OnEnter()
	GameTooltip:SetOwner(CoordsDataTextFrame, "ANCHOR_BOTTOM", 0, -15)
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
	GameTooltip:AddLine(K.LeftButton .. L["WorldMap"], 0.6, 0.8, 1)
	GameTooltip:AddLine(K.RightButton .. "Send My Pos", 0.6, 0.8, 1)
	GameTooltip:Show()
end

local function OnLeave()
	GameTooltip:Hide()
end

local function OnMouseUp(_, btn)
	if btn == "LeftButton" then
		ToggleWorldMap()
	elseif btn == "RightButton" then
		local hasUnit = UnitExists("target") and not UnitIsPlayer("target")
		local unitName = nil
		if hasUnit then
			unitName = UnitName("target")
		end

		ChatFrame_OpenChat(string_format("%s: %s %s (%s) %s", "My Position", zone, subzone or "", formatCoords(), unitName or ""), SELECTED_DOCK_FRAME)
	end
end

function Module:CreateCoordsDataText()
	if not C["DataText"].Coords then
		return
	end

	CoordsDataTextFrame = CoordsDataTextFrame or CreateFrame("Button", nil, UIParent)
	CoordsDataTextFrame:SetPoint("TOP", UIParent, "TOP", 0, -40)
	CoordsDataTextFrame:SetSize(24, 24)

	CoordsDataTextFrame.Texture = CoordsDataTextFrame:CreateTexture(nil, "BACKGROUND")
	CoordsDataTextFrame.Texture:SetPoint("CENTER", CoordsDataTextFrame, "CENTER", 0, 0)
	CoordsDataTextFrame.Texture:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\DataText\\coords.blp")
	CoordsDataTextFrame.Texture:SetSize(24, 24)
	CoordsDataTextFrame.Texture:SetVertexColor(unpack(C["DataText"].IconColor))
	CoordsDataTextFrame.Texture:SetAlpha(0.8)

	CoordsDataTextFrame.Text = CoordsDataTextFrame:CreateFontString(nil, "ARTWORK")
	CoordsDataTextFrame.Text:SetFontObject(K.UIFont)
	CoordsDataTextFrame.Text:SetPoint("CENTER", CoordsDataTextFrame.Texture, "CENTER", 0, -14)

	for _, event in pairs(eventList) do
		CoordsDataTextFrame:RegisterEvent(event)
	end

	CoordsDataTextFrame:SetScript("OnEvent", OnEvent)
	CoordsDataTextFrame:SetScript("OnMouseUp", OnMouseUp)
	CoordsDataTextFrame:SetScript("OnUpdate", OnUpdate)
	CoordsDataTextFrame:SetScript("OnLeave", OnLeave)
	CoordsDataTextFrame:SetScript("OnEnter", OnEnter)

	K.Mover(CoordsDataTextFrame, "CoordsDataText", "CoordsDataText", { "TOP", UIParent, "TOP", 0, -40 })
end
