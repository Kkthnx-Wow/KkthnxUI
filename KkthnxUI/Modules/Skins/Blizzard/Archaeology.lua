local K, C = unpack(select(2, ...))

C.themes["Blizzard_ArchaeologyUI"] = function()
	-- ArcheologyDigsiteProgressBar
	ArcheologyDigsiteProgressBar:StripTextures()

	ArcheologyDigsiteProgressBar.FillBar:SetHeight(12)
	ArcheologyDigsiteProgressBar.FillBar:SetStatusBarTexture(C["Media"].Statusbars.KkthnxUIStatusbar)
	ArcheologyDigsiteProgressBar.FillBar:SetStatusBarColor(0.7, 0.3, 0.2)
	ArcheologyDigsiteProgressBar.FillBar:CreateBorder()

	local ArcSpark = ArcheologyDigsiteProgressBar.FillBar:CreateTexture(nil, "OVERLAY")
	ArcSpark:SetTexture(C["Media"].Textures.Spark16Texture)
	ArcSpark:SetHeight(ArcheologyDigsiteProgressBar:GetHeight())
	ArcSpark:SetBlendMode("ADD")
	ArcSpark:SetPoint("CENTER", ArcheologyDigsiteProgressBar.FillBar:GetStatusBarTexture(), "RIGHT", 0, 0)

	ArcheologyDigsiteProgressBar.BarTitle:ClearAllPoints()
	ArcheologyDigsiteProgressBar.BarTitle:SetPoint("BOTTOM", ArcheologyDigsiteProgressBar, "TOP", 0, -2)
	ArcheologyDigsiteProgressBar.BarTitle:SetFontObject(K.GetFont(C["UIFonts"].GeneralFonts))
end