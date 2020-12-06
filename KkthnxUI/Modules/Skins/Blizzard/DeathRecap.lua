local K, C = unpack(select(2, ...))

local _G = _G
local select = _G.select
local unpack = _G.unpack

C.themes["Blizzard_DeathRecap"] = function()
	local DeathRecapFrame = _G.DeathRecapFrame
	DeathRecapFrame.CloseXButton:SkinCloseButton()
	DeathRecapFrame:StripTextures()
	DeathRecapFrame:CreateBorder()

	for i = 1, 5 do
		local iconBorder = DeathRecapFrame["Recap"..i].SpellInfo.IconBorder
		local icon = DeathRecapFrame["Recap"..i].SpellInfo.Icon

		iconBorder:SetAlpha(0)
		icon:SetTexCoord(unpack(K.TexCoords))
		DeathRecapFrame["Recap"..i].SpellInfo:CreateBackdrop()
		DeathRecapFrame["Recap"..i].SpellInfo.Backdrop:SetAllPoints(icon)
		icon:SetParent(DeathRecapFrame["Recap"..i].SpellInfo.Backdrop)
	end

	for i = 1, DeathRecapFrame:GetNumChildren() do
		local child = select(i, DeathRecapFrame:GetChildren())
		if (child:IsObjectType("Button") and child.GetText) and child:GetText() == CLOSE then
			child:SkinButton()
		end
	end
end