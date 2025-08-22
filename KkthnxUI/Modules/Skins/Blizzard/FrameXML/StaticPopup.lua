local K, C = KkthnxUI[1], KkthnxUI[2]

tinsert(C.defaultThemes, function()
	if not C.Skins.BlizzardFrames then
		return
	end

	local function SkinPopupButtons(popup)
		for j = 1, 4 do
			local button = _G[popup .. "Button" .. j]
			if button then
				button:SkinButton()
			end
		end
	end

	local function SkinPopupEditBoxes(popup)
		local editBox = _G[popup .. "EditBox"]
		if editBox then
			editBox:SkinEditBox()
			editBox.KKUI_Backdrop:SetPoint("TOPLEFT", -3, -6)
			editBox.KKUI_Backdrop:SetPoint("BOTTOMRIGHT", -3, 6)
		end

		for _, type in ipairs({ "Gold", "Silver", "Copper" }) do
			local box = _G[popup .. "MoneyInputFrame" .. type]
			if box then
				box:SkinEditBox()
				box.KKUI_Backdrop:SetPoint("TOPLEFT", -3, 0)
			end
		end
	end

	local function SkinPopupItemFrame(popup)
		local itemFrame = _G[popup .. "ItemFrame"]
		if itemFrame then
			_G[popup .. "ItemFrameNameFrame"]:Kill()
			itemFrame:GetNormalTexture():Kill()
			itemFrame:CreateBorder()
			itemFrame:StyleButton()
			itemFrame.IconBorder:SetAlpha(0)

			local iconTexture = itemFrame.IconTexture
			if iconTexture then
				iconTexture:SetTexCoord(0.1, 0.9, 0.1, 0.9)
				iconTexture:ClearAllPoints()
				iconTexture:SetPoint("TOPLEFT", 2, -2)
				iconTexture:SetPoint("BOTTOMRIGHT", -2, 2)
			end
		end
	end

	for i = 1, 4 do
		local popup = "StaticPopup" .. i
		local frame = _G[popup]
		frame:StripTextures()
		frame:CreateBackdrop()
		frame.KKUI_Backdrop:SetPoint("TOPLEFT", 2, -2)
		frame.KKUI_Backdrop:SetPoint("BOTTOMRIGHT", -2, 2)

		SkinPopupButtons(popup)
		SkinPopupEditBoxes(popup)
		SkinPopupItemFrame(popup)

		local closeButton = _G[popup .. "CloseButton"]
		closeButton:SetNormalTexture(0)
		closeButton.SetNormalTexture = K.Noop
		closeButton:SetPushedTexture(0)
		closeButton.SetPushedTexture = K.Noop
		closeButton:SkinCloseButton()
	end

	_G.StaticPopup1ExtraButton:SkinButton()
end)
