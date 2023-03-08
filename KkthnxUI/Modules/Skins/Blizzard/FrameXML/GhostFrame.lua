local K, C = KkthnxUI[1], KkthnxUI[2]

-- Import functions and variables
local table_insert = table.insert

-- Apply custom skin to Ghost Frame
table_insert(C.defaultThemes, function()
	-- Exit if Blizzard frames skinning is disabled
	if not C["Skins"].BlizzardFrames then
		return
	end

	-- Hide the default textures of Ghost Frame
	for i = 1, 6 do
		select(i, GhostFrame:GetRegions()):Hide()
	end

	-- Apply texture coordinates to the icon in Ghost Frame
	GhostFrameContentsFrameIcon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])

	-- Create a frame to be used as a border around the icon in Ghost Frame
	local FrameIconBorderFrame = CreateFrame("Frame", nil, GhostFrameContentsFrameIcon:GetParent())
	FrameIconBorderFrame:SetAllPoints(GhostFrameContentsFrameIcon)
	FrameIconBorderFrame:SetFrameLevel(GhostFrame:GetFrameLevel() + 1)
	FrameIconBorderFrame:CreateBorder()

	-- Apply skin to the button in Ghost Frame
	GhostFrame:SkinButton()
end)
