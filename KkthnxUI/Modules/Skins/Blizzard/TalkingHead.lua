local K, C = unpack(select(2, ...))

C.themes["Blizzard_TalkingHeadUI"] = function()
	if IsAddOnLoaded("Immersion") then
		return
	end

	if C["Misc"].NoTalkingHead then
		return
	end

	local TalkingHeadFrame = _G.TalkingHeadFrame

	TalkingHeadFrame.BackgroundFrame.TextBackground:SetAtlas(nil)
	TalkingHeadFrame.PortraitFrame.Portrait:SetAtlas(nil)
	TalkingHeadFrame.MainFrame.Model.PortraitBg:SetAtlas(nil)
	TalkingHeadFrame.PortraitFrame:StripTextures()

	if C["Skins"].TalkingHeadBackdrop then
		TalkingHeadFrame:StripTextures()
		TalkingHeadFrame.MainFrame:StripTextures()

		TalkingHeadFrame:CreateBackdrop()
		TalkingHeadFrame.Backdrop:ClearAllPoints()
		TalkingHeadFrame.Backdrop:SetPoint("LEFT", TalkingHeadFrame.MainFrame.Model, "RIGHT", 6, 0)
		TalkingHeadFrame.Backdrop:SetSize(400, 115)

		TalkingHeadFrame.MainFrame.Model:CreateBorder()

		local button = TalkingHeadFrame.MainFrame.CloseButton
		button:SkinCloseButton()
		button:ClearAllPoints()
		button:SetPoint("TOPRIGHT", TalkingHeadFrame.BackgroundFrame, "TOPRIGHT", -25, -18)
	else
		TalkingHeadFrame.MainFrame.Model:CreateBorder()
		TalkingHeadFrame.MainFrame.CloseButton:Kill()
	end

	TalkingHeadFrame.BackgroundFrame.TextBackground.SetAtlas = K.Noop
	TalkingHeadFrame.PortraitFrame.Portrait.SetAtlas = K.Noop
	TalkingHeadFrame.MainFrame.Model.PortraitBg.SetAtlas = K.Noop

	TalkingHeadFrame.NameFrame.Name:SetTextColor(1, 0.82, 0.02)
	TalkingHeadFrame.NameFrame.Name.SetTextColor = K.Noop
	TalkingHeadFrame.NameFrame.Name:SetShadowColor(0, 0, 0, 1)
	TalkingHeadFrame.NameFrame.Name:SetShadowOffset(2, -2)

	TalkingHeadFrame.TextFrame.Text:SetTextColor(1, 1, 1)
	TalkingHeadFrame.TextFrame.Text.SetTextColor = K.Noop
	TalkingHeadFrame.TextFrame.Text:SetShadowColor(0, 0, 0, 1)
	TalkingHeadFrame.TextFrame.Text:SetShadowOffset(2, -2)
end