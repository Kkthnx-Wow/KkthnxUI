local K, C = unpack(select(2, ...))
local Module = K:GetModule("Skins")

function Module:ReskinRareScanner()
	if not C["Skins"].RareScanner then
		return
	end

	if scanner_button then -- Need to figure a way to properly skins the filter button.
		scanner_button:StripTextures()
		scanner_button:SkinButton()
		scanner_button.CloseButton:SkinCloseButton()
	end
end