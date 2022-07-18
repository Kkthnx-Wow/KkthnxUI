local K, C = unpack(KkthnxUI)
local Module = K:GetModule("Skins")

function Module:ReskinRareScanner()
	if not IsAddOnLoaded("RareScanner") then
		return
	end

	if not C["Skins"].RareScanner then
		return
	end

	scanner_button:StripTextures()
	scanner_button:CreateBorder()
	scanner_button.CloseButton:SkinCloseButton()
	scanner_button.CloseButton:ClearAllPoints()
	scanner_button.CloseButton:SetPoint("TOPRIGHT")
	scanner_button.FilterDisabledButton:SkinButton()
	scanner_button.FilterDisabledButton:SetNormalTexture([[Interface\WorldMap\Dash_64Grey]])
	scanner_button.FilterDisabledButton:ClearAllPoints()
	scanner_button.FilterDisabledButton:SetPoint("TOPLEFT", 5, -5)
	scanner_button.FilterEnabledButton:SkinButton()
	scanner_button.FilterEnabledTexture:SetTexture([[Interface\WorldMap\Skull_64]])
	scanner_button.FilterEnabledButton:ClearAllPoints()
	scanner_button.FilterEnabledButton:SetPoint("TOPLEFT", 5, -5)
end
