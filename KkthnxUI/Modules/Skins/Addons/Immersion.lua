local K = unpack(select(2, ...))
local Module = K:GetModule("Skins")

function Module:ReskinImmersion()
	if not IsAddOnLoaded("Immersion") then
		return
	end

	ImmersionFrame.TalkBox.BackgroundFrame:StripTextures()
	ImmersionFrame.TalkBox.BackgroundFrame:CreateBackdrop()
	ImmersionFrame.TalkBox.BackgroundFrame.Backdrop:SetPoint("TOPLEFT", ImmersionFrame.TalkBox.BackgroundFrame, "TOPLEFT", 12, -12)
	ImmersionFrame.TalkBox.BackgroundFrame.Backdrop:SetPoint("BOTTOMRIGHT", ImmersionFrame.TalkBox.BackgroundFrame, "BOTTOMRIGHT", -12, 12)

	ImmersionFrame.TalkBox.PortraitFrame:StripTextures()
	ImmersionFrame.TalkBox.MainFrame.CloseButton:SkinCloseButton()

	ImmersionFrame.TalkBox.Hilite:SetBackdrop({edgeFile = "Interface\\AddOns\\KkthnxUI\\Media\\Border\\Border_Glow_Overlay", edgeSize = 12})
	ImmersionFrame.TalkBox.Hilite:SetPoint("TOPLEFT", ImmersionFrame.TalkBox, 8, -8)
	ImmersionFrame.TalkBox.Hilite:SetPoint("BOTTOMRIGHT", ImmersionFrame.TalkBox, -8, 8)
	ImmersionFrame.TalkBox.Hilite:SetBackdropBorderColor(0, 0.44, .87, 1)

	ImmersionFrame.TalkBox.MainFrame.Model.ModelShadow:Kill()
	ImmersionFrame.TalkBox.MainFrame.Model.PortraitBG:Hide()
	ImmersionFrame.TalkBox.MainFrame.Model:CreateBorder()

	ImmersionFrame.TalkBox.Elements:StripTextures()
	ImmersionFrame.TalkBox.Elements:CreateBackdrop()
	ImmersionFrame.TalkBox.Elements.Backdrop:SetPoint("TOPLEFT", ImmersionFrame.TalkBox.Elements, "TOPLEFT", 12, -12)
	ImmersionFrame.TalkBox.Elements.Backdrop:SetPoint("BOTTOMRIGHT", ImmersionFrame.TalkBox.Elements, "BOTTOMRIGHT", -12, 12)

	ImmersionFrame.TalkBox.MainFrame.Overlay:Kill()

	--ImmersionFrame.TalkBox.ReputationBar:CreateBorder()
	ImmersionFrame.TalkBox.ReputationBar:ClearAllPoints()
	ImmersionFrame.TalkBox.ReputationBar:SetPoint("TOPLEFT", ImmersionFrame.TalkBox, "BOTTOMLEFT", -20, 10)
	ImmersionFrame.TalkBox.ReputationBar.icon:SetAlpha(0)

	ImmersionFrame.TalkBox.Elements.Content.RewardsFrame.ItemHighlight.Icon:Hide()
	ImmersionFrame.TalkBox.Elements.Content.RewardsFrame.ItemHighlight.Icon.Show = function() end

	ImmersionFrame.TalkBox.Elements.Content.RewardsFrame.ItemHighlight.NameTag:Hide()
	ImmersionFrame.TalkBox.Elements.Content.RewardsFrame.ItemHighlight.NameTag.Show = function() end

	ImmersionFrame.TalkBox.Elements.Content.RewardsFrame.ItemHighlight.TextSheen:Hide()
	ImmersionFrame.TalkBox.Elements.Content.RewardsFrame.ItemHighlight.TextSheen.Show = function() end

	local function SkinReward(Button)
		if Button.Icon then
			Button:CreateBackdrop()

			if Button.NameFrame then
				Button.NameFrame:Hide()
			end

			if Button.Border then
				Button.Border:Hide()
			end

			if Button.Mask then
				Button.Mask:Hide()
			end

			Button.Backdrop:SetPoint("TOPLEFT", Button.Icon, "TOPRIGHT", 6, 0)
			Button.Backdrop:SetPoint("BOTTOMLEFT", Button.Icon, "BOTTOMRIGHT", -6, 0)
			Button.Backdrop:SetPoint("RIGHT", Button, "RIGHT", -6, 0)

			Button.Icon:SetTexCoord(unpack(K.TexCoords))
			Button.Icon:SetDrawLayer("ARTWORK")
			Button.Icon.Backdrop = CreateFrame("Frame", nil, Button)
			Button.Icon.Backdrop:SetFrameLevel(Button:GetFrameLevel())
			Button.Icon.Backdrop:CreateBorder()
			Button.Icon.Backdrop:SetAllPoints(Button.Icon)

			Button.AutoCastShine = CreateFrame("Frame", "$parentShine", Button, "AutoCastShineTemplate")
			Button.AutoCastShine:SetParent(Button.Icon.Backdrop)
			Button.AutoCastShine:SetAllPoints()

			for _, sparks in pairs(Button.AutoCastShine.sparkles) do
				sparks:SetSize(sparks:GetWidth() * 2, sparks:GetHeight() * 2)
			end

			Button:SetScript("OnUpdate", function(self)
				if ImmersionFrame.TalkBox.Elements.chooseItems and ImmersionFrame.TalkBox.Elements.itemChoice == self:GetID() then
					AutoCastShine_AutoCastStart(self.AutoCastShine, 0, .44, .87 )
					self.Backdrop:SetBackdropBorderColor(0, 0.44, .87, 1)
				else
					self.Backdrop:SetBackdropBorderColor(1, 1, 1)
					AutoCastShine_AutoCastStop(self.AutoCastShine)
				end
			end)
		end

		if Button.CircleBackground then
			Button.CircleBackground:SetTexture()
			Button.CircleBackgroundGlow:SetTexture()

			hooksecurefunc(Button.ValueText, "SetText", function(self, text)
				Button.Count:SetText("+"..text) self:Hide()
			end)
		end
	end

	SkinReward(ImmersionFrame.TalkBox.Elements.Content.RewardsFrame.ArtifactXPFrame)
	SkinReward(ImmersionFrame.TalkBox.Elements.Content.RewardsFrame.HonorFrame)
	SkinReward(ImmersionFrame.TalkBox.Elements.Content.RewardsFrame.MoneyFrame)
	SkinReward(ImmersionFrame.TalkBox.Elements.Content.RewardsFrame.TitleFrame)
	SkinReward(ImmersionFrame.TalkBox.Elements.Content.RewardsFrame.SkillPointFrame)

	ImmersionFrame:HookScript("OnEvent", function(self)
		for _, Button in ipairs(self.TitleButtons.Buttons) do
			if Button and not Button.Backdrop then
				Button:CreateBackdrop()
				Button:SetBackdrop(nil)

				Button.Overlay:Hide()
				Button.Backdrop:SetPoint("TOPLEFT", Button, 3, -3)
				Button.Backdrop:SetPoint("BOTTOMRIGHT", Button, -3, 3)

				Button.Hilite:SetBackdrop({edgeFile = "Interface\\AddOns\\KkthnxUI\\Media\\Border\\Border_Glow_Overlay", edgeSize = 12})
				Button.Hilite:SetPoint("TOPLEFT", Button, 0, 0)
				Button.Hilite:SetPoint("BOTTOMRIGHT", Button, 0, 0)
				Button.Hilite:SetBackdropBorderColor(0, 0.44, .87, 1)

				Button:SetHighlightTexture("")
			end
		end

		for _, Button in ipairs(self.TalkBox.Elements.Content.RewardsFrame.Buttons) do
			if Button and not Button.Backdrop then
				SkinReward(Button)
			end
		end

		for _, Button in ipairs(self.TalkBox.Elements.Progress.Buttons) do
			if Button and not Button.Backdrop then
				Button:CreateBackdrop()
				Button.Icon:SetTexCoord(unpack(K.TexCoords))
				Button.Icon:SetDrawLayer("ARTWORK")

				Button.NameFrame:Hide()
				Button.Border:Hide()
				Button.Mask:Hide()

				Button.Backdrop:SetPoint("TOPLEFT", Button.Icon, "TOPRIGHT", 6, 0)
				Button.Backdrop:SetPoint("BOTTOMLEFT", Button.Icon, "BOTTOMRIGHT", -6, 0)
				Button.Backdrop:SetPoint("RIGHT", Button, "RIGHT", -6, 0)
			end
		end
	end)
end