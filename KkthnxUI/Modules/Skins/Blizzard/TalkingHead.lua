local K = unpack(select(2, ...))
if K.CheckAddOnState("Immersion") then
	return
end

local Module = K:GetModule("Skins")

local _G = _G

local function SkinTalkingHead()
	local TalkingHeadFrame = _G["TalkingHeadFrame"]

	TalkingHeadFrame:StripTextures(true)
	TalkingHeadFrame.MainFrame:StripTextures(true)
	TalkingHeadFrame.PortraitFrame:StripTextures(true)
	TalkingHeadFrame.BackgroundFrame:StripTextures(true)

	TalkingHeadFrame.MainFrame.Model:CreateInnerShadow()
	TalkingHeadFrame.MainFrame.Model.PortraitBg:Hide()

	TalkingHeadFrame:CreateBackdrop()
	TalkingHeadFrame.Backdrop:SetPoint("TOPLEFT", 13, -13)
	TalkingHeadFrame.Backdrop:SetPoint("BOTTOMRIGHT", -35, 11)

	TalkingHeadFrame.MainFrame.Model:CreateBorder()

	TalkingHeadFrame.NameFrame.Name:SetTextColor(1, 0.82, 0.02)
	TalkingHeadFrame.NameFrame.Name.SetTextColor = function() end
	TalkingHeadFrame.NameFrame.Name:SetShadowColor(0.0, 0.0, 0.0, 1.0)

	TalkingHeadFrame.TextFrame.Text:SetTextColor(1, 1, 1)
	TalkingHeadFrame.TextFrame.Text.SetTextColor = function() end
	TalkingHeadFrame.TextFrame.Text:SetShadowColor(0.0, 0.0, 0.0, 1.0)

	TalkingHeadFrame.MainFrame.CloseButton:SkinCloseButton()
	TalkingHeadFrame.MainFrame.CloseButton:SetPoint("TOPRIGHT", -39, -17)
end

Module.SkinFuncs["Blizzard_TalkingHeadUI"] = SkinTalkingHead