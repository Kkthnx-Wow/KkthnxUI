local K, C, L, _ = select(2, ...):unpack()
if IsAddOnLoaded("Carbonite") then return end

local MinimapZone = CreateFrame("Frame", "MinimapZone", Minimap)
MinimapZone:SetSize(0, 20)
MinimapZone:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 2, 2)
MinimapZone:SetFrameLevel(Minimap:GetFrameLevel() + 3)
MinimapZone:SetFrameStrata(Minimap:GetFrameStrata())
MinimapZone:SetPoint("TOPRIGHT", Minimap, -2, 2)
MinimapZone:SetAlpha(0)

local MinimapZone_Text = MinimapZone:CreateFontString("MinimapZoneText", "Overlay")
MinimapZone_Text:SetFont(C.Media.Font, C.Media.Font_Size, C.Media.Font_Style)
MinimapZone_Text:SetPoint("TOP", 0, -1)
MinimapZone_Text:SetPoint("BOTTOM")
MinimapZone_Text:SetHeight(12)
MinimapZone_Text:SetWidth(MinimapZone:GetWidth() -6)
MinimapZone_Text:SetAlpha(0)

Minimap:SetScript("OnEnter",function()
	MinimapZone:SetAlpha(1)
	MinimapZone_Text:SetAlpha(1)
end)

Minimap:SetScript("OnLeave",function()
	MinimapZone:SetAlpha(0)
	MinimapZone_Text:SetAlpha(0)
end)

local Zone_Update = function()
	local PvP = GetZonePVPInfo()
	MinimapZone_Text:SetText(GetMinimapZoneText())
	if PvP == "friendly" then
		MinimapZone_Text:SetTextColor(0.1, 1.0, 0.1)
	elseif PvP == "sanctuary" then
		MinimapZone_Text:SetTextColor(0.41, 0.8, 0.94)
	elseif PvP == "arena" or PvP == "hostile" then
		MinimapZone_Text:SetTextColor(1.0, 0.1, 0.1)
	elseif PvP == "contested" then
		MinimapZone_Text:SetTextColor(1.0, 0.7, 0.0)
	else
		MinimapZone_Text:SetTextColor(1.0, 1.0, 1.0)
	end
end

MinimapZone:RegisterEvent("PLAYER_ENTERING_WORLD")
MinimapZone:RegisterEvent("ZONE_CHANGED_NEW_AREA")
MinimapZone:RegisterEvent("ZONE_CHANGED")
MinimapZone:RegisterEvent("ZONE_CHANGED_INDOORS")
MinimapZone:SetScript("OnEvent", Zone_Update)