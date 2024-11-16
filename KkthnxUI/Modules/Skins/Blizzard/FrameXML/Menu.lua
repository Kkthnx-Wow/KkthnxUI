local K, C = KkthnxUI[1], KkthnxUI[2]

local table_insert = table.insert

table_insert(C.defaultThemes, function()
	if not C["Skins"].BlizzardFrames then
		return
	end

	if not Menu then
		return
	end

	local menuManagerProxy = Menu.GetManager()

	local backdrops = {}

	local function skinMenu(menuFrame)
		menuFrame:StripTextures()

		if backdrops[menuFrame] then
			menuFrame.bg = backdrops[menuFrame]
		else
			menuFrame.bg = CreateFrame("Frame", nil, menuFrame, "BackdropTemplate")
			menuFrame.bg:SetFrameLevel(menuFrame:GetFrameLevel())
			menuFrame.bg:SetAllPoints(menuFrame)
			menuFrame.bg:CreateBorder()
			backdrops[menuFrame] = menuFrame.bg
		end
	end

	local function setupMenu(manager, _, menuDescription)
		local menuFrame = manager:GetOpenMenu()
		if menuFrame then
			skinMenu(menuFrame)
			menuDescription:AddMenuAcquiredCallback(skinMenu)
		end
	end

	hooksecurefunc(menuManagerProxy, "OpenMenu", setupMenu)
	hooksecurefunc(menuManagerProxy, "OpenContextMenu", setupMenu)
end)
