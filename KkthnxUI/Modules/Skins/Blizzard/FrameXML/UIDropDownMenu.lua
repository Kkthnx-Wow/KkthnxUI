local K, C = KkthnxUI[1], KkthnxUI[2]

local table_insert = table.insert
local hooksecurefunc = hooksecurefunc

local function StyleBackdrop(backdrop)
	if backdrop and not backdrop.styled then
		backdrop:StripTextures()
		backdrop:CreateBorder()
		backdrop.styled = true
	end
end

local function StyleDropdownLevel(level)
	level = level or 1
	local listFrame = _G["DropDownList" .. level]
	for i = 1, _G.UIDROPDOWNMENU_MAXBUTTONS do
		local bu = _G["DropDownList" .. level .. "Button" .. i]
		local _, _, _, x = bu:GetPoint()
		if bu:IsShown() and x then
			local hl = _G["DropDownList" .. level .. "Button" .. i .. "Highlight"]
			local arrow = _G["DropDownList" .. level .. "Button" .. i .. "ExpandArrow"]
			if hl then
				hl:SetColorTexture(K.r, K.g, K.b, 0.25)
				hl:SetPoint("TOPLEFT", -x + 4, 0)
				hl:SetPoint("BOTTOMRIGHT", listFrame:GetWidth() - bu:GetWidth() - x - 4, 0)
			end
			if arrow then
				K.SetupArrow(arrow:GetNormalTexture(), "right")
				arrow:SetSize(14, 14)
			end
		end
	end
end

local function ApplyDropdownStyling()
	local dropdowns = { "DropDownList", "L_DropDownList", "Lib_DropDownList" }
	for _, name in ipairs(dropdowns) do
		for i = 1, _G.UIDROPDOWNMENU_MAXLEVELS do
			StyleBackdrop(_G[name .. i .. "Backdrop"])
		end
	end
end

table_insert(C.defaultThemes, function()
	if not C["Skins"].BlizzardFrames then
		return
	end

	hooksecurefunc("UIDropDownMenu_CreateFrames", ApplyDropdownStyling)
	hooksecurefunc("ToggleDropDownMenu", StyleDropdownLevel)
end)
