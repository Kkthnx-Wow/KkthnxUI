local K, C = unpack(select(2, ...))
local Module = K:GetModule("Skins")

local function SkinContribution()
	if C["Tooltip"].Enable then
		-- Reward Tooltip
		ContributionBuffTooltip:StripTextures()
		ContributionBuffTooltip:CreateBorder()
		ContributionBuffTooltip:CreateBackdrop()
		ContributionBuffTooltip:StyleButton()
		ContributionBuffTooltip.Border:SetAlpha(0)
		ContributionBuffTooltip.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
		ContributionBuffTooltip.Backdrop:SetOutside(ContributionBuffTooltip.Icon)
		ContributionBuffTooltip.Backdrop:SetFrameLevel(ContributionBuffTooltip:GetFrameLevel())
	end
end

Module.SkinFuncs["Blizzard_Contribution"] = SkinContribution