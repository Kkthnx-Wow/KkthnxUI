local K, C = unpack(select(2, ...))
local Module = K:GetModule("Skins")

local _G = _G

local function ReskinRareScanner()
    if not C["Skins"].RareScanner then
		return
    end

	if scanner_button then
		scanner_button:StripTextures()
		scanner_button:SkinButton()
		scanner_button.CloseButton:SkinCloseButton()
		scanner_button.FilterDisabledButton:SkinCloseButton(nil, "-")
	end
end

Module:LoadWithAddOn("RareScanner", "RareScanner", ReskinRareScanner)