local K, C = unpack(KkthnxUI)
local Module = K:GetModule("Infobar")

local _G = _G
local select = _G.select
local string_format = _G.string.format
local unpack = _G.unpack

local COMBAT_ZONE = _G.COMBAT_ZONE
local CONTESTED_TERRITORY = _G.CONTESTED_TERRITORY
local FACTION_CONTROLLED_TERRITORY = _G.FACTION_CONTROLLED_TERRITORY
local FACTION_STANDING_LABEL4 = _G.FACTION_STANDING_LABEL4
local FREE_FOR_ALL_TERRITORY = _G.FREE_FOR_ALL_TERRITORY
local GetSubZoneText = _G.GetSubZoneText
local GetZonePVPInfo = _G.GetZonePVPInfo
local GetZoneText = _G.GetZoneText
local SANCTUARY_TERRITORY = _G.SANCTUARY_TERRITORY

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
	"ZONE_CHANGED",
	"ZONE_CHANGED_INDOORS",
	"ZONE_CHANGED_NEW_AREA",
	"PLAYER_ENTERING_WORLD",
}

local function OnEvent()
	if C["Minimap"].LocationText.Value == "HIDE" or not C["Minimap"].Enable then
		return
	end

	zone = GetZoneText()
	subZone = GetSubZoneText()
	pvpType = GetZonePVPInfo()
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

	LocationDataText = LocationDataText or CreateFrame("Frame", "KKUI_LocationDataText", UIParent)
	LocationDataText:SetPoint("TOP", Minimap, "TOP", 0, -4)
	LocationDataText:SetSize(Minimap:GetWidth(), 13)
	LocationDataText:SetFrameLevel(Minimap:GetFrameLevel() + 2)
	if C["Minimap"].LocationText.Value ~= "SHOW" or not C["Minimap"].Enable then
		LocationDataText:Hide()
	end

	LocationDataText.MainZoneText = LocationDataText:CreateFontString("OVERLAY")
	LocationDataText.MainZoneText:SetFontObject(K.GetFont(C["UIFonts"].DataTextFonts))
	LocationDataText.MainZoneText:SetFont(select(1, LocationDataText.MainZoneText:GetFont()), 13, select(3, LocationDataText.MainZoneText:GetFont()))
	LocationDataText.MainZoneText:SetAllPoints(LocationDataText)
	LocationDataText.MainZoneText:SetWordWrap(true)
	LocationDataText.MainZoneText:SetNonSpaceWrap(true)
	LocationDataText.MainZoneText:SetMaxLines(2)

	LocationDataText.SubZoneText = LocationDataText:CreateFontString("OVERLAY")
	LocationDataText.SubZoneText:SetFontObject(K.GetFont(C["UIFonts"].DataTextFonts))
	LocationDataText.SubZoneText:SetFont(select(1, LocationDataText.SubZoneText:GetFont()), 11, select(3, LocationDataText.SubZoneText:GetFont()))
	LocationDataText.SubZoneText:SetPoint("TOP", LocationDataText.MainZoneText, "BOTTOM", 0, -1)
	LocationDataText.SubZoneText:SetNonSpaceWrap(true)
	LocationDataText.SubZoneText:SetMaxLines(2)

	for _, event in pairs(eventList) do
		LocationDataText:RegisterEvent(event)
	end

	LocationDataText:SetScript("OnEvent", OnEvent)
end
