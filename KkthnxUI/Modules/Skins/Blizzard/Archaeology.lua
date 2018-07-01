local K, C = unpack(select(2, ...))
local Module = K:GetModule("Skins")

local function SkinArcheologyDigsite()
	ArcheologyDigsiteProgressBar:StripTextures()
	ArcheologyDigsiteProgressBar.FillBar:StripTextures()
	ArcheologyDigsiteProgressBar.FillBar:SetStatusBarTexture(C["Media"].Texture)
	ArcheologyDigsiteProgressBar.FillBar:SetStatusBarColor(0.7, 0.2, 0)
    ArcheologyDigsiteProgressBar.FillBar:SetHeight(12)

    ArcheologyDigsiteProgressBar.FillBar.Background = ArcheologyDigsiteProgressBar.FillBar:CreateTexture(nil, "BACKGROUND", -2)
	ArcheologyDigsiteProgressBar.FillBar.Background:SetAllPoints()
	ArcheologyDigsiteProgressBar.FillBar.Background:SetColorTexture(C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Media"].BackdropColor[4])

	K.CreateBorder(ArcheologyDigsiteProgressBar.FillBar)

    ArcheologyDigsiteProgressBar.BarTitle:SetPoint("BOTTOM", ArcheologyDigsiteProgressBar, "TOP", 0, -2)
	ArcheologyDigsiteProgressBar.BarTitle:FontTemplate(nil, nil, 'OUTLINE')
	ArcheologyDigsiteProgressBar:ClearAllPoints()
	ArcheologyDigsiteProgressBar:SetPoint("TOP", UIParent, "TOP", 0, -400)
    UIPARENT_MANAGED_FRAME_POSITIONS["ArcheologyDigsiteProgressBar"] = nil

    K.Movers:RegisterFrame(ArcheologyDigsiteProgressBar)
end

Module.SkinFuncs["Blizzard_ArchaeologyUI"] = SkinArcheologyDigsite
