local K, C = unpack(KkthnxUI)

local _G = _G
local table_insert = _G.table.insert

local hooksecurefunc = _G.hooksecurefunc
local UIDROPDOWNMENU_MAXLEVELS = _G.UIDROPDOWNMENU_MAXLEVELS
local UIDROPDOWNMENU_MAXBUTTONS = _G.UIDROPDOWNMENU_MAXBUTTONS

table_insert(C.defaultThemes, function()
	if not C["Skins"].BlizzardFrames then
		return
	end

	local r, g, b = K.r, K.g, K.b
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

	hooksecurefunc("ToggleDropDownMenu", function(level)
		if not level then
			level = 1
		end

		local listFrame = _G["DropDownList" .. level]
		for i = 1, UIDROPDOWNMENU_MAXBUTTONS do
			local bu = _G["DropDownList" .. level .. "Button" .. i]
			local _, _, _, x = bu:GetPoint()
			if bu:IsShown() and x then
				local hl = _G["DropDownList" .. level .. "Button" .. i .. "Highlight"]
				local arrow = _G["DropDownList" .. level .. "Button" .. i .. "ExpandArrow"]

				if hl then
					hl:SetColorTexture(r, g, b, 0.25)
					hl:SetPoint("TOPLEFT", -x + 4, 0)
					hl:SetPoint("BOTTOMRIGHT", listFrame:GetWidth() - bu:GetWidth() - x - 4, 0)
				end

				if arrow then
					K.SetupArrow(arrow:GetNormalTexture(), "right")
					arrow:SetSize(14, 14)
				end
			end
		end
	end)
end)
