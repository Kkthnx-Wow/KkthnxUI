local K = unpack(select(2, ...))
local Module = K:GetModule("Skins")

local _G = _G

local function SkinNPETutorial()
    local tutorialFrame = NPE_TutorialKeyboardMouseFrame_Frame
    tutorialFrame.NineSlice:Hide()
    tutorialFrame:CreateBorder()
    tutorialFrame.TitleBg:Hide()
    tutorialFrame.portrait:SetAlpha(0)
    tutorialFrame.CloseButton:SkinCloseButton()
    NPE_TutorialKeyString:SetTextColor(1, 1, 1)
end

Module.NewSkin["Blizzard_Tutorial"] = SkinNPETutorial