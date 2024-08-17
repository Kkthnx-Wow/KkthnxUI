local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("DataText")

local select = select
local string_format = string.format
local unpack = unpack

local COMBAT_ZONE = COMBAT_ZONE
local CONTESTED_TERRITORY = CONTESTED_TERRITORY
local FACTION_CONTROLLED_TERRITORY = FACTION_CONTROLLED_TERRITORY
local FACTION_STANDING_LABEL4 = FACTION_STANDING_LABEL4
local FREE_FOR_ALL_TERRITORY = FREE_FOR_ALL_TERRITORY
local GetSubZoneText = GetSubZoneText
local GetZonePVPInfo = GetZonePVPInfo
local GetZoneText = GetZoneText
local SANCTUARY_TERRITORY = SANCTUARY_TERRITORY

local LocationDataText
local pvpType
local subZone
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

local eventList = {
	"PLAYER_ENTERING_WORLD",
	"ZONE_CHANGED",
	"ZONE_CHANGED_INDOORS",
	"ZONE_CHANGED_NEW_AREA",
}

local function OnEvent()
	if C["Minimap"].LocationText.Value == "HIDE" or not C["Minimap"].Enable then
		return
	end

	zone = GetZoneText()
	subZone = GetSubZoneText()
	pvpType = C_PvP.GetZonePVPInfo()
	pvpType = pvpType or "neutral"

	local r, g, b = unpack(zoneInfo[pvpType][2])
	LocationDataText.MainZoneText:SetText(zone)
	LocationDataText.MainZoneText:SetTextColor(r, g, b)
	LocationDataText.SubZoneText:SetText(subZone)
	LocationDataText.SubZoneText:SetTextColor(r, g, b)
end

function Module:CreateLocationDataText()
	if not C["DataText"].Location then
		return
	end

	if not Minimap then
		return
	end

	Minimap:HookScript("OnEnter", function()
		if C["Minimap"].LocationText.Value ~= "MOUSEOVER" or not C["Minimap"].Enable then
			return
		end

		LocationDataText:Show()
	end)

	Minimap:HookScript("OnLeave", function()
		if C["Minimap"].LocationText.Value ~= "MOUSEOVER" or not C["Minimap"].Enable then
			return
		end

		LocationDataText:Hide()
	end)

	LocationDataText = CreateFrame("Frame", nil, UIParent)
	LocationDataText:SetPoint("TOP", Minimap, "TOP", 0, -4)
	LocationDataText:SetSize(Minimap:GetWidth(), 13)
	LocationDataText:SetFrameLevel(Minimap:GetFrameLevel() + 2)
	if C["Minimap"].LocationText.Value ~= "SHOW" or not C["Minimap"].Enable then
		LocationDataText:Hide()
	end

	LocationDataText.MainZoneText = K.CreateFontString(LocationDataText, 12)
	LocationDataText.MainZoneText:SetAllPoints(LocationDataText)
	LocationDataText.MainZoneText:SetWordWrap(true)
	LocationDataText.MainZoneText:SetNonSpaceWrap(true)
	LocationDataText.MainZoneText:SetMaxLines(2)

	LocationDataText.SubZoneText = K.CreateFontString(LocationDataText, 11)
	LocationDataText.SubZoneText:ClearAllPoints()
	LocationDataText.SubZoneText:SetPoint("TOP", LocationDataText.MainZoneText, "BOTTOM", 0, -2)
	LocationDataText.SubZoneText:SetWordWrap(true)
	LocationDataText.SubZoneText:SetNonSpaceWrap(true)
	LocationDataText.SubZoneText:SetMaxLines(2)

	local function _OnEvent(...)
		OnEvent(...) -- ??
	end

	for _, event in pairs(eventList) do
		LocationDataText:RegisterEvent(event)
	end

	LocationDataText:SetScript("OnEvent", _OnEvent)
end
