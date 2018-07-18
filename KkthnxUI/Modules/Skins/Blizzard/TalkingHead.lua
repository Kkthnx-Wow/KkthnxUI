local K, C, L, _ = unpack(select(2, ...))
local Module = K:GetModule("Skins")

local function SkinTalkingHead()
	TalkingHeadFrame:StripTextures(true)

    TalkingHeadFrame.Backgrounds = TalkingHeadFrame:CreateTexture(nil, "BACKGROUND", -2)
    TalkingHeadFrame.Backgrounds:SetAllPoints()
    TalkingHeadFrame.Backgrounds:SetPoint("TOPLEFT", 13, -13)
    TalkingHeadFrame.Backgrounds:SetPoint("BOTTOMRIGHT", -35, 11)
	TalkingHeadFrame.Backgrounds:SetColorTexture(C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Media"].BackdropColor[4])

	TalkingHeadFrame.Borders = CreateFrame("Frame", nil, TalkingHeadFrame)
    TalkingHeadFrame.Borders:SetAllPoints()
    TalkingHeadFrame.Borders:SetPoint("TOPLEFT", 13, -13)
    TalkingHeadFrame.Borders:SetPoint("BOTTOMRIGHT", -35, 11)
	K.CreateBorder(TalkingHeadFrame.Borders)

	TalkingHeadFrame.MainFrame:StripTextures(true)
	TalkingHeadFrame.PortraitFrame:StripTextures(true)
	TalkingHeadFrame.BackgroundFrame:StripTextures(true)

    TalkingHeadFrame.MainFrame.Model.Backgrounds = TalkingHeadFrame.MainFrame.Model:CreateTexture(nil, "BACKGROUND", -2)
    TalkingHeadFrame.MainFrame.Model.Backgrounds:SetAllPoints()
    TalkingHeadFrame.MainFrame.Model.Backgrounds:SetPoint("TOPLEFT", -1, 1)
    TalkingHeadFrame.MainFrame.Model.Backgrounds:SetPoint("BOTTOMRIGHT", 1, -1)
	TalkingHeadFrame.MainFrame.Model.Backgrounds:SetColorTexture(C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Media"].BackdropColor[4])

	TalkingHeadFrame.MainFrame.Model.Borders = CreateFrame("Frame", nil, TalkingHeadFrame.MainFrame.Model)
    TalkingHeadFrame.MainFrame.Model.Borders:SetAllPoints()
    TalkingHeadFrame.MainFrame.Model.Borders:SetPoint("TOPLEFT", -1, 1)
    TalkingHeadFrame.MainFrame.Model.Borders:SetPoint("BOTTOMRIGHT", 1, -1)
	K.CreateBorder(TalkingHeadFrame.MainFrame.Model.Borders)

	TalkingHeadFrame.MainFrame.CloseButton:SkinCloseButton()
	TalkingHeadFrame.MainFrame.CloseButton:SetPoint("TOPRIGHT", -39, -17)
end

Module.SkinFuncs["Blizzard_TalkingHeadUI"] = SkinTalkingHead