local K, C = unpack(select(2, ...))
local Module = K:GetModule("Skins")

local _G = _G

local CreateFrame = _G.CreateFrame

local function ReskinDeathRecapFrame()
    local DeathRecapFrame = _G["DeathRecapFrame"]
    DeathRecapFrame:StripTextures()
	DeathRecapFrame:CreateBorder()
    DeathRecapFrame.CloseButton:SkinButton()

    for i = 1, 5 do
        local IconBorder = DeathRecapFrame["Recap" .. i].SpellInfo.IconBorder
        local Icon = DeathRecapFrame["Recap" .. i].SpellInfo.Icon

        IconBorder:SetAlpha(0)
        Icon:SetTexCoord(.08, .92, .08, .92)

        DeathRecapFrame["Recap" .. i].SpellInfo.Backgrounds = DeathRecapFrame["Recap" .. i].SpellInfo:CreateTexture(nil, "BACKGROUND", -2)
		DeathRecapFrame["Recap" .. i].SpellInfo.Backgrounds:SetAllPoints()
		DeathRecapFrame["Recap" .. i].SpellInfo.Backgrounds:SetColorTexture(C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Media"].BackdropColor[4])

		DeathRecapFrame["Recap" .. i].SpellInfo.Borders = CreateFrame("Frame", nil, DeathRecapFrame["Recap" .. i].SpellInfo)
		DeathRecapFrame["Recap" .. i].SpellInfo.Borders:SetFrameLevel(DeathRecapFrame["Recap" .. i].SpellInfo:GetFrameLevel() + 1)
		DeathRecapFrame["Recap" .. i].SpellInfo.Borders:SetAllPoints()
		K.CreateBorder(DeathRecapFrame["Recap" .. i].SpellInfo.Borders)

        DeathRecapFrame["Recap" .. i].SpellInfo.Backgrounds:SetOutside(Icon)
        DeathRecapFrame["Recap" .. i].SpellInfo.Borders:SetOutside(Icon)

        Icon:SetParent(DeathRecapFrame["Recap" .. i].SpellInfo.Borders)
    end
end

Module.NewSkin["Blizzard_DeathRecap"] = ReskinDeathRecapFrame