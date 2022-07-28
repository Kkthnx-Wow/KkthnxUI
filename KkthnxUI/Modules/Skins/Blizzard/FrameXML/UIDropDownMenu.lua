local K, C = unpack(KkthnxUI)

local _G = _G
local table_insert = _G.table.insert

local hooksecurefunc = _G.hooksecurefunc

table_insert(C.defaultThemes, function()
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
				local check = _G["DropDownList" .. level .. "Button" .. i .. "Check"]
				local uncheck = _G["DropDownList" .. level .. "Button" .. i .. "UnCheck"]
				local hl = _G["DropDownList" .. level .. "Button" .. i .. "Highlight"]
				local arrow = _G["DropDownList" .. level .. "Button" .. i .. "ExpandArrow"]

				if not bu.bg then
					bu.bg = CreateFrame("Frame", nil, bu)
					bu.bg:CreateBorder()
					bu.bg:SetFrameLevel(bu:GetFrameLevel())
					bu.bg:ClearAllPoints()
					bu.bg:SetPoint("CENTER", check)
					bu.bg:SetSize(12, 12)
					hl:SetColorTexture(r, g, b, 0.25)

					if arrow then
						K.SetupArrow(arrow:GetNormalTexture(), "right")
						arrow:SetSize(14, 14)
					end
				end

				bu.bg:Hide()
				hl:SetPoint("TOPLEFT", -x + 3, 0)
				hl:SetPoint("BOTTOMRIGHT", listFrame:GetWidth() - bu:GetWidth() - x - 3, 0)
				if uncheck then
					uncheck:SetTexture("")
				end

				if not bu.notCheckable then
					-- only reliable way to see if button is radio or or check...
					local _, co = check:GetTexCoord()
					if co == 0 then
						check:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\Textures\\UI-CheckBox-Check")
						check:SetVertexColor(r, g, b, 1)
						check:SetSize(16, 16)
						check:SetDesaturated(true)
					else
						check:SetColorTexture(r, g, b, 0.6)
						check:SetSize(10, 10)
						check:SetDesaturated(false)
					end

					check:SetTexCoord(0, 1, 0, 1)
					bu.bg:Show()
				end
			end
		end
	end)

	hooksecurefunc("UIDropDownMenu_SetIconImage", function(icon, texture)
		if texture:find("Divider") then
			icon:SetColorTexture(1, 1, 1, 0.2)
			icon:SetHeight(K.Mult)
		end
	end)
end)
