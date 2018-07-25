local K, C = unpack(select(2, ...))
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
	end
end

Module.SkinFuncs["Blizzard_Contribution"] = SkinContribution