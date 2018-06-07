local K, C, L = unpack(select(2, ...))
local Module = K:GetModule("Skins")

local function SkinContribution()
	if C["Tooltip"].Enable then
		-- Reward Tooltip
		ContributionBuffTooltip:StripTextures()
		ContributionBuffTooltip:SetTemplate("Transparent")
		ContributionBuffTooltip:CreateBackdrop()
		ContributionBuffTooltip:StyleButton()
		ContributionBuffTooltip.Border:SetAlpha(0)
		ContributionBuffTooltip.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
		ContributionBuffTooltip.Backdrop:SetFrameLevel(1)
		ContributionBuffTooltip.Backdrop:SetOutside(ContributionBuffTooltip.Icon)

		-- Contribution Tooltip
		ContributionTooltip:StripTextures()
		ContributionTooltip:CreateBackdrop("Transparent")
		ContributionTooltip.ItemTooltip.IconBorder:SetAlpha(0)
		ContributionTooltip.ItemTooltip.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
		ContributionTooltip.ItemTooltip:CreateBackdrop()
		ContributionTooltip.ItemTooltip.Backdrop:SetOutside(ContributionTooltip.ItemTooltip.Icon)
	end
end

Module.SkinFuncs["Blizzard_Contribution"] = SkinContribution