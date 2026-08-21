--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/Minimap/Location.lua
	Purpose:
		The zone-name datatext across the top of the minimap, coloured by the
		zone's PvP status.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

local Module = K:GetModule("Minimap")

local _G = _G
local GetMinimapZoneText = _G.GetMinimapZoneText
local GetZonePVPInfo = _G.GetZonePVPInfo

local Minimap = _G.Minimap

local PVP_COLOR = {
	sanctuary = { 0.41, 0.8, 0.94 },
	arena = { 1, 0.1, 0.1 },
	friendly = { 0.2, 1, 0.2 },
	contested = { 1, 0.7, 0 },
	hostile = { 1, 0.1, 0.1 },
	combat = { 1, 0.1, 0.1 },
}

function Module:UpdateLocation()
	local text = self.location
	if not text then
		return
	end
	local zone = GetMinimapZoneText() or ""
	text:SetText(zone)
	local pvp = GetZonePVPInfo and GetZonePVPInfo()
	local color = pvp and PVP_COLOR[pvp] or K.Colors.gold
	text:SetTextColor(color[1], color[2], color[3])
end

function Module:CreateLocation()
	if not C.Minimap.ShowLocation then
		return
	end

	local loc = Minimap:CreateFontString(nil, "OVERLAY")
	K.SetFont(loc, 12, K.FontOutlineStyle())
	loc:SetPoint("TOP", Minimap, "TOP", 0, -4)
	loc:SetWidth(Minimap:GetWidth() - 8)
	loc:SetWordWrap(false)
	self.location = loc

	self:RegisterEvent("ZONE_CHANGED", "UpdateLocation")
	self:RegisterEvent("ZONE_CHANGED_INDOORS", "UpdateLocation")
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA", "UpdateLocation")
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "UpdateLocation")
	self:UpdateLocation()
end
