local K, C = KkthnxUI[1], KkthnxUI[2]

local table_insert = table.insert

table_insert(C.defaultThemes, function()
	if not C["Skins"].BlizzardFrames then
		return
	end

	GameMenuFrame.Header:StripTextures()
	GameMenuFrame.Header:ClearAllPoints()
	GameMenuFrame.Header:SetPoint("TOP", GameMenuFrame, 0, 7)
	GameMenuFrame:CreateBorder(nil, nil, C["General"].BorderStyle.Value ~= "KkthnxUI_Pixel" and 32 or nil, nil, C["General"].BorderStyle.Value ~= "KkthnxUI_Pixel" and -10 or nil)
	GameMenuFrame.Border:Hide()
	GameMenuFrame.Header.Text:SetFontObject(Game16Font)

	local buttons = {
		"GameMenuButtonHelp",
		"GameMenuButtonWhatsNew",
		"GameMenuButtonStore",
		"GameMenuButtonMacros",
		"GameMenuButtonAddons",
		"GameMenuButtonLogout",
		"GameMenuButtonQuit",
		"GameMenuButtonContinue",
		"GameMenuButtonSettings",
		"GameMenuButtonEditMode",
	}
	for _, buttonName in next, buttons do
		local button = _G[buttonName]
		if button then
			button:SkinButton(true)
		end
	end

	local cr, cg, cb = K.r, K.g, K.b

	hooksecurefunc(GameMenuFrame, "InitButtons", function(self)
		if not self.buttonPool then
			return
		end

		for button in self.buttonPool:EnumerateActive() do
			if not button.styled then
				button:DisableDrawLayer("BACKGROUND")
				button.bg = CreateFrame("Frame", nil, button)
				button.bg:SetFrameLevel(button:GetFrameLevel())
				button.bg:SetPoint("TOPLEFT", button, "TOPLEFT", 0, -4)
				button.bg:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 4)
				button.bg:SkinButton(true)

				button.styled = true
			end
		end
	end)
end)
