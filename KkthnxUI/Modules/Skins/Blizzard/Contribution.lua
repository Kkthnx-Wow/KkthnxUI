local K, C, L = unpack(select(2, ...))
local Module = K:GetModule("Skins")

local function SkinContribution()
	if C["Tooltip"].Enable then
		-- Reward Tooltip
		ContributionBuffTooltip:StripTextures()

		ContributionBuffTooltip.Backgrounds = ContributionBuffTooltip:CreateTexture(nil, "BACKGROUND", -2)
		ContributionBuffTooltip.Backgrounds:SetAllPoints()
		ContributionBuffTooltip.Backgrounds:SetColorTexture(C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Media"].BackdropColor[4])

		ContributionBuffTooltip.Borders = CreateFrame("Frame", nil, ContributionBuffTooltip)
		ContributionBuffTooltip.Borders:SetFrameLevel(ContributionBuffTooltip:GetFrameLevel() + 1)
		ContributionBuffTooltip.Borders:SetAllPoints()

		K.CreateBorder(ContributionBuffTooltip.Borders)

		ContributionBuffTooltip:StyleButton()
		ContributionBuffTooltip.Border:SetAlpha(0)
		ContributionBuffTooltip.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
		ContributionBuffTooltip.Backgrounds:SetOutside(ContributionBuffTooltip.Icon)
		ContributionBuffTooltip.Borders:SetOutside(ContributionBuffTooltip.Icon)

		-- Contribution Tooltip
		ContributionTooltip:StripTextures()

		ContributionTooltip.Backgrounds = ContributionTooltip:CreateTexture(nil, "BACKGROUND", -2)
		ContributionTooltip.Backgrounds:SetAllPoints()
		ContributionTooltip.Backgrounds:SetColorTexture(C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Media"].BackdropColor[4])

		K.CreateBorder(ContributionTooltip)

		ContributionTooltip.ItemTooltip.IconBorder:SetAlpha(0)
		ContributionTooltip.ItemTooltip.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])

		ContributionTooltip.ItemTooltip.Backgrounds = ContributionTooltip.ItemTooltip:CreateTexture(nil, "BACKGROUND", -2)
		ContributionTooltip.ItemTooltip.Backgrounds:SetAllPoints()
		ContributionTooltip.ItemTooltip.Backgrounds:SetColorTexture(C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Media"].BackdropColor[4])

		ContributionTooltip.ItemTooltip.Borders = CreateFrame("Frame", nil, ContributionTooltip.ItemTooltip)
		ContributionTooltip.ItemTooltip.Borders:SetFrameLevel(ContributionTooltip.ItemTooltip:GetFrameLevel() + 1)
		ContributionTooltip.ItemTooltip.Borders:SetAllPoints()

		K.CreateBorder(ContributionTooltip.ItemTooltip.Borders)

		ContributionTooltip.ItemTooltip.Backgrounds:SetOutside(ContributionTooltip.ItemTooltip.Icon)
		ContributionTooltip.ItemTooltip.Borders:SetOutside(ContributionTooltip.ItemTooltip.Icon)
	end
end

Module.SkinFuncs["Blizzard_Contribution"] = SkinContribution