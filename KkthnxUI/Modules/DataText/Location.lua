local K, C = unpack(select(2, ...))
local Module = K:GetModule("Infobar")

local _G = _G
local unpack = _G.unpack
local string_format = _G.string.format
local select = _G.select

local C_Map_GetBestMapForUnit = _G.C_Map.GetBestMapForUnit
local ChatFrame_OpenChat = _G.ChatFrame_OpenChat
local COMBAT_ZONE = _G.COMBAT_ZONE
local CONTESTED_TERRITORY = _G.CONTESTED_TERRITORY
local FACTION_CONTROLLED_TERRITORY = _G.FACTION_CONTROLLED_TERRITORY
local FACTION_STANDING_LABEL4 = _G.FACTION_STANDING_LABEL4
local FREE_FOR_ALL_TERRITORY = _G.FREE_FOR_ALL_TERRITORY
local GetSubZoneText = _G.GetSubZoneText
local GetZonePVPInfo = _G.GetZonePVPInfo
local GetZoneText = _G.GetZoneText
local InCombatLockdown = _G.InCombatLockdown
local IsInInstance = _G.IsInInstance
local SANCTUARY_TERRITORY = _G.SANCTUARY_TERRITORY
local SELECTED_DOCK_FRAME = _G.SELECTED_DOCK_FRAME
local UnitExists = _G.UnitExists
local UnitIsPlayer = _G.UnitIsPlayer
local UnitName = _G.UnitName
local WorldMapFrame = _G.WorldMapFrame

local zoneInfo = {
	arena = {FREE_FOR_ALL_TERRITORY, {0.84, 0.03, 0.03}},
	combat = {COMBAT_ZONE, {0.84, 0.03, 0.03}},
	contested = {CONTESTED_TERRITORY, {0.9, 0.85, 0.05}},
	friendly = {FACTION_CONTROLLED_TERRITORY, {0.05, 0.85, 0.03}},
	hostile = {FACTION_CONTROLLED_TERRITORY, {0.84, 0.03, 0.03}},
	neutral = {string_format(FACTION_CONTROLLED_TERRITORY, FACTION_STANDING_LABEL4), {0.9, 0.85, 0.05}},
	sanctuary = {SANCTUARY_TERRITORY, {0.035, 0.58, 0.84}},
}


local subzone, zone, pvpType, faction
local coordX, coordY = 0, 0

local function formatCoords()
	return string_format("%.1f, %.1f", coordX * 100, coordY * 100)
end

local function UpdateCoords(self, elapsed)
	Module.elapsed = (Module.elapsed or 0) + elapsed

	if Module.elapsed > 0.1 then
		local x, y = K.GetPlayerMapPos(C_Map_GetBestMapForUnit("player"))
		if x then
			coordX, coordY = x, y
		else
			coordX, coordY = 0, 0
			Module.LocationFrame:SetScript("OnUpdate", nil)
		end

		Module:LocationOnEnter()
		Module.elapsed = 0
	end
end

function Module:LocationOnEvent(self)
	subzone = GetSubZoneText()
	zone = GetZoneText()
	pvpType, _, faction = GetZonePVPInfo()
	pvpType = pvpType or "neutral"

	local r, g, b = unpack(zoneInfo[pvpType][2])
	Module.LocationFont:SetText((subzone ~= "") and subzone or zone)
	Module.LocationFont:SetTextColor(r, g, b)
end

function Module:LocationOnEnter()
	Module.LocationFrame:SetScript("OnUpdate", UpdateCoords)

	GameTooltip:SetOwner(Module.LocationFrame, "ANCHOR_BOTTOM", 0, -15)
	GameTooltip:ClearLines()
	GameTooltip:AddLine(string_format("%s |cffffffff(%s)", zone, formatCoords()), 0, 0.6, 1)

	if pvpType and not IsInInstance() then
		local r, g, b = unpack(zoneInfo[pvpType][2])
		if subzone and subzone ~= zone then
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(subzone, r, g, b)
		end

		GameTooltip:AddLine(string_format(zoneInfo[pvpType][1], faction or ""), r, g, b)
	end

	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine("Left Click:",  K.InfoColor.."WorldMap")
	GameTooltip:AddDoubleLine("Right Click:",  K.InfoColor.."Send My Pos")

	GameTooltip:Show()
end

function Module:LocationOnLeave()
	Module.LocationFrame:SetScript("OnUpdate", nil)
	GameTooltip:Hide()
end

function Module:LocationOnMouseUp(btn)
	if btn == "LeftButton" then
		if InCombatLockdown() then
			UIErrorsFrame:AddMessage(K.InfoColor..ERR_NOT_IN_COMBAT)
			return
		end
		ToggleFrame(WorldMapFrame)
	elseif btn == "RightButton" then
		local hasUnit = UnitExists("target") and not UnitIsPlayer("target")
		local unitName = nil
		if hasUnit then
			unitName = UnitName("target")
		end

		ChatFrame_OpenChat(string_format("%s: %s (%s) %s", "My Position", zone, formatCoords(), unitName or ""), SELECTED_DOCK_FRAME)
	end
end

function Module:CreateLocationDataText()
	if not C["DataText"].Location then
		return
	end

	if not Minimap then
		return
	end

	Module.LocationFrame = CreateFrame("Frame", "KKUI_LocationDataText", UIParent)
	Module.LocationFrame:SetPoint("TOP", Minimap, "TOP", 0, -4)
	Module.LocationFrame:SetSize(Minimap:GetWidth() - 12, 14)
	Module.LocationFrame:SetFrameLevel(Minimap:GetFrameLevel() + 2)

	Module.LocationFont = Module.LocationFrame:CreateFontString("OVERLAY")
	Module.LocationFont:SetFontObject(K.GetFont(C["UIFonts"].DataTextFonts))
	Module.LocationFont:SetFont(select(1, Module.LocationFont:GetFont()), 13, select(3, Module.LocationFont:GetFont()))
	Module.LocationFont:SetAllPoints(Module.LocationFrame)

	K:RegisterEvent("ZONE_CHANGED", Module.LocationOnEvent)
	K:RegisterEvent("ZONE_CHANGED_INDOORS", Module.LocationOnEvent)
	K:RegisterEvent("ZONE_CHANGED_NEW_AREA", Module.LocationOnEvent)
	K:RegisterEvent("PLAYER_ENTERING_WORLD", Module.LocationOnEvent)

	Module.LocationFrame:SetScript("OnEvent", Module.LocationOnUpdate)
	Module.LocationFrame:SetScript("OnMouseUp", Module.LocationOnMouseUp)
	Module.LocationFrame:SetScript("OnEnter", Module.LocationOnEnter)
	Module.LocationFrame:SetScript("OnLeave", Module.LocationOnLeave)
end