local K, C = unpack(KkthnxUI)

C.themes["Blizzard_ArchaeologyUI"] = function()
	local ArcDigProBar = ArcheologyDigsiteProgressBar

	ArcDigProBar:StripTextures()

	ArcDigProBar.FillBar:SetHeight(12)
	ArcDigProBar.FillBar:SetStatusBarTexture(K.GetTexture(C["General"].Texture))
	ArcDigProBar.FillBar:SetStatusBarColor(0.7, 0.3, 0.2)
	ArcDigProBar.FillBar:CreateBorder()

	local ArcSpark = ArcDigProBar.FillBar:CreateTexture(nil, "OVERLAY")
	ArcSpark:SetTexture(C["Media"].Textures.Spark16Texture)
	ArcSpark:SetHeight(ArcDigProBar:GetHeight())
	ArcSpark:SetBlendMode("ADD")
	ArcSpark:SetPoint("CENTER", ArcDigProBar.FillBar:GetStatusBarTexture(), "RIGHT", 0, 0)

	if ArcDigProBar.BarTitle then
		ArcDigProBar.BarTitle:ClearAllPoints()
		ArcDigProBar.BarTitle:SetPoint("BOTTOM", ArcDigProBar, "TOP", 0, -2)
		ArcDigProBar.BarTitle:SetFontObject(K.UIFont)
	end
end
