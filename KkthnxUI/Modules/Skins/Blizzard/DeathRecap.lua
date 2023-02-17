local K, C = KkthnxUI[1], KkthnxUI[2]

local select = select

C.themes["Blizzard_DeathRecap"] = function()
	local DeathRecapFrame = DeathRecapFrame

	DeathRecapFrame:DisableDrawLayer("BORDER")
	DeathRecapFrame.Background:Hide()
	DeathRecapFrame.BackgroundInnerGlow:Hide()
	DeathRecapFrame.Divider:Hide()

	DeathRecapFrame:CreateBorder()
	select(8, DeathRecapFrame:GetChildren()):SkinButton() -- bottom close button has no parentKey
	DeathRecapFrame.CloseXButton:SkinCloseButton()

	for i = 1, NUM_DEATH_RECAP_EVENTS do
		local recap = DeathRecapFrame["Recap" .. i].SpellInfo
		recap.IconBorder:Hide()
		recap.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
		recap:CreateBorder()
	end
end
