local K, C = unpack(select(2, ...))
local Module = K:GetModule("Skins")

local function SkinArcheologyDigsite()
	ArcheologyDigsiteProgressBar:StripTextures()
	ArcheologyDigsiteProgressBar.FillBar:StripTextures()
	ArcheologyDigsiteProgressBar.FillBar:SetStatusBarTexture(C["Media"].Texture)
	ArcheologyDigsiteProgressBar.FillBar:SetStatusBarColor(0.7, 0.2, 0)
    ArcheologyDigsiteProgressBar.FillBar:SetHeight(12)

	ArcheologyDigsiteProgressBar.FillBar:CreateBorder()

    ArcheologyDigsiteProgressBar.BarTitle:SetPoint("BOTTOM", ArcheologyDigsiteProgressBar, "TOP", 0, -2)
	ArcheologyDigsiteProgressBar.BarTitle:FontTemplate(nil, nil, 'OUTLINE')
end

Module.SkinFuncs["Blizzard_ArchaeologyUI"] = SkinArcheologyDigsite