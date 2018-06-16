local K = unpack(select(2, ...))
local Module = K:GetModule("Skins")

local function SkinDeathRecap()
    local DeathRecapFrame = _G["DeathRecapFrame"]
    DeathRecapFrame:StripTextures()
    DeathRecapFrame.CloseXButton:SkinCloseButton()
    DeathRecapFrame:SetTemplate("Transparent")
    DeathRecapFrame.CloseButton:SkinButton()

    for i = 1, 5 do
        local IconBorder = DeathRecapFrame["Recap" .. i].SpellInfo.IconBorder
        local Icon = DeathRecapFrame["Recap" .. i].SpellInfo.Icon

        IconBorder:SetAlpha(0)
        Icon:SetTexCoord(.08, .92, .08, .92)
        DeathRecapFrame["Recap" .. i].SpellInfo:CreateBackdrop()
        DeathRecapFrame["Recap" .. i].SpellInfo.Backdrop:SetOutside(Icon)
        Icon:SetParent(DeathRecapFrame["Recap" .. i].SpellInfo.Backdrop)
    end
end

Module.SkinFuncs["Blizzard_DeathRecap"] = SkinDeathRecap
