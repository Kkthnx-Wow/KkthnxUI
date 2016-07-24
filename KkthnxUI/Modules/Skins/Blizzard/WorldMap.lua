local K, C, L, _ = select(2, ...):unpack()
if C.Skins.WorldMap ~= true or IsAddOnLoaded("Mapster") == true or IsAddOnLoaded("Aurora") then return end

local floor = math.floor
local select = select
local CreateFrame = CreateFrame
local GetPlayerMapPosition = GetPlayerMapPosition
local IsInInstance = IsInInstance

-- NEEDS TO BE RECODED

if not InCombatLockdown() then
	local WorldMap_Tweak = CreateFrame("Frame")
	WorldMap_Tweak:SetScript("OnEvent", OnEvent)
	WorldMap_Tweak:RegisterEvent("PLAYER_LOGIN")
	BlackoutWorld:Hide()
	WorldMapFrame:EnableKeyboard(false)
	WorldMapFrame:EnableMouse(false)
	WorldMapFrame:SetAttribute("UIPanelLayout-area", "center")
	WorldMapFrame:SetAttribute("UIPanelLayout-allowOtherPanels", true)
	UIPanelWindows["WorldMapFrame"] = {area = "center"}
	BlackoutWorld.Show = function() UIPanelWindows["WorldMapFrame"] = {area = "center"}
		WorldMapFrame:EnableKeyboard(false)
		WorldMapFrame:EnableMouse(false)
		WorldMapFrame:SetAttribute("UIPanelLayout-area", "center")
		WorldMapFrame:SetAttribute("UIPanelLayout-allowOtherPanels", true)
	end
	WorldMapFrame:HookScript("OnShow", function(self) self:SetScale(0.80) self:SetAlpha(0.90) WorldMapTooltip:SetScale(1/0.80) end)
end

local WorldMap_Coords = CreateFrame("Frame", "CoordsFrame", WorldMapFrame)
WorldMap_Coords:SetFrameLevel(90)
WorldMap_Coords:FontString("PlayerText", C.Media.Font, 12 * 1.1, C.Media.Font_Style)
WorldMap_Coords:FontString("MouseText", C.Media.Font, 12 * 1.1, C.Media.Font_Style)
WorldMap_Coords.PlayerText:SetPoint("BOTTOMLEFT", WorldMapDetailFrame, "BOTTOMLEFT", 5, 5)
WorldMap_Coords.PlayerText:SetText("Player: 0, 0")
WorldMap_Coords.MouseText:SetPoint("BOTTOMLEFT", WorldMap_Coords.PlayerText, "TOPLEFT", 0, 5)
WorldMap_Coords.MouseText:SetText("Mouse: 0, 0")
local int = 0

WorldMapFrame:HookScript("OnUpdate", function(self, elapsed)
	int = int + 1

	if int >= 3 then
		local inInstance, _ = IsInInstance()
		local x,y = GetPlayerMapPosition("player")
		x = floor(100 * x)
		y = floor(100 * y)
		if x ~= 0 and y ~= 0 then
			WorldMap_Coords.PlayerText:SetText(PLAYER..": "..x..", "..y)
		else
			WorldMap_Coords.PlayerText:SetText(" ")
		end

		local scale = WorldMapDetailFrame:GetEffectiveScale()
		local width = WorldMapDetailFrame:GetWidth()
		local height = WorldMapDetailFrame:GetHeight()
		local centerX, centerY = WorldMapDetailFrame:GetCenter()
		local x, y = GetCursorPosition()
		local adjustedX = (x / scale - (centerX - (width/2))) / width
		local adjustedY = (centerY + (height/2) - y / scale) / height

		if (adjustedX >= 0 and adjustedY >= 0 and adjustedX <= 1 and adjustedY <= 1) then
			adjustedX = floor(100 * adjustedX)
			adjustedY = floor(100 * adjustedY)
			WorldMap_Coords.MouseText:SetText(MOUSE_LABEL..": "..adjustedX..", "..adjustedY)
		else
			WorldMap_Coords.MouseText:SetText(" ")
		end

		int = 0
	end
end)