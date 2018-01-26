local K, C, L = unpack(select(2, ...))

local _G = _G

local function LoadSkin()
	if C["Skins"].TalkingHead ~= true then return end

	TalkingHeadFrame:StripTextures()
	TalkingHeadFrame:CreateBackdrop("Transparent")
	TalkingHeadFrame.Backdrop:SetPoint("TOPLEFT", 13, -13)
	TalkingHeadFrame.Backdrop:SetPoint("BOTTOMRIGHT", -35, 11)

	TalkingHeadFrame.MainFrame:StripTextures()
	TalkingHeadFrame.PortraitFrame:StripTextures()
	TalkingHeadFrame.BackgroundFrame:StripTextures()

	TalkingHeadFrame.MainFrame.Model:CreateBackdrop("")
	TalkingHeadFrame.MainFrame.Model.Backdrop:SetAllPoints()
	TalkingHeadFrame.MainFrame.Model.Backdrop:SetFrameStrata("HIGH")
	TalkingHeadFrame.MainFrame.Model.Backdrop:SetFrameLevel(4)

	TalkingHeadFrame.MainFrame.CloseButton:SkinCloseButton()
	TalkingHeadFrame.MainFrame.CloseButton:SetPoint("TOPRIGHT", -39, -17)
end

K.SkinFuncs["Blizzard_TalkingHeadUI"] = LoadSkin