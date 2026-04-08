--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Displays the current zone and sub-zone names above the minimap.
-- - Design: Hooks minimap events and registers for zone transitions to update text and color.
-- - Events: PLAYER_ENTERING_WORLD, ZONE_CHANGED, ZONE_CHANGED_INDOORS, ZONE_CHANGED_NEW_AREA
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("DataText")

-- PERF: Localize globals and API functions to reduce lookup overhead.
local _G = _G
local C_PvP_GetZonePVPInfo = _G.C_PvP.GetZonePVPInfo
local CreateFrame = _G.CreateFrame
local GetSubZoneText = _G.GetSubZoneText
local GetZoneText = _G.GetZoneText
local Minimap = _G.Minimap
local UIParent = _G.UIParent
local pairs = pairs
local string_format = string.format
local unpack = unpack

-- ---------------------------------------------------------------------------
-- State & Constants
-- ---------------------------------------------------------------------------
local locationDataText
local pvpType
local subZoneName
local zoneName

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
	"PLAYER_ENTERING_WORLD",
	"ZONE_CHANGED",
	"ZONE_CHANGED_INDOORS",
	"ZONE_CHANGED_NEW_AREA",
}

-- ---------------------------------------------------------------------------
-- Internal Logic
-- ---------------------------------------------------------------------------
local function onEvent()
	-- REASON: Updates the zone labels based on the player's current coordinate and faction territory status.
	if C["Minimap"].LocationText == 2 or not C["Minimap"].Enable then
		return
	end

	zoneName = GetZoneText()
	subZoneName = GetSubZoneText()
	pvpType = C_PvP_GetZonePVPInfo()
	pvpType = pvpType or "neutral"

	local color = ZONE_INFO[pvpType] and ZONE_INFO[pvpType][2] or { 1, 1, 1 }
	local r, g, b = unpack(color)

	locationDataText.MainZoneText:SetText(zoneName)
	locationDataText.MainZoneText:SetTextColor(r, g, b)
	locationDataText.SubZoneText:SetText(subZoneName)
	locationDataText.SubZoneText:SetTextColor(r, g, b)
end

-- ---------------------------------------------------------------------------
-- Initialization
-- ---------------------------------------------------------------------------
function Module:CreateLocationDataText()
	-- REASON: Main entry point for the location text; manages frames above the Minimap.
	if not C["DataText"].Location or not Minimap then
		return
	end

	-- REASON: Hover logic to show/hide location text if the user has chosen the "Show on Mouseover" setting.
	Minimap:HookScript("OnEnter", function()
		if C["Minimap"].LocationText == 3 and C["Minimap"].Enable then
			locationDataText:Show()
		end
	end)

	Minimap:HookScript("OnLeave", function()
		if C["Minimap"].LocationText == 3 and C["Minimap"].Enable then
			locationDataText:Hide()
		end
	end)

	locationDataText = CreateFrame("Frame", nil, UIParent)
	locationDataText:SetPoint("TOP", Minimap, "TOP", 0, -4)
	locationDataText:SetSize(Minimap:GetWidth(), 13)
	locationDataText:SetFrameLevel(Minimap:GetFrameLevel() + 2)

	-- REASON: Initial visibility state based on whether persistent display is enabled.
	if C["Minimap"].LocationText ~= 1 or not C["Minimap"].Enable then
		locationDataText:Hide()
	end

	locationDataText.MainZoneText = K.CreateFontString(locationDataText, 12)
	locationDataText.MainZoneText:SetAllPoints(locationDataText)
	locationDataText.MainZoneText:SetWordWrap(true)
	locationDataText.MainZoneText:SetNonSpaceWrap(true)
	locationDataText.MainZoneText:SetMaxLines(2)

	locationDataText.SubZoneText = K.CreateFontString(locationDataText, 11)
	locationDataText.SubZoneText:ClearAllPoints()
	locationDataText.SubZoneText:SetPoint("TOP", locationDataText.MainZoneText, "BOTTOM", 0, -2)
	locationDataText.SubZoneText:SetWordWrap(true)
	locationDataText.SubZoneText:SetNonSpaceWrap(true)
	locationDataText.SubZoneText:SetMaxLines(2)

	for _, event in pairs(EVENT_LIST) do
		locationDataText:RegisterEvent(event)
	end

	locationDataText:SetScript("OnEvent", onEvent)
end
