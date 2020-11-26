local K, C = unpack(select(2, ...))

local _G = _G
local table_insert = _G.table.insert

table_insert(C.defaultThemes, function()
	for i = 1, 6 do
		select(i, GhostFrame:GetRegions()):Hide()
	end

	GhostFrameContentsFrameIcon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])

	local FrameIconBorderFrame = CreateFrame("Frame", nil, GhostFrameContentsFrameIcon:GetParent())
	FrameIconBorderFrame:SetAllPoints(GhostFrameContentsFrameIcon)
	FrameIconBorderFrame:SetFrameLevel(GhostFrame:GetFrameLevel() + 1)
	FrameIconBorderFrame:CreateBorder()

	GhostFrame:SkinButton()
end)