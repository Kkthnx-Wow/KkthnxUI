local K, C, L = unpack(select(2, ...))
local Module = K:GetModule("Infobar")

local string_format = _G.string.format

local C_Map_ClearUserWaypoint = _G.C_Map.ClearUserWaypoint
local C_Map_GetBestMapForUnit = _G.C_Map.GetBestMapForUnit
local C_Map_GetUserWaypointHyperlink = _G.C_Map.GetUserWaypointHyperlink
local C_Map_SetUserWaypoint = _G.C_Map.SetUserWaypoint
local ChatFrame_OpenChat = _G.ChatFrame_OpenChat
local ERR_NOT_IN_COMBAT = _G.ERR_NOT_IN_COMBAT
local GetZoneText = _G.GetZoneText
local InCombatLockdown = _G.InCombatLockdown
local IsControlKeyDown = _G.IsControlKeyDown
local IsModifierKeyDown = _G.IsModifierKeyDown
local SELECTED_DOCK_FRAME = _G.SELECTED_DOCK_FRAME
local UIErrorsFrame = _G.UIErrorsFrame
local UnitExists = _G.UnitExists
local UnitIsPlayer = _G.UnitIsPlayer
local UnitName = _G.UnitName
local WorldMapFrame = _G.WorldMapFrame

local coordX, coordY = 0, 0

local function formatCoords()
	return string_format("%.1f, %.1f", coordX * 100, coordY * 100)
end

local function OnUpdate(self, elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed
	if self.elapsed > .1 then
		local x, y = K.GetPlayerMapPos(C_Map_GetBestMapForUnit("player"))
		if x then
            coordX, coordY = x, y
            Module.CoordsDataTextFrame.Text:SetText(string_format("%s", formatCoords()), 0, 0.6, 1)
		else
            coordX, coordY = 0, 0
            Module.CoordsDataTextFrame.Text:SetText(string_format("%s", formatCoords()), 0, 0.6, 1)
			self:SetScript("OnUpdate", nil)
		end

		self.elapsed = 0
	end
end

-- local function OnEvent()
-- 	if coordX and coordY then
-- 		Module.CoordsDataTextFrame.Text:SetText(string_format("%s", formatCoords()), 0, 0.6, 1)
-- 	else
-- 		Module.CoordsDataTextFrame.Text:SetText(string_format("%s", formatCoords()), 0, 0.6, 1)
-- 	end
-- end

local function OnEnter()
	GameTooltip:SetOwner(Module.CoordsDataTextFrame, "ANCHOR_NONE")
	GameTooltip:SetPoint(K.GetAnchors(Module.CoordsDataTextFrame))
	GameTooltip:ClearLines()

	GameTooltip:AddLine("If you target an NPC you are at and right click, you can also add that npc with your location you are sending to chat.", nil, nil, nil, true)
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine("CTRL +"..Module.RightButton.."Send Basic Position Info", 1, 1, 1)
	GameTooltip:AddLine(Module.RightButton.."Send Detailed Position Info", 1, 1, 1)
	GameTooltip:AddLine(Module.LeftButton.."Toggle WorldMap", 1, 1, 1)
	GameTooltip:Show()
end

local function OnLeave()
	GameTooltip:Hide()
end

local function OnMouseUp(_, btn)
	local hasUnit = UnitExists("target") and not UnitIsPlayer("target")
	local unitName = hasUnit and UnitName("target") or ""
    local unitPlayer = "player"
    local unitZone = GetZoneText() or UNKNOWN

	if btn == "LeftButton" then
		if InCombatLockdown() then UIErrorsFrame:AddMessage(K.InfoColor..ERR_NOT_IN_COMBAT)
			return
		end
		ToggleFrame(WorldMapFrame)
	elseif not IsModifierKeyDown() and btn == "RightButton" then
		C_Map_SetUserWaypoint(UiMapPoint.CreateFromCoordinates(C_Map_GetBestMapForUnit(unitPlayer), coordX, coordY))
		ChatFrame_OpenChat(string_format("%s: %s (%s) %s %s", "My Position", unitZone, formatCoords(), C_Map_GetUserWaypointHyperlink(), unitName), SELECTED_DOCK_FRAME)
		C_Map_ClearUserWaypoint()
	elseif IsControlKeyDown() and btn == "RightButton" then
		C_Map_SetUserWaypoint(UiMapPoint.CreateFromCoordinates(C_Map_GetBestMapForUnit(unitPlayer), coordX, coordY))
		ChatFrame_OpenChat(string_format("%s %s", C_Map_GetUserWaypointHyperlink(), unitName), SELECTED_DOCK_FRAME)
		C_Map_ClearUserWaypoint()
	end
end

function Module:CreateCoordsDataText()
	if not C["DataText"].Coords then
		return
	end

	Module.CoordsDataTextFrame = CreateFrame("Button", nil, UIParent)
	Module.CoordsDataTextFrame:SetPoint("TOP", UIParent, "TOP", 0, -40)
	Module.CoordsDataTextFrame:SetSize(32, 32)

	Module.CoordsDataTextFrame.Texture = Module.CoordsDataTextFrame:CreateTexture(nil, "BACKGROUND")
	Module.CoordsDataTextFrame.Texture:SetPoint("LEFT", Module.CoordsDataTextFrame, "LEFT", 0, 0)
	Module.CoordsDataTextFrame.Texture:SetTexture("Interface\\HELPFRAME\\ReportLagIcon-Movement")
	Module.CoordsDataTextFrame.Texture:SetSize(32, 32)

	Module.CoordsDataTextFrame.Text = Module.CoordsDataTextFrame:CreateFontString(nil, "ARTWORK")
	Module.CoordsDataTextFrame.Text:SetFontObject(K.GetFont(C["UIFonts"].DataTextFonts))
	Module.CoordsDataTextFrame.Text:SetPoint("CENTER", Module.CoordsDataTextFrame.Texture, "CENTER", 0, -6)

	Module.CoordsDataTextFrame:RegisterEvent("ZONE_CHANGED", OnUpdate)
	Module.CoordsDataTextFrame:RegisterEvent("ZONE_CHANGED_INDOORS", OnUpdate)
	Module.CoordsDataTextFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA", OnUpdate)
	Module.CoordsDataTextFrame:RegisterEvent("LOADING_SCREEN_DISABLED", OnUpdate)

	Module.CoordsDataTextFrame:SetScript("OnEnter", OnEnter)
	Module.CoordsDataTextFrame:SetScript("OnLeave", OnLeave)
	Module.CoordsDataTextFrame:SetScript("OnMouseUp", OnMouseUp)
	Module.CoordsDataTextFrame:SetScript("OnUpdate", OnUpdate)

	K.Mover(Module.CoordsDataTextFrame, "CoordsDataText", "CoordsDataText", {"TOP", UIParent, "TOP", 0, -40})
end