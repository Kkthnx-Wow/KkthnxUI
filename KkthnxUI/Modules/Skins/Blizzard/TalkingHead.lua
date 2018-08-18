local K = unpack(select(2, ...))
if K.CheckAddOnState("Immersion") then
	return
end

local Module = K:GetModule("Skins")

local _G = _G

local function SkinTalkingHead()
	local TalkingHeadFrame = _G["TalkingHeadFrame"]

	TalkingHeadFrame:StripTextures()
	TalkingHeadFrame.MainFrame:StripTextures(true)
	TalkingHeadFrame.PortraitFrame:StripTextures(true)
	TalkingHeadFrame.BackgroundFrame:StripTextures(true)
	TalkingHeadFrame.MainFrame.Model.PortraitBg:Hide()

	TalkingHeadFrame:CreateBackdrop()
	TalkingHeadFrame.Backdrop:SetPoint("TOPLEFT", 13, -13)
	TalkingHeadFrame.Backdrop:SetPoint("BOTTOMRIGHT", -35, 11)

	TalkingHeadFrame.MainFrame.Model:CreateBorder()

	TalkingHeadFrame.MainFrame.CloseButton:SkinCloseButton()
	TalkingHeadFrame.MainFrame.CloseButton:SetPoint("TOPRIGHT", -39, -17)
end

Module.SkinFuncs["Blizzard_TalkingHeadUI"] = SkinTalkingHead