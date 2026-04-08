--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Skins the Blizzard UIDropDownMenu levels.
-- - Design: Hooks UIDropDownMenu_CreateFrames to apply custom borders to drop-down backdrops.
-- - Events: N/A
-----------------------------------------------------------------------------]]

local C = KkthnxUI[2]

-- REASON: Localize globals for performance and stack safety.
local _G = _G
local next = _G.next
local hooksecurefunc = _G.hooksecurefunc
local table_insert = _G.table.insert

local UIDROPDOWNMENU_MAXLEVELS = _G.UIDROPDOWNMENU_MAXLEVELS

-- REASON: Main entry point for Blizzard Dropdown Menu skinning.
table_insert(C.defaultThemes, function()
	if not C["Skins"].BlizzardFrames then
		return
	end

	-- DropDownMenu
	local dropdowns = { "DropDownList", "L_DropDownList", "Lib_DropDownList" }
	hooksecurefunc("UIDropDownMenu_CreateFrames", function()
		for _, name in next, dropdowns do
			for i = 1, UIDROPDOWNMENU_MAXLEVELS do
				local backdrop = _G[name .. i .. "Backdrop"]
				if backdrop and not backdrop.styled then
					backdrop:StripTextures()
					backdrop:CreateBorder()

					backdrop.styled = true
				end
			end
		end
	end)
end)
