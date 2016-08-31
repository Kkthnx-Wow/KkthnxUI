local K, C, L, _ = select(2, ...):unpack()

local OHSkin = CreateFrame("Frame")
OHSkin:RegisterEvent("ADDON_LOADED")
OHSkin:SetScript("OnEvent", function(self, event, addon)
	if (addon ~= "Blizzard_OrderHallUI") then
		return
	end

	OrderHallCommandBar:StripTextures()
	OrderHallCommandBar:SetTemplate("Transparent")
	OrderHallCommandBar:SetBackdropBorderColor(K.Color.r, K.Color.g, K.Color.b)
	OrderHallCommandBar:ClearAllPoints()
	OrderHallCommandBar:SetPoint("TOP", UIParent, 0, 0)
	OrderHallCommandBar:SetWidth(480)
	OrderHallCommandBar.ClassIcon:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles")
	OrderHallCommandBar.ClassIcon:SetSize(46, 20)
	OrderHallCommandBar.CurrencyIcon:SetAtlas("legionmission-icon-currency", false)
	OrderHallCommandBar.AreaName:ClearAllPoints()
	OrderHallCommandBar.AreaName:SetPoint("LEFT", OrderHallCommandBar.CurrencyIcon, "RIGHT", 10, 0)
	OrderHallCommandBar.WorldMapButton:Hide() -- Why blizzard? So pointless..

	self:UnregisterEvent("ADDON_LOADED")
end)