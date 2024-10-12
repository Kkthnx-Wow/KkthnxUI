local C = KkthnxUI[2]

local table_insert = table.insert
local hooksecurefunc = hooksecurefunc

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
