local K = unpack(select(2, ...))
local Module = K:GetModule("Skins")

local function SkinTalkingHead()
	TalkingHeadFrame:StripTextures(true)

    TalkingHeadFrame:CreateBorder()

	TalkingHeadFrame.MainFrame:StripTextures(true)
	TalkingHeadFrame.PortraitFrame:StripTextures(true)
	TalkingHeadFrame.BackgroundFrame:StripTextures(true)

    TalkingHeadFrame.MainFrame.Model:CreateBorder()

	TalkingHeadFrame.MainFrame.CloseButton:SkinCloseButton()
	TalkingHeadFrame.MainFrame.CloseButton:SetPoint("TOPRIGHT", -39, -17)
end

Module.SkinFuncs["Blizzard_TalkingHeadUI"] = SkinTalkingHead