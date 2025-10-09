local K, C = KkthnxUI[1], KkthnxUI[2]

local STATICPOPUP_NUMDIALOGS = STATICPOPUP_NUMDIALOGS or 4

tinsert(C.defaultThemes, function()
	if not C.Skins.BlizzardFrames then
		return
	end

	for i = 1, 4 do
		local frame = _G["StaticPopup" .. i]
		local itemFrame = frame.ItemFrame
		local bu = frame.ItemFrame.Item
		local icon = _G["StaticPopup" .. i .. "IconTexture"]
		local close = _G["StaticPopup" .. i .. "CloseButton"]

		local gold = _G["StaticPopup" .. i .. "MoneyInputFrameGold"]
		local silver = _G["StaticPopup" .. i .. "MoneyInputFrameSilver"]
		local copper = _G["StaticPopup" .. i .. "MoneyInputFrameCopper"]

		if itemFrame.NameFrame then
			itemFrame.NameFrame:Hide()
		end

		if bu then
			bu:SetNormalTexture(0)
			bu:SetHighlightTexture(0)
			bu:SetPushedTexture(0)

			-- bu.bg = CreateFrame("Frame", nil, bu)
			-- bu.bg:SetAllPoints(icon)
			-- bu.bg:CreateBorder()

			-- icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])

			-- local bg = CreateFrame("Frame", nil, bu)
			-- bg:SetPoint("TOPLEFT", bu.bg, "TOPRIGHT", 2, 0)
			-- bg:SetPoint("BOTTOMRIGHT", bu.bg, 115, 0)
			-- frame:CreateBorder()
		end

		silver:SetPoint("LEFT", gold, "RIGHT", 1, 0)
		copper:SetPoint("LEFT", silver, "RIGHT", 1, 0)

		frame:StripTextures()
		for j = 1, 4 do
			_G["StaticPopup" .. i .. "Button" .. j]:SkinButton()
		end
		frame:CreateBorder()
		close:SkinCloseButton()

		frame.EditBox:SkinEditBox()
		frame.EditBox.NineSlice:SetAlpha(0)

		gold:SkinEditBox()
		silver:SkinEditBox()
		copper:SkinEditBox()
	end

	hooksecurefunc("StaticPopup_Show", function(which, _, _, data)
		local info = StaticPopupDialogs[which]

		if not info then
			return
		end

		local dialog = nil
		dialog = StaticPopup_FindVisible(which, data)

		if not dialog then
			local index = 1
			if info.preferredIndex then
				index = info.preferredIndex
			end
			for i = index, STATICPOPUP_NUMDIALOGS do
				local frame = _G["StaticPopup" .. i]
				if not frame:IsShown() then
					dialog = frame
					break
				end
			end

			if not dialog and info.preferredIndex then
				for i = 1, info.preferredIndex do
					local frame = _G["StaticPopup" .. i]
					if not frame:IsShown() then
						dialog = frame
						break
					end
				end
			end
		end
	end)
end)
