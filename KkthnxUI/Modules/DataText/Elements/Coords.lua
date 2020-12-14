local K, C = unpack(select(2, ...))
local Module = K:GetModule("Infobar")

local _G = _G
local string_format = _G.string.format

local C_Map_GetBestMapForUnit = _G.C_Map.GetBestMapForUnit
local C_Map_GetPlayerMapPosition = _G.C_Map.GetPlayerMapPosition
local ERR_NOT_IN_COMBAT = _G.ERR_NOT_IN_COMBAT
local InCombatLockdown = _G.InCombatLockdown
local UIErrorsFrame = _G.UIErrorsFrame
local WorldMapFrame = _G.WorldMapFrame

local function UpdateCoords(self, elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed
	if self.elapsed > 0.1 then
		local UnitMap = C_Map_GetBestMapForUnit("player")
		local coordX, coordY = 0, 0
		if UnitMap then
			local GetPlayerMapPosition = C_Map_GetPlayerMapPosition(UnitMap, "player")
			if GetPlayerMapPosition then
				coordX, coordY = C_Map_GetPlayerMapPosition(UnitMap, "player"):GetXY()
			end
		end

		if coordX == 0 and coordY == 0 then
			Module.CoordsDataTextFrame.Text:Hide()
			Module.CoordsDataTextFrame.Texture:Hide()
			Module.CoordsDataTextFrame.Text:SetText(string_format("--, --", coordX * 100, coordY * 100))
		else
			Module.CoordsDataTextFrame.Text:Show()
			Module.CoordsDataTextFrame.Texture:Show()
			Module.CoordsDataTextFrame.Text:SetText(string_format("%.1f, %.1f", coordX * 100, coordY * 100))
		end

		self.elapsed = 0
	end
end

local function OnMouseUp()
	if InCombatLockdown() then
		UIErrorsFrame:AddMessage(K.InfoColor..ERR_NOT_IN_COMBAT)
		return
	end
	ToggleFrame(WorldMapFrame)
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

	Module.CoordsDataTextFrame:SetScript("OnMouseUp", OnMouseUp)
	Module.CoordsDataTextFrame:SetScript("OnUpdate", UpdateCoords)

	K.Mover(Module.CoordsDataTextFrame, "CoordsDataText", "CoordsDataText", {"TOP", UIParent, "TOP", 0, -40})
end