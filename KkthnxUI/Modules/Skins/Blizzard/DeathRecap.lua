local K, C = unpack(KkthnxUI)

local _G = _G
local select = _G.select

C.themes["Blizzard_DeathRecap"] = function()
	local DeathRecapFrame = _G.DeathRecapFrame
	DeathRecapFrame.CloseXButton:SkinCloseButton()
	DeathRecapFrame:StripTextures()
	DeathRecapFrame:CreateBorder()

	for i = 1, 5 do
		local iconBorder = DeathRecapFrame["Recap" .. i].SpellInfo.IconBorder
		local icon = DeathRecapFrame["Recap" .. i].SpellInfo.Icon

		iconBorder:SetAlpha(0)
		icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
		DeathRecapFrame["Recap" .. i].SpellInfo:CreateBackdrop()
		DeathRecapFrame["Recap" .. i].SpellInfo.KKUI_Backdrop:SetAllPoints(icon)
		icon:SetParent(DeathRecapFrame["Recap" .. i].SpellInfo.Backdrop)
	end

	for i = 1, DeathRecapFrame:GetNumChildren() do
		local child = select(i, DeathRecapFrame:GetChildren())
		if (child:IsObjectType("Button") and child.GetText) and child:GetText() == CLOSE then
			child:SkinButton()
		end
	end
end
