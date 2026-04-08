--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Skins the Blizzard modern Menu (context menus).
-- - Design: Hooks OpenMenu/OpenContextMenu to apply KkthnxUI borders and strip textures.
-- - Events: N/A
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

-- REASON: Localize globals for performance and stack safety.
local _G = _G
local CreateFrame = _G.CreateFrame
local hooksecurefunc = _G.hooksecurefunc
local table_insert = _G.table.insert

local Menu = _G.Menu

-- REASON: Main entry point for Blizzard Menu skinning.
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
