local K, C = unpack(KkthnxUI)

local _G = _G
local table_insert = _G.table.insert

table_insert(C.defaultThemes, function()
	if not C["Skins"].BlizzardFrames then
		return
	end

	for i = 1, 6 do
		select(i, GhostFrame:GetRegions()):Hide()
	end

	GhostFrameContentsFrameIcon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])

	local FrameIconBorderFrame = CreateFrame("Frame", nil, GhostFrameContentsFrameIcon:GetParent())
	FrameIconBorderFrame:SetAllPoints(GhostFrameContentsFrameIcon)
	FrameIconBorderFrame:SetFrameLevel(GhostFrame:GetFrameLevel() + 1)
	FrameIconBorderFrame:CreateBorder()

	GhostFrame:SkinButton()

	-- local NPCFriendshipStatusBar = _G.NPCFriendshipStatusBar

	-- NPCFriendshipStatusBar:SetStatusBarTexture(K.GetTexture(C["General"].Texture))

	-- if not NPCFriendshipStatusBar.Spark then
	-- 	NPCFriendshipStatusBar.Spark = NPCFriendshipStatusBar:CreateTexture(nil, "OVERLAY")
	-- 	NPCFriendshipStatusBar.Spark:SetWidth(64)
	-- 	NPCFriendshipStatusBar.Spark:SetHeight(NPCFriendshipStatusBar:GetHeight())
	-- 	NPCFriendshipStatusBar.Spark:SetTexture(C["Media"].Textures.Spark128Texture)
	-- 	NPCFriendshipStatusBar.Spark:SetBlendMode("ADD")
	-- 	NPCFriendshipStatusBar.Spark:SetPoint("CENTER", NPCFriendshipStatusBar:GetStatusBarTexture(), "RIGHT", 0, 0)
	-- 	NPCFriendshipStatusBar.Spark:SetAlpha(0.5)
	-- end
end)
