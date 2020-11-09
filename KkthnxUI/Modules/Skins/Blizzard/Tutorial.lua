local _, C = unpack(select(2, ...))

C.themes["Blizzard_Tutorial"] = function()
    local tutorialFrame = NPE_TutorialKeyboardMouseFrame_Frame
    tutorialFrame.NineSlice:Hide()
    tutorialFrame:CreateBorder()
    tutorialFrame.TitleBg:Hide()
    tutorialFrame.portrait:SetAlpha(0)
    tutorialFrame.CloseButton:SkinCloseButton()
    NPE_TutorialKeyString:SetTextColor(1, 1, 1)
end